# ---------------------------------------------------------------------------
# Private Endpoints and Private DNS for Azure PaaS services
# All private connectivity per architecture decisions #6, #7, #8
# Using Azure Verified Modules: Azure/avm-res-containerregistry-registry/azurerm,
# Azure/avm-res-keyvault-vault/azurerm, Azure/avm-res-network-networkmanager/azurerm
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Azure Container Registry Private Endpoint
# Zone: privatelink.azurecr.io  (gotcha #3)
# Using Azure Verified Module: Azure/avm-res-network-private-link-private-dns-zones
# ---------------------------------------------------------------------------

module "acr_private_endpoint" {
  source  = "Azure/avm-res-network-private-link-private-dns-zones/azurerm"
  version = "0.23.2"

  name                = "pep-acr-${var.acr_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id          = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-acr"
    private_connection_resource_id = var.acr_id
    is_manual_connection           = false
    request_message               = null
  }

  private_dns_zone_name = "privatelink.azurecr.io"
  vnet_id              = var.vnet_id

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Azure Key Vault Private Endpoint
# Zone: privatelink.vaultcore.azure.net  (gotcha #3)
# ---------------------------------------------------------------------------

module "kv_private_endpoint" {
  source  = "Azure/avm-res-network-private-link-private-dns-zones/azurerm"
  version = "0.23.2"

  name                = "pep-kv-${var.kv_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id          = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-kv"
    private_connection_resource_id = var.kv_id
    is_manual_connection           = false
    request_message               = null
  }

  private_dns_zone_name = "privatelink.vaultcore.azure.net"
  vnet_id              = var.vnet_id

  tags = var.tags
}

# ---------------------------------------------------------------------------
# API Management Private Endpoint
# Zone: privatelink.azure-api.net
# Note: No AVM module for APIM yet; direct resource usage retained
# ---------------------------------------------------------------------------

resource "azurerm_private_endpoint" "apim" {
  name                = "pep-apim-${var.apim_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id          = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-apim"
    private_connection_resource_id = var.apim_id
    is_manual_connection           = false
    request_message               = null
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "apim" {
  name                = "privatelink.azure-api.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "apim" {
  name                  = "link-apim-${var.resource_group_name}"
  resource_group_name    = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.apim.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_dns_zone_group" "apim" {
  name                = "zg-apim"
  private_dns_zone_id = azurerm_private_dns_zone.apim.id
  private_endpoint_id = azurerm_private_endpoint.apim.id
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "acr_private_endpoint_id" {
  description = "ID of the ACR Private Endpoint"
  value       = module.acr_private_endpoint.id
}

output "kv_private_endpoint_id" {
  description = "ID of the Key Vault Private Endpoint"
  value       = module.kv_private_endpoint.id
}

output "apim_private_endpoint_id" {
  description = "ID of the APIM Private Endpoint"
  value       = azurerm_private_endpoint.apim.id
}

output "acr_private_dns_zone_id" {
  description = "ID of the ACR Private DNS Zone"
  value       = module.acr_private_endpoint.private_dns_zone_id
}

output "kv_private_dns_zone_id" {
  description = "ID of the Key Vault Private DNS Zone"
  value       = module.kv_private_endpoint.private_dns_zone_id
}

output "apim_private_dns_zone_id" {
  description = "ID of the APIM Private DNS Zone"
  value       = azurerm_private_dns_zone.apim.id
}

output "apim_private_ip" {
  description = "Private IP of the APIM Private Endpoint"
  value       = azurerm_private_endpoint.apim.custom_dns_configs[0].ipv4_address
}