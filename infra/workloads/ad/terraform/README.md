# Active Directory Terraform Scaffold

This root module provisions two Windows Server virtual machines in the shared
Azure resource group and virtual network used by the demo NetScaler and DaaS
workloads.

It is intended to stand up the infrastructure layer for Active Directory domain
controllers. Promotion into AD DS, DNS configuration, and database server
automation should be handled in a follow-on step with configuration management
or VM extensions. This module now also enables WinRM HTTPS on the two Windows
VMs so they are reachable from the bastion for the Ansible promotion step.

The planned AD DNS domain name for this demo is `clickops.demo`.

## Design Notes

- Uses the existing shared Azure resource group, VNet, and subnet names.
- Defaults domain controllers into the `management` subnet because the current
  `server` subnet NSG is lab-oriented and denies most outbound traffic.
- Creates private-only Windows Server VMs with static private IP addresses.

## Next Steps

1. Apply this module to create the two domain controller VMs.
2. Use the AD Ansible playbook from the bastion to create the `clickops.demo`
   forest on the first VM and promote the second VM as an additional domain
   controller.
3. Point Cloud Connectors and server workloads at the new DNS servers.
4. Add the database workload in a separate root module or extend this one.

## Packer Timing

- Server image builds are useful now if you want a repeatable Windows Server
  baseline for domain controllers and future database servers.
- VDA image builds should happen after the AD baseline is defined and before
  machine catalogs are created, so the image includes the right domain tooling,
  security agents, and Citrix components.
