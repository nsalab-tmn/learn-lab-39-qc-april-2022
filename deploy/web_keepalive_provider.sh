#!/bin/bash

initial=$counter
timeout=true
available=0

until [[ $available -gt 0 || $counter -lt 0 ]]; do
    curl $url -o /tmp/web_keepalive.out -s -L 
    if [ -e /tmp/web_keepalive.out ]; then
        available=$(cat /tmp/web_keepalive.out | grep $filter | wc -l)
        rm /tmp/web_keepalive.out 2&>1
    fi
    #printf '.'
    let counter--
    sleep $sleep
done

secs=$(((initial - counter)*sleep))
 if [ $counter -ne -1 ]; then
   timeout=false
fi

jq -n --arg seconds "$secs" --arg is_timeout "$timeout" '{"seconds_to_deploy":$seconds, "timeout":$is_timeout}'