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

Starting from `phase0` - you will require an active account on `https://console.equinix.com`(https://console.equinix.com)  
You can obtain an API KEY by performing the following steps in the console:  
- Login to `https://console.equinix.com`(https://console.equinix.com)  
- Click your account name in top-right corner and select `Personal API Keys`  
- Click `+ Add New Key`  
- Create a new file `/phase0/terraform.tfvars` and enter your new API KEY for example:  
```
auth_token = "TRBJAaQtwtuQUbs3GpeSNVs2L2sVCDtV"
```

Execute the phases one at a time in sequence, allowing time for each to fully complete.  

---
#### [`>> phase0 <<`](phase0/README.md)
Deploys the metal `esx` host and provides management connectivity  
This will take some time to prepare and install `esx` and start host services  

---

#### [`>> phase1 <<`](phase1/README.md)
Configures basic `metal` host networking  
Deploys a `metal` gateway and public IPv4 management subnet  
Builds a single linux k8s appliance `controller` VM and attaches it to management subnet  

`phase1` requires that `docker` be installed on the machine that the plan is executed from.  
`docker` is used to compile the `IPXE` source code for the `bootiso` module.  

The `controller` VM is bootstrapped over a network-boot using the `stage3` approach described here:  
https://labops.sh  

---

#### [`>> phase2 <<`](phase2/README.md)
Deploys and configures a DNS service on the `controller` VM  
Provisions a DNS A Record for `vcenter.lab01.metal` resolving to the next available public IP  
