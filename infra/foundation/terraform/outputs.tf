output "resource_group_name" {
  value       = var.resource_group_name
  description = "Foundation resource group name."
}

output "location" {
  value       = var.location
  description = "Foundation deployment region."
}

output "compute_gallery_name" {
  value       = var.enable_compute_gallery ? module.compute_gallery[0].gallery_name : null
  description = "Azure Compute Gallery name when enabled."
}

output "compute_gallery_id" {
  value       = var.enable_compute_gallery ? module.compute_gallery[0].gallery_id : null
  description = "Azure Compute Gallery resource ID when enabled."
}

output "compute_gallery_image_definition_names" {
  value       = var.enable_compute_gallery ? module.compute_gallery[0].image_definition_names : {}
  description = "Azure Compute Gallery image definition names when enabled."
}
