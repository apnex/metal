## `metal`
A collection of terraform plans for labs on the `metal.equinix.com` bare-metal IaaS platform  
Clone repository and adjust input parameters as required  

---

### `clone`
```
git clone https://github.com/apnex/metal
cd metal
```

---

### `phases`
This repo is organised into 3 key phases as follows:  

<pre>
metal
  &#x2523&#x2501 phase0
  &#x2523&#x2501 phase1
  &#x2517&#x2501 phase2
</pre>

Each phase and directory represents a single atomic terraform plan for lab deployment or configuration.  
Modify parameters as necessary in each `input.tf` and `apply` or `destroy` as required.

Starting from `phase0` - you will require an active account on `console.equinix.com`  
You can obtain an API KEY by performing the following steps in the console:  
- Login to `https://console.equinix.com`  
- Click your account name in top-right corner and select `Personal API Keys`  
- Click `+ Add New Key`  
- Create a new file `/phase0/terraform.tfvars` and enter your new API TOKEN as follows:  
```
auth_token = "TRBJAaQtwtuQUbs3GpeSNVs2L2sVCDtV"
```

Execute the phases one at a time in sequence.  

**NOTE**  
`phase1` requires that `docker` be installed on the machine that the plan is execute from.  
`docker` is used to compile the IPXE source code for the `bootiso` module.  
---
