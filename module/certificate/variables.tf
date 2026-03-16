variable "resource_group_name" {
  description = "Resource group where the Key Vault will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region for the Key Vault"
  type        = string
}

variable "tenant_id" {
  description = "Azure tenant ID required for Key Vault"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault used to store certificate material"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID used for the Key Vault private endpoint"
  type        = string
}

variable "vnet_id" {
  description = "VNet ID linked to the Key Vault private DNS zone"
  type        = string
}

variable "private_dns_zone_name" {
  description = "Private DNS zone name for Key Vault private endpoint resolution"
  type        = string
  default     = "privatelink.vaultcore.azure.net"
}

variable "ca_common_name" {
  description = "Common name for the self signed CA certificate"
  type        = string
  default     = "internal-api-ca"
}

variable "client_common_name" {
  description = "Common name for the client certificate"
  type        = string
  default     = "internal-api-client"
}

variable "organization_name" {
  description = "Organization name used in certificate subjects"
  type        = string
  default     = "checkout-assessment"
}

variable "validity_period_hours" {
  description = "Validity period for generated certificates in hours"
  type        = number
  default     = 2190
}

variable "tags" {
  description = "Tags applied to the Key Vault"
  type        = map(string)
  default     = {}
}
