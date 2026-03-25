terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      graceful_shutdown = true
    }
  }
  subscription_id = var.primary_subscription_id
}

provider "azurerm" {
  alias = "secondary"
  features {
    virtual_machine {
      graceful_shutdown = true
    }
  }
  subscription_id = var.secondary_subscription_id
}
