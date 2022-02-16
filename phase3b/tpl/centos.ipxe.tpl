#!ipxe
set mirror http://mirror.aarnet.edu.au/pub/centos/7/os/x86_64
set boot http://pxe.apnex.io
set kickstart $${boot}/centos.rke.ks

#static
ifopen net0
set net0/ip ${static_ip}
set net0/netmask ${static_netmask}
set net0/gateway ${static_gateway}
set dns ${static_dns}
echo ADDRESS-: $${net0/ip}
echo NETMASK-: $${net0/netmask}
echo GATEWAY-: $${net0/gateway}
echo DNS-----: $${dns}
kernel $${mirror}/images/pxeboot/vmlinuz initrd=initrd.img ks=$${kickstart} ksdevice=eth0 net.ifnames=0 biosdevname=0 ip=$${net0/ip}::$${net0/gateway}:$${net0/netmask}:centos:eth0:none nameserver=$${dns}
initrd $${mirror}/images/pxeboot/initrd.img
boot
