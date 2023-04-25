
resource "azurerm_resource_group" "dev-bs-rg1" {
  name     = "dev-bs-rg1"
  location = "Central India"
}

resource "azurerm_virtual_network" "dev-bs-vnet1" {
  name                = "dev-bs-vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.dev-bs-rg1.location
  resource_group_name = azurerm_resource_group.dev-bs-rg1.name
}

resource "azurerm_subnet" "dev-bs-sub1" {
  name                 = "dev-bs-sub1"
  resource_group_name  = azurerm_resource_group.dev-bs-rg1.name
  virtual_network_name = azurerm_virtual_network.dev-bs-vnet1.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "dev-bs-public_ip1" {
  name                = "dev-bs-public_ip1"
  resource_group_name = azurerm_resource_group.dev-bs-rg1.name
  location            = azurerm_resource_group.dev-bs-rg1.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "dev-bs-public_ip1_fw" {
  name                = "dev-bs-public_ip1_fw"
  resource_group_name = azurerm_resource_group.dev-bs-rg1.name
  location            = azurerm_resource_group.dev-bs-rg1.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "dev-bs-netifc1" {
  name                = "dev-bs-netifc1"
  location            = azurerm_resource_group.dev-bs-rg1.location
  resource_group_name = azurerm_resource_group.dev-bs-rg1.name

  ip_configuration {
    name                          = "conf1"
    subnet_id                     = azurerm_subnet.dev-bs-sub1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.dev-bs-public_ip1.id
  }
}
#------
resource "azurerm_network_security_group" "dev-bs-nsg1" {
  name                = "dev-bs-nsg1"
  location            = azurerm_resource_group.dev-bs-rg1.location
  resource_group_name = azurerm_resource_group.dev-bs-rg1.name

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

resource "azurerm_network_interface_security_group_association" "dev-bs-association1" {
  network_interface_id      = azurerm_network_interface.dev-bs-netifc1.id
  network_security_group_id = azurerm_network_security_group.dev-bs-nsg1.id
}

resource "azurerm_virtual_machine" "dev-bs-vm1" {
  name                  = "dev-bs-vm1"
  location              = azurerm_resource_group.dev-bs-rg1.location
  resource_group_name   = azurerm_resource_group.dev-bs-rg1.name
  network_interface_ids = [azurerm_network_interface.dev-bs-netifc1.id]
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
  value = azurerm_resource_group.dev-bs-rg1.name
}

output "vnet_id" {
  value = azurerm_virtual_network.dev-bs-vnet1.id
}

output "vnet_name" {
  value = azurerm_virtual_network.dev-bs-vnet1.name
}

output "subnet_id" {
  value = azurerm_subnet.dev-bs-sub1.id
}

output "pub_ip_id" {
  value = azurerm_public_ip.dev-bs-public_ip1.id
}

output "pub_ip_id_fw" {
  value = azurerm_public_ip.dev-bs-public_ip1_fw.id
}

