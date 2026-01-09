terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Foundation modules are intentionally "opt-in" using enable_* flags.
# This lets you introduce services (ADM agent, storage, identity, etc.)
# without breaking the demo repo or requiring permissions immediately.

module "network_hub" {
  source = "./modules/network-hub"
  count  = var.enable_network_hub ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location
}

module "storage_fileshare" {
  source = "./modules/storage-fileshare"
  count  = var.enable_storage_fileshare ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location
}

module "keyvault" {
  source = "./modules/keyvault"
  count  = var.enable_keyvault ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location
}

module "identity_entra" {
  source = "./modules/identity-entra"
  count  = var.enable_identity_entra ? 1 : 0
  # Entra/Graph items will come later; module is a placeholder.
}

module "adm_agent" {
  source = "./modules/adm-agent"
  count  = var.enable_adm_agent ? 1 : 0

  resource_group_name = var.resource_group_name
  location            = var.location
}
