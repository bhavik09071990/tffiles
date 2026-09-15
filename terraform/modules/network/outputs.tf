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

output "hub_resource_group_name" {
  description = "Name of the hub resource group"
  value       = azurerm_resource_group.hub.name
}

output "hub_private_endpoint_subnet_id" {
  description = "ID of the hub Private Endpoint subnet"
  value       = azurerm_subnet.hub_private_endpoint.id
}

output "hub_private_endpoint_subnet_name" {
  description = "Name of the hub Private Endpoint subnet"
  value       = azurerm_subnet.hub_private_endpoint.name
}

output "spoke_vnet_id" {
  description = "ID of the spoke VNet"
  value       = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
  description = "Name of the spoke VNet"
  value       = azurerm_virtual_network.spoke.name
}

output "spoke_resource_group_name" {
  description = "Name of the spoke resource group"
  value       = azurerm_resource_group.spoke.name
}

output "container_apps_subnet_id" {
  description = "ID of the Container Apps subnet in the spoke VNet"
  value       = azurerm_subnet.spoke_container_apps.id
}

output "container_apps_subnet_name" {
  description = "Name of the Container Apps subnet in the spoke VNet"
  value       = azurerm_subnet.spoke_container_apps.name
}

output "spoke_private_endpoint_subnet_id" {
  description = "ID of the spoke Private Endpoint subnet"
  value       = azurerm_subnet.spoke_private_endpoint.id
}

output "spoke_private_endpoint_subnet_name" {
  description = "Name of the spoke Private Endpoint subnet"
  value       = azurerm_subnet.spoke_private_endpoint.name
}