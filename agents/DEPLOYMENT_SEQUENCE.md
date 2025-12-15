# Deployment Sequence Guide

> Step-by-step guide for deploying agents in the correct order

## Overview

The Three Horizons Platform must be deployed in phases to respect dependencies between components. This guide provides the recommended deployment sequence.

---

## Deployment Phases

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DEPLOYMENT TIMELINE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Phase 1: H1 Foundation        Phase 2: H2 Enhancement    Phase 3: H3       │
│  ─────────────────────────     ─────────────────────────  ──────────────    │
│  [Infrastructure Agent]        [GitOps Agent]             [AI Foundry]      │
│         │                            │                         │            │
│         ▼                            ▼                         ▼            │
│  [Networking Agent]            [Observability Agent]      [MLOps Agent]     │
│         │                            │                         │            │
│         ▼                            ▼                         ▼            │
│  [Security Agent]              [RHDH Portal Agent]        [SRE Agent]       │
│         │                            │                         │            │
│         ▼                            ▼                         ▼            │
│  [Container Registry]          [Golden Paths Agent]       [Multi-Agent]     │
│         │                            │                                      │
│         ▼                            ▼                                      │
│  [Database Agent]              [GitHub Runners Agent]                       │
│         │                                                                   │
│         ▼                                                                   │
│  [Defender Agent]                                                           │
│         │                                                                   │
│         ▼                                                                   │
│  [Purview Agent] (optional)                                                 │
│         │                                                                   │
│         ▼                                                                   │
│  [ARO Agent] (optional)                                                     │
│                                                                             │
├─────────────────────────────────────────────────────────────────────────────┤
│  Cross-Cutting Agents: Can run anytime after Phase 1                        │
│  ─────────────────────────────────────────────────────────────────────────  │
│  [Validation] [Migration] [Rollback] [Cost] [GitHub App] [Identity]         │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: H1 Foundation

**Duration:** 45-60 minutes
**Prerequisites:** Azure subscription, required tools installed

### Step 1.1: Pre-Setup (Cross-Cutting)

Before deploying infrastructure, optionally configure identity and GitHub:

| Order | Agent | Duration | Required |
|-------|-------|----------|----------|
| 1a | [Identity Federation Agent](./cross-cutting/identity-federation-agent.md) | 10 min | Optional |
| 1b | [GitHub App Agent](./cross-cutting/github-app-agent.md) | 10 min | Optional |

### Step 1.2: Core Infrastructure

Deploy the foundation in this order:

| Order | Agent | Duration | Dependencies | GitHub Label |
|-------|-------|----------|--------------|--------------|
| 1 | [Infrastructure Agent](./h1-foundation/infrastructure-agent.md) | 25-35 min | None | `agent:infrastructure` |
| 2 | [Networking Agent](./h1-foundation/networking-agent.md) | 10-15 min | Infrastructure | `agent:networking` |
| 3 | [Security Agent](./h1-foundation/security-agent.md) | 10-15 min | Networking | `agent:security` |
| 4 | [Container Registry Agent](./h1-foundation/container-registry-agent.md) | 5-10 min | Security | `agent:container-registry` |
| 5 | [Database Agent](./h1-foundation/database-agent.md) | 15-20 min | Networking | `agent:database` |
| 6 | [Defender Cloud Agent](./h1-foundation/defender-cloud-agent.md) | 10-15 min | Infrastructure | `agent:defender` |

### Step 1.3: Optional Foundation Components

| Order | Agent | Duration | Dependencies | When to Use |
|-------|-------|----------|--------------|-------------|
| 7 | [Purview Governance Agent](./h1-foundation/purview-governance-agent.md) | 15-20 min | Infrastructure | Data governance required |
| 8 | [ARO Platform Agent](./h1-foundation/aro-platform-agent.md) | 30-45 min | Networking | OpenShift instead of AKS |

### Phase 1 Validation

Run the Validation Agent after completing Phase 1:

```bash
# Trigger validation via GitHub Issue
gh issue create \
  --title "Validate H1 Foundation Deployment" \
  --label "agent:validation,scope:h1-foundation" \
  --body "Run comprehensive validation of H1 foundation deployment"
```

**Expected Results:**
- [ ] AKS cluster healthy
- [ ] VNet and subnets configured
- [ ] NSGs applied
- [ ] Key Vault accessible
- [ ] ACR operational
- [ ] Databases responding
- [ ] Defender enabled

---

## Phase 2: H2 Enhancement

**Duration:** 50-70 minutes
**Prerequisites:** Phase 1 completed and validated

### Step 2.1: Platform Core

Deploy platform capabilities:

| Order | Agent | Duration | Dependencies | GitHub Label |
|-------|-------|----------|--------------|--------------|
| 1 | [GitOps Agent](./h2-enhancement/gitops-agent.md) | 15-20 min | AKS Cluster | `agent:gitops` |
| 2 | [Observability Agent](./h2-enhancement/observability-agent.md) | 10-15 min | AKS Cluster | `agent:observability` |
| 3 | [RHDH Portal Agent](./h2-enhancement/rhdh-portal-agent.md) | 20-25 min | GitOps, Database | `agent:rhdh` |

### Step 2.2: Developer Experience

| Order | Agent | Duration | Dependencies | GitHub Label |
|-------|-------|----------|--------------|--------------|
| 4 | [Golden Paths Agent](./h2-enhancement/golden-paths-agent.md) | 10-15 min | RHDH Portal | `agent:golden-paths` |
| 5 | [GitHub Runners Agent](./h2-enhancement/github-runners-agent.md) | 10-15 min | AKS, ACR | `agent:github-runners` |

### Phase 2 Validation

```bash
# Trigger validation via GitHub Issue
gh issue create \
  --title "Validate H2 Enhancement Deployment" \
  --label "agent:validation,scope:h2-enhancement" \
  --body "Run comprehensive validation of H2 enhancement deployment"
```

**Expected Results:**
- [ ] ArgoCD accessible
- [ ] Applications syncing
- [ ] Prometheus scraping metrics
- [ ] Grafana dashboards loading
- [ ] RHDH portal accessible
- [ ] Golden Path templates registered
- [ ] GitHub Runners registered and idle

---

## Phase 3: H3 Innovation

**Duration:** 35-45 minutes
**Prerequisites:** Phase 1 and Phase 2 completed

### Step 3.1: AI/ML Capabilities

| Order | Agent | Duration | Dependencies | GitHub Label |
|-------|-------|----------|--------------|--------------|
| 1 | [AI Foundry Agent](./h3-innovation/ai-foundry-agent.md) | 15-20 min | Infrastructure, Security | `agent:ai-foundry` |
| 2 | [MLOps Pipeline Agent](./h3-innovation/mlops-pipeline-agent.md) | 10-15 min | AI Foundry | `agent:mlops` |

### Step 3.2: Advanced Automation

| Order | Agent | Duration | Dependencies | GitHub Label |
|-------|-------|----------|--------------|--------------|
| 3 | [SRE Agent Setup](./h3-innovation/sre-agent-setup.md) | 10-15 min | Observability | `agent:sre` |
| 4 | [Multi-Agent Setup](./h3-innovation/multi-agent-setup.md) | 15-20 min | AI Foundry, SRE | `agent:multi-agent` |

### Phase 3 Validation

```bash
# Trigger validation via GitHub Issue
gh issue create \
  --title "Validate H3 Innovation Deployment" \
  --label "agent:validation,scope:h3-innovation" \
  --body "Run comprehensive validation of H3 innovation deployment"
```

**Expected Results:**
- [ ] AI Foundry workspace operational
- [ ] Models deployed and responding
- [ ] MLOps pipelines configured
- [ ] SRE agent monitoring active
- [ ] Multi-agent orchestration functional

---

## Cross-Cutting Agents

These agents can be run at any time after Phase 1:

### Utility Agents

| Agent | When to Use | GitHub Label |
|-------|-------------|--------------|
| [Validation Agent](./cross-cutting/validation-agent.md) | After any deployment phase | `agent:validation` |
| [Cost Optimization Agent](./cross-cutting/cost-optimization-agent.md) | Post-deployment, monthly review | `agent:cost-optimization` |
| [Rollback Agent](./cross-cutting/rollback-agent.md) | Emergency recovery | `agent:rollback` |

### Setup Agents

| Agent | When to Use | GitHub Label |
|-------|-------------|--------------|
| [Identity Federation Agent](./cross-cutting/identity-federation-agent.md) | Before Phase 1 or as needed | `agent:identity` |
| [GitHub App Agent](./cross-cutting/github-app-agent.md) | Before using GitHub features | `agent:github-app` |
| [Migration Agent](./cross-cutting/migration-agent.md) | When migrating from ADO | `agent:migration` |

---

## Estimated Total Time

| Deployment Type | Phases | Estimated Time |
|-----------------|--------|----------------|
| **Minimal (H1 only)** | Phase 1 | 45-60 min |
| **Standard (H1 + H2)** | Phase 1 + 2 | 95-130 min |
| **Full (H1 + H2 + H3)** | Phase 1 + 2 + 3 | 130-175 min |

---

## Quick Deploy Commands

### Deploy All Phases (Automated)

```bash
# Option 1: Bootstrap script
./scripts/platform-bootstrap.sh --environment dev

# Option 2: Phase by phase
./scripts/platform-bootstrap.sh --horizon h1 --environment dev
./scripts/platform-bootstrap.sh --horizon h2 --environment dev
./scripts/platform-bootstrap.sh --horizon h3 --environment dev
```

### Deploy Individual Agent

```bash
# Via GitHub Issue (recommended)
gh issue create \
  --title "[Agent Request] Deploy GitOps" \
  --label "agent:gitops,env:dev" \
  --body "Deploy ArgoCD to development environment"

# Via Terraform directly
cd terraform
terraform apply -var-file=environments/dev.tfvars -target=module.argocd
```

---

## Rollback Procedures

If a deployment fails, use the Rollback Agent:

```bash
# Rollback specific component
gh issue create \
  --title "[Rollback] ArgoCD deployment" \
  --label "agent:rollback,priority:high" \
  --body "Rollback ArgoCD to previous version due to sync failures"
```

See [rollback-agent.md](./cross-cutting/rollback-agent.md) for detailed procedures.

---

## Troubleshooting

### Common Issues

| Issue | Phase | Solution |
|-------|-------|----------|
| AKS creation timeout | Phase 1 | Check Azure quotas, retry |
| NSG blocking traffic | Phase 1 | Review security rules |
| ArgoCD not syncing | Phase 2 | Check Git credentials |
| RHDH auth failing | Phase 2 | Verify OAuth configuration |
| AI model quota exceeded | Phase 3 | Request quota increase |

### Getting Help

1. Run Validation Agent to diagnose issues
2. Check [TROUBLESHOOTING_GUIDE.md](../docs/guides/TROUBLESHOOTING_GUIDE.md)
3. Open a [GitHub Issue](https://github.com/paulanunes85/three-horizons-accelerator-v4/issues)

---

## Next Steps

After completing deployment:

1. **Validate the deployment** - Run `./scripts/validate-agents.sh`
2. **Configure applications** - Use [Golden Paths Agent](./h2-enhancement/golden-paths-agent.md)
3. **Setup monitoring** - Check [Observability Agent](./h2-enhancement/observability-agent.md)
4. **Review costs** - Run [Cost Optimization Agent](./cross-cutting/cost-optimization-agent.md)
5. **Document customizations** - Update your fork's documentation

---

## Related Documentation

### Agent Documentation
- [README.md](./README.md) - Agents overview
- [INDEX.md](./INDEX.md) - Complete agent index
- [MCP_SERVERS_GUIDE.md](./MCP_SERVERS_GUIDE.md) - MCP server setup
- [TERRAFORM_MODULES_REFERENCE.md](./TERRAFORM_MODULES_REFERENCE.md) - Terraform modules
- [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md) - Visual dependencies

### Main Guides
- [Deployment Guide](../docs/guides/DEPLOYMENT_GUIDE.md) - Full deployment instructions
- [Administrator Guide](../docs/guides/ADMINISTRATOR_GUIDE.md) - Day-2 operations
- [Troubleshooting Guide](../docs/guides/TROUBLESHOOTING_GUIDE.md) - Problem resolution

---

**Version:** 4.0.0
**Last Updated:** December 2025
