#cloud-config
debug:
  verbose: true
cloud_init_modules:
 - migrator
 - seed_random
 - write-files
 - growpart
 - resizefs
 - set_hostname
 - update_hostname
 - update_etc_hosts
 - users-groups
 - ssh
 - runcmd
 - write_files
chpasswd:
  list: |
    root:${admin_pass}
  expire: false
write_files:
- path: /opt/ovf/ovfconfig.sh
  content: |
    #!/bin/bash

    # Check if VM is alredy configured
    if [[ -e /opt/ovf/.configured ]]; then
        exit
    fi

    . ~/.profile

    # Setting Management Network
    cat > /etc/network/interfaces << EOF
    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).

    # The loopback network interface
    auto lo
    iface lo inet loopback

    # The primary network interface
    iface eth0 inet manual

    auto pnet0
    iface pnet0 inet dhcp
      bridge_ports eth0
      bridge_stp off
      dns-nameservers 8.8.8.8 8.8.4.4
    EOF

    service networking restart

    # Setting the NTP server
    sed -i 's/NTPDATE_USE_NTP_CONF=.*/NTPDATE_USE_NTP_CONF=yes/g' /etc/default/ntpdate
    sed -i 's/NTPSERVERS=.*/NTPSERVERS=/g' /etc/default/ntpdate

    # Cleaning
    rm -rf /root/.bash_history /opt/unetlab/tmp/* /tmp/netio* /tmp/vmware* /opt/ovf/ovf_vars /opt/ovf/ovf.xml /root/.bash_history /root/.cache
    find /var/log -type f -exec rm -f {} \;
    find /var/lib/apt/lists -type f -exec rm -f {} \;
    find /opt/unetlab/data/Logs -type f -exec rm -f {} \;
    touch /var/log/wtmp
    chown root:utmp /var/log/wtmp
    chmod 664 /var/log/wtmp

    touch /opt/ovf/.configured
  owner: root:root
  permissions: '0644'
- path: /opt/deploy.sh
  content: |
    #!/bin/bash
        
    bash /opt/install-eve.sh > /opt/install-eve.out 2>&1
    bash /opt/eve-bootstrap.sh > /opt/eve-bootstrap.out 2>&1
    bash /opt/install-nginx.sh > /opt/install-nginx.out 2>&1
    #bash /opt/get-images.sh > /opt/get-images.out 2>&1    
    bash /opt/ovf/ovfconfig.sh > /opt/ovfconfig.out 2>&1
    
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
  owner: root:root
  permissions: '0644'
- path: /opt/install-nginx.sh
  content: |
    #!/bin/bash
    
    apt-get update
    apt-get install nginx -y
    IP=`ip -4 a l eth0 | awk '/inet/ {print $2}' | cut -d/ -f1`
    cat <<EOT > /etc/nginx/sites-available/default
    server {
        listen $IP:80 default_server;
        return 301 https://\$host\$request_uri;
    }

    server {
        listen              443 ssl default_server;
        ssl_certificate     /etc/ssl/certs/qc22.pem;
        ssl_certificate_key /etc/ssl/private/qc22.key;

      location / {
        proxy_pass http://127.0.0.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP \$remote_addr;
        }
    }
    EOT
    systemctl restart nginx
  owner: root:root
  permissions: '0644'
- path: /opt/eve-bootstrap.sh
  content: |
    #!/bin/bash
    
    #Login as admin
    curl -m 10 -b /tmp/cookie -c /tmp/cookie -X POST -d '{"username":"admin","password":"eve"}' http://127.0.0.1/api/auth/login

    #Change admin password
    curl -m 10 -c /tmp/cookie -b /tmp/cookie -X PUT -d '{"name":"admin","email":"root@localhost","password":"${admin_pass}","role":"admin","expiration":"-1","pod":0,"pexpiration":"-1"}' -H 'Content-type: application/json' http://127.0.0.1/api/users/admin
  owner: root:root
  permissions: '0644'
- path: /opt/install-eve.sh
  content: |
    #!/bin/bash
    
    wget -O - http://www.eve-ng.net/repo/eczema@ecze.com.gpg.key | sudo apt-key add -
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common

    echo "deb [arch=amd64] http://www.eve-ng.net/repo xenial main" > /etc/apt/sources.list.d/eve-ng.list
    apt-get update

    DEBIAN_FRONTEND=noninteractive apt-get -y install eve-ng
    /etc/init.d/mysql restart
    DEBIAN_FRONTEND=noninteractive apt-get -y install eve-ng
    rm -fr /var/lib/docker/aufs
    DEBIAN_FRONTEND=noninteractive apt-get -y install eve-ng
    cp /lib/firmware/bnx2/*.fw /lib/firmware/4.9.40-eve-ng-ukms-2+/bnx2/

    mv /opt/unetlab.conf /etc/apache2/sites-available/
    sed -i 's/ 80/ 127.0.0.1:80/' /etc/apache2/ports.conf
    systemctl reload apache2
  owner: root:root
  permissions: '0644'
- path: /opt/get-images.sh
  content: |
    #!/bin/bash

    apt-get -y update
    DEBIAN_FRONTEND=noninteractive apt-get -y install awscli
    aws configure set region "EU" --profile default
    aws configure set aws_access_key_id ${s3_access_key} --profile default
    aws configure set aws_secret_access_key ${s3_secret_key} --profile default
    mkdir -p /opt/unetlab/addons/qemu
    aws s3 sync --endpoint-url ${s3_endpoint} s3://${s3_bucket} /opt/unetlab/addons/qemu/
    
  owner: root:root
  permissions: '0644'
- path: /etc/ssl/certs/qc22.pem
  content: |
    -----BEGIN CERTIFICATE-----
    MIIFOTCCBCGgAwIBAgISAwMQMq0lLx2o3qy3LwOx3vKSMA0GCSqGSIb3DQEBCwUA
    MDIxCzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQswCQYDVQQD
    EwJSMzAeFw0yMjA0MDgxMzMzMDNaFw0yMjA3MDcxMzMzMDJaMCUxIzAhBgNVBAMM
    GioucWMyMi5za2lsbHNjbG91ZC5jb21wYW55MIIBIjANBgkqhkiG9w0BAQEFAAOC
    AQ8AMIIBCgKCAQEAvWzRf2r62Kva17KYw7tFrSkIWHoCz9xYg777YZQv8afm6Sb/
    NezaBTzMPJSeJ24fhrptUcnBGc8cHMNSV2R9OPWiJ3icaHU6WY9EY1Z85fNOMMQo
    HvAtA0e/SvBdly1e4RRyLoDWPcnhoLQQnrX3KSN5m1KEyrLQpizz6keOZfSrDL7P
    218Of8Jq3xgVNLYV92jDrZeU4jVI0Ss2XajQPEu07DZy+g2UikBIDInXA+BEvMS+
    b2gy0ziaEvArMJRENPweZr86Ysq69k8GSJJFcfMSXKeRPE3Dxf8ebjEziWCFcvML
    KD1gdkLib65TuyLviEJj0Ik+CV3jklCkPIUnIwIDAQABo4ICVDCCAlAwDgYDVR0P
    AQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMB
    Af8EAjAAMB0GA1UdDgQWBBToNGAw6IeQIrRoymSOexr7FonogjAfBgNVHSMEGDAW
    gBQULrMXt1hWy65QCUDmH6+dixTCxjBVBggrBgEFBQcBAQRJMEcwIQYIKwYBBQUH
    MAGGFWh0dHA6Ly9yMy5vLmxlbmNyLm9yZzAiBggrBgEFBQcwAoYWaHR0cDovL3Iz
    LmkubGVuY3Iub3JnLzAlBgNVHREEHjAcghoqLnFjMjIuc2tpbGxzY2xvdWQuY29t
    cGFueTBMBgNVHSAERTBDMAgGBmeBDAECATA3BgsrBgEEAYLfEwEBATAoMCYGCCsG
    AQUFBwIBFhpodHRwOi8vY3BzLmxldHNlbmNyeXB0Lm9yZzCCAQMGCisGAQQB1nkC
    BAIEgfQEgfEA7wB2AEHIyrHfIkZKEMahOglCh15OMYsbA+vrS8do8JBilgb2AAAB
    gAmXxiMAAAQDAEcwRQIgFVEZAf/OydYDm9fwIW0bIQ7eVEJCm0wAzyApeGcKWEQC
    IQDXwpQ5meFsIYc9nogqYb9uo7La/thM8u6AK/2x9oa7XgB1AEalVet1+pEgMLWi
    iWn0830RLEF0vv1JuIWr8vxw/m1HAAABgAmXxj0AAAQDAEYwRAIgRz4tRUNZofQL
    v8mF4d1VOKtMa4Y4DcT8P+uiHuTCpdQCIA/1ZdIlCKo/Abd1gyjVpA8cNnEeT6b7
    JUAwe99RDtouMA0GCSqGSIb3DQEBCwUAA4IBAQArbPiYeNTH6/Y04wj4/FAtEKsH
    cmMuqNBDLBnf1+eyWg9ik5fiO/Xt4cPCGZaDrIgsfBB0zwxue9M4XtD6HLo5LGcD
    BdO1InqcrV8aWtMMR1hYdY5ho4lej6OTRlY/i4YMwqqObEc7eWJURgOGOHCvNOwX
    KGYVIk5W07IlgnY/8GZM41vXF2BM3vwHy5tj2mfk3VkLmzjxwvvt/vPYylL7jwJV
    dBdmaZSQCke2AYV3sV+EhXCHQWzJd6PDC1s/Cm7RZVybiyEQce98QXe3NhcLUal8
    RWErVUbENJOPdM8R/JDqWRuIyx6VdDUY9x42Jwsoyoqr+3GfIF+t5AkYShD8
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    MIIFFjCCAv6gAwIBAgIRAJErCErPDBinU/bWLiWnX1owDQYJKoZIhvcNAQELBQAw
    TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
    cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMjAwOTA0MDAwMDAw
    WhcNMjUwOTE1MTYwMDAwWjAyMQswCQYDVQQGEwJVUzEWMBQGA1UEChMNTGV0J3Mg
    RW5jcnlwdDELMAkGA1UEAxMCUjMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
    AoIBAQC7AhUozPaglNMPEuyNVZLD+ILxmaZ6QoinXSaqtSu5xUyxr45r+XXIo9cP
    R5QUVTVXjJ6oojkZ9YI8QqlObvU7wy7bjcCwXPNZOOftz2nwWgsbvsCUJCWH+jdx
    sxPnHKzhm+/b5DtFUkWWqcFTzjTIUu61ru2P3mBw4qVUq7ZtDpelQDRrK9O8Zutm
    NHz6a4uPVymZ+DAXXbpyb/uBxa3Shlg9F8fnCbvxK/eG3MHacV3URuPMrSXBiLxg
    Z3Vms/EY96Jc5lP/Ooi2R6X/ExjqmAl3P51T+c8B5fWmcBcUr2Ok/5mzk53cU6cG
    /kiFHaFpriV1uxPMUgP17VGhi9sVAgMBAAGjggEIMIIBBDAOBgNVHQ8BAf8EBAMC
    AYYwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMBIGA1UdEwEB/wQIMAYB
    Af8CAQAwHQYDVR0OBBYEFBQusxe3WFbLrlAJQOYfr52LFMLGMB8GA1UdIwQYMBaA
    FHm0WeZ7tuXkAXOACIjIGlj26ZtuMDIGCCsGAQUFBwEBBCYwJDAiBggrBgEFBQcw
    AoYWaHR0cDovL3gxLmkubGVuY3Iub3JnLzAnBgNVHR8EIDAeMBygGqAYhhZodHRw
    Oi8veDEuYy5sZW5jci5vcmcvMCIGA1UdIAQbMBkwCAYGZ4EMAQIBMA0GCysGAQQB
    gt8TAQEBMA0GCSqGSIb3DQEBCwUAA4ICAQCFyk5HPqP3hUSFvNVneLKYY611TR6W
    PTNlclQtgaDqw+34IL9fzLdwALduO/ZelN7kIJ+m74uyA+eitRY8kc607TkC53wl
    ikfmZW4/RvTZ8M6UK+5UzhK8jCdLuMGYL6KvzXGRSgi3yLgjewQtCPkIVz6D2QQz
    CkcheAmCJ8MqyJu5zlzyZMjAvnnAT45tRAxekrsu94sQ4egdRCnbWSDtY7kh+BIm
    lJNXoB1lBMEKIq4QDUOXoRgffuDghje1WrG9ML+Hbisq/yFOGwXD9RiX8F6sw6W4
    avAuvDszue5L3sz85K+EC4Y/wFVDNvZo4TYXao6Z0f+lQKc0t8DQYzk1OXVu8rp2
    yJMC6alLbBfODALZvYH7n7do1AZls4I9d1P4jnkDrQoxB3UqQ9hVl3LEKQ73xF1O
    yK5GhDDX8oVfGKF5u+decIsH4YaTw7mP3GFxJSqv3+0lUFJoi5Lc5da149p90Ids
    hCExroL1+7mryIkXPeFM5TgO9r0rvZaBFOvV2z0gp35Z0+L4WPlbuEjN/lxPFin+
    HlUjr8gRsI3qfJOQFy/9rKIJR0Y/8Omwt/8oTWgy1mdeHmmjk7j1nYsvC9JSQ6Zv
    MldlTTKB3zhThV1+XWYp6rjd5JW1zbVWEkLNxE7GJThEUG3szgBVGP7pSWTUTsqX
    nLRbwHOoq7hHwg==
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    MIIFYDCCBEigAwIBAgIQQAF3ITfU6UK47naqPGQKtzANBgkqhkiG9w0BAQsFADA/
    MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
    DkRTVCBSb290IENBIFgzMB4XDTIxMDEyMDE5MTQwM1oXDTI0MDkzMDE4MTQwM1ow
    TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
    cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwggIiMA0GCSqGSIb3DQEB
    AQUAA4ICDwAwggIKAoICAQCt6CRz9BQ385ueK1coHIe+3LffOJCMbjzmV6B493XC
    ov71am72AE8o295ohmxEk7axY/0UEmu/H9LqMZshftEzPLpI9d1537O4/xLxIZpL
    wYqGcWlKZmZsj348cL+tKSIG8+TA5oCu4kuPt5l+lAOf00eXfJlII1PoOK5PCm+D
    LtFJV4yAdLbaL9A4jXsDcCEbdfIwPPqPrt3aY6vrFk/CjhFLfs8L6P+1dy70sntK
    4EwSJQxwjQMpoOFTJOwT2e4ZvxCzSow/iaNhUd6shweU9GNx7C7ib1uYgeGJXDR5
    bHbvO5BieebbpJovJsXQEOEO3tkQjhb7t/eo98flAgeYjzYIlefiN5YNNnWe+w5y
    sR2bvAP5SQXYgd0FtCrWQemsAXaVCg/Y39W9Eh81LygXbNKYwagJZHduRze6zqxZ
    Xmidf3LWicUGQSk+WT7dJvUkyRGnWqNMQB9GoZm1pzpRboY7nn1ypxIFeFntPlF4
    FQsDj43QLwWyPntKHEtzBRL8xurgUBN8Q5N0s8p0544fAQjQMNRbcTa0B7rBMDBc
    SLeCO5imfWCKoqMpgsy6vYMEG6KDA0Gh1gXxG8K28Kh8hjtGqEgqiNx2mna/H2ql
    PRmP6zjzZN7IKw0KKP/32+IVQtQi0Cdd4Xn+GOdwiK1O5tmLOsbdJ1Fu/7xk9TND
    TwIDAQABo4IBRjCCAUIwDwYDVR0TAQH/BAUwAwEB/zAOBgNVHQ8BAf8EBAMCAQYw
    SwYIKwYBBQUHAQEEPzA9MDsGCCsGAQUFBzAChi9odHRwOi8vYXBwcy5pZGVudHJ1
    c3QuY29tL3Jvb3RzL2RzdHJvb3RjYXgzLnA3YzAfBgNVHSMEGDAWgBTEp7Gkeyxx
    +tvhS5B1/8QVYIWJEDBUBgNVHSAETTBLMAgGBmeBDAECATA/BgsrBgEEAYLfEwEB
    ATAwMC4GCCsGAQUFBwIBFiJodHRwOi8vY3BzLnJvb3QteDEubGV0c2VuY3J5cHQu
    b3JnMDwGA1UdHwQ1MDMwMaAvoC2GK2h0dHA6Ly9jcmwuaWRlbnRydXN0LmNvbS9E
    U1RST09UQ0FYM0NSTC5jcmwwHQYDVR0OBBYEFHm0WeZ7tuXkAXOACIjIGlj26Ztu
    MA0GCSqGSIb3DQEBCwUAA4IBAQAKcwBslm7/DlLQrt2M51oGrS+o44+/yQoDFVDC
    5WxCu2+b9LRPwkSICHXM6webFGJueN7sJ7o5XPWioW5WlHAQU7G75K/QosMrAdSW
    9MUgNTP52GE24HGNtLi1qoJFlcDyqSMo59ahy2cI2qBDLKobkx/J3vWraV0T9VuG
    WCLKTVXkcGdtwlfFRjlBz4pYg1htmf5X6DYO8A4jqv2Il9DjXA6USbW1FzXSLr9O
    he8Y4IWS6wY7bCkjCWDcRQJMEhg76fsO3txE+FiYruq9RUWhiF1myv4Q6W+CyBFC
    Dfvp7OOGAN6dEOM4+qR9sdjoSYKEBpsr6GtPAQw4dy753ec5
    -----END CERTIFICATE-----

  owner: root:root
  permissions: '0644'
- path: /etc/ssl/private/qc22.key
  content: |
    -----BEGIN PRIVATE KEY-----
    MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC9bNF/avrYq9rX
    spjDu0WtKQhYegLP3FiDvvthlC/xp+bpJv817NoFPMw8lJ4nbh+Gum1RycEZzxwc
    w1JXZH049aIneJxodTpZj0RjVnzl804wxCge8C0DR79K8F2XLV7hFHIugNY9yeGg
    tBCetfcpI3mbUoTKstCmLPPqR45l9KsMvs/bXw5/wmrfGBU0thX3aMOtl5TiNUjR
    KzZdqNA8S7TsNnL6DZSKQEgMidcD4ES8xL5vaDLTOJoS8CswlEQ0/B5mvzpiyrr2
    TwZIkkVx8xJcp5E8TcPF/x5uMTOJYIVy8wsoPWB2QuJvrlO7Iu+IQmPQiT4JXeOS
    UKQ8hScjAgMBAAECggEBAKXZ8i/S1iEBj1HOIK03edEcHR+CbJXcQm/PtsAABF5c
    ePPo3gk0AMwXKGdeZH73j4jiD7dNo9HaIa4ZYi38YRuPDdPraV6YTWd+5gzn++FG
    P065YLt95Jt7pUSS4g7sfacqxLJswahF61ROdELR5b7SPbY98OCc4cytjT6yOj6P
    ESIYIcUfMw/MHvUTL0VwDLGbaOL7MRcphVTb+VSshiyPNr+Ha5nOnvuINK+FTIX4
    AXXEqOGx07iX2At5MDVaSjBZDkaE+oU8Q2Z7xMjJPVzqq6Bdf3avoGgCdmuArSte
    rXYVdART0BN+TUVHDGp082tU2/iSXGrnMyuGUDElIVkCgYEA6hiJkRnwWEgitNl5
    fHrmGGVgUawupfvb8oFEK5G1BZezN5Te8GXV9eUK1CyKsj+8b0rKxGD37o+IzYq3
    2Sck1MtL6/DNBN88k5sZvndydgysVn6FLwd1o4CaLQPI9GSo+a0e8kPGYR+L3Gvf
    BZ3Yk8JAWj3taRU2zfv0QYJ09jcCgYEAzyZAGtTKaAEeOENPrDlPIrRKqxL3FjG9
    VBaxSSxWUoqfw8m2tiJMeANqP3oba3lMKbjist+BfqhrFgKT19q2lVPW9H09SRE5
    STgwlgAlutGjp1PFqtwP1K25kvINKNl9SijwZT719VW7U0nP8u4PdIB1NQ+BG6p0
    1l/5Y2ckYHUCgYBFg5XOLbquLHWJ6I5nxYLwOaJZfly300tj/rjEi1cK2xpP5fgx
    wLvBcgs+KB/jgIOvNLFzkSvuflbsWkXvyOzp95iK7o2i5btyRXtmkMe/gFHouVdJ
    ONjY/YZK2bXhxMZcpejrne6ZxqlcgffPDilS7zr20S7fpnoIvsmwblHXDwKBgQCS
    kCyxDzd6aLgZ9L4NS6sLEeb2rX93C5A6S6f57s3QrtYlL7X/nbre+wOUj++Qlgzm
    RDLZfjvgAodp1j8GbW/brasb5vSSmwYeIQx3RPls+eDBhgsIPZVR0+zF5E6dRWxZ
    KSgVanuZrqPQZRwldHwo4K6M8UBW876g4tzPkO1y9QKBgQDTfammxl8TmzlkzodJ
    Fa8SSiIWl0GFmtVzkKP+YWEulv8oszo2ZHRbeI8mC09kbBbgah+0J0XGZNZJ2gF8
    ohDtafSTm7gj/lKPjDoQkJ2bOCPjOs9AGCdI8L7o+bRIT3sCoY5EdIiMEbuoUy0W
    qpk/qhHuqLZsGjH9NGzH+peAdw==
    -----END PRIVATE KEY-----

  owner: root:root
  permissions: '0600'
- path: /opt/unetlab.conf
  content: |
    # vim: syntax=apache ts=4 sw=4 sts=4 sr noet

    ServerName eve-ng

    <IfModule mod_rewrite.c>
            # Logging disabled by default
            # LogLevel mod_rewrite.c:trace2
    </IfModule>

    <Directory /opt/unetlab/html/>
            Options FollowSymLinks
            AllowOverride All
            Require all granted
    </Directory>

    <Directory /opt/unetlab/data/Exports/>
            Options FollowSymLinks Indexes
            AllowOverride All
            Require all granted
    </Directory>

    <Directory /opt/unetlab/data/Logs/>
            Options FollowSymLinks Indexes
            AllowOverride All
            Require all granted
    </Directory>
    <VirtualHost 127.0.0.1:80>
            ServerAdmin webmaster@unl01.example.com
            DocumentRoot /opt/unetlab/html

            ErrorLog /opt/unetlab/data/Logs/error.txt
            CustomLog /opt/unetlab/data/Logs/access.txt combined

            Alias /Exports /opt/unetlab/data/Exports
            Alias /Logs /opt/unetlab/data/Logs

            <Location /html5/>
                    Order allow,deny
                    Allow from all
                    ProxyPass http://127.0.0.1:8080/guacamole/ flushpackets=on
                    ProxyPassReverse http://127.0.0.1:8080/guacamole/
            </Location>

            <Location /html5/websocket-tunnel>
                    Order allow,deny
                    Allow from all
                    ProxyPass ws://127.0.0.1:8080/guacamole/websocket-tunnel
                    ProxyPassReverse ws://127.0.0.1:8080/guacamole/websocket-tunnel
            </Location>
    </VirtualHost>

  owner: root:root
  permissions: '0644'
runcmd:
- sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
- service sshd restart
- bash /opt/deploy.sh
- reboot