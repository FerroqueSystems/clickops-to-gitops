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

  legacy_catalog_deployments = {
    for logical_name, catalog in var.machine_catalogs :
    format("%s-%s", logical_name, var.catalog_generation) => merge(catalog, {
      logical_name = logical_name
      generation   = var.catalog_generation
    })
  }

  catalog_deployments_effective = length(var.catalog_deployments) > 0 ? var.catalog_deployments : local.legacy_catalog_deployments

  catalog_logical_names = distinct([
    for catalog in values(local.catalog_deployments_effective) :
    catalog.logical_name
  ])

  auto_selected_delivery_group_catalogs = length(var.catalog_deployments) > 0 ? {
    for logical_name in local.catalog_logical_names :
    logical_name => one([
      for catalog_key, catalog in local.catalog_deployments_effective :
      catalog_key if catalog.logical_name == logical_name
    ])
    if length([
      for catalog in values(local.catalog_deployments_effective) :
      catalog.logical_name if catalog.logical_name == logical_name
    ]) == 1
    } : {
    for catalog_key, catalog in local.catalog_deployments_effective :
    catalog.logical_name => catalog_key
  }

  active_delivery_group_catalogs_effective = length(var.active_delivery_group_catalogs) > 0 ? var.active_delivery_group_catalogs : local.auto_selected_delivery_group_catalogs

  active_delivery_group_targets = {
    for logical_name, catalog_key in local.active_delivery_group_catalogs_effective :
    logical_name => merge(local.catalog_deployments_effective[catalog_key], {
      catalog_deployment_key = catalog_key
    })
    if contains(keys(local.catalog_deployments_effective), catalog_key)
  }
}

check "active_delivery_group_catalogs_cover_each_logical_name" {
  assert {
    condition     = length(local.active_delivery_group_catalogs_effective) == length(local.catalog_logical_names)
    error_message = "Set active_delivery_group_catalogs for each logical_name when multiple catalog_deployments generations are retained side by side."
  }
}

check "active_delivery_group_catalogs_reference_existing_catalog_deployments" {
  assert {
    condition = alltrue([
      for catalog_key in values(local.active_delivery_group_catalogs_effective) :
      contains(keys(local.catalog_deployments_effective), catalog_key)
    ])
    error_message = "Each active_delivery_group_catalogs value must reference an existing catalog_deployments key."
  }
}

check "active_delivery_group_catalogs_match_logical_name" {
  assert {
    condition = alltrue([
      for logical_name, catalog_key in local.active_delivery_group_catalogs_effective :
      local.catalog_deployments_effective[catalog_key].logical_name == logical_name
    ])
    error_message = "Each active_delivery_group_catalogs mapping must point to a catalog_deployments entry with the same logical_name as the map key."
  }
}
