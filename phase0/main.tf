locals {
	ssh_user		= "root"
	ssh_key_name		= "equinix-key"
	project			= var.project
	metro			= var.metro
	plan			= var.plan
	operating_system	= var.operating_system
	hostname		= var.hostname
}

### detect project
data "metal_project" "myproject" {
	name	= local.project
}

### create SSH key
resource "tls_private_key" "ssh_key_pair" {
	algorithm = "RSA"
	rsa_bits  = 4096
}
resource "metal_ssh_key" "ssh_pub_key" {
	name       = local.ssh_key_name
	public_key = chomp(tls_private_key.ssh_key_pair.public_key_openssh)
	depends_on = [
		data.metal_project.myproject
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
	project_id		= data.metal_project.myproject.id
	metro			= local.metro
	plan			= local.plan
	operating_system	= local.operating_system
	hostname		= local.hostname
	billing_cycle		= "hourly"
	depends_on = [
		metal_ssh_key.ssh_pub_key
	]
}

### detect device ports
locals {
	bond0_id = [for p in metal_device.esx.ports: p.id if p.name == "bond0"][0]
	eth1_id = [for p in metal_device.esx.ports: p.id if p.name == "eth1"][0]
}

### build Metal networking
resource "metal_vlan" "external" {
	description	= "external public VLAN"
	metro		= local.metro
	project_id	= data.metal_project.myproject.id
}
resource "metal_reserved_ip_block" "external" {
	project_id	= data.metal_project.myproject.id
	metro		= local.metro
	type		= "public_ipv4"
	quantity	= 16
}
resource "metal_gateway" "gateway" {
	project_id		= data.metal_project.myproject.id
	vlan_id			= metal_vlan.external.id
	ip_reservation_id	= metal_reserved_ip_block.external.id
}

# add VLAN to Bond (hybrid-bond)
# https://metal.equinix.com/developers/docs/layer2-networking/hybrid-bonded-mode/
resource "metal_port" "bond0" {
	port_id		= local.bond0_id
	bonded		= true
	layer2		= false
	vlan_ids	= [metal_vlan.external.id]
	reset_on_delete = true
}

# healthcheck for ESX API response
module "esx-api-check" {
	source		= "./modules/healthcheck-ssl"
	endpoint	=  metal_device.esx.access_public_ipv4
	depends_on	= [
		metal_device.esx,
		metal_port.bond0
	]
}
