# ---------------------------------------------------------------------------
# Variables
# ---------------------------------------------------------------------------

variable "location" {
  description = "Azure region for platform resources"
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for all resource names"
  type        = string
}

variable "environment" {
  description = "Deployment environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "hub_vnet_id" {
  description = "ID of the hub VNet"
  type        = string
}

variable "spoke_vnet_id" {
  description = "ID of the spoke VNet"
  type        = string
}

variable "hub_private_endpoint_subnet_id" {
  description = "ID of the hub Private Endpoint subnet (ACR, Key Vault, APIM)"
  type        = string
}

variable "container_apps_subnet_id" {
  description = "ID of the delegated Container Apps subnet in the spoke VNet"
  type        = string
}

variable "container_app_environment_name" {
  description = "Name of the Container Apps Environment"
  type        = string
}

variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}

variable "acr_sku" {
  description = "ACR SKU tier (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "workload_profile_name" {
  description = "Workload profile name (Consumption or dedicated)"
  type        = string
  default     = "Consumption"
}

variable "workload_profile_count" {
  description = "Node count for dedicated workload profile (null for Consumption)"
  type        = number
  default     = null
}

variable "tags" {
  description = "Tags applied to platform resources"
  type        = map(string)
  default     = {}
}

# API Management
variable "api_management_name" {
  description = "Name of the Azure API Management instance"
  type        = string
}

variable "apim_sku_name" {
  description = "SKU for APIM (Developer_1, Standard_v2, Premium_v3)"
  type        = string
  default     = "Developer_1"
}

variable "apim_subnet_id" {
  description = "Subnet ID for APIM VNet integration (hub Private Endpoint subnet)"
  type        = string
}

variable "publisher_name" {
  description = "APIM publisher name"
  type        = string
  default     = "Platform Engineering"
}

variable "publisher_email" {
  description = "APIM publisher email (admin notifications)"
  type        = string
  default     = "platform@example.com"
}

variable "dotnet_api_app_name" {
  description = "Name of the .NET API Container App (used to construct internal FQDN)"
  type        = string
}

variable "container_app_environment_fqdn" {
  description = "Default FQDN of the Container Apps Environment"
  type        = string
}