data "azurerm_resource_group" "shared" {
  name = var.shared_resource_group_name
}

data "azurerm_client_config" "current" {}

data "azurerm_virtual_network" "shared" {
  name                = var.shared_virtual_network_name
  resource_group_name = data.azurerm_resource_group.shared.name
}

data "azurerm_subnet" "management" {
  name                 = var.management_subnet_name
  virtual_network_name = data.azurerm_virtual_network.shared.name
  resource_group_name  = data.azurerm_resource_group.shared.name
}

data "azurerm_subnet" "server" {
  name                 = var.server_subnet_name
  virtual_network_name = data.azurerm_virtual_network.shared.name
  resource_group_name  = data.azurerm_resource_group.shared.name
}

data "azurerm_subnet" "client" {
  name                 = var.client_subnet_name
  virtual_network_name = data.azurerm_virtual_network.shared.name
  resource_group_name  = data.azurerm_resource_group.shared.name
}
