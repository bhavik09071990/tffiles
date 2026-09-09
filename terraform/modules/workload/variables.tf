variable "location" {
  description = "Azure region for workload resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "container_app_environment_id" {
  description = "ID of the Container Apps Environment"
  type        = string
}

variable "container_app_environment_fqdn" {
  description = "Default FQDN of the Container Apps Environment"
  type        = string
}

variable "container_registry_login_server" {
  description = "Login server of the Azure Container Registry"
  type        = string
}

variable "user_assigned_identity_id" {
  description = "ID of the user-assigned Managed Identity"
  type        = string
}

variable "nextjs_app_name" {
  description = "Name of the Next.js Container App"
  type        = string
}

variable "dotnet_api_app_name" {
  description = "Name of the .NET API Container App"
  type        = string
}

variable "nextjs_image" {
  description = "Docker image for the Next.js frontend"
  type        = string
}

variable "dotnet_api_image" {
  description = "Docker image for the .NET API backend"
  type        = string
}

variable "nextjs_min_replicas" {
  description = "Minimum replica count for Next.js Container App"
  type        = number
  default     = 0  # scale-to-zero for dev; set to 1 for prod
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
  description = "Target number of concurrent requests per replica (for concurrency-based scaling)"
  type        = number
  default     = 100
}

variable "dotnet_api_target_concurrency" {
  description = "Target number of concurrent requests per replica (for concurrency-based scaling)"
  type        = number
  default     = 50
}

variable "tags" {
  description = "Tags applied to workload resources"
  type        = map(string)
  default     = {}
}
