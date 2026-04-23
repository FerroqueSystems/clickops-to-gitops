output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "container_name" {
  value = azurerm_storage_container.this.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

output "container_url" {
  value = "${azurerm_storage_account.this.primary_blob_endpoint}${azurerm_storage_container.this.name}"
}
