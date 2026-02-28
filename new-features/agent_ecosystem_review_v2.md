# Three Horizons Accelerator — Agent Ecosystem Review v2.0

| Field | Value |
|-------|-------|
| **Date** | February 26, 2026 |
| **Version** | 2.0 |
| **Author** | paulasilva@microsoft.com |
| **Total Agents** | 18 + 1 meta-template |
| **Status** | Complete Review |

---

## 1. Executive Summary

This document presents a comprehensive audit of all 18 agents in the Three Horizons Accelerator multi-agent system. The review maps every agent's responsibilities, handoffs, boundaries, and identifies structural issues that should be addressed.

**Key Findings:**

- **18 agents** are defined and operational (+ 1 AGENT_TEMPLATE meta-prompt)
- **`rhdh-expert` exists** and correctly separates RHDH from Backstage — good architecture
- **3 structural overlaps** found between `platform`, `template-engineer`, and portal agents
- **2 tools/frontmatter issues** in `deploy` and `architect` agents (oversized tools lists)
- **1 scope ambiguity** in `platform` agent (says "maintain RHDH" but should be portal-agnostic)
- **0 missing agents** for current scope — the ecosystem is complete
- **Recommendation:** Refine `platform` agent scope, fix tools lists, clarify template ownership

---

## 2. Complete Agent Inventory

### 2.1 Agent Catalog

| # | Agent Name | File | Domain | Solo Task? | Handoffs Out |
|---|-----------|------|--------|------------|-------------|
| 1 | `architect` | architect_agent.md | Solution Design, WAF, ADRs | ✅ | terraform, security |
| 2 | `terraform` | terraform_agent.md | Azure IaC (Terraform) | ✅ | security, devops |
| 3 | `security` | security_agent.md | Compliance, Vulnerabilities, Zero Trust | ✅ | devops |
| 4 | `reviewer` | reviewer_agent.md | Code Quality, SOLID, Clean Code | ✅ | security |
| 5 | `test` | test_agent.md | TDD, Unit/Integration/E2E | ✅ | reviewer |
| 6 | `docs` | docs_agent.md | Technical Writing, ADRs, Mermaid | ✅ | architect |
| 7 | `sre` | sre_agent.md | Observability, SLOs, Incidents | ✅ | devops, security |
| 8 | `devops` | devops_agent.md | CI/CD, GitHub Actions, ArgoCD, K8s | ✅ | security, platform |
| 9 | `deploy` | deploy_agent.md | Deployment Orchestration | ✅ | 9 agents (orchestrator) |
| 10 | `onboarding` | onboarding_agent.md | New User Guidance | ✅ | architect, terraform, deploy |
| 11 | `platform` | platform_agent.md | IDP Strategy, Catalog, Golden Paths | ⚠️ | devops, security, backstage-expert, rhdh-expert |
| 12 | `backstage-expert` | backstage-expert_agent.md | Backstage Deploy + Static Plugins + Config | ✅ | 8 agents |
| 13 | `rhdh-expert` | rhdh-expert_agent.md | RHDH Deploy + Dynamic Plugins + RBAC + Helm | ✅ | 8 agents |
| 14 | `azure-portal-deploy` | azure-portal-deploy_agent.md | Azure AKS/ARO Provisioning | ✅ | backstage-expert, rhdh-expert, terraform, security |
| 15 | `github-integration` | github-integration_agent.md | GitHub App, OAuth, Org Discovery, GHAS | ✅ | backstage-expert, rhdh-expert, security, hybrid-scenarios |
| 16 | `ado-integration` | ado-integration_agent.md | ADO PAT, Pipelines, Boards, Copilot | ✅ | backstage-expert, rhdh-expert, hybrid-scenarios |
| 17 | `hybrid-scenarios` | hybrid-scenarios_agent.md | GitHub + ADO Coexistence (A/B/C) | ✅ | github-integration, ado-integration, backstage-expert, rhdh-expert |
| 18 | `template-engineer` | template-engineer_agent.md | Software Templates + Codespaces | ✅ | 8 agents |
| — | `AGENT_TEMPLATE` | AGENT_TEMPLATE.md | Meta: generates AGENTS.md files | N/A | N/A |

### 2.2 Agent Groups

```
┌─────────────────────────────────────────────────────────────┐
│                    GROUP 1: FOUNDATION                       │
│  (Technology-agnostic, work on any codebase)                │
│                                                             │
│  architect · terraform · security · reviewer                │
│  test · docs · sre                                          │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    GROUP 2: DELIVERY                         │
│  (CI/CD, deployment, user guidance)                         │
│                                                             │
│  devops · deploy · onboarding                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                GROUP 3: AZURE INFRASTRUCTURE                │
│  (Cloud provisioning)                                       │
│                                                             │
│  azure-portal-deploy                                        │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│              GROUP 4: PORTAL — BACKSTAGE                    │
│  (Backstage upstream on AKS only)                           │
│                                                             │
│  backstage-expert                                           │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                 GROUP 5: PORTAL — RHDH                      │
│  (Red Hat Developer Hub on AKS or ARO)                      │
│                                                             │
│  rhdh-expert                                                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│            GROUP 6: PORTAL — SHARED SERVICES                │
│  (Work with both Backstage and RHDH)                        │
│                                                             │
│  template-engineer · platform · github-integration          │
│  ado-integration · hybrid-scenarios                         │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Handoff Matrix

### 3.1 Complete Handoff Map

| Source Agent | → Target Agents |
|-------------|----------------|
| `architect` | `terraform`, `security` |
| `terraform` | `security`, `devops` |
| `security` | `devops` |
| `reviewer` | `security` |
| `test` | `reviewer` |
| `docs` | `architect` |
| `sre` | `devops`, `security` |
| `devops` | `security`, `platform` |
| `deploy` | `security`, `terraform`, `sre`, `backstage-expert`, `rhdh-expert`, `azure-portal-deploy`, `github-integration`, `ado-integration`, `hybrid-scenarios` |
| `onboarding` | `architect`, `terraform`, `deploy` |
| `platform` | `devops`, `security`, `backstage-expert`, `rhdh-expert` |
| `backstage-expert` | `azure-portal-deploy`, `github-integration`, `ado-integration`, `hybrid-scenarios`, `deploy`, `platform`, `security`, `rhdh-expert` |
| `rhdh-expert` | `azure-portal-deploy`, `github-integration`, `ado-integration`, `hybrid-scenarios`, `deploy`, `platform`, `security`, `backstage-expert` |
| `azure-portal-deploy` | `backstage-expert`, `rhdh-expert`, `terraform`, `security` |
| `github-integration` | `backstage-expert`, `rhdh-expert`, `security`, `hybrid-scenarios` |
| `ado-integration` | `backstage-expert`, `rhdh-expert`, `hybrid-scenarios` |
| `hybrid-scenarios` | `github-integration`, `ado-integration`, `backstage-expert`, `rhdh-expert` |
| `template-engineer` | `backstage-expert`, `rhdh-expert`, `github-integration`, `ado-integration`, `security`, `platform`, `devops`, `hybrid-scenarios` |

### 3.2 Most Connected Agents (Hub Score)

| Agent | Outbound | Inbound | Total | Role |
|-------|----------|---------|-------|------|
| `deploy` | 9 | 3 | 12 | **Orchestrator** — highest connectivity |
| `backstage-expert` | 8 | 8 | 16 | **Hub** — Backstage ecosystem center |
| `rhdh-expert` | 8 | 8 | 16 | **Hub** — RHDH ecosystem center |
| `template-engineer` | 8 | 0 | 8 | **Producer** — creates, delegates |
| `security` | 1 | 8 | 9 | **Sink** — receives from many, delegates little |
| `devops` | 2 | 4 | 6 | **Executor** — receives and executes |
| `terraform` | 2 | 3 | 5 | **Specialist** — focused domain |

### 3.3 Handoff Chains (Common Workflows)

**New Project Setup:**
```
onboarding → deploy → azure-portal-deploy → backstage-expert/rhdh-expert → template-engineer → platform
```

**Infrastructure Change:**
```
architect → terraform → security → devops → platform
```

**Incident Response:**
```
sre → devops → security (if needed)
```

**Template Creation:**
```
template-engineer → security → platform → backstage-expert/rhdh-expert
```

**Hybrid Integration:**
```
hybrid-scenarios → github-integration + ado-integration → backstage-expert/rhdh-expert
```

---

## 4. Technology Separation: Backstage vs RHDH

### 4.1 Why They Must Be Separate Agents

| Aspect | Backstage (upstream) | RHDH (Red Hat Developer Hub) |
|--------|---------------------|-------------------------------|
| **Plugin Model** | Static — `yarn add`, code edit, rebuild Docker image | Dynamic — YAML config only, no rebuild |
| **Plugin Install** | `yarn add @backstage/plugin-xxx` + wiring in `EntityPage.tsx` | `dynamic-plugins.yaml` with `disabled: false` |
| **EntityPage** | Edit `EntityPage.tsx` in TypeScript/React | Pre-composed via dynamic plugin frontend config |
| **Configuration** | `app-config.yaml` + `app-config.production.yaml` | Helm `values.yaml` + ConfigMap `app-config-rhdh` |
| **Auth Setup** | Code module baked into custom Docker image + config | Helm values only (no code changes) |
| **RBAC** | Community plugin (`@janus-idp/backstage-plugin-rbac`) | Built-in, CSV permission policies |
| **Deployment** | Custom Docker image → Helm on AKS | Helm chart or Operator CR on AKS/ARO |
| **Cluster Options** | AKS only | AKS or ARO (OpenShift) |
| **Ingress** | Ingress + cert-manager | OpenShift Routes (ARO) or Ingress (AKS) |
| **Plugin Ecosystem** | 146+ community plugins on npmjs.com | Red Hat certified + Janus-IDP curated |
| **TechDocs** | Build locally or via CI, config in app-config | Same logic, config via Helm values |
| **Image Source** | Custom built from `backstage/packages/backend/Dockerfile` | `registry.redhat.io/rhdh` (requires Red Hat sub) |

### 4.2 Current Agent Coverage — Correct ✅

| Responsibility | Covered By | Technology |
|----------------|-----------|------------|
| Deploy Backstage on AKS | `backstage-expert` | Backstage |
| Build custom Backstage Docker image | `backstage-expert` | Backstage |
| Static plugin installation (npm) | `backstage-expert` | Backstage |
| EntityPage.tsx composition | `backstage-expert` | Backstage |
| app-config.yaml management | `backstage-expert` | Backstage |
| Deploy RHDH on AKS or ARO | `rhdh-expert` | RHDH |
| Dynamic plugin configuration | `rhdh-expert` | RHDH |
| Helm values management | `rhdh-expert` | RHDH |
| RBAC CSV policies | `rhdh-expert` | RHDH |
| Operator CR management (ARO) | `rhdh-expert` | RHDH |
| ConfigMap management | `rhdh-expert` | RHDH |
| Software Templates (v1beta3) | `template-engineer` | Both (shared API) |
| GitHub App / OAuth | `github-integration` | Both |
| ADO PAT / Pipelines | `ado-integration` | Both |
| Hybrid Scenarios (A/B/C) | `hybrid-scenarios` | Both |
| Catalog strategy | `platform` | Both |
| AKS/ARO provisioning | `azure-portal-deploy` | Both |

**Verdict:** The separation is architecturally sound. Each portal technology has its own expert agent.

---

## 5. Issues Found

### 5.1 Overlaps (3 found)

#### Overlap 1: `platform` ↔ `template-engineer` — Template Creation

| Agent | Claims | Evidence |
|-------|--------|----------|
| `platform` | "Create and edit Backstage templates (`template.yaml`)" | Capabilities section |
| `template-engineer` | Full template creation with skeleton, devcontainer, Codespaces | Entire agent purpose |

**Impact:** User confusion on who to call for template work.
**Recommendation:** Remove template creation from `platform`. Its role should be **strategy** (which templates to build, catalog organization) not **implementation** (writing template.yaml). Add explicit note: "For template creation, handoff to `@template-engineer`".

#### Overlap 2: `platform` ↔ `rhdh-expert` — RHDH Operations

| Agent | Claims | Evidence |
|-------|--------|----------|
| `platform` | Identity says "maintain the Red Hat Developer Hub (RHDH)" | Identity section |
| `platform` | Skill Set: "RHDH Portal Operations — Validate template syntax, Interact with catalog API" | Skill Set section |
| `rhdh-expert` | Full RHDH deployment, configuration, and operations | Entire agent purpose |

**Impact:** `platform` agent may attempt RHDH-specific tasks it shouldn't own.
**Recommendation:** Refine `platform` identity to be **portal-agnostic**. Remove "maintain the RHDH" and change to "maintain the Internal Developer Platform strategy". Remove RHDH-specific skill references.

#### Overlap 3: Portal Agents ↔ `template-engineer` — Golden Path Registration

| Agent | Claims | Evidence |
|-------|--------|----------|
| `backstage-expert` | "Register Golden Path templates (H1 + H2) in the catalog" | Capabilities |
| `rhdh-expert` | "Register Golden Path templates (H1 + H2) in the catalog" | Capabilities |
| `template-engineer` | Creates complete templates ready for registration | Task Decomposition |

**Impact:** Low — registration is a natural follow-up to either creation or deployment.
**Recommendation:** Clarify ownership: `template-engineer` **creates** templates. Portal agents **register** them. `platform` **decides which** to create.

### 5.2 Structural Issues (2 found)

#### Issue 1: `deploy` agent — Oversized Tools List

The `deploy` agent frontmatter contains **50+ tools** that appear copy-pasted from VS Code agent mode:

```yaml
tools:vscode/getProjectSetupInfo, vscode/installExtension, vscode/memory, vscode/newWorkspace...
```

**Impact:** Noise in the agent definition. Most tools are irrelevant to deployment.
**Recommendation:** Reduce to the tools actually used:
```yaml
tools:
  - search/codebase
  - edit/editFiles
  - execute/runInTerminal
  - read/problems
```

#### Issue 2: `architect` agent — Same Oversized Tools List

The `architect` agent also has the massive tools list, but its boundaries say "🚫 NEVER Run CLI Commands".

**Impact:** Contradiction between tools and boundaries.
**Recommendation:** Reduce to read-only tools:
```yaml
tools:
  - search/codebase
  - read/problems
```

### 5.3 Scope Ambiguity (1 found)

#### `platform` Agent — Identity Mismatch

| Section | Says | Should Say |
|---------|------|-----------|
| Identity | "maintain the Red Hat Developer Hub (RHDH) and the Service Catalog" | "maintain the Internal Developer Platform strategy and the Service Catalog" |
| Skill Set | "RHDH Portal Operations" | "Portal Strategy (portal-agnostic)" |
| Task Step 1 | "Check current RHDH status" | "Check current portal status" |

**Impact:** Agent tries to do RHDH-specific work instead of staying at strategy level.
**Recommendation:** Make `platform` fully portal-agnostic. It decides WHAT to build; portal experts decide HOW.

---

## 6. Task Ownership Matrix

### 6.1 "Who Do I Call?" Decision Tree

| User Question | Primary Agent | Secondary |
|---------------|--------------|-----------|
| "Design a new architecture" | `architect` | |
| "Write Terraform for AKS" | `terraform` | |
| "Review my code" | `reviewer` | `security` |
| "Write tests for this module" | `test` | |
| "Set up CI/CD pipeline" | `devops` | |
| "Deploy the platform" | `deploy` | (orchestrates others) |
| "I'm new, help me start" | `onboarding` | |
| "Check why pods are crashing" | `sre` | `devops` |
| "Scan for vulnerabilities" | `security` | |
| "Update the README" | `docs` | |
| "Create a Golden Path template" | `template-engineer` | |
| "Which templates should we build?" | `platform` | |
| "Set up Backstage on AKS" | `backstage-expert` | `azure-portal-deploy` |
| "Set up RHDH on ARO" | `rhdh-expert` | `azure-portal-deploy` |
| "Provision AKS cluster" | `azure-portal-deploy` | `terraform` |
| "Configure GitHub App for portal" | `github-integration` | |
| "Connect ADO to the portal" | `ado-integration` | |
| "We use both GitHub and ADO" | `hybrid-scenarios` | |
| "Install Kubernetes plugin on Backstage" | `backstage-expert` | |
| "Enable dynamic plugin on RHDH" | `rhdh-expert` | |
| "Configure RBAC on RHDH" | `rhdh-expert` | |
| "Switch from Backstage to RHDH" | `backstage-expert` → `rhdh-expert` | |

### 6.2 Template Lifecycle Ownership

```
WHO decides which templates → platform
WHO creates templates      → template-engineer
WHO reviews templates      → security + reviewer
WHO registers templates    → backstage-expert (Backstage) or rhdh-expert (RHDH)
WHO deploys via templates  → devops (CI/CD in skeleton)
```

---

## 7. Boundary Analysis

### 7.1 Destructive Actions — Never Allowed

| Action | Blocked By |
|--------|-----------|
| `terraform apply` (without confirmation) | terraform, deploy |
| `terraform destroy` | terraform, deploy |
| Delete production K8s resources | devops |
| Delete catalog entities | platform |
| Delete repos | github-integration |
| Delete ADO resources | ado-integration |
| Grant IAM access | security |
| Disable security controls | security |
| Merge code | reviewer |
| Auto-approve PRs | reviewer |
| Skip failing tests | test |
| Expose secrets | ALL agents |

### 7.2 "Ask First" Actions

| Action | Agent | Why |
|--------|-------|-----|
| `terraform plan` | terraform | Needs read-only access |
| `terraform apply` | deploy | Confirm plan first |
| Create GitHub App | github-integration, backstage-expert, rhdh-expert | Needs org admin |
| Create ADO PAT | ado-integration | Needs ADO admin |
| Configure RBAC | rhdh-expert, hybrid-scenarios | May restrict access |
| Register in catalog | platform | Needs portal URL |
| Restart pods | devops, sre | Explain impact |
| Scale clusters | sre | Cost implication |
| Edit config files | onboarding | User confirms content |
| Configure dual auth | hybrid-scenarios | Impacts all users |

---

## 8. Skills Reference Map

### 8.1 Shared Skills (Used by Multiple Agents)

| Skill | Used By |
|-------|---------|
| Terraform CLI | terraform, deploy, backstage-expert, rhdh-expert, azure-portal-deploy |
| Azure CLI | terraform, deploy, backstage-expert, rhdh-expert, azure-portal-deploy, security |
| Kubectl CLI | devops, deploy, sre, backstage-expert, rhdh-expert, azure-portal-deploy, platform |
| GitHub CLI | devops, backstage-expert, rhdh-expert, github-integration |
| Helm CLI | devops, azure-portal-deploy |
| Validation Scripts | security, onboarding, deploy |
| Codespaces Golden Paths | backstage-expert, rhdh-expert, template-engineer |

### 8.2 Exclusive Skills

| Skill | Only Used By |
|-------|-------------|
| Backstage Deployment | backstage-expert |
| RHDH Portal | rhdh-expert, platform |
| ARO Deployment | rhdh-expert, azure-portal-deploy |
| OC CLI (OpenShift) | rhdh-expert |
| ArgoCD CLI | devops |
| Observability Stack | sre |
| Deploy Orchestration | deploy |
| Prerequisites | onboarding, deploy |

---

## 9. Recommendations Summary

### 9.1 Priority Actions

| # | Action | Agent | Effort | Impact |
|---|--------|-------|--------|--------|
| 1 | Fix `deploy` tools list — reduce to 4 core tools | deploy | Low | Clean frontmatter |
| 2 | Fix `architect` tools list — reduce to 2 read-only tools | architect | Low | Fix boundary contradiction |
| 3 | Refine `platform` identity — make portal-agnostic | platform | Medium | Remove overlap with rhdh-expert |
| 4 | Remove template creation from `platform` capabilities | platform | Low | Clarify template-engineer ownership |
| 5 | Add "template lifecycle" note to portal agents | backstage-expert, rhdh-expert | Low | Clarify registration vs creation |

### 9.2 No New Agents Needed

The current 18-agent architecture covers all identified use cases. The technology separation between Backstage and RHDH is correct. The `template-engineer` fills the template gap. Portal-agnostic services (GitHub, ADO, hybrid) work with both portals via handoffs.

---

## 10. Appendix: Agent Quick Reference Cards

### architect
- **Role:** Principal Solution Architect
- **Does:** Design systems, ADRs, WAF evaluation, Mermaid diagrams
- **Never:** Writes code, runs CLI commands
- **Hands off to:** terraform (IaC), security (review)

### terraform
- **Role:** Terraform Engineer (Azure)
- **Does:** Write/edit .tf files, fmt, validate, plan
- **Never:** apply, destroy, read secrets
- **Hands off to:** security (review), devops (CI/CD)

### security
- **Role:** Security Engineer (Zero Trust)
- **Does:** Scan, audit, classify findings, suggest fixes
- **Never:** Grant access, disable controls, view secrets
- **Hands off to:** devops (implement fixes)

### reviewer
- **Role:** Senior Code Reviewer
- **Does:** Static analysis, logic review, style enforcement
- **Never:** Auto-approve PRs, merge code, ignore tests
- **Hands off to:** security (deep analysis)

### test
- **Role:** SDET (Testing Pyramid)
- **Does:** TDD, unit/integration/e2e tests, coverage
- **Never:** Skip failing tests, commit flaky tests
- **Hands off to:** reviewer (code review)

### docs
- **Role:** Technical Writer
- **Does:** READMEs, ADRs, Mermaid diagrams, Markdown
- **Never:** Invent information, delete history
- **Hands off to:** architect (technical accuracy)

### sre
- **Role:** Site Reliability Engineer
- **Does:** Observability, SLOs, incident response, troubleshooting
- **Never:** Ignore errors, expose PII
- **Hands off to:** devops (deploy fix), security (security incident)

### devops
- **Role:** DevOps Specialist (GitOps)
- **Does:** GitHub Actions, ArgoCD, K8s debugging, Helm
- **Never:** Delete production resources, bypass CI checks
- **Hands off to:** security (pipeline review), platform (registration)

### deploy
- **Role:** Deployment Orchestrator
- **Does:** Orchestrate 12-step deployment, validate, troubleshoot
- **Never:** terraform destroy, modify secrets directly
- **Hands off to:** 9 specialist agents based on deployment phase

### onboarding
- **Role:** Onboarding Specialist
- **Does:** Prerequisites, configuration, education, first deploy
- **Never:** Skip checks
- **Hands off to:** architect (customization), terraform (config), deploy (deployment)

### platform
- **Role:** Platform Engineer (DevEx Strategy)
- **Does:** Catalog management, Golden Path strategy, TechDocs structure
- **Never:** Delete catalog entities, expose internal APIs
- **Hands off to:** devops (GitOps), security (review), portal experts (config)

### backstage-expert
- **Role:** Backstage Platform Engineer (AKS only)
- **Does:** Deploy Backstage, build custom images, static plugins, EntityPage, app-config, Codespaces
- **Never:** Deploy to ARO, deploy outside Central/East US, disable auth in prod
- **Hands off to:** azure-portal-deploy (infra), github-integration (auth), rhdh-expert (switch)

### rhdh-expert
- **Role:** RHDH Platform Engineer (AKS or ARO)
- **Does:** Deploy RHDH, dynamic plugins, RBAC, Helm/Operator, ConfigMaps, Codespaces
- **Never:** Deploy outside Central/East US, use without Red Hat subscription, disable auth in prod
- **Hands off to:** azure-portal-deploy (infra), github-integration (auth), backstage-expert (switch)

### azure-portal-deploy
- **Role:** Azure Infrastructure Engineer
- **Does:** Provision AKS/ARO, Key Vault, PostgreSQL, ACR, Helm/Operator install
- **Never:** Deploy outside Central/East US, store secrets in ConfigMap, use SQLite in prod
- **Hands off to:** backstage-expert or rhdh-expert (portal config), terraform (issues)

### github-integration
- **Role:** GitHub Integration Engineer
- **Does:** GitHub Apps, org discovery, GHAS, Actions, Packages, supply chain security
- **Never:** Delete repos
- **Hands off to:** backstage-expert or rhdh-expert (portal config), security (review)

### ado-integration
- **Role:** ADO Integration Engineer
- **Does:** PAT setup, repo discovery, pipeline creation, boards, Copilot licensing
- **Never:** Delete ADO resources
- **Hands off to:** backstage-expert or rhdh-expert (portal config), hybrid-scenarios

### hybrid-scenarios
- **Role:** Hybrid Integration Architect
- **Does:** Scenario A/B/C design, dual auth, hybrid templates, cross-platform catalog
- **Never:** N/A (all actions require confirmation)
- **Hands off to:** github-integration (GitHub), ado-integration (ADO), portal experts (config)

### template-engineer
- **Role:** Backstage Software Template Engineer
- **Does:** Create templates from scratch, convert repos, devcontainer.json, Codespaces, Nunjucks, validation
- **Never:** Deploy portals, manage infrastructure, modify live catalog, hardcode secrets, skip devcontainer
- **Hands off to:** backstage-expert or rhdh-expert (registration), security (review), platform (strategy)
