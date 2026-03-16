output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.this.name
}

output "funcapp_subnet_id" {
  description = "ID of the Function App subnet"
  value       = azurerm_subnet.funcapp.id
}

output "private_endpoint_subnet_id" {
  description = "ID of the Private Endpoint subnet"
  value       = azurerm_subnet.private_endpoints.id
}

