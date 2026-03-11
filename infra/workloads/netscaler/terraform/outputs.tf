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

output "netscaler_agent_public_ip" {
  description = "Public IP of the NetScaler Console Agent VM (null when disabled)."
  value       = var.enable_netscaler_agent ? azurerm_public_ip.netscaler_agent_public_ip[0].ip_address : null
}

output "netscaler_agent_private_ip" {
  description = "Private IP of the NetScaler Console Agent VM management NIC (null when disabled)."
  value       = var.enable_netscaler_agent ? azurerm_network_interface.netscaler_agent_management_interface[0].private_ip_address : null
}

output "netscaler_console_agent_public_ip" {
  description = "Alias for the NetScaler Console Agent public IP output."
  value       = var.enable_netscaler_agent ? azurerm_public_ip.netscaler_agent_public_ip[0].ip_address : null
}

output "netscaler_console_agent_private_ip" {
  description = "Alias for the NetScaler Console Agent private IP output."
  value       = var.enable_netscaler_agent ? azurerm_network_interface.netscaler_agent_management_interface[0].private_ip_address : null
}
