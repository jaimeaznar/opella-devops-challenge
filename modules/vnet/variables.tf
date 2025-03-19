variable "resource_group_name" {
  description = "Name of the resource group where the VNET will be created"
  type        = string
}

variable "location" {
  description = "Azure region where the VNET will be deployed"
  type        = string
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "address_space" {
  description = "The address space for the VNET in CIDR notation"
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

variable "dns_servers" {
  description = "List of DNS servers to use with the VNET"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Map of tags to assign to the VNET resources"
  type        = map(string)
  default     = {}
}
