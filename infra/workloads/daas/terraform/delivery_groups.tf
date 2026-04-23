module "delivery_groups" {
  for_each = local.active_delivery_group_targets
  source   = "./modules/delivery-group"

  catalog_deployment_key = each.value.catalog_deployment_key
  logical_name           = each.key
  generation             = each.value.generation
  delivery_group_name    = each.value.delivery_group_name
  machine_catalog_id     = module.machine_catalogs[each.value.catalog_deployment_key].catalog_id
  machine_catalog_name   = module.machine_catalogs[each.value.catalog_deployment_key].catalog_name
  machine_count          = each.value.machine_count
  session_type           = each.value.session_type
  tags = merge(var.tags, {
    ActiveCatalogDeployment = each.value.catalog_deployment_key
    ActiveGeneration        = each.value.generation
    Lifecycle               = "static"
    Role                    = "delivery-group"
  })
}
