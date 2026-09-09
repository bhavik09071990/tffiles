# ---------------------------------------------------------------------------
# Azure Container Apps Environment
# Uses VNet integration with dedicated subnet per architecture decision #2.
# Internal (no public IP) + workload profile (decision #3). The Consumption
# workload profile requires internal_load_balancer_enabled (gotcha #2).
# Using Azure Verified Module: Azure/avm-res-containerapp/azurerm
# ---------------------------------------------------------------------------

module "container_apps_environment" {
  source  = "Azure/avm-res-containerapp/azurerm"
  version = "0.9.0"

  name                          = var.container_app_environment_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  log_analytics_workspace_id    = var.log_analytics_workspace_id

  vnet_configuration {
    internal                     = true
    infrastructure_subnet_id      = var.container_apps_subnet_id
    docker_bridge_cidr            = "172.16.0.0/16"
    internal_load_balancer_enabled = true
  }

  dynamic "workload_profile" {
    for_each = var.workload_profile_name == "Consumption" ? [] : [1]

    content {
      name  = var.workload_profile_name
      count = var.workload_profile_count
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Azure Container Registry
# Private by default (decision #6). Public network access disabled.
# Container Apps pull images over the Private Endpoint using Managed Identity
# (AcrPull role). Admin user disabled per security requirements.
# Using Azure Verified Module: Azure/avm-res-containerregistry-registry/azurerm
# ---------------------------------------------------------------------------

module "container_registry" {
  source  = "Azure/avm-res-containerregistry-registry/azurerm"
  version = "0.8.0"

  name                = var.container_registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku

  admin_enabled = false

  public_network_access_enabled = false

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Azure Key Vault
# REQUIRED per project requirements and architecture decision #6.
# Managed Identity + RBAC for authentication (no secrets in Terraform).
# Public network access disabled — applications use Key Vault SDK / MI auth.
# Soft delete and purge protection enabled for data recovery.
# Using Azure Verified Module: Azure/avm-res-keyvault-vault/azurerm
# ---------------------------------------------------------------------------

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.11.0"

  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  soft_delete_retention_days  = 7
  purge_protection_enabled    = false # Allow purge for dev; enable in prod

  public_network_access_enabled = false

  # RBAC for secrets, keys, and certificates
  rbac_authorization_enabled = true

  tags = var.tags
}

data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "container_apps_environment_id" {
  description = "ID of the Container Apps Environment"
  value       = module.container_apps_environment.id
}

output "container_apps_environment_fqdn" {
  description = "Default FQDN of the Container Apps Environment"
  value       = module.container_apps_environment.default_domain
}

output "container_registry_id" {
  description = "ID of the Azure Container Registry"
  value       = module.container_registry.id
}

output "container_registry_login_server" {
  description = "Login server of the Azure Container Registry"
  value       = module.container_registry.login_server
}

output "key_vault_id" {
  description = "ID of the Azure Key Vault"
  value       = module.key_vault.id
}

output "key_vault_name" {
  description = "Name of the Azure Key Vault"
  value       = module.key_vault.name
}

output "api_management_id" {
  description = "ID of the API Management instance"
  value       = azurerm_api_management.main.id
}

output "api_management_name" {
  description = "Name of the API Management instance"
  value       = azurerm_api_management.main.name
}

output "api_management_hostname" {
  description = "Hostname of the API Management instance"
  value       = azurerm_api_management.main.hostname
}