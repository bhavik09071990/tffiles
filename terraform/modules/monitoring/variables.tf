variable "location" {
  description = "Azure region for monitoring resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "application_insights_name" {
  description = "Name of the Application Insights instance"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "container_app_environment_id" {
  description = "ID of the Container Apps Environment for diagnostic settings"
  type        = string
}

variable "tags" {
  description = "Tags applied to monitoring resources"
  type        = map(string)
  default     = {}
}
