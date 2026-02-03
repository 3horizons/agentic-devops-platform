# GitHub Copilot Instructions for Three Horizons Accelerator

## Project Overview

This is the Three Horizons Accelerator v4.0.0 - an enterprise-grade platform accelerator for Azure with AI capabilities. The platform is organized into three horizons:

- **H1 Foundation**: Core infrastructure (AKS/ARO, networking, security, databases)
- **H2 Enhancement**: Platform services (ArgoCD, RHDH, observability, Golden Paths)
- **H3 Innovation**: AI capabilities (AI Foundry, agents, MLOps)

## Technology Stack

- **Infrastructure**: Terraform for Azure (AKS, ARO, networking, databases)
- **Container Platform**: Azure Kubernetes Service (AKS) or Azure Red Hat OpenShift (ARO)
- **GitOps**: ArgoCD for continuous deployment
- **IDP**: Red Hat Developer Hub (Backstage-based)
- **Observability**: Prometheus, Grafana, Alertmanager, Loki
- **AI**: Azure AI Foundry, OpenAI models

## Code Standards

### Terraform
- Use Terraform 1.5+
- Always specify provider versions
- Use modules for reusable components
- Tag all resources with: environment, project, owner, cost-center
- Use Workload Identity (never service principal secrets)
- Enable private endpoints for all PaaS services

### Kubernetes
- Use Kustomize for environment overlays
- Always set resource limits and requests
- Run containers as non-root
- Configure liveness and readiness probes
- Apply network policies
- Use standard Kubernetes labels (app.kubernetes.io/*)

### Python
- Use Python 3.11+
- Use FastAPI for APIs
- Use Pydantic for validation
- Use structlog for logging
- Follow PEP 8 style guidelines

### Shell Scripts
- Use bash with strict mode (set -euo pipefail)
- Include usage instructions
- Validate inputs
- Use meaningful variable names

## File Locations

| Component | Location |
|-----------|----------|
| Terraform modules | `terraform/modules/` |
| Environment configs | `terraform/environments/` |
| Kubernetes manifests | `deploy/kubernetes/` |
| Helm values | `deploy/helm/` |
| Golden Path templates | `golden-paths/` |
| Agent specifications | `agents/` |
| Agent skills | `.github/skills/` |
| Automation scripts | `scripts/` |
| Documentation | `docs/` |
| Prompt files | `.github/prompts/` |
| Instructions | `.github/instructions/` |

## Security Requirements

1. **Authentication**: Always use Workload Identity or Managed Identity
2. **Secrets**: Store in Azure Key Vault, never in code
3. **Network**: Use private endpoints, configure NSGs
4. **Scanning**: Run security scans in CI/CD (Trivy, tfsec, gitleaks)
5. **RBAC**: Follow least privilege principle

## Naming Conventions

- Resources: `{project}-{environment}-{resource}-{region}`
- Terraform: snake_case for variables, resources
- Kubernetes: kebab-case for names, labels
- Files: kebab-case for filenames

## Common Tasks

### Creating a new module
```bash
./scripts/create-module.sh <module-name>
```

### Deploying infrastructure
```bash
cd terraform
terraform init
terraform plan -var-file=environments/dev.tfvars
terraform apply
```

### Running validation
```bash
./scripts/validate-deployment.sh --environment dev
```

## Agent System

The platform uses 23 AI agents organized by horizon for deployment orchestration, plus 17 skills for specialized CLI operations. There are also 16 Terraform modules, 22 Golden Path templates, and 28 Issue templates.

### Agent Organization
- **H1 Foundation**: infrastructure, networking, security, database, container-registry, defender-cloud, aro-platform, purview-governance
- **H2 Enhancement**: gitops, observability, rhdh-portal, golden-paths, github-runners
- **H3 Innovation**: ai-foundry, mlops-pipeline, sre-agent, multi-agent
- **Cross-Cutting**: validation, migration, rollback, cost-optimization, github-app, identity-federation

### Skills Available
Agents can use skills from `.github/skills/` including: terraform-cli, kubectl-cli, azure-cli, argocd-cli, helm-cli, github-cli, oc-cli, validation-scripts, and more.

### Agent Handoffs
Agents support handoffs for workflow orchestration. Example: @infrastructure -> @networking -> @security -> @validation

When generating code for agents:
- Follow the agent specification format in `agents/`
- Include proper YAML frontmatter with `tools`, `infer`, `skills`, `handoffs`
- Define three-tier boundaries: ALWAYS / ASK FIRST / NEVER
- Reference skills for CLI operations
- Include clarifying questions before proceeding

## Golden Paths

When creating or modifying Golden Path templates:
- Follow Backstage template format
- Include skeleton files
- Add comprehensive documentation
- Test scaffolding locally before registering
