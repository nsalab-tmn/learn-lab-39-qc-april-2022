#!/bin/bash

# Exit if any of the intermediate steps fail
#set -e

#rm /tmp/web_login.out > /dev/null
#rm /tmp/web_passwd.out > /dev/null
#rm /tmp/web_lab_start.out > /dev/null

# Login as admin
curl -w -k -L -b /tmp/cookie -c /tmp/cookie -X POST -d '{"username":"'"$login"'","password":"'"$old_password"'"}' $endpoint/api/auth/login -o /tmp/web_login_$prefix.out >/dev/null 2>&1

# Change admin password
curl -w -k -L -c /tmp/cookie -b /tmp/cookie -X PUT -d '{"name":"'"$login"'","email":"root@localhost","password":"'"$new_password"'","role":"admin","expiration":"-1","pod":0,"pexpiration":"-1"}' -H 'Content-type: application/json' $endpoint/api/users/admin -o /tmp/web_passwd_$prefix.out >/dev/null 2>&1

# Login
#curl -w -k -L -b /tmp/cookie -c /tmp/cookie -X POST -d '{"username":"'"$login"'","password":"'"$new_password"'"}' $endpoint/api/auth/login  -o /tmp/web_login_$prefix.out >/dev/null 2>&1

# Start lab
#curl -w -k -L -c /tmp/cookie -b /tmp/cookie -X GET -H 'Content-type: application/json' $endpoint/api/labs/$lab/nodes/start  -o /tmp/web_lab_start_$prefix.out >/dev/null 2>&1
