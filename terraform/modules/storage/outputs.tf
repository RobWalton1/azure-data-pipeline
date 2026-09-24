output "storage_account_name" {
  value = azurerm_storage_account.pipeline_storage.name
}

output "id" {
  value = azurerm_storage_account.pipeline_storage.id
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.pipeline_storage.primary_blob_endpoint
}
