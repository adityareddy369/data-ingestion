terraform {
  backend "azurerm" {}
  required_version = ">= 0.14.11"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.57.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 2.2.0"
    }
  }
}

provider "azurerm" {
  features {
    template_deployment {
      delete_nested_items_during_deletion = true
    }
  }
  subscription_id = var.subscription_id
}
