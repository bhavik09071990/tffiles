# ---------------------------------------------------------------------------
# Hub VNet - shared services (ACR, Key Vault, APIM)
# Contains Private Endpoint subnet for hub-level services
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.name_prefix
}

resource "azurerm_virtual_network" "hub" {
  name                = "${local.name_prefix}-hub-vnet"
  address_space       = [var.hub_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "private_endpoint" {
  name               = "${local.name_prefix}-pep-subnet"
  virtual_network_id = azurerm_virtual_network.hub.id
  address_prefixes   = [var.private_endpoint_subnet_address_prefix]
  service_endpoints  = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.ContainerRegistry", "Microsoft.ApiManagement"]
  delegations        = []
  tags               = var.tags
}