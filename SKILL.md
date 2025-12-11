# Three Horizons Accelerator v4.0.0 - AI Skill

## Overview

This package provides enterprise platform engineering automation for Azure-based
Three Horizons deployments. It includes 23 AI agents, prompts, and guardrails for
deploying production-grade Kubernetes platforms with GitOps and AI capabilities.

## When to Use This Skill

Use this skill when the user asks to:

- Deploy Azure infrastructure (AKS, ARO, ACR, Key Vault)
- Setup GitOps with ArgoCD
- Configure Red Hat Developer Hub
- Deploy Azure AI Foundry
- Configure Defender for Cloud or Purview
- Setup GitHub App or Workload Identity Federation
- Migrate from Azure DevOps to GitHub
- Run platform health checks
- Create Golden Path templates

## Key Capabilities

### H1 - Foundation (8 Agents)
- `infrastructure-agent`: Create AKS cluster, networking, identities
- `networking-agent`: VNets, NSGs, private endpoints
- `security-agent`: Workload Identity, RBAC, policies
- `container-registry-agent`: ACR setup, geo-replication
- `database-agent`: PostgreSQL, Redis, Cosmos DB
- `defender-cloud-agent`: Defender for Cloud, CSPM, container scanning
- `purview-governance-agent`: Data governance, LATAM classifications
- `aro-platform-agent`: Azure Red Hat OpenShift deployment

### H2 - Enhancement (5 Agents)
- `gitops-agent`: ArgoCD deployment and configuration
- `golden-paths-agent`: Template scaffolding for RHDH
- `observability-agent`: Prometheus, Grafana, Alertmanager
- `rhdh-portal-agent`: Red Hat Developer Hub on AKS or ARO
- `github-runners-agent`: Self-hosted runners on AKS

### H3 - Innovation (4 Agents)
- `ai-foundry-agent`: Azure AI Foundry setup
- `sre-agent-setup`: Azure SRE Agent, auto-remediation
- `mlops-pipeline-agent`: Azure ML, MLflow, model deployment
- `multi-agent-setup`: AutoGen, Semantic Kernel, agent teams

### Cross-Cutting (6 Agents)
- `migration-agent`: ADO to GitHub migration
- `validation-agent`: Health checks, compliance, audits
- `rollback-agent`: Emergency rollback procedures
- `cost-optimization-agent`: FinOps analysis
- `github-app-agent`: GitHub App setup and configuration
- `identity-federation-agent`: Workload Identity Federation setup

## T-Shirt Sizing

When deploying infrastructure, ask user for sizing:

| Size | Team | Est. Cost/mo | Use Case |
|------|------|--------------|----------|
| Small | <10 devs | $2,000-3,000 | Dev/POC |
| Medium | 10-50 | $5,000-8,000 | Standard |
| Large | 50-200 | $15,000-25,000 | Enterprise |
| XLarge | 200+ | $40,000-60,000 | Critical |

## LATAM Regions

| Region | AI Support | Data Residency |
|--------|------------|----------------|
| Brazil South | Limited (GPT-4, 3.5) | LGPD compliant |
| East US 2 | Full (GPT-4o, o3-mini) | - |
| South Central US | Full | - |

**Recommended Pattern:** Brazil South (data) + East US 2 (AI via Private Link)

## Platform Options

### Developer Hub
- **AKS**: Requires OLM installation, uses Ingress
- **ARO**: OLM built-in, uses Routes

### Authentication
- **Entra ID**: For GitHub EMU enterprises
- **GitHub OAuth**: For GitHub Enterprise Cloud

## Example Interactions

**User:** "Deploy a Three Horizons platform for my team of 30 developers"
**Action:** Use Medium sizing, deploy H1 foundation, suggest H2 enhancements

**User:** "Setup our Developer Hub with GitHub authentication"
**Action:** Use GitHub OAuth configuration, deploy on selected platform

**User:** "Migrate our repos from Azure DevOps to GitHub"
**Action:** Run migration-agent with full inventory

**User:** "Configure Defender for Cloud for our subscription"
**Action:** Run defender-cloud-agent with CSPM and container scanning

## File Locations

- Agent specs: `agents/`
- Sizing profiles: `config/sizing-profiles.yaml`
- Region availability: `config/region-availability.yaml`
- Issue templates: `.github/ISSUE_TEMPLATE/`
- MCP config: `mcp-servers/mcp-config.json`
- Terraform modules: `terraform/modules/`
- Golden Paths: `golden-paths/`

## Integration Points

This skill integrates with:
- Azure CLI (az commands)
- Kubernetes (kubectl, helm)
- OpenShift CLI (oc commands)
- ArgoCD CLI
- GitHub CLI (gh)
- Terraform

## Component Summary

| Category | Count |
|----------|-------|
| Terraform Modules | 14 |
| AI Agents | 23 |
| Issue Templates | 25 |
| Golden Path Templates | 21 |
| MCP Servers | 15 |
| Scripts | 10 |

## Guardrails

Always follow:
- Use Workload Identity (no service principal keys)
- Enable GHAS for all repositories
- Configure private endpoints for PaaS services
- Use managed identities for inter-service auth
- Enable audit logging
- Follow Azure naming conventions (use naming module)
- Configure Defender for Cloud for CSPM
- Use Purview for data governance in LATAM

---

**Version:** 4.0.0
**Last Updated:** December 2025
