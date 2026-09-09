# ---------------------------------------------------------------------------
# Next.js Frontend Container App
# Internal ingress only (architecture decision #4). No public exposure.
# Uses concurrency-based scaling for production-ready autoscaling.
# Using Azure Verified Module: Azure/avm-res-app-containerapp/azurerm
# ---------------------------------------------------------------------------

module "nextjs" {
  source  = "Azure/avm-res-app-containerapp/azurerm"
  version = "0.9.0"

  name                = var.nextjs_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  container_app_environment_id = var.container_app_environment_id

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  registry {
    server     = var.container_registry_login_server
    identity   = var.user_assigned_identity_id
  }

  configuration {
    revision_mode = "Single"

    ingress {
      external_enabled          = false
      target_port               = 3000
      transport                 = "http"
      allow_insecure_connections = false
    }

    # Concurrency-based scaling: scale based on target concurrency per replica
    scale {
      min_replicas    = var.nextjs_min_replicas
      max_replicas    = var.nextjs_max_replicas
      target_concurrency = var.nextjs_target_concurrency
    }
  }

  template {
    container {
      name   = "nextjs"
      image  = var.nextjs_image
      cpu    = 1.0
      memory = "2.0"

      env {
        name  = "PORT"
        value = "3000"
      }
      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# .NET API Backend Container App
# Internal ingress only — not accessible from the public internet.
# Uses concurrency-based scaling for production-ready autoscaling.
# Using Azure Verified Module: Azure/avm-res-app-containerapp/azurerm
# ---------------------------------------------------------------------------

module "dotnet_api" {
  source  = "Azure/avm-res-app-containerapp/azurerm"
  version = "0.9.0"

  name                = var.dotnet_api_app_name
  resource_group_name = var.resource_group_name
  location            = var.location
  container_app_environment_id = var.container_app_environment_id

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  registry {
    server     = var.container_registry_login_server
    identity   = var.user_assigned_identity_id
  }

  configuration {
    revision_mode = "Single"

    ingress {
      external_enabled          = false
      target_port               = 8080
      transport                 = "http"
      allow_insecure_connections = false
    }

    # Concurrency-based scaling: scale based on target concurrency per replica
    scale {
      min_replicas    = var.dotnet_api_min_replicas
      max_replicas    = var.dotnet_api_max_replicas
      target_concurrency = var.dotnet_api_target_concurrency
    }
  }

  template {
    container {
      name   = "dotnet-api"
      image  = var.dotnet_api_image
      cpu    = 1.0
      memory = "2.0"

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }
    }
  }

  tags = var.tags
}

# ---------------------------------------------------------------------------
# Outputs
# ---------------------------------------------------------------------------

output "nextjs_app_fqdn" {
  description = "FQDN of the Next.js Container App"
  value       = module.nextjs.fqdn
}

output "dotnet_api_fqdn" {
  description = "FQDN of the .NET API Container App"
  value       = module.dotnet_api.fqdn
}