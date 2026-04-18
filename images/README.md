# Azure Image Builds

This folder contains the Packer scaffolding used to build Windows base images
and publish them into an Azure Compute Gallery created by Terraform.

By default, the base template creates a clean Windows image, optionally installs
Chocolatey and Chocolatey packages, optionally installs the Citrix VDA,
optionally runs Citrix Optimizer, prepares the VM for Citrix MCS capture, and
then generalizes it.

## Files

- `azure-windows-base.pkr.hcl`: reusable Azure Packer template for Windows builds
- `windows-2022-azure.pkrvars.hcl.example`: example build variables for Windows Server 2022
- `win11-azure.pkrvars.hcl.example`: example build variables for Windows 11
- `scripts/windows/install-chocolatey.ps1`: bootstraps Chocolatey on the build VM
- `scripts/windows/install-chocolatey-packages.ps1`: installs requested Chocolatey packages
- `scripts/windows/install-citrix-vda.ps1`: downloads and runs the Citrix VDA installer
- `scripts/windows/run-citrix-optimizer.ps1`: downloads the Citrix Optimizer zip and runs the selected template
- `scripts/windows/prepare-citrix-master-image.ps1`: performs final cleanup before sysprep
- `scripts/windows/sysprep.ps1`: final generalization step before image capture

## Workflow

1. Create the Azure Compute Gallery and image definitions from
   `infra/foundation/terraform`.
2. Copy one of the `*.example` var files to a real `*.pkrvars.hcl` file.
3. Review the source marketplace image values.
4. Add the Chocolatey packages you want baked into the image.
5. Upload the Citrix VDA installer and Citrix Optimizer zip to the private artifact blob container.
6. Generate read-only SAS URLs for those blobs.
7. Add the Citrix VDA installer URL and silent install arguments when you are ready to build a usable Citrix image.
8. Add the Citrix Optimizer zip URL and template name if you want the image optimized during the build.
9. Leave `prepare_for_citrix_mcs = true` for normal catalog image builds.
10. Run `packer init`.
11. Run `packer build`.

## Installer Model

The image template no longer relies on `winget`. Applications are installed
through Chocolatey, which aligns better with the handbook flow and is more
reliable for Azure image baking than depending on App Installer.

Example Chocolatey packages should be declared in the real `*.pkrvars.hcl`
files, for example:

```hcl
install_chocolatey_packages = true
chocolatey_packages = [
  "googlechrome",
  "vscode",
  "notepadplusplus"
]
```

For Citrix images, add the VDA installer explicitly as well:

```hcl
install_citrix_vda        = true
citrix_vda_installer_url  = "https://<your-storage-or-artifact-location>/VDAWorkstationSetup_2402.exe"
citrix_vda_installer_args = "/quiet /controllers \"\" /enable_hdx_ports /noresume /noreboot /mastermcsimage"
```

And add Citrix Optimizer from blob storage if desired:

```hcl
run_citrix_optimizer          = true
citrix_optimizer_zip_url      = "https://<your-storage-or-artifact-location>/CitrixOptimizerTool.zip"
citrix_optimizer_template_name = "Citrix_Windows_11_2009.xml"
```

The exact VDA installer binary and command line should match your Citrix release
and whether the image is single-session or multi-session.

## Artifact Storage

The foundation Terraform can now create a dedicated private blob container for
image build artifacts such as:

- `VDAWorkstationSetup_2507.exe`
- `VDAServerSetup_2507.exe`
- `CitrixOptimizerTool.zip`
- custom optimizer XML templates

The recommended pattern is:

1. Keep the storage account private.
2. Upload the artifacts with Azure CLI or AzCopy.
3. Generate read-only SAS URLs for the specific blobs you want Packer to consume.
4. Put those SAS URLs in the real `*.pkrvars.hcl` files.

For Azure Blob storage upload and SAS-style access patterns, see Microsoft Learn:
- Blob upload with AzCopy: https://learn.microsoft.com/azure/storage/common/storage-use-azcopy-blobs-upload
- Anonymous access should remain disabled: https://learn.microsoft.com/azure/storage/blobs/anonymous-read-access-prevent-classic

Chocolatey references:
- Chocolatey setup/install docs: https://docs.chocolatey.org/en-us/choco/setup/
- `choco install` command docs: https://docs.chocolatey.org/en-us/choco/commands/install/

## Example

```bash
cd ~/clickops-to-gitops/images
packer init azure-windows-base.pkr.hcl
packer build -var-file windows-2022-azure.pkrvars.hcl azure-windows-base.pkr.hcl
packer build -var-file win11-azure.pkrvars.hcl azure-windows-base.pkr.hcl
```
