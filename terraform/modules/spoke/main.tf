# ---------------------------------------------------------------------------
# Spoke VNet - workload network for Container Apps
# Contains Container Apps subnet and Private Endpoint subnet (future PostgreSQL, Redis)
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.name_prefix
}

resource "azurerm_virtual_network" "spoke" {
  name                = "${local.name_prefix}-spoke-vnet"
  address_space       = [var.spoke_address_space]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Container Apps subnet - for ACA Environment
resource "azurerm_subnet" "container_apps" {
  name               = "${local.name_prefix}-aca-subnet"
  virtual_network_id = azurerm_virtual_network.spoke.id
  address_prefixes   = [var.container_apps_subnet_address_prefix]
  service_endpoints  = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
  delegations = [{
    name = "delegation"
    delegation = {
      name    = "Microsoft.App/environments"
      service = "Microsoft.App/environments"
      service_delegation = [{
        name = "Microsoft.App/environments"
      }]
    }
  }]
  tags = var.tags
}

# Private Endpoint subnet - for future PostgreSQL, Redis
resource "azurerm_subnet" "private_endpoint" {
  name               = "${local.name_prefix}-spoke-pep-subnet"
  virtual_network_id = azurerm_virtual_network.spoke.id
  address_prefixes   = [var.spoke_private_endpoint_subnet_address_prefix]
  service_endpoints  = ["Microsoft.ContainerRegistry", "Microsoft.KeyVault"]
  tags               = var.tags
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "spoke_vnet_id" {
  description = "ID of the spoke VNet"
  value       = azurerm_virtual_network.spoke.id
}

output "spoke_vnet_name" {
  description = "Name of the spoke VNet"
  value       = azurerm_virtual_network.spoke.name
}

output "container_apps_subnet_id" {
  description = "ID of the Container Apps subnet in the spoke VNet"
  value       = azurerm_subnet.container_apps.id
}

output "container_apps_subnet_name" {
  description = "Name of the Container Apps subnet in the spoke VNet"
  value       = azurerm_subnet.container_apps.name
}

output "spoke_private_endpoint_subnet_id" {
  description = "ID of the spoke Private Endpoint subnet"
  value       = azurerm_subnet.private_endpoint.id
}

output "spoke_private_endpoint_subnet_name" {
  description = "Name of the spoke Private Endpoint subnet"
  value       = azurerm_subnet.private_endpoint.name
}

# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

variable "name_prefix" {
  description = "Prefix used for all resource names (e.g. 'aca')"
  type        = string
  default     = "aca"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
  }
}

variable "spoke_address_space" {
  description = "Address space for the spoke VNet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "container_apps_subnet_address_prefix" {
  description = "Address prefix for the Container Apps subnet (minimum /22 required by Azure Container Apps)"
  type        = string
  default     = "10.1.0.0/22"
}

variable "spoke_private_endpoint_subnet_address_prefix" {
  description = "Address prefix for the Private Endpoint subnet in the spoke"
  type        = string
  default     = "10.1.4.0/26"
}