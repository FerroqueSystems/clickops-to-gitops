module "delivery_groups" {
  for_each = module.machine_catalogs
  source   = "./modules/delivery-group"

  logical_name         = each.key
  generation           = each.value.generation
  delivery_group_name  = each.value.delivery_group_name
  machine_catalog_name = each.value.catalog_name
  session_type         = each.value.session_type
  tags = merge(var.tags, {
    Lifecycle = "static"
    Role      = "delivery-group"
  })
}
