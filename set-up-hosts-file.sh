#!/bin/bash
# This runs as root.
lava-network broadcast eth0
lava-network collect eth0
lava-group | sort | \
awk '{ role=$2; rolecounts[role]+=1; printf $1 " " $2 "%02d\n", rolecounts[role] }' | \
while read host testname; do
    echo $(lava-network query $host ipv4) $testname $host >> /etc/hosts
done
