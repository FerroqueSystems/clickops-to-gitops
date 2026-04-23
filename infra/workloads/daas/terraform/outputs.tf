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

output "machine_catalog_resource_group" {
  description = "Dedicated Azure resource group where Citrix MCS places catalog VDA resources."
  value = {
    name     = azurerm_resource_group.machine_catalogs.name
    location = azurerm_resource_group.machine_catalogs.location
    id       = azurerm_resource_group.machine_catalogs.id
  }
}

output "resource_location_plan" {
  description = "Citrix resource location details."
  value       = local.resource_location_plan
}

output "resource_location_id" {
  description = "Actual Citrix Cloud resource location ID."
  value       = local.resource_location_id
}

output "resource_location_name" {
  description = "Actual Citrix Cloud resource location name."
  value       = local.resource_location_name_effective
}

output "hosting_connection_plan" {
  description = "Citrix Azure hosting connection details."
  value       = local.hosting_connection_plan
}

output "zone_id" {
  description = "Citrix DaaS zone ID associated with the resource location and hosting connection."
  value       = citrix_zone.this.id
}

output "zone_name" {
  description = "Citrix DaaS zone name associated with the resource location and hosting connection."
  value       = citrix_zone.this.name
}

output "hosting_connection_hypervisor_id" {
  description = "Citrix Azure hypervisor ID."
  value       = citrix_azure_hypervisor.this.id
}

output "hosting_connection_resource_pool_id" {
  description = "Citrix Azure hypervisor resource pool ID. This is the object machine catalogs will use."
  value       = citrix_azure_hypervisor_resource_pool.this.id
}

output "cloud_connectors_plan" {
  description = "Planned and deployed details for the static Cloud Connector layer."
  value       = module.cloud_connectors.plan
}

output "cloud_connector_names" {
  description = "Names of the deployed Cloud Connector VMs."
  value       = module.cloud_connectors.planned_names
}

output "cloud_connector_private_ips" {
  description = "Private IP addresses assigned to the deployed Cloud Connector VMs."
  value       = module.cloud_connectors.private_ip_addresses
}

output "cloud_connector_vm_ids" {
  description = "Azure resource IDs for the deployed Cloud Connector VMs."
  value       = module.cloud_connectors.virtual_machine_ids
}

output "cloud_connector_principal_ids" {
  description = "Azure system-assigned managed identity principal IDs for the deployed Cloud Connector VMs."
  value       = module.cloud_connectors.principal_ids
}

output "cloud_connector_ansible_inventory" {
  description = "Sample Ansible inventory content for managing the deployed Cloud Connector VMs from the bastion."
  value = join("\n", concat(
    ["[cloud_connectors]"],
    [
      for index, name in module.cloud_connectors.planned_names :
      format("%s ansible_host=%s", name, module.cloud_connectors.private_ip_addresses[index])
    ],
    [
      "",
      "[cloud_connectors:vars]",
      "ansible_connection=winrm",
      "ansible_port=5986",
      "ansible_winrm_transport=ntlm",
      "ansible_winrm_server_cert_validation=ignore",
      format("ansible_user=.\\%s", var.cloud_connector_admin_username),
      "ansible_password=REPLACE_WITH_CLOUD_CONNECTOR_ADMIN_PASSWORD"
    ]
  ))
}

output "machine_catalogs_plan" {
  description = "Starter plan for the rotating machine catalog layer."
  value = {
    for name, module_ref in module.machine_catalogs :
    name => module_ref.plan
  }
}

output "delivery_groups_plan" {
  description = "Starter plan for stable delivery groups that can point to a new catalog generation."
  value = {
    for name, module_ref in module.delivery_groups :
    name => module_ref.plan
  }
}

output "monthly_rebuild_pattern" {
  description = "Summary of the intended monthly rebuild split between static and rotating components."
  value = {
    static_layers   = ["resource_location", "hosting_connection", "cloud_connectors"]
    rotating_layers = ["machine_catalogs"]
    cutover_layers  = ["delivery_groups"]
    generation      = var.catalog_generation
  }
}
