# Highest level construct in Azure after Subscription

resource "azurerm_resource_group" "rg_starbug" {
  name     = var.rg_name
  location = var.location
}


# VNet is equivalent to AWS'/GCP's VPC 
resource "azurerm_virtual_network" "vnet_01" {
  name                = "vnet_01"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_subnet" "subnet_01" {
  name                 = "subnet_01"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet_01.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Assign a Public IP to a RG & location
resource "azurerm_public_ip" "pip_kryten" {
  name                = "pip_kryten"
  resource_group_name = var.rg_name
  location            = var.location
  allocation_method   = "Dynamic"
}

# NIC public IP
resource "azurerm_network_interface" "nic_primary" {
  name                = "nic_primary"
  resource_group_name = var.rg_name
  location            = var.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.subnet_01.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip_kryten.id
  }
}

# NIC internal
resource "azurerm_network_interface" "nic_internal" {
  name                      = "nic_internal"
  resource_group_name       = var.rg_name
  location                  = var.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_01.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "nsg_webserver" {
  name                = "nsg_webserver"
  location            = var.location
  resource_group_name = var.rg_name
}

resource "azurerm_network_security_rule" "nsr_443" {
  name                        = "nsr_443"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg_webserver.name
}

resource "azurerm_network_security_rule" "nsr_22" {
  name                        = "nsr_22"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg_webserver.name
}

# Bind NIC to NSG
resource "azurerm_network_interface_security_group_association" "nic_internal_bind_nsg_webawecwe" {
  network_interface_id      = azurerm_network_interface.nic_internal.id
  network_security_group_id = azurerm_network_security_group.nsg_webserver.id
}
