# Terraform remote backend (Azure Storage) setup

Create a resource group, storage account and blob container to hold Terraform state. Replace `<uniquename>` and `<subscription-id>` with your values.

```bash
az group create -n rg-terraform-state -l eastus
az storage account create -n tfstate<uniquename> -g rg-terraform-state -l eastus --sku Standard_LRS
az storage container create -n tfstate --account-name tfstate<uniquename>
```

Assign a service principal (or use GitHub OIDC) permissions to the storage account. For SPN auth:

```bash
az ad sp create-for-rbac --name "github-actions-clickops" --role "Contributor" --scopes /subscriptions/<subscription-id>/resourceGroups/rg-terraform-state

# Note the appId and password for GitHub Secrets: ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID
```

In GitHub repository secrets, add:
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_TENANT_ID`
- `ARM_SUBSCRIPTION_ID`

In GitHub repository variables, add:
- `TFSTATE_RESOURCE_GROUP`
- `TFSTATE_STORAGE_ACCOUNT`
- `TFSTATE_CONTAINER`

## Per-root backend config

Each Terraform root uses an empty `backend "azurerm" {}` block and a local backend config file.

Example files:
- `infra/workloads/ad/terraform/backend.hcl.example`
- `infra/workloads/daas/terraform/backend.hcl.example`
- `infra/workloads/netscaler/terraform/backend.hcl.example`

Copy the relevant example file to `backend.hcl` in that root and replace the placeholders with your real state resource names.

Example for NetScaler:

```bash
cd infra/workloads/netscaler/terraform
cp backend.hcl.example backend.hcl
terraform init -migrate-state -backend-config backend.hcl
```

Example for AD:

```bash
cd infra/workloads/ad/terraform
cp backend.hcl.example backend.hcl
terraform init -migrate-state -backend-config backend.hcl
```

Example for DaaS:

```bash
cd infra/workloads/daas/terraform
cp backend.hcl.example backend.hcl
terraform init -migrate-state -backend-config backend.hcl
```

Use a different `key` value per root, but keep the same storage account and container so laptop, bastion, and CI all share one backend.
