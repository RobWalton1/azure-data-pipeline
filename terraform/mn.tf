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

resource "azurerm_resource_group" "pipeline_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "pipeline_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.pipeline_rg.name
  location                 = azurerm_resource_group.pipeline_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "pipeline_container" {
  name                  = "pipeline-output"
  storage_account_id    = azurerm_storage_account.pipeline_storage.id
  container_access_type = "private"
}

resource "azurerm_container_registry" "pipeline_acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.pipeline_rg.name
  location            = azurerm_resource_group.pipeline_rg.location
  sku                 = "Basic"
  admin_enabled       = true
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
    server               = azurerm_container_registry.pipeline_acr.login_server
    username             = azurerm_container_registry.pipeline_acr.admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = azurerm_container_registry.pipeline_acr.admin_password
  }

  template {
    container {
      name   = "data-pipeline"
      image  = "${azurerm_container_registry.pipeline_acr.login_server}/data-pipeline:latest"
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