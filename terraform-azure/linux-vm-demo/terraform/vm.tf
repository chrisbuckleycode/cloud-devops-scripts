resource "azurerm_linux_virtual_machine" "kryten_vm" {
  name                            = "kryten-vm"
  resource_group_name             = var.rg_name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = "cloud_user"
  admin_password                  = "Spaceman123!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic_primary.id,
    azurerm_network_interface.nic_internal.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
