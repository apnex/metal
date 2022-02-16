#!/bin/bash
%{ for nic in nics ~}
NIC="${nic.name}"
IP="${nic.ip}"
echo "$NIC : $IP"
EXISTS=$(nmcli connection show id $NIC 2>/dev/null 1>/dev/null && echo "true" || echo "false")
if [[ $EXISTS == "true" ]]; then
	nmcli connection down $NIC 2>/dev/null
	nmcli connection delete $NIC 2>/dev/null
fi
nmcli connection add type ethernet con-name $NIC ifname $NIC
nmcli connection modify $NIC \
	ipv4.method manual \
	ipv4.addresses $IP \
	ipv4.never-default yes
nmcli connection up $NIC
sleep 2

%{ endfor ~}
