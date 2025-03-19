provider "azurerm" {
  features {}
}

terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "opellaterraformstate"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(var.tags, {
    Environment = "Development"
  })
}

module "vnet" {
  source              = "../../modules/vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  vnet_name           = "${var.prefix}-vnet"
  address_space       = var.vnet_address_space
  subnets             = var.subnets
  tags = merge(var.tags, {
    Environment = "Development"
  })
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.prefix}-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.vnet.subnet_ids["app"]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.ssh_public_key_content
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = merge(var.tags, {
    Environment = "Development"
  })
}

resource "azurerm_storage_account" "storage" {
  name                     = "devopella${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [module.vnet.subnet_ids["app"]]
    bypass                     = ["AzureServices"]
  }

  tags = merge(var.tags, {
    Environment = "Development"
  })
}

resource "azurerm_storage_container" "container" {
  name                  = "data"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}
