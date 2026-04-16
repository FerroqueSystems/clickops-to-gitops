variable "resource_group_name" {
  description = "Resource group for foundation services."
  type        = string
  default     = "rg-clickops-gitops-foundation"
}

variable "location" {
  description = "Azure region for foundation services."
  type        = string
  default     = "Canada Central"
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

variable "enable_compute_gallery" {
  description = "Create an Azure Compute Gallery and image definitions for Packer-built images."
  type        = bool
  default     = false
}

variable "compute_gallery_name" {
  description = "Azure Compute Gallery name."
  type        = string
  default     = "clickopsGallery"
}

variable "compute_gallery_description" {
  description = "Description for the Azure Compute Gallery."
  type        = string
  default     = "Shared image gallery for ClickOps-to-GitOps Citrix images."
}

variable "compute_gallery_image_definitions" {
  description = "Image definitions to create inside the Azure Compute Gallery."
  type = map(object({
    os_type            = string
    publisher          = string
    offer              = string
    sku                = string
    hyper_v_generation = optional(string, "V2")
    architecture       = optional(string, "x64")
  }))
  default = {}
}

variable "compute_gallery_tags" {
  description = "Tags to apply to the Azure Compute Gallery and image definitions."
  type        = map(string)
  default     = {}
}
