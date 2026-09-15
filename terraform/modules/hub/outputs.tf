# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "hub_vnet_id" {
  description = "ID of the hub VNet"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Name of the hub VNet"
  value       = azurerm_virtual_network.hub.name
}

output "hub_private_endpoint_subnet_id" {
  description = "ID of the hub Private Endpoint subnet"
  value       = azurerm_subnet.private_endpoint.id
}

output "hub_private_endpoint_subnet_name" {
  description = "Name of the hub Private Endpoint subnet"
  value       = azurerm_subnet.private_endpoint.name
}