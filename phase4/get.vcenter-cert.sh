#!/bin/bash

function getCertificate {
	local HOST="${1}"
	PAYLOAD=$(echo -n | openssl s_client -connect "${HOST}" 2>/dev/null)
	RESULT=$(echo "${PAYLOAD}" |  sed -e '1h;2,$H;$!d;g' -e 's/.*\(-----BEGIN\sCERTIFICATE-----.*-----END\sCERTIFICATE-----\).*/\1/g')
	printf "%s\n" "$RESULT"
	#printf "%s\n" "$RESULT" | sed ':a;N;$!ba;s/\n/\\\\n/g'
}

getCertificate "vcenter.lab01.metal:443"
