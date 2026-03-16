terraform {
  backend "azurerm" {
    use_oidc             = true
    use_azuread_auth     = true
    storage_account_name = "sa-prod-tfstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    resource_group_name  = "rg-prod-tfstate"
  }
}
