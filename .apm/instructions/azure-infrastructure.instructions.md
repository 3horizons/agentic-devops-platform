---
applyTo: "**/*.tf,**/terraform/**"
---

# Azure Infrastructure Standards

## Authentication
- ALWAYS use Workload Identity for AKS
- NEVER use service principal secrets
- Use Managed Identity for Azure services
- Store secrets in Key Vault only

## Networking
- Use private endpoints for all PaaS services
- Configure NSGs with deny-by-default
- Enable DDoS protection for production
- Use Azure Firewall or Application Gateway for ingress

## Compliance
- Tag all resources with: environment, project, owner, cost-center
- Enable diagnostic logging on all resources
- Use Azure Policy for governance
- Enable Defender for Cloud

## AKS Specific
- Use system-assigned managed identity
- Enable Azure AD integration
- Configure authorized IP ranges
- Use private cluster for production
- Enable Workload Identity
- Configure auto-scaling

## Code Standards
```hcl
# Always include provider version constraints
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }
}

# Use locals for computed values
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Always use resource naming convention
resource "azurerm_resource_group" "main" {
  name     = "${var.project}-${var.environment}-rg"
  location = var.location
  tags     = local.common_tags
}
```
