variable "resource_group_name" {
  description = "Resource group for foundation services."
  type        = string
  default     = "rg-clickops-gitops-foundation"
}

variable "location" {
  description = "Azure region for foundation services."
  type        = string
  default     = "eastus2"
}

# Feature flags (opt-in)
variable "enable_network_hub" {
  description = "Create hub networking primitives (optional)."
  type        = bool
  default     = false
}

variable "enable_storage_fileshare" {
  description = "Create shared storage / file share services (optional)."
  type        = bool
  default     = false
}

variable "enable_keyvault" {
  description = "Create an Azure Key Vault (optional)."
  type        = bool
  default     = false
}

variable "enable_identity_entra" {
  description = "Create Entra ID objects (optional; placeholder)."
  type        = bool
  default     = false
}

variable "enable_adm_agent" {
  description = "Deploy Citrix ADM agent resources (optional; placeholder)."
  type        = bool
  default     = false
}
