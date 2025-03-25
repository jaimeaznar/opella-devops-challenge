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

################
###Monitoring###
################
output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace's ID"
  value       = azurerm_log_analytics_workspace.workspace.id
}

output "log_analytics_workspace_portal_url" {
  description = "Log Analytics Workspace URL"
  value       = "https://portal.azure.com/#@/resource${azurerm_log_analytics_workspace.workspace.id}/overview"
}

output "monitor_action_group_id" {
  description = "Monitor Action Group's ID"
  value       = azurerm_monitor_action_group.critical.id
}