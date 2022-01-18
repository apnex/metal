output "thumbprint" {
	value = data.external.thumbprint.result.thumbprint
}
output "endpoint" {
	value = data.external.thumbprint.result.endpoint
}
output "port" {
	value = data.external.thumbprint.result.port
}
