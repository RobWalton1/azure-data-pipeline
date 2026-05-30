resource "azurerm_container_app_environment" "pipeline_env" {
  name                = var.container_env_name
  location            = var.location
  resource_group_name = var.resource_group_name
}