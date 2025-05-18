terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.9.0"
    }

  }

  backend "azurerm" {
    use_azuread_auth     = true                                   # Can also be set via `ARM_USE_AZUREAD` environment variable.
    tenant_id            = "980a9497-3393-4e89-9671-4f0f938006fe" # Can also be set via `ARM_TENANT_ID` environment variable.
    subscription_id      = "f5a72aa1-60c1-4225-90ba-4e5273d6af91"
    resource_group_name  = "tfstaterg"
    storage_account_name = "tfstateshubham"    # Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    container_name       = "tfstate"           # Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    key                  = "terraform.tfstate" # Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
  }

}

provider "azurerm" {

  features {}
  tenant_id       = "980a9497-3393-4e89-9671-4f0f938006fe"
  subscription_id = "f5a72aa1-60c1-4225-90ba-4e5273d6af91"

}

 