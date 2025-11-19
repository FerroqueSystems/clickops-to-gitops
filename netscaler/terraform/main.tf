terraform {
  required_version = ">= 1.5.0"

  required_providers {
    citrixadc = {
      source  = "citrix/citrixadc"
      version = "~> 1.0"
    }
  }
}

provider "citrixadc" {
  endpoint = var.netscaler_endpoint
  username = var.netscaler_username
  password = var.netscaler_password
}

# Placeholder for NetScaler resources.

output "netscaler_endpoint" {
  value       = var.netscaler_endpoint
  description = "NetScaler endpoint used for this configuration."
}
