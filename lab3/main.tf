## Task 1
terraform {
     required_providers {
        azurerm = {
         source  = "hashicorp/azurerm"
         version = "=3.0.0"
        }
    }
}
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "RG3" {
      name     = "RG3"
      location = "West Europe"
}

resource "azurerm_virtual_network" "lab3_vnet" {
      name                = "example-network"
        resource_group_name = azurerm_resource_group.RG3.name
        location          = azurerm_resource_group.RG3.location
        address_space     = ["10.1.0.0/16"]
        dns_servers       = ["10.0.0.4", "10.0.0.5"]
            }
resource "azurerm_subnet" "lab3_subnet" {
      name                 = "lab3-subnet"
      resource_group_name  = azurerm_resource_group.RG3.name
      virtual_network_name = azurerm_virtual_network.lab3_vnet.name
      address_prefixes     = ["10.1.1.0/24"]
}

## Task 2

resource "azurerm_route_table" "lab3_route_table" {
  name                          = "lab3-route-table"
  location                      = azurerm_resource_group.RG3.location
  resource_group_name           = azurerm_resource_group.RG3.name
  disable_bgp_route_propagation = false

  route {
    name           = "routelocal"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal"
  }

  route { 
    name = "routeinternet"
    address_prefix = "0.0.0.0/0"
    next_hop_type = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "lab3_subnet_rta" {
  subnet_id      = azurerm_subnet.lab3_subnet.id
  route_table_id = azurerm_route_table.lab3_route_table.id
}

## Task 3

resource "azurerm_network_security_group" "lab3_SecurityGroup" {
  name                = "lab3_SecurityGroup"
  location            = azurerm_resource_group.RG3.location
  resource_group_name = azurerm_resource_group.RG3.name

  security_rule {
    name                       = "WebAdminNSG"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = [3389]
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "lab3_nsg_assoc" {
  subnet_id                 = azurerm_subnet.lab3_subnet.id
  network_security_group_id = azurerm_network_security_group.lab3_SecurityGroup.id
}

## Task 4

resource "azurerm_network_interface" "lab3_nic" {
  name                = "lab3-nic"
  location            = azurerm_resource_group.RG3.location
  resource_group_name = azurerm_resource_group.RG3.name

  ip_configuration {
    name                          = "lab3_ip"
    subnet_id                     = azurerm_subnet.lab3_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab3publicpip.id
  }
}



resource "azurerm_windows_virtual_machine" "VM3" {
  name                = "VM3"
  resource_group_name = azurerm_resource_group.RG3.name
  location            = azurerm_resource_group.RG3.location
  size                = "Standard_B2S"
  admin_username      = "TFadminuser"
  admin_password      = "TFP@$$w0rd1234!"
  network_interface_ids = [azurerm_network_interface.lab3_nic.id,]
 

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

}

resource "azurerm_public_ip" "lab3publicpip" {
  name                    = "lab3-pip"
  location                = azurerm_resource_group.RG3.location
  resource_group_name     = azurerm_resource_group.RG3.name
  allocation_method       = "Dynamic"
  idle_timeout_in_minutes = 30

}

