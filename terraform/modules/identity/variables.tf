variable "location" {
  description = "Azure region for identity resources"
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

variable "container_registry_id" {
  description = "ID of the Azure Container Registry"
  type        = string
}

variable "key_vault_id" {
  description = "ID of the Azure Key Vault"
  type        = string
}

variable "application_insights_id" {
  description = "ID of the Application Insights instance"
  type        = string
}

variable "api_management_id" {
  description = "ID of the API Management instance"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to identity resources"
  type        = map(string)
  default     = {}
}
