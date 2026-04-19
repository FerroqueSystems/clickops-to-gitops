locals {
  machine_catalog_resource_group_name = coalesce(
    var.machine_catalog_resource_group_name,
    format("%s-catalogs", data.azurerm_resource_group.shared.name)
  )

  subnet_names_by_role = {
    management = data.azurerm_subnet.management.name
    server     = data.azurerm_subnet.server.name
    client     = data.azurerm_subnet.client.name
  }

  subnet_ids_by_role = {
    management = data.azurerm_subnet.management.id
    server     = data.azurerm_subnet.server.id
    client     = data.azurerm_subnet.client.id
  }
}
