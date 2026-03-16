
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "action_group_id" {
  description = "ID of the Azure Monitor Action Group"
  value       = azurerm_monitor_action_group.main.id
}

output "metric_alert_id" {
  description = "ID of the Function App metric alert"
  value       = azurerm_monitor_metric_alert.function_5xx.id
}

output "function_app_diagnostic_setting_id" {
  description = "ID of the diagnostic setting applied to the Function App"
  value       = azurerm_monitor_diagnostic_setting.function_app.id
}

output "storage_account_diagnostic_setting_id" {
  description = "ID of the diagnostic setting applied to the storage account"
  value       = azurerm_monitor_diagnostic_setting.storage_account.id
}
