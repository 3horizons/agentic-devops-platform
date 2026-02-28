# GitHub Copilot Instructions for Three Horizons Accelerator

## Project Overview

This is the Three Horizons Accelerator v4.0.0 - an enterprise-grade platform accelerator for Azure with AI capabilities. The platform is organized into three horizons:

- **H1 Foundation**: Core infrastructure (AKS, networking, security, databases)
- **H2 Enhancement**: Platform services (ArgoCD, RHDH, observability, Golden Paths)
- **H3 Innovation**: AI capabilities (AI Foundry, agents, MLOps)

## Technology Stack

- **Infrastructure**: Terraform for Azure (AKS, networking, databases)
- **Container Platform**: Azure Kubernetes Service (AKS)
- **GitOps**: ArgoCD for continuous deployment
- **IDP**: Red Hat Developer Hub (RHDH)
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
| Agent specifications | `.github/agents/` |
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

### Deploying the platform (3 options)

**Option A — Agent-guided:**
```
@deploy Deploy the platform to dev environment
```

**Option B — Automated script:**
```bash
./scripts/deploy-full.sh --environment dev --dry-run
./scripts/deploy-full.sh --environment dev
```

**Option C — Manual:**
```bash
cd terraform
terraform init
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
```

### Running validation
```bash
./scripts/validate-prerequisites.sh
./scripts/validate-config.sh --environment dev
./scripts/validate-deployment.sh --environment dev
```

## Agent System

The platform uses 17 Copilot Chat Agents in `.github/agents/` for interactive development assistance, plus 15 skills for specialized CLI operations.

### Agent Organization
- **@deploy**: Deployment orchestration, end-to-end platform deployment
- **@architect**: System architecture, AI Foundry, multi-agent design
- **@devops**: CI/CD, GitOps, MLOps, Golden Paths, pipelines
- **@docs**: Documentation generation and maintenance
- **@onboarding**: New team member onboarding and guidance
- **@platform**: RHDH portal, platform services, developer experience
- **@reviewer**: Code review, PR analysis, quality checks
- **@security**: Security policies, scanning, compliance
- **@sre**: Reliability engineering, incident response, monitoring
- **@terraform**: Infrastructure as Code, Terraform modules
- **@test**: Test generation, validation, quality assurance
- **@azure-portal-deploy**: Azure AKS provisioning, Key Vault, PostgreSQL, ACR, Helm
- **@github-integration**: GitHub App, org discovery, GHAS, Actions, Packages, supply chain
- **@ado-integration**: Azure DevOps PAT, repos, pipelines, boards, Copilot Standalone
- **@hybrid-scenarios**: GitHub + ADO coexistence scenarios A/B/C, dual auth, hybrid templates
- **@template-engineer**: Software Template expert for RHDH, Golden Path creation, devcontainer configs
- **@context-architect**: Multi-file change planning/execution, dependency tracing, codebase context mapping

### Skills Available
Agents can use skills from `.github/skills/` including: terraform-cli, kubectl-cli, azure-cli, argocd-cli, helm-cli, github-cli, validation-scripts, and more.

### Agent Handoffs
Agents support handoffs for workflow orchestration. Key orchestration flows:
- **Deployment:** @onboarding -> @architect -> @terraform -> @deploy -> @sre
- **Security:** @reviewer -> @security -> @devops (remediate) -> @test
- **Templates:** @platform -> @template-engineer -> @devops -> @security
- **Multi-file:** Any agent -> @context-architect -> @test -> @docs
- **Hybrid:** @github-integration + @ado-integration -> @hybrid-scenarios -> @deploy

When generating code for agents:
- Follow the agent specification format in `.github/agents/`
- Include proper YAML frontmatter with `tools`, `infer`, `skills`, `handoffs`
- Define three-tier boundaries: ALWAYS / ASK FIRST / NEVER
- Reference skills for CLI operations
- Include clarifying questions before proceeding

## Golden Paths

When creating or modifying Golden Path templates:
- Follow RHDH Software Template format
- Include skeleton files
- Add comprehensive documentation
- Test scaffolding locally before registering
