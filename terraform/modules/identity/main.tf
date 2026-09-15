# ---------------------------------------------------------------------------
# User-assigned Managed Identity
# Used by Container Apps for authentication to Azure services (Key Vault, ACR, Log Analytics).
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
# ---------------------------------------------------------------------------

# AcrPull — allows pulling images from ACR
resource "azurerm_role_assignment" "container_apps_acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.container_apps_mi.principal_id
}

# Key Vault Secrets User — allows the MI to read secrets from Key Vault
resource "azurerm_role_assignment" "container_apps_key_vault_secrets" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.container_apps_mi.principal_id
}

# Key Vault Keys User — allows the MI to use keys from Key Vault
resource "azurerm_role_assignment" "container_apps_key_vault_keys" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Keys User"
  principal_id         = module.container_apps_mi.principal_id
}

# Log Analytics Reader — allows the MI to read logs from Log Analytics
resource "azurerm_role_assignment" "container_apps_log_analytics_reader" {
  scope                = var.application_insights_id
  role_definition_name = "Log Analytics Reader"
  principal_id         = module.container_apps_mi.principal_id
}