# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = module.application_insights.resource_id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.log_analytics_workspace.resource_id
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.application_insights.instrumentation_key
  sensitive   = true
}

output "application_insights_app_id" {
  description = "Application Insights application ID"
  value       = module.application_insights.app_id
}