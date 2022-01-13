#!/bin/bash
function getThumbprint {
	local PAYLOAD=$(echo -n | timeout 3 openssl s_client -connect "${ENDPOINT}" 2>/dev/null)
	local PRINT=$(echo "$PAYLOAD" | openssl x509 -noout -fingerprint -sha256 2>/dev/null)
	local REGEX='^(.*)=(([0-9A-Fa-f]{2}[:])+([0-9A-Fa-f]{2}))$'
	if [[ $PRINT =~ $REGEX ]]; then
		local TYPE=${BASH_REMATCH[1]}
		local CODE=${BASH_REMATCH[2]}
	fi
	printf "%s" "${CODE}"
}

if [[ -n $ENDPOINT ]]; then
	ALIVE=0
	while [[ $ALIVE == 0 ]]; do
		THUMBPRINT=$(getThumbprint "$ENDPOINT")
		if [[ -n $THUMBPRINT ]]; then
			ALIVE=1
		else
			printf "%s\n" "[ SSL ] ENDPOINT [ $ENDPOINT ] waiting for response.. sleep 10"
			sleep 10
		fi
	done
	printf "%s\n" "[ SSL ] ENDPOINT [ $ENDPOINT ] is ALIVE !!!" 1>&2
fi
