locals {
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

  domain_controller_names = [
    for index in range(var.domain_controller_count) :
    format("%s-%s-%02d", var.domain_controller_name_prefix, var.environment_name, index + 1)
  ]
}
