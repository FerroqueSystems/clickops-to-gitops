# Nutanix (on-prem) Terraform skeleton

This folder contains a minimal Terraform skeleton to start building an
on-premises Nutanix IaC workflow. It deliberately keeps examples generic
so you can adapt provider details, modules and state backend to your
environment.

Quick steps:

- Copy `backend.tf.example` → `backend.tf` and choose a backend (local
  for testing or a remote backend for team usage).
- Populate `variables.tf` values via `terraform.tfvars` or CI secrets.
- Uncomment and configure the `provider "nutanix"` block in
  `main.tf` once you've added the provider plugin and validated access.

Notes:

- This is an intentionally small scaffold. Add modules under
  `infra/nutanix/terraform/modules/` and keep sensitive values out of
  source control.
- Keep the existing Azure examples in the repo. You'll pivot between
  on-prem Nutanix and Azure by selecting the appropriate folder and
  backend when running Terraform.
