variable "resource_group_name" {
  description = "Resource group where the Function App resources will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "function_app_name" {
  description = "Name of the Azure Function App"
  type        = string
}

variable "service_plan_name" {
  description = "Name of the App Service Plan for the Function App"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the storage account used by the Function App"
  type        = string
}

variable "application_insights_name" {
  description = "Name of the Application Insights resource"
  type        = string
}

variable "funcapp_subnet_id" {
  description = "Subnet ID used for Function App VNet integration"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID used for the Function App private endpoint"
  type        = string
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint created for the Function App"
  type        = string
}

variable "vnet_id" {
  description = "VNet ID used to link private DNS for the Function App private endpoint"
  type        = string
}

variable "key_vault_id" {
  description = "Key Vault ID used for granting the Function App managed identity access to secrets"
  type        = string
}

variable "mtls_ca_cert_secret_uri" {
  description = "Versionless Key Vault secret URI for the CA certificate used by the function code"
  type        = string
}

variable "tags" {
  description = "Tags applied to all Function App resources"
  type        = map(string)
  default     = {}
}
