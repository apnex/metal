locals {
	ssh_user		= "root"
	ssh_key_name		= "equinix-key"
	project			= var.project
	metro			= var.metro
	plan			= var.plan
	operating_system	= var.operating_system
	hostname		= var.hostname
}

### build project
resource "metal_project" "myproject" {
	name	= local.project
}

### build metal gateway
resource "metal_vlan" "external" {
	description	= "external public VLAN"
	metro		= local.metro
	project_id	= metal_project.myproject.id
}

resource "metal_reserved_ip_block" "external" {
	project_id	= metal_project.myproject.id
	metro		= local.metro
	type		= "public_ipv4"
	quantity	= 8
}

resource "metal_gateway" "gateway" {
	project_id		= metal_project.myproject.id
	vlan_id			= metal_vlan.external.id
	ip_reservation_id	= metal_reserved_ip_block.external.id
}

### build SSH key
resource "tls_private_key" "ssh_key_pair" {
	algorithm = "RSA"
	rsa_bits  = 4096
}

resource "metal_ssh_key" "ssh_pub_key" {
	name       = local.ssh_key_name
	public_key = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
	depends_on = [
		metal_project.myproject
	]
}

resource "local_file" "project_private_key_pem" {
	content         = chomp(tls_private_key.ssh_key_pair.private_key_pem)
	filename        = pathexpand("~/.ssh/${local.ssh_key_name}")
	file_permission = "0600"
	provisioner "local-exec" {
		command = "cp ~/.ssh/${local.ssh_key_name} ~/.ssh/${local.ssh_key_name}.bak"
	}
}

## deploy esx node
resource "metal_device" "esx" {
	project_id		= metal_project.myproject.id
	metro			= local.metro
	plan			= local.plan
	operating_system	= local.operating_system
	hostname		= local.hostname
	billing_cycle		= "hourly"
	depends_on = [
		metal_ssh_key.ssh_pub_key
	]
}

### SET NETWORK TYPES
locals {
	bond0_id = [for p in metal_device.esx.ports: p.id if p.name == "bond0"][0]
	eth1_id = [for p in metal_device.esx.ports: p.id if p.name == "eth1"][0]
}

# Add VLAN to Switch Port
resource "metal_port" "esx_hosts" {
	## port not tagged - use vlan 0 on esx vmnic3 uplink
	bonded   = false
	port_id  = local.eth1_id
	vlan_ids = [metal_vlan.external.id]
	reset_on_delete = true
}

# healthcheck for ESX API response
module "esx-api-check" {
	source		= "./modules/healthcheck-ssl"
	endpoint	=  metal_device.esx.access_public_ipv4
	depends_on	= [
		metal_device.esx,
		metal_port.esx_hosts
	]
}
