# virtual network outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "vnet_id" {
  description = "The ID of the VNet"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "The name of the VNet"
  value       = module.vnet.vnet_name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = module.vnet.subnet_ids
}

#virtual machine outputs
output "vm_id" {
  description = "The ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.id
}

output "vm_private_ip" {
  description = "The private IP address of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.private_ip_address
}

#storage account outputs
output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint URL"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}
