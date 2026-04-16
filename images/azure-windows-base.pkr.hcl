packer {
  required_plugins {
    azure = {
      source  = "github.com/hashicorp/azure"
      version = ">= 2.2.0"
    }
  }
}

variable "subscription_id" {
  type = string
}

variable "location" {
  type = string
}

variable "build_resource_group_name" {
  type = string
}

variable "gallery_resource_group_name" {
  type = string
}

variable "gallery_name" {
  type = string
}

variable "gallery_image_name" {
  type = string
}

variable "gallery_image_version" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_D4s_v5"
}

variable "shared_image_replica_count" {
  type    = number
  default = 1
}

variable "shared_image_replication_regions" {
  type    = list(string)
  default = []
}

variable "azure_imgpublisher" {
  type = string
}

variable "azure_imgoffer" {
  type = string
}

variable "azure_imgsku" {
  type = string
}

variable "azure_imgversion" {
  type    = string
  default = "latest"
}

variable "communicator_username" {
  type    = string
  default = "packer"
}

variable "winrm_timeout" {
  type    = string
  default = "30m"
}

variable "managed_image_tags" {
  type    = map(string)
  default = {}
}

variable "install_winget_packages" {
  type    = bool
  default = false
}

variable "winget_package_ids" {
  type    = list(string)
  default = []
}

locals {
  shared_image_replication_regions = length(var.shared_image_replication_regions) > 0 ? var.shared_image_replication_regions : [var.location]
}

source "azure-arm" "windows" {
  use_azure_cli_auth = true

  subscription_id = var.subscription_id
  location        = var.location
  vm_size         = var.vm_size
  os_type         = "Windows"

  build_resource_group_name = var.build_resource_group_name

  image_publisher = var.azure_imgpublisher
  image_offer     = var.azure_imgoffer
  image_sku       = var.azure_imgsku
  image_version   = var.azure_imgversion

  communicator   = "winrm"
  winrm_use_ssl  = true
  winrm_insecure = true
  winrm_timeout  = var.winrm_timeout
  winrm_username = var.communicator_username

  shared_image_gallery_destination {
    resource_group      = var.gallery_resource_group_name
    gallery_name        = var.gallery_name
    image_name          = var.gallery_image_name
    image_version       = var.gallery_image_version
    replication_regions = local.shared_image_replication_regions
  }

  shared_image_gallery_replica_count = var.shared_image_replica_count

  azure_tags = merge(var.managed_image_tags, {
    SourcePublisher = var.azure_imgpublisher
    SourceOffer     = var.azure_imgoffer
    SourceSku       = var.azure_imgsku
    GalleryImage    = var.gallery_image_name
  })
}

build {
  name    = var.gallery_image_name
  sources = ["source.azure-arm.windows"]

  provisioner "powershell" {
    inline = [
      "$ProgressPreference = 'SilentlyContinue'",
      "Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine -Force"
    ]
  }

  provisioner "powershell" {
    environment_vars = [
      "INSTALL_WINGET_PACKAGES=${var.install_winget_packages}"
    ]
    script = "${path.root}/scripts/windows/install-winget.ps1"
  }

  provisioner "powershell" {
    environment_vars = [
      "INSTALL_WINGET_PACKAGES=${var.install_winget_packages}",
      "WINGET_PACKAGE_IDS=${join(\"|\", var.winget_package_ids)}"
    ]
    script = "${path.root}/scripts/windows/install-winget-packages.ps1"
  }

  provisioner "powershell" {
    script = "${path.root}/scripts/windows/sysprep.ps1"
  }
}
