# CLAUDE.md — Three Horizons Implementation Accelerator

> Context file for Claude Code / Claude Agent SDK. This file provides Claude with deep understanding of the entire codebase to enable effective assistance.

## Project Identity

- **Name**: Three Horizons Implementation Accelerator
- **Version**: 4.0.0
- **License**: MIT
- **Author**: Microsoft LATAM Platform Engineering
- **Repository**: `agentic-devops-platform/`
- **Scale**: 949+ files, ~105,000 lines of production-ready code
- **Partnership**: Microsoft + GitHub + Red Hat

## What This Project Is

An enterprise-grade **Agentic DevOps Platform** that combines Infrastructure as Code (Terraform), GitOps (ArgoCD), AI Agents (GitHub Copilot), and an Internal Developer Platform (Red Hat Developer Hub) to accelerate software delivery. It follows a **Three Horizons** maturity model:

- **H1 Foundation**: Core Azure infrastructure (AKS, networking, databases, security, DR)
- **H2 Enhancement**: Platform services (ArgoCD, RHDH, observability, Golden Paths, runners)
- **H3 Innovation**: AI capabilities (Azure AI Foundry, Copilot agents, MCP servers, Developer Lightspeed)

## Technology Stack

### Infrastructure & Cloud (Azure-primary)

- **Terraform** >= 1.5.0 with AzureRM >= 3.75, AzureAD >= 2.45, AzAPI >= 1.9
- **AKS** (Kubernetes 1.29+) with Calico network policy, Workload Identity, auto-scaling
- **Azure Container Registry** (Basic/Standard/Premium by deployment mode)
- **Azure Key Vault** with RBAC, soft delete, purge protection
- **PostgreSQL Flexible Server** v16 with geo-redundant backup
- **Redis Cache** with TLS 1.2+ enforcement
- **Azure AI Foundry** with GPT-4o, GPT-4o-mini, text-embedding-3-large, AI Search, Content Safety
- **Microsoft Purview** for data governance
- **Microsoft Defender** for containers and cloud posture
- **Azure Backup Vault** for disaster recovery

### Platform & Orchestration

- **Red Hat Developer Hub (RHDH) 1.8** — Backstage-based IDP with Dynamic Plugins
- **ArgoCD 5.51.0** — GitOps with App-of-Apps pattern and sync waves
- **Helm** — Package management for all K8s deployments
- **OPA Gatekeeper** — Policy enforcement with 5 constraint templates
- **External Secrets Operator 0.9.9** — Azure Key Vault sync via Workload Identity
- **Prometheus + Grafana + Alertmanager** — Full observability stack
- **Jaeger** — Distributed tracing
- **GitHub Actions Self-Hosted Runners** on AKS (ARC)

### AI & Agents

- **18 GitHub Copilot Chat Agents** (.agent.md format) with handoff orchestration
- **14 MCP Servers** for AI-tool communication (azure, github, terraform, kubernetes, helm, docker, git, bash, filesystem, defender, purview, entra, copilot, engineering-intelligence)
- **19 Reusable Skills** for CLI operations
- **4 Chat Modes**: Architect, Reviewer, SRE, Engineering Intelligence
- **10 Reusable Prompts**: deploy-platform, create-service, review-code, generate-tests, generate-docs, deploy-service, troubleshoot-incident, collect-metrics, generate-dashboard, audit-security-posture
- **Developer Lightspeed** — AI chat in RHDH using Llama Stack + RAG

### Languages

- **HCL** (Terraform) — Infrastructure definitions
- **Go** — Terratest infrastructure tests
- **Python** 3.11+ — AI agents, automation scripts (FastAPI, Pydantic, structlog)
- **Bash** — Operational scripts (strict mode: `set -euo pipefail`)
- **YAML** — K8s manifests, Helm values, GitHub Actions, ArgoCD configs
- **Rego** — OPA policy definitions
- **JSON** — Grafana dashboards, configurations
- **Markdown** — Documentation, agent specs

## Directory Structure

```
agentic-devops-platform/
├── .github/                          # GitHub config
│   ├── agents/                       # 18 Copilot Chat agents (.agent.md)
│   ├── chatmodes/                    # 4 chat modes (.chatmode.md)
│   ├── instructions/                 # 4 code-gen instructions (terraform, kubernetes, python, engineering-intelligence)
│   ├── prompts/                      # 10 reusable prompts (.prompt.md)
│   ├── skills/                       # 19 operational skills
│   ├── workflows/                    # 10 GitHub Actions workflows
│   ├── ISSUE_TEMPLATE/               # 28 issue templates
│   └── copilot-instructions.md       # Global Copilot context
├── terraform/                        # 15 IaC modules
│   ├── main.tf                       # Root orchestration (providers, locals, module calls)
│   ├── variables.tf                  # All input variables with validation
│   ├── outputs.tf                    # All outputs
│   └── modules/                      # 15 modules (see below)
├── golden-paths/                     # RHDH Software Templates
│   ├── h1-foundation/                # 6 basic templates
│   ├── h2-enhancement/               # 9 advanced templates
│   └── h3-innovation/                # 7 AI/Agent templates
├── argocd/                           # GitOps configuration
│   ├── app-of-apps/root-application.yaml
│   ├── apps/                         # Individual ArgoCD apps
│   ├── secrets/cluster-secret-store.yaml
│   ├── sync-policies.yaml            # 5 sync presets
│   └── repo-credentials.yaml         # Multi-repo support
├── deploy/helm/                      # Helm values and K8s manifests
├── config/                           # Platform config (apm.yml, sizing-profiles.yaml, region-availability.yaml)
├── grafana/dashboards/               # 3 JSON dashboards
├── prometheus/                       # alerting-rules.yaml (50+ rules), recording-rules.yaml (40+ rules)
├── policies/                         # OPA/Rego for Terraform + Gatekeeper for K8s
├── mcp-servers/                      # MCP config (mcp-config.json) + USAGE.md
├── scripts/                          # 15+ operational scripts
├── platform/                         # Platform documentation and configuration
├── agents-templates/                 # Agent specification templates
├── new-features/                     # RHDH-specific features (AI agents, homepage, dynamic plugins)
├── tests/terraform/modules/          # 16 Go test files (Terratest)
├── docs/                             # Research, best practices, official Red Hat PDFs
└── images-logos/                     # Brand assets
```

## Terraform Modules (15)

All modules are in `terraform/modules/` and follow consistent patterns: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`.

| Module | Path | Purpose |
|--------|------|---------|
| **naming** | `modules/naming/` | Resource naming convention: `{customer}-{env}-{resource}` |
| **networking** | `modules/networking/` | VNet, subnets (AKS nodes, pods, PE, bastion, AppGW), NSGs, private DNS zones, route tables |
| **aks-cluster** | `modules/aks-cluster/` | AKS with system + user node pools, Workload Identity, Azure Policy, Defender, auto-scaling |
| **container-registry** | `modules/container-registry/` | ACR with geo-replication, AKS integration (AcrPull role) |
| **databases** | `modules/databases/` | PostgreSQL Flexible Server + Redis Cache with private endpoints |
| **security** | `modules/security/` | Key Vault (RBAC, soft delete), Managed Identities, Workload Identity Federation |
| **argocd** | `modules/argocd/` | ArgoCD via Helm with HA, SSO, RBAC, ingress |
| **observability** | `modules/observability/` | Log Analytics, Container Insights, Azure Managed Grafana, action groups |
| **external-secrets** | `modules/external-secrets/` | ESO via Helm + ClusterSecretStore linked to Key Vault |
| **github-runners** | `modules/github-runners/` | ARC (Actions Runner Controller) self-hosted runners |
| **ai-foundry** | `modules/ai-foundry/` | Cognitive Account (OpenAI), AI Search, Content Safety, model deployments |
| **purview** | `modules/purview/` | Microsoft Purview account with private endpoints |
| **defender** | `modules/defender/` | Defender for Containers, Servers, Storage, Key Vault |
| **cost-management** | `modules/cost-management/` | Budgets with alerts at 50/75/90/100% |
| **disaster-recovery** | `modules/disaster-recovery/` | Backup Vault, geo-replication, cross-region DR |

### Deployment Modes

The root `main.tf` uses a `deployment_mode` variable with three presets:

| Mode | AKS Nodes | VM Size | HA | Monitoring | AI |
|------|-----------|---------|----|-----------|----|
| **express** | 3 | Standard_D4s_v5 | No | Yes | No |
| **standard** | 5 | Standard_D4s_v5 | Yes | Yes | Yes |
| **enterprise** | 10 | Standard_D8s_v5 | Yes | Yes | Yes |

### Required Variables

```hcl
customer_name          # 3-20 lowercase alphanumeric, e.g. "contoso"
environment            # "dev" | "staging" | "prod"
azure_subscription_id  # Azure subscription
azure_tenant_id        # Azure AD tenant
admin_group_id         # Azure AD admin group
github_org             # GitHub organization
github_token           # GitHub PAT (sensitive)
```

### Feature Flags

```hcl
enable_databases           = true    # PostgreSQL + Redis
enable_container_registry  = true    # ACR
enable_argocd              = true    # GitOps
enable_external_secrets    = true    # ESO
enable_observability       = true    # Prometheus/Grafana
enable_github_runners      = false   # Self-hosted runners
enable_ai_foundry          = false   # Azure AI (H3)
enable_defender            = false   # Microsoft Defender
enable_purview             = false   # Data governance
enable_cost_management     = false   # Budget alerts
enable_disaster_recovery   = false   # DR config
```

### Module Dependency Order

```
networking → security → aks-cluster → databases
                                    → container-registry
                                    → ai-foundry
                                    → observability → argocd
                                                   → external-secrets
                                                   → github-runners
```

## Agent System

### 18 Copilot Chat Agents

Located in `.github/agents/`. Each agent uses YAML frontmatter with `tools`, `infer`, `skills`, `handoffs` and a three-tier boundary system (ALWAYS / ASK FIRST / NEVER).

| Agent | Invoke | Domain |
|-------|--------|--------|
| `@architect` | `@architect Design a microservice` | System architecture, AI Foundry, multi-agent design |
| `@platform` | `@platform Register a Golden Path` | RHDH portal, IDP, developer experience |
| `@devops` | `@devops Set up GitOps` | CI/CD, pipelines, GitOps, MLOps |
| `@sre` | `@sre Create runbook` | Observability, SLOs, incident response |
| `@terraform` | `@terraform Create AKS module` | Infrastructure as Code |
| `@security` | `@security Scan for vulnerabilities` | Compliance, policies, scanning |
| `@reviewer` | `@reviewer Review this PR` | Code review, quality gates |
| `@deploy` | `@deploy Deploy to dev` | End-to-end deployment orchestration |
| `@test` | `@test Generate tests` | Testing, validation, QA |
| `@docs` | `@docs Generate API docs` | Documentation |
| `@onboarding` | `@onboarding Set up new team` | Team onboarding guidance |
| `@template-engineer` | `@template-engineer Create template` | Golden Path / Software Template creation |
| `@context-architect` | `@context-architect Plan changes` | Multi-file change planning, dependency tracing |
| `@github-integration` | `@github-integration Setup GHAS` | GitHub App, org discovery, Actions, Packages |
| `@ado-integration` | `@ado-integration Migrate from ADO` | Azure DevOps PAT, repos, pipelines, boards |
| `@hybrid-scenarios` | `@hybrid-scenarios Scenario A` | GitHub + ADO coexistence (scenarios A/B/C) |
| `@azure-portal-deploy` | `@azure-portal-deploy Provision AKS` | Azure portal AKS, Key Vault, PostgreSQL, ACR |
| `@engineering-intelligence` | `@engineering-intelligence Collect DORA metrics` | DORA metrics, Copilot analytics, GHAS security posture, developer productivity |

### Key Orchestration Flows

```
Deployment:   @onboarding → @architect → @terraform → @deploy → @sre
Security:     @reviewer → @security → @devops (remediate) → @test
Templates:    @platform → @template-engineer → @devops → @security
Multi-file:   Any agent → @context-architect → @test → @docs
Hybrid:       @github-integration + @ado-integration → @hybrid-scenarios → @deploy
Intelligence: @engineering-intelligence → @platform (RHDH dashboard) → @sre (SLO correlation)
```

### 14 MCP Servers

Defined in `mcp-servers/mcp-config.json`. Access matrix in `mcp-servers/USAGE.md`.

**Read-only (always allowed)**: `az resource list/show`, `kubectl get`, `gh pr/issue view`, `helm list`, `terraform state list/show`

**Requires confirmation**: `terraform apply/destroy`, `kubectl apply/delete`, `helm install/upgrade/uninstall`, `az resource delete`, `az aks scale`

**Forbidden (never)**: `kubectl delete namespace production`, `terraform destroy -auto-approve`, `kubectl get secret -o yaml`, `az keyvault secret show --query value`, `az role assignment create --role Owner`

## Coding Standards

### Terraform

- Terraform >= 1.5.0, always pin provider versions
- snake_case for variables and resources
- Tag ALL resources with: `environment`, `project`, `owner`, `cost-center`
- Use Workload Identity (never service principal secrets)
- Enable private endpoints for all PaaS services
- Validate variables with `validation {}` blocks
- Document every variable with `description`

### Kubernetes / YAML

- kebab-case for names and labels
- Always set resource `requests` and `limits`
- Run containers as non-root, read-only rootfs
- Use standard labels: `app.kubernetes.io/{name,instance,version}`
- Configure liveness and readiness probes
- Apply network policies per namespace

### Python

- Python 3.11+, FastAPI for APIs, Pydantic for validation, structlog for logging
- Follow PEP 8, use Black + isort + Flake8

### Shell Scripts

- `#!/usr/bin/env bash` with `set -euo pipefail`
- Include usage instructions, validate inputs
- Use `readonly` for constants, meaningful variable names

### Commits

```
<type>(<scope>): <description>
Types: feat, fix, docs, refactor, test, chore, ci, infra
Scopes: terraform, k8s, argocd, agents, golden-paths, scripts, docs
```

### Branch Strategy

- `main` — Protected, requires PR + approval
- `feature/*`, `bugfix/*`, `hotfix/*`, `release/*`

## Key Configuration Files

| File | Purpose |
|------|---------|
| `config/apm.yml` | Agent Package Manager manifest (dependencies, instructions, prompts, agents, compilation targets for VSCode/Claude/Codex) |
| `config/sizing-profiles.yaml` | T-shirt sizing (Small/Medium/Large/XLarge) with detailed infra specs per profile |
| `config/region-availability.yaml` | Azure region matrix with Tier 1/2 support and LGPD deployment patterns |
| `.pre-commit-config.yaml` | 14 pre-commit hooks (terraform, shell, K8s, YAML, markdown, secrets) |
| `.tflint.hcl` | TFLint rules (Azure-specific) |
| `.yamllint.yml` | YAML lint rules (200 char max, comments allowed) |
| `.markdownlint.json` | Markdown lint rules (proper names: Kubernetes, Azure, RHDH) |
| `.secrets.baseline` | detect-secrets baseline with 13+ detectors |
| `.terraform-docs.yml` | Auto-generated Terraform module documentation |
| `CODEOWNERS` | Code ownership (@platform-team, @infra-team, @security-team, @devops-team, @ai-team, @docs-team) |

## ArgoCD GitOps

### App-of-Apps Pattern

Root Application in `argocd/app-of-apps/root-application.yaml` manages all child apps. Sync waves ensure correct deployment order:

1. cert-manager, external-dns (Wave 1)
2. ingress-nginx (Wave 2)
3. prometheus, jaeger (Wave 3)
4. Red Hat Developer Hub (Wave 4)
5. Team namespaces, applications (Wave 5+)

### Sync Policy Presets (argocd/sync-policies.yaml)

| Preset | Auto-Sync | Self-Heal | Prune | Use |
|--------|-----------|-----------|-------|-----|
| `dev-auto-sync` | Yes | Yes | Yes | Dev environments |
| `staging-auto-sync` | Yes | Yes | Yes | Staging |
| `prod-manual-sync` | No | No | No | Production (manual approval) |
| `infra-careful-sync` | Yes | Yes | No | Critical infrastructure |
| `preview-aggressive-sync` | Yes | Yes | Yes | Ephemeral/preview environments |

## Observability

### Prometheus Rules

- **alerting-rules.yaml**: 50+ alerts across infrastructure (CPU, memory, disk, nodes), applications (error rate, latency), AI agents (token usage, LLM latency), GitOps (sync failures), security (cert expiry, login failures), SLOs (burn rates at 5m/1h/24h/30d windows)
- **recording-rules.yaml**: 40+ pre-calculated metrics for cluster utilization, app RED metrics (p50/p90/p99), SLO availability, GitOps success rates, AI agent performance

### Grafana Dashboards (3)

- `platform-overview.json` — Cluster health, node status, pod distribution, resource usage
- `cost-management.json` — Budget utilization, cost trends, resource costs by tag
- `golden-path-application.json` — App RED metrics, latency, error rates, deployment frequency

### ServiceMonitors

Configured for: RHDH (:7007/metrics), ArgoCD (server, repo-server, controller), ingress-nginx (:10254), cert-manager (:9402), external-secrets (:8080)

## Policies

### Terraform Policies (OPA/Rego)

In `policies/terraform/azure.rego`, enforced via Conftest in CI:

- Required tags (environment, project, owner, cost-center)
- TLS 1.2 enforcement on storage and PostgreSQL
- Encryption at rest for storage and Key Vault
- No public access on Storage, Key Vault, AKS
- HTTPS-only for storage accounts
- AKS must have RBAC, Managed Identity, Azure Policy, Defender
- Geo-redundant backups for PostgreSQL
- Warns on expensive VM sizes (Standard_E, Standard_M series)

### Kubernetes Policies (Gatekeeper)

5 ConstraintTemplates in `policies/kubernetes/constraint-templates/`:

- **K8sRequiredLabels** — Mandatory labels with regex validation
- **K8sContainerResources** — CPU/memory requests and limits required
- **K8sDenyPrivileged** — Block privileged containers
- **K8sRequireNonRoot** — Enforce non-root execution
- **K8sAllowedRegistries** — Restrict to approved registries only

## Tests

### Terratest (Go)

16 test files in `tests/terraform/modules/`, one per module plus `integration_test.go`. Each test:

1. Runs `t.Parallel()`
2. Defines Terraform variables
3. Calls `terraform.Init()` → `terraform.Validate()` → `terraform.Plan()`
4. Asserts plan outputs (resource names, configurations, properties)

### CI Validation

9 GitHub Actions workflows in `.github/workflows/`:

| Workflow | Trigger |
|----------|---------|
| `ci-cd.yml` | Push/PR to main — full pipeline |
| `ci.yml` | Push/PR — lint, test, validate |
| `cd.yml` | Merge to main — deploy staging/prod |
| `terraform-test.yml` | Changes in terraform/ — Terratest |
| `validate-agents.yml` | Changes in agents/ — agent spec validation |
| `release.yml` | Tag creation — release automation |
| `agent-router.yml` | Issue creation — route to correct agent |
| `issue-ops.yml` | Issue events — automation |
| `branch-protection.yml` | Scheduled — enforce branch rules |

## Scripts

### Deployment

- `scripts/deploy-full.sh` — End-to-end: `--environment dev --dry-run`
- `scripts/platform-bootstrap.sh` — Platform setup (RHDH, ArgoCD, monitoring)
- `scripts/bootstrap.sh` — H1 infrastructure setup, `--register-templates`

### Validation

- `scripts/validate-prerequisites.sh` — Check CLIs (az >= 2.50, terraform >= 1.5, kubectl >= 1.28, helm >= 3.12, gh >= 2.30)
- `scripts/validate-config.sh` — Config files (tfvars, sizing, regions)
- `scripts/validate-deployment.sh` — Post-deploy health (pods, services, endpoints)
- `scripts/validate-agents.sh` — Agent specs (YAML frontmatter, boundaries, handoffs)
- `scripts/validate-docs.sh` — Documentation (links, formatting, completeness)
- `scripts/validate-substitutions.sh` — Template substitution validation

### Setup

- `scripts/setup-github-app.sh` — GitHub App for RHDH/ArgoCD auth
- `scripts/setup-identity-federation.sh` — OIDC Workload Identity Federation
- `scripts/setup-pre-commit.sh` — Install pre-commit hooks (`--install-tools` for full setup)
- `scripts/setup-branch-protection.sh` — GitHub branch rules
- `scripts/setup-terraform-backend.sh` — Azure Storage Account for remote state
- `scripts/setup-portal.sh` — RHDH portal setup and configuration

### Operations

- `scripts/migration/ado-to-github-migration.sh` — ADO → GitHub migration in 6 phases

## Golden Paths (23 RHDH Templates)

### H1 Foundation (6)

basic-cicd, security-baseline, documentation-site, web-application, new-microservice, infrastructure-provisioning

### H2 Enhancement (9)

microservice (full), api-microservice, event-driven-microservice, data-pipeline, batch-job, api-gateway, gitops-deployment, ado-to-github-migration (6-phase), reusable-workflows

### H3 Innovation (8)

foundry-agent, sre-agent-integration, mlops-pipeline, multi-agent-system, copilot-extension, rag-application, ai-evaluation-pipeline, engineering-intelligence-dashboard

## Security Model

### Authentication

- **Workload Identity** for all AKS workloads (no static secrets)
- **Managed Identity** for all Azure services
- **OIDC Federation** for GitHub Actions
- **Azure AD SSO** for RHDH, ArgoCD, Grafana
- **GitHub OAuth** for RHDH authentication

### Network

- Private endpoints for ALL PaaS services (Key Vault, PostgreSQL, Redis, ACR, AI Search, OpenAI)
- NSGs with deny-by-default
- VNet isolation with dedicated subnets
- No public access on any PaaS service in standard/enterprise mode

### Container Runtime

- Non-root execution enforced via Gatekeeper
- No privilege escalation
- Read-only root filesystem
- Approved container registries only
- Image scanning via Trivy

### Secrets

- Azure Key Vault as single source of truth
- External Secrets Operator syncs to K8s Secrets
- detect-secrets + gitleaks in pre-commit and CI
- Never store secrets in code, env vars, or Git

### Compliance

- **LGPD**: Primary region brazilsouth
- **SOC 2**: Audit trails, access controls, monitoring
- **PCI-DSS**: Network segmentation, encryption
- **CIS Benchmarks**: Azure + Kubernetes hardening

## RHDH (Red Hat Developer Hub)

### Key Differences from Backstage OSS

- **Dynamic Plugins**: Enable/disable via YAML, no rebuild needed
- **Built-in RBAC**: Admin, Developer, Viewer roles with CSV policies
- **Developer Lightspeed**: Native AI chat with Llama Stack + RAG + BYOM support
- **Enterprise Support**: Red Hat commercial backing

### New Features (in `new-features/`)

- `configs/` — Dynamic plugin configurations, RBAC policies, Helm values
- `foundry/` — Python-based AI agents for RHDH
- `homepage/` — Customized RHDH homepage with quick actions, links, status widgets

## Common Development Tasks

### Deploy the platform

```bash
# Option A: Agent-guided
@deploy Deploy the platform to dev environment

# Option B: Automated
./scripts/deploy-full.sh --environment dev --dry-run
./scripts/deploy-full.sh --environment dev

# Option C: Manual Terraform
cd terraform && terraform init
terraform plan -var-file=environments/dev.tfvars -out=tfplan
terraform apply tfplan
```

### Validate prerequisites

```bash
./scripts/validate-prerequisites.sh
```

### Run pre-commit hooks

```bash
pre-commit run --all-files          # All hooks
pre-commit run terraform_fmt --all-files  # Specific hook
```

### Run Terraform tests

```bash
cd tests/terraform && go test -v ./modules/...
```

### Set up the RHDH portal

```bash
./scripts/setup-portal.sh
```

### Register Golden Path templates in RHDH

```bash
./scripts/bootstrap.sh --register-templates
```

## Important Notes for Claude

1. **APM compilation targets**: The `config/apm.yml` explicitly lists `CLAUDE.md` and `.claude/commands/` and `.claude/skills/` as Claude compilation targets
2. **Deployment order matters**: Terraform modules have strict dependency chains (networking → security → AKS → everything else)
3. **Feature flags control scope**: Most modules are behind `enable_*` variables — don't assume everything is deployed
4. **Three deployment modes**: express (minimal), standard (production), enterprise (HA/multi-zone) — affects sizing, HA, and which modules are enabled
5. **Security is non-negotiable**: No public access, no static secrets, Workload Identity everywhere, TLS 1.2+ always
6. **Agent handoffs are key**: The 17 agents are designed to collaborate — understand the orchestration flows before suggesting changes
7. **Golden Paths are RHDH Software Templates**: They follow Backstage template format with `template.yaml`, `skeleton/`, and parameters
8. **Observability is comprehensive**: 50+ alert rules, 40+ recording rules, 3 dashboards — changes should maintain this coverage
9. **Policy as Code is enforced**: OPA policies for Terraform (Conftest in CI) and Gatekeeper constraints for K8s runtime — all code must comply
10. **Brazil-first**: Default region is `brazilsouth` for LGPD compliance, AI Foundry uses `eastus2` for model availability
