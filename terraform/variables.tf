# ---------------------------------------------------------------------------
# Resource naming
# ---------------------------------------------------------------------------

variable "resource_name_prefix" {
  description = "Prefix used for all resource names (e.g. 'aca' produces 'aca-rg', 'aca-vnet')"
  type        = string
  default     = "aca"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Deployment environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ---------------------------------------------------------------------------
# VNet / Networking
# ---------------------------------------------------------------------------

variable "virtual_network_address_space" {
  description = "Address space for the application VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_apps_subnet_address_prefix" {
  description = "Address prefix for the Container Apps subnet"
  type        = string
  default     = "10.0.0.0/22"
}

variable "private_endpoint_subnet_address_prefix" {
  description = "Address prefix for the Private Endpoint subnet"
  type        = string
  default     = "10.0.4.0/26"
}

# ---------------------------------------------------------------------------
# Container Apps
# ---------------------------------------------------------------------------

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
  default     = null
}

variable "container_app_environment_name" {
  description = "Name of the Container Apps Environment"
  type        = string
  default     = null
}

# Container App names (defaults are set via locals in root)
variable "nextjs_app_name" {
  description = "Name of the Next.js Container App"
  type        = string
  default     = null
}

variable "dotnet_api_app_name" {
  description = "Name of the .NET API Container App"
  type        = string
  default     = null
}

# ---------------------------------------------------------------------------
# Container Images
# ---------------------------------------------------------------------------

variable "nextjs_image" {
  description = "Docker image for the Next.js frontend (e.g. myacr.azurecr.io/nextjs-app:latest)"
  type        = string
  default     = "mcr.microsoft.com/samples/azure-container-apps-todo-app:latest"
}

variable "dotnet_api_image" {
  description = "Docker image for the .NET API backend (e.g. myacr.azurecr.io/dotnet-api:latest)"
  type        = string
  default     = "mcr.microsoft.com/samples/azure-container-apps-todo-app:latest"
}

# ---------------------------------------------------------------------------
# Container App scaling
# ---------------------------------------------------------------------------

variable "nextjs_min_replicas" {
  description = "Minimum replica count for Next.js Container App"
  type        = number
  default     = 1
}

variable "nextjs_max_replicas" {
  description = "Maximum replica count for Next.js Container App"
  type        = number
  default     = 5
}

variable "dotnet_api_min_replicas" {
  description = "Minimum replica count for .NET API Container App"
  type        = number
  default     = 0  # scale-to-zero for dev; set to 1 for prod
}

variable "dotnet_api_max_replicas" {
  description = "Maximum replica count for .NET API Container App"
  type        = number
  default     = 10
}

# Concurrency-based scaling targets
variable "nextjs_target_concurrency" {
  description = "Target concurrent requests per replica for Next.js autoscaling"
  type        = number
  default     = 100
}

variable "dotnet_api_target_concurrency" {
  description = "Target concurrent requests per replica for .NET API autoscaling"
  type        = number
  default     = 50
}

# ---------------------------------------------------------------------------
# SKU / Tier
# ---------------------------------------------------------------------------

variable "acr_sku" {
  description = "ACR SKU tier"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "acr_sku must be Basic, Standard, or Premium."
  }
}

# ---------------------------------------------------------------------------
# Container App Environment workload profile
# ---------------------------------------------------------------------------

variable "workload_profile_name" {
  description = "Workload profile name for Container Apps Environment (Consumption or dedicated)"
  type        = string
  default     = "Consumption"
}

variable "workload_profile_count" {
  description = "Node count for dedicated workload profile (null for Consumption)"
  type        = number
  default     = null
}

# ---------------------------------------------------------------------------
# Tags
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default = {
    environment = "dev"
    managed_by  = "terraform"
  }
}
