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

variable "enable_artifact_storage" {
  description = "Create a blob storage account and private container for image build artifacts such as Citrix VDA installers and Optimizer packages."
  type        = bool
  default     = false
}

variable "artifact_storage_account_name" {
  description = "Azure Storage account name for image build artifacts. Must be globally unique and use only lowercase letters and numbers."
  type        = string
  default     = null
}

variable "artifact_storage_container_name" {
  description = "Private blob container name for image build artifacts."
  type        = string
  default     = "ctxsw"
}

variable "artifact_storage_account_tier" {
  description = "Storage account tier for image build artifacts."
  type        = string
  default     = "Standard"
}

variable "artifact_storage_account_replication_type" {
  description = "Storage account replication type for image build artifacts."
  type        = string
  default     = "LRS"
}

variable "artifact_storage_access_tier" {
  description = "Blob access tier for image build artifacts."
  type        = string
  default     = "Hot"
}

variable "artifact_storage_tags" {
  description = "Tags to apply to the image build artifact storage account."
  type        = map(string)
  default     = {}
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
