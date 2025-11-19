terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # Example provider; adjust to your environment
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "machine_catalog" {
  source = "./modules/machine-catalog"

  catalog_name = var.catalog_name
}

module "delivery_group" {
  source = "./modules/delivery-group"

  delivery_group_name = var.delivery_group_name
  catalog_name        = module.machine_catalog.catalog_name
}

module "app_publishing" {
  source = "./modules/app-publishing"

  delivery_group_name = module.delivery_group.delivery_group_name
}
