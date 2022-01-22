#!/bin/bash
ovftool --noSSLVerify \
	--name=vcenter.lab01.metal \
	--datastore=datastore1 \
	--deploymentOption=tiny \
	--diskMode=thin \
	--powerOn \
	--X:waitForIp \
	--acceptAllEulas \
	--X:injectOvfEnv \
	--X:enableHiddenProperties \
	--allowExtraConfig \
	--sourceType=OVA \
	--X:logFile=./moo.log \
	--X:logLevel=verbose \
	--X:logTransferHeaderData \
	--net:"Network 1"=external \
	--prop:guestinfo.cis.deployment.autoconfig=True \
	--prop:guestinfo.cis.deployment.node.type=embedded \
	--prop:guestinfo.cis.vmdir.first-instance=True \
	--prop:guestinfo.cis.vmdir.password=VMware1!SDDC \
	--prop:guestinfo.cis.vmdir.domain-name=vsphere.local \
	--prop:guestinfo.cis.appliance.root.passwd=VMware1!SDDC \
	--prop:guestinfo.cis.appliance.ssh.enabled=True \
	--prop:guestinfo.cis.appliance.net.gateway=136.144.62.25 \
	--prop:guestinfo.cis.appliance.net.pnid=vcenter.lab01.metal \
	--prop:guestinfo.cis.appliance.net.mode=static \
	--prop:guestinfo.cis.appliance.net.dns.servers=136.144.62.26 \
	--prop:guestinfo.cis.appliance.net.addr.family=ipv4 \
	--prop:guestinfo.cis.appliance.net.prefix=29 \
	--prop:guestinfo.cis.appliance.net.addr=136.144.62.27 \
	--prop:guestinfo.cis.appliance.ntp.servers=216.239.35.12 \
	--prop:guestinfo.cis.ceip_enabled=False \
	--prop:guestinfo.cis.system.vm0.port=443 \
http://iso.apnex.io/VMware-vCenter-Server-Appliance-7.0.3.00100-18778458_OVF10.ova \
vi://root:gyM9FBp22^@136.144.62.58:443
