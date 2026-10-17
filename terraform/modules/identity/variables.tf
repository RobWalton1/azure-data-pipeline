variable "identity_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "acr_id" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "ci_principal_id" {
  description = "Principal ID of the identity GitHub Actions logs in as."
  type        = string
}
