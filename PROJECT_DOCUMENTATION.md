# Three Horizons Implementation Accelerator — Complete Project Documentation

> **Agentic DevOps Platform with Red Hat Developer Hub**
> Version: 4.0.0 | License: MIT | Last Updated: 2026-02-28

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Three Horizons Architecture](#2-three-horizons-architecture)
3. [Complete Technology Stack](#3-complete-technology-stack)
4. [Functional Requirements](#4-functional-requirements)
5. [Non-Functional Requirements](#5-non-functional-requirements)
6. [User Stories](#6-user-stories)
7. [Repository Structure](#7-repository-structure)
8. [Terraform Modules (Infrastructure as Code)](#8-terraform-modules-infrastructure-as-code)
9. [Golden Paths (RHDH Templates)](#9-golden-paths-rhdh-templates)
10. [AI Agent System](#10-ai-agent-system)
11. [MCP Servers (Model Context Protocol)](#11-mcp-servers-model-context-protocol)
12. [GitOps with ArgoCD](#12-gitops-with-argocd)
13. [Observability and Monitoring](#13-observability-and-monitoring)
14. [Security and Compliance](#14-security-and-compliance)
15. [Policies (OPA/Gatekeeper)](#15-policies-opagatekeeper)
16. [CI/CD and Automation](#16-cicd-and-automation)
17. [Configuration](#17-configuration)
18. [Operational Scripts](#18-operational-scripts)
19. [Tests](#19-tests)
20. [Multi-Cloud Deployment](#20-multi-cloud-deployment)
21. [RHDH — Red Hat Developer Hub](#21-rhdh--red-hat-developer-hub)
22. [Metrics and KPIs](#22-metrics-and-kpis)
23. [Version History](#23-version-history)
24. [References and Links](#24-references-and-links)

---

## 1. Project Overview

The **Three Horizons Implementation Accelerator** is an enterprise-grade Agentic DevOps Platform that combines **Infrastructure as Code**, **GitOps**, **AI Agents**, and an **Internal Developer Platform (IDP)** to accelerate software delivery across large organizations.

### Project Numbers

| Metric | Value |
|--------|-------|
| Total files | 949+ |
| Lines of code | ~105,000 |
| Terraform modules | 15 |
| AI Agents (GitHub Copilot) | 17 |
| Golden Path Templates | 22 (H1: 6, H2: 9, H3: 7) |
| MCP Servers | 13 |
| GitHub Workflows | 9 |
| Issue Templates | 27 |
| Reusable Skills | 15 |
| Prometheus Alert Rules | 50+ |
| Recording Rules | 40+ |
| Grafana Dashboards | 3 |
| Go Tests (Terratest) | 16 files |
| OPA/Rego Policies | 10+ |
| Gatekeeper Constraint Templates | 5 |

### Problem Statement

Enterprise organizations face tool fragmentation, lack of standardization, slow delivery cycles, and difficulty scaling DevOps practices. This platform provides a pre-configured accelerator that spans from base infrastructure to AI-powered development across three maturity horizons.

### Value Proposition

- **70% reduction in onboarding time** for new teams
- **Standardization via Golden Paths** guiding developers along the happy path
- **AI-Assisted Operations** with 17 specialized agents and MCP servers
- **Automated compliance** via Policy as Code (OPA + Gatekeeper)
- **Multi-cloud ready** with Azure as primary, support for AWS, GCP, and On-Premise

---

## 2. Three Horizons Architecture

The project follows the **Three Horizons of Innovation** model, dividing the platform into three maturity phases:

### H1 — Foundation (Horizon 1: Base)

Core infrastructure and fundamental services.

- **AKS Cluster** — Managed Kubernetes on Azure
- **Networking** — VNet, Subnets, NSGs, Private Endpoints
- **Container Registry** — ACR (Azure Container Registry)
- **Databases** — PostgreSQL Flexible Server + Redis Cache
- **Security** — Key Vault, Managed Identity, RBAC
- **Naming Convention** — Standardized naming for all resources
- **Disaster Recovery** — Backup Vault, geo-redundant replication

### H2 — Enhancement (Horizon 2: Evolution)

Development platform and automation.

- **Red Hat Developer Hub (RHDH)** — Developer portal with Backstage
- **ArgoCD** — GitOps engine for deployments
- **Golden Path Templates** — Standardized templates for service creation
- **Observability Stack** — Prometheus + Grafana + Alertmanager
- **External Secrets** — Integration with Azure Key Vault
- **GitHub Runners** — Self-hosted runners for CI/CD
- **OPA Gatekeeper** — Policy enforcement on the cluster
- **API Gateway** — API management with rate limiting

### H3 — Innovation (Horizon 3: Innovation)

AI, intelligent automation, and developer experience.

- **AI Foundry** — Azure AI with GPT-4o and embeddings
- **Developer Lightspeed** — AI chat integrated into RHDH (Llama Stack + RAG)
- **GitHub Copilot Agents** — 17 specialized agents
- **MCP Servers** — 13 context servers for AI
- **Microsoft Purview** — Data governance and cataloging
- **Cost Management** — Cost optimization with budgets and alerts
- **Microsoft Defender** — Advanced security for containers and cloud

---

## 3. Complete Technology Stack

### Infrastructure & Cloud

| Technology | Usage | Version/Details |
|------------|-------|-----------------|
| **Microsoft Azure** | Primary cloud provider | Regions: brazilsouth, eastus2, southcentralus |
| **Terraform** | Infrastructure as Code | >= 1.5.0 with AzureRM >= 3.75.0 |
| **Azure Kubernetes Service (AKS)** | Container orchestration | Kubernetes 1.29+ |
| **Azure Container Registry (ACR)** | Image registry | Basic/Standard/Premium by deployment mode |
| **Azure Key Vault** | Secrets management | RBAC, soft delete, purge protection |
| **Azure PostgreSQL Flexible** | Relational database | v16 with geo-redundant backup |
| **Azure Redis Cache** | Distributed cache | TLS 1.2+ enforcement |
| **Azure AI Foundry** | AI services | GPT-4o, GPT-4o-mini, text-embedding-3-large |
| **Azure Virtual Network** | Networking | /16 with dedicated subnets |
| **Azure Backup Vault** | Disaster Recovery | Geo-redundant |
| **Microsoft Purview** | Data Governance | Cataloging and classification |
| **Microsoft Defender for Cloud** | Security | Containers + Cloud posture |

### Platform & Orchestration

| Technology | Usage |
|------------|-------|
| **Red Hat Developer Hub (RHDH) 1.8** | Internal Developer Platform (Backstage enterprise) |
| **ArgoCD 5.51.0** | GitOps continuous deployment |
| **Helm** | Package manager for Kubernetes |
| **OPA Gatekeeper** | Policy enforcement engine |
| **External Secrets Operator 0.9.9** | Secrets synchronization |
| **cert-manager** | TLS certificate management |
| **ingress-nginx** | Ingress controller |
| **external-dns** | DNS automation |
| **Prometheus** | Monitoring and metrics |
| **Grafana** | Visualization and dashboards |
| **Alertmanager** | Alert management |
| **Jaeger** | Distributed tracing |

### AI & Agents

| Technology | Usage |
|------------|-------|
| **GitHub Copilot** | AI code assistant |
| **GitHub Copilot Agents** | 17 specialized agents (.agent.md) |
| **Model Context Protocol (MCP)** | AI-to-tools communication protocol |
| **Azure AI Foundry** | AI model backend |
| **Developer Lightspeed** | AI chat in RHDH (Llama Stack + RAG) |
| **Llama Stack** | LLM inference server |
| **Python AI SDK** | Azure AI Foundry SDK |

### CI/CD & DevOps

| Technology | Usage |
|------------|-------|
| **GitHub Actions** | CI/CD pipelines |
| **GitHub Self-Hosted Runners** | Runners on AKS (ARC) |
| **Pre-commit hooks** | Code quality gates (14 hooks) |
| **Terratest (Go)** | Infrastructure tests |
| **tflint** | Terraform linting |
| **tfsec** | Terraform security scanning |
| **ShellCheck** | Shell script linting |
| **yamllint** | YAML linting |
| **markdownlint** | Markdown linting |
| **detect-secrets** | Secret detection in code |
| **kubeconform** | K8s manifest validation |
| **Conftest** | Policy testing with OPA |
| **Gitleaks** | Secret scanning |
| **Trivy** | Container vulnerability scanning |

### Languages & Frameworks

| Language | Usage |
|----------|-------|
| **HCL (Terraform)** | Infrastructure definitions |
| **Go** | Infrastructure tests (Terratest) |
| **Python 3.11+** | AI agents, automation scripts (FastAPI, Pydantic, structlog) |
| **Bash/Shell** | Operational scripts (strict mode: `set -euo pipefail`) |
| **YAML** | K8s configs, Helm, ArgoCD, GitHub Actions |
| **Rego** | OPA policies |
| **JSON** | Grafana dashboards, configurations |
| **Markdown** | Documentation, agent specs |

---

## 4. Functional Requirements

### RF-001: Infrastructure Provisioning

- **RF-001.1** — The system MUST provision an AKS cluster with configurable node pools (system + user) via Terraform
- **RF-001.2** — The system MUST create a VNet with isolated subnets for AKS, databases, private endpoints, and services
- **RF-001.3** — The system MUST configure NSGs (Network Security Groups) with security rules per subnet
- **RF-001.4** — The system MUST provision an Azure Container Registry (ACR) with geo-replication
- **RF-001.5** — The system MUST create an Azure Key Vault with soft delete, purge protection, and RBAC
- **RF-001.6** — The system MUST provision PostgreSQL Flexible Server with high availability and geo-redundant backup
- **RF-001.7** — The system MUST provision Redis Cache with TLS 1.2+ enforcement
- **RF-001.8** — The system MUST follow a standardized naming convention for all Azure resources

### RF-002: GitOps and Continuous Deployment

- **RF-002.1** — The system MUST implement ArgoCD as the GitOps engine with the App-of-Apps pattern
- **RF-002.2** — The system MUST support differentiated sync policies per environment (dev: auto-sync, staging: auto-sync, prod: manual)
- **RF-002.3** — The system MUST implement sync waves to ensure deployment order (cert-manager → ingress → monitoring → RHDH → apps)
- **RF-002.4** — The system MUST integrate External Secrets Operator with Azure Key Vault via Workload Identity
- **RF-002.5** — The system MUST support multiple Git repositories (GitHub HTTPS/SSH, Azure DevOps, Helm repos)
- **RF-002.6** — The system MUST configure RBAC in ArgoCD with SSO integration via Dex

### RF-003: Internal Developer Platform (IDP)

- **RF-003.1** — The system MUST deploy Red Hat Developer Hub (RHDH) as the developer portal
- **RF-003.2** — The system MUST provide Golden Path templates for standardized service creation
- **RF-003.3** — The system MUST support Dynamic Plugins via YAML (no rebuild required)
- **RF-003.4** — The system MUST implement TechDocs for integrated technical documentation
- **RF-003.5** — The system MUST configure a customized homepage with links, quick actions, and widgets
- **RF-003.6** — The system MUST implement RBAC in RHDH with Admin, Developer, and Viewer roles
- **RF-003.7** — The system MUST support authentication via GitHub OAuth

### RF-004: Golden Path Templates

- **RF-004.1** — The system MUST provide a full microservice template (API, DB, events, observability, CI/CD)
- **RF-004.2** — The system MUST provide an API microservice template with OpenAPI, validation, and error handling
- **RF-004.3** — The system MUST provide an event-driven microservice template with Event Hubs/Service Bus
- **RF-004.4** — The system MUST provide a data pipeline template with ETL and quality checks
- **RF-004.5** — The system MUST provide a batch job template with CronJob and monitoring
- **RF-004.6** — The system MUST provide an API Gateway template with rate limiting and auth
- **RF-004.7** — The system MUST provide a GitOps deployment template with ArgoCD
- **RF-004.8** — The system MUST provide an ADO → GitHub migration template (6 phases)
- **RF-004.9** — The system MUST provide a reusable GitHub Actions workflows template

### RF-005: Observability

- **RF-005.1** — The system MUST implement Prometheus for metrics collection
- **RF-005.2** — The system MUST implement Grafana with 3 pre-configured dashboards (Platform Overview, Cost Management, Golden Path Application)
- **RF-005.3** — The system MUST implement 50+ alert rules covering infrastructure, applications, AI agents, GitOps, security, and SLA
- **RF-005.4** — The system MUST implement 40+ recording rules for aggregated metrics
- **RF-005.5** — The system MUST configure ServiceMonitors for RHDH, ArgoCD, ingress-nginx, cert-manager, and external-secrets
- **RF-005.6** — The system MUST implement Alertmanager with configurable notifications
- **RF-005.7** — The system MUST support SLO metrics with burn rates across 5m, 1h, 24h, and 30d windows

### RF-006: AI and Intelligent Agents

- **RF-006.1** — The system MUST provision Azure AI Foundry with GPT-4o / GPT-4o-mini models and embeddings
- **RF-006.2** — The system MUST provide 17 specialized GitHub Copilot agents
- **RF-006.3** — The system MUST configure 13 MCP servers for AI-to-tool communication
- **RF-006.4** — The system MUST support Developer Lightspeed in RHDH for AI chat
- **RF-006.5** — The system MUST implement BYOM (Bring Your Own Model) with Azure OpenAI, Ollama, and vLLM support
- **RF-006.6** — The system MUST support agent-to-agent handoffs with shared context
- **RF-006.7** — The system MUST implement 15 reusable skills for agents

### RF-007: Security

- **RF-007.1** — The system MUST implement Managed Identity / Workload Identity for secret-less authentication
- **RF-007.2** — The system MUST apply Network Policies isolating namespaces
- **RF-007.3** — The system MUST implement OPA Gatekeeper with 5 constraint templates
- **RF-007.4** — The system MUST integrate Microsoft Defender for Containers and Cloud
- **RF-007.5** — The system MUST configure private endpoints for all PaaS services
- **RF-007.6** — The system MUST implement secret scanning with detect-secrets and gitleaks
- **RF-007.7** — The system MUST enforce TLS 1.2+ across all services

### RF-008: Automation and Scripts

- **RF-008.1** — The system MUST provide a full deployment script (`deploy-full.sh`)
- **RF-008.2** — The system MUST provide validation scripts (prerequisites, config, deployment, agents, docs, substitutions)
- **RF-008.3** — The system MUST provide setup scripts (GitHub App, Identity Federation, Pre-commit, Branch Protection, Terraform Backend, Portal)
- **RF-008.4** — The system MUST provide Python automation scripts (TechDocs, skeleton generation, template updates)
- **RF-008.5** — The system MUST provide an ADO → GitHub migration script

### RF-009: Cost Management

- **RF-009.1** — The system MUST implement budgets with alerts at 50%, 75%, 90%, and 100% of budget
- **RF-009.2** — The system MUST provide a Grafana cost dashboard
- **RF-009.3** — The system MUST implement mandatory resource tagging (environment, project, owner, cost-center)
- **RF-009.4** — The system MUST alert on expensive VM sizes

---

## 5. Non-Functional Requirements

### RNF-001: Availability

- **RNF-001.1** — The platform MUST maintain 99.9% SLA availability for core services (AKS, RHDH, ArgoCD)
- **RNF-001.2** — SLO burn rate MUST be monitored across 5m, 1h, 24h, and 30d windows
- **RNF-001.3** — Automatic failover MUST be configured for PostgreSQL with geo-redundancy

### RNF-002: Performance

- **RNF-002.1** — API latency MUST be < 500ms at p99 (alerts at > 1s)
- **RNF-002.2** — RHDH MUST respond in < 5s for catalog operations
- **RNF-002.3** — AI Foundry alerts MUST trigger when latency > 5s
- **RNF-002.4** — Recording rules MUST pre-calculate latency percentiles (p50, p90, p99)

### RNF-003: Scalability

- **RNF-003.1** — AKS MUST support node pool auto-scaling (min 2 → configurable max)
- **RNF-003.2** — The system MUST support 4 sizing profiles: Small (≤10 devs), Medium (10-50 devs), Large (50-200 devs), XLarge (200+ devs)
- **RNF-003.3** — ACR MUST support geo-replication across multiple regions

### RNF-004: Security

- **RNF-004.1** — All data in transit MUST use TLS 1.2+
- **RNF-004.2** — All data at rest MUST be encrypted (AES-256)
- **RNF-004.3** — No PaaS service MUST have public access enabled (mandatory private endpoints)
- **RNF-004.4** — Containers MUST run as non-root with no privilege escalation
- **RNF-004.5** — Images MUST be restricted to approved registries
- **RNF-004.6** — RBAC MUST be enabled on AKS, RHDH, ArgoCD, and Key Vault

### RNF-005: Compliance

- **RNF-005.1** — The platform MUST support LGPD compliance (data in Brazil: brazilsouth)
- **RNF-005.2** — The platform MUST support SOC 2 audits
- **RNF-005.3** — The platform MUST support PCI-DSS and CIS Benchmarks
- **RNF-005.4** — All policies MUST be versioned and auditable via Git

### RNF-006: Observability

- **RNF-006.1** — 100% of core services MUST have ServiceMonitors configured
- **RNF-006.2** — Alerts MUST have classified severity (critical, warning, info)
- **RNF-006.3** — Dashboards MUST be available for infrastructure, costs, and applications
- **RNF-006.4** — AI agent metrics MUST include invocation, latency, tokens, and error rate

### RNF-007: Maintainability

- **RNF-007.1** — All Terraform code MUST pass tflint, tfsec, and Conftest
- **RNF-007.2** — Documentation MUST be auto-generated via terraform-docs
- **RNF-007.3** — Pre-commit hooks MUST validate Terraform, Shell, YAML, Markdown, Kubernetes, and Secrets
- **RNF-007.4** — Agent specs MUST be validatable via `validate-agents.sh`

### RNF-008: Portability

- **RNF-008.1** — The architecture MUST support deployment on Azure (primary), AWS, GCP, and On-Premise
- **RNF-008.2** — Terraform modules MUST be independent and reusable
- **RNF-008.3** — Golden Paths MUST be cloud-agnostic when possible

### RNF-009: Disaster Recovery

- **RNF-009.1** — RPO (Recovery Point Objective) MUST be ≤ 1 hour for critical data
- **RNF-009.2** — RTO (Recovery Time Objective) MUST be ≤ 4 hours for full restoration
- **RNF-009.3** — Backups MUST be geo-redundant with configurable retention
- **RNF-009.4** — DR runbooks MUST be documented and tested

---

## 6. User Stories

### Epic 1: Infrastructure Provisioning

**US-001** — As a **Platform Engineer**, I want to provision all Azure infrastructure with a single `terraform apply`, so I can have a complete environment in less than 1 hour.

**US-002** — As a **Platform Engineer**, I want all resources to follow a standardized naming convention (`{customer}-{env}-{resource}`), so that identification and governance are easier.

**US-003** — As an **SRE**, I want the AKS cluster to have auto-scaling configured with sizing profiles (S/M/L/XL), so it can serve different team scales without manual reconfiguration.

**US-004** — As a **Security Engineer**, I want all PaaS services to use private endpoints, so no data traverses the public internet.

**US-005** — As a **Platform Engineer**, I want the naming system to generate consistent names for all resources, so I can maintain organizational standards across multiple environments.

### Epic 2: GitOps and Deployments

**US-006** — As a **DevOps Engineer**, I want all applications deployed via ArgoCD with Git as the source of truth, so I have auditability and easy rollback.

**US-007** — As a **DevOps Engineer**, I want differentiated sync policies per environment (dev=auto, prod=manual), so I have speed in dev without compromising production security.

**US-008** — As a **DevOps Engineer**, I want sync waves to ensure base infrastructure (cert-manager, ingress) is deployed before applications, to avoid dependency failures.

**US-009** — As a **DevOps Engineer**, I want secrets to be automatically synced from Azure Key Vault via External Secrets Operator, so secrets are never stored in Git repositories.

### Epic 3: Developer Experience

**US-010** — As a **Developer**, I want to access a portal (RHDH) where I can create a new microservice from a standardized template, so I can start developing in minutes instead of days.

**US-011** — As a **Developer**, I want to choose between different Golden Paths (microservice, API, event-driven, data pipeline, batch job), to use the correct architectural pattern for my use case.

**US-012** — As a **Developer**, I want templates to already include CI/CD, observability, tests, and documentation, so I don't need to configure each one manually.

**US-013** — As a **Developer**, I want an AI assistant (Developer Lightspeed) integrated into the portal, to help me solve problems and generate code with my project's context.

**US-014** — As a **Tech Lead**, I want to view the complete catalog of services, APIs, and documentation in RHDH, to have visibility into all platform components.

**US-015** — As a **Developer**, I want to use reusable GitHub Actions workflow templates, to avoid duplicating pipelines across projects.

### Epic 4: Observability

**US-016** — As an **SRE**, I want pre-configured Grafana dashboards for infrastructure, costs, and applications, to monitor platform health in real time.

**US-017** — As an **SRE**, I want automatic alerts when pods restart more than 5x in 15min, CPU > 80%, or disk > 85%, to act proactively before user impact.

**US-018** — As an **SRE**, I want to monitor SLOs with burn rates across multiple time windows, to prioritize actions based on error budget impact.

**US-019** — As an **SRE**, I want specific AI agent metrics (invocation, latency, tokens, error), to ensure agents are performing adequately.

**US-020** — As an **SRE**, I want GitOps alerts that indicate when ArgoCD sync has failed or RHDH is unavailable, to react quickly to deployment issues.

### Epic 5: AI Agents

**US-021** — As a **Developer**, I want to interact with specialized agents (@platform, @devops, @sre, @security, etc.) in GitHub Copilot, to receive contextual assistance for my task.

**US-022** — As a **Platform Engineer**, I want agents to be able to delegate tasks between each other (handoffs), so a complex flow like deployment passes through validation, security, and observability automatically.

**US-023** — As a **Platform Engineer**, I want to use MCP servers to give agents controlled access to Azure, GitHub, Terraform, Kubernetes, and Helm, so they can execute real actions safely.

**US-024** — As a **DevOps Engineer**, I want to use chat modes (Architect, Reviewer, SRE) for specialized personas, to receive guidance with the correct tone and expertise.

**US-025** — As a **Platform Engineer**, I want to create new agents following the standardized template (.agent.md), to expand the platform's capabilities with new specialists.

### Epic 6: Security and Compliance

**US-026** — As a **Security Engineer**, I want OPA Gatekeeper to block privileged containers, containers without resource limits, or containers from unapproved registries, to enforce security policies automatically.

**US-027** — As a **Security Engineer**, I want Terraform policies to validate mandatory tags, TLS, encryption, and public access on every Azure resource, to ensure compliance before deployment.

**US-028** — As a **Compliance Officer**, I want the platform to support LGPD (data in Brazil), SOC 2, and PCI-DSS, to meet regulatory requirements.

**US-029** — As a **Security Engineer**, I want pre-commit hooks to detect secrets in code before commit, to prevent credential leaks.

**US-030** — As a **Security Engineer**, I want security alerts (expiring certificates, login failures, pod security violations), to respond to incidents quickly.

### Epic 7: Migration and Onboarding

**US-031** — As a **Platform Engineer**, I want an ADO → GitHub migration template in 6 phases, to migrate teams from Azure DevOps to GitHub in a structured way.

**US-032** — As a **Platform Engineer**, I want a bootstrap script that configures prerequisites, infrastructure, and platform services, to bootstrap the entire environment quickly.

**US-033** — As a **New Developer**, I want an agent-guided quick start that sets me up in 3 steps (prerequisites → deploy → validate), to start using the platform on day one.

### Epic 8: Cost Management

**US-034** — As a **FinOps Engineer**, I want Azure budgets with alerts at 50%, 75%, 90%, and 100%, to proactively control spending.

**US-035** — As a **FinOps Engineer**, I want a Grafana cost dashboard, to visualize trends and identify optimization opportunities.

**US-036** — As a **FinOps Engineer**, I want alerts when expensive VMs (Standard_E, Standard_M) are used, to validate whether sizing is appropriate.

---

## 7. Repository Structure

```
agentic-devops-platform/
├── .github/                          # GitHub configuration
│   ├── agents/                       # 17 Copilot Chat agents (.agent.md)
│   │   ├── AGENT_TEMPLATE.md         # Base template for creating agents
│   │   ├── architect.agent.md        # System architecture specialist
│   │   ├── platform.agent.md         # IDP/Golden Paths specialist
│   │   ├── devops.agent.md           # CI/CD specialist
│   │   ├── sre.agent.md              # SRE/Observability specialist
│   │   ├── terraform.agent.md        # IaC specialist
│   │   ├── security.agent.md         # Security compliance
│   │   ├── reviewer.agent.md         # Code review
│   │   ├── deploy.agent.md           # Deployment orchestration
│   │   ├── test.agent.md             # Testing/QA
│   │   ├── docs.agent.md             # Documentation
│   │   ├── onboarding.agent.md       # Team onboarding
│   │   ├── template-engineer.agent.md # Template creation
│   │   ├── context-architect.agent.md # Multi-file change planning
│   │   ├── github-integration.agent.md # GitHub operations
│   │   ├── ado-integration.agent.md  # Azure DevOps integration
│   │   ├── hybrid-scenarios.agent.md # GitHub + ADO coexistence
│   │   └── azure-portal-deploy.agent.md # Azure portal deployment
│   ├── chatmodes/                    # 3 chat modes
│   │   ├── architect.chatmode.md     # Architecture design sessions
│   │   ├── reviewer.chatmode.md      # Code review sessions
│   │   └── sre.chatmode.md           # Operations/incident sessions
│   ├── instructions/                 # 3 path-specific instructions
│   │   ├── kubernetes.instructions.md # *.yaml, *.yml, kubernetes/**, helm/**
│   │   ├── python.instructions.md    # *.py, python/**
│   │   └── terraform.instructions.md # *.tf, terraform/**, *.tfvars
│   ├── prompts/                      # 7 reusable prompts
│   │   ├── create-service.prompt.md  # Scaffold a new microservice
│   │   ├── deploy-platform.prompt.md # Deploy the platform
│   │   ├── deploy-service.prompt.md  # Deploy a service to AKS
│   │   ├── generate-docs.prompt.md   # Generate documentation
│   │   ├── generate-tests.prompt.md  # Generate test suites
│   │   ├── review-code.prompt.md     # Perform code review
│   │   └── troubleshoot-incident.prompt.md # Troubleshoot incidents
│   ├── skills/                       # 15 reusable agent skills
│   │   ├── README.md
│   │   ├── ai-foundry-operations/    # Azure AI Foundry operations
│   │   ├── argocd-cli/               # ArgoCD CLI operations
│   │   ├── azure-cli/                # Azure CLI operations
│   │   ├── azure-infrastructure/     # Azure infrastructure patterns
│   │   ├── codespaces-golden-paths/  # GitHub Codespaces devcontainer configs
│   │   ├── database-management/      # Database operations
│   │   ├── deploy-orchestration/     # End-to-end deployment
│   │   ├── github-cli/               # GitHub CLI operations
│   │   ├── helm-cli/                 # Helm CLI operations
│   │   ├── kubectl-cli/              # Kubernetes CLI operations
│   │   ├── mcp-cli/                  # MCP server reference
│   │   ├── observability-stack/      # Prometheus/Grafana setup
│   │   ├── prerequisites/            # CLI tool validation
│   │   ├── terraform-cli/            # Terraform CLI operations
│   │   └── validation-scripts/       # Validation scripts
│   ├── workflows/                    # 9 GitHub Actions workflows
│   │   ├── ci-cd.yml                 # Combined CI/CD pipeline
│   │   ├── ci.yml                    # Continuous Integration
│   │   ├── cd.yml                    # Continuous Deployment
│   │   ├── terraform-test.yml        # Terraform testing
│   │   ├── validate-agents.yml       # Agent validation
│   │   ├── release.yml               # Release automation
│   │   ├── agent-router.yml          # Route issues to agents
│   │   ├── issue-ops.yml             # Issue operations
│   │   └── branch-protection.yml     # Branch protection rules
│   ├── ISSUE_TEMPLATE/               # 27 issue templates
│   ├── PULL_REQUEST_TEMPLATE.md      # PR template
│   ├── scripts/                      # GitHub-specific scripts
│   ├── copilot-instructions.md       # Global Copilot instructions
│   └── dependabot.yml                # Dependabot configuration
│
├── agents-templates/                 # Agent spec backup/reference copies
│   ├── AGENT_TEMPLATE.md             # Base template
│   └── *.agent.md                    # 16 agent specification copies
│
├── terraform/                        # Infrastructure as Code
│   ├── main.tf                       # Root module orchestration
│   ├── variables.tf                  # Input variables with validation
│   ├── outputs.tf                    # Output values
│   ├── backend.tf.example            # Remote state backend example
│   ├── terraform.tfvars.example      # Example variable values
│   ├── .terraform.lock.hcl           # Provider lock file
│   ├── .tflint.hcl                   # Module-level TFLint config
│   ├── README.md                     # Module documentation
│   ├── environments/                 # Environment-specific tfvars
│   ├── examples/                     # Usage examples
│   └── modules/                      # 15 Terraform modules
│       ├── naming/                   # Resource naming convention
│       ├── networking/               # VNet, Subnets, NSGs
│       ├── aks-cluster/              # AKS configuration
│       ├── container-registry/       # ACR
│       ├── databases/                # PostgreSQL + Redis
│       ├── security/                 # Key Vault, RBAC
│       ├── argocd/                   # ArgoCD deployment
│       ├── observability/            # Prometheus, Grafana, Log Analytics
│       ├── external-secrets/         # External Secrets Operator
│       ├── github-runners/           # Self-hosted runners (ARC)
│       ├── ai-foundry/               # Azure AI services
│       ├── purview/                  # Data governance
│       ├── defender/                 # Microsoft Defender
│       ├── cost-management/          # Budgets and alerts
│       └── disaster-recovery/        # Backup and recovery
│
├── golden-paths/                     # RHDH Software Templates (22 total)
│   ├── README.md
│   ├── common/                       # Shared template resources
│   ├── h1-foundation/                # Horizon 1: 6 basic templates
│   │   ├── README.md
│   │   ├── basic-cicd/
│   │   ├── documentation-site/
│   │   ├── infrastructure-provisioning/
│   │   ├── new-microservice/
│   │   ├── security-baseline/
│   │   └── web-application/
│   ├── h2-enhancement/               # Horizon 2: 9 advanced templates
│   │   ├── README.md
│   │   ├── microservice/
│   │   ├── api-microservice/
│   │   ├── event-driven-microservice/
│   │   ├── data-pipeline/
│   │   ├── batch-job/
│   │   ├── api-gateway/
│   │   ├── gitops-deployment/
│   │   ├── ado-to-github-migration/
│   │   └── reusable-workflows/
│   └── h3-innovation/                # Horizon 3: 7 AI/Agent templates
│       ├── README.md
│       ├── ai-evaluation-pipeline/
│       ├── copilot-extension/
│       ├── foundry-agent/
│       ├── mlops-pipeline/
│       ├── multi-agent-system/
│       ├── rag-application/
│       └── sre-agent-integration/
│
├── argocd/                           # GitOps configuration
│   ├── README.md
│   ├── app-of-apps/                  # Root application
│   ├── apps/                         # Individual ArgoCD applications
│   ├── secrets/                      # Secret stores (ClusterSecretStore)
│   ├── sync-policies.yaml            # 5 sync policy presets
│   └── repo-credentials.yaml         # Multi-repo access credentials
│
├── deploy/                           # Deployment manifests
│   ├── README.md
│   └── helm/                         # Helm values & K8s manifests
│       ├── argocd/                   # ArgoCD Helm values
│       ├── monitoring/               # Prometheus stack values
│       ├── argocd-apps.yaml          # ArgoCD applications manifest
│       ├── external-secrets-config.yaml # ESO configuration
│       ├── ingress-all.yaml          # Ingress resources
│       ├── service-monitors.yaml     # ServiceMonitor definitions
│       └── sre-alerts.yaml           # SRE alert rules
│
├── config/                           # Platform configuration
│   ├── README.md
│   ├── apm.yml                       # Agent Package Manager manifest
│   ├── sizing-profiles.yaml          # T-shirt sizing (S/M/L/XL)
│   └── region-availability.yaml      # Azure regions matrix
│
├── grafana/                          # Grafana dashboards
│   ├── README.md
│   └── dashboards/
│       ├── platform-overview.json
│       ├── cost-management.json
│       └── golden-path-application.json
│
├── prometheus/                       # Monitoring rules
│   ├── README.md
│   ├── alerting-rules.yaml           # 50+ alert rules
│   └── recording-rules.yaml          # 40+ recording rules
│
├── policies/                         # Policy as Code
│   ├── README.md
│   ├── terraform/
│   │   └── azure.rego                # OPA policies for Terraform
│   └── kubernetes/
│       ├── constraint-templates/     # Gatekeeper ConstraintTemplates
│       └── constraints/              # Applied constraints
│
├── mcp-servers/                      # MCP configuration
│   ├── mcp-config.json               # 13 server definitions
│   └── USAGE.md                      # Usage guide + access matrix
│
├── scripts/                          # Operational scripts
│   ├── README.md
│   ├── deploy-full.sh                # Full end-to-end deployment
│   ├── platform-bootstrap.sh         # Platform setup (RHDH, ArgoCD, monitoring)
│   ├── bootstrap.sh                  # H1 infrastructure setup
│   ├── setup-github-app.sh           # GitHub App for RHDH/ArgoCD auth
│   ├── setup-identity-federation.sh  # OIDC Workload Identity Federation
│   ├── setup-pre-commit.sh           # Install pre-commit hooks
│   ├── setup-branch-protection.sh    # GitHub branch protection rules
│   ├── setup-terraform-backend.sh    # Azure Storage for remote state
│   ├── setup-portal.sh               # RHDH portal setup
│   ├── validate-prerequisites.sh     # CLI tool validation
│   ├── validate-config.sh            # Config file validation
│   ├── validate-deployment.sh        # Post-deploy health checks
│   ├── validate-agents.sh            # Agent spec validation
│   ├── validate-docs.sh              # Documentation validation
│   ├── validate-substitutions.sh     # Template substitution validation
│   ├── add-techdocs.py               # Add TechDocs to catalog entities
│   ├── fix-ownerpicker.py            # Fix OwnerPicker in templates
│   ├── generate-skeletons.py         # Generate template skeletons
│   ├── update-templates.py           # Update Golden Path templates
│   ├── golden-paths/                 # Golden Path helper scripts
│   │   ├── h1-foundation/
│   │   └── h2-enhancement/
│   └── migration/                    # Migration scripts
│       └── ado-to-github-migration.sh
│
├── new-features/                     # RHDH-specific features & customization
│   ├── AGENTS.md                     # RHDH agent ecosystem guide
│   ├── DEPLOY_CUSTOMIZATIONS_GUIDE.md
│   ├── agent_ecosystem_github_foundry_v1.0.md
│   ├── agent_ecosystem_review_v2.md
│   ├── cowork_tasks_mcp_ai_deploy_v2.md
│   ├── mcp_ai_deploy_master_index_v1.0.md
│   ├── multi_cloud_deploy_guide_v1.0.md
│   ├── rhdh_agent_ecosystem_v1.md
│   ├── rhdh_deploy_customization_guide_v1.0.md
│   ├── rhdh_mcp_lightspeed_deploy_guide_v1.0.md
│   ├── configs/                      # Dynamic plugin & RBAC configs
│   │   ├── app-config-lightspeed.yaml
│   │   ├── app-config-mcp.yaml
│   │   ├── dynamic-plugins-lightspeed.yaml
│   │   ├── dynamic-plugins-mcp.yaml
│   │   ├── configmaps/              # LCS & Llama Stack configs
│   │   ├── helm/                    # Helm value variants
│   │   └── rbac/                    # RBAC policies
│   ├── deploy/                       # RHDH deployment configs
│   │   ├── app-config-rhdh.yaml     # Main RHDH app config (branding, auth)
│   │   ├── configmaps.yaml          # K8s ConfigMaps (homepage, RBAC)
│   │   ├── dynamic-plugins.yaml     # Dynamic plugin configuration
│   │   ├── helm-values.yaml         # Helm values for RHDH
│   │   └── secrets.yaml             # Secrets template
│   ├── foundry/                      # Python-based AI agents for RHDH
│   │   ├── lightspeed-monitor-agent.py
│   │   └── rhdh-agent.py
│   └── homepage/                     # RHDH homepage customization
│       ├── README.md
│       ├── app-config.homepage.yaml
│       ├── homepage-data.json
│       ├── index.html
│       └── login.html
│
├── tests/                            # Test suites
│   └── terraform/
│       ├── README.md
│       ├── go.mod
│       └── modules/                  # 16 Go test files (Terratest)
│
├── docs/                             # Documentation
│   ├── architecture/                 # Architecture docs
│   │   ├── agents-overview.md
│   │   └── copilot-agents-improvement-plan.md
│   ├── assets/                       # 77 SVG/PNG diagram assets
│   ├── guides/                       # 8 operational guides
│   │   ├── ADMINISTRATOR_GUIDE.md
│   │   ├── ARCHITECTURE_GUIDE.md
│   │   ├── DEPLOYMENT_GUIDE.md
│   │   ├── MODULE_REFERENCE.md
│   │   ├── PERFORMANCE_TUNING_GUIDE.md
│   │   ├── TROUBLESHOOTING_GUIDE.md
│   │   ├── copilot-agents-best-practices.md
│   │   └── copilot-agents-complete-guide.md
│   ├── research/                     # Research documents
│   │   └── agent-research.md
│   ├── runbooks/                     # 6 operational runbooks
│   │   ├── README.md
│   │   ├── deployment-runbook.md
│   │   ├── disaster-recovery.md
│   │   ├── emergency-procedures.md
│   │   ├── incident-response.md
│   │   ├── node-replacement.md
│   │   └── rollback-runbook.md
│   ├── official-docs/                # Official vendor documentation
│   │   ├── ansible/
│   │   ├── backstage/
│   │   └── rhdh/
│   ├── BRANCHING_STRATEGY.md
│   ├── GITHUB_COPILOT_AGENTS_BEST_PRACTICES.md
│   └── github_copilot_agents_best_practices_analysis.md
│
├── images-logos/                     # Brand assets (15 files)
│   ├── Three Horizon.png             # 3-partner composite logo (color)
│   ├── Three Horizon-White.png       # 3-partner composite logo (white)
│   └── *.png                         # Individual partner logos
│
├── platform/                         # Platform services documentation
│   └── README.md
│
├── AGENTS.md                         # Agent system overview
├── CLAUDE.md                         # Claude Code context file
├── PROJECT_DOCUMENTATION.md          # This file
├── README.md                         # Project README
├── CONTRIBUTING.md                   # Contribution guide
├── SECURITY.md                       # Security policy
├── CHANGELOG.md                      # Version history
├── CODEOWNERS                        # Code ownership
├── LICENSE                           # MIT License
├── .pre-commit-config.yaml           # 14 pre-commit hooks
├── .tflint.hcl                       # TFLint rules (Azure-specific)
├── .yamllint.yml                     # YAML lint rules
├── .markdownlint.json                # Markdown lint rules
├── .secrets.baseline                 # detect-secrets baseline
└── .terraform-docs.yml              # Auto-generated Terraform docs
```

---

## 8. Terraform Modules (Infrastructure as Code)

### 8.1 Module Overview

All modules use AzureRM provider >= 3.75.0 and Terraform >= 1.5.0. Each module follows a consistent structure: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `README.md`.

| # | Module | Description | Resources Created |
|---|--------|-------------|-------------------|
| 1 | **naming** | Resource naming convention | Standardized names: `{customer}-{env}-{resource}` |
| 2 | **networking** | Virtual networking | VNet, Subnets (AKS nodes, pods, PE, bastion, AppGW), NSGs, Private DNS Zones, Route Tables |
| 3 | **aks-cluster** | Kubernetes cluster | AKS with system + user node pools, Workload Identity, Azure Policy, Defender |
| 4 | **container-registry** | Image registry | ACR with geo-replication, AKS AcrPull role integration |
| 5 | **databases** | Databases | PostgreSQL Flexible Server v16 + Redis Cache with private endpoints |
| 6 | **security** | Core security | Key Vault (RBAC, soft delete), Managed Identities, Workload Identity Federation |
| 7 | **argocd** | GitOps | ArgoCD via Helm with HA, SSO, RBAC, ingress |
| 8 | **observability** | Monitoring | Log Analytics, Container Insights, Azure Managed Grafana, action groups |
| 9 | **external-secrets** | Secret sync | External Secrets Operator via Helm + ClusterSecretStore linked to Key Vault |
| 10 | **github-runners** | CI runners | ARC (Actions Runner Controller) self-hosted runners on AKS |
| 11 | **ai-foundry** | Artificial intelligence | Cognitive Account (OpenAI), AI Search, Content Safety, model deployments |
| 12 | **purview** | Data governance | Microsoft Purview Account with private endpoints |
| 13 | **defender** | Advanced security | Defender for Containers, Servers, Storage, Key Vault |
| 14 | **cost-management** | Cost management | Budgets with alerts at 50/75/90/100% |
| 15 | **disaster-recovery** | DR | Backup Vault, geo-replication, cross-region DR |

### 8.2 Deployment Modes

The root `main.tf` uses a `deployment_mode` variable with three presets:

| Mode | AKS Nodes | VM Size | HA | Monitoring | AI |
|------|-----------|---------|----|-----------|----|
| **express** | 3 | Standard_D4s_v5 | No | Yes | No |
| **standard** | 5 | Standard_D4s_v5 | Yes | Yes | Yes |
| **enterprise** | 10 | Standard_D8s_v5 | Yes | Yes | Yes |

### 8.3 Required Variables (terraform/variables.tf)

```hcl
customer_name          # 3-20 lowercase alphanumeric, e.g. "contoso"
environment            # "dev" | "staging" | "prod"
azure_subscription_id  # Azure subscription
azure_tenant_id        # Azure AD tenant
admin_group_id         # Azure AD admin group
github_org             # GitHub organization
github_token           # GitHub PAT (sensitive)
```

### 8.4 Feature Flags

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

### 8.5 Module Dependency Order

```
networking → security → aks-cluster → databases
                                    → container-registry
                                    → ai-foundry
                                    → observability → argocd
                                                   → external-secrets
                                                   → github-runners
```

### 8.6 Global Outputs (terraform/outputs.tf)

Outputs include:

- IDs and endpoints for all created resources
- Access credentials (via Key Vault references)
- `kubectl` commands for cluster connection
- Access URLs for RHDH, ArgoCD, Grafana
- Connection strings for databases

---

## 9. Golden Paths (RHDH Templates)

Golden Paths are standardized templates registered in Red Hat Developer Hub that guide developers along the "happy path" of service creation.

### 9.1 H1 Foundation Templates (6)

| Template | Description |
|----------|-------------|
| **basic-cicd** | Basic CI/CD pipeline with GitHub Actions |
| **security-baseline** | Security baseline configuration |
| **documentation-site** | Documentation site with TechDocs |
| **web-application** | Web application scaffold |
| **new-microservice** | New microservice scaffold |
| **infrastructure-provisioning** | IaC provisioning template |

### 9.2 H2 Enhancement Templates (9)

| Template | Description |
|----------|-------------|
| **microservice** | Full microservice (API + DB + Events + Observability + CI/CD) |
| **api-microservice** | RESTful API with OpenAPI spec, validation, error handling |
| **event-driven-microservice** | Event-based with Event Hubs/Service Bus, dead letter, retry |
| **data-pipeline** | ETL pipeline with data quality checks and schema validation |
| **batch-job** | Kubernetes CronJob with monitoring and failure handling |
| **api-gateway** | API Management with rate limiting, JWT/OAuth auth |
| **gitops-deployment** | ArgoCD application manifests with sync policies |
| **ado-to-github-migration** | 6-phase migration (Config → Repos → Pipelines → Boards → Artifacts → Validation) |
| **reusable-workflows** | GitHub Actions reusable workflow library |

### 9.3 H3 Innovation Templates (7)

| Template | Description |
|----------|-------------|
| **foundry-agent** | AI Foundry agent with Azure OpenAI |
| **sre-agent-integration** | SRE agent with observability integration |
| **mlops-pipeline** | MLOps pipeline for model training and deployment |
| **multi-agent-system** | Multi-agent orchestration system |
| **copilot-extension** | GitHub Copilot extension |
| **rag-application** | RAG (Retrieval Augmented Generation) application |
| **ai-evaluation-pipeline** | AI model evaluation pipeline |

---

## 10. AI Agent System

### 10.1 GitHub Copilot Agents

The project defines 17 specialized agents in `.github/agents/` following the `.agent.md` open standard format:

| Agent | Scope | Tools |
|-------|-------|-------|
| **@architect** | System design, AI Foundry, multi-agent design | — |
| **@platform** | IDP, Golden Paths, Catalog, Onboarding | kubernetes, helm, github |
| **@devops** | CI/CD, K8s, GitOps, MLOps, Pipelines | kubernetes, helm, github, argocd |
| **@sre** | Observability, SLOs, Incident Response | prometheus, grafana, kubernetes |
| **@terraform** | Infrastructure as Code | terraform, azure |
| **@security** | Compliance, vulnerability scanning | defender, gitleaks, trivy |
| **@reviewer** | Code review, security analysis | github |
| **@deploy** | Deployment orchestration | argocd, kubernetes, helm |
| **@test** | Testing and QA automation | — |
| **@docs** | Documentation generation | — |
| **@onboarding** | Team onboarding workflows | kubernetes, github |
| **@template-engineer** | Golden Path template creation | kubernetes, helm |
| **@context-architect** | Multi-file change planning, dependency tracing | all |
| **@github-integration** | GitHub App, org discovery, GHAS, Actions, Packages | github |
| **@ado-integration** | Azure DevOps PAT, repos, pipelines, boards | azure |
| **@hybrid-scenarios** | GitHub + ADO coexistence (scenarios A/B/C) | all |
| **@azure-portal-deploy** | Azure portal AKS, Key Vault, PostgreSQL, ACR | azure |

### 10.2 Agent Spec Structure (.agent.md)

Each agent follows a standardized format with YAML frontmatter:

```yaml
---
name: agent-name
description: Agent purpose
tools: [tool1, tool2]
user-invokable: true
handoffs: [other-agent-1, other-agent-2]
---
```

Followed by sections:
- **Purpose** — What the agent does
- **Commands** — Available commands
- **Boundaries** — Always do / Ask first / Never do
- **Task Decomposition** — How to break down complex tasks
- **Handoffs** — When and to whom to delegate

### 10.3 Handoff Flows

```
Deployment:   @onboarding → @architect → @terraform → @deploy → @sre
Security:     @reviewer → @security → @devops (remediate) → @test
Templates:    @platform → @template-engineer → @devops → @security
Multi-file:   Any agent → @context-architect → @test → @docs
Hybrid:       @github-integration + @ado-integration → @hybrid-scenarios → @deploy
```

### 10.4 Reusable Skills

15 skills in `.github/skills/`:

| Skill | Description |
|-------|-------------|
| **ai-foundry-operations** | Azure AI Foundry and OpenAI operations |
| **argocd-cli** | ArgoCD CLI for GitOps workflows |
| **azure-cli** | Azure CLI resource management |
| **azure-infrastructure** | Azure infrastructure patterns |
| **codespaces-golden-paths** | GitHub Codespaces devcontainer configs |
| **database-management** | Database operations and health monitoring |
| **deploy-orchestration** | End-to-end platform deployment |
| **github-cli** | GitHub CLI for repos and workflows |
| **helm-cli** | Helm CLI for Kubernetes packages |
| **kubectl-cli** | Kubernetes CLI for AKS |
| **mcp-cli** | MCP server reference |
| **observability-stack** | Prometheus, Grafana, observability |
| **prerequisites** | CLI tool validation and setup |
| **terraform-cli** | Terraform CLI for Azure infra |
| **validation-scripts** | Validation scripts for deployments |

### 10.5 Chat Modes

3 specialized personas for GitHub Copilot Chat:

| Mode | Focus |
|------|-------|
| **Architect** | System design, trade-offs, ADRs |
| **Reviewer** | Code review, security, best practices |
| **SRE** | Observability, SLOs, incident response |

### 10.6 Reusable Prompts

7 standardized prompts in `.github/prompts/`:

| Prompt | Usage |
|--------|-------|
| **deploy-platform** | Deploy the Three Horizons platform |
| **create-service** | Scaffold a new microservice |
| **deploy-service** | Deploy a service to AKS |
| **generate-docs** | Generate documentation |
| **generate-tests** | Generate test suites |
| **review-code** | Perform code review |
| **troubleshoot-incident** | Troubleshoot incidents |

---

## 11. MCP Servers (Model Context Protocol)

### 11.1 Configured Servers

13 MCP servers giving AI agents controlled access to tools. Defined in `mcp-servers/mcp-config.json`:

| Server | Command | Capabilities |
|--------|---------|-------------|
| **azure** | `az` | Azure CLI — resources, RBAC, monitoring |
| **github** | `gh` | GitHub CLI — repos, PRs, issues, actions |
| **terraform** | `terraform` | Plan, apply, state, validate |
| **kubernetes** | `kubectl` | Pods, services, deployments, logs |
| **helm** | `helm` | Install, upgrade, rollback, template |
| **docker** | `docker` | Build, push, pull, inspect |
| **git** | `git` | Clone, commit, push, branch, merge |
| **bash** | `bash` | Shell commands (with restrictions) |
| **filesystem** | `fs` | Read, write, list files |
| **defender** | `defender` | Security scanning, compliance |
| **purview** | `purview` | Data governance operations |
| **entra** | `entra` | Azure AD / Entra ID operations |
| **copilot** | `copilot` | GitHub Copilot CLI |

### 11.2 Access Matrix

Each agent has specific access to certain MCP servers:

| Agent | azure | github | terraform | kubernetes | helm |
|-------|-------|--------|-----------|------------|------|
| @terraform | ✅ | ✅ | ✅ | ❌ | ❌ |
| @devops | ✅ | ✅ | ❌ | ✅ | ✅ |
| @sre | ✅ | ❌ | ❌ | ✅ | ❌ |
| @security | ✅ | ✅ | ✅ | ✅ | ❌ |
| @deploy | ✅ | ✅ | ❌ | ✅ | ✅ |

### 11.3 MCP Server Security

- **Read-only operations**: Allowed without confirmation (`az resource list/show`, `kubectl get`, `helm list`)
- **Write operations**: Require user confirmation (`terraform apply`, `kubectl apply`, `helm install`)
- **Forbidden operations**: Never executed (`kubectl delete namespace production`, `terraform destroy -auto-approve`, `az keyvault secret show --query value`)

---

## 12. GitOps with ArgoCD

### 12.1 App-of-Apps Pattern

ArgoCD uses the **App-of-Apps** pattern with a Root Application (`argocd/app-of-apps/root-application.yaml`) that manages all child apps.

**Deployment Waves (installation order):**

| Wave | Component | Type |
|------|-----------|------|
| 1 | cert-manager, external-dns | Infrastructure |
| 2 | ingress-nginx | Networking |
| 3 | prometheus, jaeger | Observability |
| 4 | Red Hat Developer Hub | Platform |
| 5+ | Team namespaces, applications | Applications |

### 12.2 Sync Policies

5 sync policy presets defined in `argocd/sync-policies.yaml`:

| Preset | Prune | Self-Heal | Auto-Sync | Usage |
|--------|-------|-----------|-----------|-------|
| **dev-auto-sync** | ✅ | ✅ | ✅ | Development |
| **staging-auto-sync** | ✅ | ✅ | ✅ | Staging |
| **prod-manual-sync** | ❌ | ❌ | ❌ | Production (manual approval) |
| **infra-careful-sync** | ❌ | ✅ | ✅ | Critical infrastructure |
| **preview-aggressive-sync** | ✅ | ✅ | ✅ | Ephemeral/preview environments |

### 12.3 Repository Credentials

Support for multiple repository types (`argocd/repo-credentials.yaml`):
- GitHub HTTPS with PAT
- GitHub SSH with deploy keys
- Azure DevOps HTTPS
- Helm repositories (Bitnami, Prometheus, Grafana, Jetstack)
- ACR (Azure Container Registry) as Helm OCI

---

## 13. Observability and Monitoring

### 13.1 Observability Stack

- **Prometheus** — Metrics collection with configured scrape
- **Grafana** — Dashboards with SSO via Azure AD
- **Alertmanager** — Alert management and routing
- **Jaeger** — Distributed tracing
- **Log Analytics** — Azure-native logging

### 13.2 Alerts by Category

#### Infrastructure (H1)
- Node not ready > 5min (critical)
- Pod restarting > 5x in 15min (warning)
- PVC > 85% used (warning)
- CPU > 80% for > 15min (warning)
- Memory > 85% for > 15min (warning)

#### Platform (H2)
- RHDH unavailable > 5min (critical)
- ArgoCD sync failing > 15min (critical)
- Grafana unavailable > 5min (warning)

#### AI/Agents (H3)
- AI Foundry latency > 5s (warning)
- Agent failure rate > 10% in 15min (warning)
- Multi-agent orchestration timeout (warning)

#### SRE/SLOs
- SLO burn rate high (1h window) (critical)
- SLO burn rate moderate (6h window) (warning)
- Availability SLA breach (critical)

#### Security
- Certificates expiring in < 30 days (warning)
- Failed login attempts > 10 in 5min (warning)
- Pod security policy violations (warning)

### 13.3 Grafana Dashboards

| Dashboard | Panels |
|-----------|--------|
| **Platform Overview** | Cluster health, node status, pod distribution, resource usage |
| **Cost Management** | Budget utilization, cost trends, resource costs by tag |
| **Golden Path Application** | App RED metrics, latency, error rates, deployment frequency |

### 13.4 ServiceMonitors

Metrics collected from:
- RHDH (port 7007, path /metrics)
- ArgoCD (server, repo-server, controller)
- ingress-nginx (port 10254)
- cert-manager (port 9402)
- external-secrets (port 8080)

---

## 14. Security and Compliance

### 14.1 Security Model

```
┌──────────────────────────────────────────────────┐
│                   Perimeter                       │
│  ┌─────────────────────────────────────────────┐  │
│  │           Network Security                   │  │
│  │  VNet + NSGs + Private Endpoints            │  │
│  │  ┌────────────────────────────────────────┐ │  │
│  │  │         Identity & Access              │ │  │
│  │  │  Managed Identity + Workload Identity  │ │  │
│  │  │  RBAC + Azure AD + Key Vault          │ │  │
│  │  │  ┌──────────────────────────────────┐ │ │  │
│  │  │  │       Runtime Security          │ │ │  │
│  │  │  │  Gatekeeper + Defender          │ │ │  │
│  │  │  │  Non-root + No-privilege        │ │ │  │
│  │  │  │  Approved registries only       │ │ │  │
│  │  │  └──────────────────────────────────┘ │ │  │
│  │  └────────────────────────────────────────┘ │  │
│  └─────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

### 14.2 Security Standards

| Area | Implementation |
|------|----------------|
| **Authentication** | Managed Identity, Workload Identity, OIDC Federation, Azure AD SSO, GitHub OAuth |
| **Network** | Private Endpoints, NSGs, VNet isolation, no public access |
| **Data Protection** | TLS 1.2+, AES-256 encryption at rest, Key Vault for secrets |
| **Container** | Non-root, no privilege escalation, read-only rootfs, approved registries |
| **CI/CD** | Branch protection, signed commits, secret scanning, SAST |

### 14.3 Integrated Security Tooling

- **Gitleaks** — Secret scanning in commits
- **detect-secrets** — Repository secrets baseline (13+ detectors)
- **Trivy** — Container vulnerability scanning
- **tfsec** — Terraform security analysis
- **OPA/Gatekeeper** — Runtime policy enforcement
- **Microsoft Defender** — Cloud security posture management
- **Conftest** — Policy testing for Terraform plans

### 14.4 Compliance Support

- **LGPD** — Primary region brazilsouth, consent management
- **SOC 2** — Audit trails, access controls, monitoring
- **PCI-DSS** — Network segmentation, encryption, access management
- **CIS Benchmarks** — Kubernetes and Azure hardening

### 14.5 Supported Versions

| Version | Support |
|---------|---------|
| 4.x | ✅ Active support with security patches |
| 3.x | ❌ No support |
| < 3.0 | ❌ No support |

---

## 15. Policies (OPA/Gatekeeper)

### 15.1 Terraform Policies (Rego)

OPA policies executed via Conftest in the CI pipeline (`policies/terraform/azure.rego`):

| Policy | Severity | Description |
|--------|----------|-------------|
| Required Tags | Error | environment, project, owner, cost-center mandatory |
| TLS Enforcement | Error | Storage accounts and PostgreSQL must use TLS 1.2 |
| Encryption | Error | Storage and Key Vault must have encryption enabled |
| No Public Access | Error | Storage, Key Vault, AKS without public access |
| HTTPS Only | Error | Storage accounts HTTPS-only |
| Private Endpoints | Warning | PaaS services should have private endpoints |
| AKS RBAC | Error | AKS must have RBAC, Managed Identity, Azure Policy, Defender |
| Geo-redundant Backups | Error | PostgreSQL must have geo-redundant backups |
| Expensive VMs | Warning | Alert on Standard_E/Standard_M series usage |

### 15.2 Kubernetes Constraint Templates (Gatekeeper)

5 ConstraintTemplates in `policies/kubernetes/constraint-templates/`:

| Template | Description |
|----------|-------------|
| **K8sRequiredLabels** | Mandatory labels with regex validation |
| **K8sContainerResources** | CPU and memory requests/limits required |
| **K8sDenyPrivileged** | Block privileged containers |
| **K8sRequireNonRoot** | Enforce non-root execution |
| **K8sAllowedRegistries** | Restrict to approved registries only |

---

## 16. CI/CD and Automation

### 16.1 GitHub Actions Workflows

9 workflows in `.github/workflows/`:

| Workflow | Trigger | Description |
|----------|---------|-------------|
| **ci-cd.yml** | push/PR to main | Full pipeline (lint, test, build, deploy) |
| **ci.yml** | push/PR | Continuous Integration (lint, test, validate) |
| **cd.yml** | merge to main | Continuous Deployment (deploy to staging/prod) |
| **terraform-test.yml** | changes in terraform/ | Terratest execution |
| **validate-agents.yml** | changes in agents/ | Agent spec validation |
| **release.yml** | tag creation | Release automation with CHANGELOG |
| **agent-router.yml** | issue creation | Route issues to correct agents |
| **issue-ops.yml** | issue events | Issue operations automation |
| **branch-protection.yml** | scheduled | Branch rules enforcement |

### 16.2 Pre-commit Hooks

14 hooks defined in `.pre-commit-config.yaml`:

| Hook | Scope | Action |
|------|-------|--------|
| terraform fmt | .tf files | Formatting |
| terraform validate | .tf files | Syntax validation |
| tflint | .tf files | Terraform linting |
| tfsec | .tf files | Security scanning |
| shellcheck | .sh files | Shell linting |
| kubeconform | .yaml K8s files | Manifest validation |
| yamllint | .yaml files | YAML linting |
| markdownlint | .md files | Markdown linting |
| detect-secrets | all files | Secret detection |
| end-of-file-fixer | all files | Final newline |
| trailing-whitespace | all files | Whitespace cleanup |
| check-yaml | .yaml files | YAML syntax |
| check-json | .json files | JSON syntax |
| gitleaks | all files | Secret scanning |

### 16.3 Branch Strategy

- `main` — Protected branch, requires PR with approval
- `feature/*` — New features
- `bugfix/*` — Bug fixes
- `hotfix/*` — Production hotfixes
- `release/*` — Release preparation

### 16.4 Commit Convention

```
<type>(<scope>): <description>

Types: feat, fix, docs, refactor, test, chore, ci, infra
Scopes: terraform, k8s, argocd, agents, golden-paths, scripts, docs
```

---

## 17. Configuration

### 17.1 APM (Agent Package Manager) — config/apm.yml

Central manifest defining all dependencies, instructions, prompts, agents, and compilation targets (VSCode, Claude, Codex).

### 17.2 Sizing Profiles — config/sizing-profiles.yaml

T-shirt sizing profiles for infrastructure dimensioning:

| Profile | Devs | AKS Nodes | PostgreSQL | Redis | AI Foundry |
|---------|------|-----------|------------|-------|------------|
| **Small** | ≤10 | 2 (Standard_D4s_v5) | B_Standard_B2s | Basic C1 | S0 |
| **Medium** | 10-50 | 3 (Standard_D8s_v5) | GP_Standard_D4s_v3 | Standard C3 | S1 |
| **Large** | 50-200 | 5 (Standard_D16s_v5) | GP_Standard_D8s_v3 | Premium P2 | S2 |
| **XLarge** | 200+ | 8 (Standard_D32s_v5) | MO_Standard_E4s_v3 | Premium P4 | S3 |

### 17.3 Region Availability — config/region-availability.yaml

| Tier | Regions | Services |
|------|---------|----------|
| **Tier 1** | brazilsouth, eastus2, southcentralus | All services (AKS, AI, Purview, etc.) |
| **Tier 2** | westus2 | Most services (no Purview) |

**Deployment Patterns:**
- **LGPD Compliance**: Primary brazilsouth, DR eastus2
- **Multi-LATAM**: Primary brazilsouth, Secondary southcentralus
- **US-Based**: Primary eastus2, Secondary westus2

### 17.4 Lint and Validation Files

| File | Purpose |
|------|---------|
| `.tflint.hcl` | Terraform linting rules (Azure-specific) |
| `.yamllint.yml` | YAML lint rules (200 chars max, allow comments) |
| `.markdownlint.json` | Markdown lint rules (proper names: Kubernetes, Azure, RHDH) |
| `.terraform-docs.yml` | Auto-generated Terraform module docs |
| `.secrets.baseline` | detect-secrets baseline with 13+ detectors |
| `.pre-commit-config.yaml` | All pre-commit hook definitions |

---

## 18. Operational Scripts

All scripts are in `scripts/` and follow strict mode (`set -euo pipefail`).

### 18.1 Deployment Scripts

| Script | Description |
|--------|-------------|
| `deploy-full.sh` | Full end-to-end deployment (infra + platform + apps) |
| `platform-bootstrap.sh` | Platform setup (RHDH, ArgoCD, monitoring) |
| `bootstrap.sh` | H1 infrastructure setup (Terraform apply) |

### 18.2 Validation Scripts

| Script | Validates |
|--------|-----------|
| `validate-prerequisites.sh` | Installed CLIs (az ≥ 2.50, terraform ≥ 1.5, kubectl ≥ 1.28, helm ≥ 3.12, gh ≥ 2.30) |
| `validate-config.sh` | Configuration files (tfvars, sizing, regions) |
| `validate-deployment.sh` | Post-deploy health (pods, services, endpoints) |
| `validate-agents.sh` | Agent specs (YAML frontmatter, boundaries, handoffs) |
| `validate-docs.sh` | Documentation (broken links, formatting, completeness) |
| `validate-substitutions.sh` | Template substitution validation |

### 18.3 Setup Scripts

| Script | Configures |
|--------|------------|
| `setup-github-app.sh` | GitHub App for RHDH/ArgoCD auth |
| `setup-identity-federation.sh` | OIDC Workload Identity Federation |
| `setup-pre-commit.sh` | Install and configure pre-commit hooks |
| `setup-branch-protection.sh` | GitHub branch protection rules |
| `setup-terraform-backend.sh` | Azure Storage Account for remote state |
| `setup-portal.sh` | RHDH portal setup and configuration |

### 18.4 Python Automation Scripts

| Script | Description |
|--------|-------------|
| `add-techdocs.py` | Add TechDocs annotations to catalog entities |
| `fix-ownerpicker.py` | Fix OwnerPicker in Golden Path templates |
| `generate-skeletons.py` | Generate template skeletons from specifications |
| `update-templates.py` | Update Golden Path template versions |

### 18.5 Migration Scripts

| Script | Description |
|--------|-------------|
| `migration/ado-to-github-migration.sh` | ADO → GitHub migration in 6 phases |

---

## 19. Tests

### 19.1 Test Framework

The project uses **Terratest** (Go) for infrastructure tests. Each Terraform module has its own test file in `tests/terraform/modules/`.

### 19.2 Test Files

| Test | Module | Validations |
|------|--------|-------------|
| `aks_cluster_test.go` | AKS | K8s version, node pools, RBAC, identity |
| `networking_test.go` | Networking | VNet CIDR, subnets, NSGs |
| `container_registry_test.go` | ACR | SKU, geo-replication, admin disabled |
| `databases_test.go` | Databases | PostgreSQL version, SSL, Redis config |
| `security_test.go` | Security | Key Vault, purge protection, RBAC |
| `argocd_test.go` | ArgoCD | Namespace, Helm values, ingress |
| `ai_foundry_test.go` | AI Foundry | Model deployments, endpoints |
| `observability_test.go` | Observability | Prometheus, Grafana, ServiceMonitors |
| `github_runners_test.go` | GitHub Runners | Runner deployment, labels |
| `purview_test.go` | Purview | Account creation, scan rules |
| `cost_management_test.go` | Costs | Budgets, alert thresholds |
| `disaster_recovery_test.go` | DR | Backup vault, retention |
| `defender_test.go` | Defender | Plans enabled, auto-provisioning |
| `external_secrets_test.go` | Ext Secrets | Operator, SecretStore, sync |
| `naming_test.go` | Naming | Convention compliance |
| `integration_test.go` | All | End-to-end cross-module tests |

### 19.3 Test Pattern

Each test follows:

1. `t.Parallel()` — Parallel execution
2. Define Terraform variables
3. `terraform.Init()` — Initialize module
4. `terraform.Validate()` — Validate syntax
5. `terraform.Plan()` — Generate plan
6. Assertions on plan output (names, configurations, properties)

---

## 20. Multi-Cloud Deployment

### 20.1 Azure (Primary)

Full deployment with all 15 Terraform modules:
- **Compute**: AKS, GitHub Runners
- **Storage**: ACR, PostgreSQL, Redis, Backup Vault
- **Security**: Key Vault, Managed Identity, Defender
- **AI**: AI Foundry (GPT-4o, GPT-4o-mini, text-embedding-3-large)
- **Governance**: Purview, Cost Management
- **Networking**: VNet, NSGs, Private Endpoints

### 20.2 AWS (Secondary)

| Azure | AWS Equivalent |
|-------|----------------|
| AKS | EKS |
| ACR | ECR |
| Key Vault | Secrets Manager |
| Managed Identity | IRSA (IAM Roles for Service Accounts) |
| PostgreSQL Flexible | RDS PostgreSQL |
| Redis Cache | ElastiCache |

### 20.3 GCP (Secondary)

| Azure | GCP Equivalent |
|-------|----------------|
| AKS | GKE |
| ACR | Artifact Registry |
| Key Vault | Secret Manager |
| Managed Identity | Workload Identity |
| AI Foundry | Vertex AI |

### 20.4 On-Premise

| Azure | On-Premise Equivalent |
|-------|----------------------|
| AKS | OpenShift / k3s |
| ACR | Harbor |
| Key Vault | HashiCorp Vault |
| AI Foundry | Ollama / vLLM |

---

## 21. RHDH — Red Hat Developer Hub

### 21.1 RHDH vs Backstage

| Aspect | Backstage OSS | RHDH (Red Hat) |
|--------|---------------|----------------|
| Plugins | Code-based (npm build) | Dynamic Plugins (YAML-only) |
| Deployment | Kustomize + custom image | Standard Helm chart |
| RBAC | Basic (Owner model) | Built-in with CSV policies |
| AI | Requires custom plugin | Native Developer Lightspeed |
| Support | Community | Red Hat Enterprise Support |
| Auth | Manual configuration | Pre-integrated with OAuth |

### 21.2 Dynamic Plugins

In RHDH, plugins are enabled via YAML without rebuild. Configuration in `new-features/deploy/dynamic-plugins.yaml`:

```yaml
global:
  dynamic:
    includes:
      - dynamic-plugins.default.yaml
    plugins:
      - package: ./dynamic-plugins/dist/backstage-plugin-github-actions
        disabled: false
      - package: ./dynamic-plugins/dist/backstage-plugin-kubernetes
        disabled: false
```

### 21.3 Developer Lightspeed

AI chat integrated into RHDH using:
- **LCS (Lightspeed Conversation Service)** — Conversation backend
- **Llama Stack** — LLM inference
- **RAG** — Retrieval Augmented Generation with project docs
- **BYOM** — Support for Azure OpenAI, Ollama, vLLM as alternative models

Configuration files in `new-features/configs/`:
- `app-config-lightspeed.yaml` — Lightspeed app config
- `dynamic-plugins-lightspeed.yaml` — Lightspeed plugins
- `configmaps/llama-stack-*.yaml` — Llama Stack variants (Azure OpenAI, Ollama, vLLM)

### 21.4 RBAC Policies

| Role | Permissions |
|------|------------|
| **Admin** | Everything (catalog, scaffolder, AI, plugins) |
| **Developer** | Catalog read/write, scaffolder execute, AI chat |
| **Viewer** | Catalog read-only, documentation |

Policy files: `new-features/configs/rbac/permission-policies-ai.csv`

### 21.5 Customized Homepage

RHDH homepage customization in `new-features/homepage/`:
- Quick actions (create service, view catalog)
- Important links (ArgoCD, Grafana, docs)
- Status widgets (recent deployments, alerts)
- Three Horizons branding (Microsoft + GitHub + Red Hat)

---

## 22. Metrics and KPIs

### 22.1 Recording Rules (Pre-calculated Metrics)

| Category | Metrics |
|----------|---------|
| **Cluster** | CPU/memory/storage utilization ratios |
| **Applications** | Request rate, error rate, latency (p50/p90/p99) |
| **SLO** | Availability across 5m, 1h, 24h, 30d windows |
| **GitOps** | ArgoCD app sync success rate, time to sync |
| **AI Agents** | Invocation rate, LLM latency, token usage, error rate |
| **Golden Paths** | Template creation rate, success rate, time to first deploy |
| **Platform Health** | Aggregated health score |

### 22.2 Estimated Deploy Times

| Phase | Time |
|-------|------|
| H1 Foundation (Terraform) | ~45 minutes |
| H2 Enhancement (ArgoCD + RHDH) | ~30 minutes |
| H3 Innovation (AI + Agents) | ~15 minutes |
| **Total** | **~90 minutes** |

---

## 23. Version History

### v4.0.0 (2026-02-28) — Current

Major additions:
- 15 complete Terraform modules
- 17 GitHub Copilot agents with handoffs
- 22 Golden Path templates (H1: 6, H2: 9, H3: 7)
- 13 MCP servers
- 3 Grafana dashboards
- 50+ alert rules + 40+ recording rules
- 5 Gatekeeper constraint templates
- 16 Terratest suites
- 27 issue templates
- 9 GitHub Actions workflows
- 77 SVG/PNG diagram assets
- 8 operational guides + 6 runbooks
- Python automation scripts
- RHDH portal customization (homepage, branding, dynamic plugins)
- Developer Lightspeed integration (Llama Stack + RAG + BYOM)
- Deployment, validation, setup, and migration scripts

### v3.0.0 (2025-06-01)

- Initial Three Horizons architecture
- 8 Terraform modules
- ArgoCD with App-of-Apps
- 5 basic Golden Paths
- Prometheus + Grafana base

### v2.0.0 (2025-01-15)

- Azure infrastructure modules
- AKS + Networking + ACR + Databases + Key Vault
- Basic CI pipeline

### v1.0.0 (2024-09-01)

- Initial release
- Base Terraform for AKS
- Initial documentation

---

## 24. References and Links

### Official Documentation

- [Red Hat Developer Hub 1.8 Documentation](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.8)
- [Backstage.io](https://backstage.io)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm)
- [GitHub Copilot Agents](https://docs.github.com/en/copilot)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io)
- [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper)
- [Terratest](https://terratest.gruntwork.io)

### Responsible Teams (CODEOWNERS)

| Area | Team |
|------|------|
| Default | @platform-team |
| Terraform | @platform-team @infra-team |
| Kubernetes/Helm | @platform-team @devops-team |
| Golden Paths | @platform-team + per-horizon teams |
| Security | @security-team |
| AI Agents/MCP | @platform-team @ai-team |
| Documentation | @platform-team @docs-team |

### Security Contacts

- **Email**: security@three-horizons.dev
- **Vulnerabilities**: Report via process described in SECURITY.md
- **Severity**: Critical (< 24h), High (< 48h), Medium (< 1 week), Low (next sprint)

---

> **Document generated on**: 2026-02-28
> **Source**: Complete analysis of the `agentic-devops-platform/` repository
> **Coverage**: 949+ files, 105,000+ lines of code, 15 Terraform modules, 17 AI agents, 22 Golden Paths, 13 MCP servers
