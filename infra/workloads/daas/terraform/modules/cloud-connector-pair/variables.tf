variable "environment_name" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "instance_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
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

variable "tags" {
  type = map(string)
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "private_ip_addresses" {
  type    = list(string)
  default = []
}

variable "zones" {
  type    = list(string)
  default = []
}

variable "image_publisher" {
  type = string
}

variable "image_offer" {
  type = string
}

variable "image_sku" {
  type = string
}

variable "image_version" {
  type = string
}

variable "enable_domain_join" {
  type    = bool
  default = false
}

variable "domain_name" {
  type    = string
  default = null
}

variable "domain_join_username" {
  type    = string
  default = null
}

variable "domain_join_password" {
  type      = string
  sensitive = true
  default   = null
}

variable "domain_join_ou_path" {
  type    = string
  default = null
}

variable "auto_shutdown_enabled" {
  type    = bool
  default = true
}

variable "auto_shutdown_time" {
  type = string
}

variable "auto_shutdown_timezone" {
  type = string
}

variable "enable_system_assigned_identity" {
  type    = bool
  default = true
}
