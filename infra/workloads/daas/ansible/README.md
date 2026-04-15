# DaaS Cloud Connector Ansible Scaffold

This folder manages the Windows Cloud Connector VMs created by the DaaS
Terraform root.

It provides:
- generated inventory from Terraform outputs
- an environment-backed domain join role for Cloud Connector VMs
- an environment-backed Cloud Connector installer role

## Structure

- `render-inventory.sh`: writes `inventory.ini` from Terraform output
- `cc-secrets.env.example`: environment variable template for bastion use
- `playbook-cloud-connectors.yml`: domain join and install/configure playbook
- `group_vars/cloud_connectors.yml`: shared Cloud Connector variables
- `roles/cloud-connector-domain/`: joins the VMs to `clickops.demo`
- `roles/cloud-connector-install/`: stages `cwc.json` and runs a generic silent installer

## Notes

- Run this from the Ubuntu bastion after the Cloud Connector VMs are deployed.
- The inventory and secrets files are intentionally not committed.
- The install role is generic by design. It expects a current Citrix Cloud
  Connector installer URL and current silent arguments from your Citrix Cloud
  workflow.
- If the VMs were already domain joined by Terraform, the domain join role will
  detect that and skip the join action.

## Run From The Bastion

1. Install collections:
   `ansible-galaxy collection install -r requirements.yml`
2. Generate the inventory:
   `bash render-inventory.sh`
3. Copy `cc-secrets.env.example` to `cc-secrets.env`, set the values, then load it:
   `chmod 600 cc-secrets.env && source cc-secrets.env`
4. Run the full playbook:
   `ansible-playbook -i inventory.ini playbook-cloud-connectors.yml`

Useful subsets:
- Domain join only:
  `ansible-playbook -i inventory.ini playbook-cloud-connectors.yml --tags domain_join`
- Install only:
  `ansible-playbook -i inventory.ini playbook-cloud-connectors.yml --tags connector_install`
