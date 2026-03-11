module "machine_catalogs" {
  for_each = var.machine_catalogs
  source   = "./modules/machine-catalog"

  environment_name      = var.environment_name
  generation            = var.catalog_generation
  logical_name          = each.key
  location              = data.azurerm_resource_group.shared.location
  resource_group_name   = data.azurerm_resource_group.shared.name
  subnet_role           = each.value.subnet_role
  subnet_name           = local.subnet_names_by_role[each.value.subnet_role]
  subnet_id             = local.subnet_ids_by_role[each.value.subnet_role]
  session_type          = each.value.session_type
  image_definition_name = each.value.image_definition_name
  machine_count         = each.value.machine_count
  vm_size               = each.value.vm_size
  delivery_group_name   = each.value.delivery_group_name
  tags = merge(var.tags, {
    Lifecycle          = "rotating"
    RotationGeneration = var.catalog_generation
    Role               = "machine-catalog"
  })
}
