variable "container_env_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "log_analytics_shared_key" {
  type      = string
  sensitive = true
}