# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "container_apps_user_assigned_identity_id" {
  description = "ID of the user-assigned Managed Identity used by Container Apps"
  value       = module.container_apps_mi.resource_id
}

output "container_apps_user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned Managed Identity"
  value       = module.container_apps_mi.principal_id
}

output "apim_user_assigned_identity_id" {
  description = "ID of the user-assigned Managed Identity used by APIM"
  value       = module.apim_mi.resource_id
}

output "apim_user_assigned_identity_principal_id" {
  description = "Principal ID of the user-assigned Managed Identity used by APIM"
  value       = module.apim_mi.principal_id
}