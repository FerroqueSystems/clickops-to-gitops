output "gallery_name" {
  value = azurerm_shared_image_gallery.this.name
}

output "gallery_id" {
  value = azurerm_shared_image_gallery.this.id
}

output "image_definition_names" {
  value = {
    for name, image in azurerm_shared_image.this :
    name => image.name
  }
}

output "image_definition_ids" {
  value = {
    for name, image in azurerm_shared_image.this :
    name => image.id
  }
}
