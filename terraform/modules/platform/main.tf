# ---------------------------------------------------------------------------
# Platform Layer - ACA Environment, ACR, Key Vault, APIM
# Hub-and-spoke topology:
#   - ACA Environment in spoke (Container Apps subnet)
#   - APIM in hub (Private Endpoint subnet)
#   - ACR and Key Vault private endpoints in hub (Private Endpoint subnet)
# ---------------------------------------------------------------------------

locals {
  name_prefix = var.name_prefix
}

# ---------------------------------------------------------------------------
# Azure Container Apps Managed Environment
# Workload-profile environment with internal load balancer in spoke VNet
# Using Azure Verified Module: Azure/avm-res-app-managedenvironment/azurerm
# ---------------------------------------------------------------------------

module "container_apps_environment" {
  source  = "Azure/avm-res-app-managedenvironment/azurerm"
  version = "0.5.0"

  name                = var.container_app_environment_name
  resource_group_name = var.resource_group_name
  location            = var.location
  log_analytics_workspace = {
    resource_id = var.log_analytics_workspace_id
  }

  vnet_configuration = {
    internal                       = true
    infrastructure_subnet_id       = var.container_apps_subnet_id
    docker_bridge_cidr             = "172.16.0.0/16"
    internal_load_balancer_enabled = true
  }

  workload_profile = var.workload_profile_name == "Consumption" ? [] : [{
    name                  = var.workload_profile_name
    count                 = var.workload_profile_count
    workload_profile_type = "Dedicated"
  }]

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = []
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Azure Container Registry - Private by default (decision #6)
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
# Azure Key Vault - REQUIRED per requirements (decision #7)
# ---------------------------------------------------------------------------

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "0.11.0"

  name                = var.key_vault_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  soft_delete_retention_days = 7
  purge_protection_enabled   = false # Allow purge for dev; enable in prod

  public_network_access_enabled = false

  tags = var.tags
}

data "azurerm_client_config" "current" {}

# ---------------------------------------------------------------------------
# Azure API Management - Public gateway for internal backends
# Deployed in hub VNet (private endpoint subnet) with internal VNet type
# ---------------------------------------------------------------------------

resource "azurerm_api_management" "main" {
  name                = var.api_management_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.apim_sku_name

  virtual_network_type = "Internal"
  virtual_network_configuration {
    subnet_id = var.apim_subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# API: dotnet-api
# Backend = .NET API internal FQDN. mTLS handled by the Container Apps platform.
# ---------------------------------------------------------------------------

resource "azurerm_api_management_api" "dotnet_api" {
  name                = "dotnet-api"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.main.name
  revision            = "1"
  display_name        = ".NET API"
  path                = "api"
  protocols           = ["https"]
}

locals {
  dotnet_api_backend_url = "https://${var.dotnet_api_app_name}.internal.${var.container_app_environment_fqdn}"
}

resource "azurerm_api_management_backend" "dotnet_api" {
  name                = "dotnet-api-backend"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.main.name
  url                 = local.dotnet_api_backend_url
  protocol            = "http"
}

# ---------------------------------------------------------------------------
# Diagnostic settings
# ---------------------------------------------------------------------------

resource "azurerm_api_management_logger" "main" {
  name                = "apim-logger"
  api_management_name = azurerm_api_management.main.name
  resource_group_name = var.resource_group_name

  resource_id = var.log_analytics_workspace_id
}

resource "azurerm_api_management_diagnostic" "main" {
  identifier               = "applicationinsights"
  api_management_name      = azurerm_api_management.main.name
  resource_group_name      = var.resource_group_name
  api_management_logger_id = azurerm_api_management_logger.main.id

  frontend_request {
    body_bytes     = 32
    headers_to_log = ["content-type", "accept"]
  }
  frontend_response {
    body_bytes     = 32
    headers_to_log = ["content-type"]
  }
  backend_request {
    body_bytes     = 32
    headers_to_log = ["content-type"]
  }
  backend_response {
    body_bytes     = 32
    headers_to_log = ["content-type"]
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "container_apps_environment_id" {
  description = "ID of the Container Apps Environment"
  value       = module.container_apps_environment.resource_id
}

output "container_apps_environment_fqdn" {
  description = "Default FQDN of the Container Apps Environment"
  value       = module.container_apps_environment.default_domain
}

output "container_registry_id" {
  description = "ID of the Azure Container Registry"
  value       = module.container_registry.resource_id
}

output "container_registry_login_server" {
  description = "Login server of the Azure Container Registry"
  value       = module.container_registry.login_server
}

output "key_vault_id" {
  description = "ID of the Azure Key Vault"
  value       = module.key_vault.resource_id
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
  value       = azurerm_api_management.main.gateway_url
}
