output "login_server" {
  value = azurerm_container_registry.pipeline_acr.login_server
}

output "admin_username" {
  value = azurerm_container_registry.pipeline_acr.admin_username
}

output "admin_password" {
  value     = azurerm_container_registry.pipeline_acr.admin_password
  sensitive = true
}