#!/bin/bash

CURRENT_SESSION=$(who -m)
echo $CURRENT_SESSION
read -ra arr <<<"$CURRENT_SESSION"

USER=${arr[0]}
PID=${arr[1]}
IP=${arr[4]}
IP1=$(echo $IP | sed -e 's/)//g')
IP2=$(echo $IP1 | sed -e 's/(//g')
echo "IP2: $IP2"


