variable "location" {
  description = "Azure region for the VNet"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the VNet"
  type        = string
}

variable "virtual_network_address_space" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "container_apps_subnet_name" {
  description = "Name of the Container Apps subnet"
  type        = string
  default     = "aca-subnet"
}

variable "container_apps_subnet_address_prefix" {
  description = "Address prefix for the Container Apps subnet (minimum /23 required by Azure Container Apps)"
  type        = string
  default     = "10.0.0.0/22"
}

variable "private_endpoint_subnet_name" {
  description = "Name of the Private Endpoint subnet"
  type        = string
  default     = "pep-subnet"
}

variable "private_endpoint_subnet_address_prefix" {
  description = "Address prefix for the Private Endpoint subnet"
  type        = string
  default     = "10.0.4.0/26"
}

variable "tags" {
  description = "Tags applied to all resources in this module"
  type        = map(string)
  default     = {}
}
