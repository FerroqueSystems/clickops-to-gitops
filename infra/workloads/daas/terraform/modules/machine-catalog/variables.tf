variable "environment_name" {
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

variable "session_type" {
  type = string
}

variable "image_definition_name" {
  type = string
}

variable "machine_count" {
  type = number
}

variable "vm_size" {
  type = string
}

variable "delivery_group_name" {
  type = string
}

variable "tags" {
  type = map(string)
}
