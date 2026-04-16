module "cloud_connectors" {
  source = "./modules/cloud-connector-pair"

  environment_name                = var.environment_name
  name_prefix                     = var.cloud_connector_name_prefix
  instance_count                  = var.cloud_connector_count
  location                        = data.azurerm_resource_group.shared.location
  resource_group_name             = data.azurerm_resource_group.shared.name
  subnet_role                     = var.cloud_connector_subnet_role
  subnet_name                     = local.subnet_names_by_role[var.cloud_connector_subnet_role]
  subnet_id                       = local.subnet_ids_by_role[var.cloud_connector_subnet_role]
  vm_size                         = var.cloud_connector_vm_size
  admin_username                  = var.cloud_connector_admin_username
  admin_password                  = var.cloud_connector_admin_password
  private_ip_addresses            = var.cloud_connector_private_ip_addresses
  zones                           = var.cloud_connector_zones
  image_publisher                 = var.cloud_connector_image_publisher
  image_offer                     = var.cloud_connector_image_offer
  image_sku                       = var.cloud_connector_image_sku
  image_version                   = var.cloud_connector_image_version
  enable_domain_join              = var.cloud_connector_enable_domain_join
  domain_name                     = var.cloud_connector_domain_name
  domain_join_username            = var.cloud_connector_domain_join_username
  domain_join_password            = var.cloud_connector_domain_join_password
  domain_join_ou_path             = var.cloud_connector_domain_join_ou_path
  auto_shutdown_enabled           = var.cloud_connector_auto_shutdown_enabled
  auto_shutdown_time              = var.cloud_connector_auto_shutdown_time
  auto_shutdown_timezone          = var.cloud_connector_auto_shutdown_timezone
  enable_system_assigned_identity = var.cloud_connector_enable_system_assigned_identity
  tags = merge(var.tags, {
    Lifecycle = "static"
    Role      = "cloud-connector"
  })
}
