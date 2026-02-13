variable "prism_endpoint" {
  description = "Prism endpoint (https://<prism-ip>:9440)"
  type        = string
}

variable "prism_username" {
  description = "Prism user with required privileges"
  type        = string
}

variable "prism_password" {
  description = "Prism password (sensitive)"
  type        = string
  sensitive   = true
}

variable "cluster_uuid" {
  description = "Target cluster UUID"
  type        = string
  default     = ""
}
