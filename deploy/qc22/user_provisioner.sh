#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Register user
curl -w -L -X POST "$endpoint/v1/account" -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $bearer" -o /tmp/user_register.out >/dev/null 2>&1 --data-raw '{
    "username":"'"$username"'",
    "login":"'"$login"'",
    "domain": "'"$domain"'",
    "email": "'"$email"'",
    "phone": "",
    "is_activated":true,
    "is_banned":false,
    "roles":[],
    "entities": [
            {
                "id": "'"$entity"'",
                "type": "'"$type"'",
                "role": "'"$role"'"
            }
    ]
}'

# Get full user details
curl -w -L -X GET "$endpoint/v1/account/$(cat /tmp/user_register.out | jq -r .id)" -H 'Accept: application/json' -H "Authorization: Bearer $bearer" -o /tmp/user_data.out >/dev/null 2>&1

# Set project to user
curl -w -L -X PUT "$endpoint/v1/client/$(cat /tmp/user_data.out | jq -r .entities[].entity.id)/team/$(cat /tmp/user_data.out | jq -r .entities[].member_id)" -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $bearer" -o /tmp/user_set.out >/dev/null 2>&1 --data-raw '{
  "user": "'"$(cat /tmp/user_register.out | jq -r .id)"'",
  "role": "'"$role"'",
  "acl_list": [
    {
      "id": "'"$project"'",
      "type": "project"
    }
  ]
}'

# Reset user password
curl -w -L -X PATCH "$endpoint/v1/account/$(cat /tmp/user_register.out | jq -r .id)/reset_password" -H "Authorization: Bearer $bearer" -o /tmp/user_password.out >/dev/null 2>&1 

# Leave bearer token for deprovisioner
echo $bearer > /tmp/bearer

