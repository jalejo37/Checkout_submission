terraform {
  backend "azurerm" {
    use_oidc             = true
    use_azuread_auth     = true
    storage_account_name = "sa-dev-tfstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
    resource_group_name  = "rg-dev-tfstate"
  }
}
