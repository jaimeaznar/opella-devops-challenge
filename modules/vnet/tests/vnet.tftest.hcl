provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}

variables {
  resource_group_name = "test-rg"
  location            = "eastus"
  vnet_name           = "test-vnet"
  address_space       = ["10.0.0.0/16"]
  subnets = {
    "app" = {
      address_prefixes  = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
    }
    "data" = {
      address_prefixes  = ["10.0.2.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
    }
  }
  tags = {
    Environment = "Test"
    Project     = "Module Testing"
  }
}

run "verify_vnet_creation" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.vnet.name == var.vnet_name
    error_message = "VNET name doesn't match expected value"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.location == var.location
    error_message = "VNET location doesn't match expected value"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.resource_group_name == var.resource_group_name
    error_message = "VNET resource group doesn't match expected value"
  }

  assert {
    condition     = contains(azurerm_virtual_network.vnet.address_space, var.address_space[0])
    error_message = "VNET address space doesn't contain expected value"
  }

  assert {
    condition     = azurerm_virtual_network.vnet.tags["Environment"] == var.tags["Environment"]
    error_message = "VNET Environment tag doesn't match expected value"
  }
}

run "verify_subnets" {
  command = plan

  assert {
    condition     = length(azurerm_subnet.subnet) == 2
    error_message = "Expected 2 subnets to be created"
  }

  assert {
    condition     = lookup(azurerm_subnet.subnet, "app", null) != null
    error_message = "App subnet not found"
  }

  assert {
    condition     = azurerm_subnet.subnet["app"].address_prefixes[0] == var.subnets["app"].address_prefixes[0]
    error_message = "App subnet address prefix doesn't match expected value"
  }

  assert {
    condition     = lookup(azurerm_subnet.subnet, "data", null) != null
    error_message = "Data subnet not found"
  }

  assert {
    condition     = azurerm_subnet.subnet["data"].address_prefixes[0] == var.subnets["data"].address_prefixes[0]
    error_message = "Data subnet address prefix doesn't match expected value"
  }
}

run "verify_nsgs" {
  command = plan

  assert {
    condition     = length(azurerm_network_security_group.nsg) == 2
    error_message = "Expected 2 NSGs to be created"
  }

  assert {
    condition     = length([for r in azurerm_network_security_group.nsg["app"].security_rule : r if r.name == "AllowHTTP"]) == 1
    error_message = "HTTP rule not found in App NSG"
  }

  assert {
    condition     = [for r in azurerm_network_security_group.nsg["app"].security_rule : r if r.name == "AllowHTTP"][0].destination_port_range == "80"
    error_message = "HTTP rule port doesn't match expected value"
  }

  assert {
    condition     = length([for r in azurerm_network_security_group.nsg["app"].security_rule : r if r.name == "AllowSSH"]) == 1
    error_message = "SSH rule not found in App NSG"
  }

  assert {
    condition     = [for r in azurerm_network_security_group.nsg["app"].security_rule : r if r.name == "AllowSSH"][0].destination_port_range == "22"
    error_message = "SSH rule port doesn't match expected value"
  }
}

run "verify_nsg_associations" {
  command = plan

  assert {
    condition     = length(azurerm_subnet_network_security_group_association.nsg_association) == 2
    error_message = "Expected 2 NSG associations to be created"
  }

  assert {
    condition     = contains(keys(azurerm_subnet_network_security_group_association.nsg_association), "app")
    error_message = "App subnet NSG association not found"
  }

  assert {
    condition     = contains(keys(azurerm_subnet_network_security_group_association.nsg_association), "data")
    error_message = "Data subnet NSG association not found"
  }
}

run "verify_outputs" {
  command = plan

  assert {
    condition     = azurerm_virtual_network.vnet != null
    error_message = "VNET resource should be created"
  }
  
  assert {
    condition     = azurerm_virtual_network.vnet.name == var.vnet_name
    error_message = "VNET name output doesn't match expected value"
  }

  assert {
    condition     = length(azurerm_subnet.subnet) == 2
    error_message = "Expected 2 subnet resources"
  }
}