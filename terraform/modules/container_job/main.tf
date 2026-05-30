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

  registry {
    server               = var.acr_login_server
    username             = var.acr_admin_username
    password_secret_name = "acr-password"
  }

  secret {
    name  = "acr-password"
    value = var.acr_admin_password
  }

  template {
    container {
      name   = "data-pipeline"
      image  = "${var.acr_login_server}/data-pipeline:latest"
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