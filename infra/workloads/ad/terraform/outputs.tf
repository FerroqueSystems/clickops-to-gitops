output "shared_infra" {
  description = "Shared Azure infrastructure read from the existing NetScaler resource group and VNet."
  value = {
    resource_group_name = data.azurerm_resource_group.shared.name
    location            = data.azurerm_resource_group.shared.location
    virtual_network     = data.azurerm_virtual_network.shared.name
    subnet_names        = local.subnet_names_by_role
    subnet_ids          = local.subnet_ids_by_role
  }
}

output "domain_controller_names" {
  description = "Names of the provisioned domain controller VMs."
  value       = azurerm_windows_virtual_machine.domain_controller[*].name
}

output "domain_controller_private_ips" {
  description = "Static private IP addresses assigned to the domain controller NICs."
  value       = azurerm_network_interface.domain_controller[*].private_ip_address
}

output "domain_controller_subnet_role" {
  description = "Subnet role used for the domain controller VMs."
  value       = var.domain_controller_subnet_role
}
