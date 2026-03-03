# Three Horizons Developer Hub — Full Implementation Guide

## Microsoft Foundry (Claude Sonnet 4.6 Extended Thinking) + RHDH 1.8 MCP + 10 MCP Servers + Agentic DevOps Platform

**Version:** 2.0
**Date:** March 2026
**Author:** paulasilva@microsoft.com | Latam Software GBB
**Status:** Implementation Blueprint

---

## 1. Executive Summary

This guide covers the **end-to-end implementation** of the Three Horizons Developer Hub — an AI-powered Internal Developer Portal built on Red Hat Developer Hub (RHDH) 1.8, orchestrated by **Microsoft Foundry Agent Service** using **Claude Sonnet 4.6 Extended Thinking** as the reasoning backbone, connected via the **Model Context Protocol (MCP)**.

The implementation involves **16 specialized agents**, **4 custom plugins**, **6 Golden Path templates**, **13 portal pages**, and a full CI/CD pipeline — all automated via GitHub Copilot agent mode.

### What Gets Built

| Layer | Components | Technology |
|-------|-----------|------------|
| **AI Backbone** | Foundry Agent with Claude Sonnet 4.6 Extended Thinking | Microsoft Foundry Agent Service |
| **MCP Transport** | Streamable HTTP + SSE endpoints | RHDH mcp-actions-backend plugin |
| **Developer Portal** | 13 pages (8 native + 4 custom + 1 topology) | RHDH 1.8 on OpenShift/AKS |
| **Custom Plugins** | Home Page, My Group, Copilot Metrics, GHAS Metrics | React + TypeScript + Backstage APIs |
| **Templates** | 6 Golden Path templates | Scaffolder v1beta3 |
| **Agent Ecosystem** | 16 Copilot agents for automated delivery | GitHub Copilot Agent Mode |
| **CI/CD** | Plugin build, OCI push, Helm deploy | GitHub Actions + ArgoCD |

---

## 2. Agent Ecosystem — Who Does What

### 2.1 Agent Registry

| # | Agent | Role | Color | Skills / Tools |
|---|-------|------|-------|---------------|
| 1 | `@rhdh-architect` | **RHDH Plugin Architect** — designs all plugin architectures, component specs, ADRs, and YAML wiring | 🟣 Purple | `rhdh-plugin-design` skill with 3 references + 2 assets + validator script |
| 2 | `@deploy` | **Deployment Orchestrator** — runs the full portal-customization workflow, triggers all other agents | 🔵 Blue | `portal-customization.workflow.md` + `pre-deploy-validate.hook.md` |
| 3 | `@platform` | **RHDH Platform Engineer** — PRIMARY AGENT for all config + custom plugin React development | 🔵 Blue | RHDH config, React, TypeScript, Backstage APIs, MUI theming |
| 4 | `@template-engineer` | **Template Creator** — builds all 6 Golden Path Scaffolder templates | 🟢 Green | Scaffolder v1beta3, skeleton generation, devcontainers |
| 5 | `@devops` | **CI/CD Engineer** — builds GitHub Actions pipelines for plugin packaging | 🟠 Orange | GitHub Actions, OCI/ORAS, Dynamic Plugin Factory |
| 6 | `@security` | **Security Reviewer** — RBAC policies, auth config, code scanning | 🔴 Red | trivy, gitleaks, RBAC policy validator |
| 7 | `@docs` | **Documentation Engineer** — TechDocs content, MkDocs sites | 🟢 Green | MkDocs, TechDocs plugin configuration |
| 8 | `@test` | **Test Engineer** — unit tests, integration tests, E2E | 🟢 Green | Jest, React Testing Library, TestApiProvider |
| 9 | `@reviewer` | **Code Reviewer** — SOLID, Clean Code, Backstage patterns | 🟡 Yellow | Static analysis, Backstage API pattern validation |
| 10 | `@sre` | **Site Reliability Engineer** — monitoring, SLOs, Grafana | 🔵 Teal | Prometheus, Grafana, alert rules |
| 11 | `@onboarding` | **Onboarding Specialist** — user guides, walkthroughs | 🟢 Green | TechDocs, user journey mapping |
| 12 | `@github-integration` | **GitHub Integration** — GitHub App, org discovery, GHAS | 🟣 Purple | GitHub REST API, entity providers |
| 13 | `@terraform` | **Infrastructure as Code** — Azure resource provisioning | 🔵 Blue | Terraform, AzureRM provider |
| 14 | `@azure-portal-deploy` | **Azure Deployment** — AKS, PostgreSQL, Key Vault | 🔵 Blue | Azure CLI, Helm, CSI Driver |
| 15 | `@ado-integration` | **ADO Integration** — Azure DevOps pipelines/discovery | 🟠 Orange | ADO REST API, hybrid config |
| 16 | `@hybrid-scenarios` | **Hybrid Orchestrator** — GitHub + ADO coexistence | 🟡 Yellow | Multi-SCM catalog providers |

### 2.2 Agent Orchestration Chain

```
@rhdh-architect (designs plugins + config)
    ↓ hands off specs to
@deploy (orchestrates the full deployment)
    ↓ activates in sequence
    ├── @azure-portal-deploy → infrastructure provisioning
    ├── @platform → RHDH config + custom plugin React code
    ├── @template-engineer → Golden Path templates
    ├── @github-integration → GitHub App + catalog discovery
    ├── @devops → CI/CD pipeline for plugin packaging
    ├── @security → RBAC policies + security scanning
    ├── @docs → TechDocs content authoring
    ├── @test → unit tests + integration tests
    ├── @reviewer → code review + quality gates
    ├── @sre → monitoring + SLOs + Grafana dashboards
    └── @onboarding → user guides + walkthroughs
```

### 2.3 Agent Handoff Map

```
@rhdh-architect → @platform      (component specs, YAML configs)
@rhdh-architect → @security      (RBAC requirements, auth design)
@rhdh-architect → @deploy        (architecture validation)
@platform       → @test          (plugin code for testing)
@platform       → @reviewer      (plugin code for review)
@platform       → @devops        (built plugins for CI/CD)
@template-engineer → @test       (templates for execution testing)
@template-engineer → @reviewer   (template quality review)
@devops         → @deploy        (OCI artifacts ready for Helm)
@security       → @deploy        (RBAC policies validated)
@deploy         → @sre           (running instance for monitoring)
@deploy         → @onboarding    (live portal for user guides)
@github-integration → @platform  (discovered entities for catalog)
```

---

## 3. @rhdh-architect — The Master Agent

### 3.1 Agent Definition

```yaml
# rhdh-architect.agent.md
name: rhdh-architect
description: >
  RHDH Plugin Architect specializing in Red Hat Developer Hub 1.8
  customization. Designs dynamic plugin architectures, component specs,
  frontend wiring, and generates validated YAML configurations.

skills:
  - rhdh-plugin-design

instructions:
  - rhdh-plugin-architecture.instructions.md

references:
  - portal-gap-analysis.md       # 14-page gap analysis (11 original + Copilot + GHAS)
  - frontend-wiring.md           # 8 RHDH wiring mechanisms
  - backstage-apis.md            # Backstage API catalog

assets:
  - three-horizons-branding.yaml       # Microsoft branding config
  - dynamic-plugins-three-horizons.yaml # Plugin wiring for all 13 pages

scripts:
  - validate-plugin-config.py    # YAML config validator
  - scaffold-plugin.sh           # Plugin scaffolder

hooks:
  - pre-deploy-validate.hook.md  # Pre-deployment checks

workflows:
  - portal-customization.workflow.md  # 6-phase delivery workflow
```

### 3.2 Primary Skill — rhdh-plugin-design

**Purpose:** Designs dynamic plugin architectures for RHDH 1.8 using a Decision Framework.

**Decision Framework (applied to every page):**

```
1. Can it be solved with app-config.yaml only?      → Config snippet
2. Is there a supported RHDH 1.8 dynamic plugin?    → Enable + wire it
3. Is there a community Backstage plugin?            → Evaluate Dynamic Plugin Factory
4. None of the above?                                → Design a custom dynamic plugin
```

**Outputs:**
- Architecture Decision Records (ADRs)
- Component specifications with TypeScript interfaces
- `dynamic-plugins-config.yaml` wiring
- `app-config.yaml` branding sections
- Effort estimates per page

### 3.3 Architecture Instructions

```markdown
# rhdh-plugin-architecture.instructions.md

## Code Standards for Custom RHDH Plugins

1. **TypeScript strict mode** — no `any` types, all props typed
2. **Backstage API usage** — always use `useApi(apiRef)` hook, never direct fetch
3. **MUI theming** — use MS_COLORS constants, never hardcoded hex
4. **Error handling** — ErrorBoundary wrapping, Progress spinner, ResponseErrorPanel
5. **Dynamic Plugin packaging** — export via `@janus-idp/cli package export-dynamic-plugin`
6. **OCI distribution** — push to ACR via `oras push`
7. **Testing** — >80% code coverage with TestApiProvider mocks
8. **RBAC** — respect Backstage permission framework for admin-only pages

## Microsoft Color Constants

MS_COLORS = {
  BLUE: '#0078D4',
  RED: '#F25022',
  GREEN: '#7FBA00',
  YELLOW: '#FFB900',
  DARK_SIDEBAR: '#1B1B1F',
  PRIMARY: '#0078D4',
  DARK_BLUE: '#005A9E',
  CHART_GREEN: '#107C10',
  ALERT_RED: '#D13438',
}
```

---

## 4. Portal Pages — 13 Pages Implementation

### 4.1 Page Classification

| # | Page | Route | Type | Agent | Effort |
|---|------|-------|------|-------|--------|
| 1 | **Home** | `/` | 🔴 Custom Plugin | @platform | 3-5 days |
| 2 | **My Group** | `/my-group` | 🔴 Custom Plugin | @platform | 2-3 days |
| 3 | **Catalog** | `/catalog` | 🟢 Native | @platform | 1 day |
| 4 | **APIs** | `/api-docs` | 🟢 Native | @platform | 1 day |
| 5 | **Create** | `/create` | 🟢 Native + Templates | @template-engineer | 3-4 days |
| 6 | **Docs** | `/docs` | 🟢 Native TechDocs | @docs | 2-3 days |
| 7 | **Lightspeed** | `/lightspeed` | 🟡 Dynamic Plugin | @platform | 1 day |
| 8 | **Copilot Metrics** | `/copilot-metrics` | 🔴 Custom Plugin (Full-Stack) | @platform | 4-6 days |
| 9 | **GHAS Metrics** | `/ghas-metrics` | 🔴 Custom Plugin (Full-Stack) | @platform | 5-7 days |
| 10 | **Notifications** | `/notifications` | 🟡 Dynamic Plugin | @platform | 0.5 day |
| 11 | **Administration** | `/admin/rbac` | 🟢 Native RBAC | @security | 1 day |
| 12 | **Settings** | `/settings` | 🟢 Native | @platform | 0.5 day |
| 13 | **Topology** | `/topology` | 🟡 Dynamic Plugin | @platform | 0.5 day |

**Total estimated effort: 25-34 days**

### 4.2 Custom Home Page Plugin

**Components:**

| Component | Purpose | Backstage API | Data |
|-----------|---------|--------------|------|
| `HeroBanner` | Welcome + search bar | `catalogApiRef` search | User identity + search query |
| `StatCards` | 4 colored KPI cards | `catalogApiRef.getEntityFacets()` | Components, APIs, Templates, Teams counts |
| `HorizonCards` | H1/H2/H3 progress bars | Static config or custom API | Horizon adoption metrics |
| `QuickAccess` | 6 shortcut buttons | Pure route links | Static navigation |
| `FeaturedTemplates` | 3 template cards | `scaffolderApiRef` | Template metadata |
| `ColorBar` | Microsoft 4-color gradient | Pure CSS | Static |

**File structure:**
```
plugins/home-page-three-horizons/
├── package.json
├── src/
│   ├── plugin.ts                    # createPlugin + createRoutableExtension
│   ├── components/
│   │   ├── HomePage.tsx             # Main container, layout grid
│   │   ├── HeroBanner.tsx           # Welcome message + catalog search
│   │   ├── StatCards.tsx            # 4 colored cards with counts
│   │   ├── HorizonCards.tsx         # H1/H2/H3 progress bars
│   │   ├── QuickAccess.tsx          # 6 shortcut buttons
│   │   ├── FeaturedTemplates.tsx    # 3 template cards
│   │   └── ColorBar.tsx             # 4-color Microsoft gradient bar
│   └── api/
│       └── catalogStats.ts          # Catalog count queries
└── dev/
    └── index.tsx                    # Local dev server
```

**Wiring:**
```yaml
dynamicPlugins:
  frontend:
    home-page-three-horizons:
      dynamicRoutes:
        - path: /
          importName: ThreeHorizonsHomePage
          menuItem:
            icon: HomeIcon
            text: Home
```

### 4.3 Copilot Metrics Plugin (Full-Stack)

**Backend — Express routes proxying GitHub Copilot Metrics API:**

| Route | GitHub API Endpoint | Auth Scope |
|-------|-------------------|------------|
| `GET /api/copilot-metrics/org` | `GET /orgs/{org}/copilot/metrics` | `manage_billing:copilot` |
| `GET /api/copilot-metrics/team/:slug` | `GET /orgs/{org}/team/{slug}/copilot/metrics` | `read:org` |
| `GET /api/copilot-metrics/billing` | `GET /orgs/{org}/copilot/billing` | `manage_billing:copilot` |

**Frontend — 8 React components:**

| Component | Chart Type | Data Source |
|-----------|-----------|-------------|
| `ActiveUsersCard` | KPI + trend arrow | `total_active_users`, `total_engaged_users` |
| `SeatUtilization` | Gauge chart | Billing: assigned vs active seats |
| `AcceptanceRateChart` | 30-day line chart (recharts) | `copilot_ide_code_completions` acceptance rate |
| `LanguageBreakdown` | Data table | Per-language: lines suggested/accepted/rate |
| `IdeUsageChart` | Bar chart | Per-editor: VS Code, JetBrains, Neovim |
| `TeamComparison` | Data table | Per-team: users, engagement, acceptance |
| `ChatUsageStats` | 3 KPI cards | IDE Chat, Dotcom Chat, PR Summaries |
| `TrendSparklines` | Mini line charts | 30-day sparklines for key metrics |

### 4.4 GHAS Metrics Plugin (Full-Stack)

**Backend — Express routes + aggregation logic:**

| Route | GitHub API Endpoint | Notes |
|-------|-------------------|-------|
| `GET /api/ghas-metrics/code-scanning` | `GET /orgs/{org}/code-scanning/alerts` | Supports state, severity, tool_name filters |
| `GET /api/ghas-metrics/secret-scanning` | `GET /orgs/{org}/secret-scanning/alerts` | Supports state, secret_type, validity filters |
| `GET /api/ghas-metrics/dependabot` | `GET /repos/{owner}/{repo}/dependabot/alerts` | **AGGREGATES** across all org repos |
| `GET /api/ghas-metrics/billing` | `GET /orgs/{org}/settings/billing/advanced-security` | GHAS committers + per-repo breakdown |
| `GET /api/ghas-metrics/mttr` | Computed from closed code-scanning alerts | `avg(fixed_at - created_at)` per severity |

**Frontend — 10 React components:**

| Component | Chart Type | Data |
|-----------|-----------|------|
| `CodeScanningCard` | Summary + severity badges | Open/fixed/dismissed by critical/high/medium/low |
| `SecretScanningCard` | Summary + validity badges | Open/resolved, active/inactive/unknown |
| `DependabotAlertsCard` | Severity breakdown + ecosystem pie | Aggregated across all repos |
| `GhasCommittersCard` | Gauge + top repos table | Total GHAS-licensed committers |
| `SecurityTrendChart` | 30-day line chart | Alerts opened vs closed over time |
| `SeverityBreakdown` | Donut chart | Critical(red)/High(orange)/Medium(yellow)/Low(blue) |
| `MttrMetrics` | 4 KPI cards | MTTR by severity: critical/high/medium/low |
| `PushProtectionCard` | Count + event list | Bypass count + recent bypass events |
| `RepoCoverageTable` | Data table | Repo name, GHAS enabled, committers, last scan |

---

## 5. Microsoft Foundry Integration — Claude Sonnet 4.6 Extended Thinking

### 5.1 Architecture

```
Developer Clients (VS Code, Cursor, Continue)
        │
        │ Natural language query
        ▼
Microsoft Foundry Agent Service
        │
        │ Claude Sonnet 4.6 Extended Thinking reasoning + tool selection
        ▼
MCP Transport (Streamable HTTP)
        │
        │ Bearer token auth
        ▼
RHDH MCP Server (/api/mcp-actions/v1)
        │
        ├── fetch-catalog-entities     → Software Catalog (PostgreSQL)
        ├── fetch-techdocs             → TechDocs (S3/Object Storage)
        ├── analyze-techdocs-coverage  → Catalog + TechDocs
        └── retrieve-techdocs-content  → TechDocs content
```

### 5.2 Foundry Agent Creation (Python SDK)

```python
from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import McpToolDefinition
from azure.identity import DefaultAzureCredential

client = AIProjectClient(
    credential=DefaultAzureCredential(),
    endpoint="https://<your-foundry>.api.azureml.ms",
    project_name="developer-hub-agent"
)

agent = client.agents.create_agent(
    model="claude-sonnet-4-5-20250929",
    name="Developer Hub Assistant",
    instructions="""You are the Three Horizons Developer Hub AI assistant.
    You help developers query the Software Catalog, find documentation,
    analyze TechDocs coverage, and understand service dependencies.
    Use the RHDH MCP tools to answer questions about components, APIs,
    systems, users, groups, and technical documentation.
    Always provide structured, actionable answers.""",
    tools=[McpToolDefinition(
        server_label="rhdh-mcp",
        server_url="https://rhdh.example.com/api/mcp-actions/v1",
        allowed_tools=[
            "fetch-catalog-entities",
            "fetch-techdocs",
            "analyze-techdocs-coverage",
            "retrieve-techdocs-content"
        ]
    )]
)
```

### 5.3 Running Queries

```python
thread = client.agents.create_thread()

message = client.agents.create_message(
    thread_id=thread.id,
    role="user",
    content="List all production services missing TechDocs"
)

run = client.agents.create_run(
    thread_id=thread.id,
    agent_id=agent.id,
    tool_resources={
        "mcp": {
            "servers": {
                "rhdh-mcp": {
                    "headers": {
                        "Authorization": "Bearer <rhdh-static-token>"
                    },
                    "require_approval": "never"
                }
            }
        }
    }
)

# Claude Sonnet 4.6 Extended Thinking will:
# 1. Call fetch-catalog-entities with filter: kind=component,spec.lifecycle=production
# 2. Call analyze-techdocs-coverage with filter: kind=component
# 3. Cross-reference results to identify production services without docs
# 4. Return a structured table with service names, owners, and recommendations
```

### 5.4 MCP Tools Reference

| Tool | Parameters | Returns |
|------|-----------|---------|
| `fetch-catalog-entities` | `kind`, `type`, `name`, `owner`, `lifecycle`, `tags`, `verbose` | JSON array of entities with metadata |
| `fetch-techdocs` | `entityType`, `namespace`, `owner`, `lifecycle`, `tags` | Entities with TechDocs metadata |
| `analyze-techdocs-coverage` | (filter params) | `totalEntities`, `entitiesWithDocs`, `coveragePercentage` |
| `retrieve-techdocs-content` | `entityRef`, `pagePath` | Full documentation content + metadata |

### 5.5 Why Claude Sonnet 4.6 Extended Thinking

| Capability | Claude Sonnet 4.6 Extended Thinking | GPT-4o | Llama 3.1 405B |
|-----------|-------------------|--------|----------------|
| Context Window | 200K tokens | 128K tokens | 128K tokens |
| Tool Use Accuracy | Excellent — native MCP | Very Good | Good |
| Code Understanding | Excellent | Excellent | Very Good |
| Structured Output | Strong JSON/YAML | Strong | Moderate |
| Foundry Availability | Yes — model catalog | Yes — native | Yes — model catalog |

---

## 6. MCP Configuration

### 6.1 RHDH Plugin Installation

```yaml
# dynamic-plugins-rhdh.yaml ConfigMap
plugins:
  # Backend MCP Server (required)
  - package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/backstage-plugin-mcp-actions-backend:bs_1.42.5__0.1.2!backstage-plugin-mcp-actions-backend
    disabled: false

  # Software Catalog MCP Tool
  - package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/red-hat-developer-hub-backstage-plugin-software-catalog-mcp-tool:bs_1.42.5__0.2.3!red-hat-developer-hub-backstage-plugin-software-catalog-mcp-tool
    disabled: false

  # TechDocs MCP Tool
  - package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/red-hat-developer-hub-backstage-plugin-techdocs-mcp-tool:bs_1.42.5__0.3.0!red-hat-developer-hub-backstage-plugin-techdocs-mcp-tool
    disabled: false
```

### 6.2 Authentication Configuration

```yaml
# app-config.yaml
backend:
  actions:
    pluginSources:
      - 'software-catalog-mcp-tool'
      - 'techdocs-mcp-tool'
  auth:
    externalAccess:
      - type: static
        options:
          token: ${MCP_TOKEN}
          subject: mcp-clients
```

**Generate token:**
```bash
node -p 'require("crypto").randomBytes(24).toString("base64")'
```

### 6.3 Client Configuration

**Cursor IDE:**
```json
{
  "mcpServers": {
    "backstage-actions": {
      "url": "https://<rhdh-domain>/api/mcp-actions/v1",
      "headers": {
        "Authorization": "Bearer <MCP_TOKEN>"
      }
    }
  }
}
```

**Continue:**
```yaml
mcpServers:
  - name: backstage-actions
    type: sse
    url: https://<rhdh-domain>/api/mcp-actions/v1/sse
    requestOptions:
      headers:
        Authorization: "Bearer <MCP_TOKEN>"
```

**Developer Lightspeed for RHDH:**
```yaml
lightspeed:
  mcpServers:
    - name: mcp::backstage
      token: ${MCP_TOKEN}
```

### 6.4 Complete 10-MCP Server Architecture

The 3horizons platform connects to **10 MCP servers** that collectively cover the full developer lifecycle:

| # | MCP Server | Repository / Source | Transport | Key Tools |
|---|------------|-------------------|-----------|-----------|
| 1 | **RHDH MCP** | RHDH 1.8 built-in (3 OCI packages) | Streamable HTTP | `fetch-catalog-entities`, `fetch-techdocs`, `analyze-techdocs-coverage`, `retrieve-techdocs-content` |
| 2 | **GitHub MCP** | [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) | stdio / SSE | `create_repository`, `push_files`, `create_pull_request`, `search_code`, `list_issues` |
| 3 | **Azure MCP** | [microsoft/mcp](https://github.com/microsoft/mcp) | Streamable HTTP | 40+ Azure services: AKS, ACR, KeyVault, Monitor, Log Analytics, Microsoft Foundry |
| 4 | **Azure DevOps MCP** | [microsoft/azure-devops-mcp](https://github.com/microsoft/azure-devops-mcp) (GA) | stdio / SSE | 9 domains: `work-items`, `repositories`, `pipelines`, `wiki`, `search`, `test-plans`, `advanced-security` |
| 5 | **Terraform MCP** | [hashicorp/terraform-mcp-server](https://github.com/hashicorp/terraform-mcp-server) | Streamable HTTP / SSE | `resolveProviderDocID`, `getProviderDocs`, `resolveModuleID`, `getModuleDocs`, workspace CRUD, create runs |
| 6 | **Figma MCP** | [Figma Official](https://developers.figma.com/docs/figma-mcp-server/) | Local / Remote | `get_design_context`, `get_screenshot`, `get_metadata`, `generate_diagram`, `get_code_connect_map` |
| 7 | **Markitdown MCP** | [microsoft/markitdown](https://github.com/microsoft/markitdown) | Streamable HTTP / SSE | `convert_to_markdown(uri)` — converts PDF, DOCX, PPTX, XLSX, images to Markdown |
| 8 | **Playwright MCP** | [microsoft/playwright-mcp](https://github.com/microsoft/playwright-mcp) | stdio | `browser_navigate`, `browser_click`, `browser_screenshot`, `browser_snapshot` — UI automation |
| 9 | **Microsoft Learn** | [learn.microsoft.com/api/mcp](https://learn.microsoft.com) | HTTPS | `microsoft_docs_search`, `microsoft_docs_fetch`, `microsoft_code_sample_search` |
| 10 | **Context7** | [context7.com](https://context7.com) | HTTPS | `resolve-library-id`, `query-docs` — live docs for Backstage, React, etc. |

#### Use Cases by MCP Server

**RHDH MCP (core):** Catalog queries, TechDocs analysis, compliance audits, dependency graphs
**GitHub MCP:** Template scaffolding, PR automation, code search across org, issue tracking
**Azure MCP:** AKS cluster management, ACR push OCI plugins, KeyVault secrets rotation, Monitor dashboards
**Azure DevOps MCP:** Sprint work items, CI/CD pipeline triggers, Advanced Security scans, wiki updates
**Terraform MCP:** IaC for RHDH infra (AKS + ACR + PostgreSQL + KeyVault), registry module validation
**Figma MCP:** Design-to-code for RHDH plugins (React/TypeScript), Code Connect mapping, visual QA
**Markitdown MCP:** Legacy doc migration to TechDocs Markdown (bulk conversion of PDF/DOCX archives)
**Playwright MCP:** Visual regression testing, portal smoke tests, plugin rendering validation
**Microsoft Learn:** Real-time Azure/K8s/RHDH documentation lookup during AI chat sessions
**Context7:** Up-to-date Backstage plugin API docs, React component patterns, library references

#### Foundry Agent Multi-MCP Configuration

```python
from azure.ai.projects import AIProjectClient
from azure.ai.agents.models import McpToolDefinition

client = AIProjectClient.from_connection_string(conn_str=os.environ["PROJECT_CONNECTION_STRING"])

# Define all MCP servers
mcp_servers = {
    "rhdh-catalog": {
        "url": "https://<rhdh-domain>/api/mcp-actions/v1",
        "token": os.environ["MCP_TOKEN"]
    },
    "github": {
        "url": "https://api.github.com/mcp",
        "token": os.environ["GITHUB_TOKEN"]
    },
    "azure": {
        "url": "https://azure-mcp.microsoft.com/mcp",
        "token": os.environ["AZURE_TOKEN"]
    },
    "azure-devops": {
        "url": "https://dev.azure.com/<org>/_mcp",
        "token": os.environ["ADO_TOKEN"]
    },
    "terraform": {
        "url": "https://app.terraform.io/mcp",
        "token": os.environ["TF_TOKEN"]
    }
}

# Create MCP tool definitions
mcp_tools = []
for name, config in mcp_servers.items():
    mcp_tools.append(McpToolDefinition(
        server_label=name,
        server_url=config["url"],
        headers={"Authorization": f"Bearer {config['token']}"}
    ))

# Create agent with all 10 MCP connections
agent = client.agents.create_agent(
    model="claude-sonnet-4-6-extended-thinking",
    name="3horizons-ai-assistant",
    instructions="You are the 3horizons AI Assistant with access to 10 MCP servers...",
    tools=mcp_tools
)
```

---

## 7. Microsoft Branding Configuration

### 7.1 app-config.yaml Branding

```yaml
app:
  branding:
    fullLogo: /branding/microsoft-logo.svg
    iconLogo: /branding/ms-icon.svg
    theme:
      light:
        primaryColor: '#0078D4'
        headerColor1: '#F25022'
        headerColor2: '#7FBA00'
        headerColor3: '#00A4EF'
        headerColor4: '#FFB900'
        navigationIndicatorColor: '#0078D4'
      dark:
        primaryColor: '#50E6FF'
```

### 7.2 Sidebar Navigation (13 pages)

```yaml
# dynamic-plugins-config.yaml
dynamicPlugins:
  frontend:
    home-page-three-horizons:
      dynamicRoutes:
        - path: /
          importName: ThreeHorizonsHomePage
          menuItem:
            icon: HomeIcon
            text: Home

    my-group-dashboard:
      dynamicRoutes:
        - path: /my-group
          importName: MyGroupDashboardPage
          menuItem:
            icon: GroupIcon
            text: My Group

    copilot-metrics-frontend:
      dynamicRoutes:
        - path: /copilot-metrics
          importName: CopilotMetricsPage
          menuItem:
            icon: AssessmentIcon
            text: Copilot Metrics

    ghas-metrics-frontend:
      dynamicRoutes:
        - path: /ghas-metrics
          importName: GhasMetricsPage
          menuItem:
            icon: SecurityIcon
            text: GHAS Metrics
```

### 7.3 RBAC Roles

| Role | Permissions |
|------|------------|
| **Platform Admin** | Full access + RBAC management + MCP admin |
| **Developer** | Catalog read, Create templates, TechDocs, Lightspeed, MCP queries |
| **Team Lead** | Developer + My Group dashboard + team management |
| **Viewer** | Read-only: Catalog, Docs, APIs |

---

## 8. Golden Path Templates

### 8.1 Template Gallery (Create Page)

| # | Template | Language | Includes |
|---|----------|----------|----------|
| 1 | **Microservice** | Node.js Express | CI/CD, TechDocs, Monitoring, Dockerfile, Devcontainer |
| 2 | **Frontend App** | React/Next.js | Tailwind, Storybook, Testing, CI/CD |
| 3 | **Data Pipeline** | Python/Airflow | dbt models, Great Expectations, CI/CD |
| 4 | **ML Model Service** | Python | MLflow, BentoML, Feature Store, A/B Testing |
| 5 | **API Gateway** | Kong/Envoy | OpenAPI spec, Rate Limiting, Auth config |
| 6 | **Event-Driven Service** | Kafka | Avro schemas, Schema Registry, Dead Letter Queue |

### 8.2 Template Structure

```
golden-paths/h1/{template-name}/
├── template.yaml                    # Scaffolder v1beta3 definition
└── skeleton/
    ├── catalog-info.yaml            # Backstage entity registration
    ├── mkdocs.yml                   # TechDocs setup
    ├── docs/
    │   └── index.md                 # Default documentation
    ├── .github/
    │   └── workflows/
    │       └── ci.yaml              # CI/CD pipeline
    ├── Dockerfile                   # Container build
    ├── .devcontainer/
    │   └── devcontainer.json        # Dev container config
    └── src/
        └── ...                      # Application source code
```

---

## 9. Security Architecture

### 9.1 Authentication Flow

```
Developer → Entra ID (Azure AD) → Foundry Agent Service
                                        │
                                   Claude Sonnet 4.6 Extended Thinking
                                        │
                                   Static Bearer Token
                                        │
                                   RHDH MCP Server
                                        │
                                   mcp-clients subject
                                        │
                                   Backstage Permission Framework
```

### 9.2 Security Requirements

- RHDH MCP endpoint: HTTPS only (TLS 1.2+)
- Static Bearer token: stored in Azure Key Vault, rotated quarterly
- GitHub PATs (Copilot + GHAS): stored in Key Vault via CSI Driver
- Network policies: restrict MCP endpoint to Foundry Agent IP ranges
- Plugin code: scanned with trivy + gitleaks before OCI push
- RBAC: least-privilege, reviewed by @security agent

---

## 10. CI/CD Pipeline

### 10.1 Plugin Build Pipeline

```yaml
# .github/workflows/build-rhdh-plugins.yaml
name: Build RHDH Plugins
on:
  push:
    paths: ['plugins/**']
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        plugin:
          - home-page-three-horizons
          - my-group-dashboard
          - copilot-metrics
          - ghas-metrics
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: cd plugins/${{ matrix.plugin }} && npm ci
      - run: cd plugins/${{ matrix.plugin }} && npm run lint
      - run: cd plugins/${{ matrix.plugin }} && npm test -- --coverage
      - run: cd plugins/${{ matrix.plugin }} && npm run build
      - run: cd plugins/${{ matrix.plugin }} && npx @janus-idp/cli package export-dynamic-plugin
      - uses: azure/docker-login@v1
        with:
          login-server: ${{ secrets.ACR_NAME }}.azurecr.io
      - run: |
          oras push ${{ secrets.ACR_NAME }}.azurecr.io/plugins/${{ matrix.plugin }}:${{ github.sha }} \
            plugins/${{ matrix.plugin }}/dist-dynamic/*
```

### 10.2 Deployment

```bash
helm upgrade --install backstage backstage/backstage \
  --namespace rhdh \
  --values values-aks.yaml \
  --set global.clusterRouterBase=portal.mycompany.com
```

---

## 11. Implementation Timeline

```
Week 1:  Phase 0 — Architecture Design + Infrastructure
         @rhdh-architect → @azure-portal-deploy → @terraform

Week 2:  Phase 1 — Branding + Navigation + Native Pages (Catalog, APIs, Create, Docs)
         @platform → @template-engineer → @docs → @github-integration

Week 3:  Phase 2 — Native Pages (Lightspeed, Notifications, Admin, Settings, Topology)
         @platform → @security

Week 4:  Phase 3a — Custom Home Page Plugin + My Group Plugin
         @rhdh-architect → @platform → @test → @reviewer

Week 5:  Phase 3b — Copilot Metrics Plugin (Full-Stack) + GHAS Metrics Plugin (Full-Stack)
         @platform → @test → @reviewer → @security

Week 6:  Phase 4 — CI/CD Pipeline + Helm Deployment
         @devops → @deploy → @sre

Week 7:  Phase 5 — MCP Integration + Foundry Agent Setup
         @platform (MCP plugins) → Foundry Agent (Claude Sonnet 4.6 Extended Thinking)

Week 8:  Phase 6 — Polish, Security Audit, Onboarding
         @security → @sre → @onboarding → @test (E2E)
```

---

## 12. Execution Prompts — Copy-Paste Ready

### 12.1 Master Prompt (Full Orchestration)

```
@deploy Execute the portal-customization workflow.

Context: We are customizing RHDH 1.8 to match the Three Horizons Developer Hub
reference template. The portal has 13 pages, 4 custom plugins, MCP integration
with Microsoft Foundry (Claude Sonnet 4.6 Extended Thinking), and 6 Golden Path templates.

Execution mode: Phase-by-Phase (pause at each validation gate for approval).

Phase sequence:
1. @rhdh-architect → Architecture design (ADRs + specs + YAML)
2. @platform → Branding + sidebar navigation
3. @platform + @template-engineer + @docs + @github-integration → Native pages
4. @platform → Custom plugins (Home, My Group, Copilot Metrics, GHAS Metrics)
5. @devops → CI/CD pipeline → @deploy → Helm deployment
6. @platform → MCP plugins installation + Foundry Agent configuration
7. @security + @sre + @onboarding → Polish & verification

Start with Phase 0: call @rhdh-architect to design the architecture.
```

### 12.2 MCP + Foundry Setup Prompt

```
@platform Install and configure MCP plugins for RHDH 1.8.

Tasks:
1. Install 3 OCI plugin packages:
   - backstage-plugin-mcp-actions-backend:bs_1.42.5__0.1.2
   - software-catalog-mcp-tool:bs_1.42.5__0.2.3
   - techdocs-mcp-tool:bs_1.42.5__0.3.0

2. Configure app-config.yaml:
   - Add pluginSources for both MCP tools
   - Configure externalAccess with static Bearer token (subject: mcp-clients)
   - Store token in Key Vault

3. Create Microsoft Foundry Agent:
   - Model: claude-sonnet-4-5-20250929
   - McpToolDefinition pointing to /api/mcp-actions/v1
   - Allowed tools: fetch-catalog-entities, fetch-techdocs,
     analyze-techdocs-coverage, retrieve-techdocs-content

4. Configure IDE clients (Cursor, Continue, Lightspeed)

Validation:
- [ ] MCP plugins appear in install logs
- [ ] Bearer token authenticates successfully
- [ ] Foundry Agent can query catalog entities
- [ ] Claude Sonnet returns structured answers
```

### 12.3 Custom Plugin Build Prompt

```
@platform Build the Copilot Metrics Plugin for RHDH.

Scaffold: ./scripts/scaffold-plugin.sh copilot-metrics ./plugins

BACKEND (Express router):
- GET /api/copilot-metrics/org → GitHub /orgs/{org}/copilot/metrics
- GET /api/copilot-metrics/team/:slug → GitHub /orgs/{org}/team/{slug}/copilot/metrics
- GET /api/copilot-metrics/billing → GitHub /orgs/{org}/copilot/billing
- Auth: GITHUB_COPILOT_METRICS_PAT from Key Vault

FRONTEND (React):
- ActiveUsersCard, SeatUtilization, AcceptanceRateChart
- LanguageBreakdown, IdeUsageChart, TeamComparison
- ChatUsageStats, TrendSparklines

Wire at /copilot-metrics with AssessmentIcon.
Chart colors: Blue #0078D4, Green #107C10, Yellow #FFB900, Red #D13438.

After implementation:
  npx @janus-idp/cli package export-dynamic-plugin
  oras push myacr.azurecr.io/plugins/copilot-metrics:1.0.0
```

---

## 13. Monitoring & SLOs

| SLO | Target | Alert Threshold |
|-----|--------|----------------|
| Availability | 99.9% uptime | < 99.5% over 1h |
| Page Load | < 2s | > 3s p95 over 15min |
| API Response | < 500ms | > 1s p95 over 15min |
| Error Rate | < 0.1% 5xx | > 0.5% over 5min |
| MCP Tool Latency | < 1.5s per tool call | > 3s over 5min |

---

## 14. File Structure — Complete Repository

```
three-horizons-portal/
├── .github/
│   ├── copilot/agents/
│   │   └── rhdh-architect/              # Master agent
│   │       ├── rhdh-architect.agent.md
│   │       ├── plugin.md
│   │       ├── skills/rhdh-plugin-design/
│   │       ├── instructions/
│   │       ├── workflows/
│   │       └── hooks/
│   └── workflows/
│       └── build-rhdh-plugins.yaml      # CI/CD pipeline
│
├── plugins/
│   ├── home-page-three-horizons/        # Custom Home Page
│   ├── my-group-dashboard/              # Custom My Group
│   ├── copilot-metrics/                 # Copilot Metrics (frontend + backend)
│   └── ghas-metrics/                    # GHAS Metrics (frontend + backend)
│
├── golden-paths/
│   └── h1/
│       ├── nodejs-microservice/
│       ├── react-frontend/
│       ├── python-data-pipeline/
│       ├── ml-model-service/
│       ├── api-gateway/
│       └── event-driven-service/
│
├── docs/
│   ├── getting-started/
│   ├── architecture-guide/
│   ├── api-reference/
│   ├── security-playbook/
│   ├── onboarding-guide/
│   └── platform-operations/
│
├── config/
│   ├── app-config.yaml                  # RHDH config + branding
│   ├── dynamic-plugins-config.yaml      # All 13 pages wired
│   ├── rbac-policy.csv                  # RBAC roles
│   └── values-aks.yaml                  # Helm values for AKS
│
├── infrastructure/
│   ├── terraform/                       # AKS + PostgreSQL + Key Vault
│   └── helm/                            # RHDH Helm chart overrides
│
├── foundry/
│   ├── create_agent.py                  # Foundry Agent creation script
│   ├── query_agent.py                   # Query example
│   └── .env.example                     # Environment variables template
│
└── docs-meta/
    ├── RHDH_Official_Documentation_Guide.md
    ├── RHDH_Three_Horizons_Portal_Implementation_Plan.md
    ├── RHDH_Agent_Execution_Prompts.md
    ├── MCP_in_RHDH_Guide.md
    └── Foundry_Claude_RHDH_MCP_Implementation_Guide.md  ← THIS FILE
```

---

## 15. Sources

- [Red Hat Developer Hub 1.8 — MCP Tools Official Documentation](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.8/html/interacting_with_model_context_protocol_tools_for_red_hat_developer_hub/index)
- [Microsoft Foundry — Connect to MCP Server Endpoint](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/how-to/tools-classic/model-context-protocol)
- [Introducing MCP in Microsoft Foundry — Microsoft Blog](https://devblogs.microsoft.com/foundry/integrating-azure-ai-agents-mcp/)
- [Foundry MCP Server (Preview) in the Cloud](https://devblogs.microsoft.com/foundry/announcing-foundry-mcp-server-preview-speeding-up-ai-dev-with-microsoft-foundry/)
- [Microsoft Foundry Model Catalog](https://azure.microsoft.com/en-us/products/ai-foundry/models)
- [What's New in Microsoft Foundry — Dec 2025 & Jan 2026](https://devblogs.microsoft.com/foundry/whats-new-in-microsoft-foundry-dec-2025-jan-2026/)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/specification)
- [MCP in Red Hat Developer Hub — Chat with Your Catalog](https://developers.redhat.com/articles/2025/11/10/mcp-red-hat-developer-hub-chat-your-catalog)
- [Backstage as the Ultimate MCP Server](https://vrabbi.cloud/post/backstage-as-the-ultimate-mcp-server/)
- [GitHub Copilot Metrics REST API](https://docs.github.com/en/rest/copilot/copilot-metrics)
- [GitHub Advanced Security REST API](https://docs.github.com/en/rest/code-scanning)
- [Azure MCP Server](https://github.com/microsoft/mcp) — 40+ Azure services via MCP
- [Azure DevOps MCP Server (GA)](https://github.com/microsoft/azure-devops-mcp) — 9 domains
- [GitHub MCP Server](https://github.com/modelcontextprotocol/servers) — repos, PRs, issues, code search
- [Terraform MCP Server](https://github.com/hashicorp/terraform-mcp-server) — IaC registry + workspaces
- [Figma MCP Server](https://developers.figma.com/docs/figma-mcp-server/) — design-to-code, Code Connect
- [Markitdown MCP](https://github.com/microsoft/markitdown) — PDF/DOCX/PPTX to Markdown
- [Playwright MCP](https://github.com/microsoft/playwright-mcp) — browser automation & UI tests
