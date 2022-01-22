{
	"Name": "${name}",
	"PowerOn": false,
	"InjectOvfEnv": true,
	"WaitForIP": true,
	"Deployment": "tiny",
	"DiskProvisioning": "thin",
	"IPProtocol": "IPv4",
	"Annotation": "VMware vCenter Server Appliance",
	"MarkAsTemplate": false,
	"NetworkMapping": [
		{
			"Name": "Network 1",
			"Network": "${network}"
		}
	],
	"PropertyMapping": [
		{
			"Key": "guestinfo.cis.deployment.node.type",
			"Value": "embedded"
		},
		{
			"Key": "guestinfo.cis.vmdir.first-instance",
			"Value": "True"
		},
		{
			"Key": "guestinfo.cis.vmdir.password",
			"Value": "${sso_password}"
		},
		{
			"Key": "guestinfo.cis.appliance.net.addr.family",
			"Value": "ipv4"
		},
		{
			"Key": "guestinfo.cis.appliance.net.mode",
			"Value": "static"
		},
		{
			"Key": "guestinfo.cis.appliance.net.addr",
			"Value": "${ip}"
		},
		{
			"Key": "guestinfo.cis.appliance.net.prefix",
			"Value": "${prefix}"
		},
		{
			"Key": "guestinfo.cis.appliance.net.gateway",
			"Value": "${gateway}"
		},
		{
			"Key": "guestinfo.cis.appliance.net.dns.servers",
			"Value": "${dns_servers}"
		},
		{
			"Key": "guestinfo.cis.appliance.ntp.servers",
			"Value": "${ntp_servers}"
		},
		{
			"Key": "guestinfo.cis.appliance.net.pnid",
			"Value": "${name}"
		},
		{
			"Key": "guestinfo.cis.appliance.root.passwd",
			"Value": "${os_password}"
		},
		{
			"Key": "guestinfo.cis.appliance.root.shell",
			"Value": "/bin/bash"
		},
		{
			"Key": "guestinfo.cis.appliance.ssh.enabled",
			"Value": "True"
		},
		{
			"Key": "guestinfo.cis.ceip_enabled",
			"Value": "False"
		},
		{
			"Key": "vami.domain.VMware-vCenter-Server-Appliance",
			"Value": "${sso_domain_name}"
		},
		{
			"Key": "guestinfo.cis.deployment.autoconfig",
			"Value": "True"
		}
	]
}
