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
  description = "Object ID of the service principal GitHub Actions uses to push images."
  type        = string
}
