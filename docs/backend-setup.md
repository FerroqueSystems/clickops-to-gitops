# Terraform Remote Backend Setup

This repo uses Azure Storage remote state for the Terraform roots under `infra/`.

The current GitHub Actions workflows consume backend settings from repository variables and then pass a root-specific `key` value during `terraform init`.

## 1. Create The Shared State Storage

Replace `<uniquename>` and `<subscription-id>` with your values.

```bash
az group create -n rg-terraform-state -l eastus
az storage account create -n tfstate<uniquename> -g rg-terraform-state -l eastus --sku Standard_LRS
az storage container create -n tfstate --account-name tfstate<uniquename>
```

## 2. Grant CI Access

OIDC is the preferred model for GitHub Actions. If you use a service principal instead, create one and capture the resulting IDs and secret:

```bash
az ad sp create-for-rbac \
  --name "github-actions-clickops" \
  --role "Contributor" \
  --scopes /subscriptions/<subscription-id>/resourceGroups/rg-terraform-state
```

For GitHub OIDC, use a federated credential subject that matches how the workflow runs.

Recommended when using protected environments:

- `repo:<org>/<repo>:environment:production`

Branch-scoped subjects such as `repo:<org>/<repo>:ref:refs/heads/main` only match that exact ref.

## 3. Configure GitHub Variables And Secrets

Repository variables used by `pipelines/github-actions/deploy.yml`:

- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`

Azure authentication secrets commonly required by the workflows:

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`

Workload-specific secrets are separate from backend configuration. For example:

- NetScaler workflow values such as `ADC_ADMIN_PASSWORD`
- DaaS Terraform variables such as `TF_VAR_citrix_customer_id`
- DaaS and Cloud Connector credentials such as `TF_VAR_cloud_connector_admin_password`

The backend variables only control where state lives. They do not replace the runtime credentials required by each Terraform root.

## 4. Per-Root Backend Files For Local Use

Each Terraform root includes an empty `backend "azurerm" {}` block and can be initialized locally with a `backend.hcl` file.

Examples in this repo:

- `infra/foundation/terraform/backend.tf.example`
- `infra/workloads/ad/terraform/backend.hcl.example`
- `infra/workloads/daas/terraform/backend.hcl.example`
- `infra/workloads/netscaler/terraform/backend.hcl.example`

Copy the example file for the root you are working in and replace the placeholders with your real state resource names.

## 5. Local Initialization Examples

NetScaler:

```powershell
cd infra/workloads/netscaler/terraform
Copy-Item backend.hcl.example backend.hcl
terraform init -migrate-state -backend-config=backend.hcl
```

DaaS:

```powershell
cd infra/workloads/daas/terraform
Copy-Item backend.hcl.example backend.hcl
terraform init -migrate-state -backend-config=backend.hcl
```

AD:

```powershell
cd infra/workloads/ad/terraform
Copy-Item backend.hcl.example backend.hcl
terraform init -migrate-state -backend-config=backend.hcl
```

Foundation:

```powershell
cd infra/foundation/terraform
Copy-Item backend.tf.example backend.tf
terraform init
```

## 6. State Key Guidance

Use one storage account and container for the repo, but a different `key` per Terraform root.

Current workflow examples:

- `infra/workloads/daas/terraform.tfstate`
- `infra/workloads/netscaler/terraform.tfstate`

That keeps state isolated while still letting laptops, bastions, and CI operate against the same backend.

## 7. Operational Notes

- Keep backend configuration out of tracked live `.tfvars` files.
- Do not commit `backend.hcl` files with real tenant or storage values unless that is an intentional repo policy.
- If you expand GitHub Actions to cover `foundation` or `ad`, reuse the same shared backend variables and assign a distinct `key` for each new root.
