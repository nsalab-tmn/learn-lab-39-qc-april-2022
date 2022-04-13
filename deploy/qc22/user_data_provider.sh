#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

# Get user details from provisioned state

export user_id=$(jq -r .id /tmp/user_data.out)
export user_login=$(jq -r .login /tmp/user_data.out)
export user_member_id=$(jq -r .entities[].member_id /tmp/user_data.out)
export user_password=$(jq -r .password /tmp/user_password.out)

jq -n --arg userid "$user_id"\
    --arg userlogin "$user_login"\
    --arg usermemberid "$user_member_id"\
    --arg userpassword "$user_password"\
    '{"id":$userid, "login":$userlogin, "member_id":$usermemberid, "password":$userpassword}'

# да, я сам охуел
# охуительная история лежит тут
# https://github.com/hashicorp/terraform/issues/13991
#printf '{"base64_encoded":"%s"}\n' $(echo "$(jq -c . /tmp/user_data.out)" | base64 -w 0)

#echo -n \' > /tmp/user_data.out && echo -n $(cat /tmp/user_data_tmp.out) >> /tmp/user_data.out && echo -n \' >> /tmp/user_data.out

#rm /tmp/user_data.out