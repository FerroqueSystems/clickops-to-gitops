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
- The inventory assumes local admin credentials before the domain exists.
- Store passwords with Ansible Vault or environment-backed variables rather than
  committing them to source control.

## Run From The Bastion

1. Install the collections if they are not already present:
   `ansible-galaxy collection install -r requirements.yml`
2. Copy `inventory.sample` to an environment-specific inventory file.
3. Replace the local admin and domain password placeholders.
4. Run:
   `ansible-playbook -i inventory.sample playbook-ad.yml`
