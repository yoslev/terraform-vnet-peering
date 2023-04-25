terraform {
  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise.
      source        = "hashicorp/azurerm"
      version       = ">= 2.90.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "management1"
    storage_account_name = "management1"
    container_name       = "tfstate"
    subscription_id      = "46306db1...f587b0"
	key = "dev/yl1"
  }
}

provider "azurerm" {
  features {}
}
