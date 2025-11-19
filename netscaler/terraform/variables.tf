variable "netscaler_endpoint" {
  description = "NetScaler/ADC management endpoint."
  type        = string
  default     = "https://netscaler.example.com"
}

variable "netscaler_username" {
  description = "Username for NetScaler management."
  type        = string
  default     = "nsroot"
  sensitive   = true
}

variable "netscaler_password" {
  description = "Password for NetScaler management."
  type        = string
  default     = "CHANGE_ME"
  sensitive   = true
}
