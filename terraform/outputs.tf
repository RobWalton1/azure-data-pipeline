output "resource_group_name" {
  value = azurerm_resource_group.pipeline_rg.name
}

output "storage_account_name" {
  value = azurerm_storage_account.pipeline_storage.name
}

output "acr_login_server" {
  value = azurerm_container_registry.pipeline_acr.login_server
}

output "container_job_name" {
  value = azurerm_container_app_job.pipeline_job.name
}