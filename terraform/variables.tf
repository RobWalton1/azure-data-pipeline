variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_name" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "container_env_name" {
  type = string
}

variable "container_job_name" {
  type = string
}

variable "log_analytics_name" {
  type = string
}

variable "api_url" {
  type = string
}

variable "blob_container_name" {
  type = string
}

variable "storage_connection_string" {
  type      = string
  sensitive = true
}