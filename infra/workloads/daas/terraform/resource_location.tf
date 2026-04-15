resource "citrix_cloud_resource_location" "this" {
  count = var.existing_resource_location_id == null ? 1 : 0
  name  = var.resource_location_name
}

locals {
  resource_location_id = var.existing_resource_location_id != null ? var.existing_resource_location_id : one(citrix_cloud_resource_location.this[*].id)
  resource_location_name_effective = var.existing_resource_location_name != null ? var.existing_resource_location_name : (
    var.existing_resource_location_id != null ? var.resource_location_name : one(citrix_cloud_resource_location.this[*].name)
  )

  resource_location_plan = {
    id                   = local.resource_location_id
    name                 = local.resource_location_name_effective
    location             = data.azurerm_resource_group.shared.location
    resource_group_name  = data.azurerm_resource_group.shared.name
    lifecycle            = "static"
    managed_by_terraform = var.existing_resource_location_id == null
  }
}
