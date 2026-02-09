# Terraform Modules Reference

> Cross-reference between agents and Terraform modules

## Overview

Each Three Horizons agent uses specific Terraform modules to provision infrastructure. This document maps agents to their corresponding Terraform modules and provides quick access to module documentation.

---

## Module Directory Structure

```
terraform/
├── main.tf                      # Root module
├── variables.tf                 # Input variables
├── outputs.tf                   # Outputs
├── providers.tf                 # Provider configuration
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── modules/
    ├── aks-cluster/             # Azure Kubernetes Service
    ├── argocd/                  # ArgoCD GitOps
    ├── networking/              # VNet, Subnets, NSGs
    ├── observability/           # Prometheus, Grafana, Loki
    ├── databases/               # PostgreSQL, Redis, Cosmos
    ├── security/                # Key Vault, Identities
    ├── ai-foundry/              # Azure AI Foundry
    ├── container-registry/      # ACR
    ├── github-runners/          # Self-hosted runners
    ├── rhdh/                    # Red Hat Developer Hub
    ├── defender/                # Defender for Cloud
    ├── purview/                 # Microsoft Purview
    ├── external-secrets/        # External Secrets Operator
    └── naming/                  # Naming conventions
```

---

## Agent to Module Mapping

### H1 Foundation Agents

| Agent | Primary Module | Supporting Modules |
|-------|----------------|-------------------|
| [Infrastructure Agent](./h1-foundation/infrastructure-agent.md) | `aks-cluster` | `naming`, `security` |
| [Networking Agent](./h1-foundation/networking-agent.md) | `networking` | `naming` |
| [Security Agent](./h1-foundation/security-agent.md) | `security` | `naming` |
| [Container Registry Agent](./h1-foundation/container-registry-agent.md) | `container-registry` | `naming`, `networking` |
| [Database Agent](./h1-foundation/database-agent.md) | `databases` | `naming`, `networking`, `security` |
| [Defender Cloud Agent](./h1-foundation/defender-cloud-agent.md) | `defender` | `security` |
| [ARO Platform Agent](./h1-foundation/aro-platform-agent.md) | N/A (Azure CLI) | `networking`, `security` |
| [Purview Governance Agent](./h1-foundation/purview-governance-agent.md) | `purview` | `naming`, `security` |

### H2 Enhancement Agents

| Agent | Primary Module | Supporting Modules |
|-------|----------------|-------------------|
| [GitOps Agent](./h2-enhancement/gitops-agent.md) | `argocd` | `external-secrets` |
| [Observability Agent](./h2-enhancement/observability-agent.md) | `observability` | `naming` |
| [RHDH Portal Agent](./h2-enhancement/rhdh-portal-agent.md) | `rhdh` | `databases`, `security` |
| [Golden Paths Agent](./h2-enhancement/golden-paths-agent.md) | N/A (Kubernetes) | `rhdh` |
| [GitHub Runners Agent](./h2-enhancement/github-runners-agent.md) | `github-runners` | `container-registry` |

### H3 Innovation Agents

| Agent | Primary Module | Supporting Modules |
|-------|----------------|-------------------|
| [AI Foundry Agent](./h3-innovation/ai-foundry-agent.md) | `ai-foundry` | `security`, `networking` |
| [MLOps Pipeline Agent](./h3-innovation/mlops-pipeline-agent.md) | `ai-foundry` | `databases` |
| [SRE Agent Setup](./h3-innovation/sre-agent-setup.md) | N/A (Kubernetes) | `observability` |
| [Multi-Agent Setup](./h3-innovation/multi-agent-setup.md) | `ai-foundry` | `security` |

### Cross-Cutting Agents

| Agent | Primary Module | Supporting Modules |
|-------|----------------|-------------------|
| [Validation Agent](./cross-cutting/validation-agent.md) | All modules | - |
| [Migration Agent](./cross-cutting/migration-agent.md) | N/A (CLI tools) | - |
| [Rollback Agent](./cross-cutting/rollback-agent.md) | N/A (Helm/ArgoCD) | - |
| [Cost Optimization Agent](./cross-cutting/cost-optimization-agent.md) | `cost-management` | - |
| [GitHub App Agent](./cross-cutting/github-app-agent.md) | N/A (GitHub CLI) | - |
| [Identity Federation Agent](./cross-cutting/identity-federation-agent.md) | `security` | - |

---

## Module Details

### aks-cluster

**Path:** `terraform/modules/aks-cluster/`

**Used by:** Infrastructure Agent

**Resources Created:**
- Azure Kubernetes Service cluster
- Node pools (system, user, AI)
- Managed Identity
- Log Analytics workspace

**Key Variables:**
```hcl
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.29"
}

variable "node_pool_config" {
  description = "Node pool configuration"
  type = object({
    name       = string
    node_count = number
    vm_size    = string
  })
}
```

**Outputs:**
```hcl
output "cluster_id" {}
output "cluster_fqdn" {}
output "kube_config" {}
output "kubelet_identity" {}
```

---

### networking

**Path:** `terraform/modules/networking/`

**Used by:** Networking Agent

**Resources Created:**
- Virtual Network
- Subnets (AKS, databases, services, endpoints)
- Network Security Groups
- Private DNS Zones
- Private Endpoints

**Key Variables:**
```hcl
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "Address space for VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Subnet configurations"
  type = map(object({
    address_prefix = string
    service_endpoints = list(string)
  }))
}
```

---

### security

**Path:** `terraform/modules/security/`

**Used by:** Security Agent, Identity Federation Agent

**Resources Created:**
- Azure Key Vault
- Managed Identities
- Role Assignments
- Azure Policies

**Key Variables:**
```hcl
variable "keyvault_name" {
  description = "Name of the Key Vault"
  type        = string
}

variable "enable_rbac" {
  description = "Enable RBAC authorization"
  type        = bool
  default     = true
}
```

---

### container-registry

**Path:** `terraform/modules/container-registry/`

**Used by:** Container Registry Agent

**Resources Created:**
- Azure Container Registry
- Geo-replication (optional)
- Private endpoint
- Webhook configurations

**Key Variables:**
```hcl
variable "acr_name" {
  description = "Name of the container registry"
  type        = string
}

variable "sku" {
  description = "ACR SKU"
  type        = string
  default     = "Premium"
}
```

---

### databases

**Path:** `terraform/modules/databases/`

**Used by:** Database Agent

**Resources Created:**
- Azure Database for PostgreSQL Flexible Server
- Azure Cache for Redis
- Azure Cosmos DB (optional)
- Azure SQL Database (optional)

**Key Variables:**
```hcl
variable "postgresql_config" {
  description = "PostgreSQL configuration"
  type = object({
    name    = string
    version = string
    sku     = string
    storage = number
  })
}

variable "redis_config" {
  description = "Redis configuration"
  type = object({
    name     = string
    sku      = string
    capacity = number
  })
}
```

---

### argocd

**Path:** `terraform/modules/argocd/`

**Used by:** GitOps Agent

**Resources Created:**
- ArgoCD namespace
- ArgoCD Helm release
- RBAC configurations
- ApplicationSets
- Notifications ConfigMap

**Key Variables:**
```hcl
variable "namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "5.51.0"
}

variable "enable_sso" {
  description = "Enable SSO with Azure AD"
  type        = bool
  default     = true
}
```

---

### observability

**Path:** `terraform/modules/observability/`

**Used by:** Observability Agent

**Resources Created:**
- Prometheus (Azure Managed or self-hosted)
- Grafana (Azure Managed or self-hosted)
- Alertmanager
- Loki (optional)

**Key Variables:**
```hcl
variable "use_azure_managed" {
  description = "Use Azure Managed Prometheus/Grafana"
  type        = bool
  default     = true
}

variable "retention_days" {
  description = "Metrics retention in days"
  type        = number
  default     = 30
}
```

---

### ai-foundry

**Path:** `terraform/modules/ai-foundry/`

**Used by:** AI Foundry Agent, MLOps Pipeline Agent, Multi-Agent Setup

**Resources Created:**
- Azure AI Foundry workspace
- Azure OpenAI resource
- AI Search (vector store)
- Compute instances
- Model deployments

**Key Variables:**
```hcl
variable "workspace_name" {
  description = "AI Foundry workspace name"
  type        = string
}

variable "openai_models" {
  description = "OpenAI models to deploy"
  type = list(object({
    name    = string
    version = string
    sku     = string
  }))
}
```

---

### defender

**Path:** `terraform/modules/defender/`

**Used by:** Defender Cloud Agent

**Resources Created:**
- Defender for Cloud plans
- Security contacts
- Auto-provisioning settings
- Regulatory compliance

**Key Variables:**
```hcl
variable "enable_plans" {
  description = "Defender plans to enable"
  type        = list(string)
  default     = ["VirtualMachines", "Containers", "KeyVaults"]
}
```

---

### purview

**Path:** `terraform/modules/purview/`

**Used by:** Purview Governance Agent

**Resources Created:**
- Microsoft Purview account
- Collections
- Data sources
- Classification rules

**Key Variables:**
```hcl
variable "purview_name" {
  description = "Purview account name"
  type        = string
}

variable "managed_resource_group" {
  description = "Managed resource group name"
  type        = string
}
```

---

### rhdh

**Path:** `terraform/modules/rhdh/`

**Used by:** RHDH Portal Agent

**Resources Created:**
- RHDH namespace
- RHDH Helm release
- PostgreSQL database
- OAuth configuration

**Key Variables:**
```hcl
variable "namespace" {
  description = "Namespace for RHDH"
  type        = string
  default     = "rhdh"
}

variable "github_oauth" {
  description = "GitHub OAuth configuration"
  type = object({
    client_id     = string
    client_secret = string
  })
  sensitive = true
}
```

---

### github-runners

**Path:** `terraform/modules/github-runners/`

**Used by:** GitHub Runners Agent

**Resources Created:**
- Actions Runner Controller
- Runner deployments
- Runner scale sets
- Service accounts

**Key Variables:**
```hcl
variable "github_org" {
  description = "GitHub organization"
  type        = string
}

variable "runner_groups" {
  description = "Runner group configurations"
  type = list(object({
    name     = string
    replicas = number
    labels   = list(string)
  }))
}
```

---

## Usage Examples

### Deploy Single Module

```bash
cd terraform

# Initialize
terraform init

# Plan specific module
terraform plan -target=module.aks-cluster -var-file=environments/dev.tfvars

# Apply specific module
terraform apply -target=module.aks-cluster -var-file=environments/dev.tfvars
```

### Deploy All H1 Modules

```bash
terraform apply \
  -target=module.networking \
  -target=module.security \
  -target=module.aks-cluster \
  -target=module.container-registry \
  -target=module.databases \
  -var-file=environments/dev.tfvars
```

### View Module Outputs

```bash
terraform output -module=aks-cluster
terraform output -module=networking
```

---

## Module Dependencies

```
naming (no dependencies)
    │
    ├── networking
    │       │
    │       ├── security
    │       │       │
    │       │       ├── aks-cluster
    │       │       │       │
    │       │       │       ├── argocd
    │       │       │       ├── observability
    │       │       │       ├── rhdh
    │       │       │       └── github-runners
    │       │       │
    │       │       ├── ai-foundry
    │       │       │
    │       │       └── defender
    │       │
    │       ├── container-registry
    │       │
    │       ├── databases
    │       │
    │       └── purview
    │
    └── external-secrets (post AKS)
```

---

## Next Steps

After understanding the module mapping:

1. **Deploy modules** - Follow [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md)
2. **Detailed module docs** - See [Module Reference Guide](../../guides/MODULE_REFERENCE.md)
3. **Understand dependencies** - Check [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md)
4. **Validate deployment** - Run `./scripts/validate-agents.sh`

---

## Related Documentation

### Agent Documentation
- [README.md](./README.md) - Agents overview
- [INDEX.md](./INDEX.md) - Complete agent index
- [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md) - Deployment order
- [MCP_SERVERS_GUIDE.md](./MCP_SERVERS_GUIDE.md) - MCP server setup
- [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md) - Visual dependencies

### Main Guides
- [Module Reference Guide](../../guides/MODULE_REFERENCE.md) - Detailed module documentation
- [Deployment Guide](../../guides/DEPLOYMENT_GUIDE.md) - Full deployment instructions
- [Architecture Guide](../../guides/ARCHITECTURE_GUIDE.md) - Three Horizons architecture

---

**Version:** 4.0.0
**Last Updated:** December 2025
