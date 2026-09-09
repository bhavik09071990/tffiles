variable "acr_id" {
  description = "Resource ID of the Azure Container Registry"
  type        = string
}

variable "acr_name" {
  description = "Name of the Azure Container Registry"
  type        = string
}

variable "kv_id" {
  description = "Resource ID of the Azure Key Vault"
  type        = string
}

variable "kv_name" {
  description = "Name of the Azure Key Vault"
  type        = string
}

variable "apim_id" {
  description = "Resource ID of the API Management instance"
  type        = string
}

variable "apim_name" {
  description = "Name of the API Management instance"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_id" {
  description = "ID of the application VNet"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "ID of the Private Endpoint subnet"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
