## [`metal`](../README.md)`/phase1`
Terraform module for the `metal.equinix` bare-metal server platform
This `plan` deploys a DNS Controller onto the physical ESX appliance

---
### `run`
This phase assumes you have already executed the `phase0` plan.  

```
terraform init
terraform plan
terraform apply
```

---
### `inputs`
There are a number of inputs defined, that all default to values provided by `phase0`

---
#### `controller_ip`
`controller_ip` is the ip address that will be assigned to the controller

---
### `destroy` [optional]
```
terraform destroy
```

---
