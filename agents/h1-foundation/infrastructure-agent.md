---
name: "Infrastructure Agent"
version: "1.0.0"
horizon: "H1"
status: "stable"
last_updated: "2025-12-15"
mcp_servers:
  - azure
  - terraform
  - kubernetes
dependencies:
  - naming
  - aks-cluster
  - networking
  - security
  - container-registry
---

# Infrastructure Agent

## Overview

The Infrastructure Agent provisions and manages core Azure infrastructure for the Three Horizons Platform.

## Responsibilities

- Deploy Azure Kubernetes Service (AKS) clusters
- Configure networking (VNet, subnets, NSGs)
- Provision Azure Container Registry (ACR)
- Setup Azure Key Vault
- Configure Managed Identities
- Apply Azure Policy assignments

## Integration Points

### Terraform Modules

| Module | Path | Purpose |
|--------|------|---------|
| **naming** | `terraform/modules/naming/` | CAF-compliant resource naming |
| aks-cluster | `terraform/modules/aks-cluster/` | Kubernetes cluster |
| networking | `terraform/modules/networking/` | Network infrastructure |
| security | `terraform/modules/security/` | Key Vault, identities |
| container-registry | `terraform/modules/container-registry/` | Container registry |

### Scripts

| Script | Purpose |
|--------|---------|
| `scripts/validate-cli-prerequisites.sh` | Verify required CLIs |
| `scripts/validate-naming.sh` | Validate resource names |
| `scripts/validate-config.sh` | Validate configuration |

### Issue Template

- **Template**: `.github/ISSUE_TEMPLATE/infrastructure.yml`
- **Labels**: `agent:infrastructure`, `horizon:h1`

### MCP Servers

- `azure-mcp-server` - Azure Resource Manager operations
- `terraform-mcp-server` - Infrastructure as Code
- `kubernetes-mcp-server` - Cluster configuration

## Naming Convention

This agent uses the **naming module** for CAF-compliant names:

```hcl
module "naming" {
  source = "./modules/naming"
  
  project_name = var.project_name  # e.g., "threehorizons"
  environment  = var.environment   # e.g., "prd"
  location     = var.location      # e.g., "brazilsouth"
}

# Usage
resource "azurerm_kubernetes_cluster" "main" {
  name = module.naming.aks_cluster  # aks-threehorizons-prd-brs
}
```

### Resource Naming Patterns

| Resource | Pattern | Example |
|----------|---------|---------|
| Resource Group | `rg-{project}-{env}-{region}` | `rg-threehorizons-prd-brs` |
| AKS Cluster | `aks-{project}-{env}-{region}` | `aks-threehorizons-prd-brs` |
| Container Registry | `cr{project}{env}{region}` | `crthreehorizonsprdbrs` |
| Key Vault | `kv-{project}-{env}-{region}` | `kv-threehorizons-prd-brs` |
| VNet | `vnet-{project}-{env}-{region}` | `vnet-threehorizons-prd-brs` |

⚠️ **Critical Naming Rules:**
- **ACR**: No hyphens allowed, alphanumeric only
- **Storage Account**: No hyphens, lowercase + numbers only, max 24 chars
- **Key Vault**: Max 24 characters

## Workflow

```yaml
# Triggered by: infrastructure.yml issue
# Dependencies: None (foundation)

steps:
  - name: Validate Prerequisites
    run: ./scripts/validate-cli-prerequisites.sh
    
  - name: Validate Naming
    run: ./scripts/validate-naming.sh --all $PROJECT $ENV $REGION
    
  - name: Initialize Terraform
    run: |
      cd terraform
      terraform init
      
  - name: Plan Infrastructure
    run: terraform plan -out=tfplan
    
  - name: Apply Infrastructure
    run: terraform apply tfplan
    
  - name: Output Summary
    run: terraform output -json > infrastructure-summary.json
```

## Dependencies

### Requires
- Azure subscription with Owner/Contributor access
- Entra ID permissions for managed identities
- GitHub repository for GitOps

### Enables
- `security-agent` - Key Vault configuration
- `gitops-agent` - ArgoCD deployment
- `rhdh-portal-agent` - Developer portal
- `observability-agent` - Monitoring stack

## Configuration

### Sizing Profiles

See `config/sizing-profiles.yaml`:

| Profile | Nodes | VM Size | Use Case |
|---------|-------|---------|----------|
| small | 3 | D4s_v3 | Development |
| medium | 5 | D8s_v3 | Staging |
| large | 10 | D16s_v3 | Production |
| xlarge | 20 | D32s_v3 | Enterprise |

### Region Availability

See `config/region-availability.yaml` for service availability by region.

## Example Usage

```bash
# 1. Validate prerequisites
./scripts/validate-cli-prerequisites.sh

# 2. Validate naming
./scripts/validate-naming.sh --all myproject prd brazilsouth

# 3. Deploy infrastructure
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

## Related Agents

| Agent | Relationship |
|-------|-------------|
| `networking-agent` | Provides network foundation |
| `security-agent` | Configures Key Vault and identities |
| `container-registry-agent` | Provisions ACR |
| `database-agent` | Deploys PostgreSQL/Redis |
| `validation-agent` | Validates deployment |
