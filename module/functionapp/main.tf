resource "azurerm_storage_account" "function" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [var.funcapp_subnet_id]
  }

  tags = var.tags
}

resource "azurerm_service_plan" "function" {
  name                = var.service_plan_name
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = "B1"

  tags = var.tags
}

resource "azurerm_application_insights" "function" {
  name                = var.application_insights_name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  tags = var.tags
}

resource "azurerm_windows_function_app" "function" {
  name                = var.function_app_name
  resource_group_name = var.resource_group_name
  location            = var.location

  service_plan_id = azurerm_service_plan.function.id

  storage_account_name       = azurerm_storage_account.function.name
  storage_account_access_key = azurerm_storage_account.function.primary_access_key

  https_only                    = true
  public_network_access_enabled = false
  virtual_network_subnet_id     = var.funcapp_subnet_id
  client_certificate_mode       = "Required"

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version = "v8.0"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME               = "dotnet-isolated"
    APPLICATIONINSIGHTS_CONNECTION_STRING  = azurerm_application_insights.function.connection_string
    MTLS_CA_CERT_PEM                       = "@Microsoft.KeyVault(SecretUri=${var.mtls_ca_cert_secret_uri})"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "function_key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_windows_function_app.function.identity[0].principal_id
}

resource "azurerm_private_endpoint" "function" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.private_endpoint_name}-connection"
    private_connection_resource_id = azurerm_windows_function_app.function.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "function_app" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "function_app" {
  name                  = "${var.function_app_name}-dnslink"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.function_app.name
  virtual_network_id    = var.vnet_id
}

resource "azurerm_private_dns_zone_group" "function_app" {
  name                 = "default"
  private_endpoint_id  = azurerm_private_endpoint.function.id
  private_dns_zone_ids = [azurerm_private_dns_zone.function_app.id]
}
