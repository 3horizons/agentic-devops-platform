# Three Horizons Implementation Accelerator

> **A solution created in partnership with Microsoft, GitHub, and Red Hat**

## Overview

The **Three Horizons Implementation Accelerator** is a complete kit of Infrastructure as Code (IaC), GitOps, and developer templates designed to implement the Three Horizons platform for LATAM clients.

### What's Included

| Component | Quantity | Description |
|-----------|----------|-------------|
| **Terraform Modules** | 16 | Complete Azure infrastructure |
| **AI Agents** | 23 | Intelligent deployment orchestration |
| **Golden Path Templates** | 22 | Self-service templates for RHDH |
| **Issue Templates** | 28 | GitHub Issues templates |
| **Automation Scripts** | 14 | Bootstrap and operations |
| **MCP Servers** | 15 | MCP server configurations |
| **Observability** | 4 | Dashboards and alerts |

**Total: 120+ files | ~20,000 lines of production-ready code**

---

## Three Horizons Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        H3: INNOVATION                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ AI Foundry  │  │ SRE Agent   │  │ Multi-Agent │  │   MLOps     │    │
│  │   Agents    │  │ Integration │  │  Systems    │  │  Pipeline   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────────────┤
│                        H2: ENHANCEMENT                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   ArgoCD    │  │    RHDH     │  │Observability│  │   GitOps    │    │
│  │   GitOps    │  │   Portal    │  │    Stack    │  │  Workflows  │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────────────┤
│                        H1: FOUNDATION                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │     AKS     │  │  Network    │  │  Security   │  │     ACR     │    │
│  │   Cluster   │  │  VNet/NSG   │  │  KeyVault   │  │  Registry   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Quick Start

### Prerequisites

```bash
# Required tools
az version        # >= 2.50.0
terraform version # >= 1.5.0
kubectl version   # >= 1.28
helm version      # >= 3.12
gh --version      # >= 2.30

# Authentication
az login
gh auth login
```

### Quick Deploy

```bash
# 1. Clone the accelerator
git clone https://github.com/YOUR_ORG/three-horizons-accelerator-v4.git
cd three-horizons-accelerator-v4

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Validate prerequisites and configure variables
./scripts/validate-cli-prerequisites.sh
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your values

# 4. Complete deploy (Dev)
./scripts/platform-bootstrap.sh --environment dev

# Or deploy by horizon
./scripts/platform-bootstrap.sh --horizon h1 --environment dev
./scripts/platform-bootstrap.sh --horizon h2 --environment staging
./scripts/platform-bootstrap.sh --horizon h3 --environment prod
```

---

## Directory Structure

```
three-horizons-accelerator-v4/
│
├── agents/                         # 23 AI agent specifications
│   ├── h1-foundation/              # 8 agents (infra, network, security, ACR, DB, defender, purview, ARO)
│   ├── h2-enhancement/             # 5 agents (gitops, golden-paths, observability, rhdh, runners)
│   ├── h3-innovation/              # 4 agents (ai-foundry, sre, mlops, multi-agent)
│   └── cross-cutting/              # 6 agents (migration, validation, rollback, cost, github-app, identity)
│
├── terraform/                      # 16 Infrastructure as Code modules
│   ├── main.tf                     # Root module
│   └── modules/
│       ├── aks-cluster/            # Azure Kubernetes Service
│       ├── ai-foundry/             # Azure AI Foundry
│       ├── argocd/                 # ArgoCD GitOps
│       ├── container-registry/     # ACR
│       ├── cost-management/        # Cost analysis and budgets
│       ├── databases/              # PostgreSQL, Redis, Cosmos
│       ├── defender/               # Defender for Cloud
│       ├── disaster-recovery/      # Backup and DR
│       ├── external-secrets/       # External Secrets Operator
│       ├── github-runners/         # Self-hosted runners
│       ├── naming/                 # Naming conventions
│       ├── networking/             # VNet, Subnets, NSGs
│       ├── observability/          # Prometheus, Grafana, Loki
│       ├── purview/                # Microsoft Purview
│       ├── rhdh/                   # Red Hat Developer Hub
│       └── security/               # Key Vault, Identities
│
├── golden-paths/                   # 22 RHDH templates (Backstage)
│   ├── h1-foundation/              # 6 basic templates
│   ├── h2-enhancement/             # 9 advanced templates (incl. ADO migration)
│   └── h3-innovation/              # 7 AI/Agent templates
│
├── .github/ISSUE_TEMPLATE/         # 28 issue templates
├── argocd/                         # GitOps configurations
├── config/                         # Sizing profiles and regions
├── mcp-servers/                    # 15 MCP configurations
├── scripts/                        # 14 automation scripts
├── grafana/dashboards/             # Dashboards
├── prometheus/                     # Alerts
└── docs/                           # Documentation
```

---

## Documentation

### Comprehensive Guides

| Guide | Description |
|-------|-------------|
| [Deployment Guide](./docs/guides/DEPLOYMENT_GUIDE.md) | Complete step-by-step deployment instructions |
| [Architecture Guide](./docs/guides/ARCHITECTURE_GUIDE.md) | Three Horizons architecture explained |
| [Administrator Guide](./docs/guides/ADMINISTRATOR_GUIDE.md) | Day-2 operations and maintenance |
| [Module Reference](./docs/guides/MODULE_REFERENCE.md) | All Terraform modules with examples |
| [Troubleshooting Guide](./docs/guides/TROUBLESHOOTING_GUIDE.md) | Problem diagnosis and resolution |

### Agent Documentation

| Document | Description |
|----------|-------------|
| [Agent Overview](./agents/README.md) | Introduction to 23 AI deployment agents |
| [Agent Index](./agents/INDEX.md) | Complete agent catalog by horizon |
| [Deployment Sequence](./agents/DEPLOYMENT_SEQUENCE.md) | Step-by-step agent deployment order |
| [MCP Servers Guide](./agents/MCP_SERVERS_GUIDE.md) | Model Context Protocol server setup |
| [Dependency Graph](./agents/DEPENDENCY_GRAPH.md) | Visual agent dependencies |

### Reference

- [Sizing Profiles](./config/sizing-profiles.yaml) - Cost estimation by environment
- [Branching Strategy](./docs/BRANCHING_STRATEGY.md) - Git workflow and branch protection

---

## Detailed Usage Guide

### Step 1: Deploy Base Infrastructure (H1)

```bash
cd terraform

# Initialize Terraform
terraform init

# Create plan
terraform plan -var-file=environments/dev.tfvars -out=tfplan

# Apply (H1 Foundation)
terraform apply tfplan
```

**Resources created in H1:**
- AKS Cluster (3 nodes)
- VNet with 3 subnets
- Azure Container Registry
- Key Vault
- Managed Identities
- NSGs and Private Endpoints

### Step 2: Deploy ArgoCD and RHDH (H2)

```bash
# After H1 is complete, apply H2
terraform apply -var-file=environments/dev.tfvars -var="enable_h2=true"

# Or via script
./scripts/platform-bootstrap.sh --horizon h2 --environment dev
```

**Resources created in H2:**
- ArgoCD with ApplicationSets
- Red Hat Developer Hub
- Prometheus + Grafana + Loki
- GitHub Actions Runners

### Step 3: Deploy AI Foundry (H3)

```bash
# Requires H1 and H2
terraform apply -var-file=environments/dev.tfvars -var="enable_h3=true"
```

**Resources created in H3:**
- Azure AI Foundry
- Azure OpenAI (GPT-4o, o1)
- AI Search (Vector)
- Cosmos DB (Vector Store)

---

## Golden Paths

### Register Templates in RHDH

```bash
# Register all templates
./scripts/bootstrap.sh --register-templates

# Or register individually
kubectl apply -f golden-paths/h1-foundation/basic-cicd/template.yaml
```

### Create Application via RHDH

1. Access the portal: `https://rhdh.your-domain.com`
2. Navigate to **Create** → **Choose Template**
3. Select the template (e.g., "H2: Create Microservice")
4. Fill in the parameters:
   - Component name
   - Description
   - Owner (team)
   - Language/Framework
   - Deployment type
5. Click **Create**
6. Monitor in ArgoCD

### Available Templates by Horizon

#### H1 Foundation (Getting Started)
| Template | Use Case |
|----------|----------|
| `basic-cicd` | Simple CI/CD pipeline |
| `security-baseline` | Security configuration |
| `documentation-site` | Documentation sites |
| `web-application` | Full-stack web applications |
| `new-microservice` | Basic microservice |
| `infrastructure-provisioning` | Terraform modules |

#### H2 Enhancement (Production)
| Template | Use Case |
|----------|----------|
| `gitops-deployment` | ArgoCD applications |
| `microservice` | Complete microservice |
| `api-gateway` | API Management |
| `event-driven-microservice` | Event Hubs/Service Bus |
| `data-pipeline` | ETL with Databricks |
| `batch-job` | Scheduled jobs |
| `reusable-workflows` | GitHub workflows |

#### H3 Innovation (AI/Agents)
| Template | Use Case |
|----------|----------|
| `foundry-agent` | AI Foundry agents |
| `sre-agent-integration` | SRE automation |
| `mlops-pipeline` | Complete ML pipeline |
| `multi-agent-system` | Multi-agent orchestration |
| `copilot-extension` | GitHub Copilot extensions |
| `rag-application` | RAG applications |
| `ai-evaluation-pipeline` | Model evaluation |

---

## ArgoCD Configuration

### ApplicationSets

The accelerator uses ApplicationSets for dynamic application generation:

```yaml
# Monorepo - apps/* becomes an Application
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: monorepo-apps
spec:
  generators:
    - git:
        repoURL: https://github.com/org/platform-gitops.git
        directories:
          - path: apps/*
```

### Projects by Environment

- **Dev** - auto-sync enabled
- **Staging** - auto-sync with approval
- **Prod** - manual sync, maintenance windows

### RBAC and Roles

| Role | Permissions |
|------|-------------|
| `admin` | Full access |
| `platform-engineer` | Full access + exec |
| `sre` | Sync + actions, no delete |
| `developer` | Full dev, sync staging, view prod |
| `qa` | Full staging, view others |
| `release-manager` | Can sync prod |
| `ci-bot` | Deploy dev/staging/previews |

### Notifications

Configured to send to:
- **Microsoft Teams** - Formatted cards
- **Slack** - Colored attachments
- **Email** - HTML templates
- **PagerDuty** - Critical incidents

---

## Observability

### Grafana Dashboards

1. **Platform Overview** - Infrastructure health
2. **Golden Path Application** - RED/USE metrics
3. **AI Agent Metrics** - Agent observability

### Prometheus Alerts

| Category | Alerts | Examples |
|----------|--------|----------|
| Infrastructure | 8 | CPU, Memory, Disk, Node |
| Applications | 10 | Error rate, Latency, Availability |
| AI & Agents | 8 | Token usage, Latency, Errors |
| GitOps | 5 | Sync failures, App health |
| Security | 4 | Certificate expiration, Secrets |

---

## Security

### Secrets Management

The accelerator uses **External Secrets Operator** with **Azure Key Vault**:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
spec:
  secretStoreRef:
    name: azure-keyvault
  target:
    name: app-secrets
  data:
    - secretKey: database-password
      remoteRef:
        key: prod-database-password
```

### Workload Identity

All applications use **Azure Workload Identity** (no static secrets):

```yaml
serviceAccountName: my-app
metadata:
  annotations:
    azure.workload.identity/client-id: "<managed-identity-client-id>"
```

---

## ADO to GitHub Migration

### Migration Script

```bash
# Migrate repositories from Azure DevOps to GitHub
./scripts/migration/ado-to-github-migration.sh \
  --ado-org "contoso" \
  --ado-project "MyProject" \
  --github-org "contoso-github" \
  --repos "repo1,repo2,repo3"
```

### What's Migrated

| Item | Status |
|------|--------|
| Source code and Git history | Fully migrated |
| Branches and tags | Fully migrated |
| Pull requests | Migrated as issues |
| Wiki | Migrated as separate repository |
| Pipelines | Requires manual conversion |
| Work items | Via Azure Boards integration |

---

## Estimated Costs (USD/month)

| Resource | Dev | Staging | Production |
|----------|-----|---------|------------|
| AKS (3-5 nodes) | $300 | $600 | $1,500 |
| PostgreSQL | $50 | $100 | $300 |
| Redis | $30 | $60 | $150 |
| ACR | $20 | $40 | $100 |
| AI Foundry | $100 | $300 | $1,000+ |
| Monitoring | $50 | $100 | $250 |
| **Total** | **~$550** | **~$1,200** | **~$3,300+** |

*Note: AI Foundry costs vary with token usage*

---

## Deploy Times

| Phase | Dev | Staging | Production |
|-------|-----|---------|------------|
| H1 Foundation | 25-35 min | 35-45 min | 45-60 min |
| H2 Enhancement | 30-40 min | 40-50 min | 50-70 min |
| H3 Innovation | 20-30 min | 25-35 min | 35-45 min |
| **Total** | **75-105 min** | **100-130 min** | **130-175 min** |

---

## Troubleshooting

### Terraform Errors

```bash
# Clean corrupted state
terraform state list
terraform state rm <resource>

# Refresh state
terraform refresh

# Import existing resource
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/...
```

### ArgoCD Issues

```bash
# Check sync status
argocd app list
argocd app get <app-name>

# Force sync
argocd app sync <app-name> --force

# View logs
argocd app logs <app-name>

# Hard refresh
argocd app get <app-name> --hard-refresh
```

### AKS Issues

```bash
# Check nodes
kubectl get nodes
kubectl describe node <node-name>

# View problematic pods
kubectl get pods --all-namespaces | grep -v Running

# Pod logs
kubectl logs <pod-name> -n <namespace> --previous
```

---

## Next Steps

After reviewing this README:

1. **First time deploying?**
   - Read the [Architecture Guide](./docs/guides/ARCHITECTURE_GUIDE.md) to understand the Three Horizons model
   - Follow the [Deployment Guide](./docs/guides/DEPLOYMENT_GUIDE.md) step by step

2. **Using AI agents?**
   - Start with [Agent Overview](./agents/README.md)
   - Follow the [Deployment Sequence](./agents/DEPLOYMENT_SEQUENCE.md)
   - Setup [MCP Servers](./agents/MCP_SERVERS_GUIDE.md)

3. **Operating the platform?**
   - Use the [Administrator Guide](./docs/guides/ADMINISTRATOR_GUIDE.md) for day-2 operations
   - Reference [Troubleshooting Guide](./docs/guides/TROUBLESHOOTING_GUIDE.md) for issues

4. **Contributing?**
   - Read [CONTRIBUTING.md](./CONTRIBUTING.md)
   - Follow the [Branching Strategy](./docs/BRANCHING_STRATEGY.md)

---

## Support

For questions, issues, or suggestions, open an issue on GitHub:
- **GitHub Issues:** [Create Issue](https://github.com/paulanunes85/three-horizons-accelerator-v4/issues)

---

## References

### Official Documentation
- [Azure AKS](https://docs.microsoft.com/azure/aks/)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Red Hat Developer Hub](https://developers.redhat.com/rhdh)
- [Azure AI Foundry](https://azure.microsoft.com/products/ai-foundry/)
- [GitHub Actions](https://docs.github.com/actions)
- [External Secrets Operator](https://external-secrets.io/)

---

## Version History

### v4.0.0 (December 2025)
- 16 Terraform modules (including Defender, Purview, Naming, Disaster Recovery)
- 23 AI agents for intelligent deployment orchestration
- 28 GitHub Issues templates
- 22 Golden Path templates for RHDH (including ADO to GitHub migration)
- 14 automation scripts
- 15 MCP Server configurations
- Complete observability stack

---

**Version:** 4.0.0
**Last Updated:** December 2025
**License:** MIT
