output "catalog_name" {
  value = local.catalog_name
}

output "prepared_image_definition_id" {
  value = citrix_image_definition.this.id
}

output "prepared_image_version_id" {
  value = citrix_image_version.this.id
}

output "catalog_id" {
  value = citrix_machine_catalog.this.id
}

output "delivery_group_name" {
  value = var.delivery_group_name
}

output "generation" {
  value = var.generation
}

output "session_type" {
  value = var.session_type
}

output "plan" {
  value = local.plan
}
