output "resource_group_name" {
  value = azurerm_resource_group.pipeline_rg.name
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "container_job_name" {
  value = module.container_job.name
}
output "ci_client_id" {
  description = "Set as the AZURE_CLIENT_ID repository variable."
  value       = module.github_oidc.client_id
}

output "ci_tenant_id" {
  description = "Set as the AZURE_TENANT_ID repository variable."
  value       = module.github_oidc.tenant_id
}
