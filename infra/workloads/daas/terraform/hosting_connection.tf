resource "citrix_zone" "this" {
  resource_location_id = local.resource_location_id
}

locals {
  hosting_connection_resource_pool_name = coalesce(
    var.hosting_connection_resource_pool_name,
    "${var.hosting_connection_name}-pool"
  )

  hosting_connection_subnet_names = [
    for role in var.hosting_connection_subnet_roles :
    local.subnet_names_by_role[role]
  ]
}

resource "citrix_azure_hypervisor" "this" {
  name                = var.hosting_connection_name
  zone                = citrix_zone.this.id
  active_directory_id = coalesce(var.azure_active_directory_id, data.azurerm_client_config.current.tenant_id)
  subscription_id     = var.subscription_id

  authentication_mode                        = var.hosting_connection_authentication_mode
  application_id                             = var.hosting_connection_authentication_mode != "SystemAssignedManagedIdentity" ? var.hosting_connection_application_id : null
  application_secret                         = var.hosting_connection_authentication_mode == "AppClientSecret" ? var.hosting_connection_application_secret : null
  application_secret_expiration_date         = var.hosting_connection_authentication_mode == "AppClientSecret" ? var.hosting_connection_application_secret_expiration_date : null
  proxy_hypervisor_traffic_through_connector = var.hosting_connection_proxy_hypervisor_traffic_through_connector

  lifecycle {
    precondition {
      condition = (
        var.hosting_connection_authentication_mode != "AppClientSecret" ||
        (
          var.hosting_connection_application_id != null &&
          trimspace(var.hosting_connection_application_id) != "" &&
          var.hosting_connection_application_secret != null &&
          trimspace(var.hosting_connection_application_secret) != ""
        )
      )
      error_message = "Set hosting_connection_application_id and hosting_connection_application_secret when hosting_connection_authentication_mode is AppClientSecret."
    }

    precondition {
      condition = (
        var.hosting_connection_authentication_mode != "UserAssignedManagedIdentities" ||
        (
          var.hosting_connection_application_id != null &&
          trimspace(var.hosting_connection_application_id) != ""
        )
      )
      error_message = "Set hosting_connection_application_id to the user-assigned managed identity client ID when hosting_connection_authentication_mode is UserAssignedManagedIdentities."
    }
  }
}

resource "citrix_azure_hypervisor_resource_pool" "this" {
  name                           = local.hosting_connection_resource_pool_name
  hypervisor                     = citrix_azure_hypervisor.this.id
  region                         = var.location
  virtual_network_resource_group = data.azurerm_resource_group.shared.name
  virtual_network                = data.azurerm_virtual_network.shared.name
  subnets                        = local.hosting_connection_subnet_names
}

locals {
  hosting_connection_plan = {
    zone_id                    = citrix_zone.this.id
    zone_name                  = citrix_zone.this.name
    hypervisor_id              = citrix_azure_hypervisor.this.id
    hypervisor_name            = citrix_azure_hypervisor.this.name
    resource_pool_id           = citrix_azure_hypervisor_resource_pool.this.id
    resource_pool_name         = citrix_azure_hypervisor_resource_pool.this.name
    authentication_mode        = var.hosting_connection_authentication_mode
    location                   = var.location
    resource_group_name        = data.azurerm_resource_group.shared.name
    virtual_network_name       = data.azurerm_virtual_network.shared.name
    subnet_names_by_role       = local.subnet_names_by_role
    resource_pool_subnet_names = local.hosting_connection_subnet_names
    lifecycle                  = "static"
  }
}
