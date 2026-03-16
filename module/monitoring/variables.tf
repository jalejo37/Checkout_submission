
variable "resource_group_name" {
  description = "Resource group where monitoring resources will be deployed"
  type        = string
}

variable "location" {
  description = "Azure region for monitoring resources"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
}

variable "action_group_name" {
  description = "Name of the Azure Monitor Action Group"
  type        = string
}

variable "action_group_short_name" {
  description = "Short name for the Azure Monitor Action Group"
  type        = string
}

variable "alert_email_address" {
  description = "Email address that receives alert notifications"
  type        = string
}

variable "metric_alert_name" {
  description = "Name of the metric alert for the Function App"
  type        = string
}

variable "function_app_id" {
  description = "ID of the Function App being monitored"
  type        = string
}

variable "storage_account_id" {
  description = "ID of the storage account being monitored"
  type        = string
}

variable "function_app_diagnostic_setting_name" {
  description = "Name of the diagnostic setting applied to the Function App"
  type        = string
}

variable "storage_account_diagnostic_setting_name" {
  description = "Name of the diagnostic setting applied to the storage account"
  type        = string
}

variable "tags" {
  description = "Tags applied to monitoring resources"
  type        = map(string)
  default     = {}
}
