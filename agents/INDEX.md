# Agent Index

> Complete inventory of all Three Horizons deployment agents

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Total Agents** | 23 |
| **Total Lines** | 10,362 |
| **Categories** | 4 |
| **Average Lines/Agent** | 450 |
| **Spec Version** | 1.0.0 |

---

## Complete Agent Inventory

### By Category

<details>
<summary><strong>H1 Foundation (8 agents - 3,346 lines)</strong></summary>

| # | Agent | File | Lines | Complexity | MCP Servers |
|---|-------|------|-------|------------|-------------|
| 1 | Infrastructure | `h1-foundation/infrastructure-agent.md` | 165 | Medium | Azure, Kubernetes, Terraform |
| 2 | Networking | `h1-foundation/networking-agent.md` | 372 | High | Azure, Kubernetes |
| 3 | Security | `h1-foundation/security-agent.md` | 371 | High | Azure, Kubernetes |
| 4 | Container Registry | `h1-foundation/container-registry-agent.md` | 338 | Medium | Azure, Kubernetes |
| 5 | Database | `h1-foundation/database-agent.md` | 405 | High | Azure, Kubernetes |
| 6 | Defender Cloud | `h1-foundation/defender-cloud-agent.md` | 398 | Medium | Azure |
| 7 | ARO Platform | `h1-foundation/aro-platform-agent.md` | 454 | Very High | Azure, Kubernetes |
| 8 | Purview Governance | `h1-foundation/purview-governance-agent.md` | 594 | High | Azure |

</details>

<details>
<summary><strong>H2 Enhancement (5 agents - 2,326 lines)</strong></summary>

| # | Agent | File | Lines | Complexity | MCP Servers |
|---|-------|------|-------|------------|-------------|
| 1 | GitOps | `h2-enhancement/gitops-agent.md` | 576 | High | Kubernetes, Helm, GitHub |
| 2 | Observability | `h2-enhancement/observability-agent.md` | 206 | Medium | Kubernetes, Helm |
| 3 | RHDH Portal | `h2-enhancement/rhdh-portal-agent.md` | 651 | Very High | Kubernetes, Helm, GitHub |
| 4 | Golden Paths | `h2-enhancement/golden-paths-agent.md` | 521 | Medium | Kubernetes, GitHub |
| 5 | GitHub Runners | `h2-enhancement/github-runners-agent.md` | 383 | Medium | Kubernetes, GitHub |

</details>

<details>
<summary><strong>H3 Innovation (4 agents - 2,016 lines)</strong></summary>

| # | Agent | File | Lines | Complexity | MCP Servers |
|---|-------|------|-------|------------|-------------|
| 1 | AI Foundry | `h3-innovation/ai-foundry-agent.md` | 677 | Very High | Azure, Azure-AI, Kubernetes |
| 2 | MLOps Pipeline | `h3-innovation/mlops-pipeline-agent.md` | 452 | Very High | Azure, Kubernetes |
| 3 | SRE Agent | `h3-innovation/sre-agent-setup.md` | 336 | High | Kubernetes, Prometheus |
| 4 | Multi-Agent | `h3-innovation/multi-agent-setup.md` | 501 | Very High | Kubernetes, Azure-AI |

</details>

<details>
<summary><strong>Cross-Cutting (6 agents - 2,674 lines)</strong></summary>

| # | Agent | File | Lines | Complexity | MCP Servers |
|---|-------|------|-------|------------|-------------|
| 1 | Validation | `cross-cutting/validation-agent.md` | 693 | Medium | Azure, Kubernetes, Terraform |
| 2 | Migration | `cross-cutting/migration-agent.md` | 678 | High | Git, GitHub |
| 3 | Rollback | `cross-cutting/rollback-agent.md` | 422 | High | Kubernetes, Helm |
| 4 | Cost Optimization | `cross-cutting/cost-optimization-agent.md` | 446 | Medium | Azure |
| 5 | GitHub App | `cross-cutting/github-app-agent.md` | 356 | Medium | GitHub |
| 6 | Identity Federation | `cross-cutting/identity-federation-agent.md` | 367 | High | Azure |

</details>

---

## Alphabetical Index

| Agent | Category | Horizon | File |
|-------|----------|---------|------|
| AI Foundry | H3 Innovation | H3 | [ai-foundry-agent.md](./h3-innovation/ai-foundry-agent.md) |
| ARO Platform | H1 Foundation | H1 | [aro-platform-agent.md](./h1-foundation/aro-platform-agent.md) |
| Container Registry | H1 Foundation | H1 | [container-registry-agent.md](./h1-foundation/container-registry-agent.md) |
| Cost Optimization | Cross-Cutting | All | [cost-optimization-agent.md](./cross-cutting/cost-optimization-agent.md) |
| Database | H1 Foundation | H1 | [database-agent.md](./h1-foundation/database-agent.md) |
| Defender Cloud | H1 Foundation | H1 | [defender-cloud-agent.md](./h1-foundation/defender-cloud-agent.md) |
| GitHub App | Cross-Cutting | All | [github-app-agent.md](./cross-cutting/github-app-agent.md) |
| GitHub Runners | H2 Enhancement | H2 | [github-runners-agent.md](./h2-enhancement/github-runners-agent.md) |
| GitOps | H2 Enhancement | H2 | [gitops-agent.md](./h2-enhancement/gitops-agent.md) |
| Golden Paths | H2 Enhancement | H2 | [golden-paths-agent.md](./h2-enhancement/golden-paths-agent.md) |
| Identity Federation | Cross-Cutting | All | [identity-federation-agent.md](./cross-cutting/identity-federation-agent.md) |
| Infrastructure | H1 Foundation | H1 | [infrastructure-agent.md](./h1-foundation/infrastructure-agent.md) |
| Migration | Cross-Cutting | All | [migration-agent.md](./cross-cutting/migration-agent.md) |
| MLOps Pipeline | H3 Innovation | H3 | [mlops-pipeline-agent.md](./h3-innovation/mlops-pipeline-agent.md) |
| Multi-Agent | H3 Innovation | H3 | [multi-agent-setup.md](./h3-innovation/multi-agent-setup.md) |
| Networking | H1 Foundation | H1 | [networking-agent.md](./h1-foundation/networking-agent.md) |
| Observability | H2 Enhancement | H2 | [observability-agent.md](./h2-enhancement/observability-agent.md) |
| Purview Governance | H1 Foundation | H1 | [purview-governance-agent.md](./h1-foundation/purview-governance-agent.md) |
| RHDH Portal | H2 Enhancement | H2 | [rhdh-portal-agent.md](./h2-enhancement/rhdh-portal-agent.md) |
| Rollback | Cross-Cutting | All | [rollback-agent.md](./cross-cutting/rollback-agent.md) |
| Security | H1 Foundation | H1 | [security-agent.md](./h1-foundation/security-agent.md) |
| SRE Agent | H3 Innovation | H3 | [sre-agent-setup.md](./h3-innovation/sre-agent-setup.md) |
| Validation | Cross-Cutting | All | [validation-agent.md](./cross-cutting/validation-agent.md) |

---

## By Use Case

### Infrastructure Setup
- [Infrastructure Agent](./h1-foundation/infrastructure-agent.md) - AKS, Key Vault, ACR
- [Networking Agent](./h1-foundation/networking-agent.md) - VNet, NSG, DNS
- [Security Agent](./h1-foundation/security-agent.md) - RBAC, Policies
- [Container Registry Agent](./h1-foundation/container-registry-agent.md) - ACR

### Database & Storage
- [Database Agent](./h1-foundation/database-agent.md) - PostgreSQL, Redis, Cosmos

### Security & Compliance
- [Security Agent](./h1-foundation/security-agent.md) - Workload Identity, RBAC
- [Defender Cloud Agent](./h1-foundation/defender-cloud-agent.md) - Defender for Cloud
- [Purview Governance Agent](./h1-foundation/purview-governance-agent.md) - Data governance

### GitOps & CI/CD
- [GitOps Agent](./h2-enhancement/gitops-agent.md) - ArgoCD
- [GitHub Runners Agent](./h2-enhancement/github-runners-agent.md) - Self-hosted runners
- [GitHub App Agent](./cross-cutting/github-app-agent.md) - GitHub App setup

### Developer Experience
- [RHDH Portal Agent](./h2-enhancement/rhdh-portal-agent.md) - Developer Hub
- [Golden Paths Agent](./h2-enhancement/golden-paths-agent.md) - Templates

### Monitoring & Observability
- [Observability Agent](./h2-enhancement/observability-agent.md) - Prometheus, Grafana

### AI/ML
- [AI Foundry Agent](./h3-innovation/ai-foundry-agent.md) - Azure AI Foundry
- [MLOps Pipeline Agent](./h3-innovation/mlops-pipeline-agent.md) - ML pipelines
- [Multi-Agent Agent](./h3-innovation/multi-agent-setup.md) - Multi-agent orchestration

### Operations & SRE
- [SRE Agent](./h3-innovation/sre-agent-setup.md) - Auto-healing
- [Validation Agent](./cross-cutting/validation-agent.md) - Health checks
- [Rollback Agent](./cross-cutting/rollback-agent.md) - Emergency rollback
- [Cost Optimization Agent](./cross-cutting/cost-optimization-agent.md) - Cost management

### Migration
- [Migration Agent](./cross-cutting/migration-agent.md) - ADO to GitHub

### Identity & Auth
- [Identity Federation Agent](./cross-cutting/identity-federation-agent.md) - Entra ID, OIDC

### Alternative Platforms
- [ARO Platform Agent](./h1-foundation/aro-platform-agent.md) - OpenShift alternative

---

## By Complexity

### Very High Complexity
| Agent | Lines | Reason |
|-------|-------|--------|
| AI Foundry | 677 | Multiple AI services, RAG, models |
| RHDH Portal | 651 | Dual platform support (AKS/ARO) |
| Multi-Agent | 501 | Complex orchestration patterns |
| ARO Platform | 454 | Full OpenShift deployment |
| MLOps Pipeline | 452 | End-to-end ML lifecycle |

### High Complexity
| Agent | Lines | Reason |
|-------|-------|--------|
| Validation | 693 | Many validation types |
| Migration | 678 | Complex conversion logic |
| GitOps | 576 | ArgoCD full setup |
| Golden Paths | 521 | Template management |
| Purview Governance | 594 | Governance rules |
| Database | 405 | Multiple database types |
| Networking | 372 | Network architecture |
| Security | 371 | Security policies |

### Medium Complexity
| Agent | Lines | Reason |
|-------|-------|--------|
| Cost Optimization | 446 | Cost analysis |
| Rollback | 422 | Rollback procedures |
| Defender Cloud | 398 | Security scanning |
| GitHub Runners | 383 | Runner deployment |
| Identity Federation | 367 | Identity setup |
| GitHub App | 356 | App configuration |
| Container Registry | 338 | ACR setup |
| SRE Agent | 336 | Auto-remediation |

### Lower Complexity
| Agent | Lines | Reason |
|-------|-------|--------|
| Observability | 206 | Standard stack deployment |
| Infrastructure | 165 | Core infrastructure |

---

## MCP Server Requirements

| MCP Server | Required By | Priority |
|------------|-------------|----------|
| **Kubernetes** | 15 agents | Critical |
| **Azure** | 13 agents | Critical |
| **GitHub** | 10 agents | Critical |
| **Helm** | 6 agents | High |
| **Terraform** | 4 agents | High |
| **Git** | 2 agents | Medium |
| **Azure-AI** | 2 agents | High |
| **Prometheus** | 1 agent | Low |

See [MCP_SERVERS_GUIDE.md](./MCP_SERVERS_GUIDE.md) for setup instructions.

---

## Next Steps

1. **Ready to deploy?** Follow the [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md)
2. **Need to setup MCP servers?** See [MCP_SERVERS_GUIDE.md](./MCP_SERVERS_GUIDE.md)
3. **Check Terraform modules?** View [TERRAFORM_MODULES_REFERENCE.md](./TERRAFORM_MODULES_REFERENCE.md)
4. **Understand dependencies?** Check [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md)
5. **Validate setup?** Run `./scripts/validate-agents.sh`

---

## Related Documentation

### Agent Documentation
- [README.md](./README.md) - Quick start guide
- [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md) - Deployment order
- [MCP_SERVERS_GUIDE.md](./MCP_SERVERS_GUIDE.md) - MCP server setup
- [TERRAFORM_MODULES_REFERENCE.md](./TERRAFORM_MODULES_REFERENCE.md) - Terraform modules
- [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md) - Visual dependencies

### Main Guides
- [Deployment Guide](../docs/guides/DEPLOYMENT_GUIDE.md) - Full deployment instructions
- [Troubleshooting Guide](../docs/guides/TROUBLESHOOTING_GUIDE.md) - Problem resolution

---

**Version:** 4.0.0
**Last Updated:** December 2025
