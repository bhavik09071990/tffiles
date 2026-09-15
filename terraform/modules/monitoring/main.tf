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

  workspace_id = module.log_analytics_workspace.resource_id

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

  log_analytics_workspace_sku                     = "PerNode"
  log_analytics_workspace_retention_in_days         = 30
  log_analytics_workspace_daily_quota_gb            = 0.1

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Diagnostic settings for Application Insights
# ---------------------------------------------------------------------------

resource "azurerm_monitor_diagnostic_setting" "ai_to_law" {
  name                       = "ai-diagnostic-settings"
  target_resource_id         = module.application_insights.resource_id
  log_analytics_workspace_id = module.log_analytics_workspace.resource_id

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
  log_analytics_workspace_id = module.log_analytics_workspace.resource_id

  enabled_log {
    category = "ContainerAppConsoleLogs"

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