# ---------------------------------------------------------------------------
# Application Insights
# Using Azure Verified Module: Azure/avm-res-insights-component/azurerm
# ---------------------------------------------------------------------------

module "application_insights" {
  source  = "Azure/avm-res-insights-component/azurerm"
  version = "0.4.0"

  name                = var.application_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location

  workspace_id = var.log_analytics_workspace_id

  application_type = "web"

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Log Analytics Workspace
# Using Azure Verified Module: Azure/avm-res-operationalinsights-workspace/azurerm
# ---------------------------------------------------------------------------

module "log_analytics_workspace" {
  source  = "Azure/avm-res-operationalinsights-workspace/azurerm"
  version = "0.5.1"

  name                = var.log_analytics_workspace_name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku                 = "PerNode"
  retention_in_days   = 30
  daily_quota_mb      = 100

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Diagnostic settings for Application Insights
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "ai_to_law" {
  name                       = "ai-diagnostic-settings"
  target_resource_id         = module.application_insights.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "Audit"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# ---------------------------------------------------------------------------
# Diagnostic settings for Log Analytics (container apps logs)
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "aca_to_law" {
  name                       = "aca-diagnostic-settings"
  target_resource_id         = var.container_app_environment_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "ContainerAppConsoleLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = module.application_insights.id
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.log_analytics_workspace.id
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