# -----------------------------------------------------------------------------
# Application server: Java backend + React (served by nginx)
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "app" {
  name                = "pip-${local.name_prefix}-app"
  location            = local.rg_location
  resource_group_name = local.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "app" {
  name                = "nic-${local.name_prefix}-app"
  location            = local.rg_location
  resource_group_name = local.rg_name
  tags                = local.common_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app.id
  }
}

resource "azurerm_network_interface_security_group_association" "app" {
  network_interface_id      = azurerm_network_interface.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_linux_virtual_machine" "app" {
  name                            = "vm-${local.name_prefix}-app"
  resource_group_name             = local.rg_name
  location                        = local.rg_location
  size                            = var.app_vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.app.id]
  disable_password_authentication = false
  tags                            = merge(local.common_tags, { Role = "app" })

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Enable SSH password auth so Ansible can connect with the admin password.
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    set -e
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
    systemctl restart ssh || systemctl restart sshd
    echo "app server ready" > /tmp/ready.txt
  EOF
  )
}
