terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.43.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.18.0"
    }
  }

  required_version = ">= 1.2"
}

# Configure the Microsoft Azure Provider
# skip registration reference: https://www.puppeteers.net/blog/terraform-azure-resource-provider-registration-fails/
provider "azurerm" {
  skip_provider_registration = "true"
  features {}
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.main.kube_config.0.host
  username               = azurerm_kubernetes_cluster.main.kube_config.0.username
  password               = azurerm_kubernetes_cluster.main.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)
}
