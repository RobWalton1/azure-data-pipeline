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

  subscription_id = "cf6310ce-9655-45c5-86fe-79db67dacccc"

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

  acr_name           = var.acr_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location
}

module "container_env" {
  source = "./modules/container_env"

  container_env_name  = var.container_env_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location

  log_analytics_workspace_id = module.log_analytics.id
  log_analytics_shared_key   = module.log_analytics.primary_shared_key
}

module "container_job" {
  source = "./modules/container_job"

  container_job_name      = var.container_job_name
  resource_group_name     = azurerm_resource_group.pipeline_rg.name
  location                = azurerm_resource_group.pipeline_rg.location

  container_environment_id = module.container_env.id

  acr_login_server   = module.acr.login_server
  acr_admin_username = module.acr.admin_username
  acr_admin_password = module.acr.admin_password
  api_url                   = var.api_url
  blob_container_name       = var.blob_container_name
  storage_connection_string = var.storage_connection_string
}

module "log_analytics" {
  source = "./modules/log_analytics"

  workspace_name     = var.log_analytics_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location
}