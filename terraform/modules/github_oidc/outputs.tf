output "principal_id" {
  value = azurerm_user_assigned_identity.github_actions.principal_id
}

output "client_id" {
  value = azurerm_user_assigned_identity.github_actions.client_id
}

output "tenant_id" {
  value = azurerm_user_assigned_identity.github_actions.tenant_id
}
