# ---------------------------------------------------------------------------
# Network Module - Hub and Spoke Topology
# Creates hub VNet (shared services) and spoke VNet (workloads) with peering.
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.name_prefix
}

# ---------------------------------------------------------------------------
# Hub VNet - shared services (ACR, Key Vault, APIM)
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "hub" {
  name     = "${local.name_prefix}-hub-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "hub" {
  name                = "${local.name_prefix}-hub-vnet"
  address_space       = [var.hub_address_space]
  location            = var.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags
}

# Hub Private Endpoint subnet - for ACR, Key Vault, APIM
resource "azurerm_subnet" "hub_private_endpoint" {
  name                = "${local.name_prefix}-pep-subnet"
  resource_group_name = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes    = [var.private_endpoint_subnet_address_prefix]
  service_endpoints   = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault", "Microsoft.ApiManagement"]
}

# ---------------------------------------------------------------------------
# Spoke VNet - workload network (Container Apps)
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "spoke" {
  name     = "${local.name_prefix}-spoke-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = "${local.name_prefix}-spoke-vnet"
  address_space       = [var.spoke_address_space]
  location            = var.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags
}

# Spoke Container Apps subnet - for ACA Environment
resource "azurerm_subnet" "spoke_container_apps" {
  name                = "${local.name_prefix}-aca-subnet"
  resource_group_name = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes    = [var.container_apps_subnet_address_prefix]
  service_endpoints   = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault"]

  delegation {
    name = "Microsoft.App/environments"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Spoke Private Endpoint subnet - for future PostgreSQL, Redis
resource "azurerm_subnet" "spoke_private_endpoint" {
  name                = "${local.name_prefix}-spoke-pep-subnet"
  resource_group_name = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes    = [var.spoke_private_endpoint_subnet_address_prefix]
  service_endpoints   = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
}

# ---------------------------------------------------------------------------
# VNet Peering (Hub <-> Spoke)
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "${local.name_prefix}-hub-to-spoke"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${local.name_prefix}-spoke-to-hub"
  resource_group_name       = azurerm_resource_group.spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}