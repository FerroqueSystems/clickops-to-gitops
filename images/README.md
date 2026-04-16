# Azure Image Builds

This folder contains the Packer scaffolding used to build Windows base images
and publish them into an Azure Compute Gallery created by Terraform.

## Files

- `azure-windows-base.pkr.hcl`: reusable Azure Packer template for Windows builds
- `windows-2022-azure.pkrvars.hcl.example`: example build variables for Windows Server 2022
- `win11-azure.pkrvars.hcl.example`: example build variables for Windows 11
- `scripts/windows/sysprep.ps1`: final generalization step before image capture

## Workflow

1. Create the Azure Compute Gallery and image definitions from
   `infra/foundation/terraform`.
2. Copy one of the `*.example` var files to a real `*.pkrvars.hcl` file.
3. Review the source marketplace image values.
4. Run `packer init`.
5. Run `packer build`.

## Example

```bash
cd ~/clickops-to-gitops/images
packer init azure-windows-base.pkr.hcl
packer build -var-file windows-2022-azure.pkrvars.hcl azure-windows-base.pkr.hcl
packer build -var-file win11-azure.pkrvars.hcl azure-windows-base.pkr.hcl
```
