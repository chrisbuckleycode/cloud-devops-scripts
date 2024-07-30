terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
# skip registration reference: https://www.puppeteers.net/blog/terraform-azure-resource-provider-registration-fails/
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}
