# Outputs
locals {
	esx = {
		hostname	: metal_device.esx.hostname,
		address		: metal_device.esx.access_public_ipv4,
		username	: "root",
		password	: nonsensitive(metal_device.esx.root_password)
	}
	network = {
		cidr		: metal_reserved_ip_block.external.cidr_notation,
		prefix		: metal_reserved_ip_block.external.cidr,
		netmask		: metal_reserved_ip_block.external.netmask,
		gateway		: cidrhost(metal_reserved_ip_block.external.cidr_notation, 1),
		dns		: "8.8.8.8",
		allocation	: {
			gateway		: cidrhost(metal_reserved_ip_block.external.cidr_notation, 1),
			controller	: cidrhost(metal_reserved_ip_block.external.cidr_notation, 2),
			vcenter		: cidrhost(metal_reserved_ip_block.external.cidr_notation, 3),
			adminws		: cidrhost(metal_reserved_ip_block.external.cidr_notation, 4),
			admin01		: cidrhost(metal_reserved_ip_block.external.cidr_notation, 5),
			admin02		: cidrhost(metal_reserved_ip_block.external.cidr_notation, 6),
			admin03		: cidrhost(metal_reserved_ip_block.external.cidr_notation, 7)
		}
	}
}
output "esx" {
	value = local.esx
}

output "network" {
	value = local.network
}

# render outputs to file
resource "local_file" "outputs" {
	filename = "./state/outputs.json"
	content = jsonencode({
		esx	: local.esx,
		network	: local.network
	})
}

