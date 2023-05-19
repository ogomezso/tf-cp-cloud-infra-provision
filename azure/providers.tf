terraform {
  required_version = ">=1.0"
  backend "azurerm" {
      resource_group_name  = "migrations"
      storage_account_name = "migrationstfstateazure"
      container_name       = "tfstate"
      key                  = "terraform.tfstate"
  }
}