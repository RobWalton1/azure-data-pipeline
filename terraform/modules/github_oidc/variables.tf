variable "identity_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "github_repository" {
  description = "Repository allowed to use this identity, as owner/name."
  type        = string
}

variable "github_branch" {
  description = "Branch whose workflow runs may use this identity."
  type        = string
}
