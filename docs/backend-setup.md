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

Copy `backend.tf.example` → `backend.tf` and replace placeholders with the real resource names.
