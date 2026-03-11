locals {
  catalog_name = format("%s-%s-%s", var.environment_name, var.logical_name, var.generation)

  plan = {
    logical_name          = var.logical_name
    catalog_name          = local.catalog_name
    delivery_group_name   = var.delivery_group_name
    generation            = var.generation
    session_type          = var.session_type
    image_definition_name = var.image_definition_name
    machine_count         = var.machine_count
    vm_size               = var.vm_size
    location              = var.location
    resource_group_name   = var.resource_group_name
    subnet_role           = var.subnet_role
    subnet_name           = var.subnet_name
    subnet_id             = var.subnet_id
    tags                  = var.tags
    lifecycle             = "rotating"
  }
}
