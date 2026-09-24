resource "azurerm_user_assigned_identity" "pipeline_job" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_role_assignment" "job_acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.pipeline_job.principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "job_blob_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.pipeline_job.principal_id
  principal_type       = "ServicePrincipal"
}

# Updating the job re-submits its identity, which requires assign permission on it.
resource "azurerm_role_assignment" "ci_identity_operator" {
  scope                = azurerm_user_assigned_identity.pipeline_job.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = var.ci_principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "ci_acr_push" {
  scope                = var.acr_id
  role_definition_name = "AcrPush"
  principal_id         = var.ci_principal_id
  principal_type       = "ServicePrincipal"
}
