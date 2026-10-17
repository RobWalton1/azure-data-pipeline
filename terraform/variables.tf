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

variable "job_cron_expression" {
  description = "When the pipeline job runs, as a cron expression in UTC."
  type        = string
  default     = "0 * * * *"
}

variable "ci_identity_name" {
  description = "Name of the managed identity GitHub Actions logs in as."
  type        = string
  default     = "github-actions-ci"
}

variable "github_repository" {
  description = "Repository whose workflows may log in as the CI identity, as owner/name."
  type        = string
  default     = "RobWalton1/azure-data-pipeline"
}

variable "github_branch" {
  description = "Branch whose workflow runs may log in as the CI identity."
  type        = string
  default     = "main"
}
