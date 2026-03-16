mock_provider "azurerm" {}

run "function_app_keeps_security_controls" {
  command = plan

  variables {
    resource_group_name       = "rg-test"
    location                  = "uksouth"
    function_app_name         = "func-checkout-test"
    service_plan_name         = "asp-checkout-test"
    storage_account_name      = "stcheckouttest123"
    application_insights_name = "appi-checkout-test"

    funcapp_subnet_id         = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/app"
    private_endpoint_subnet_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/pe"
    private_endpoint_name     = "pe-checkout-test"
    vnet_id                   = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet"

    key_vault_id              = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv-checkout-test"
    mtls_ca_cert_secret_uri   = "https://kv-checkout-test.vault.azure.net/secrets/ca-cert-pem"

    tags = {
      Environment = "dev"
      Project     = "checkout"
    }
  }

  assert {
    condition     = azurerm_windows_function_app.function.public_network_access_enabled == false
    error_message = "Function App must not expose public network access."
  }

  assert {
    condition     = azurerm_windows_function_app.function.client_certificate_mode == "Required"
    error_message = "Function App client certificate mode must be Required."
  }

  assert {
    condition     = azurerm_windows_function_app.function.identity[0].type == "SystemAssigned"
    error_message = "Function App must use a system-assigned managed identity."
  }

  assert {
    condition     = azurerm_windows_function_app.function.https_only == true
    error_message = "Function App must enforce HTTPS-only traffic."
  }

  assert {
    condition     = azurerm_storage_account.function.public_network_access_enabled == false
    error_message = "Storage account public network access must be disabled."
  }

  assert {
    condition     = azurerm_role_assignment.function_key_vault_secrets_user.role_definition_name == "Key Vault Secrets User"
    error_message = "Function App managed identity must be granted Key Vault Secrets User on the Key Vault."
  }

  assert {
    condition     = startswith(azurerm_windows_function_app.function.app_settings["MTLS_CA_CERT_PEM"], "@Microsoft.KeyVault(")
    error_message = "Function App must use a Key Vault reference for the trusted CA certificate."
  }
}