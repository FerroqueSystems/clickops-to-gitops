locals {
  plan = {
    logical_name         = var.logical_name
    delivery_group_name  = var.delivery_group_name
    machine_catalog_name = var.machine_catalog_name
    session_type         = var.session_type
    generation           = var.generation
    tags                 = var.tags
    lifecycle            = "cutover"
  }
}
