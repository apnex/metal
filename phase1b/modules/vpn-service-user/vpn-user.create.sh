#!/bin/bash
set -e

## get POD from deployment
SELECTOR="name=control-vpn-deploy"
POD=$(kubectl get pods --selector=${SELECTOR} -o json | jq -r '.items[0] | .metadata.name')

## configure user
echo "POD [ ${POD} ]"
(kubectl exec -it ${POD} -- easyrsa build-client-full user1 nopass && echo "Success") || true
kubectl exec -it ${POD} -- ovpn_getclient user1 > user1.ovpn
