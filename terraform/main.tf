# ---------------------------------------------------------------------------
# Root module — orchestrates all platform components
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.resource_name_prefix
  tags        = merge(var.tags, { environment = var.environment })

  # Derived names
  resource_group_name            = "${local.name_prefix}-rg"
  virtual_network_name           = "${local.name_prefix}-vnet"
  container_app_environment_name = var.container_app_environment_name != null ? var.container_app_environment_name : "${local.name_prefix}-env"
  container_registry_name        = "${replace(local.name_prefix, "-", "")}acr${var.environment}"
  key_vault_name                 = "${replace(local.name_prefix, "-", "")}kv${var.environment}"
  log_analytics_workspace_name   = var.log_analytics_workspace_name != null ? var.log_analytics_workspace_name : "${local.name_prefix}-law"
  application_insights_name      = "${local.name_prefix}-ai"

  # Container App names
  nextjs_app_name     = var.nextjs_app_name != null ? var.nextjs_app_name : "${local.name_prefix}-nextjs"
  dotnet_api_app_name = var.dotnet_api_app_name != null ? var.dotnet_api_app_name : "${local.name_prefix}-dotnetapi"

  # Container Apps subnet name
  container_apps_subnet_name   = "${local.name_prefix}-aca-subnet"
  private_endpoint_subnet_name = "${local.name_prefix}-pep-subnet"
}

# ---------------------------------------------------------------------------
# Resource Group
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = local.tags
}

# ---------------------------------------------------------------------------
# Network layer (Hub and Spoke)
# ---------------------------------------------------------------------------

module "network" {
  source = "./modules/network"

  location    = var.location
  name_prefix = local.name_prefix
  tags        = local.tags

  hub_address_space   = var.virtual_network_address_space
  spoke_address_space = "10.1.0.0/16"

  container_apps_subnet_address_prefix         = var.container_apps_subnet_address_prefix
  private_endpoint_subnet_address_prefix       = var.private_endpoint_subnet_address_prefix
  spoke_private_endpoint_subnet_address_prefix = var.private_endpoint_subnet_address_prefix
}

# ---------------------------------------------------------------------------
# Monitoring layer (Log Analytics, Application Insights)
# Must come before platform so log_analytics_workspace_id is available.
# ---------------------------------------------------------------------------

module "monitoring" {
  source = "./modules/monitoring"

  location                     = var.location
  resource_group_name          = azurerm_resource_group.main.name
  tags                         = local.tags
  application_insights_name    = local.application_insights_name
  log_analytics_workspace_name = local.log_analytics_workspace_name
  container_app_environment_id = module.platform.container_apps_environment_id
}

# ---------------------------------------------------------------------------
# Platform layer (ACA Environment, ACR, Key Vault, APIM)
# ---------------------------------------------------------------------------

module "platform" {
  source = "./modules/platform"

  location            = var.location
  environment         = var.environment
  name_prefix         = local.name_prefix
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  # VNet / Subnet (hub-and-spoke)
  hub_vnet_id                    = module.network.hub_vnet_id
  spoke_vnet_id                  = module.network.spoke_vnet_id
  hub_private_endpoint_subnet_id = module.network.hub_private_endpoint_subnet_id
  container_apps_subnet_id       = module.network.container_apps_subnet_id
  apim_subnet_id                 = module.network.hub_private_endpoint_subnet_id

  # Naming
  container_app_environment_name = local.container_app_environment_name
  container_registry_name        = local.container_registry_name
  key_vault_name                 = local.key_vault_name
  api_management_name            = "${local.name_prefix}-apim"
  acr_sku                        = var.acr_sku

  # Monitoring
  log_analytics_workspace_name = local.log_analytics_workspace_name
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id

  # Workload profile
  workload_profile_name  = var.workload_profile_name
  workload_profile_count = var.workload_profile_count

  # APIM
  apim_sku_name                  = var.apim_sku_name
  dotnet_api_app_name            = local.dotnet_api_app_name
  container_app_environment_fqdn = module.platform.container_apps_environment_fqdn
}

# ---------------------------------------------------------------------------
# Identity layer (Managed Identity, RBAC)
# ---------------------------------------------------------------------------

module "identity" {
  source = "./modules/identity"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  container_app_environment_id = module.platform.container_apps_environment_id
  container_registry_id        = module.platform.container_registry_id
  key_vault_id                 = module.platform.key_vault_id
  application_insights_id      = module.monitoring.application_insights_id
}

# ---------------------------------------------------------------------------
# Workload layer (Next.js, .NET API Container Apps)
# ---------------------------------------------------------------------------

module "workload" {
  source = "./modules/workload"

  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  # Core dependencies
  container_app_environment_id    = module.platform.container_apps_environment_id
  container_app_environment_fqdn  = module.platform.container_apps_environment_fqdn
  container_registry_login_server = module.platform.container_registry_login_server

  # Identity
  user_assigned_identity_id = module.identity.container_apps_user_assigned_identity_id

  # App names
  nextjs_app_name     = local.nextjs_app_name
  dotnet_api_app_name = local.dotnet_api_app_name

  # Images
  nextjs_image     = var.nextjs_image
  dotnet_api_image = var.dotnet_api_image

  # Scaling
  nextjs_min_replicas           = var.nextjs_min_replicas
  nextjs_max_replicas           = var.nextjs_max_replicas
  nextjs_target_concurrency     = var.nextjs_target_concurrency
  dotnet_api_min_replicas       = var.dotnet_api_min_replicas
  dotnet_api_max_replicas       = var.dotnet_api_max_replicas
  dotnet_api_target_concurrency = var.dotnet_api_target_concurrency
}