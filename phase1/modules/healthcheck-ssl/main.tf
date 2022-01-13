locals {
	endpoint	= var.endpoint
	port		= var.port
}

#resource "null_resource" "healthcheck-ping" {
#	triggers = {
#		always_run	= timestamp()
#		endpoint	= local.endpoint
#	}
#	provisioner "local-exec" {
#		interpreter	= ["/bin/bash", "-c"]
#		command		= "${path.module}/healthcheck-ping.sh"
#		environment	= {
#			ENDPOINT	= self.triggers.endpoint
#		}
#	}
#}

resource "null_resource" "healthcheck-ssl" {
	triggers = {
		always_run	= timestamp()
		endpoint	= local.endpoint
		port		= local.port
	}
	provisioner "local-exec" {
		interpreter	= ["/bin/bash", "-c"]
		command		= "${path.module}/healthcheck-ssl.sh"
		environment	= {
			ENDPOINT	= self.triggers.endpoint
			PORT		= self.triggers.port
		}
	}
}

data "external" "thumbprint" {
	program	= ["/bin/bash", "-c", "${path.module}/thumbprint.sh"]
	query	= {
		endpoint	= local.endpoint
		port		= local.port
	}
	depends_on = [
		null_resource.healthcheck-ssl
	]
}
