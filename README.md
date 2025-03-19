# Opella DevOps Technical Challenge: Azure Infrastructure with Terraform

This repository contains Terraform code for provisioning Azure infrastructure, following the requirements of the Opella DevOps Technical Challenge. It includes a reusable VNET module and configurations for multiple environments.

## Features

- **Reusable VNET Module**: Modular design with a Virtual Network module that can be reused across environments
- **Multi-Environment Support**: Separate configurations for development and production environments
- **Free Tier Resources**: All resources designed to use Azure's free tier where possible
- **Security-First Approach**: Network isolation with properly configured NSGs and access controls
- **CI/CD Pipeline**: GitHub Actions workflows for automated deployment and cleanup
- **Code Quality Tools**: Pre-commit hooks, TFLint, and Checkov for maintaining high code standards
- **Automated Documentation**: Using terraform-docs to maintain up-to-date documentation

## Repository Structure

```
.
├── .github/                      # GitHub Actions workflows
│   └── workflows/
│       ├── terraform.yml         # CI/CD workflow
│       └── terraform-destroy.yml # Infrastructure cleanup workflow
├── environments/                 # Environment-specific configurations
│   ├── dev/                      # Development environment
│   └── prod/                     # Production environment
├── modules/                      # Reusable Terraform modules
│   └── vnet/                     # Virtual Network module
├── .gitignore                    # Git ignore file
├── .pre-commit-config.yaml       # Pre-commit hooks configuration
├── .tflint.hcl                   # TFLint configuration
├── .terraform-docs.yml           # Terraform docs configuration
└── README.md                     # Project documentation
```

## Prerequisites

- Azure subscription (free tier is sufficient)
- Terraform >= 1.0.0
- Azure CLI >= 2.30.0
- Git
- GitHub account (for CI/CD)

## Getting Started

### Local Development Setup

1. **Clone this repository**:
   ```bash
   git clone https://github.com/yourusername/opella-devops-challenge.git
   cd opella-devops-challenge
   ```

2. **Install required tools**:
   ```bash
   # For macOS
   brew install terraform azure-cli pre-commit terraform-docs tflint checkov

   # Install pre-commit and other tools
   brew install pre-commit
   sudo apt install terraform-docs tflint
   brew install checkov
   ```

3. **Install pre-commit hooks**:
   ```bash
   pre-commit install
   ```

4. **Log in to Azure CLI**:
   ```bash
   az login
   ```

5. **Create a Service Principal for Terraform**:
   ```bash
   # Create a service principal and save the output
   az ad sp create-for-rbac --name "OpellaTerraformSP" --role Contributor --scopes /subscriptions/$(az account show --query id -o tsv)
   ```
   You'll need to save the output (appId, password, tenant) for the next step.

6. **Create Azure Storage Backend Resources**:
   ```bash
   # Set variables
   RESOURCE_GROUP_NAME="terraform-state-rg"
   STORAGE_ACCOUNT_NAME="Must be globally unique"
   CONTAINER_NAME="tfstate"
   LOCATION="eastus"

   # Create resource group
   az group create --name $RESOURCE_GROUP_NAME --location $LOCATION

   # Create storage account
   az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP_NAME --sku Standard_LRS --kind StorageV2

   # Create blob container
   az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME
   ```

7. **Configure environment variables for Terraform**:
   ```bash
   # From the service principal output
   export ARM_CLIENT_ID="<appId>"
   export ARM_CLIENT_SECRET="<password>"
   export ARM_SUBSCRIPTION_ID="<subscription-id>"
   export ARM_TENANT_ID="<tenant>"
   ```

8. **Generate SSH key for VM access**:
   ```bash
   ssh-keygen -t rsa-sha2-256 -f ~/.ssh/azure_terraform_key
   ```

9. **Copy the public key content**:
   ```bash
   cat ~/.ssh/azure_terraform_key.pub
   ```

### Deploy Infrastructure Locally

1. **Initialize Terraform for the development environment**:
   ```bash
   cd environments/dev
   
   # Get storage account key for backend
   STORAGE_KEY=$(az storage account keys list --account-name opellaterraformstate --resource-group terraform-state-rg --query '[0].value' -o tsv)
   
   # Initialize with backend access
   terraform init -backend-config="access_key=$STORAGE_KEY"
   ```

2. **Modify variables if needed**:
   Review and update `terraform.tfvars` if you need to customize any variables.

3. **Run a Terraform plan**:
   ```bash
   terraform plan -var="ssh_public_key_content=$(cat ~/.ssh/azure_terraform_key.pub)"
   ```

4. **Apply the Terraform configuration**:
   ```bash
   terraform apply -var="ssh_public_key_content=$(cat ~/.ssh/azure_terraform_key.pub)"
   ```

5. **Destroy resources when done**:
   ```bash
   terraform destroy -var="ssh_public_key_content=$(cat ~/.ssh/azure_terraform_key.pub)"
   ```

## Using GitHub Actions for Deployment

This repository includes GitHub Actions workflows for automated infrastructure deployment and cleanup.

### Setup for GitHub Actions

1. **Fork or push this repository to your GitHub account**

2. **Add repository secrets**:
   Go to your repository → Settings → Secrets and variables → Actions → New repository secret:
   
   - `AZURE_CREDENTIALS`: The entire JSON output from the service principal creation
   - `ARM_CLIENT_ID`: The client ID from your service principal
   - `ARM_CLIENT_SECRET`: The client secret from your service principal
   - `ARM_SUBSCRIPTION_ID`: Your Azure subscription ID
   - `ARM_TENANT_ID`: Your Azure tenant ID
   - `SSH_PUBLIC_KEY`: The content of your SSH public key file

3. **Run the deployment workflow**:
   - Go to the "Actions" tab in your repository
   - Select and run the "Terraform CI/CD" workflow

4. **Clean up resources when done**:
   - Go to the "Actions" tab
   - Select and run the "Terraform Destroy" workflow


## VNET Module Documentation

The central component of this project is the reusable VNET module.

<!-- BEGIN_TF_DOCS -->
## Requirements
No requirements.
## Providers
| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.23.0 |
## Modules
| Name |
|------|
| vnet |
## Resources
| Name | Type |
|------|------|
| [azurerm_network_security_group.nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_subnet.subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | The address space for the VNET in CIDR notation | `list(string)` | <pre>[<br/>  "10.0.0.0/16"<br/>]</pre> | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | List of DNS servers to use with the VNET | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the VNET will be deployed | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group where the VNET will be created | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Map of subnet names to configuration | <pre>map(object({<br/>    address_prefixes                          = list(string)<br/>    service_endpoints                         = optional(list(string), [])<br/>    private_endpoint_network_policies_enabled = optional(bool, true)<br/>    delegation                                = optional(map(list(map(string))), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to assign to the VNET resources | `map(string)` | `{}` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Name of the Virtual Network | `string` | n/a | yes |
## Outputs
| Name | Description |
|------|-------------|
| <a name="output_network_security_group_ids"></a> [network\_security\_group\_ids](#output\_network\_security\_group\_ids) | Map of subnet names to network security group IDs |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Map of subnet names to subnet IDs |
| <a name="output_vnet_address_space"></a> [vnet\_address\_space](#output\_vnet\_address\_space) | The address space of the Virtual Network |
| <a name="output_vnet_id"></a> [vnet\_id](#output\_vnet\_id) | The ID of the Virtual Network |
| <a name="output_vnet_name"></a> [vnet\_name](#output\_vnet\_name) | The name of the Virtual Network |
<!-- END_TF_DOCS -->

### Usage Example

```hcl
module "vnet" {
  source              = "./modules/vnet"
  resource_group_name = "example-rg"
  location            = "eastus"
  vnet_name           = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  
  subnets = {
    "subnet1" = {
      address_prefixes = ["10.0.1.0/24"]
      service_endpoints = ["Microsoft.Storage", "Microsoft.KeyVault"]
    }
    "subnet2" = {
      address_prefixes = ["10.0.2.0/24"]
    }
  }
  
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}
```

## Development and Production Environments

This project includes configurations for two environments:

### Development

- VNet with 10.0.0.0/16 address space
- App and Data subnets
- Standard_B1s VM (free tier eligible)
- Standard LRS storage account
- Private storage container

### Production

- VNet with 10.1.0.0/16 address space
- App and Data subnets
- Standard_B1s VM (free tier eligible for demonstration)
- Standard LRS storage account
- Private storage container

## Code Quality Tools

This project uses several tools to maintain code quality:

### Pre-commit Hooks

Pre-commit hooks run automatically before each commit to ensure code quality:

```yaml
repos:
- repo: https://github.com/pre-commit/pre-commit-hooks
  rev: v4.4.0
  hooks:
  - id: trailing-whitespace
  - id: end-of-file-fixer
  - id: check-yaml
  - id: check-added-large-files

- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.77.1
  hooks:
  - id: terraform_fmt
  - id: terraform_docs
  - id: terraform_validate
  - id: terraform_tflint
  - id: terraform_checkov
    args:
      - --args=--quiet
      - --args=--framework=terraform
```

### TFLint

TFLint provides static analysis of Terraform code, checking for:
- Deprecated syntax
- Unused declarations
- Documentation completeness
- Naming conventions
- Provider configurations

### Checkov

Checkov scans infrastructure-as-code for security and compliance issues, helping identify:
- Insecure configurations
- Compliance violations
- Best practice deviations

### Automated Documentation

This project uses terraform-docs to automatically generate and maintain documentation:
- Documentation is generated from code comments and resource definitions
- The process is automated via pre-commit hooks and GitHub Actions
- Documentation stays in sync with the actual code