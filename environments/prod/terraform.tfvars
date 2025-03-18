prefix              = "prod"
resource_group_name = "prod-opella-rg"
location            = "eastus2"
vnet_address_space  = ["10.1.0.0/16"]

subnets = {
  "app" = {
    address_prefixes  = ["10.1.1.0/24"]
    service_endpoints = ["Microsoft.Storage"]
  }
  "data" = {
    address_prefixes  = ["10.1.2.0/24"]
    service_endpoints = ["Microsoft.Storage", "Microsoft.Sql"]
  }
}

tags = {
  Project    = "OpellaDevOpsChallenge"
  ManagedBy  = "Terraform"
  CostCenter = "Engineering"
}

ssh_public_key_path = ""
