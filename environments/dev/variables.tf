variable "prefix" {
  description = "Prefix to use for all resources in this environment"
  type        = string
  default     = "dev"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "eastus"
}

variable "vnet_address_space" {
  description = "Address space for the VNET"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnet names to configuration"
  type = map(object({
    address_prefixes                          = list(string)
    service_endpoints                         = optional(list(string), [])
    private_endpoint_network_policies_enabled = optional(bool, true)
    delegation                                = optional(map(list(map(string))), {})
  }))
  default = {}
}

variable "tags" {
  description = "Map of tags for the deployment"
  type        = map(string)
  default     = {}
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
}
