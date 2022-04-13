#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Delete record
curl -w -L -X DELETE "https://$(cat /tmp/user_data.out | jq -r .domain.name)/v1/dns/$(cat /tmp/dns_register.out | jq -r .id)/record/$(cat /tmp/dns_add_record.out | jq -r .id)" -H "Authorization: Bearer $(head -c -1 /tmp/admin_bearer)" -o /tmp/dns_delete_record.out >/dev/null 2>&1

# Deregister zone
curl -w -L -X DELETE "https://$(cat /tmp/user_data.out | jq -r .domain.name)/v1/dns/$(cat /tmp/dns_register.out | jq -r .id)" -H "Authorization: Bearer $(head -c -1 /tmp/admin_bearer)" -o /tmp/dns_deregister.out >/dev/null 2>&1

