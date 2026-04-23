module "machine_catalogs" {
  for_each = local.catalog_deployments_effective
  source   = "./modules/machine-catalog"

  environment_name            = var.environment_name
  zone_id                     = citrix_zone.this.id
  hypervisor_id               = citrix_azure_hypervisor.this.id
  hypervisor_resource_pool_id = citrix_azure_hypervisor_resource_pool.this.id
  generation                  = each.value.generation
  logical_name                = each.value.logical_name
  location                    = azurerm_resource_group.machine_catalogs.location
  image_resource_group_name   = data.azurerm_resource_group.shared.name
  vda_resource_group_name     = azurerm_resource_group.machine_catalogs.name
  gallery_name                = var.compute_gallery_name
  subnet_role                 = each.value.subnet_role
  subnet_name                 = local.subnet_names_by_role[each.value.subnet_role]
  subnet_id                   = local.subnet_ids_by_role[each.value.subnet_role]
  session_type                = each.value.session_type
  image_definition_name       = each.value.image_definition_name
  image_version               = each.value.image_version
  machine_count               = each.value.machine_count
  vm_size                     = each.value.vm_size
  domain_name                 = var.cloud_connector_domain_name
  domain_join_username        = var.cloud_connector_domain_join_username
  domain_join_password        = var.cloud_connector_domain_join_password
  domain_join_ou_path         = var.cloud_connector_domain_join_ou_path
  domain_service_account_id   = var.machine_catalog_domain_service_account_id
  delivery_group_name         = each.value.delivery_group_name
  tags = merge(var.tags, {
    Lifecycle          = "rotating"
    RotationGeneration = each.value.generation
    Role               = "machine-catalog"
  })

  depends_on = [azurerm_role_assignment.cloud_connector_machine_catalog_rg_contributor]
}
