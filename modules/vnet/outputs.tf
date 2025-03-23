output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network"
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "Map of subnet names to subnet IDs"
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "network_security_group_ids" {
  description = "Map of subnet names to network security group IDs"
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}

output "vnet_tags" {
  description = "The tags assigned to the Virtual Network"
  value       = azurerm_virtual_network.vnet.tags
}
