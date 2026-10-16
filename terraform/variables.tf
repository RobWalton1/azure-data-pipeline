variable "subscription_id" {
  description = "Azure subscription to deploy into."
  type        = string
}

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

variable "identity_name" {
  type = string
}

variable "ci_principal_id" {
  description = "Object ID of the service principal GitHub Actions uses to push images."
  type        = string
}

variable "job_cron_expression" {
  description = "When the pipeline job runs, as a cron expression in UTC."
  type        = string
  default     = "0 * * * *"
}
