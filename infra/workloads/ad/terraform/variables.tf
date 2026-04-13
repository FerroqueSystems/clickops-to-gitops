variable "subscription_id" {
  description = "Azure subscription ID where the shared NetScaler and AD resources exist."
  type        = string
}

variable "environment_name" {
  description = "Short environment label used in generated names."
  type        = string
  default     = "demo"
}

variable "domain_name" {
  description = "Active Directory DNS domain name that these servers will be promoted into."
  type        = string
  default     = "clickops.demo"
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

variable "domain_controller_count" {
  description = "Number of domain controller VMs to create for the demo environment."
  type        = number
  default     = 2

  validation {
    condition     = var.domain_controller_count == 2
    error_message = "This demo scaffold currently expects exactly two domain controllers."
  }
}

variable "domain_controller_name_prefix" {
  description = "Name prefix used for the domain controller VM naming."
  type        = string
  default     = "ad-dc"
}

variable "domain_controller_subnet_role" {
  description = "Subnet role used for the domain controller VMs."
  type        = string
  default     = "management"

  validation {
    condition     = contains(["management", "server", "client"], var.domain_controller_subnet_role)
    error_message = "domain_controller_subnet_role must be one of management, server, or client."
  }
}

variable "domain_controller_private_ip_addresses" {
  description = "Static private IP addresses for the two domain controller NICs."
  type        = list(string)

  validation {
    condition     = length(var.domain_controller_private_ip_addresses) == var.domain_controller_count
    error_message = "Provide one private IP address per domain controller."
  }
}

variable "domain_controller_zones" {
  description = "Optional availability zones for the domain controller VMs."
  type        = list(string)
  default     = ["1", "2"]

  validation {
    condition     = length(var.domain_controller_zones) == 0 || length(var.domain_controller_zones) == var.domain_controller_count
    error_message = "domain_controller_zones must be empty or contain one value per domain controller."
  }
}

variable "domain_controller_vm_size" {
  description = "Azure VM size for the domain controller VMs."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "domain_controller_admin_username" {
  description = "Local administrator username for the Windows Server VMs."
  type        = string
  default     = "localadmin"
}

variable "domain_controller_admin_password" {
  description = "Local administrator password for the Windows Server VMs."
  type        = string
  sensitive   = true
}

variable "domain_controller_image_publisher" {
  description = "Marketplace image publisher for the domain controller Windows Server image."
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "domain_controller_image_offer" {
  description = "Marketplace image offer for the domain controller Windows Server image."
  type        = string
  default     = "WindowsServer"
}

variable "domain_controller_image_sku" {
  description = "Marketplace image SKU for the domain controller Windows Server image."
  type        = string
  default     = "2022-datacenter-azure-edition"
}

variable "domain_controller_image_version" {
  description = "Marketplace image version for the domain controller Windows Server image."
  type        = string
  default     = "latest"
}

variable "tags" {
  description = "Tags to apply to the domain controller resources."
  type        = map(string)
  default     = {}
}
