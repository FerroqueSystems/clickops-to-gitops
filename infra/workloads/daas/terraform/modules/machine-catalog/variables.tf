variable "environment_name" {
  type = string
}

variable "catalog_name_prefix" {
  type    = string
  default = "Ferroque"
}

variable "zone_id" {
  type = string
}

variable "hypervisor_id" {
  type = string
}

variable "hypervisor_resource_pool_id" {
  type = string
}

variable "generation" {
  type = string
}

variable "logical_name" {
  type = string
}

variable "location" {
  type = string
}

variable "image_resource_group_name" {
  type = string
}

variable "vda_resource_group_name" {
  type = string
}

variable "gallery_name" {
  type = string
}

variable "subnet_role" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "session_type" {
  type = string
}

variable "image_definition_name" {
  type = string
}

variable "image_version" {
  type = string
}

variable "machine_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "domain_join_username" {
  type = string
}

variable "domain_join_password" {
  type      = string
  sensitive = true
}

variable "domain_join_ou_path" {
  type    = string
  default = null
}

variable "domain_service_account_id" {
  type    = string
  default = null
}

variable "delivery_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
