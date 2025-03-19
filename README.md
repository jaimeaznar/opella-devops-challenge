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