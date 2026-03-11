locals {
  hosting_connection_plan = {
    name                 = var.hosting_connection_name
    location             = data.azurerm_resource_group.shared.location
    resource_group_name  = data.azurerm_resource_group.shared.name
    virtual_network_name = data.azurerm_virtual_network.shared.name
    subnet_names_by_role = local.subnet_names_by_role
    lifecycle            = "static"
  }
}
