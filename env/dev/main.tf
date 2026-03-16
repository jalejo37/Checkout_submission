locals {
  env = "dev"

  tags = {
    environment = local.env
    project     = "checkout-assessment"
  }
}

# Rg

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = local.tags
}

# Certificates module

module "certificate" {
  source = "../../module/certificate"

  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  tenant_id                 = var.tenant_id
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  vnet_id                    = module.networking.vnet_id


  key_vault_name         = "kv-checkout-dev-001"
  ca_common_name         = "internal-api-ca-dev"
  client_common_name     = "internal-api-client-dev"
  organization_name      = "checkout-assessment"
  validity_period_hours  = 2190

  tags = local.tags
}

# Networking module

module "networking" {
  source = "../../module/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  vnet_name          = "vnet-checkout-dev"
  vnet_address_space = "10.10.0.0/16"

  funcapp_subnet_name = "snet-funcapp-dev"
  funcapp_subnet_cidr = "10.10.1.0/24"

  private_endpoint_subnet_name = "snet-pe-dev"
  private_endpoint_subnet_cidr = "10.10.2.0/24"

  funcapp_nsg_name          = "nsg-funcapp-dev"
  private_endpoint_nsg_name = "nsg-pe-dev"

  tags = local.tags
}

# Function App module
module "functionapp" {
  source = "../../module/functionapp"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  function_app_name         = "func-checkout-dev"
  service_plan_name         = "asp-checkout-dev"
  storage_account_name      = "stcheckoutdev001"
  application_insights_name = "appi-checkout-dev"
  key_vault_id               = module.certificate.key_vault_id
  funcapp_subnet_id          = module.networking.funcapp_subnet_id
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_endpoint_name      = "pe-func-checkout-dev"
  vnet_id                    = module.networking.vnet_id

  mtls_ca_cert_secret_uri    = module.certificate.ca_cert_secret_uri

  tags = local.tags
}

# Monitoring module
module "monitoring" {
  source = "../../module/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  log_analytics_workspace_name            = "law-checkout-dev"
  action_group_name                       = "ag-checkout-dev"
  action_group_short_name                 = "agdev"
  alert_email_address                     = var.alert_email_address
  metric_alert_name                       = "alert-func-5xx-dev"
  function_app_id                         = module.functionapp.function_app_id
  storage_account_id                      = module.functionapp.storage_account_id
  function_app_diagnostic_setting_name    = "diag-func-dev"
  storage_account_diagnostic_setting_name = "diag-storage-dev"

  tags = local.tags
}
