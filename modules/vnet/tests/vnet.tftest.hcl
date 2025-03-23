# Simple provider configuration - credentials will be picked up from environment variables
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

# Test module configuration
variables {
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

run "create_vnet" {
  command = plan

  variables {
    resource_group_name = var.resource_group_name
    location            = var.location
    vnet_name           = var.vnet_name
    address_space       = var.address_space
    subnets             = var.subnets
    tags                = var.tags
  }

  assert {
    condition     = contains(output.vnet_address_space, var.address_space[0])
    error_message = "VNET address space does not contain expected value"
  }

  assert {
    condition     = output.vnet_name == var.vnet_name
    error_message = "VNET name does not match expected value"
  }
}

run "verify_subnet_configuration" {
  command = plan

  variables {
    resource_group_name = var.resource_group_name
    location            = var.location
    vnet_name           = var.vnet_name
    address_space       = var.address_space
    subnets             = var.subnets
    tags                = var.tags
  }

  assert {
    condition     = contains(keys(output.subnet_ids), "test-subnet-1")
    error_message = "Expected subnet 'test-subnet-1' was not created"
  }
}

run "verify_tags" {
  command = plan

  variables {
    resource_group_name = var.resource_group_name
    location            = var.location
    vnet_name           = var.vnet_name
    address_space       = var.address_space
    subnets             = var.subnets
    tags                = var.tags
  }

  assert {
    condition     = output.vnet_tags["Environment"] == var.tags["Environment"]
    error_message = "VNET Environment tag does not match expected value"
  }
}
