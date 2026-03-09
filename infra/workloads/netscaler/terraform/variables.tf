variable "resource_group_name" {
  description = "Name for the resource group that will contain all created resources"
  default     = "terraform-resource-group"
}

variable "subscription_id" {
  description = "Azure subscription ID where resources will be deployed."
  type        = string
}

variable "create_netscaler_service_principal" {
  description = "Whether to create an Azure AD application/service principal for NetScaler Azure integration."
  type        = bool
  default     = true
}

variable "netscaler_service_principal_name" {
  description = "Display name for the Azure AD application created for NetScaler."
  type        = string
  default     = "netscaler-azure-integration"
}

variable "netscaler_service_principal_role" {
  description = "Azure RBAC role assigned to the NetScaler service principal at subscription scope."
  type        = string
  default     = "Contributor"
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
