resource "azurerm_storage_account" "pipeline_storage" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "pipeline_container" {
  name                  = "pipeline-output"
  storage_account_id    = azurerm_storage_account.pipeline_storage.id
  container_access_type = "private"
}