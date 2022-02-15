#!/bin/bash
export VCSA_NAME='${VCSA_NAME}'
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
GOVC+=" vmware/govc /govc"

## import ova and power on
$${GOVC} vm.destroy $${VCSA_NAME}
