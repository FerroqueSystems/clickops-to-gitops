output "resource_group_name" {
  value       = var.resource_group_name
  description = "Foundation resource group name."
}

output "location" {
  value       = var.location
  description = "Foundation deployment region."
}

output "artifact_storage_account_name" {
  value       = var.enable_artifact_storage ? module.artifact_storage[0].storage_account_name : null
  description = "Artifact storage account name when enabled."
}

output "artifact_storage_container_name" {
  value       = var.enable_artifact_storage ? module.artifact_storage[0].container_name : null
  description = "Artifact storage container name when enabled."
}

output "artifact_storage_blob_endpoint" {
  value       = var.enable_artifact_storage ? module.artifact_storage[0].primary_blob_endpoint : null
  description = "Primary blob endpoint for artifact storage when enabled."
}

output "artifact_storage_container_url" {
  value       = var.enable_artifact_storage ? module.artifact_storage[0].container_url : null
  description = "Artifact storage container URL when enabled."
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
