#!/bin/bash

export VCSA_URL='${VCSA_URL}'
export VCSA_NAME='${VCSA_NAME}'
export VCSA_IP='${VCSA_IP}'
export VCSA_USERNAME='${VCSA_USERNAME}'
export VCSA_PASSWORD='${VCSA_PASSWORD}'
export VCSA_JSON='${VCSA_JSON}'
export GOVC_URL='${GOVC_URL}'
export GOVC_USERNAME='${GOVC_USERNAME}'
export GOVC_PASSWORD='${GOVC_PASSWORD}'
export GOVC_INSECURE='${GOVC_INSECURE}'

## set govc docker cmd
GOVC="docker run --rm -t"
GOVC+=" -e GOVC_URL"
GOVC+=" -e GOVC_USERNAME"
GOVC+=" -e GOVC_PASSWORD"
GOVC+=" -e GOVC_INSECURE"
GOVC+=" -v $${VCSA_JSON}:/iso/vcsa.json"
GOVC+=" vmware/govc /govc"

## import ova and power on
$${GOVC} import.ova --options=/iso/vcsa.json $${VCSA_URL}
$${GOVC} vm.change -vm $${VCSA_NAME} -g vmwarePhoton64Guest
$${GOVC} vm.power -on $${VCSA_NAME}

## login and retreive token
function vspLogin {
	local URL="https://$${VCSA_IP}:5480/rest/com/vmware/cis/session"
	curl -k --max-time 5 -X POST \
		--user "$${VCSA_USERNAME}:$${VCSA_PASSWORD}" \
		-H "Content-Type: application/json" \
		-H "Content-Length: 0" \
	"$${URL}" 2>/dev/null
}

## poll deployment status
function vspDeployment {
	local TOKEN=$1
	local URL="https://$${VCSA_IP}:5480/rest/vcenter/deployment"
	curl -k --max-time 5 -X GET \
		-H "vmware-api-session-id: $${TOKEN}" \
		-H "Content-Type: application/json" \
	"$${URL}" 2>/dev/null
}

## wait for APITOKEN
while [[ ! ($${TOKEN} =~ ([0-9a-zA-Z]+) && $${TOKEN} != "null") ]]; do
	printf "%s\n" "[ API ] ENDPOINT [ $${VCSA_IP}:5480 ] not alive, sleeping 10..."
	sleep 10
	TOKEN=$(vspLogin | jq -r '.value' 2>/dev/null)
done
echo "API Session TOKEN received [ $${TOKEN} ]"

## wait for RPMINSTALL
STATUS="RUNNING"
while [[ $${STATUS} != "SUCCEEDED" ]]; do
	BODY=$(vspDeployment $${TOKEN})
	TOTAL=$(echo -n $${BODY} | jq -r '.subtasks[0].value.progress.total' 2>/dev/null)
	COMPLETED=$(echo -n $${BODY} | jq -r '.subtasks[0].value.progress.completed' 2>/dev/null)
	MESSAGE=$(echo -n $${BODY} | jq -r '.subtasks[0].value.progress.message.default_message' 2>/dev/null)
	STATUS=$(echo -n $${BODY} | jq -r '.subtasks[0].value.status' 2>/dev/null)
	NEWLOG="[ VCSA ] rpminstall [ $${STATUS} - $${COMPLETED}/$${TOTAL} ] $${MESSAGE}"
	if [[ $${STATUS} != "" && $${STATUS} != "null" && $${NEWLOG} != "$${OLDLOG}" ]]; then
		printf "%s\n" "$${NEWLOG}"
		OLDLOG="$${NEWLOG}"
	fi
	sleep 5
done

## wait for FIRSTBOOT
STATUS="RUNNING"
while [[ $${STATUS} != "SUCCEEDED" ]]; do
	BODY=$(vspDeployment $${TOKEN})
	TOTAL=$(echo -n $${BODY} | jq -r '.subtasks[2].value.progress.total' 2>/dev/null)
	COMPLETED=$(echo -n $${BODY} | jq -r '.subtasks[2].value.progress.completed' 2>/dev/null)
	MESSAGE=$(echo -n $${BODY} | jq -r '.subtasks[2].value.progress.message.default_message' 2>/dev/null)
	STATUS=$(echo -n $${BODY} | jq -r '.subtasks[2].value.status' 2>/dev/null)
	NEWLOG="[ VCSA ] firstboot  [ $${STATUS} - $${COMPLETED}/$${TOTAL} ] $${MESSAGE}"
	if [[ $${STATUS} != "" && $${STATUS} != "null" && $${NEWLOG} != "$${OLDLOG}" ]]; then
		printf "%s\n" "$${NEWLOG}"
		OLDLOG="$${NEWLOG}"
	fi
	sleep 5
done
