#!/bin/bash

VCSA="VMware-vCenter-Server-Appliance-7.0.3.00100-18778458_OVF10.ova"
docker run --rm -it \
	-e GOVC_URL='136.144.62.58' \
	-e GOVC_USERNAME='root' \
	-e GOVC_PASSWORD='%4CijQ}p$A' \
	-e GOVC_INSECURE=true \
	-v ${PWD}/${VCSA}:/iso/${VCSA} \
vmware/govc \
/govc import.spec /iso/${VCSA} | tr -d '\r' | jq --tab .

