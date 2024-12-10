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
        address_space     = ["10.0.0.0/16"]
        dns_servers       = ["10.0.0.4", "10.0.0.5"]
            }
resource "azurerm_subnet" "lab3_subnet" {
      name                 = "lab3-subnet"
      resource_group_name  = azurerm_resource_group.RG3.name
      virtual_network_name = azurerm_virtual_network.lab3_vnet.name
      address_prefixes     = ["10.1.1.0/24"]
}

## Task 2


## Task 3

## Task 4
