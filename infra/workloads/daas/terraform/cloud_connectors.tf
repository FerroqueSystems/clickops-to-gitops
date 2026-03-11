module "cloud_connectors" {
  source = "./modules/cloud-connector-pair"

  environment_name    = var.environment_name
  name_prefix         = var.cloud_connector_name_prefix
  instance_count      = var.cloud_connector_count
  location            = data.azurerm_resource_group.shared.location
  resource_group_name = data.azurerm_resource_group.shared.name
  subnet_role         = var.cloud_connector_subnet_role
  subnet_name         = local.subnet_names_by_role[var.cloud_connector_subnet_role]
  subnet_id           = local.subnet_ids_by_role[var.cloud_connector_subnet_role]
  vm_size             = var.cloud_connector_vm_size
  tags = merge(var.tags, {
    Lifecycle = "static"
    Role      = "cloud-connector"
  })
}
