resource "citrix_cloud_resource_location" "this" {
  name = var.resource_location_name
}

locals {
  resource_location_plan = {
    id                  = citrix_cloud_resource_location.this.id
    name                = citrix_cloud_resource_location.this.name
    location            = data.azurerm_resource_group.shared.location
    resource_group_name = data.azurerm_resource_group.shared.name
    lifecycle           = "static"
  }
}
