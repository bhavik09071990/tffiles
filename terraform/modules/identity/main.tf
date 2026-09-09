# ---------------------------------------------------------------------------
# User-assigned Managed Identity
# Used by Container Apps for authentication to Azure services (Key Vault, ACR, Log Analytics).
# System-assigned identity on the Container Apps environment is the primary mechanism
# per architecture decision #4. User-assigned identity is also available for granular control.
# Using Azure Verified Module: Azure/avm-res-managedidentity-userassignedidentity/azurerm
# ---------------------------------------------------------------------------

module "container_apps_mi" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.5.2"

  name                = "aca-container-apps-mi"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

module "apim_mi" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "0.5.2"

  name                = "aca-apim-mi"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# ---------------------------------------------------------------------------
# RBAC assignments — least-privilege access via Managed Identity
# Using AVM pattern modules where available
# ---------------------------------------------------------------------------

# AcrPull — allows pulling images from ACR
resource "azurerm_role_assignment" "container_apps_acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.container_apps_mi.principal_id
  skip_principal_assignment_validation = true
}

# Key Vault Secrets User — allows the MI to read secrets from Key Vault
resource "azurerm_role_assignment" "container_apps_key_vault_secrets" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.container_apps_mi.principal_id
  skip_principal_assignment_validation = true
}

# Key Vault Keys User — allows the MI to use keys from Key Vault
resource "azurerm_role_assignment" "container_apps_key_vault_keys" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Keys User"
  principal_id         = module.container_apps_mi.principal_id
  skip_principal_assignment_validation = true
}

# Log Analytics Reader — allows the MI to read logs from Log Analytics
resource "azurerm_role_assignment" "container_apps_log_analytics_reader" {
  scope                = var.application_insights_id
  role_definition_name = "Log Analytics Reader"
  principal_id         = module.container_apps_mi.principal_id
  skip_principal_assignment_validation = true
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "container_apps_user_assigned_identity_id" {
  description = "ID of the user-assigned Managed Identity used by Container Apps"
  value       = module.container_apps_mi.id
}

output "container_apps_user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned Managed Identity used by Container Apps"
  value      = module.container_apps_mi.principal_id
}

output "apim_user_assigned_identity_id" {
  description = "ID of the user-assigned Managed Identity used by APIM"
  value       = module.apim_mi.id
}

output "apim_user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned Managed Identity used by APIM"
  value      = module.apim_mi.principal_id
}