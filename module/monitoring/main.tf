# Create a Log Analytics Workspace for centralised logging
# Create an Action Group for alert notifications
# reate at least one Metric Alert for the Function App
# Create Diagnostic Settings to send platform logs/metrics to Log Analytics

# Azure Monitor alerts overview:
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_metric_alert

# Diagnostic Settings overview:
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting


# Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

# Action Group for alert notifications
resource "azurerm_monitor_action_group" "main" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name

  email_receiver {
    name                    = "email-notification"
    email_address           = var.alert_email_address
    use_common_alert_schema = true
  }

  tags = var.tags
}

# Metric Alert for Function App 5xx responses
resource "azurerm_monitor_metric_alert" "function_5xx" {
  name                = var.metric_alert_name
  resource_group_name = var.resource_group_name
  scopes              = [var.function_app_id]
  description         = "Alert when the Function App returns 5xx responses"
  severity            = 2
  enabled             = true
  frequency           = "PT5M"
  window_size         = "PT5M"

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 0
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }

  tags = var.tags
}

# Diagnostic Settings for the Function App
resource "azurerm_monitor_diagnostic_setting" "function_app" {
  name                       = var.function_app_diagnostic_setting_name
  target_resource_id         = var.function_app_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Diagnostic Settings for the Storage Account
resource "azurerm_monitor_diagnostic_setting" "storage_account" {
  name                       = var.storage_account_diagnostic_setting_name
  target_resource_id         = var.storage_account_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category_group = "allLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
