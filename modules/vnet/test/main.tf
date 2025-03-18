provider "azurerm" {
  features {}
}

module "test_vnet" {
  source              = "../"
  resource_group_name = "test-rg"
  location            = "eastus"
  vnet_name           = "test-vnet"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    "test-subnet-1" = {
      address_prefixes = ["10.0.1.0/24"]
    }
  }

  tags = {
    Environment = "Test"
    Project     = "Module Testing"
  }
}

output "vnet_id" {
  value = module.test_vnet.vnet_id
}

output "subnet_ids" {
  value = module.test_vnet.subnet_ids
}
