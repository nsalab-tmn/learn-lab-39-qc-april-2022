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
    
    bash /opt/install-eve.sh 
    #rm -f /opt/install-eve.sh

    bash /opt/get-images.sh
    #rm /opt/get-images.sh

    bash /opt/eve-bootstrap.sh
    #rm /opt/eve-bootstrap.sh

    bash /opt/ovf/ovfconfig.sh
    #rm /opt/ovf/ovfconfig.sh

    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
  owner: root:root
  permissions: '0644'
- path: /opt/eve-bootstrap.sh
  content: |
    #!/bin/bash
    
    #Login as admin
    curl -s -b /tmp/cookie -c /tmp/cookie -X POST -d '{"username":"admin","password":"eve"}' http://127.0.0.1/api/auth/login

    #Change admin password
    curl -s -c /tmp/cookie -b /tmp/cookie -X PUT -d '{"name":"admin","email":"root@localhost","password":"${admin_pass}","role":"admin","expiration":"-1","pod":0,"pexpiration":"-1"}' -H 'Content-type: application/json' http://127.0.0.1/api/users/admin
  owner: root:root
  permissions: '0644'
- path: /opt/get-images.sh
  content: |
    #!/bin/bash

    apt-get -y update
    apt-get -y install awscli
    aws configure set region "EU" --profile default
    aws configure set aws_access_key_id ${s3_access_key} --profile default
    aws configure set aws_secret_access_key ${s3_secret_key} --profile default
    mkdir -p /opt/unetlab/addons/qemu
    aws s3 sync --endpoint-url ${s3_endpoint} s3://${s3_bucket} /opt/unetlab/addons/qemu/
    
  owner: root:root
  permissions: '0644'
runcmd:
- sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
- service sshd restart
- wget -O - http://www.eve-ng.net/repo/install-eve.sh > /opt/install-eve.sh
- bash /opt/deploy.sh >> /opt/deploy.log
- reboot