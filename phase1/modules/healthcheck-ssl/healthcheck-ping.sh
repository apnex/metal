#!/bin/bash
ALIVE=0
if [[ -n $ENDPOINT ]]; then
	while [[ $ALIVE == 0 ]]; do
		if [[ $(ping -W 1 -c 1 "${ENDPOINT}" &>/dev/null && echo 1 || echo 0) == 1 ]]; then
			ALIVE=1
		else
			printf "%s\n" "[ PING ] ENDPOINT [ $ENDPOINT ] waiting for response.. sleep 10"
			sleep 10
		fi
	done
	printf "%s\n" "[ PING ] ENDPOINT [ $ENDPOINT ] is ALIVE !!!"
else
	printf "%s\n" "[ PING ] ERROR - ENDPOINT env not set!"
fi
