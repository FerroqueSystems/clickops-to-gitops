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

output "domain_name" {
  description = "Active Directory DNS domain name planned for domain controller promotion."
  value       = var.domain_name
}

output "ansible_inventory" {
  description = "Sample Ansible inventory content for promoting the domain controllers from the bastion."
  value = join("\n", concat(
    ["[domain_controllers]"],
    [
      for index, name in local.domain_controller_names :
      format("%s ansible_host=%s", name, var.domain_controller_private_ip_addresses[index])
    ],
    [
      "",
      "[domain_controllers:vars]",
      "ansible_connection=winrm",
      "ansible_port=5986",
      "ansible_winrm_transport=ntlm",
      "ansible_winrm_server_cert_validation=ignore",
      format("ansible_user=.\\%s", var.domain_controller_admin_username),
      "ansible_password=REPLACE_WITH_LOCAL_ADMIN_PASSWORD",
      "",
      "[domain_forest]",
      local.domain_controller_names[0],
      "",
      "[domain_replicas]",
      local.domain_controller_names[1]
    ]
  ))
}
