# @rhdh-architect — Execution Prompts & Orchestration Plan

> **Purpose:** Copy-paste ready prompts to execute the entire Three Horizons Portal customization using the @rhdh-architect agent and its 15-agent ecosystem.
> **Author:** paulasilva@microsoft.com | Latam Software GBB
> **Version:** 1.0 | March 2026

---

## How to Use This Guide

1. **Copy the agent directory** to your Copilot workspace:
   ```bash
   cp -r agents/rhdh-architect/ .github/copilot/agents/
   ```

2. **Follow the phases in order** — each phase produces inputs for the next
3. **Wait for validation gates** before proceeding to the next phase
4. **Use the exact prompts below** — they reference the skill, references, and assets the agent needs

---

## MASTER PROMPT — Full Orchestration (One-Shot)

Use this single prompt with `@deploy` to trigger the entire workflow:

```
@deploy Execute the portal-customization workflow.

Context: We are customizing RHDH 1.8 to match the Three Horizons Developer Hub
reference template (three-horizons-portal.html). The @rhdh-architect agent has all
the architecture knowledge, skills, and references needed.

Execution mode: Phase-by-Phase (pause at each validation gate for my approval).

Workflow file: agents/rhdh-architect/workflows/portal-customization.workflow.md

Phase sequence:
1. @rhdh-architect → Architecture design (ADRs + component specs + config YAML)
2. @platform → Branding & sidebar navigation
3. @platform + @template-engineer + @docs + @github-integration → Native pages (parallel)
4. @rhdh-architect specs → @platform code → @test + @reviewer → Custom plugins
5. @devops → CI/CD pipeline → @deploy → Helm deployment
6. @security + @sre + @onboarding → Polish & verification

Start with Phase 0: call @rhdh-architect to design the architecture.
Pre-deploy hook: agents/rhdh-architect/hooks/pre-deploy-validate.hook.md
```

---

## PHASE 0 — Architecture Design

### Prompt 0.1: Full Architecture Design (Primary)

```
@rhdh-architect Design the complete plugin architecture for the Three Horizons
Portal customization.

Use your rhdh-plugin-design skill. Read these references:
- skills/rhdh-plugin-design/references/portal-gap-analysis.md (14-page gap analysis)
- skills/rhdh-plugin-design/references/frontend-wiring.md (8 wiring mechanisms)
- skills/rhdh-plugin-design/references/backstage-apis.md (API catalog)
- ../../RHDH_Official_Documentation_Guide.md (compiled from 31 PDFs)

For each of the 11 portal pages, apply the Decision Framework:
1. Can it be solved with app-config.yaml only? → config snippet
2. Is there a supported RHDH dynamic plugin? → enable and wire it
3. Is there a community Backstage plugin? → evaluate Dynamic Plugin Factory
4. None → design a custom dynamic plugin

Deliverables I need:
- ADR-001: Custom Home Page Plugin architecture (HeroBanner, StatCards, HorizonCards,
  QuickAccess, FeaturedTemplates, ColorBar)
- ADR-002: Custom My Group Dashboard Plugin architecture (GroupHeader, GroupStats,
  MemberList, OwnedComponents)
- Component specifications for each custom React component (props, data sources,
  Backstage APIs consumed, visual requirements)
- Ready-to-use app-config.yaml branding section (use assets/three-horizons-branding.yaml
  as baseline)
- Ready-to-use dynamic-plugins-config.yaml for all 13 pages
  (use assets/dynamic-plugins-three-horizons.yaml as baseline)
- Effort estimate per page

After generating the YAML, validate it using:
  python scripts/validate-plugin-config.py <config-files>
```

### Prompt 0.2: Architecture Review Only (Quick)

```
@rhdh-architect I have the Three Horizons Portal reference template
(three-horizons-portal.html).

Give me a quick gap analysis: for each of the 13 pages, tell me:
- Native (config only), Dynamic Plugin (enable + wire), or Custom Plugin (build)?
- Which Backstage APIs does each page consume?
- Effort estimate in days?

Use your portal-gap-analysis.md reference.
```

### Prompt 0.3: Single Plugin Architecture

```
@rhdh-architect Design only the Custom Home Page Plugin for RHDH.

The home page needs these components:
- HeroBanner: Welcome message + search bar (uses catalogApiRef search)
- StatCards: 4 colored cards showing counts (Components, APIs, Templates, Teams)
  from catalogApiRef.getEntityFacets()
- HorizonCards: 3 cards for H1/H2/H3 with progress bars (static config or custom API)
- QuickAccess: 6 shortcut buttons linking to Create, APIs, Docs, etc.
- FeaturedTemplates: 3 template cards from scaffolderApiRef.listTasks()
- ColorBar: Microsoft 4-color gradient bar (pure CSS)

Produce:
1. ADR with decision rationale
2. Component specification with TypeScript interfaces for each component
3. dynamicRoutes wiring to register as the "/" route
4. Scaffold command: ./scripts/scaffold-plugin.sh home-three-horizons ./plugins
```

---

## PHASE 1 — Branding & Navigation

### Prompt 1.1: Apply Microsoft Branding

```
@platform Apply Microsoft branding to the RHDH instance.

Use the branding configuration from:
  agents/rhdh-architect/skills/rhdh-plugin-design/assets/three-horizons-branding.yaml

Tasks:
1. Upload Microsoft logo SVGs to the branding path
2. Configure app-config.yaml:
   - primaryColor: '#0078D4' (Microsoft Blue)
   - Dark sidebar background: '#1B1B1F'
   - 4-color header: Red #F25022, Green #7FBA00, Blue #00A4EF, Yellow #FFB900
   - Typography: Segoe UI
3. Set navigation indicator color to Microsoft Blue

Validation criteria:
- [ ] Logo displays correctly in sidebar header
- [ ] Sidebar background is dark (#1B1B1F)
- [ ] Primary blue (#0078D4) applied to navigation indicator
- [ ] Header color bar shows 4 Microsoft logo colors
```

### Prompt 1.2: Configure Sidebar Navigation

```
@platform Configure the RHDH sidebar navigation with all 13 pages.

Use the dynamic-plugins-config.yaml from:
  agents/rhdh-architect/skills/rhdh-plugin-design/assets/dynamic-plugins-three-horizons.yaml

Menu items (in order):
1. Home → HomeIcon → / (custom plugin, Phase 3)
2. My Group → GroupIcon → /my-group (custom plugin, Phase 3)
3. Catalog → CategoryIcon → /catalog (native)
4. APIs → ExtensionIcon → /api-docs (native)
5. Create → CreateComponentIcon → /create (native scaffolder)
6. Docs → LibraryBooksIcon → /docs (native techdocs)
7. Lightspeed → ChatIcon → /lightspeed (dynamic plugin)
8. Copilot Metrics → AssessmentIcon → /copilot-metrics (custom plugin)
9. GHAS Metrics → SecurityIcon → /ghas-metrics (custom plugin)
10. Notifications → NotificationsIcon → /notifications (dynamic plugin)
11. Administration → AdminPanelSettingsIcon → /admin/rbac (native RBAC)
12. Settings → SettingsIcon → /settings (native)
13. Topology → StorageIcon → /topology (dynamic plugin)

Validate: all 13 items visible in sidebar with correct icons.
```

---

## PHASE 2 — Native Pages Configuration

### Prompt 2.1: Configure All Native Plugins (Parallel)

```
@platform Enable and configure all native/dynamic plugins for the portal.

Plugins to enable in dynamic-plugins-config.yaml:
1. @backstage/plugin-catalog — Catalog page with search, filters, entity table
2. @backstage/plugin-api-docs — API documentation with Swagger/AsyncAPI
3. @backstage/plugin-scaffolder — Template gallery (Create page)
4. @backstage/plugin-techdocs — TechDocs with MkDocs backend
5. @backstage-community/plugin-lightspeed — AI chat (configure Azure OpenAI)
6. @backstage-community/plugin-notifications — Event feed
7. @janus-idp/plugin-rbac — RBAC admin UI
8. @backstage/plugin-user-settings — User profile/settings
9. @janus-idp/plugin-topology — Kubernetes topology view

For Lightspeed, configure Azure OpenAI:
  provider: azure-openai
  endpoint: ${AZURE_OPENAI_ENDPOINT}
  apiKey: ${AZURE_OPENAI_KEY}

Validation: each plugin page loads without errors.
```

### Prompt 2.2: Create Golden Path Templates

```
@template-engineer Create 6 Golden Path templates for the RHDH Create page.

Templates to create (all Scaffolder v1beta3):

1. Microservice Template (nodejs-microservice)
   - Node.js Express microservice with CI/CD, monitoring, TechDocs
   - Includes: Dockerfile, GitHub Actions, devcontainer.json

2. Frontend App (react-frontend)
   - React/Next.js with design system integration
   - Includes: Tailwind CSS, testing, Storybook

3. Data Pipeline (python-data-pipeline)
   - Apache Airflow DAG with data quality checks
   - Includes: dbt models, Great Expectations

4. ML Model Service (ml-model-service)
   - Python ML model with feature store and A/B testing
   - Includes: MLflow, BentoML, monitoring

5. API Gateway (api-gateway)
   - Kong/Envoy gateway with rate limiting and auth
   - Includes: OpenAPI spec, rate limit configs

6. Event-Driven Service (event-driven-service)
   - Kafka consumer/producer with schema registry
   - Includes: Avro schemas, dead letter queue

For each template, create:
  golden-paths/h1/{name}/template.yaml
  golden-paths/h1/{name}/skeleton/catalog-info.yaml
  golden-paths/h1/{name}/skeleton/.github/workflows/ci.yaml
  golden-paths/h1/{name}/skeleton/Dockerfile
  golden-paths/h1/{name}/skeleton/devcontainer.json
```

### Prompt 2.3: Create TechDocs Content

```
@docs Create TechDocs content structure for the RHDH Docs page.

Categories to create (matching reference template):
1. Getting Started — Platform onboarding guide
2. Architecture Guide — System architecture patterns and decisions
3. API Reference — How to register and document APIs
4. Security Playbook — Security practices and RBAC guide
5. Onboarding Guide — New developer 30-day checklist
6. Platform Operations — Runbooks and operational procedures

For each category, create:
  docs/{category}/mkdocs.yml
  docs/{category}/docs/index.md
  docs/{category}/docs/overview.md

Configure TechDocs backend: 'local' builder for dev, 'external' for production.
```

### Prompt 2.4: Configure GitHub Discovery

```
@github-integration Configure GitHub App and org discovery for RHDH catalog.

Tasks:
1. Configure GitHub App integration in app-config.yaml
2. Set up GitHub discovery catalog provider to auto-import repositories
3. Configure entity provider to read catalog-info.yaml from all repos
4. Set up GitHub Actions integration for CI/CD status in entity pages

Validation: catalog shows discovered entities from GitHub org.
```

---

## PHASE 3 — Custom Plugins Development

### Prompt 3.1: Build Home Page Plugin

```
@platform Implement the Custom Home Page Plugin for RHDH.

Scaffold first:
  ./scripts/scaffold-plugin.sh home-three-horizons ./plugins

Then implement these React components using the specs from @rhdh-architect:

1. HomePage.tsx — Main container, layout grid
2. HeroBanner.tsx — Welcome message + search bar
   - Uses: catalogApiRef (search)
3. StatCards.tsx — 4 cards: Components count, APIs count, Templates count, Teams count
   - Uses: catalogApiRef.getEntityFacets()
   - Each card has a colored top border (Red, Green, Blue, Yellow)
4. HorizonCards.tsx — 3 cards for H1/H2/H3 with progress bars
   - Static config or custom backend API
5. QuickAccess.tsx — 6 shortcut buttons (Create, APIs, Docs, etc.)
   - Pure route links
6. FeaturedTemplates.tsx — 3 template cards with "Use Template" buttons
   - Uses: scaffolderApiRef
7. ColorBar.tsx — Microsoft 4-color gradient bar (pure CSS)

Follow the code standards in:
  agents/rhdh-architect/instructions/rhdh-plugin-architecture.instructions.md

Microsoft colors: Red #F25022, Green #7FBA00, Blue #00A4EF, Yellow #FFB900
Dark sidebar: #1B1B1F, Primary: #0078D4

After implementation:
  npx @janus-idp/cli package export-dynamic-plugin
  oras push myacr.azurecr.io/plugins/home-three-horizons:1.0.0
```

### Prompt 3.2: Build My Group Plugin

```
@platform Implement the Custom My Group Dashboard Plugin for RHDH.

Scaffold:
  ./scripts/scaffold-plugin.sh my-group-dashboard ./plugins

Components to implement:

1. MyGroupPage.tsx — Main container
2. GroupHeader.tsx — Team name, description, member count
   - Uses: catalogApiRef.getEntityByRef() for Group entity
   - Uses: identityApiRef to resolve current user's group
3. GroupStats.tsx — Deployment frequency, PR velocity stats
   - Uses: catalogApiRef for owned entity counts
4. MemberList.tsx — Team members with roles
   - Uses: catalogApiRef (filter User entities by memberOf relation)
5. OwnedComponents.tsx — Table of team-owned services
   - Uses: catalogApiRef (filter by spec.owner = current group)

Wire as dynamicRoute at /my-group with GroupIcon sidebar item.

Same code standards and build/push flow as the Home Page plugin.
```

### Prompt 3.3: Build Copilot Metrics Plugin (Frontend + Backend)

```
@platform Implement the Copilot Metrics Dashboard Plugin for RHDH.

This is a FULL-STACK plugin (frontend + backend proxy to GitHub REST API).

Scaffold:
  ./scripts/scaffold-plugin.sh copilot-metrics ./plugins

BACKEND — GitHub API Proxy (Express router):
Create copilot-metrics-backend with Express routes:
- GET /api/copilot-metrics/org → proxies GitHub GET /orgs/{org}/copilot/metrics
- GET /api/copilot-metrics/team/:slug → proxies GitHub GET /orgs/{org}/team/{slug}/copilot/metrics
- GET /api/copilot-metrics/billing → proxies GitHub GET /orgs/{org}/copilot/billing
- Auth: GITHUB_COPILOT_METRICS_PAT from config (Key Vault via CSI Driver)
- Headers: Accept: application/vnd.github+json, X-GitHub-Api-Version: 2022-11-28

FRONTEND — React Dashboard:
1. CopilotMetricsPage.tsx — Main layout grid
2. ActiveUsersCard.tsx — total_active_users + total_engaged_users + trend arrow
3. SeatUtilization.tsx — Gauge: assigned vs active seats (from /billing)
4. AcceptanceRateChart.tsx — 30-day line chart (recharts): acceptance rate %
5. LanguageBreakdown.tsx — Table: language, lines suggested, accepted, rate %
6. IdeUsageChart.tsx — Bar chart: usage by editor (VS Code, JetBrains, etc.)
7. TeamComparison.tsx — Table: team name, active users, engaged, acceptance rate
8. ChatUsageStats.tsx — 3 cards: IDE Chat, Dotcom Chat, PR Summaries
9. TrendSparklines.tsx — 30-day sparkline charts for key metrics

Chart colors: Blue #0078D4 (primary), Green #107C10 (secondary),
Yellow #FFB900 (accent), Red #D13438 (alert)

Wire at /copilot-metrics with AssessmentIcon.

After implementation:
  npx @janus-idp/cli package export-dynamic-plugin
  oras push myacr.azurecr.io/plugins/copilot-metrics:1.0.0
```

### Prompt 3.4: Build GHAS Metrics Plugin (Frontend + Backend)

```
@platform Implement the GitHub Advanced Security (GHAS) Metrics Dashboard Plugin for RHDH.

This is a FULL-STACK plugin (frontend + backend proxy to GitHub REST API).
The backend needs AGGREGATION logic since Dependabot is repo-level only.

Scaffold:
  ./scripts/scaffold-plugin.sh ghas-metrics ./plugins

BACKEND — GitHub API Proxy + Aggregator (Express router):
Create ghas-metrics-backend with Express routes:
- GET /api/ghas-metrics/code-scanning → proxies GitHub GET /orgs/{org}/code-scanning/alerts
  Supports query params: state (open/closed/dismissed), severity, tool_name
- GET /api/ghas-metrics/secret-scanning → proxies GitHub GET /orgs/{org}/secret-scanning/alerts
  Supports query params: state, secret_type, resolution, validity
- GET /api/ghas-metrics/dependabot → AGGREGATES across all org repos
  Iterates GET /repos/{owner}/{repo}/dependabot/alerts for each repo
  Returns aggregated counts by severity + ecosystem
- GET /api/ghas-metrics/billing → proxies GitHub GET /orgs/{org}/settings/billing/advanced-security
  Returns total_advanced_security_committers + per-repo breakdown
- GET /api/ghas-metrics/mttr → COMPUTES Mean Time To Remediate
  Fetches closed code-scanning alerts, calculates avg(fixed_at - created_at) per severity
- Auth: GITHUB_GHAS_METRICS_PAT from config (Key Vault via CSI Driver)
  Scopes needed: security_events, repo, admin:org
- Headers: Accept: application/vnd.github+json, X-GitHub-Api-Version: 2022-11-28
- Add caching layer (5-min TTL) to avoid GitHub rate limits on aggregation

FRONTEND — React Dashboard:
1. GhasMetricsPage.tsx — Main layout grid (2-column responsive)
2. CodeScanningCard.tsx — Summary: open/fixed/dismissed by severity, filterable
3. SecretScanningCard.tsx — Summary: open/resolved, validity status badges
4. DependabotAlertsCard.tsx — Aggregated: severity breakdown + ecosystem pie chart
5. GhasCommittersCard.tsx — Total committers gauge + top repos table
6. SecurityTrendChart.tsx — 30-day line chart (recharts): alerts opened vs closed
7. SeverityBreakdown.tsx — Donut chart: critical(red)/high(orange)/medium(yellow)/low(blue)
8. MttrMetrics.tsx — 4 cards: MTTR by severity tier (critical/high/medium/low)
9. PushProtectionCard.tsx — Bypass count + recent bypass events list
10. RepoCoverageTable.tsx — Table: repo name, GHAS enabled?, committers, last scan

Chart colors: Red #D13438 (critical), Orange #FFB900 (high),
Yellow #FFF100 (medium), Blue #0078D4 (low), Green #107C10 (fixed)

Wire at /ghas-metrics with SecurityIcon.

After implementation:
  npx @janus-idp/cli package export-dynamic-plugin
  oras push myacr.azurecr.io/plugins/ghas-metrics:1.0.0
```

### Prompt 3.5: Test Custom Plugins

```
@test Write unit and integration tests for the custom RHDH plugins.

For home-three-horizons plugin:
- Test StatCards renders correct counts from mocked catalogApiRef
- Test HeroBanner search triggers catalogApiRef search
- Test FeaturedTemplates renders cards from mocked scaffolderApiRef
- Test QuickAccess buttons link to correct routes
- Use TestApiProvider to mock all Backstage API refs
- Target: >80% code coverage

For my-group-dashboard plugin:
- Test GroupHeader displays group info from mocked catalogApiRef
- Test MemberList renders members from mocked catalog relations
- Test OwnedComponents filters entities by owner correctly
- Test identityApiRef resolves current user's group

For copilot-metrics plugin (frontend + backend):
- Test ActiveUsersCard renders total_active_users from mocked API response
- Test AcceptanceRateChart renders 30-day line chart from mocked data
- Test LanguageBreakdown table shows per-language stats
- Test SeatUtilization gauge handles zero seats gracefully
- Test backend router returns 401 when PAT is missing/invalid
- Test backend proxy correctly rewrites paths to GitHub API
- Mock GitHub API responses (use fixtures from Copilot Metrics API docs)

For ghas-metrics plugin (frontend + backend):
- Test CodeScanningCard renders alert counts by severity from mocked data
- Test SecretScanningCard shows validity badges (active/inactive/unknown)
- Test DependabotAlertsCard aggregates across multiple repos correctly
- Test GhasCommittersCard gauge displays percentage utilization
- Test SecurityTrendChart renders 30-day trend line from time-series data
- Test SeverityBreakdown donut renders correct proportions
- Test MttrMetrics computes average correctly from mocked alert pairs
- Test RepoCoverageTable shows repos with/without GHAS enabled
- Test backend aggregator correctly rolls up repo-level Dependabot data
- Test backend caching layer returns cached results within TTL
- Test backend returns 403 when PAT lacks required scopes
- Mock GitHub API responses for code-scanning, secret-scanning, billing

Run: npm test -- --coverage
```

### Prompt 3.6: Code Review

```
@reviewer Review the custom RHDH plugins for quality.

Review criteria:
- SOLID principles applied to React components
- Backstage API usage follows official patterns (useApi hook, not direct fetch)
- MUI theming with MS_COLORS constants (not hardcoded hex values)
- Error handling: ErrorBoundary wrapping, Progress spinner, ResponseErrorPanel
- TypeScript strict mode, no 'any' types
- Plugin exports follow Dynamic Plugin packaging requirements
- No security issues (no hardcoded credentials, proper RBAC checks)

Files to review:
  plugins/home-three-horizons/src/**/*.tsx
  plugins/my-group-dashboard/src/**/*.tsx
  plugins/copilot-metrics/copilot-metrics-frontend/src/**/*.tsx
  plugins/copilot-metrics/copilot-metrics-backend/src/**/*.ts
  plugins/ghas-metrics/ghas-metrics-frontend/src/**/*.tsx
  plugins/ghas-metrics/ghas-metrics-backend/src/**/*.ts

Additional review focus for backend plugins:
- GitHub API client handles pagination (Link header) correctly
- Rate limiting: respects X-RateLimit headers, implements backoff
- Caching: TTL-based cache with proper invalidation
- Secrets: PATs loaded from config (Key Vault), never hardcoded
- Error responses: maps GitHub 4xx/5xx to user-friendly messages
```

---

## PHASE 4 — CI/CD & Deployment

### Prompt 4.1: Create Plugin Build Pipeline

```
@devops Set up CI/CD pipeline for the custom RHDH dynamic plugins.

Create: .github/workflows/build-rhdh-plugins.yaml

Pipeline:
- Trigger: push to plugins/** on main branch
- Steps:
  1. npm ci
  2. npm run lint
  3. npm test -- --coverage (fail if <80%)
  4. npm run build
  5. npx @janus-idp/cli package export-dynamic-plugin
  6. Login to ACR: azure/docker-login
  7. oras push to ACR: plugins/{name}:{sha}
  8. Update dynamic-plugins-config.yaml with new OCI reference
  9. Trigger Helm upgrade (via ArgoCD sync or manual)

Environment variables needed:
- ACR_NAME, ACR_USERNAME, ACR_PASSWORD
- RHDH_NAMESPACE, HELM_RELEASE_NAME
```

### Prompt 4.2: Deploy Updated Portal

```
@deploy Deploy the complete Three Horizons Portal to RHDH.

Pre-deployment validation:
  Run the pre-deploy hook: agents/rhdh-architect/hooks/pre-deploy-validate.hook.md
  This validates: YAML syntax, OCI references, route conflicts, RBAC, branding assets.

Deployment steps:
1. Apply updated app-config.yaml (branding + plugin configs)
2. Apply updated dynamic-plugins-config.yaml (all 13 pages wired)
3. Apply updated rbac-policy.csv (Admin, Developer, Team Lead, Viewer roles)
4. Helm upgrade:
   helm upgrade --install backstage backstage/backstage \
     --namespace rhdh \
     --values values-aks.yaml \
     --set global.clusterRouterBase=portal.mycompany.com
5. Verify pods: kubectl get pods -n rhdh
6. Verify all 13 pages accessible

Rollback if failure:
  helm rollback backstage 0 --namespace rhdh
```

---

## PHASE 5 — Polish & Verification

### Prompt 5.1: Security Audit

```
@security Perform final security review of the RHDH portal.

Review:
1. RBAC policies in rbac-policy.csv — verify least-privilege:
   - Admin: full access + RBAC management
   - Developer: catalog read, create templates, techdocs, lightspeed
   - Team Lead: developer + my-group dashboard
   - Viewer: read-only catalog, docs, APIs
2. Auth provider config — Entra ID + GitHub App properly configured
3. Custom plugin code scan — run trivy and gitleaks on plugin source
4. Key Vault integration — all secrets using CSI Driver, no plaintext
5. Network policies — RHDH pods restricted to necessary egress
```

### Prompt 5.2: Monitoring Setup

```
@sre Set up monitoring for the RHDH portal.

Tasks:
1. Configure Prometheus metrics export from RHDH
2. Create Grafana dashboard:
   - Pod health (CPU, memory, restarts)
   - HTTP request latency per page
   - Error rate by plugin
   - Catalog entity count trends
3. Define SLOs:
   - Availability: 99.9% uptime
   - Latency: <2s page load, <500ms API response
   - Error rate: <0.1% 5xx responses
4. Set up alerts for SLO violations
```

### Prompt 5.3: Onboarding Materials

```
@onboarding Create onboarding materials for the Three Horizons Portal.

Create:
1. Getting Started Guide — "Your First 30 Minutes" walkthrough:
   - Login via Entra ID
   - Explore Catalog and find your team's services
   - Run your first Golden Path template
   - Read TechDocs
   - Set up notifications
2. Page-by-Page Reference — what each of the 13 pages does
3. Golden Path Quick Start — step-by-step template execution
4. FAQ — common questions and troubleshooting

Format: TechDocs MkDocs site at /docs/onboarding
```

---

## UTILITY PROMPTS

### Validate Configuration

```
@rhdh-architect Validate my RHDH configuration files.

Run: python scripts/validate-plugin-config.py dynamic-plugins-config.yaml app-config.yaml

Check for:
- YAML syntax errors
- Route conflicts (two plugins claiming same path)
- Invalid icon names in menuItems
- Missing RBAC policies for admin-only plugins
- Branding asset paths exist
```

### Scaffold a New Plugin

```
@rhdh-architect I need a new custom plugin for [DESCRIPTION].

Use the scaffold script:
  ./scripts/scaffold-plugin.sh [plugin-name] ./plugins

Then design the component architecture:
- What Backstage APIs does it need?
- What wiring mechanism (dynamicRoutes, mountPoints, entityTabs)?
- What React components are needed?
- Produce a component spec and ADR.
```

### Add a New Page to the Portal

```
@rhdh-architect I want to add a new page to the portal: [PAGE DESCRIPTION].

Apply the Decision Framework:
1. Can it be done with app-config.yaml? → config only
2. Is there a dynamic plugin? → enable and wire
3. Need custom? → design the plugin

Then:
- Update dynamic-plugins-config.yaml with the new route
- Add menuItem to sidebar navigation
- If custom: produce component spec for @platform to implement
```

---

## AGENT CONTENT MAP

This is what each agent has access to and what it produces:

| Agent | Reads From | Produces |
|-------|-----------|----------|
| `@rhdh-architect` | SKILL.md, 3 references, 2 assets, RHDH_Official_Documentation_Guide.md | ADRs, component specs, YAML configs |
| `@deploy` | workflow, hooks, implementation plan | Helm deployments, pod verification |
| `@platform` | Component specs from @rhdh-architect, branding assets | React plugin code, app-config changes |
| `@template-engineer` | Template specs from @rhdh-architect | Scaffolder v1beta3 templates + skeletons |
| `@devops` | Plugin build specs | GitHub Actions workflows, OCI pipelines |
| `@security` | RBAC specs from @rhdh-architect | rbac-policy.csv, security scan reports |
| `@docs` | TechDocs specs | MkDocs sites, documentation content |
| `@test` | Component specs, API contracts | Unit tests, integration tests |
| `@reviewer` | Plugin source code | Code review feedback |
| `@sre` | Deployment config | Grafana dashboards, SLO definitions |
| `@onboarding` | Portal pages, template specs | User guides, walkthrough docs |
| `@github-integration` | GitHub App config | Catalog discovery, entity providers |
| `@terraform` | AKS requirements | Terraform modules, infrastructure |
| `@azure-portal-deploy` | Helm values | AKS provisioning, Helm install |
| `@ado-integration` | ADO config | ADO repo discovery, pipelines |

---

## QUICK REFERENCE — File Locations

```
agents/rhdh-architect/
├── rhdh-architect.agent.md                          ← Agent definition
├── plugin.md                                        ← Plugin bundle
├── skills/rhdh-plugin-design/
│   ├── SKILL.md                                     ← Primary skill
│   ├── references/
│   │   ├── frontend-wiring.md                       ← 8 wiring mechanisms
│   │   ├── backstage-apis.md                        ← API catalog
│   │   └── portal-gap-analysis.md                   ← 14-page analysis
│   ├── scripts/
│   │   ├── validate-plugin-config.py                ← Config validator
│   │   └── scaffold-plugin.sh                       ← Plugin scaffolder
│   └── assets/
│       ├── three-horizons-branding.yaml             ← Branding config
│       └── dynamic-plugins-three-horizons.yaml      ← Plugin wiring
├── instructions/
│   └── rhdh-plugin-architecture.instructions.md     ← Code standards
├── workflows/
│   └── portal-customization.workflow.md             ← 6-phase workflow
└── hooks/
    └── pre-deploy-validate.hook.md                  ← Pre-deploy checks
```

Supporting files:
```
RHDH_Official_Documentation_Guide.md                 ← 26-section reference (31 PDFs)
RHDH_Three_Horizons_Portal_Implementation_Plan.md    ← Master implementation plan
rhdh_architect_agent_summary_v1.0.docx               ← Professional summary document
```
