
resource "azurerm_resource_group" "dev-bs-rg2" {
  name     = "dev-bs-rg2"
  location = "Central India"
}

resource "azurerm_virtual_network" "dev-bs-vnet2" {
  name                = "dev-bs-vnet2"
  address_space       = ["10.20.0.0/16"]
  location            = azurerm_resource_group.dev-bs-rg2.location
  resource_group_name = azurerm_resource_group.dev-bs-rg2.name
}

resource "azurerm_subnet" "dev-bs-sub2" {
  name                 = "dev-bs-sub2"
  resource_group_name  = azurerm_resource_group.dev-bs-rg2.name
  virtual_network_name = azurerm_virtual_network.dev-bs-vnet2.name
  address_prefixes     = ["10.20.0.0/24"]
}

resource "azurerm_public_ip" "dev-bs-public_ip2" {
  name                = "dev-bs-public_ip2"
  resource_group_name = azurerm_resource_group.dev-bs-rg2.name
  location            = azurerm_resource_group.dev-bs-rg2.location
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_public_ip" "dev-bs-public_ip2_fw" {
  name                = "dev-bs-public_ip2_fw"
  resource_group_name = azurerm_resource_group.dev-bs-rg2.name
  location            = azurerm_resource_group.dev-bs-rg2.location
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_network_interface" "dev-bs-netifc2" {
  name                = "dev-bs-netifc2"
  location            = azurerm_resource_group.dev-bs-rg2.location
  resource_group_name = azurerm_resource_group.dev-bs-rg2.name

  ip_configuration {
    name                          = "conf2"
    subnet_id                     = azurerm_subnet.dev-bs-sub2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.dev-bs-public_ip2.id
  }
}
#------
resource "azurerm_network_security_group" "dev-bs-nsg2" {
  name                = "dev-bs-nsg2"
  location            = azurerm_resource_group.dev-bs-rg2.location
  resource_group_name = azurerm_resource_group.dev-bs-rg2.name

  security_rule {
    name                       = "allow_ssh_sg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
#------

resource "azurerm_network_interface_security_group_association" "dev-bs-association2" {
  network_interface_id      = azurerm_network_interface.dev-bs-netifc2.id
  network_security_group_id = azurerm_network_security_group.dev-bs-nsg2.id
}

resource "azurerm_virtual_machine" "dev-bs-vm2" {
  name                  = "dev-bs-vm2"
  location              = azurerm_resource_group.dev-bs-rg2.location
  resource_group_name   = azurerm_resource_group.dev-bs-rg2.name
  network_interface_ids = [azurerm_network_interface.dev-bs-netifc2.id]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "dev-bs-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "examplevm"
    admin_username = "exampleadmin"
    admin_password = "P@ssw0rd1234"
  }

  os_profile_windows_config {
    provision_vm_agent               = true
    timezone                        = "Eastern Standard Time"
  }

  tags = {
    environment = "dev"
  }
}

output "rsc_grp_name" {
  value = azurerm_resource_group.dev-bs-rg2.name
}

output "vnet_id" {
  value = azurerm_virtual_network.dev-bs-vnet2.id
}

output "vnet_name" {
  value = azurerm_virtual_network.dev-bs-vnet2.name
}

output "subnet_id" {
  value = azurerm_subnet.dev-bs-sub2.id
}

output "pub_ip_id" {
  value = azurerm_public_ip.dev-bs-public_ip2.id
}

output "pub_ip_id_fw" {
  value = azurerm_public_ip.dev-bs-public_ip2_fw.id
}
