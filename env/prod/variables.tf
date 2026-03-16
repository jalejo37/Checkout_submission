variable "resource_group_name" {
  description = "Resource group for the prod environment"
  type        = string
}

variable "location" {
  description = "Azure region for the prod environment"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID for Key Vault"
  type        = string
}

variable "alert_email_address" {
  description = "Email address for monitoring alerts"
  type        = string
}
