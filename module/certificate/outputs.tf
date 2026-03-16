output "key_vault_id" {
  description = "ID of the Key Vault storing certificate material"
  value       = azurerm_key_vault.certs.id
}

output "key_vault_name" {
  description = "Name of the Key Vault storing certificate material"
  value       = azurerm_key_vault.certs.name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.certs.vault_uri
}

output "ca_cert_secret_name" {
  description = "Key Vault secret name for the CA certificate"
  value       = azurerm_key_vault_secret.ca_cert_pem.name
}

output "ca_cert_secret_uri" {
  description = "Versionless Key Vault secret URI for the CA certificate"
  value       = "${azurerm_key_vault.certs.vault_uri}secrets/${azurerm_key_vault_secret.ca_cert_pem.name}"
}

output "client_cert_secret_name" {
  description = "Key Vault secret name for the client certificate"
  value       = azurerm_key_vault_secret.client_cert_pem.name
}

output "ca_cert_pem" {
  description = "CA certificate in PEM format"
  value       = tls_self_signed_cert.ca.cert_pem
  sensitive   = true
}

output "client_cert_pem" {
  description = "Client certificate in PEM format"
  value       = tls_locally_signed_cert.client.cert_pem
  sensitive   = true
}

output "key_vault_private_endpoint_id" {
  description = "ID of the Key Vault private endpoint"
  value       = azurerm_private_endpoint.key_vault.id
}

output "key_vault_private_dns_zone_id" {
  description = "ID of the Key Vault private DNS zone"
  value       = azurerm_private_dns_zone.key_vault.id
}
