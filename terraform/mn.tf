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

resource "azurerm_container_app_environment" "pipeline_env" {
  name                = var.container_env_name
  location            = azurerm_resource_group.pipeline_rg.location
  resource_group_name = azurerm_resource_group.pipeline_rg.name
}

resource "azurerm_container_app_job" "pipeline_job" {
  name                         = var.container_job_name
  location                     = azurerm_resource_group.pipeline_rg.location
  resource_group_name          = azurerm_resource_group.pipeline_rg.name
  container_app_environment_id = azurerm_container_app_environment.pipeline_env.id

  replica_timeout_in_seconds = 300
  replica_retry_limit        = 1

  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }

  registry {
    server               = module.acr.login_server
    username             = module.acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = module.acr.admin_password
  }

  template {
    container {
      name   = "data-pipeline"
      image  = "${module.acr.login_server}/data-pipeline:latest"
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  lifecycle {
  ignore_changes = [
    template[0].container[0].image
  ]
}
}