locals {
  netscaler_agent_plan_name    = coalesce(var.netscaler_agent_plan_name, var.netscaler_agent_image_sku)
  netscaler_agent_plan_product = coalesce(var.netscaler_agent_plan_product, var.netscaler_agent_image_offer)
}

resource "azurerm_marketplace_agreement" "netscaler_agent_marketplace_agreement" {
  count     = var.enable_netscaler_agent ? 1 : 0
  publisher = var.netscaler_agent_image_publisher
  offer     = var.netscaler_agent_image_offer
  plan      = local.netscaler_agent_plan_name

  lifecycle {
    precondition {
      condition = (
        var.netscaler_agent_image_offer != null &&
        trimspace(var.netscaler_agent_image_offer) != "" &&
        var.netscaler_agent_image_sku != null &&
        trimspace(var.netscaler_agent_image_sku) != ""
      )
      error_message = "Set netscaler_agent_image_offer and netscaler_agent_image_sku when enable_netscaler_agent is true."
    }
  }
}

resource "azurerm_public_ip" "netscaler_agent_public_ip" {
  count               = var.enable_netscaler_agent ? 1 : 0
  name                = "${var.netscaler_agent_name}-public-ip"
  resource_group_name = azurerm_resource_group.terraform-resource-group.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "netscaler_agent_management_interface" {
  count               = var.enable_netscaler_agent ? 1 : 0
  name                = "${var.netscaler_agent_name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.terraform-resource-group.name

  ip_configuration {
    name                          = "management"
    subnet_id                     = azurerm_subnet.terraform-management-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.netscaler_agent_public_ip[0].id
  }
}

resource "azurerm_linux_virtual_machine" "netscaler_agent_machine" {
  count               = var.enable_netscaler_agent ? 1 : 0
  name                = var.netscaler_agent_name
  resource_group_name = azurerm_resource_group.terraform-resource-group.name
  location            = var.location
  size                = var.netscaler_agent_vm_size
  admin_username      = var.netscaler_agent_admin_username
  admin_password      = var.netscaler_agent_admin_password
  network_interface_ids = [
    azurerm_network_interface.netscaler_agent_management_interface[0].id
  ]
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.netscaler_agent_image_publisher
    offer     = var.netscaler_agent_image_offer
    sku       = var.netscaler_agent_image_sku
    version   = var.netscaler_agent_image_version
  }

  plan {
    publisher = var.netscaler_agent_image_publisher
    product   = local.netscaler_agent_plan_product
    name      = local.netscaler_agent_plan_name
  }

  custom_data = var.netscaler_agent_auto_register ? base64encode(<<-EOT
    #!/bin/bash
    registeragent -serviceurl ${coalesce(var.netscaler_console_service_url, "")} -activationcode ${coalesce(var.netscaler_console_activation_code, "")}
  EOT
  ) : null

  lifecycle {
    precondition {
      condition = (
        var.netscaler_agent_admin_password != null &&
        trimspace(var.netscaler_agent_admin_password) != ""
      )
      error_message = "Set netscaler_agent_admin_password when enable_netscaler_agent is true."
    }
    precondition {
      condition = (
        !var.netscaler_agent_auto_register || (
          var.netscaler_console_service_url != null &&
          trimspace(var.netscaler_console_service_url) != "" &&
          var.netscaler_console_activation_code != null &&
          trimspace(var.netscaler_console_activation_code) != ""
        )
      )
      error_message = "Set netscaler_console_service_url and netscaler_console_activation_code when netscaler_agent_auto_register is true."
    }
  }

  depends_on = [
    azurerm_marketplace_agreement.netscaler_agent_marketplace_agreement,
    azurerm_subnet_network_security_group_association.management-subnet-association,
  ]
}
