# Three Horizons Agents

> **A solution created in partnership with Microsoft, GitHub, and Red Hat**
>
> Intelligent deployment orchestration for the Three Horizons Platform

## Quick Reference

| Category | Agents | Purpose |
| :--- | :--- | :--- |
| [H1 Foundation](./h1-foundation/) | 8 | Core infrastructure (AKS, networking, security, databases) |
| [H2 Enhancement](./h2-enhancement/) | 5 | Platform capabilities (GitOps, observability, developer portal) |
| [H3 Innovation](./h3-innovation/) | 4 | Advanced features (AI/ML, SRE automation, multi-agent) |
| [Cross-Cutting](./cross-cutting/) | 6 | Utilities (validation, migration, rollback, cost optimization) |

**Total: 23 agents | 10,362 lines of specifications**

> 🤖 **Looking for Chat Agents?**
> If you want interactive help in VS Code (e.g., `@architect`, `@terraform`), see the [Copilot Agents Playbook](../../../AGENTS.md).

---

## Agent Categories

### H1 Foundation - Infrastructure Layer

These agents deploy the core Azure infrastructure required by all other horizons.

| Agent | File | Purpose |
|-------|------|---------|
| Infrastructure | [infrastructure-agent.md](./h1-foundation/infrastructure-agent.md) | AKS clusters, Key Vault, ACR, Managed Identities |
| Networking | [networking-agent.md](./h1-foundation/networking-agent.md) | VNets, subnets, NSGs, Private Endpoints, DNS |
| Security | [security-agent.md](./h1-foundation/security-agent.md) | Workload Identity, RBAC, Network Policies |
| Container Registry | [container-registry-agent.md](./h1-foundation/container-registry-agent.md) | Azure Container Registry provisioning |
| Database | [database-agent.md](./h1-foundation/database-agent.md) | PostgreSQL, Redis, Cosmos DB, Azure SQL |
| Defender Cloud | [defender-cloud-agent.md](./h1-foundation/defender-cloud-agent.md) | Microsoft Defender for Cloud, compliance |
| ARO Platform | [aro-platform-agent.md](./h1-foundation/aro-platform-agent.md) | Azure Red Hat OpenShift (alternative to AKS) |
| Purview Governance | [purview-governance-agent.md](./h1-foundation/purview-governance-agent.md) | Data governance, PII classification |

### H2 Enhancement - Platform Capabilities

These agents add operational patterns and developer experience improvements.

| Agent | File | Purpose |
|-------|------|---------|
| GitOps | [gitops-agent.md](./h2-enhancement/gitops-agent.md) | ArgoCD, ApplicationSets, RBAC, notifications |
| Observability | [observability-agent.md](./h2-enhancement/observability-agent.md) | Prometheus, Grafana, Alertmanager, Loki |
| RHDH Portal | [RHDH-portal-agent.md](./h2-enhancement/rhdh-portal-agent.md) | Red Hat Developer Hub / Backstage |
| Golden Paths | [golden-paths-agent.md](./h2-enhancement/golden-paths-agent.md) | Self-service templates management |
| GitHub Runners | [GitHub-runners-agent.md](./h2-enhancement/github-runners-agent.md) | Self-hosted GitHub Actions runners |

### H3 Innovation - Advanced Features

These agents enable AI/ML capabilities and autonomous operations.

| Agent | File | Purpose |
|-------|------|---------|
| AI Foundry | [ai-foundry-agent.md](./h3-innovation/ai-foundry-agent.md) | Azure AI Foundry, models, RAG pipelines |
| MLOps Pipeline | [mlops-pipeline-agent.md](./h3-innovation/mlops-pipeline-agent.md) | Azure ML, training, model deployment |
| SRE Agent | [sre-agent-setup.md](./h3-innovation/sre-agent-setup.md) | Self-healing, auto-remediation |
| Multi-Agent | [multi-agent-setup.md](./h3-innovation/multi-agent-setup.md) | Multi-agent orchestration patterns |

### Cross-Cutting - Utilities

These agents support any horizon level and can run independently.

| Agent | File | Purpose |
|-------|------|---------|
| Validation | [validation-agent.md](./cross-cutting/validation-agent.md) | Health checks, security scans, compliance |
| Migration | [migration-agent.md](./cross-cutting/migration-agent.md) | ADO to GitHub migration |
| Rollback | [rollback-agent.md](./cross-cutting/rollback-agent.md) | Emergency rollback procedures |
| Cost Optimization | [cost-optimization-agent.md](./cross-cutting/cost-optimization-agent.md) | Cost analysis, rightsizing |
| GitHub App | [GitHub-app-agent.md](./cross-cutting/github-app-agent.md) | GitHub App setup, permissions |
| Identity Federation | [identity-federation-agent.md](./cross-cutting/identity-federation-agent.md) | Entra ID, OIDC, workload identity |

---

## Quick Start

### 1. Prerequisites

Before using any agent, ensure you have:

```bash
# Required tools
az version        # >= 2.50.0
terraform version # >= 1.5.0
kubectl version   # >= 1.28
gh --version      # >= 2.30

# MCP Servers configured (see MCP_SERVERS_GUIDE.md)
```

### 2. Deployment Sequence

Follow the recommended deployment order:

```
Phase 1: H1 Foundation (required)
├── Infrastructure Agent
├── Networking Agent
├── Security Agent
├── Container Registry Agent
└── Database Agent

Phase 2: H2 Enhancement (after H1)
├── GitOps Agent
├── Observability Agent
└── RHDH Portal Agent

Phase 3: H3 Innovation (after H2)
├── AI Foundry Agent
└── MLOps Pipeline Agent
```

See [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md) for detailed instructions.

### 3. Trigger an Agent

Agents are triggered via GitHub Issues:

1. Navigate to **Issues** → **New Issue**
2. Select the appropriate issue template
3. Fill in the configuration parameters
4. Submit the issue
5. The agent will execute automatically

---

## Documentation

| Document | Description |
|----------|-------------|
| [INDEX.md](./INDEX.md) | Complete agent inventory with search |
| [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md) | Step-by-step deployment guide |
| [MCP_SERVERS_GUIDE.md](./MCP_SERVERS_GUIDE.md) | MCP server setup instructions |
| [TERRAFORM_MODULES_REFERENCE.md](./TERRAFORM_MODULES_REFERENCE.md) | Cross-reference to Terraform modules |
| [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md) | Visual dependency map |

---

## Agent Specification Format

All agents follow a consistent specification format:

```markdown
# [Agent Name]

## Agent Identity
- Metadata (name, version, horizon)
- Model compatibility

## Capabilities
- Feature matrix with complexity levels

## MCP Servers Required
- Server configurations
- Required capabilities

## Trigger Labels
- GitHub issue labels

## Issue Template(s)
- Configuration forms

## Execution Workflow
- Mermaid diagrams
- CLI commands

## Validation Criteria
- Acceptance checklist

## Agent Communication
- Response templates
```

---

## Next Steps

1. **New to agents?** Start with the [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md) guide
2. **Looking for a specific agent?** Check the [INDEX.md](./INDEX.md)
3. **Setting up MCP servers?** See [MCP_SERVERS_GUIDE.md](./MCP_SERVERS_GUIDE.md)
4. **Understanding dependencies?** View the [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md)
5. **Terraform modules?** Check [TERRAFORM_MODULES_REFERENCE.md](./TERRAFORM_MODULES_REFERENCE.md)

---

## Related Documentation

### Agent Documentation

- [INDEX.md](./INDEX.md) - Complete agent inventory
- [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md) - Step-by-step deployment guide
- [MCP_SERVERS_GUIDE.md](./MCP_SERVERS_GUIDE.md) - MCP server setup instructions
- [TERRAFORM_MODULES_REFERENCE.md](./TERRAFORM_MODULES_REFERENCE.md) - Terraform module cross-reference
- [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md) - Visual dependency map

### Main Documentation

- [Deployment Guide](../../guides/DEPLOYMENT_GUIDE.md) - Complete deployment instructions
- [Architecture Guide](../../guides/ARCHITECTURE_GUIDE.md) - Three Horizons architecture
- [Troubleshooting Guide](../../guides/TROUBLESHOOTING_GUIDE.md) - Problem resolution
- [Module Reference](../../guides/MODULE_REFERENCE.md) - Terraform modules details

---

## Support

For questions or issues:

- **GitHub Issues:** [Create Issue](https://github.com/paulanunes85/three-horizons-accelerator-v4/issues)

---

**Version:** 4.0.0
**Last Updated:** December 2025
**Maintained by:** Microsoft LATAM Platform Engineering
