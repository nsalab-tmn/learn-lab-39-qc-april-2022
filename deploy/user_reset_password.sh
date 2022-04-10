# Reset user password
eval "$(jq -r '@sh "endpoint=\(.endpoint) user_id=\(.user_id) bearer=\(.bearer)"')"

curl -X PATCH "$endpoint/v1/account/$user_id/reset_password" -H "Authorization: Bearer $bearer" 