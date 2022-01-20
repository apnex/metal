locals {
	state		= join("/", [path.root, "state"])
	file		= var.target_file
	path		= join("/", [local.state, local.file])
	dockerfile	= join("/", [path.module, "ipxe-builder.docker"])
	scriptfile	= var.script_file
	scriptpath	= join("/", [local.state, local.scriptfile])
}

# fetch ipxe script
resource "null_resource" "script" {
	triggers = {
		scriptsrc	= local.scriptpath
		scriptdst	= "${path.module}/${local.scriptfile}"
	}
	provisioner "local-exec" {
		command = <<-EOT
			echo "COPY ${self.triggers.scriptsrc} >> ${self.triggers.scriptdst}"
			cp ${self.triggers.scriptsrc} ${self.triggers.scriptdst}
		EOT
	}
	provisioner "local-exec" {
		when = destroy
		command = <<-EOT
			echo "REMOVE ${self.triggers.scriptdst}"
			rm ${self.triggers.scriptdst}
		EOT
	}
}

# render dockerfile
resource "local_file" "dockerfile" {
	depends_on = [
		null_resource.script
	]
	filename = local.dockerfile
	content = templatefile("${path.module}/docker.tpl", {
		scriptfile	= local.scriptfile
	})
}

# compile ipxe.iso using ipxe-builder
resource "null_resource" "compile-boot-iso" {
	depends_on	= [
		local_file.dockerfile
	]
	triggers	= {
		state		= local.state
		path		= local.path
		dockerfile	= local.dockerfile
		always_run	= timestamp()
	}
	provisioner "local-exec" {
		interpreter = ["/bin/bash" ,"-c"]
		command = <<-EOT
			mkdir -p ${self.triggers.state}
			docker build -f ${self.triggers.dockerfile} -t apnex/ipxe-builder:latest ${path.module}
			echo "COPY FILE ipxe.iso >>> ${self.triggers.path}"
			docker cp $(docker create --rm apnex/ipxe-builder):/usr/src/ipxe/src/bin/ipxe.iso ${self.triggers.path}
		EOT
	}
	provisioner "local-exec" {
		when = destroy
		command = <<-EOT
			echo "REMOVE ${self.triggers.path}"
			rm ${self.triggers.path}
		EOT
	}
}
