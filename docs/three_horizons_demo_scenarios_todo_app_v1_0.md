# Three Horizons — Demo Scenarios

> **End-to-End Todo App: Golden Path Template → Codespaces → Azure Deploy**
> 3 Complete Demo Scenarios for Customer Presentation
>
> Version 1.0 | Microsoft LATAM — Platform Engineering | paulasilva@microsoft.com

---

## Executive Summary

This document defines three complete demo scenarios for the Three Horizons Agentic DevOps Platform. The demo uses a single application — a Full-Stack Todo App (React + Node.js + TypeScript + Terraform + Azure) — to showcase how a developer goes from ZERO to a fully deployed application in under 10 minutes, using nothing but the RHDH portal and GitHub Copilot agents.

The base repository is github.com/3horizons/todo-app (forked from paulasilvatech/sre-demo). This repo already contains a complete full-stack application with frontend (React 18 + Vite + Tailwind CSS), backend (Node.js 20 + Express + Prisma ORM + Redis), Terraform IaC for Azure, GitHub Actions CI/CD, Playwright E2E tests, and 5 Copilot custom agents.

The three scenarios are complementary — they show the SAME end-to-end flow from three different perspectives. For a full customer demo, run all three in sequence (~50 min). For a focused session, pick the one most relevant to the audience.

| Scenario | Focus | Audience | Duration |
|----------|-------|----------|----------|
| 1. Developer Self-Service | Dev picks template in RHDH → repo created → Codespaces opens → starts coding with AI agents → app deployed on Azure | Developers, Engineering Managers | 15 min |
| 2. Platform Engineering | How the template was built → Terraform IaC → GitHub Actions CI/CD → Azure infra provisioned in parallel → GitOps | Platform Engineers, SREs, Architects | 20 min |
| 3. AI-Powered Development | Copilot agents write features → MCP servers manage Azure → Playwright tests auto-generated → Lightspeed AI in RHDH | CTO, VP Engineering, AI/ML Leaders | 15 min |

---

## Source Repository: 3horizons/todo-app

### Architecture

The Todo App follows a classic three-tier architecture designed for Azure deployment. The frontend is a React 18 SPA hosted on Azure Static Web Apps. The backend is a Node.js 20 Express API running on Azure App Service (or Container Apps). Data is stored in PostgreSQL Flexible Server with Redis Cache for performance. All components are monitored via Application Insights.

```
┌─────────────────┐
│  React Frontend  │
│  (Static Web)    │
└────────┬─────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────┐
│  Express API     │◄────►│  PostgreSQL   │
│  (App Service)   │      │  (Flexible)   │
└────────┬─────────┘      └──────────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────┐
│  Redis Cache     │      │  App Insights │
│                  │      │  + Monitoring  │
└─────────────────┘      └──────────────┘
```

### Current Repository Structure

| Folder/File | Contents | Tech Stack |
|-------------|----------|------------|
| frontend/ | React 18 + TypeScript + Vite + Tailwind CSS + React Query + Axios | Azure Static Web Apps |
| backend/ | Node.js 20 + Express + TypeScript + Prisma ORM + Redis + Winston logging | Azure App Service |
| terraform/ | Complete Azure IaC: Resource Group, PostgreSQL, Redis, App Service, Static Web App, App Insights, Key Vault, Log Analytics | Terraform + AzureRM |
| deployments/ | Kubernetes manifests and Helm values for container-based deployment | K8s + Helm |
| .github/workflows/ | 3 CI/CD pipelines: frontend-deploy.yml, backend-deploy.yml, infrastructure-deploy.yml | GitHub Actions |
| .github/agents/ | 5 Copilot agents: playwright-tester, playwright-explorer, playwright-planner, playwright-implementer, azure-infrastructure | Copilot Custom Agents |
| .github/instructions/ | E2E testing conventions and patterns (e2e-testing.instructions.md) | Copilot Instructions |
| e2e/ | Playwright E2E tests: Page Object Model, API mocking, multi-viewport (desktop + mobile) | Playwright |
| .testagent/ | Agent exploration results and test plans | Agent Artifacts |
| .vscode/ | VS Code workspace settings and recommended extensions | VS Code |
| docs/ | Architecture, Chaos Scenarios, Deployment Guide, GitHub Setup Guide | Markdown |
| docker-compose.yml | Local dev environment: PostgreSQL 16 + Redis 7 containers | Docker Compose |
| docker-compose.dev.yml | Extended dev config with hot-reload and volume mounts | Docker Compose |

### Existing Copilot Agents (in repo)

| Agent | Invoke Command | What It Does |
|-------|---------------|--------------|
| Playwright E2E Tester | `@playwright-tester 'Generate tests for Todos page'` | ORCHESTRATOR: Calls explorer → planner → implementer in sequence. Full test pipeline. |
| Playwright Explorer | `@playwright-explorer 'Explore the Dashboard'` | Navigates the running app via Playwright MCP, documents DOM elements, flows, accessibility info. |
| Playwright Test Planner | `@playwright-planner 'Create test plan'` | Reads exploration results + source code → generates phased test plan in .testagent/e2e-plan.md. |
| Playwright Test Implementer | `@playwright-implementer 'Implement Phase 3'` | Writes Page Objects + test specs with API mocking. Runs and fixes up to 3 retries. |
| Azure Infrastructure Expert | `@azure-infrastructure 'Check App Service health'` | Azure IaC guidance, monitoring, troubleshooting, optimization. Knows the Terraform modules. |

### Chaos Scenarios (for SRE demo)

| Scenario | Severity | Trigger Endpoint |
|----------|----------|-----------------|
| Memory Leak | High | POST /api/chaos/memory-leak |
| N+1 Query Problem | Medium | GET /api/todos?inefficient=true |
| Connection Pool Exhaustion | Critical | POST /api/chaos/exhaust-pool |
| CPU Intensive Loop | Critical | POST /api/chaos/cpu-spike |
| Database Timeout | High | POST /api/chaos/db-timeout |
| Cache Invalidation Bug | Medium | PUT /api/todos/:id?skipCache=true |
| Missing Error Handling | Medium | POST /api/todos (malformed data) |
| Unhandled Promise Rejection | High | POST /api/chaos/unhandled-promise |
| Missing Index | Medium | GET /api/todos/search?q=term |
| Infrastructure Drift | Low | Manual Terraform changes |

---

## Files to Add to the Repository

The 3horizons/todo-app repo already has 80% of what we need. Below are the files that must be CREATED or MODIFIED to enable the full Golden Path template experience.

### New Files to Create

| File Path | Purpose | Priority |
|-----------|---------|----------|
| `.devcontainer/devcontainer.json` | Codespaces environment: Node 20, Terraform, Azure CLI, GitHub CLI, Docker-in-Docker, Playwright, VS Code extensions, port forwarding (5173, 3000, 5432, 6379) | P0 — Required |
| `.devcontainer/post-create.sh` | Auto-setup: npm install (frontend + backend), docker-compose up -d, prisma migrate dev, configure MCP servers, display ready message | P0 — Required |
| `catalog-info.yaml.njk` | Backstage/RHDH catalog entity with Nunjucks variables for name, owner, system, environment | P0 — Required |
| `template.yaml` | RHDH Golden Path template definition (url: './' — uses this repo as skeleton) | P0 — Required |
| `terraform/environments/dev.tfvars.njk` | Terraform variables with app name, region, environment | P0 — Required |
| `.github/agents/todo-dev.agent.md` | App development agent: React 18 + Vite + Tailwind + Express + Prisma | P0 — Required |
| `.github/agents/todo-deploy.agent.md` | Deployment agent: Terraform, GitHub Actions, Azure, environment promotion | P0 — Required |
| `.github/agents/todo-sre.agent.md` | SRE agent: chaos scenarios, App Insights, alerts, runbooks | P1 — Recommended |
| `.vscode/mcp.json` | MCP server config: Azure, Terraform, GitHub, Playwright | P1 — Recommended |
| `.github/copilot-instructions.md` | Global Copilot context: project overview, conventions, structure | P1 — Recommended |

---

## Scenario 1 — Developer Self-Service (15 min)

**PERSONA:** Ana, a developer joining the platform team. She needs to build a Todo microservice. Instead of spending days reading docs and configuring tools, she uses the RHDH self-service portal.

**KEY MESSAGE:** "From portal to production in under 10 minutes — zero manual setup."

### Act 1: Login & Discovery (2 min)

**DEMO STEPS:**

1. Open the RHDH portal URL in the browser (devhub.{IP}.nip.io or custom domain)
2. Show the Microsoft-branded login page: white background, 4-color Microsoft logo, "Sign in with GitHub" button
3. Click "Sign in with GitHub" → GitHub OAuth flow → authorize → redirect back to RHDH homepage
4. PAUSE — Show the homepage: Welcome banner (personalized "Hello, Ana"), Quick Access Card (Getting Started, Dev Tools, AI & Automation, Operations), Three Horizons maturity cards (H1 blue, H2 green, H3 yellow), Featured Templates section
5. Click "Create" in the sidebar → Self-service page → template gallery appears
6. HIGHLIGHT: "This is the developer's SINGLE entry point. No more Confluence pages, no Slack messages asking how to create a repo. Everything starts here."

### Act 2: Template Wizard (3 min)

Ana clicks "Choose" on the "Full-Stack Todo Application" template. The wizard has 3 pages:

**PAGE 1 — Application Details:**

| Field | Type | What Ana Fills | Guardrails |
|-------|------|---------------|------------|
| Name | string (text input) | my-todo-app | Pattern: ^[a-z][a-z0-9-]{2,20}$. Only lowercase, hyphens. Prevents naming conflicts. |
| Description | string (text area) | Team task management application | maxLength: 200. Shows in catalog and README. |
| Owner | EntityPicker | user:ana-silva | Picks from RHDH catalog users/groups. Enforces ownership from day zero. |
| System | EntityPicker | three-horizons | Links to parent system in catalog. Enables dependency tracking. |

**PAGE 2 — Infrastructure Configuration:**

| Field | Type | What Ana Fills | Guardrails |
|-------|------|---------------|------------|
| Environment | enum dropdown | dev | Options: dev \| staging \| prod. Controls Terraform SKU sizing and feature flags. |
| Azure Region | enum dropdown | brazilsouth | Options: brazilsouth \| eastus2 \| westeurope. Brazilsouth default for LGPD compliance. |
| Enable Redis Cache | boolean toggle | Yes (checked) | When true, provisions Azure Cache for Redis alongside PostgreSQL. |
| Enable Monitoring | boolean toggle | Yes (checked) | When true, provisions Application Insights + Log Analytics + alert rules. |
| Enable Chaos Scenarios | boolean toggle | Yes (checked) | Only available in dev. Enables /api/chaos/* endpoints for SRE testing. |

**PAGE 3 — Repository Settings:**

| Field | Type | What Ana Fills | Guardrails |
|-------|------|---------------|------------|
| Repository Location | RepoUrlPicker | github.com / 3horizons / my-todo-app | allowedHosts: github.com only. Org must have GitHub App configured. |
| Visibility | enum dropdown | Private | Options: private \| public. Private by default for security. |
| Create Codespace | boolean toggle | Yes (checked) | When true, scaffolder creates a Codespace immediately after repo creation. |
| Branch Protection | boolean toggle | Yes (checked) | When true, configures main branch protection: require PR, 1 approval, status checks. |

**TALKING POINT:** "Notice the guardrails: regex on the name, limited region choices, LGPD-compliant defaults. The developer makes choices — the platform enforces standards. No one can accidentally deploy to a non-compliant region."

### Act 3: Scaffolding (3 min)

Ana clicks "Review" (shows summary) → "Create". The scaffolder executes steps visible in real-time:

| # | Step | Action | Duration | What Happens Behind the Scenes |
|---|------|--------|----------|-------------------------------|
| 1 | Generating Source Code | fetch:template | ~5s | Downloads skeleton from 3horizons/todo-app. Replaces ALL $\{\{ parameters.* \}\} variables: name in catalog-info, region in terraform.tfvars, owner in catalog-info.yaml. |
| 2 | Publishing Repository | publish:github | ~10s | Creates github.com/3horizons/my-todo-app. Pushes all files. Sets default branch to main. Adds topics. |
| 3 | Deploying Infrastructure | github:actions:dispatch | ~3-5 min | Triggers infrastructure-deploy.yml: terraform init → terraform plan (9 resources) → terraform apply. |
| 4 | Registering in Catalog | catalog:register | ~5s | Registers the component in RHDH catalog using catalog-info.yaml. Entity appears with all metadata. |

**TALKING POINT:** "Step 3 (infrastructure) takes 3-5 minutes — but it runs in PARALLEL. By the time Ana opens her Codespace, Azure resources are already being provisioned. She doesn't wait."

### Act 4: Codespace Opens (3 min)

Ana clicks "Open Codespace". Within 90 seconds she has a full VS Code environment:

- VS Code in the browser with the complete Todo app source code, file explorer, terminal, extensions
- Node.js 20 LTS + npm installed
- Terraform 1.5+ installed
- Azure CLI 2.50+ installed
- GitHub CLI 2.30+ installed
- Docker-in-Docker running (PostgreSQL + Redis containers UP)
- Frontend running at localhost:5173, Backend at localhost:3000
- Prisma migrations applied: database schema ready
- 7 Copilot agents available in Chat panel
- MCP servers configured: Azure, Terraform, GitHub, Playwright
- Pre-commit hooks installed: ESLint, Prettier, TypeScript type-check, secret detection

**TALKING POINT:** "Ana did NOT install Node, did NOT configure Docker, did NOT run npm install, did NOT set up a database. The devcontainer did EVERYTHING. Every developer on the team gets the EXACT same environment."

### Act 5: First Feature with AI Agents (4 min)

1. Ana types: `@todo-dev Add a priority field to todos with High, Medium, Low values`
2. The @todo-dev agent responds with a plan: (1) Add priority enum to Prisma schema, (2) Create migration, (3) Update Express routes, (4) Update React components, (5) Add TypeScript types
3. Ana approves → agent generates code across 6 files
4. Ana reviews the diff, makes a small tweak, saves
5. Ana types: `@playwright-tester Generate tests for the priority feature`
6. The agent creates 2 new test files with 8 test cases. ALL PASS.
7. Ana commits and pushes
8. GitHub Actions triggers automatically: lint ✓ → test ✓ → build ✓ → deploy to Azure dev ✓
9. In ~2 minutes, the new feature is live

**TALKING POINT:** "From idea to production in under 5 minutes. The agent wrote the code, another agent wrote the tests, and the pipeline deployed it — all while enforcing the team's standards."

---

## Scenario 2 — Platform Engineering (20 min)

**PERSONA:** Carlos, the platform engineer who DESIGNED the Golden Path template. This scenario reveals what's behind the curtain.

**KEY MESSAGE:** "The platform team builds it once — every developer benefits forever."

### Act 1: The Golden Path Template (5 min)

Carlos opens the template.yaml and walks through each section:

- **METADATA:** apiVersion, kind: Template, name, title, description, tags
- **PARAMETERS:** The 3-page wizard with guardrails (regex, enums, EntityPicker)
- **STEPS:** fetch:template (url: './') → publish:github → github:actions:dispatch → catalog:register
- **OUTPUT:** Links to repo, Codespace, catalog, Azure Portal

**TALKING POINT:** "The template encodes 6 months of platform engineering best practices into a 5-minute wizard."

### Act 2: Infrastructure as Code (5 min)

Carlos opens terraform/ and shows the Azure resources:

| Resource | Terraform Resource | SKU (dev) | SKU (prod) | Key Config |
|----------|-------------------|-----------|------------|------------|
| Resource Group | azurerm_resource_group | — | — | name: rg-{app}-{env}, location: brazilsouth, tags |
| PostgreSQL Flexible | azurerm_postgresql_flexible_server | B_Standard_B1ms, 32GB | GP_Standard_D4s_v3, 128GB | Version 16, geo-backup (prod), private endpoint |
| Redis Cache | azurerm_redis_cache | Basic C0 (256MB) | Standard C1 (1GB) | TLS 1.2 enforced, private endpoint |
| App Service Plan | azurerm_service_plan | B1 (Linux) | P1v3 (Linux) | Autoscale: 1-3 (dev), 2-10 (prod) |
| App Service (Backend) | azurerm_linux_web_app | B1 | P1v3 | Node 20, Docker, App Insights, health check |
| Static Web App (Frontend) | azurerm_static_web_app | Free | Standard | GitHub integration, global CDN |
| Application Insights | azurerm_application_insights | Workspace-based | Workspace-based | Sampling: 100% (dev), 20% (prod) |
| Key Vault | azurerm_key_vault | Standard | Premium | RBAC, soft delete, stores all connection strings |
| Log Analytics | azurerm_log_analytics_workspace | 30-day retention | 90-day retention | Container logs, custom metrics, KQL |

**TALKING POINT:** "The developer chose 'dev' in the wizard. That single choice cascaded through every Terraform resource."

### Act 3: CI/CD Pipelines (5 min)

**PIPELINE 1: infrastructure-deploy.yml**
1. Trigger: push to terraform/** OR workflow_dispatch
2. az login (OIDC federation — no stored credentials)
3. terraform init → terraform plan → APPROVAL GATE (staging/prod) → terraform apply
4. Extract outputs → set GitHub Secrets

**PIPELINE 2: backend-deploy.yml**
1. Trigger: push to backend/** on main
2. npm ci → lint → test → build → docker build → push ACR → az webapp deploy → health check

**PIPELINE 3: frontend-deploy.yml**
1. Trigger: push to frontend/** on main
2. npm ci → lint → build → deploy Static Web App → Playwright E2E tests → promote

### Act 4: Show Parallel Execution (3 min)

1. Open GitHub Actions tab → infrastructure-deploy workflow RUNNING
2. Show Terraform plan: "9 resources to create"
3. Switch to Codespace — Ana is already coding
4. Switch back — apply completed. Show Azure Portal: all resources green.
5. Show Key Vault and GitHub Secrets auto-populated

### Act 5: MCP Server Alternative (2 min)

- `@azure Create a resource group rg-todo-dev in brazilsouth`
- `@azure Deploy PostgreSQL Flexible Server with B_Standard_B1ms SKU`
- `@azure Show me the connection string for the PostgreSQL server`
- **TALKING POINT:** "GitHub Actions = automated. MCP = interactive. Both valid."

---

## Scenario 3 — AI-Powered Development (15 min)

**PERSONA:** The audience (CTO, VP Engineering).

**KEY MESSAGE:** "AI agents that understand YOUR project, YOUR conventions, and YOUR infrastructure — not generic chatbots."

### Act 1: Feature Development with @todo-dev (4 min)

| Developer Request | Agent | Files Modified | What the Agent Generates |
|-------------------|-------|---------------|--------------------------|
| "Add project categorization to todos" | @todo-dev | 6 files | Prisma schema (Project model + relation), Express routes (/api/projects), React components (ProjectSelector, ProjectFilter), TypeScript interfaces |
| "Review my changes for security issues" | @reviewer | — | Scans for SQL injection, checks auth middleware, validates input sanitization, reviews CORS config |
| "Generate E2E tests for projects feature" | @playwright-tester | 2 test files | Explores app → discovers routes → creates test plan → implements tests → runs in Chromium + mobile |
| "Create deployment PR for dev" | @todo-deploy | 1 PR | Creates PR, triggers CI pipeline, shows deployment preview, links to Azure resources |

### Act 2: MCP Servers in Action (5 min)

| MCP Server | Demo Command | What It Does |
|------------|-------------|--------------|
| Azure MCP | `@azure Show me the health of my App Service` | Calls az webapp show, az monitor metrics list — returns CPU, memory, request count in real-time |
| Terraform MCP | `@terraform What resources are in my state?` | Calls terraform state list — shows all 9 Azure resources. Then terraform plan — shows no drift. |
| GitHub MCP | `@github Show open PRs and their CI status` | Calls gh pr list — shows PRs with checks status |
| Playwright MCP | `@playwright-explorer Navigate to the Projects page` | Opens browser, navigates, documents elements and flows |

### Act 3: Lightspeed AI in RHDH (5 min)

- Open the Lightspeed chat panel in RHDH
- "What is the architecture of my-todo-app?" → RAG-powered response with architecture and tech stack
- "How do I add a new API endpoint?" → Step-by-step guide based on project patterns
- "Show me the deployment status" → Queries GitHub Actions + Azure Monitor
- "What chaos scenarios are available?" → Returns 10 scenarios from docs

---

## Golden Path Template Specification

### template.yaml — Parameters

| Step | Parameter | Type | Validation | Default |
|------|-----------|------|------------|---------|
| 1. App Details | name | string | pattern: ^[a-z][a-z0-9-]{2,20}$, required | my-todo-app |
| 1. App Details | description | string | maxLength: 200 | Full-stack Todo application |
| 1. App Details | owner | string (EntityPicker) | kind: [User, Group] | (current user) |
| 1. App Details | system | string (EntityPicker) | kind: [System] | three-horizons |
| 2. Infrastructure | environment | string (enum) | dev \| staging \| prod | dev |
| 2. Infrastructure | azure_region | string (enum) | brazilsouth \| eastus2 \| westeurope | brazilsouth |
| 2. Infrastructure | enable_redis | boolean | — | true |
| 2. Infrastructure | enable_monitoring | boolean | — | true |
| 3. Repository | repoUrl | string (RepoUrlPicker) | allowedHosts: github.com | — |
| 3. Repository | visibility | string (enum) | private \| public | private |

### template.yaml — Steps

| # | Step ID | Action | Description |
|---|---------|--------|-------------|
| 1 | fetch-skeleton | fetch:template | Copy this repo (url: './'), process .njk files with variable substitution |
| 2 | publish-repo | publish:github | Create new GitHub repo, push all files, set default branch to main |
| 3 | deploy-infrastructure | github:actions:dispatch | Trigger infrastructure-deploy.yml → Terraform provisions Azure resources |
| 4 | register-catalog | catalog:register | Register component in RHDH catalog via catalog-info.yaml |

### template.yaml — Output Links

| Link | URL | Icon |
|------|-----|------|
| Open Repository | $\{\{ steps.publish-repo.output.remoteUrl \}\} | github |
| Open Codespace | $\{\{ steps.publish-repo.output.remoteUrl \}\}/codespaces/new | code |
| View in Catalog | $\{\{ steps.register-catalog.output.entityRef \}\} | catalog |
| View Azure Resources | https://portal.azure.com | cloud |

---

## Codespaces / devcontainer.json Specification

### Features & Tools

| Category | Tool | Version | Purpose |
|----------|------|---------|---------|
| Runtime | Node.js | 20 LTS | Frontend + Backend development |
| IaC | Terraform | 1.5+ | Infrastructure provisioning |
| Cloud CLI | Azure CLI | 2.50+ | Azure resource management |
| DevOps CLI | GitHub CLI (gh) | 2.30+ | Repo, PR, Actions management |
| Containers | Docker-in-Docker | latest | Local PostgreSQL + Redis via docker-compose |
| Testing | Playwright + Chromium | latest | E2E browser testing |
| Database | Prisma CLI | latest | ORM and migration management |
| Quality | ESLint + Prettier | latest | Code linting and formatting |

### VS Code Extensions (auto-installed)

| Extension | Purpose |
|-----------|---------|
| GitHub.copilot + GitHub.copilot-chat | AI pair programming + custom agents |
| hashicorp.terraform | Terraform syntax, validation, autocomplete |
| ms-azuretools.vscode-azurefunctions | Azure resource explorer |
| prisma.prisma | Prisma schema syntax + autocomplete |
| dbaeumer.vscode-eslint | JavaScript/TypeScript linting |
| esbenp.prettier-vscode | Code formatting |
| ms-playwright.playwright | Playwright test runner |
| bradlc.vscode-tailwindcss | Tailwind CSS IntelliSense |

### Post-Create Script (auto-runs)

1. `cd frontend && npm install`
2. `cd backend && npm install`
3. `docker-compose up -d` (starts PostgreSQL + Redis)
4. `cd backend && npx prisma migrate dev` (runs database migrations)
5. `cp .vscode/mcp.json.template .vscode/mcp.json` (configures MCP servers)
6. `echo 'Environment ready! Frontend: localhost:5173 | Backend: localhost:3000'`

---

## Copilot Agents for the Todo App

| Agent | Domain | Tools | Key Capabilities |
|-------|--------|-------|-----------------|
| @todo-dev | Application Development | edit, search, terminal, read | Knows React 18 + Vite + Tailwind patterns, Express + Prisma conventions, TypeScript interfaces. Generates feature code across frontend + backend + database. |
| @todo-deploy | Deployment Orchestration | terminal, github, search | Runs Terraform commands, triggers GitHub Actions, checks Azure health, manages secrets. Handles dev/staging/prod promotion. |
| @todo-sre | SRE & Monitoring | terminal, search, read | Triggers chaos scenarios, reads App Insights metrics, creates alert rules, writes runbooks. Knows the 10 chaos scenarios. |
| @playwright-tester | E2E Testing | terminal, edit, search, read | Orchestrates the test pipeline: explore → plan → implement → run. Creates Page Objects and specs with API mocking. |
| @playwright-explorer | App Exploration | terminal, read | Navigates the running app via Playwright MCP, documents DOM elements, flows, and interactive components. |

### Agent Handoff Flow

@todo-dev → @playwright-tester → @todo-deploy → @todo-sre

---

## Pre-Demo Checklist

### Environment

| Check | Command / Action | Expected Result |
|-------|-----------------|-----------------|
| RHDH portal accessible | Open devhub.{IP}.nip.io | Microsoft-branded login page |
| GitHub OAuth working | Click "Sign in with GitHub" | Redirect → GitHub → back to RHDH homepage |
| Template registered | Go to Create → search "Todo" | Full-Stack Todo Application template visible |
| Azure subscription active | `az account show` | Active subscription with contributor access |
| GitHub org ready | `gh repo list 3horizons` | Org accessible, PAT has repo + workflow scopes |
| Codespaces enabled | `gh codespace list` | Codespaces feature enabled for the org |
| Terraform backend | Check Azure Storage Account for tfstate | Storage account with container "tfstate" exists |

### Demo Credentials

| Secret | Where | How to Set |
|--------|-------|-----------|
| AZURE_CREDENTIALS | GitHub Org Secret | `az ad sp create-for-rbac --role Contributor --scopes /subscriptions/{id} --sdk-auth` |
| AZURE_SUBSCRIPTION_ID | GitHub Org Secret | `az account show --query id -o tsv` |
| GITHUB_TOKEN (PAT) | RHDH Secret | Scopes: repo, workflow, codespace, read:org, admin:org |
| RHDH OAuth App | GitHub Developer Settings | Callback: `https://devhub.*.nip.io/api/auth/github/handler/frame` |

### Cleanup After Demo

1. Delete the demo repo: `gh repo delete 3horizons/my-todo-app --yes`
2. Delete Azure resources: `az group delete -n rg-my-todo-app-dev --yes --no-wait`
3. Delete Codespace: `gh codespace delete --repo 3horizons/my-todo-app --all`
4. Remove catalog entity from RHDH: go to catalog → my-todo-app → unregister

---

## Implementation Timeline

| Week | Deliverable | Owner |
|------|------------|-------|
| W1 | Create .devcontainer/devcontainer.json + post-create.sh in 3horizons/todo-app | Platform Engineer |
| W1 | Create catalog-info.yaml.njk with Backstage entity definition | Platform Engineer |
| W1 | Create/update .github/agents/ with todo-dev, todo-deploy, todo-sre agents | Platform Engineer |
| W1 | Configure .vscode/mcp.json with Azure, Terraform, GitHub, Playwright MCP servers | Platform Engineer |
| W2 | Create template.yaml in the repo root (Option A: same repo) | Platform Engineer |
| W2 | Create terraform/environments/dev.tfvars.njk with variables | Platform Engineer |
| W2 | Register the template in RHDH catalog | Platform Engineer |
| W2 | Test full flow: template → repo → Codespace → Azure → deploy | Platform + SRE |
| W3 | Dry-run demo 3x with timing and talking points | All presenters |
| W3 | Record backup video in case of live-demo failure | All presenters |

---

## Sources

1. [3horizons/todo-app Repository](https://github.com/3horizons/todo-app)
2. [RHDH 1.8 Software Templates](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.8/html/streamline_software_development/)
3. [Golden Paths and Developer Productivity](https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity)
4. Developer Portals Summit eBook (project knowledge)
5. [GitHub Codespaces Dev Containers](https://docs.github.com/en/codespaces/setting-up-your-project-for-codespaces/adding-a-dev-container-configuration)
6. [GitHub Copilot Custom Agents](https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-custom-agents)
7. [Backstage Software Templates](https://backstage.io/docs/features/software-templates/)
8. [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
9. Three Horizons RHDH Deploy Guide (project knowledge)
10. DEPLOY_CUSTOMIZATIONS_GUIDE (project knowledge)
