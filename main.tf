terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }
}

variable "SUBSCRIPTION_ID" {
  description = "The Azure region for resources."
  type        = string
}

provider "azurerm" {
  subscription_id = "ENTER_YOUR_SUBSCRIPTION_ID_HERE"
}

resource "azurerm_resource_group" "main" {
    name = "learn-tf-rg-eastus"
    location = "eastus"
}

resource "azurerm_virtual_network" "main" {
    name = "learn-tf-vnet-eastus"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "main" {
    name = "learn-tf-subnet"
    resource_group_name = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes = ["10.0.0.0/24"] 
}

resource "azurerm_network_interface" "internal" {
    name = "learn-tf-nic"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name

    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.main.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "main" {
    name = "learn-tf-vm"
    location = azurerm_resource_group.main.location
    resource_group_name = azurerm_resource_group.main.name
    network_interface_ids = [azurerm_network_interface.internal.id]
    vm_size = "Standard_B1s"

    storage_os_disk {
        name = "learn-tf-osdisk"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        publisher = "MicrosoftWindowsServer"
        offer = "WindowsServer"
        sku = "2016-DataCenter"
        version = "latest"
    }

    os_profile {
        computer_name = "hostname"
        admin_username = "azureuser"
        admin_password = "<YourPasswordHere>"
    }
    os_profile_windows_config {
        provision_vm_agent = true
    }
    tags = {
        environment = "Learning"
    }
  
}