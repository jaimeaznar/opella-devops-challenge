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