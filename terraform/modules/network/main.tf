# ---------------------------------------------------------------------------
# Virtual Network
# Single application VNet (no hub) per architecture decision #1.
# Using Azure Verified Module: Azure/vnet/azurerm
# ---------------------------------------------------------------------------

module "vnet" {
  source  = "Azure/vnet/azurerm"
  version = "5.0.1"

  resource_group_name = var.resource_group_name
  vnet_location       = var.location
  vnet_name           = var.virtual_network_name

  address_space = [var.virtual_network_address_space]

  # Container Apps subnet
  subnet_names    = [var.container_apps_subnet_name, var.private_endpoint_subnet_name]
  subnet_prefixes = [var.container_apps_subnet_address_prefix, var.private_endpoint_subnet_address_prefix]

  subnet_delegation = {
    "${var.container_apps_subnet_name}" = {
      name = "Microsoft.App/environment"
      service {
        name = "Microsoft.App/environments"
      }
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "virtual_network_id" {
  description = "ID of the application VNet"
  value       = module.vnet.vnet_id
}

output "virtual_network_name" {
  description = "Name of the application VNet"
  value       = module.vnet.vnet_name
}

output "container_apps_subnet_id" {
  description = "ID of the Container Apps subnet"
  value       = module.vnet.vnet_subnets[var.container_apps_subnet_name]
}

output "container_apps_subnet_name" {
  description = "Name of the Container Apps subnet"
  value       = var.container_apps_subnet_name
}

output "private_endpoint_subnet_id" {
  description = "ID of the Private Endpoint subnet"
  value       = module.vnet.vnet_subnets[var.private_endpoint_subnet_name]
}

output "private_endpoint_subnet_name" {
  description = "Name of the Private Endpoint subnet"
  value       = var.private_endpoint_subnet_name
}