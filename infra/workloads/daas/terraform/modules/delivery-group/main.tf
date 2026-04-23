terraform {
  required_providers {
    citrix = {
      source = "citrix/citrix"
    }
  }
}

resource "citrix_delivery_group" "this" {
  name        = var.delivery_group_name
  description = format("Delivery group for %s generation %s", var.logical_name, var.generation)

  associated_machine_catalogs = [
    {
      machine_catalog = var.machine_catalog_id
      machine_count   = var.machine_count
    }
  ]

  metadata = [
    for key, value in var.tags : {
      name  = key
      value = value
    }
  ]
}

locals {
  plan = {
    catalog_deployment_key = var.catalog_deployment_key
    logical_name           = var.logical_name
    delivery_group_id      = citrix_delivery_group.this.id
    delivery_group_name    = var.delivery_group_name
    machine_catalog_id     = var.machine_catalog_id
    machine_catalog_name   = var.machine_catalog_name
    machine_count          = var.machine_count
    session_type           = var.session_type
    generation             = var.generation
    tags                   = var.tags
    lifecycle              = "cutover"
  }
}
