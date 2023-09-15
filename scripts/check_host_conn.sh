#!/bin/bash

set -x

HOSTS=host_list
i=0

date > host_status
echo ""

while read host;
do

    echo ""
    ((i=i+1))

    echo "############### HOST $i ################"
    ping -c 1 "$host" > /dev/null

    if [ $? -eq 0 ]; then
        echo "node $host ICMP is up"
    else
        echo "node $host ICMP is down"
    fi

    printf "$host = %s\\n" $(dig +short "$host")

    if nc -z -v -w1 "$host" 22 >/dev/null 2>&1; then
        echo "Found SSH port open on $host"
    else
        echo "Did not find open SSH port on $host"
    fi

done < $HOSTS >> host_status
