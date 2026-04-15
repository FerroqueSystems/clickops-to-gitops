# Active Directory Ansible Scaffold

This folder bootstraps the two Windows Server VMs created by Terraform into an
Active Directory forest for the `clickops.demo` domain.

## Structure

- `inventory.sample`: sample WinRM inventory for the two domain controller VMs
- `group_vars/domain_controllers.yml`: shared AD inputs
- `playbook-ad.yml`: promotes the first server to the forest root DC and the
  second server to an additional DC
- `roles/domain-forest/`: creates the forest and first domain controller
- `roles/domain-replica/`: promotes the second server into the domain
- `requirements.yml`: Ansible collections required for Windows and AD modules

## Notes

- Run this from a Linux-based control node that can reach the private IPs of the
  domain controller VMs over WinRM.
- Generate the inventory from Terraform output rather than hand-editing host IPs.
- Store passwords with Ansible Vault or environment-backed variables rather than
  committing them to source control.

## Run From The Bastion

1. Install the collections if they are not already present:
   `ansible-galaxy collection install -r requirements.yml`
2. Generate the inventory from the Terraform root:
   `bash render-inventory.sh`
3. Copy `ad-secrets.env.example` to `ad-secrets.env`, set the passwords, and load
   them into the shell:
   `chmod 600 ad-secrets.env && source ad-secrets.env`
4. Run:
   `ansible-playbook -i inventory.ini playbook-ad.yml`

`AD_DOMAIN_ADMIN_PASSWORD` is optional. If it is omitted, the replica promotion
step reuses `AD_LOCAL_ADMIN_PASSWORD` for `CLICKOPS\Administrator`.
