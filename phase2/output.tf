output "vcsa_json" {
	value = jsondecode(data.local_file.vcsa_json.content)
}
