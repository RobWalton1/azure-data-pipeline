resource "azurerm_container_app_job" "pipeline_job" {
  name                         = var.container_job_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_environment_id

  replica_timeout_in_seconds = 300
  replica_retry_limit        = 1

  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.identity_id
  }

  template {
    container {
      name = "data-pipeline"
      # Placeholder so a fresh environment can be created before CI has pushed
      # an image; CI sets the real image and ignore_changes keeps it.
      image  = "mcr.microsoft.com/k8se/quickstart-jobs:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "API_URL"
        value = var.api_url
      }

      env {
        name  = "BLOB_CONTAINER_NAME"
        value = var.blob_container_name
      }

      env {
        name  = "AZURE_STORAGE_ACCOUNT_URL"
        value = var.storage_account_url
      }

      env {
        name  = "AZURE_CLIENT_ID"
        value = var.identity_client_id
      }
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].container[0].image
    ]
  }
}
