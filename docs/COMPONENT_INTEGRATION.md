# Component Integration Map

## Overview

This document maps the relationships between all components in the Three Horizons Accelerator.

## Integration Matrix

### Agents ↔ Terraform Modules

| Agent | Primary Module | Secondary Modules | Naming Pattern |
|-------|---------------|-------------------|----------------|
| `infrastructure-agent` | `aks-cluster` | `networking`, `security` | `aks-{project}-{env}-{region}` |
| `networking-agent` | `networking` | - | `vnet-{project}-{env}-{region}` |
| `security-agent` | `security` | - | `kv-{project}-{env}-{region}` |
| `container-registry-agent` | `container-registry` | `security` | `cr{project}{env}{region}` |
| `database-agent` | `databases` | `security`, `networking` | `psql-{project}-{env}-{region}` |
| `defender-cloud-agent` | `defender` | - | N/A (subscription-level) |
| `purview-governance-agent` | `purview` | - | `pview-{project}-{env}-{region}` |
| `gitops-agent` | `argocd` | `security` | N/A (Kubernetes) |
| `github-runners-agent` | `github-runners` | `aks-cluster` | N/A (GitHub) |
| `rhdh-portal-agent` | `rhdh` | `databases`, `security` | N/A (Kubernetes) |
| `observability-agent` | `observability` | - | `log-{project}-{env}-{region}` |
| `ai-foundry-agent` | `ai-foundry` | `security`, `networking` | `oai-{project}-{env}-{region}` |

### Agents ↔ Scripts

| Agent | Primary Script | Helper Scripts |
|-------|---------------|----------------|
| `infrastructure-agent` | - | `validate-cli-prerequisites.sh` |
| `identity-federation-agent` | `setup-identity-federation.sh` | - |
| `github-app-agent` | `setup-github-app.sh` | - |
| `aro-platform-agent` | `deploy-aro.sh` | - |
| `gitops-agent` | `bootstrap.sh` | - |
| `golden-paths-agent` | `onboard-team.sh` | - |
| `migration-agent` | `ado-to-github-migration.sh` | - |
| `validation-agent` | `validate-config.sh` | `validate-naming.sh` |

### Agents ↔ Issue Templates

| Agent | Issue Template | Labels |
|-------|---------------|--------|
| `infrastructure-agent` | `infrastructure.yml` | `agent:infrastructure`, `horizon:h1` |
| `networking-agent` | `networking.yml` | `agent:networking`, `horizon:h1` |
| `security-agent` | `security.yml` | `agent:security`, `horizon:h1` |
| `container-registry-agent` | `container-registry.yml` | `agent:container-registry`, `horizon:h1` |
| `database-agent` | `database.yml` | `agent:database`, `horizon:h1` |
| `defender-cloud-agent` | `defender-cloud.yml` | `agent:defender`, `horizon:h1` |
| `purview-governance-agent` | `purview-governance.yml` | `agent:purview`, `horizon:h1` |
| `gitops-agent` | `gitops.yml` | `agent:gitops`, `horizon:h2` |
| `github-runners-agent` | `github-runners.yml` | `agent:github-runners`, `horizon:h2` |
| `rhdh-portal-agent` | `rhdh-portal.yml` | `agent:rhdh`, `horizon:h2` |
| `observability-agent` | `observability.yml` | `agent:observability`, `horizon:h2` |
| `golden-paths-agent` | `golden-paths.yml` | `agent:golden-paths`, `horizon:h2` |
| `ai-foundry-agent` | `ai-foundry.yml` | `agent:ai-foundry`, `horizon:h3` |
| `mlops-pipeline-agent` | `mlops-pipeline.yml` | `agent:mlops`, `horizon:h3` |
| `identity-federation-agent` | `identity-federation.yml` | `agent:identity`, `cross-cutting` |
| `github-app-agent` | `github-app.yml` | `agent:github-app`, `cross-cutting` |
| `aro-platform-agent` | `aro-platform.yml` | `agent:aro`, `horizon:h1` |
| `migration-agent` | `migration.yml` | `agent:migration`, `cross-cutting` |
| `validation-agent` | `validation.yml` | `agent:validation`, `cross-cutting` |
| `rollback-agent` | `rollback.yml` | `agent:rollback`, `cross-cutting` |
| `cost-optimization-agent` | `cost-optimization.yml` | `agent:cost`, `cross-cutting` |

### Scripts ↔ Terraform Modules

| Script | Terraform Modules Used | Naming Validation |
|--------|----------------------|-------------------|
| `bootstrap.sh` | `argocd`, `rhdh`, `observability` | ❌ |
| `deploy-aro.sh` | None (uses `az` CLI) | ✅ |
| `setup-identity-federation.sh` | None (uses `az` & `gh` CLI) | ❌ |
| `setup-github-app.sh` | None (uses `gh` CLI) | ❌ |
| `onboard-team.sh` | None (GitOps) | ❌ |
| `validate-naming.sh` | `naming` (validation) | ✅ |
| `validate-config.sh` | All (validation) | ✅ |

### MCP Servers ↔ Agents

| MCP Server | Primary Agents |
|------------|---------------|
| `azure-mcp-server` | infrastructure, security, database, defender, purview |
| `github-mcp-server` | gitops, github-runners, github-app, migration |
| `terraform-mcp-server` | infrastructure, networking, security, all |
| `kubernetes-mcp-server` | gitops, rhdh, observability, golden-paths |
| `openshift-mcp-server` | aro-platform |
| `helm-mcp-server` | argocd, rhdh, observability |
| `defender-mcp-server` | defender-cloud |
| `purview-mcp-server` | purview-governance |
| `copilot-mcp-server` | ai-foundry, mlops-pipeline |

## Dependency Graph

```
                    ┌──────────────────┐
                    │  Prerequisites   │
                    │ ─────────────────│
                    │ • CLI validation │
                    │ • Naming check   │
                    │ • Identity Fed   │
                    └────────┬─────────┘
                             │
              ┌──────────────┴──────────────┐
              ▼                              ▼
    ┌─────────────────┐            ┌─────────────────┐
    │   Networking    │            │    Security     │
    │ ────────────────│            │ ────────────────│
    │ • VNet          │            │ • Key Vault     │
    │ • Subnets       │            │ • Identities    │
    │ • NSGs          │◄──────────►│ • RBAC          │
    └────────┬────────┘            └────────┬────────┘
             │                              │
             └──────────────┬───────────────┘
                            ▼
              ┌─────────────────────────┐
              │    AKS / ARO Cluster    │
              │ ────────────────────────│
              │ • Kubernetes            │
              │ • Node pools            │
              │ • Workload Identity     │
              └────────────┬────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
┌─────────────┐   ┌─────────────┐   ┌─────────────┐
│     ACR     │   │  Databases  │   │  Defender   │
│ ────────────│   │ ────────────│   │ ────────────│
│ • Registry  │   │ • PostgreSQL│   │ • Security  │
│ • Scanning  │   │ • Redis     │   │ • Policies  │
└──────┬──────┘   └──────┬──────┘   └──────┬──────┘
       │                 │                 │
       └─────────────────┴─────────────────┘
                         │
         ┌───────────────┼───────────────┐
         ▼               ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│   ArgoCD    │ │    RHDH     │ │Observability│
│ ────────────│ │ ────────────│ │ ────────────│
│ • GitOps    │ │ • Portal    │ │ • Prometheus│
│ • Apps      │ │ • Catalog   │ │ • Grafana   │
└──────┬──────┘ └──────┬──────┘ └──────┬──────┘
       │               │               │
       └───────────────┼───────────────┘
                       ▼
         ┌─────────────────────────┐
         │      Golden Paths       │
         │ ────────────────────────│
         │ • Templates             │
         │ • Scaffolding           │
         └────────────┬────────────┘
                      │
         ┌────────────┴────────────┐
         ▼                         ▼
┌─────────────────┐     ┌─────────────────┐
│   AI Foundry    │     │     MLOps       │
│ ────────────────│     │ ────────────────│
│ • OpenAI        │     │ • Pipelines     │
│ • AI Search     │     │ • Models        │
└─────────────────┘     └─────────────────┘
```

## Validation Checklist

Before deploying, run these validations:

```bash
# 1. CLI Prerequisites
./scripts/validate-cli-prerequisites.sh

# 2. Naming Convention (all resources)
./scripts/validate-naming.sh --all myproject prd brazilsouth

# 3. Terraform Validation
cd terraform
terraform validate

# 4. Configuration Validation
./scripts/validate-config.sh
```

## Quick Reference: Scripts by Purpose

| Purpose | Script | When to Use |
|---------|--------|-------------|
| **Validate Tools** | `validate-cli-prerequisites.sh` | Before any deployment |
| **Validate Names** | `validate-naming.sh` | Before creating resources |
| **Validate Config** | `validate-config.sh` | Before terraform apply |
| **Setup OIDC** | `setup-identity-federation.sh` | For GitHub Actions auth |
| **Setup GitHub App** | `setup-github-app.sh` | For RHDH/ArgoCD SSO |
| **Deploy ARO** | `deploy-aro.sh` | Alternative to AKS |
| **Bootstrap Platform** | `bootstrap.sh` | After infrastructure |
| **Onboard Team** | `onboard-team.sh` | For new teams |
| **Migrate from ADO** | `ado-to-github-migration.sh` | ADO to GitHub |

## File Locations

```
three-horizons-accelerator-v4/
├── agents/                      # Agent specifications
│   ├── h1-foundation/          # H1 agents
│   ├── h2-enhancement/         # H2 agents
│   ├── h3-innovation/          # H3 agents
│   └── cross-cutting/          # Cross-cutting agents
├── terraform/
│   ├── main.tf                 # Root configuration
│   ├── modules/
│   │   ├── naming/             # ⭐ NAMING MODULE
│   │   ├── aks-cluster/
│   │   ├── networking/
│   │   ├── security/
│   │   ├── container-registry/
│   │   ├── databases/
│   │   └── ...
│   └── examples/
│       └── naming-integration.tf
├── scripts/
│   ├── validate-cli-prerequisites.sh
│   ├── validate-naming.sh      # ⭐ NAMING VALIDATION
│   ├── validate-config.sh
│   ├── setup-identity-federation.sh
│   ├── setup-github-app.sh
│   ├── deploy-aro.sh
│   ├── bootstrap.sh
│   └── onboard-team.sh
├── .github/
│   └── ISSUE_TEMPLATE/         # Issue templates
├── golden-paths/               # Software templates
├── docs/
│   ├── NAMING_CONVENTIONS.md   # ⭐ NAMING DOCS
│   └── COMPONENT_INTEGRATION.md
└── config/
    ├── sizing-profiles.yaml
    └── region-availability.yaml
```
