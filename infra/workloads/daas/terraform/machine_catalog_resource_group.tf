resource "azurerm_resource_group" "machine_catalogs" {
  name     = local.machine_catalog_resource_group_name
  location = data.azurerm_resource_group.shared.location

  tags = merge(var.tags, {
    Lifecycle = "rotating"
    Role      = "machine-catalog-resource-group"
  })
}
