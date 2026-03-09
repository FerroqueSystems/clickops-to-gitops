output "resource_group_name" {
  description = "Name of the resource group created"
  value       = azurerm_resource_group.terraform-resource-group.name
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.terraform-virtual-network.name
}

output "ubuntu_public_ip" {
  description = "Public IP address of the ubuntu bastion host"
  value       = azurerm_public_ip.terraform-ubuntu-public-ip.ip_address
}

output "adc_public_ips" {
  description = "Public IP addresses for ADC management interfaces (may be empty if not provisioned)"
  value       = azurerm_public_ip.terraform-adc-management-public-ip[*].ip_address
}

output "load_balancer_public_ips" {
  description = "Public IP(s) for the load balancer (empty array if HA internal LB is used)"
  value       = azurerm_public_ip.terraform-load-balancer-public-ip[*].ip_address
}

output "ubuntu_private_ip" {
  description = "Private IP of the ubuntu management interface"
  value       = azurerm_network_interface.terraform-ubuntu-management-interface.private_ip_address
}

output "netscaler_tenant_id" {
  description = "Azure tenant ID to use in NetScaler Azure integration settings."
  value       = data.azurerm_client_config.current.tenant_id
}

output "netscaler_application_id" {
  description = "Azure application (client) ID created for NetScaler Azure integration."
  value       = var.create_netscaler_service_principal ? azuread_application.netscaler[0].client_id : null
}

output "netscaler_application_secret" {
  description = "Azure application secret created for NetScaler Azure integration."
  value       = var.create_netscaler_service_principal ? azuread_application_password.netscaler[0].value : null
  sensitive   = true
}
