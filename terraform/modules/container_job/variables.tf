variable "container_job_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "container_environment_id" {
  type = string
}

variable "acr_login_server" {
  type = string
}

variable "acr_admin_username" {
  type = string
}

variable "acr_admin_password" {
  type      = string
  sensitive = true
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