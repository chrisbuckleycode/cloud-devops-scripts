/*
resource "azurerm_resource_group" "main" {
  name     = local.resourceGroupName
  location = var.location
}
*/

resource "azurerm_api_management" "main" {
  name                = local.apimName
  location            = var.location
  resource_group_name = local.resourceGroupName
  publisher_name      = "CZ Inc."
  publisher_email     = "f8974h3h48@dsf8y43gsdg.com"
  identity {
    type = "SystemAssigned"
  }
  sku_name = "Consumption_0"
  # Pricing: https://azure.microsoft.com/en-us/pricing/details/api-management/#pricing
}
