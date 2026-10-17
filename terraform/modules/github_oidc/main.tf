resource "azurerm_user_assigned_identity" "github_actions" {
  name                = var.identity_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Lets GitHub Actions runs from one branch of one repo exchange their OIDC token for this identity.
resource "azurerm_federated_identity_credential" "github_main" {
  name                = "github-${var.github_branch}"
  parent_id           = azurerm_user_assigned_identity.github_actions.id
  issuer              = "https://token.actions.githubusercontent.com"
  audience            = ["api://AzureADTokenExchange"]
  subject             = "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"
}