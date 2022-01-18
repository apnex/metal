#!/bin/bash
ENDPOINT=$1
while [[ $(ping -W 1 -c 1 "${ENDPOINT}" &>/dev/null && echo 1 || echo 0) == 0 ]]; do
	printf "%s\n" "Waiting for ENDPOINT [ $ENDPOINT ] to respond.. sleep 30"
	sleep 30
done
printf "%s\n" "ENDPOINT [ $ENDPOINT ] is ALIVE !!!"
