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
