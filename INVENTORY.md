# Three Horizons Accelerator v4.0.0 - Complete Inventory

> **Version:** 4.0.0 (Unified)  
> **Date:** December 2025  
> **Status:** Enterprise-Ready with Agentic DevOps

## 🎯 What's New in v4.0.0

This version **merges** two previously separate accelerators:
1. **Traditional Accelerator** (v3.0.0) - Production-ready IaC code
2. **Agent Kit** (v2.1.0) - AI-powered orchestration

---

## 📊 Complete Component Matrix

### Terraform Modules (14 total)

| Module | Status | Lines | Source |
|--------|--------|-------|--------|
| **aks-cluster** | ✅ Complete | 500+ | Traditional |
| **networking** | ✅ Complete | 400+ | Traditional |
| **security** | ✅ Complete | 450+ | Traditional |
| **databases** | ✅ Complete | 400+ | Traditional |
| **container-registry** | ✅ Complete | 350+ | Traditional |
| **ai-foundry** | ✅ Complete | 450+ | Traditional |
| **observability** | ✅ Complete | 500+ | Traditional |
| **argocd** | ✅ Complete | 600+ | Traditional |
| **rhdh** | ✅ Complete | 300+ | Traditional |
| **github-runners** | ✅ Complete | 250+ | Traditional |
| **defender** | ✅ Complete | 400+ | Agent Kit v4 |
| **purview** | ✅ Complete | 450+ | Agent Kit v4 |
| **naming** | ✅ NEW | 200+ | v4.0.0 |

**Total Terraform:** ~5,500+ lines of production-ready IaC

---

### Agent Specifications (23 total)

| Agent | Horizon | Issue Template | Terraform Module |
|-------|---------|----------------|------------------|
| infrastructure-agent | H1 | ✅ | aks-cluster, networking |
| networking-agent | H1 | ✅ | networking |
| security-agent | H1 | ✅ | security |
| container-registry-agent | H1 | ✅ | container-registry |
| database-agent | H1 | ✅ | databases |
| **defender-cloud-agent** | H1 | ✅ | **defender** |
| **purview-governance-agent** | H1 | ✅ | **purview** |
| **aro-platform-agent** | H1 | ✅ | scripts/deploy-aro.sh |
| gitops-agent | H2 | ✅ | argocd |
| golden-paths-agent | H2 | ✅ | golden-paths/ |
| observability-agent | H2 | ✅ | observability |
| rhdh-portal-agent | H2 | ✅ | rhdh |
| github-runners-agent | H2 | ✅ | github-runners |
| ai-foundry-agent | H3 | ✅ | ai-foundry |
| sre-agent-setup | H3 | ✅ | - |
| mlops-pipeline-agent | H3 | ✅ | ai-foundry |
| multi-agent-setup | H3 | ✅ | - |
| migration-agent | Cross | ✅ | scripts/ |
| validation-agent | Cross | ✅ | scripts/ |
| rollback-agent | Cross | ✅ | - |
| cost-optimization-agent | Cross | ✅ | - |
| **github-app-agent** | Cross | ✅ | scripts/setup-github-app.sh |
| **identity-federation-agent** | Cross | ✅ | scripts/setup-identity-federation.sh |

---

### Issue Templates (25 total)

All templates include:
- T-shirt sizing (S/M/L/XL)
- Azure region selection (Brazil South, East US 2, South Central US)
- Feature checkboxes
- Environment selection

| Template | Category | Agent Mapped |
|----------|----------|--------------|
| infrastructure.yml | H1 | infrastructure-agent |
| networking.yml | H1 | networking-agent |
| security.yml | H1 | security-agent |
| container-registry.yml | H1 | container-registry-agent |
| database.yml | H1 | database-agent |
| defender-cloud.yml | H1 | defender-cloud-agent |
| purview-governance.yml | H1 | purview-governance-agent |
| **aro-platform.yml** | H1 | aro-platform-agent |
| gitops.yml | H2 | gitops-agent |
| golden-paths.yml | H2 | golden-paths-agent |
| observability.yml | H2 | observability-agent |
| rhdh-portal.yml | H2 | rhdh-portal-agent |
| github-runners.yml | H2 | github-runners-agent |
| ai-foundry.yml | H3 | ai-foundry-agent |
| sre-agent.yml | H3 | sre-agent-setup |
| mlops-pipeline.yml | H3 | mlops-pipeline-agent |
| multi-agent.yml | H3 | multi-agent-setup |
| migration.yml | Cross | migration-agent |
| validation.yml | Cross | validation-agent |
| rollback.yml | Cross | rollback-agent |
| cost-optimization.yml | Cross | cost-optimization-agent |
| **github-app.yml** | Cross | github-app-agent |
| **identity-federation.yml** | Cross | identity-federation-agent |
| **full-deployment.yml** | Orchestrator | All agents |

---

### Configuration Files

| File | Purpose | Source |
|------|---------|--------|
| config/sizing-profiles.yaml | T-shirt sizing (S/M/L/XL) | Agent Kit |
| config/region-availability.yaml | LATAM region matrix | Agent Kit |
| mcp-servers/mcp-config.json | 15 MCP server configs | Agent Kit |
| terraform/terraform.tfvars.example | Terraform variables | Traditional |
| terraform/backend.tf.example | Remote state config | Traditional |

---

### Golden Path Templates (21 total)

#### H1 Foundation (6)
- new-microservice (Python, Java, Node, Go, .NET)
- basic-cicd
- security-baseline
- documentation-site
- infrastructure-provisioning
- web-application

#### H2 Enhancement (8)
- api-microservice
- gitops-deployment
- event-driven-microservice
- data-pipeline
- batch-job
- api-gateway
- microservice
- reusable-workflows

#### H3 Innovation (7)
- rag-application
- foundry-agent
- mlops-pipeline
- multi-agent-system
- copilot-extension
- ai-evaluation-pipeline
- sre-agent-integration

---

### Scripts (10 total)

| Script | Purpose | Status |
|--------|---------|--------|
| scripts/bootstrap.sh | Full platform deployment | ✅ |
| scripts/validate-config.sh | Pre-deployment validation | ✅ |
| scripts/onboard-team.sh | Team onboarding automation | ✅ |
| scripts/platform-bootstrap.sh | Platform-only deployment | ✅ |
| scripts/deploy-aro.sh | ARO cluster deployment | ✅ |
| scripts/setup-github-app.sh | GitHub App configuration | ✅ |
| scripts/setup-identity-federation.sh | Workload Identity setup | ✅ |
| scripts/validate-cli-prerequisites.sh | CLI tools validation | ✅ |
| scripts/validate-naming.sh | Naming convention validation | ✅ |
| scripts/migration/ado-to-github-migration.sh | ADO migration | ✅ |

---

### Observability

| Component | Type | Status |
|-----------|------|--------|
| grafana/dashboards/golden-path-application.json | Dashboard | ✅ |
| prometheus/alerting-rules.yaml | Alert Rules | ✅ |
| platform/rhdh/values.yaml | RHDH Helm Values | ✅ |

---

### ArgoCD GitOps

| File | Purpose |
|------|---------|
| argocd/app-of-apps/root-application.yaml | 6-wave bootstrap |
| argocd/sync-policies.yaml | Sync configurations |
| argocd/repo-credentials.yaml | Git credentials |
| argocd/secrets/ | External secrets directory |

---

## 🔢 Summary Statistics

| Category | Count |
|----------|-------|
| Terraform Modules | 14 |
| Agent Specifications | 23 |
| Issue Templates | 25 |
| Golden Path Templates | 21 |
| MCP Servers | 15 |
| Scripts | 10 |
| Config Files | 5 |
| ArgoCD Configs | 4 |

**Total Lines of Code:** ~18,000+

---

## 🆕 New in v4.0.0

### From Agent Kit (NEW)
- ✅ Defender for Cloud agent + Terraform module
- ✅ Purview Governance agent + Terraform module
- ✅ ARO Platform agent + deployment script
- ✅ GitHub App agent + setup script
- ✅ Identity Federation agent + setup script
- ✅ 25 Issue Templates with T-shirt sizing
- ✅ Sizing profiles (S/M/L/XL with costs)
- ✅ LATAM region availability matrix
- ✅ 15 MCP server configurations
- ✅ APM package structure
- ✅ Cost Optimization agent
- ✅ Rollback agent
- ✅ Naming module for Azure conventions

### From Traditional (EXISTING)
- ✅ 11 production-tested Terraform modules
- ✅ 21 Golden Path templates
- ✅ ArgoCD GitOps configuration
- ✅ Bootstrap and validation scripts
- ✅ Grafana dashboards
- ✅ Prometheus alert rules
- ✅ Multi-language documentation

---

## 🚀 Quick Start

```bash
# 1. Fork this repository

# 2. Configure Terraform variables
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform.tfvars with your values

# 3. Validate prerequisites and configuration
./scripts/validate-cli-prerequisites.sh
./scripts/validate-config.sh

# 4. Deploy (choose one)
./scripts/bootstrap.sh express    # Quick start
./scripts/bootstrap.sh standard   # Full platform
./scripts/bootstrap.sh enterprise # Enterprise features

# OR use GitHub Issues with AI agent
# Open an issue using any template in .github/ISSUE_TEMPLATE/
```

---

## 📁 Directory Structure

```
three-horizons-accelerator-v4/
├── agents/                    # 23 AI agent specifications
│   ├── h1-foundation/         # 8 agents (infra, network, security, ACR, DB, defender, purview, ARO)
│   ├── h2-enhancement/        # 5 agents (gitops, golden-paths, observability, rhdh, runners)
│   ├── h3-innovation/         # 4 agents (ai-foundry, sre, mlops, multi-agent)
│   └── cross-cutting/         # 6 agents (migration, validation, rollback, cost, github-app, identity)
├── terraform/                 # 14 Terraform modules
│   ├── main.tf
│   ├── modules/
│   │   ├── aks-cluster/
│   │   ├── networking/
│   │   ├── security/
│   │   ├── databases/
│   │   ├── container-registry/
│   │   ├── ai-foundry/
│   │   ├── observability/
│   │   ├── argocd/
│   │   ├── rhdh/
│   │   ├── github-runners/
│   │   ├── defender/
│   │   ├── purview/
│   │   └── naming/
│   └── examples/
├── argocd/                    # GitOps configuration
├── golden-paths/              # 21 Backstage templates
│   ├── h1-foundation/         # 6 templates
│   ├── h2-enhancement/        # 8 templates
│   └── h3-innovation/         # 7 templates
├── config/                    # Sizing & region configs
├── mcp-servers/               # 15 MCP server configs
├── scripts/                   # 10 automation scripts
├── docs/                      # Additional documentation
├── grafana/                   # Dashboards
├── prometheus/                # Alert rules
├── platform/                  # Platform configs
├── orchestrator/              # Agent router
├── .github/
│   ├── ISSUE_TEMPLATE/        # 25 issue templates
│   └── workflows/             # CI/CD workflows
├── .apm/                      # APM package
├── SKILL.md                   # AI discovery
├── apm.yml                    # APM manifest
└── ENTERPRISE_REVIEW.md       # Architecture docs
```
