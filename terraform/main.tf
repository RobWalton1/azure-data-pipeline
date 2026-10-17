terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id

  resource_provider_registrations = "none"
}

module "storage" {
  source = "./modules/storage"

  storage_account_name = var.storage_account_name
  resource_group_name  = azurerm_resource_group.pipeline_rg.name
  location             = azurerm_resource_group.pipeline_rg.location
}

resource "azurerm_resource_group" "pipeline_rg" {
  name     = var.resource_group_name
  location = var.location
}

module "acr" {
  source = "./modules/acr"

  acr_name            = var.acr_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location
}

module "container_env" {
  source = "./modules/container_env"

  container_env_name  = var.container_env_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location

  log_analytics_workspace_id = module.log_analytics.id
}

module "identity" {
  source = "./modules/identity"

  identity_name       = var.identity_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location

  acr_id             = module.acr.id
  storage_account_id = module.storage.id
  ci_principal_id    = module.github_oidc.principal_id
}

module "github_oidc" {
  source = "./modules/github_oidc"

  identity_name       = var.ci_identity_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location

  github_repository = var.github_repository
  github_branch     = var.github_branch
}

module "container_job" {
  source = "./modules/container_job"

  container_job_name  = var.container_job_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location

  container_environment_id = module.container_env.id

  acr_login_server    = module.acr.login_server
  identity_id         = module.identity.id
  identity_client_id  = module.identity.client_id
  api_url             = var.api_url
  blob_container_name = var.blob_container_name
  storage_account_url = module.storage.primary_blob_endpoint
  cron_expression     = var.job_cron_expression

  # The job pulls its image on creation, so AcrPull must already be granted.
  depends_on = [module.identity]
}

resource "azurerm_role_assignment" "ci_job_contributor" {
  scope                = module.container_job.id
  role_definition_name = "Contributor"
  principal_id         = module.github_oidc.principal_id
  principal_type       = "ServicePrincipal"
}

module "log_analytics" {
  source = "./modules/log_analytics"

  workspace_name      = var.log_analytics_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location
}