# NetScaler Terraform Guide

This folder manages the shared Azure network and NetScaler-side infrastructure that the Citrix DaaS workload depends on.

Use this root for:

- Shared Azure resource group
- Shared VNet and subnets
- Subnet NSGs
- Ubuntu bastion
- Citrix ADC VMs and related load balancer components
- Optional NetScaler Console Agent

Use the DaaS Terraform root for:

- Citrix resource location
- Citrix hosting connection
- Cloud Connectors
- Machine catalog generations
- Delivery-group cutover

## Core Model

This root builds the shared platform layer.

The design assumption is:

- NetScaler/network resources are relatively static
- The DaaS root consumes the subnets and resource group created here
- NSG changes here directly affect Cloud Connector, VDA, Bastion, and DC communication

If DaaS registration or domain join starts failing, inspect this root first for subnet layout and NSG behavior.

## Important Files

- `clickops.tfvars`
  - The live tracked configuration used by plan/apply for this root.
  - This is the main file operators usually edit.
- `clickops.tfvars.example`
  - Example/reference settings.
- `variables.tf`
  - Input contract for the NetScaler/shared-network root.
- `main.tf`
  - Core Azure network, subnet, NSG, bastion, and ADC deployment logic.
- `netscaler_console_agent.tf`
  - Optional NetScaler Console Agent deployment and registration.
- `outputs.tf`
  - Important resulting values such as bastion public IP.
- `backend.hcl.example`
  - Example backend settings for remote state.
- `templates/`
  - Helper bootstrap content for bastion and related VM setup.
- `stages/`
  - Supporting stage artifacts used by this area of the repo.

## What To Edit

Most routine work should happen in `clickops.tfvars`.

Common operator changes:

- Azure region and resource group name
- VNet and subnet CIDRs
- DNS server IPs for the shared VNet
- controlling subnet CIDR
- optional public IP CIDR for management access
- VM sizes
- tags
- whether the NetScaler Console Agent is enabled

Edit `main.tf` only when:

- network behavior must change
- NSG rules need adjustment
- ADC/bastion deployment behavior must change
- Azure infrastructure wiring is wrong

## What Must Not Be Stored In `clickops.tfvars`

Do not commit secrets or private credentials to this file.

Sensitive values should come from GitHub Secrets or `TF_VAR_...` environment variables.

At minimum, treat these as secrets:

- `adc_admin_password`
- `citrixadc_rpc_node_password`
- `netscaler_agent_admin_password`
- `netscaler_console_activation_code`
- potentially `netscaler_console_service_url` if you do not want it public

Treat `ssh_public_key` as less sensitive than passwords, but still review whether you want it tracked.

The current tracked `clickops.tfvars` should be cleaned up over time if it still contains live passwords.

## `clickops.tfvars` Walkthrough

### Core Azure settings

These define where the shared platform is built:

- `subscription_id`
- `resource_group_name`
- `location`

### Shared network settings

These define the VNet and subnet layout:

- `virtual_network_address_space`
- `virtual_network_dns_servers`
- `management_subnet_address_prefix`
- `client_subnet_address_prefix`
- `server_subnet_address_prefix`

Guidance:

- `management` is for bastion, Cloud Connectors, AD/DC-facing administration, and other static support components
- `server` is for rotating machine catalog VDAs and related workload VMs
- `client` is intended for ADC-facing client traffic, not for Cloud Connectors or normal VDA placement

If you change subnet CIDRs after deployment, expect broad impact.

### Access control settings

These govern who can reach the management plane:

- `controlling_subnet`
- `vdi_public_ip_cidr`

`controlling_subnet` is used to permit management access into the management subnet.

`vdi_public_ip_cidr` is optional and can allow limited direct public access to management ports for troubleshooting.

### Bastion settings

These control the Ubuntu bastion:

- `ssh_public_key`
- `ubuntu_vm_size`
- `ubuntu_admin_user`
- `bastion_repository_url`
- `bastion_github_public_key_usernames`

The bastion is the normal operator entry point for Terraform, Packer, and VM troubleshooting.

### ADC settings

These control the Citrix ADC VMs:

- `adc_vm_size`
- `adc_admin_username`
- `adc_admin_password`
- `citrixadc_rpc_node_password`
- `ha_for_internal_lb`

### NetScaler Console Agent settings

These control the optional NetScaler Console Agent:

- `enable_netscaler_agent`
- `netscaler_agent_name`
- `netscaler_agent_admin_username`
- `netscaler_agent_admin_password`
- `netscaler_agent_vm_size`
- `netscaler_agent_image_*`
- `netscaler_agent_auto_register`
- `netscaler_console_service_url`
- `netscaler_console_activation_code`

If `enable_netscaler_agent = true`, make sure the required image offer/sku/version and registration secrets are valid.

### Cost and lifecycle settings

These are useful for demo and lab environments:

- `auto_shutdown_enabled`
- `auto_shutdown_time`
- `auto_shutdown_timezone`
- `tags`

## Network And NSG Expectations

This root defines the subnet NSGs in `main.tf`.

That means this folder controls whether:

- Bastion can RDP/SSH into targets
- Cloud Connectors can reach domain controllers
- VDAs can reach Cloud Connectors
- Cloud Connectors can communicate back to VDAs
- NetScaler/client paths work correctly

Recent operational guidance from this repo:

- management and server subnets should have explicit east-west allows for DaaS traffic
- Bastion access to server-subnet Windows VMs should be explicitly allowed on `3389`
- relying only on Azure default NSG behavior makes troubleshooting harder

If Citrix registration fails, inspect these rules before assuming the Citrix provider or AD is the problem.

## Safe Change Areas

Relatively safe changes:

- VM size changes
- auto-shutdown settings
- tags
- adding explicit NSG allow rules
- enabling or disabling the NetScaler Console Agent

Higher-risk changes:

- VNet address space
- subnet CIDRs
- DNS server IPs
- management access CIDRs
- ADC HA or LB behavior

## Troubleshooting Hints

### Bastion cannot reach a VM

Check:

- subnet NSG inbound allow for `3389` or `22`
- any NIC-level NSG on the VM
- guest OS firewall
- RDP/SSH service state inside the guest

### Cloud Connector cannot talk to a VDA

Check:

- management-to-server and server-to-management NSG rules
- DNS resolution
- Windows Firewall on the VDA
- VDA registration prerequisites

### `FailedToBindToDomainController`

Even though this shows up in the DaaS workflow, this shared root may still be the cause if:

- DNS servers on the VNet are wrong
- management subnet cannot reach the DCs
- east-west subnet rules are missing

### Bastion works to one machine but not another

That often means the subnet NSG is fine and the issue is:

- guest firewall
- guest service config
- NIC NSG
- VM being marked for deletion

## Running Terraform

Typical local flow:

```powershell
terraform init -backend-config=backend.hcl
terraform plan -var-file=clickops.tfvars
terraform apply -var-file=clickops.tfvars
```

GitHub workflow usage should follow the same tracked `clickops.tfvars` model unless deliberately changed.

## Relationship To The DaaS Root

The DaaS root depends on:

- resource group
- VNet
- management/server/client subnets
- DNS behavior
- NSGs

If you break shared network assumptions here, DaaS symptoms will appear there.

In practice:

- use this root to fix network reachability
- use the DaaS root to fix Citrix object lifecycle and catalog rotation

## Recommended Operator Workflow

1. Make shared network changes here first.
2. Apply and verify reachability.
3. Then run DaaS plan/apply if the change affects Cloud Connectors, VDAs, or Citrix registration.
4. Document any manual operational exceptions in `docs/`.

For routine monthly VDA image rotation, you should usually not need to edit this folder unless a network issue is discovered.
