output "id" {
  value = azurerm_user_assigned_identity.pipeline_job.id
}

output "client_id" {
  value = azurerm_user_assigned_identity.pipeline_job.client_id
}
