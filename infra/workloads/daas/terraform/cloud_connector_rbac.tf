locals {
  cloud_connector_principal_ids = toset([
    for principal_id in module.cloud_connectors.principal_ids :
    principal_id
    if principal_id != null && trimspace(principal_id) != ""
  ])
}

resource "azurerm_role_assignment" "cloud_connector_machine_catalog_rg_contributor" {
  for_each = local.cloud_connector_principal_ids

  scope                = azurerm_resource_group.machine_catalogs.id
  role_definition_name = "Contributor"
  principal_id         = each.value
}
