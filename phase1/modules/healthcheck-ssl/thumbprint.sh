#!/bin/bash
read INPUT
ENDPOINT=$(echo "${INPUT}" | jq -r '.endpoint')
PORT=$(echo "${INPUT}" | jq -r '.port')

function getThumbprint {
	local PAYLOAD=$(echo -n | timeout 3 openssl s_client -connect "${ENDPOINT}:${PORT}" 2>/dev/null)
	local PRINT=$(echo "$PAYLOAD" | openssl x509 -noout -fingerprint -sha256 2>/dev/null)
	local REGEX='^(.*)=(([0-9A-Fa-f]{2}[:])+([0-9A-Fa-f]{2}))$'
	if [[ $PRINT =~ $REGEX ]]; then
		local TYPE=${BASH_REMATCH[1]}
		local CODE=${BASH_REMATCH[2]}
	fi
	#printf "%s\n" "${CODE}" |  sed "s/\(.*\)/\L\1/g" | sed "s/://g"
	printf "%s" "${CODE}"
}

if [[ -n $ENDPOINT ]]; then
	THUMBPRINT=$(getThumbprint "$ENDPOINT")
	read -r -d '' BODY <<-CONFIG
	{
		"endpoint": "${ENDPOINT}",
		"port": "${PORT}",
		"thumbprint": "${THUMBPRINT}"
	}
	CONFIG
	echo ${BODY} | jq '.'
else
	jq -s '{}'
fi
