
#------------------
data "terraform_remote_state" "dev-tfstate" {
  backend = "azurerm"
  config = {
    resource_group_name = "99management"
    storage_account_name = "99management"
    container_name = "tfstate"
    subscription_id      = "46306db1-ba78-4ed8-9ab9-5a7e52f587b0"
    key = "dev/yl1"
  }
}
data "terraform_remote_state" "test-tfstate" {
  backend = "azurerm"
  config = {
    resource_group_name = "99management"
    storage_account_name = "99management"
    container_name = "tfstate"
    subscription_id      = "46306db1-ba78-4ed8-9ab9-5a7e52f587b0"
    #key = "development/app2"
    #key                  = "Q8H9FNl9l4OR1wyBfc0itNT9p40sbmxoMdyotuUcWtnBSqL70GEkcy8G5qCkpsJ1xl3mtbuCuJJM+AStcBg8eg=="
    key = "dev/yl2"
  }
}

resource "azurerm_resource_group" "peering-rg1" {
  name     = "peering-rg1"
  location = "Central India"
}

##
resource "azurerm_virtual_network" "peering-vnet" {
  name                = "dev-bs-vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.peering-rg1.location
  resource_group_name = azurerm_resource_group.peering-rg1.name
}

resource "azurerm_subnet" "peering-sub" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.peering-rg1.name
  virtual_network_name = azurerm_virtual_network.peering-vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
##

resource "azurerm_virtual_network_peering" "dev-to-test" {
  name = "dev-to-test"
  resource_group_name = data.terraform_remote_state.dev-tfstate.outputs.rsc_grp_name
  virtual_network_name = data.terraform_remote_state.dev-tfstate.outputs.vnet_name
  remote_virtual_network_id = data.terraform_remote_state.test-tfstate.outputs.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  #provider = "azurerm.dev"
}

resource "azurerm_virtual_network_peering" "test-to-dev" {
  name = "test-to-dev"
  resource_group_name = data.terraform_remote_state.test-tfstate.outputs.rsc_grp_name
  virtual_network_name = data.terraform_remote_state.test-tfstate.outputs.vnet_name
  remote_virtual_network_id = data.terraform_remote_state.dev-tfstate.outputs.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic = true
  #provider = "azurerm.test"
}

resource "azurerm_firewall" "test_fw" {
  name                = "testfirewall"
  location            = azurerm_resource_group.peering-rg1.location
  resource_group_name = azurerm_resource_group.peering-rg1.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "fw-ip-configuration1"
    public_ip_address_id = data.terraform_remote_state.dev-tfstate.outputs.pub_ip_id_fw
    subnet_id            = azurerm_subnet.peering-sub.id
  }
  ip_configuration {
    name                 = "fw-ip-configuration2"
    public_ip_address_id = data.terraform_remote_state.test-tfstate.outputs.pub_ip_id_fw
    #subnet_id            = azurerm_subnet.peering-sub.id
  }
}
