prefix              = "dev"
resource_group_name = "dev-opella-rg"
location            = "eastus"
vnet_address_space  = ["10.0.0.0/16"]

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
  Project    = "OpellaDevOpsChallenge"
  ManagedBy  = "Terraform"
  CostCenter = "Engineering"
}
