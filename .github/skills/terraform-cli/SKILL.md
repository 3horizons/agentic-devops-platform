---
name: terraform-cli
description: 'Terraform CLI reference for infrastructure as code. Use when asked to provision infrastructure, plan changes, apply configs, manage state, import resources. Covers terraform init, terraform plan, terraform apply, terraform state.'
license: Complete terms in LICENSE.txt
---

# Terraform CLI

USE FOR:
- `terraform` commands and infrastructure as code
- Initializing Terraform projects (`terraform init`)
- Planning infrastructure changes (`terraform plan`)
- Applying configurations (`terraform apply`)
- Managing Terraform state (`terraform state`)
- Importing existing resources (`terraform import`)
- Destroying infrastructure (`terraform destroy`)
- Module development and usage

DO NOT USE FOR:
- Azure CLI commands (use azure-cli)
- Kubernetes manifest management (use kubectl-cli)
- Helm chart deployments (use helm-cli)
- Direct API calls to cloud providers
- Bicep or ARM template authoring

Comprehensive reference for Terraform CLI - infrastructure as code tool.

**Version:** 1.10.0+ (current as of 2026)

## Prerequisites

### Installation

```bash
# macOS
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Linux (Debian/Ubuntu)
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform version
```

### Environment Setup

```bash
# Azure Provider authentication
export ARM_CLIENT_ID="$CLIENT_ID"
export ARM_CLIENT_SECRET="$CLIENT_SECRET"
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"
export ARM_TENANT_ID="$TENANT_ID"

# Or use Azure CLI authentication
az login
export ARM_USE_CLI=true

# Enable debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH="terraform.log"

# Set parallelism
export TF_CLI_ARGS_apply="-parallelism=30"
```

## CLI Structure

```
terraform                   # Root command
├── init                    # Initialize working directory
├── validate                # Validate configuration
├── plan                    # Generate execution plan
├── apply                   # Apply changes
├── destroy                 # Destroy infrastructure
├── fmt                     # Format configuration
├── state                   # State management
├── workspace               # Workspace management
├── import                  # Import existing resources
├── output                  # Show output values
├── providers               # Show provider info
├── refresh                 # Update state
├── taint                   # Mark resource for recreation
├── untaint                 # Remove taint
├── graph                   # Create dependency graph
├── console                 # Interactive console
├── force-unlock            # Release state lock
└── test                    # Run tests
```

## Core Commands

### Initialize

```bash
# Basic init
terraform init

# Reconfigure backend
terraform init -reconfigure

# Migrate state
terraform init -migrate-state

# Upgrade providers
terraform init -upgrade

# From module directory
terraform init -from-module=./modules/aks

# Backend config from file
terraform init -backend-config=backend.hcl

# Backend config inline
terraform init \
  -backend-config="resource_group_name=rg-tfstate" \
  -backend-config="storage_account_name=sttfstate" \
  -backend-config="container_name=tfstate" \
  -backend-config="key=prod.terraform.tfstate"
```

### Validate

```bash
# Validate configuration
terraform validate

# JSON output
terraform validate -json
```

### Format

```bash
# Format files
terraform fmt

# Check format (don't write)
terraform fmt -check

# Recursive
terraform fmt -recursive

# Diff output
terraform fmt -diff

# List changed files
terraform fmt -list=true
```

### Plan

```bash
# Basic plan
terraform plan

# Save plan to file
terraform plan -out=tfplan

# Plan with variables
terraform plan -var="environment=prod" -var="location=eastus"

# Plan with var file
terraform plan -var-file=environments/prod.tfvars

# Destroy plan
terraform plan -destroy

# Target specific resource
terraform plan -target=module.aks

# Replace resource
terraform plan -replace=azurerm_kubernetes_cluster.main

# Compact warnings
terraform plan -compact-warnings

# JSON output
terraform plan -json
```

### Apply

```bash
# Interactive apply
terraform apply

# Apply saved plan
terraform apply tfplan

# Auto-approve (use in CI/CD)
terraform apply -auto-approve

# Apply with variables
terraform apply -var="environment=prod" -auto-approve

# Apply specific target
terraform apply -target=module.networking -auto-approve

# Parallelism control
terraform apply -parallelism=10

# Replace resource
terraform apply -replace=azurerm_kubernetes_cluster.main
```

### Destroy

```bash
# Interactive destroy
terraform destroy

# Auto-approve destroy
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=module.aks -auto-approve

# Destroy with variables
terraform destroy -var-file=environments/prod.tfvars -auto-approve
```

### Output

```bash
# Show all outputs
terraform output

# Show specific output
terraform output cluster_name

# Raw output (no quotes)
terraform output -raw kubeconfig

# JSON output
terraform output -json

# State file output
terraform output -state=terraform.tfstate
```

## State Management

### State Commands

```bash
# List resources in state
terraform state list

# Show resource details
terraform state show azurerm_kubernetes_cluster.main

# Show module resources
terraform state list module.aks

# Pull remote state
terraform state pull > state.json

# Push local state
terraform state push state.json
```

### Move Resources

```bash
# Rename resource
terraform state mv azurerm_resource_group.old azurerm_resource_group.new

# Move to module
terraform state mv azurerm_kubernetes_cluster.main module.aks.azurerm_kubernetes_cluster.main

# Move between modules
terraform state mv module.old.azurerm_virtual_network.main module.new.azurerm_virtual_network.main
```

### Remove from State

```bash
# Remove resource (doesn't destroy)
terraform state rm azurerm_kubernetes_cluster.main

# Remove module
terraform state rm module.aks

# Dry run
terraform state rm -dry-run module.aks
```

### Replace Provider

```bash
# Replace provider in state
terraform state replace-provider \
  registry.terraform.io/-/azurerm \
  registry.terraform.io/hashicorp/azurerm
```

## Workspaces

### Workspace Commands

```bash
# List workspaces
terraform workspace list

# Show current workspace
terraform workspace show

# Create workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Select workspace
terraform workspace select prod

# Delete workspace
terraform workspace delete staging
```

### Workspace Patterns

```hcl
# Use workspace in configuration
locals {
  environment = terraform.workspace
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project}-${terraform.workspace}-${var.location_short}"
  location = var.location
}
```

## Import

### Import Existing Resources

```bash
# Import resource
terraform import azurerm_resource_group.main /subscriptions/$SUB/resourceGroups/my-rg

# Import AKS cluster
terraform import azurerm_kubernetes_cluster.main \
  /subscriptions/$SUB/resourceGroups/$RG/providers/Microsoft.ContainerService/managedClusters/$NAME

# Import Key Vault
terraform import azurerm_key_vault.main \
  /subscriptions/$SUB/resourceGroups/$RG/providers/Microsoft.KeyVault/vaults/$NAME

# Import into module
terraform import module.aks.azurerm_kubernetes_cluster.main \
  /subscriptions/$SUB/resourceGroups/$RG/providers/Microsoft.ContainerService/managedClusters/$NAME
```

### Import Block (Terraform 1.5+)

```hcl
import {
  to = azurerm_resource_group.main
  id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}"
}

import {
  to = azurerm_kubernetes_cluster.main
  id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.ContainerService/managedClusters/${var.cluster_name}"
}
```

### Generate Config

```bash
# Generate configuration for imported resources (1.5+)
terraform plan -generate-config-out=generated.tf
```

## Providers

### Provider Commands

```bash
# Show providers
terraform providers

# Lock providers
terraform providers lock

# Mirror providers
terraform providers mirror ./mirror

# Show provider schema
terraform providers schema -json
```

### Provider Configuration

```hcl
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
  
  subscription_id = var.subscription_id
}
```

## Backend Configuration

### Azure Backend

```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_oidc             = true  # For workload identity
  }
}
```

### Backend Config File

```hcl
# backend.hcl
resource_group_name  = "rg-terraform-state"
storage_account_name = "stterraformstate"
container_name       = "tfstate"
key                  = "prod.terraform.tfstate"
```

```bash
terraform init -backend-config=backend.hcl
```

## Graph and Visualization

```bash
# Generate dependency graph
terraform graph

# Output as DOT
terraform graph > graph.dot

# Generate PNG (requires graphviz)
terraform graph | dot -Tpng > graph.png

# Plan graph
terraform graph -type=plan

# Apply graph
terraform graph -type=apply
```

## Console

```bash
# Start console
terraform console

# Console examples
> var.environment
"prod"
> local.resource_prefix
"aks-myproject-prod"
> azurerm_kubernetes_cluster.main.kube_config[0].host
"https://..."
> [for s in var.subnets : s.name]
["snet-aks", "snet-db", "snet-apps"]
```

## Testing (1.6+)

### Test Configuration

```hcl
# tests/aks.tftest.hcl
run "validate_aks_cluster" {
  command = plan
  
  variables {
    environment = "test"
    location    = "eastus"
  }
  
  assert {
    condition     = azurerm_kubernetes_cluster.main.location == "eastus"
    error_message = "AKS cluster should be in eastus"
  }
  
  assert {
    condition     = azurerm_kubernetes_cluster.main.sku_tier == "Standard"
    error_message = "AKS should use Standard tier"
  }
}
```

### Run Tests

```bash
# Run all tests
terraform test

# Run specific test
terraform test -filter=tests/aks.tftest.hcl

# Verbose output
terraform test -verbose

# JSON output
terraform test -json
```

## Taint and Untaint

```bash
# Mark resource for recreation
terraform taint azurerm_kubernetes_cluster.main

# Untaint resource
terraform untaint azurerm_kubernetes_cluster.main

# Taint in module
terraform taint module.aks.azurerm_kubernetes_cluster.main
```

> **Note:** `taint` is deprecated. Use `terraform apply -replace` instead:
> ```bash
> terraform apply -replace=azurerm_kubernetes_cluster.main
> ```

## Force Unlock

```bash
# Unlock state (use with caution)
terraform force-unlock LOCK_ID

# Skip confirmation
terraform force-unlock -force LOCK_ID
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `TF_LOG` | Log level (TRACE, DEBUG, INFO, WARN, ERROR) |
| `TF_LOG_PATH` | Log file path |
| `TF_INPUT` | Disable interactive input (false) |
| `TF_VAR_name` | Set variable value |
| `TF_CLI_ARGS` | Additional CLI arguments |
| `TF_CLI_ARGS_plan` | Additional plan arguments |
| `TF_CLI_ARGS_apply` | Additional apply arguments |
| `TF_DATA_DIR` | Data directory (default: .terraform) |
| `TF_WORKSPACE` | Workspace name |
| `TF_IN_AUTOMATION` | Adjust output for CI/CD |
| `TF_PLUGIN_CACHE_DIR` | Provider plugin cache |

```bash
# Example usage
export TF_VAR_environment="prod"
export TF_VAR_location="eastus"
export TF_LOG=INFO
export TF_IN_AUTOMATION=true
export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"
```

## CI/CD Patterns

### GitHub Actions

```yaml
- name: Terraform Init
  run: terraform init -backend-config=backend.hcl

- name: Terraform Plan
  run: terraform plan -out=tfplan -var-file=environments/${{ inputs.environment }}.tfvars

- name: Terraform Apply
  if: github.event_name == 'push' && github.ref == 'refs/heads/main'
  run: terraform apply -auto-approve tfplan
```

### Azure DevOps

```yaml
- task: TerraformCLI@0
  inputs:
    command: 'init'
    backendType: 'azurerm'
    backendServiceArm: 'AzureServiceConnection'
    
- task: TerraformCLI@0
  inputs:
    command: 'plan'
    environmentServiceName: 'AzureServiceConnection'
    commandOptions: '-out=$(Build.ArtifactStagingDirectory)/tfplan'
```

## Common Workflows

### New Environment Setup

```bash
# 1. Create workspace
terraform workspace new prod

# 2. Initialize with backend
terraform init -backend-config=environments/prod/backend.hcl

# 3. Plan
terraform plan -var-file=environments/prod/terraform.tfvars -out=tfplan

# 4. Review and apply
terraform apply tfplan
```

### Migrate State

```bash
# 1. Backup current state
terraform state pull > backup.tfstate

# 2. Update backend config
# Edit backend.tf

# 3. Migrate state
terraform init -migrate-state
```

### Upgrade Providers

```bash
# 1. Update version constraints
# Edit versions.tf

# 2. Upgrade
terraform init -upgrade

# 3. Plan to check changes
terraform plan

# 4. Apply if needed
terraform apply
```

## Best Practices

1. **State Management**: Always use remote state with locking
2. **Plan Files**: Save plans to files, especially in CI/CD
3. **Workspaces**: Use workspaces for environment separation
4. **Modules**: Use modules for reusable components
5. **Variables**: Use tfvars files per environment
6. **Formatting**: Run `terraform fmt` before commits
7. **Validation**: Run `terraform validate` in CI
8. **Import**: Use import blocks for existing resources
9. **Documentation**: Use terraform-docs for auto-documentation
10. **Locking**: Enable state locking in backends

## References

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
