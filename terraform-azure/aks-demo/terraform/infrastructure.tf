/*
resource "azurerm_resource_group" "main" {
  name     = local.resourceGroupName
  location = var.location
}
*/

resource "azurerm_kubernetes_cluster" "main" {
  name                = local.aksName
  location            = var.location
  resource_group_name = local.resourceGroupName
  dns_prefix          = "dnsprefix01"
  sku_tier            = "Free"

  default_node_pool {
    name                = "nodepool01"
    node_count          = 1
    enable_auto_scaling = false
    # uncomment if setting above to 'true'
    # min_count         = 1
    # max_count         = 1
    vm_size             = "Standard_B2ms"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.main.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "client_key" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate
  sensitive = true
}

output "host" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.host
  sensitive = true
}

output "username" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.username
  sensitive = true
}

output "password" {
  value = azurerm_kubernetes_cluster.main.kube_config.0.password
  sensitive = true
}
