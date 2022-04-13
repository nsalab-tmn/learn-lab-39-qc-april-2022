#!/bin/bash

eval "$(jq -r '@sh "url=\(.url) filter=\(.filter) counter=\(.counter) sleep=\(.sleep) prefix=\(.prefix)"')"

#record=$(cat /tmp/dns_add_record.out | jq -r .host)
#export url="https://${record::-1}"
#export filter="200 OK"
#export counter=40
#export sleep=60

initial=$counter
timeout=true
#available=0

echo $url > /tmp/web_keepalive_$prefix.vars
echo $filter >> /tmp/web_keepalive_$prefix.vars
echo $counter >> /tmp/web_keepalive_$prefix.vars
echo $sleep >> /tmp/web_keepalive_$prefix.vars 

rm /tmp/web_keepalive_$prefix.out 2&>1
#echo $url > /tmp/web_keepalive_$prefix.out

until [[ ! -z $(curl $url -s -L -I -o /tmp/web_keepalive_$prefix.out && cat /tmp/web_keepalive_$prefix.out | grep "$filter" | wc -l) || $counter -lt 0 ]]; do
#until [[ $available -gt 0 || $counter -lt 0 ]]; do
    #curl $url -o /tmp/web_keepalive_$prefix.out -s -L -I
    #if [ -e /tmp/web_keepalive_$prefix.out ]; then
    #    available=$(cat /tmp/web_keepalive_$prefix.out | grep "$filter" | wc -l)        
    #fi
    #printf '.'
    let counter--
    sleep $sleep
done

secs=$((initial - counter))
secs=$((secs*sleep))
if [ $counter -ne -1 ]; then
   timeout=false
fi

jq -n --arg seconds "$secs" --arg is_timeout "$timeout" '{"seconds_to_deploy":$seconds, "timeout":$is_timeout}'