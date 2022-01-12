locals {
	ssh_user	= "root"
	ssh_key_name	= "equinix-key"
}

### build project
resource "metal_project" "myproject" {
	name	= "labops"
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
	metro			= "sy"
	plan			= "c3.small.x86"
	operating_system	= "vmware_esxi_7_0"
	hostname		= "core"
	billing_cycle		= "hourly"
	depends_on = [
		metal_ssh_key.ssh_pub_key
	]
}

### build METAL GATEWAY
resource "metal_vlan" "external" {
	description	= "external test VLAN in SY"
	metro		= "sy"
	project_id	= metal_project.myproject.id
}

resource "metal_reserved_ip_block" "external" {
	project_id	= metal_project.myproject.id
	metro		= "sy"
	type		= "public_ipv4"
	quantity	= 8
}

resource "metal_gateway" "gateway" {
	project_id		= metal_project.myproject.id
	vlan_id			= metal_vlan.external.id
	ip_reservation_id	= metal_reserved_ip_block.external.id
}

### SET NETWORK TYPES
locals {
	bond0_id = [for p in metal_device.esx.ports: p.id if p.name == "bond0"][0]
	eth1_id = [for p in metal_device.esx.ports: p.id if p.name == "eth1"][0]
}

# Add VLAN to Switch Port
resource "metal_port" "esx_hosts" {
	## port not tagged - use vlan 0 on esx uplink
	bonded   = false
	port_id  = local.eth1_id
	vlan_ids = [metal_vlan.external.id]
	reset_on_delete = true
}

data "metal_precreated_ip_block" "external" {
	metro		= "sy"
	project_id	= metal_project.myproject.id
	address_family	= 4
	public		= true
	depends_on	= [
		metal_device.esx
	]
}
