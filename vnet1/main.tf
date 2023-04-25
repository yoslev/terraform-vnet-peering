terraform {
  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise.
      source        = "hashicorp/azurerm"
      version       = ">= 2.90.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "99management"
    storage_account_name = "99management"
    container_name       = "tfstate"
    subscription_id      = "46306db1-ba78-4ed8-9ab9-5a7e52f587b0"
    #key                  = "Q8H9FNl9l4OR1wyBfc0itNT9p40sbmxoMdyotuUcWtnBSqL70GEkcy8G5qCkpsJ1xl3mtbuCuJJM+AStcBg8eg=="
	key = "dev/yl1"
  }
}

provider "azurerm" {
  features {}
}
