variable "subscription_id" {
  description = "Azure subscription ID where the shared NetScaler and DaaS resources exist."
  type        = string
}

variable "environment_name" {
  description = "Short environment label used in generated names."
  type        = string
  default     = "demo"
}

variable "catalog_generation" {
  description = "Generation identifier for the rotating machine catalog layer, for example 2026-03."
  type        = string
}

variable "shared_resource_group_name" {
  description = "Existing Azure resource group name shared with the NetScaler deployment."
  type        = string
}

variable "shared_virtual_network_name" {
  description = "Existing VNet name shared with the NetScaler deployment."
  type        = string
  default     = "terraform-virtual-network"
}

variable "management_subnet_name" {
  description = "Existing management subnet name."
  type        = string
  default     = "terraform-management-subnet"
}

variable "server_subnet_name" {
  description = "Existing server subnet name."
  type        = string
  default     = "terraform-server-subnet"
}

variable "client_subnet_name" {
  description = "Existing client subnet name."
  type        = string
  default     = "terraform-client-subnet"
}

variable "resource_location_name" {
  description = "Planned Citrix resource location name."
  type        = string
  default     = "demo-resource-location"
}

variable "hosting_connection_name" {
  description = "Planned Citrix Azure hosting connection name."
  type        = string
  default     = "demo-shared-hosting-connection"
}

variable "cloud_connector_count" {
  description = "Number of static Cloud Connector VMs to plan for."
  type        = number
  default     = 2
}

variable "cloud_connector_name_prefix" {
  description = "Name prefix used for Cloud Connector VM naming."
  type        = string
  default     = "ctx-cc"
}

variable "cloud_connector_vm_size" {
  description = "Azure VM size planned for Cloud Connector VMs."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "cloud_connector_subnet_role" {
  description = "Subnet role used for Cloud Connectors in the shared VNet."
  type        = string
  default     = "management"

  validation {
    condition     = contains(["management", "server", "client"], var.cloud_connector_subnet_role)
    error_message = "cloud_connector_subnet_role must be one of management, server, or client."
  }
}

variable "machine_catalogs" {
  description = "Logical machine catalogs that will be recreated on the monthly cadence."
  type = map(object({
    subnet_role           = string
    session_type          = string
    image_definition_name = string
    machine_count         = number
    vm_size               = string
    delivery_group_name   = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for catalog in values(var.machine_catalogs) :
      contains(["management", "server", "client"], catalog.subnet_role)
    ])
    error_message = "Each machine catalog subnet_role must be one of management, server, or client."
  }

  validation {
    condition = alltrue([
      for catalog in values(var.machine_catalogs) :
      contains(["single_session", "multi_session"], catalog.session_type)
    ])
    error_message = "Each machine catalog session_type must be single_session or multi_session."
  }
}

variable "tags" {
  description = "Tags to apply to planned static and rotating DaaS components."
  type        = map(string)
  default     = {}
}
