# Azure Image Builds

This folder contains the Packer scaffolding used to build Windows base images
and publish them into an Azure Compute Gallery created by Terraform.

By default, the base template only prepares the machine for customization and
generalizes it. Application installation is opt-in through the
`install_winget_packages` and `winget_package_ids` variables.

## Files

- `azure-windows-base.pkr.hcl`: reusable Azure Packer template for Windows builds
- `windows-2022-azure.pkrvars.hcl.example`: example build variables for Windows Server 2022
- `win11-azure.pkrvars.hcl.example`: example build variables for Windows 11
- `scripts/windows/install-winget.ps1`: bootstraps `winget` when it is not already present
- `scripts/windows/install-winget-packages.ps1`: installs requested packages from the `winget` repository
- `scripts/windows/sysprep.ps1`: final generalization step before image capture

## Workflow

1. Create the Azure Compute Gallery and image definitions from
   `infra/foundation/terraform`.
2. Copy one of the `*.example` var files to a real `*.pkrvars.hcl` file.
3. Review the source marketplace image values.
4. Review the requested `winget` packages and remove anything you do not want baked into the image.
5. Run `packer init`.
6. Run `packer build`.

## Example packages

The example var files currently demonstrate package installation with:

- `Microsoft.Teams`
- `SlackTechnologies.Slack`
- `Microsoft.VisualStudioCode`
- `Google.Chrome`
- `Microsoft.Edge`
- `Notepad++.Notepad++`
- `Microsoft.Office`

Notes:

- `Microsoft.Edge` is already present on some Microsoft base images, so including it is mostly a demonstration of the Packer phase.
- `Microsoft.Office` installs software, but licensing and activation remain a separate concern.
- `winget` is native on Windows 11. On Windows Server 2022, this template attempts to bootstrap it with `Microsoft.WinGet.Client` before package installation.

## Example

```bash
cd ~/clickops-to-gitops/images
packer init azure-windows-base.pkr.hcl
packer build -var-file windows-2022-azure.pkrvars.hcl azure-windows-base.pkr.hcl
packer build -var-file win11-azure.pkrvars.hcl azure-windows-base.pkr.hcl
```
