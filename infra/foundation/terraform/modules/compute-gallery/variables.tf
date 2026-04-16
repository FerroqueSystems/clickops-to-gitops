variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "gallery_name" {
  type = string
}

variable "description" {
  type = string
}

variable "image_definitions" {
  type = map(object({
    os_type            = string
    publisher          = string
    offer              = string
    sku                = string
    hyper_v_generation = optional(string, "V2")
    architecture       = optional(string, "x64")
  }))
}

variable "tags" {
  type = map(string)
}
