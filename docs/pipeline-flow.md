# Pipeline Flow

This document describes how changes move from Git into the Azure, Citrix DaaS, and NetScaler resources managed by this repo.

## 1. Choose The Correct Root

Most changes land in one of these Terraform roots:

- `infra/workloads/netscaler/terraform`
  - Shared Azure resource group, VNet, subnets, NSGs, bastion, ADCs, optional NetScaler Console Agent.
- `infra/workloads/daas/terraform`
  - Citrix resource location, hosting connection, Cloud Connectors, machine catalogs, delivery-group cutover.
- `infra/foundation/terraform`
  - Shared foundation components such as identity, storage, gallery, and Key Vault.
- `infra/workloads/ad/terraform`
  - Active Directory infrastructure used by the DaaS layer.

The current GitHub Actions validation and deployment workflows automate only the `daas` and `netscaler` roots. Foundation and AD remain operator-driven unless you add additional workflows.

## 2. Make The Change In Git

Typical edits are:

- `infra/workloads/netscaler/terraform/clickops.tfvars`
  - Shared network or ADC settings.
- `infra/workloads/daas/terraform/daas.auto.tfvars`
  - Cloud Connector settings, catalog generations, or delivery-group cutover targets.
- Terraform module code under the same roots
  - Only when behavior or wiring must change.

For most monthly lifecycle work, operators should stay in the tracked `.tfvars` files instead of changing module code.

## 3. Pull Request Validation

`pipelines/github-actions/validate.yml` runs on pull requests targeting `main`.

Today that workflow performs, for both `infra/workloads/daas/terraform` and `infra/workloads/netscaler/terraform`:

- `terraform fmt -check -diff`
- `tflint`
- `tfsec`
- `terraform init -backend=false`
- `terraform validate`

This stage is a structure and policy gate. It does not apply infrastructure, run Ansible, execute smoke tests, or validate Citrix runtime health.

## 4. Merge And Deploy

`pipelines/github-actions/deploy.yml` runs on:

- pushes to `main`
- manual `workflow_dispatch`

The workflow currently does this in sequence:

1. Check out the repo.
2. Install Terraform.
3. Authenticate to Azure with `azure/login`.
4. Run `terraform init`, `terraform plan`, and `terraform apply -auto-approve` for:
   - `infra/workloads/daas/terraform`
   - `infra/workloads/netscaler/terraform`

The workflow uses remote Azure Storage state through repository variables:

- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`

It also depends on GitHub secrets for Azure and workload credentials. NetScaler secrets are wired directly in the workflow. DaaS secrets are expected through Terraform variables and must be available in the runtime environment if the DaaS apply is going to succeed.

## 5. State And Configuration Model

The repo currently follows this split:

- NetScaler root
  - Base shared platform layer.
  - Main operator file: `infra/workloads/netscaler/terraform/clickops.tfvars`.
- DaaS root
  - Static Citrix hosting layer plus rotating machine catalogs.
  - Main operator file: `infra/workloads/daas/terraform/daas.auto.tfvars`.

The DaaS root is designed so that:

- Cloud Connectors, hosting connection, and resource location are relatively stable.
- Machine catalogs rotate side by side by generation.
- Delivery groups cut over explicitly through `active_delivery_group_catalogs`.

## 6. Manual Or Semi-Manual Steps

Not everything in the operating model is fully automated by the current workflows.

You should still expect separate operator steps for some areas:

- Packer/image build and validation in `images/`
- AD configuration playbooks in `infra/workloads/ad/ansible`
- DaaS Cloud Connector post-provision configuration in `infra/workloads/daas/ansible`
- NetScaler staged execution from `infra/workloads/netscaler/terraform/stages`
- smoke testing, user validation, and old-catalog retirement during cutover

## 7. End-To-End Summary

The practical flow is:

1. Edit the correct Terraform root or tracked `.tfvars` file.
2. Open a pull request.
3. Let `validate.yml` check Terraform formatting, linting, security scanning, and validation for DaaS and NetScaler.
4. Merge to `main` after review.
5. Let `deploy.yml` apply the DaaS and NetScaler roots against the shared remote backend.
6. Run any required post-apply validation, Ansible, or operational cutover steps that are still outside the workflow.

For the monthly DaaS lifecycle specifically, see [monthly-rebuild-pattern.md](./monthly-rebuild-pattern.md).
