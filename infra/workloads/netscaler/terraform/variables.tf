variable "resource_group_name" {
  description = "Name for the resource group that will contain all created resources"
  default     = "terraform-resource-group"
}

variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed."
  type        = string
}

variable "tags" {
  description = "Tags to apply to created resources. Used for cost allocation, governance, and tracking."
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Azure location where all resources will be created"
}

variable "virtual_network_address_space" {
  description = "Address space for the virtual network."
}

variable "management_subnet_address_prefix" {
  description = "The address prefix that will be used for the management subnet. Must be contained inside the VNet address space"
}

variable "client_subnet_address_prefix" {
  description = "The address prefix that will be used for the client subnet. Must be contained inside the VNet address space"
}

variable "server_subnet_address_prefix" {
  description = "The address prefix that will be used for the server subnet. Must be contained inside the VNet address space"
}

variable "adc_admin_username" {
  description = "User name for the Citrix ADC admin user."
  default     = "nsroot"
}

variable "adc_admin_password" {
  type        = string
  sensitive   = true
  description = "Password for the Citrix ADC admin user. Must be sufficiently complex to pass azurerm provider checks."
}
variable "citrixadc_rpc_node_password" {
  description = "The new ADC RPC node password that will replace the default one on both ADC instances. [Learn More about RPCNode](https://docs.citrix.com/en-us/citrix-adc/current-release/getting-started-with-citrix-adc/change-rpc-node-password.html)"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key content for accessing the Ubuntu bastion and ADC VMs."
  type        = string
}

variable "ubuntu_vm_size" {
  description = "Size for the ubuntu machine."
  default     = "Standard_B2als_v2"
}

variable "ubuntu_admin_user" {
  description = "User name for ubuntu admin"
  default     = "adminuser"
}

variable "bastion_repository_url" {
  description = "Git repository URL to use from the bastion helper files."
  type        = string
  default     = "git@github.com:FerroqueSystems/clickops-to-gitops.git"
}

variable "controlling_subnet" {
  description = "The CIDR block of the machines that will be allowed access to the management subnet."
}

variable "vdi_public_ip_cidr" {
  description = "Optional public CIDR block (for example x.x.x.x/32) allowed to access management ports."
  type        = string
  default     = null
}

variable "adc_vm_size" {
  description = "Size for the ADC machine. Must allow for 3 NICs."
  default     = "Standard_F8s_v2"
}

variable "ha_for_internal_lb" {
  description = "Whether to use HA for the internal load balancer."
  default     = false
}

variable "auto_shutdown_enabled" {
  description = "Whether to enable daily auto-shutdown for lab VMs."
  type        = bool
  default     = true
}

variable "auto_shutdown_time" {
  description = "Daily auto-shutdown time in HHMM 24-hour format."
  type        = string
  default     = "1800"
}

variable "auto_shutdown_timezone" {
  description = "Windows time zone ID used by Azure for auto-shutdown scheduling."
  type        = string
  default     = "Eastern Standard Time"
}

variable "enable_netscaler_agent" {
  description = "Whether to deploy a NetScaler Console Agent VM."
  type        = bool
  default     = false
}

variable "netscaler_agent_name" {
  description = "Name of the NetScaler Console Agent VM."
  type        = string
  default     = "terraform-netscaler-agent"
}

variable "netscaler_agent_vm_size" {
  description = "Azure VM size for NetScaler Console Agent."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "netscaler_agent_admin_username" {
  description = "Provisioning username for the NetScaler Console Agent VM. Do not use reserved appliance usernames such as nsroot or nsrecover."
  type        = string
  default     = "agentadmin"

  validation {
    condition     = !contains(["nsroot", "nsrecover"], lower(var.netscaler_agent_admin_username))
    error_message = "netscaler_agent_admin_username must not be nsroot or nsrecover."
  }
}

variable "netscaler_agent_admin_password" {
  description = "Provisioning password for the NetScaler Console Agent VM."
  type        = string
  sensitive   = true
  default     = null
}

variable "netscaler_agent_image_publisher" {
  description = "Marketplace image publisher for NetScaler Console Agent."
  type        = string
  default     = "citrix"
}

variable "netscaler_agent_image_offer" {
  description = "Marketplace image offer for NetScaler Console Agent."
  type        = string
  default     = null
}

variable "netscaler_agent_image_sku" {
  description = "Marketplace image SKU for NetScaler Console Agent."
  type        = string
  default     = null
}

variable "netscaler_agent_image_version" {
  description = "Marketplace image version for NetScaler Agent."
  type        = string
  default     = "latest"
}

variable "netscaler_agent_plan_name" {
  description = "Marketplace plan name for NetScaler Console Agent. If null, defaults to image SKU."
  type        = string
  default     = null
}

variable "netscaler_agent_plan_product" {
  description = "Marketplace plan product for NetScaler Console Agent. If null, defaults to image offer."
  type        = string
  default     = null
}

variable "netscaler_agent_auto_register" {
  description = "Whether to auto-register NetScaler Console Agent to NetScaler Console using custom data."
  type        = bool
  default     = true
}

variable "netscaler_console_service_url" {
  description = "NetScaler Console service URL used by registeragent."
  type        = string
  default     = null
}

variable "netscaler_console_activation_code" {
  description = "NetScaler Console activation code used by registeragent."
  type        = string
  sensitive   = true
  default     = null
}
