#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Login
curl -w -k -L -b /tmp/cookie -c /tmp/cookie -X POST -d '{"username":"'"$login"'","password":"'"$new_password"'"}' $endpoint/api/auth/login  -o /tmp/web_login.out >/dev/null 2>&1

# Start lab
curl -w -k -L -c /tmp/cookie -b /tmp/cookie -X GET -H 'Content-type: application/json' $endpoint/api/labs/$lab/nodes/start  -o /tmp/web_lab_start.out >/dev/null 2>&1
