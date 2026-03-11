locals {
  planned_names = [
    for index in range(var.instance_count) :
    format("%s-%s-%02d", var.name_prefix, var.environment_name, index + 1)
  ]

  plan = {
    names               = local.planned_names
    instance_count      = var.instance_count
    vm_size             = var.vm_size
    location            = var.location
    resource_group_name = var.resource_group_name
    subnet_role         = var.subnet_role
    subnet_name         = var.subnet_name
    subnet_id           = var.subnet_id
    tags                = var.tags
    lifecycle           = "static"
  }
}
