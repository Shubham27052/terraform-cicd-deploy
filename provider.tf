terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.9.0"
    }

  }

  backend "azurerm" {
    use_azuread_auth     = true                                   # Can also be set via `ARM_USE_AZUREAD` environment variable.
    tenant_id            = "62add8d4-1f2a-4fed-8f52-1071990464a1" # Can also be set via `ARM_TENANT_ID` environment variable.
    # client_id            = var.client_id                          # Can also be set via `ARM_CLIENT_ID` environment variable.
    # client_secret        = var.client_secret
    storage_account_name = "tfbackendshubham"  # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tfstate"           # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "terraform.tfstate" # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }

}

provider "azurerm" {

  features {}
  tenant_id       = "62add8d4-1f2a-4fed-8f52-1071990464a1"
  subscription_id = "d76c02a2-6f94-4c24-be34-8147ea509940"


}

 