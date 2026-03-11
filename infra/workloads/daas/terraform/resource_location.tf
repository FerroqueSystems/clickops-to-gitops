locals {
  resource_location_plan = {
    name                = var.resource_location_name
    location            = data.azurerm_resource_group.shared.location
    resource_group_name = data.azurerm_resource_group.shared.name
    lifecycle           = "static"
  }
}
