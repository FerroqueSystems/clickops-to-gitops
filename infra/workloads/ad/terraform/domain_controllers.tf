resource "azurerm_network_interface" "domain_controller" {
  count               = var.domain_controller_count
  name                = "${local.domain_controller_names[count.index]}-nic"
  location            = data.azurerm_resource_group.shared.location
  resource_group_name = data.azurerm_resource_group.shared.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = local.subnet_ids_by_role[var.domain_controller_subnet_role]
    private_ip_address_allocation = "Static"
    private_ip_address            = var.domain_controller_private_ip_addresses[count.index]
  }

  tags = merge(var.tags, {
    Lifecycle = "static"
    Role      = "domain-controller"
  })
}

resource "azurerm_windows_virtual_machine" "domain_controller" {
  count               = var.domain_controller_count
  name                = local.domain_controller_names[count.index]
  resource_group_name = data.azurerm_resource_group.shared.name
  location            = data.azurerm_resource_group.shared.location
  size                = var.domain_controller_vm_size
  admin_username      = var.domain_controller_admin_username
  admin_password      = var.domain_controller_admin_password
  network_interface_ids = [
    azurerm_network_interface.domain_controller[count.index].id
  ]
  patch_mode         = "AutomaticByOS"
  provision_vm_agent = true
  zone               = length(var.domain_controller_zones) > count.index ? var.domain_controller_zones[count.index] : null

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = var.domain_controller_image_publisher
    offer     = var.domain_controller_image_offer
    sku       = var.domain_controller_image_sku
    version   = var.domain_controller_image_version
  }

  tags = merge(var.tags, {
    Lifecycle = "static"
    Role      = "domain-controller"
  })
}
