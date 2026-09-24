resource "azurerm_container_app_environment" "pipeline_env" {
  name                = var.container_env_name
  location            = var.location
  resource_group_name = var.resource_group_name

  log_analytics_workspace_id = var.log_analytics_workspace_id

  # Azure adds this profile to new environments; declaring it avoids perpetual drift.
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}