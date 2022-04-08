#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Register zone
curl -w -L -X POST "$endpoint/v1/dns" -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $bearer"  -o /tmp/dns_register.out >/dev/null 2>&1 --data-raw '{
  "project": "'"$project"'",
  "name": "'"$zone"'"
}'

# Add A record
curl -w -L -X POST "$endpoint/v1/dns/$(cat /tmp/dns_register.out | jq -r .id)/record" -H 'Content-Type: application/json' -H 'Accept: application/json' -H "Authorization: Bearer $bearer" -o /tmp/dns_add_record.out >/dev/null 2>&1 --data-raw '{
  "type": "A",
  "host": "@",
  "ttl": 86400,
  "data": "'"$ip_address"'"
}'


# Leave admin token for deprovisioner
echo $bearer > /tmp/admin_bearer
