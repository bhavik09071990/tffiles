# ---------------------------------------------------------------------------
# API Management
# Per requirements + decision #10: internal VNet, Private Endpoint, internal FQDN
# backends for Container Apps. APIM deployed in same VNet as the CAE (gotcha #1)
# so the internal FQDN resolves.
# Note: No AVM module available for APIM yet; using direct azurerm resource.
# ---------------------------------------------------------------------------

resource "azurerm_api_management" "main" {
  name                = var.apim_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.apim_sku

  virtual_network_type = "Internal"
  subnet_id            = var.container_apps_subnet_id

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
  identifier         = "apim-diagnostic"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.main.name
  enabled            = true

  logger_id = azurerm_api_management_logger.main.id

  frontend {
    request {
      body_bytes = 32
      headers_to_log = ["content-type", "accept"]
    }
    response {
      body_bytes = 32
      headers_to_log = ["content-type"]
    }
  }

  backend {
    request {
      body_bytes = 32
      headers_to_log = ["content-type"]
    }
    response {
      body_bytes = 32
      headers_to_log = ["content-type"]
    }
  }
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "apim_id" {
  description = "Resource ID of the API Management instance"
  value       = azurerm_api_management.main.id
}

output "apim_name" {
  description = "Name of the API Management instance"
  value       = azurerm_api_management.main.name
}

output "apim_gateway_url" {
  description = "Default gateway URL of the API Management instance"
  value       = azurerm_api_management.main.gateway_url
}

output "apim_identity_principal_id" {
  description = "Principal ID of the APIM system-assigned managed identity"
  value       = azurerm_api_management.main.identity[0].principal_id
}