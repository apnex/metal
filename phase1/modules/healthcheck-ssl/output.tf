output "thumbprint" {
	value = data.external.thumbprint.result.thumbprint
}
output "endpoint" {
	value = local.endpoint
}
output "port" {
	value = local.port
}
