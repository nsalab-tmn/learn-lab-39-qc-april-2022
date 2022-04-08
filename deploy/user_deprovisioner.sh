#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Unset project from user
curl -w -L -X PUT "https://$(cat /tmp/user_data.out | jq -r .domain.name)/v1/client/$(cat /tmp/user_data.out | jq -r .entities[].entity.id)/team/$(cat /tmp/user_data.out | jq -r .entities[].member_id)" -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $(head -c -1 /tmp/bearer)" -o /tmp/user_unset.out >/dev/null 2>&1 --data-raw '{
  "user": "'"$(cat /tmp/user_data.out | jq -r .id)"'",
  "role": "'"$(cat /tmp/user_data.out | jq -r .entities[].role.id)"'",
  "acl_list": [ ]
}'

# Exclude from client team
curl -w -L -g -X DELETE "https://$(cat /tmp/user_data.out | jq -r .domain.name)/v1/client/$(cat /tmp/user_data.out | jq -r .entities[].entity.id)/team/$(cat /tmp/user_data.out | jq -r .entities[].member_id)" -H "Authorization: Bearer $(cat /tmp/bearer)" >/dev/null 2>&1

# Unregister user
curl -w -L -X PATCH "https://$(cat /tmp/user_data.out | jq -r .domain.name)/v1/account/$(cat /tmp/user_data.out | jq -r .id)/unregister" -H "Authorization: Bearer $(cat /tmp/bearer)" -o /tmp/user_deregister.out >/dev/null 2>&1

#rm /tmp/bearer

#rm /tmp/user_deregister.out