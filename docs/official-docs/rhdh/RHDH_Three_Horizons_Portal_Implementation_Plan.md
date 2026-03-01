# Three Horizons Portal — RHDH Implementation Plan

> **Goal:** Customize Red Hat Developer Hub (RHDH) 1.8 to match the *Three Horizons Developer Hub* reference template as closely as possible, leveraging native configuration, dynamic plugins, and custom plugins where necessary.

---

## Executive Summary

The Three Horizons Portal reference template contains **11 pages/tabs**. After analyzing each against RHDH 1.8 capabilities and the 31 official documentation PDFs, the implementation breaks down as follows:

| Category | Pages | Effort |
|----------|-------|--------|
| **Native Config Only** | Catalog, APIs, Create, Docs, Lightspeed, Notifications, Administration, Settings | ~60% of work |
| **Custom Plugin Required** | Home Page, My Group | ~30% of work |
| **Branding + Theme** | All pages (sidebar, color bar, Microsoft palette) | ~10% of work |

**Primary Agents (ordered by involvement):**

| Agent | Role in This Plan |
|-------|-------------------|
| `@architect` | Overall design, plugin architecture, Three Horizons mapping |
| `@platform` | RHDH configuration, catalog setup, dynamic plugin enablement |
| `@template-engineer` | Golden Path templates for Create page, scaffolder actions |
| `@devops` | CI/CD pipeline for custom plugins, GitOps deployment |
| `@deploy` | Full platform deployment orchestration |
| `@docs` | TechDocs structure, Learning Paths content |
| `@security` | RBAC policies, auth config, security review |
| `@github-integration` | GitHub App, org discovery, GHAS integration |
| `@terraform` | Azure infrastructure modules (if AKS-based) |
| `@azure-portal-deploy` | AKS provisioning, Helm deployment |
| `@test` | Plugin testing, integration tests |
| `@reviewer` | Code review for custom plugins |
| `@onboarding` | User onboarding flows, documentation |
| `@sre` | Monitoring, SLOs for portal health |
| `@ado-integration` | ADO pipelines/discovery (if hybrid scenario) |
| `@hybrid-scenarios` | GitHub + ADO coexistence config |

---

## Phase 0: Architecture & Foundation

### 0.1 — Design Plugin Architecture
**Agent:** `@architect`
**Description:** Design the overall architecture for the Three Horizons Portal customization, including:
- Decide which RHDH frontend plugin wiring mechanisms to use (`dynamicRoutes`, `mountPoints`, `menuItems`, `entityTabs`)
- Define the Custom Home Page Plugin component architecture (React + Backstage APIs)
- Define the My Group Dashboard Plugin component architecture
- Map Three Horizons (H1/H2/H3) to RHDH feature tiers
- Produce an Architecture Decision Record (ADR)

**Deliverables:**
- `docs/adr/001-portal-customization-architecture.md`
- Component diagram (Mermaid)
- Plugin dependency map

**Handoff:** → `@platform` (for RHDH config), → `@security` (for auth review)

---

### 0.2 — Provision Infrastructure (if not already deployed)
**Agent:** `@azure-portal-deploy` → `@terraform`
**Description:** Ensure AKS cluster, PostgreSQL, Key Vault, and ACR are provisioned.

**Deliverables:**
- AKS cluster running in `centralus` or `eastus`
- PostgreSQL Flexible Server with SSL
- Key Vault with CSI Driver enabled
- ACR for custom RHDH images

**Handoff:** → `@deploy` (for Helm install)

---

## Phase 1: Global Branding & Theme

### 1.1 — Custom Theme (Microsoft Branding)
**Agent:** `@platform`
**Description:** Configure RHDH `app-config.yaml` to apply Microsoft branding across all pages.

**What to configure:**
```yaml
app:
  branding:
    fullLogo: /path/to/microsoft-logo.svg
    iconLogo: /path/to/ms-icon.svg
    theme:
      light:
        primaryColor: '#0078D4'       # Microsoft Blue
        headerColor1: '#F25022'       # Red
        headerColor2: '#7FBA00'       # Green
        headerColor3: '#00A4EF'       # Blue
        headerColor4: '#FFB900'       # Yellow
        navigationIndicatorColor: '#0078D4'
```

**Key elements from the reference template:**
- Dark sidebar background (`#1B1B1F`) → Configure via `theme.light.navigation.background`
- 4-color gradient bar at top → Custom CSS via theme extension or Custom Home Page plugin
- Segoe UI font → Configure in theme typography
- Stat cards with colored top borders → Custom Home Page plugin component

**Native support:** ~70% (logo, colors, sidebar). The 4-color gradient bar requires a custom theme extension or CSS injection in the Custom Home Page plugin.

**Handoff:** → `@architect` (verify design compliance)

---

### 1.2 — Sidebar Navigation Configuration
**Agent:** `@platform`
**Description:** Configure the sidebar menu items to match the reference template's 11-page navigation.

**Configuration via `dynamic-plugins-config.yaml` → `menuItems`:**

| Menu Item | Icon | Route | Plugin Required |
|-----------|------|-------|-----------------|
| Home | `HomeIcon` | `/` | Custom Home Page Plugin |
| My Group | `GroupIcon` | `/my-group` | Custom My Group Plugin |
| Catalog | `CategoryIcon` | `/catalog` | Native (built-in) |
| APIs | `ExtensionIcon` | `/api-docs` | Native (API Docs plugin) |
| Learning Paths | `SchoolIcon` | `/learning-paths` | Custom or TechDocs route |
| Create | `CreateComponentIcon` | `/create` | Native (Scaffolder) |
| Docs | `LibraryBooksIcon` | `/docs` | Native (TechDocs) |
| Lightspeed | `ChatIcon` | `/lightspeed` | Dynamic Plugin (Lightspeed) |
| Notifications | `NotificationsIcon` | `/notifications` | Dynamic Plugin (Notifications) |
| Administration | `AdminPanelSettingsIcon` | `/admin` | Native (RBAC UI) |
| Settings | `SettingsIcon` | `/settings` | Native (User Settings) |

**Handoff:** → `@security` (verify RBAC for admin menu visibility)

---

## Phase 2: Native Pages Configuration

### 2.1 — Catalog Page
**Agent:** `@platform`
**Description:** The Catalog page in the reference shows a search bar, stat summary cards, and an entity table. Most of this is **native**.

**Configuration tasks:**
1. Enable catalog search plugin (built-in)
2. Configure entity `Kind` filters: Component, API, Resource, System, Domain, User, Group
3. Register all services/components via `catalog-info.yaml` or Bulk Import
4. Configure custom columns in the catalog table if needed (via `entityTabs` wiring)

**What's native:** Search bar, entity table, kind filters, pagination
**What needs custom work:** The colored stat summary cards (showing "1,247 Components", "89 APIs") → Can be added as a `mountPoint` component on the catalog page, or via a custom catalog page override

**Agent:** `@github-integration` (for GitHub org discovery to populate catalog)
**Agent:** `@ado-integration` (if hybrid: ADO repository discovery)

---

### 2.2 — APIs Page
**Agent:** `@platform`
**Description:** The reference shows API cards with type badges (REST, gRPC, GraphQL, AsyncAPI).

**Configuration tasks:**
1. Enable API Docs plugin (dynamic plugin: `@backstage/plugin-api-docs`)
2. Register APIs in catalog with `kind: API` and `spec.type` (openapi, grpc, graphql, asyncapi)
3. Configure API card display in `dynamicRoutes`

**What's native:** API listing, type filtering, API definition viewer
**What needs custom work:** The card-grid layout (reference shows 6 cards). The native RHDH API page uses a table; a card layout may require a custom `mountPoint` component or the API Docs plugin configuration.

---

### 2.3 — Create Page (Template Gallery)
**Agent:** `@template-engineer`
**Description:** The reference shows 6 Golden Path templates in a card gallery layout. This is **100% native** via the Scaffolder plugin.

**Templates to create (from reference):**
1. **Microservice Template** — "Deploy a production-ready microservice with CI/CD, monitoring, and docs"
2. **Frontend App** — "React/Next.js application with design system integration"
3. **Data Pipeline** — "Apache Airflow DAG with data quality checks"
4. **ML Model Service** — "Deploy ML model with feature store and A/B testing"
5. **API Gateway** — "Kong/Envoy gateway with rate limiting and auth"
6. **Event-Driven Service** — "Kafka consumer/producer with schema registry"

**For each template, create:**
```
golden-paths/
└── {horizon}/
    └── {template_name}/
        ├── template.yaml          # Scaffolder v1beta3
        └── skeleton/
            ├── catalog-info.yaml
            ├── .github/workflows/
            ├── devcontainer.json
            ├── Dockerfile
            └── src/
```

**Agent assignments per template:**
- `@template-engineer` → All 6 `template.yaml` files + skeleton structures
- `@devops` → CI/CD workflows in skeleton (`github/workflows/`)
- `@security` → Security scanning steps in templates
- `@github-integration` → GitHub repo creation actions in templates

**Handoff:** → `@reviewer` (review template quality), → `@test` (test template execution)

---

### 2.4 — Docs Page (TechDocs)
**Agent:** `@docs` → `@platform`
**Description:** The reference shows a docs page with search and documentation cards.

**Configuration tasks:**
1. Enable TechDocs plugin (dynamic plugin)
2. Configure TechDocs storage backend (S3 or ODF)
3. Set up `mkdocs.yml` in each service repo
4. Configure TechDocs builder: `local` (dev) or `external` (CI/CD)
5. Create documentation categories matching reference: Getting Started, Architecture Guide, API Reference, Security Playbook, Onboarding Guide, Platform Operations

**What's native:** Full TechDocs experience with search
**What needs work:** The card-grid layout in the reference. TechDocs native UI uses a table; cards may need `mountPoint` customization.

**Agent:** `@docs` → Create documentation content for all 6 categories
**Agent:** `@platform` → Configure TechDocs plugin settings

---

### 2.5 — Lightspeed Page
**Agent:** `@platform`
**Description:** The reference shows an AI chat interface. This maps to **RHDH Lightspeed** (Developer Preview).

**Configuration tasks:**
1. Enable Lightspeed dynamic plugin
2. Configure AI model provider (OpenAI, Azure OpenAI, or RHAI)
3. Set up Lightspeed permissions in RBAC

```yaml
dynamicPlugins:
  frontend:
    lightspeed:
      enabled: true
      config:
        ai:
          provider: azure-openai
          endpoint: ${AZURE_OPENAI_ENDPOINT}
          apiKey: ${AZURE_OPENAI_KEY}
```

**What's native:** Full chat UI, conversation history, model switching
**What needs custom work:** The "suggested prompts" cards from the reference. These can be configured via Lightspeed plugin config if supported, or via a custom `mountPoint`.

---

### 2.6 — Notifications Page
**Agent:** `@platform`
**Description:** The reference shows an event feed with deployment, PR, and security notifications.

**Configuration tasks:**
1. Enable Notifications dynamic plugin (`@backstage-community/plugin-notifications`)
2. Configure notification sources (GitHub webhooks, ArgoCD events, security scanners)
3. Set up notification routing rules

**What's native:** Full notification UI with filtering
**What needs custom work:** The colored severity badges and category icons from the reference. Minor CSS customization.

---

### 2.7 — Administration Page
**Agent:** `@platform` → `@security`
**Description:** The reference shows RBAC management and plugin administration.

**Configuration tasks:**
1. Enable RBAC Web UI plugin (built-in with RHDH 1.8)
2. Configure role definitions in `rbac-policy.csv`
3. Enable Dynamic Plugin admin UI (if available)

**Roles to create (from reference):**
| Role | Permissions |
|------|-------------|
| Platform Admin | Full access to all features, RBAC management |
| Developer | Catalog read, Create templates, TechDocs, Lightspeed |
| Team Lead | Developer + My Group dashboard, team management |
| Viewer | Read-only catalog, docs, APIs |

**Agent:** `@security` → Define RBAC policies, review role definitions
**Agent:** `@platform` → Implement RBAC configuration

---

### 2.8 — Settings Page
**Agent:** `@platform`
**Description:** The reference shows user profile and integration settings. This is **100% native**.

**Configuration tasks:**
1. User Settings plugin is built-in
2. Configure authentication providers (Microsoft Entra ID, GitHub)
3. Enable integration toggles

**What's native:** Full settings UI including profile, auth tokens, theme toggle
**What needs custom work:** The "Integration Status" cards from the reference (GitHub Connected, Azure DevOps Active, etc.) → Minor custom `mountPoint` component

---

## Phase 3: Custom Plugins Development

### 3.1 — Custom Home Page Plugin
**Agent:** `@architect` (design) → `@platform` (develop) → `@devops` (CI/CD)
**Priority:** 🔴 HIGH — This is the centerpiece of the customization.

**Description:** Create a custom RHDH dynamic plugin that replaces the default home page with the Three Horizons Portal home page design.

**Components to build (React):**

| Component | Description | Data Source |
|-----------|-------------|-------------|
| `HeroBanner` | Welcome message with search bar | Static + Catalog Search API |
| `StatCards` | 4 colored stat cards (Components, APIs, Templates, Teams) | Catalog API (`/api/catalog/entities/count`) |
| `HorizonCards` | 3 cards for H1/H2/H3 with progress bars | Custom backend API or static config |
| `QuickAccess` | 6 shortcut buttons (Create Service, View APIs, etc.) | Static routes |
| `FeaturedTemplates` | 3 template cards with "Use Template" buttons | Scaffolder API (`/api/scaffolder/templates`) |
| `ColorBar` | 4-color Microsoft gradient bar at page top | Pure CSS |

**Technical approach:**
1. Use **Dynamic Plugin Factory** to scaffold the plugin
2. Build as a React frontend plugin consuming Backstage APIs:
   - `@backstage/catalog-client` for entity counts
   - `@backstage/plugin-scaffolder` for template listing
3. Register via `dynamicRoutes` as the `/` route
4. Package as OCI artifact for dynamic loading

**File structure:**
```
plugins/
└── home-page-three-horizons/
    ├── package.json
    ├── src/
    │   ├── plugin.ts
    │   ├── components/
    │   │   ├── HomePage.tsx
    │   │   ├── HeroBanner.tsx
    │   │   ├── StatCards.tsx
    │   │   ├── HorizonCards.tsx
    │   │   ├── QuickAccess.tsx
    │   │   └── FeaturedTemplates.tsx
    │   └── api/
    │       └── catalogStats.ts
    └── dev/
        └── index.tsx
```

**Plugin wiring (`dynamic-plugins-config.yaml`):**
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

**Estimated effort:** 3-5 days
**Handoff:** → `@test` (unit tests), → `@reviewer` (code review), → `@devops` (build pipeline)

---

### 3.2 — Custom My Group Dashboard Plugin
**Agent:** `@architect` (design) → `@platform` (develop) → `@devops` (CI/CD)
**Priority:** 🟡 MEDIUM

**Description:** Create a custom plugin showing team-scoped dashboard with member list and owned components.

**Components to build (React):**

| Component | Description | Data Source |
|-----------|-------------|-------------|
| `GroupHeader` | Team name, description, member count | Catalog API (Group entity) |
| `MemberList` | Team members with roles | Catalog API (User entities via `memberOf`) |
| `OwnedComponents` | Table of team-owned services | Catalog API (filter by `spec.owner`) |
| `GroupStats` | Deployment frequency, PR velocity | Scorecard API or custom metrics |

**Technical approach:**
1. Use `@backstage/catalog-client` to fetch Group + owned entities
2. Use `identityApi` to resolve current user's group membership
3. Register via `dynamicRoutes` as `/my-group`

**Estimated effort:** 2-3 days
**Handoff:** → `@test`, → `@reviewer`, → `@devops`

---

### 3.3 — Learning Paths Page (Custom or TechDocs)
**Agent:** `@docs` → `@platform`
**Priority:** 🟢 LOW (can be approximated with TechDocs)

**Two approaches:**

**Option A — TechDocs Route (Simpler):**
- Create a dedicated TechDocs site at `/docs/learning-paths`
- Structure as MkDocs with categories: Platform Fundamentals, Cloud Native Development, Security Best Practices, AI/ML Operations, DevOps Excellence, Advanced Architecture

**Option B — Custom Plugin (Richer):**
- Build a React plugin with card-grid layout matching the reference
- Each card links to a TechDocs page or external resource
- Includes progress tracking per user (requires backend)

**Recommendation:** Start with Option A, upgrade to Option B in Phase 5 if needed.

---

## Phase 4: Plugin Build & Deployment Pipeline

### 4.1 — CI/CD for Custom Plugins
**Agent:** `@devops`
**Description:** Set up build pipeline for the custom plugins.

**Pipeline steps:**
1. `npm install` → `npm run build` → `npm test`
2. Run `npx @janus-idp/cli package export-dynamic-plugin` to convert to dynamic plugin
3. Push OCI artifact to ACR
4. Update `dynamic-plugins-config.yaml` with new plugin reference
5. Trigger RHDH Helm upgrade

**GitHub Actions workflow:**
```yaml
name: Build RHDH Plugins
on:
  push:
    paths: ['plugins/**']
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci && npm test && npm run build
      - run: npx @janus-idp/cli package export-dynamic-plugin
      - uses: azure/docker-login@v1
        with:
          login-server: ${{ secrets.ACR_NAME }}.azurecr.io
      - run: |
          oras push ${{ secrets.ACR_NAME }}.azurecr.io/plugins/home-page:${{ github.sha }} \
            dist-dynamic/*
```

**Handoff:** → `@deploy` (Helm upgrade), → `@security` (scan OCI artifact)

---

### 4.2 — Deploy Updated Portal
**Agent:** `@deploy`
**Description:** Orchestrate the full deployment with updated configuration and custom plugins.

**Deployment sequence:**
1. Update `app-config.yaml` with branding config
2. Update `dynamic-plugins-config.yaml` with all plugin references
3. Update `rbac-policy.csv` with role definitions
4. Run `helm upgrade --install backstage backstage/backstage --values values-aks.yaml`
5. Verify pods are running
6. Validate all 11 pages are accessible

**Handoff:** → `@sre` (monitoring setup), → `@onboarding` (user guides)

---

## Phase 5: Polish & Post-Deployment

### 5.1 — Monitoring & SLOs
**Agent:** `@sre`
**Description:** Set up monitoring for the portal.

**Tasks:**
- Configure Prometheus metrics export from RHDH
- Set up Grafana dashboards for portal health
- Define SLOs: 99.9% uptime, < 2s page load, < 500ms API response

---

### 5.2 — Security Review
**Agent:** `@security`
**Description:** Final security review of all configuration and custom plugins.

**Tasks:**
- Review RBAC policies for least-privilege compliance
- Scan custom plugin code for vulnerabilities (trivy, gitleaks)
- Verify Key Vault integration for all secrets
- Review auth provider configuration (Entra ID + GitHub)

---

### 5.3 — User Onboarding
**Agent:** `@onboarding`
**Description:** Create onboarding materials for the new portal.

**Tasks:**
- Create "Getting Started" guide for the new portal
- Record walkthrough of all 11 pages
- Set up "first-day" Golden Path template execution flow

---

### 5.4 — Testing
**Agent:** `@test`
**Description:** End-to-end testing of the portal.

**Tasks:**
- Unit tests for Custom Home Page Plugin components
- Unit tests for My Group Dashboard Plugin components
- Integration tests: Catalog API, Scaffolder API, TechDocs
- E2E smoke test: Navigate all 11 pages, execute a template, view docs

---

### 5.5 — Code Review
**Agent:** `@reviewer`
**Description:** Review all custom code and configuration.

**Tasks:**
- Review Custom Home Page Plugin code (SOLID, Clean Code)
- Review My Group Dashboard Plugin code
- Review `app-config.yaml` changes
- Review `dynamic-plugins-config.yaml` changes
- Review RBAC policies

---

## Implementation Timeline

```
Week 1:  Phase 0 (Architecture) + Phase 1 (Branding)
         @architect → @platform → @security

Week 2:  Phase 2.1-2.4 (Catalog, APIs, Create, Docs)
         @platform → @template-engineer → @docs → @github-integration

Week 3:  Phase 2.5-2.8 (Lightspeed, Notifications, Admin, Settings)
         @platform → @security

Week 4:  Phase 3.1 (Custom Home Page Plugin)
         @architect → @platform → @test → @reviewer

Week 5:  Phase 3.2-3.3 (My Group + Learning Paths)
         @platform → @docs → @test → @reviewer

Week 6:  Phase 4 (CI/CD + Deploy) + Phase 5 (Polish)
         @devops → @deploy → @sre → @security → @onboarding
```

---

## Agent Assignment Summary

| Agent | Phases | Primary Tasks |
|-------|--------|---------------|
| `@architect` | 0.1, 3.1, 3.2 | Architecture design, plugin component design, ADR |
| `@platform` | 1.1, 1.2, 2.1-2.8, 3.1, 3.2 | **PRIMARY AGENT** — All RHDH config + custom plugin development |
| `@template-engineer` | 2.3 | Create 6 Golden Path templates |
| `@devops` | 4.1 | CI/CD pipeline for plugins, GitOps |
| `@deploy` | 0.2, 4.2 | Infrastructure + Helm deployment |
| `@docs` | 2.4, 3.3 | TechDocs content, Learning Paths |
| `@security` | 1.2, 2.7, 5.2 | RBAC, auth, security review |
| `@github-integration` | 2.1, 2.3 | GitHub org discovery, template actions |
| `@terraform` | 0.2 | Azure infrastructure modules |
| `@azure-portal-deploy` | 0.2 | AKS, PostgreSQL, Key Vault provisioning |
| `@test` | 3.1, 3.2, 5.4 | Plugin unit tests, integration tests |
| `@reviewer` | 3.1, 3.2, 5.5 | Code review for plugins and config |
| `@sre` | 5.1 | Monitoring, SLOs, Grafana dashboards |
| `@onboarding` | 5.3 | User guides, walkthrough docs |
| `@ado-integration` | 2.1 | ADO discovery (if hybrid scenario) |
| `@hybrid-scenarios` | 2.1 | GitHub + ADO coexistence (if applicable) |

---

## Quick-Start: First 3 Commands

To begin implementation immediately:

1. **`@architect`** → "Design the plugin architecture for the Three Horizons Portal customization, including Custom Home Page Plugin and My Group Dashboard Plugin. Produce an ADR."

2. **`@platform`** → "Configure RHDH branding in app-config.yaml with Microsoft colors (#0078D4 primary, #1B1B1F sidebar) and set up the 11-page sidebar navigation."

3. **`@template-engineer`** → "Create the 6 Golden Path templates: Microservice, Frontend App, Data Pipeline, ML Model Service, API Gateway, Event-Driven Service."
