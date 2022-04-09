#!/bin/bash

record=$(cat /tmp/dns_add_record.out | jq -r .host)
export url="https://${record::-1}"
export filter="200 OK"
export counter=200
export sleep=5

initial=$counter
timeout=true
#available=0

echo $url > /tmp/web_keepalive.vars
echo $filter >> /tmp/web_keepalive.vars
echo $counter >> /tmp/web_keepalive.vars
echo $sleep >> /tmp/web_keepalive.vars 

rm /tmp/web_keepalive.out 2&>1
#echo $url > /tmp/web_keepalive.out

until [[ ! -z $(curl $url -s -L -I -o /tmp/web_keepalive.out && cat /tmp/web_keepalive.out | grep "$filter" | wc -l) || $counter -lt 0 ]]; do
#until [[ $available -gt 0 || $counter -lt 0 ]]; do
    #curl $url -o /tmp/web_keepalive.out -s -L -I
    #if [ -e /tmp/web_keepalive.out ]; then
    #    available=$(cat /tmp/web_keepalive.out | grep "$filter" | wc -l)        
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