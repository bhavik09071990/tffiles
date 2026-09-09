variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "apim_name" {
  description = "Name of the API Management instance"
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

variable "apim_sku" {
  description = "APIM SKU"
  type        = string
  default     = "Consumption_0"
}

variable "container_apps_subnet_id" {
  description = "ID of the Container Apps subnet (APIM deployed here)"
  type        = string
}

variable "dotnet_api_app_name" {
  description = "Name of the .NET API Container App (used to construct internal FQDN)"
  type        = string
}

variable "container_app_environment_fqdn" {
  description = "Default FQDN of the Container Apps Environment"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  type        = string
}

variable "tags" {
  description = "Tags applied to APIM"
  type        = map(string)
  default     = {}
}
