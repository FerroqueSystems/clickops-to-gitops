variable "subscription_id" {
  description = "Azure subscription ID where the shared NetScaler and DaaS resources exist."
  type        = string
}

variable "location" {
  description = "Azure region for DaaS resources."
  type        = string
  default     = "Canada Central"
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
  description = "Citrix Cloud resource location name."
  type        = string
  default     = "demo-resource-location"
}

variable "citrix_customer_id" {
  description = "Citrix Cloud customer ID used by the Citrix Terraform provider."
  type        = string
  sensitive   = true
}

variable "citrix_client_id" {
  description = "Citrix Cloud service principal ID used by the Citrix Terraform provider."
  type        = string
  sensitive   = true
}

variable "citrix_client_secret" {
  description = "Citrix Cloud service principal secret used by the Citrix Terraform provider."
  type        = string
  sensitive   = true
}

variable "citrix_cloud_environment" {
  description = "Citrix Cloud environment used by the Citrix Terraform provider."
  type        = string
  default     = "Production"
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

variable "cloud_connector_admin_username" {
  description = "Local administrator username for the Cloud Connector Windows VMs."
  type        = string
  default     = "localadmin"
}

variable "cloud_connector_admin_password" {
  description = "Local administrator password for the Cloud Connector Windows VMs."
  type        = string
  sensitive   = true
}

variable "cloud_connector_private_ip_addresses" {
  description = "Optional static private IP addresses for the Cloud Connector NICs. Leave empty to use dynamic allocation."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.cloud_connector_private_ip_addresses) == 0 || length(var.cloud_connector_private_ip_addresses) == var.cloud_connector_count
    error_message = "cloud_connector_private_ip_addresses must be empty or contain one value per Cloud Connector."
  }
}

variable "cloud_connector_zones" {
  description = "Optional availability zones for the Cloud Connector VMs."
  type        = list(string)
  default     = ["1", "2"]

  validation {
    condition     = length(var.cloud_connector_zones) == 0 || length(var.cloud_connector_zones) == var.cloud_connector_count
    error_message = "cloud_connector_zones must be empty or contain one value per Cloud Connector."
  }
}

variable "cloud_connector_image_publisher" {
  description = "Marketplace image publisher for the Cloud Connector Windows Server image."
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "cloud_connector_image_offer" {
  description = "Marketplace image offer for the Cloud Connector Windows Server image."
  type        = string
  default     = "WindowsServer"
}

variable "cloud_connector_image_sku" {
  description = "Marketplace image SKU for the Cloud Connector Windows Server image."
  type        = string
  default     = "2022-datacenter-azure-edition"
}

variable "cloud_connector_image_version" {
  description = "Marketplace image version for the Cloud Connector Windows Server image."
  type        = string
  default     = "latest"
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

variable "cloud_connector_enable_domain_join" {
  description = "Whether to join the Cloud Connector VMs to the Active Directory domain during deployment."
  type        = bool
  default     = true
}

variable "cloud_connector_domain_name" {
  description = "Active Directory DNS domain name used for Cloud Connector domain join."
  type        = string
  default     = "clickops.demo"
}

variable "cloud_connector_domain_join_username" {
  description = "Domain user with permission to join the Cloud Connector VMs to Active Directory."
  type        = string
  default     = "CLICKOPS\\localadmin"
}

variable "cloud_connector_domain_join_password" {
  description = "Password for the domain join account used by the Cloud Connector VMs."
  type        = string
  sensitive   = true
  default     = null
}

variable "cloud_connector_domain_join_ou_path" {
  description = "Optional OU path for Cloud Connector domain join."
  type        = string
  default     = null
}

variable "cloud_connector_auto_shutdown_enabled" {
  description = "Whether to enable daily auto-shutdown for Cloud Connector VMs."
  type        = bool
  default     = true
}

variable "cloud_connector_auto_shutdown_time" {
  description = "Daily auto-shutdown time for Cloud Connector VMs in HHMM 24-hour format."
  type        = string
  default     = "1800"
}

variable "cloud_connector_auto_shutdown_timezone" {
  description = "Windows time zone ID used by Azure for Cloud Connector auto-shutdown scheduling."
  type        = string
  default     = "Eastern Standard Time"
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
