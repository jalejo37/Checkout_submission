output "function_app_id" {
  description = "ID of the Azure Windows Function App"
  value       = azurerm_windows_function_app.function.id
}

output "function_app_name" {
  description = "Name of the Azure Windows Function App"
  value       = azurerm_windows_function_app.function.name
}

output "function_app_default_hostname" {
  description = "Default hostname of the Function App"
  value       = azurerm_windows_function_app.function.default_hostname
}

output "function_app_principal_id" {
  description = "Principal ID of the Function App system assigned managed identity"
  value       = azurerm_windows_function_app.function.identity[0].principal_id
}

output "storage_account_id" {
  description = "ID of the storage account used by the Function App"
  value       = azurerm_storage_account.function.id
}

output "application_insights_id" {
  description = "ID of the Application Insights resource"
  value       = azurerm_application_insights.function.id
}

output "private_endpoint_id" {
  description = "ID of the Function App private endpoint"
  value       = azurerm_private_endpoint.function.id
}
