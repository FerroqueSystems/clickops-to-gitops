output "planned_names" {
  value = local.planned_names
}

output "plan" {
  value = local.plan
}

output "network_interface_ids" {
  value = azurerm_network_interface.cloud_connector[*].id
}

output "virtual_machine_ids" {
  value = azurerm_windows_virtual_machine.cloud_connector[*].id
}

output "private_ip_addresses" {
  value = azurerm_network_interface.cloud_connector[*].private_ip_address
}
