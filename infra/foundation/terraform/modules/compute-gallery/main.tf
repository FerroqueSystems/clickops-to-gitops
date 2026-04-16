resource "azurerm_shared_image_gallery" "this" {
  name                = var.gallery_name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = var.description
  tags                = var.tags
}

resource "azurerm_shared_image" "this" {
  for_each            = var.image_definitions
  name                = each.key
  gallery_name        = azurerm_shared_image_gallery.this.name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = each.value.os_type
  hyper_v_generation  = each.value.hyper_v_generation
  architecture        = each.value.architecture

  identifier {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
  }

  tags = var.tags
}
