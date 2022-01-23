#!/bin/bash

VSPHOST="vcenter.lab01.metal:5480"
VSPUSER='root'
VSPPASS='VMware1!SDDC'

function vspLogin {
	local URL="https://${VSPHOST}/rest/com/vmware/cis/session"

	### DEBUG ###
	#printf "%s\n" "VSPUSER: ${VSPUSER}" 1>&2
	#printf "%s\n" "VSPPASS: ${VSPPASS}" 1>&2
	#curl -k --trace-ascii /dev/stdout -w "%  {http_code}" -X POST \
	#	--user "${VSPUSER}:${VSPPASS}" \
	#	-H "Content-Type: application/json" \
	#	-H "Content-Length: 0" \
	#"${URL}" 1>&2
	### DEBUG ###

	curl -k --max-time 5 -X POST \
		--user "${VSPUSER}:${VSPPASS}" \
		-H "Content-Type: application/json" \
		-H "Content-Length: 0" \
	"${URL}" 2>/dev/null
}

function vspDeployment {
	local TOKEN=$1
	local URL="https://${VSPHOST}/rest/vcenter/deployment"
	curl -k --max-time 5 -X GET \
		-H "vmware-api-session-id: ${TOKEN}" \
		-H "Content-Type: application/json" \
	"${URL}" 2>/dev/null
}

## check for APITOKEN
ALIVE=0
while [[ $ALIVE == 0 ]]; do
	TOKEN=$(vspLogin | jq -r '.value')
	if [[ -n ${TOKEN} ]]; then
		echo "API Session TOKEN received [ ${TOKEN} ]"
		ALIVE=1
	else
		printf "%s\n" "[ API ] ENDPOINT [ vcenter.lab01.metal:5480 ] not alive, sleeping 10..."
		sleep 10
	fi
done

## check for RPMINSTALL
STATUS="RUNNING"
while [[ $STATUS != "SUCCEEDED" ]]; do
	BODY=$(vspDeployment ${TOKEN})
	TOTAL=$(echo -n ${BODY} | jq -r '.subtasks[0].value.progress.total' 2>/dev/null)
	COMPLETED=$(echo -n ${BODY} | jq -r '.subtasks[0].value.progress.completed' 2>/dev/null)
	MESSAGE=$(echo -n ${BODY} | jq -r '.subtasks[0].value.progress.message.default_message' 2>/dev/null)
	STATUS=$(echo -n ${BODY} | jq -r '.subtasks[0].value.status' 2>/dev/null)
	if [[ ${STATUS} != "" ]]; then
		printf "%s\n" "[ VCSA ] rpminstall [ ${STATUS} - ${COMPLETED} / ${TOTAL} ] ${MESSAGE}"
	fi
	sleep 10
done

## check for FIRSTBOOT
STATUS="RUNNING"
while [[ $STATUS != "SUCCEEDED" ]]; do
	BODY=$(vspDeployment ${TOKEN})
	TOTAL=$(echo -n ${BODY} | jq -r '.subtasks[2].value.progress.total' 2>/dev/null)
	COMPLETED=$(echo -n ${BODY} | jq -r '.subtasks[2].value.progress.completed' 2>/dev/null)
	MESSAGE=$(echo -n ${BODY} | jq -r '.subtasks[2].value.progress.message.default_message' 2>/dev/null)
	STATUS=$(echo -n ${BODY} | jq -r '.subtasks[2].value.status' 2>/dev/null)
	if [[ ${STATUS} != "" ]]; then
		printf "%s\n" "[ VCSA ] firstboot  [ ${STATUS} - ${COMPLETED} / ${TOTAL} ] ${MESSAGE}"
	fi
	sleep 10
done
