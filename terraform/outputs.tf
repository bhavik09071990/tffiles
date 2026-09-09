# ---------------------------------------------------------------------------
# Resource identifiers
# ---------------------------------------------------------------------------

output "resource_group_id" {
  description = "ID of the primary resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_name" {
  description = "Name of the primary resource group"
  value       = azurerm_resource_group.main.name
}

output "virtual_network_id" {
  description = "ID of the application VNet"
  value       = module.network.virtual_network_id
}

output "container_apps_environment_id" {
  description = "ID of the Container Apps Environment"
  value       = module.platform.container_apps_environment_id
}

output "container_apps_environment_fqdn" {
  description = "FQDN of the Container Apps Environment"
  value       = module.platform.container_apps_environment_fqdn
}

output "container_registry_login_server" {
  description = "Login server of the Azure Container Registry"
  value       = module.platform.container_registry_login_server
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = module.platform.key_vault_id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.platform.key_vault_name
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value      = module.monitoring.application_insights_instrumentation_key
  sensitive  = true
}

output "application_insights_app_id" {
  description = "Application Insights application ID"
  value       = module.monitoring.application_insights_app_id
}

# ---------------------------------------------------------------------------
# Container App URLs
# ---------------------------------------------------------------------------

output "nextjs_app_fqdn" {
  description = "FQDN of the Next.js Container App (external)"
  value       = module.workload.nextjs_app_fqdn
}

output "dotnet_api_fqdn" {
  description = "FQDN of the .NET API Container App (internal)"
  value       = module.workload.dotnet_api_fqdn
}

# ---------------------------------------------------------------------------
# Identity
# ---------------------------------------------------------------------------

output "container_apps_user_assigned_identity_id" {
  description = "ID of the user-assigned Managed Identity used by Container Apps"
  value       = module.identity.container_apps_user_assigned_identity_id
}

output "container_apps_user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned Managed Identity"
  value      = module.identity.container_apps_user_assigned_identity_principal_id
}
