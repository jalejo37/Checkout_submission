# Checks whether identity has sufficient permissions to put secrets into keyvault

data "azurerm_client_config" "current" {}

# Generates the private key for the Certificate Authority (The TLS module in providers.tf)
# Like a pen for your passport office to givve approval signature to docs (certs)
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Creates a self signed CA certificate using the CA private key above. Acts as the Certificate Authority.
resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name  = var.ca_common_name
    organization = var.organization_name
  }
  # "true" tells Terraform this is not just a normal certificate. It is a certificate that is allowed to sign other certificates.
  is_ca_certificate     = true
  validity_period_hours = var.validity_period_hours

  # These allowed uses let the CA sign other certificates.
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
    "key_encipherment"
  ]
}

# Generates the private key for the client/request certificate. 
resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Creates a certificate signing request for the client.
# This is basically the client asking the CA to issue it a certificate.
resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name  = var.client_common_name
    organization = var.organization_name
  }
}

# Signs the client certificate request using the CA private key and CA certificate.
# Result: a client certificate trusted by the CA you created above.
resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.validity_period_hours

  # client_auth is the important usage for mutual TLS client authentication.
  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_encipherment"
  ]
}

# Creates the Key Vault where the certs and private keys will be stored.
# Public access is disabled so the vault is only reachable through Private Link.
resource "azurerm_key_vault" "certs" {
  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  public_network_access_enabled = false

  tags = var.tags
}

# Private DNS zone used for Key Vault private endpoint name resolution.
resource "azurerm_private_dns_zone" "key_vault" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Links the private DNS zone to the VNet so resources in that VNet resolve the vault privately.
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "${var.key_vault_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = var.tags
}

# Private endpoint for the Key Vault.
# The Key Vault private link subresource is named "vault".
resource "azurerm_private_endpoint" "key_vault" {
  name                = "${var.key_vault_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.key_vault_name}-psc"
    private_connection_resource_id = azurerm_key_vault.certs.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  tags = var.tags
}

# Associates the Key Vault private endpoint with the Key Vault private DNS zone.
resource "azurerm_private_dns_zone_group" "key_vault" {
  name                 = "default"
  private_endpoint_id  = azurerm_private_endpoint.key_vault.id
  private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]
}

# Grants the current Terraform identity permission to manage secrets in this Key Vault.
# With RBAC enabled on the vault, Terraform needs a role assignment rather than an access policy.
resource "azurerm_role_assignment" "current_key_vault_secrets_officer" {
  scope                = azurerm_key_vault.certs.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Stores the CA certificate in Key Vault.
# This is the public CA cert that other components can trust.
# Note: once the vault is private only, the Terraform runner must be able to reach the private endpoint.
resource "azurerm_key_vault_secret" "ca_cert_pem" {
  name         = "ca-cert-pem"
  value        = tls_self_signed_cert.ca.cert_pem
  key_vault_id = azurerm_key_vault.certs.id

  depends_on = [
    azurerm_role_assignment.current_key_vault_secrets_officer,
    azurerm_private_dns_zone_group.key_vault,
    azurerm_private_dns_zone_virtual_network_link.key_vault
  ]
}

# Stores the CA private key in Key Vault.
# This is highly sensitive because it can be used to sign more certificates.
resource "azurerm_key_vault_secret" "ca_private_key_pem" {
  name         = "ca-private-key-pem"
  value        = tls_private_key.ca.private_key_pem
  key_vault_id = azurerm_key_vault.certs.id

  depends_on = [
    azurerm_role_assignment.current_key_vault_secrets_officer,
    azurerm_private_dns_zone_group.key_vault,
    azurerm_private_dns_zone_virtual_network_link.key_vault
  ]
}

# Stores the signed client certificate in Key Vault.
# This is the certificate a calling service could present for mTLS.
resource "azurerm_key_vault_secret" "client_cert_pem" {
  name         = "client-cert-pem"
  value        = tls_locally_signed_cert.client.cert_pem
  key_vault_id = azurerm_key_vault.certs.id

  depends_on = [
    azurerm_role_assignment.current_key_vault_secrets_officer,
    azurerm_private_dns_zone_group.key_vault,
    azurerm_private_dns_zone_virtual_network_link.key_vault
  ]
}

# Stores the client private key in Key Vault.
# Together with the client certificate, this forms the client identity for mutual TLS.
resource "azurerm_key_vault_secret" "client_private_key_pem" {
  name         = "client-private-key-pem"
  value        = tls_private_key.client.private_key_pem
  key_vault_id = azurerm_key_vault.certs.id

  depends_on = [
    azurerm_role_assignment.current_key_vault_secrets_officer,
    azurerm_private_dns_zone_group.key_vault,
    azurerm_private_dns_zone_virtual_network_link.key_vault
  ]
}
