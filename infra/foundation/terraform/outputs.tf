output "resource_group_name" {
  value       = var.resource_group_name
  description = "Foundation resource group name."
}

output "location" {
  value       = var.location
  description = "Foundation deployment region."
}

# Future: surface module outputs (Key Vault name, storage account, ADM agent IP, etc.)
