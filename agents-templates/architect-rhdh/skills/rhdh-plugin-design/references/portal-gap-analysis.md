# Three Horizons Portal — Gap Analysis

Detailed mapping of every UI element in the Three Horizons Portal HTML reference to RHDH 1.8 capabilities.

## Global Elements

### Color Bar (4-color gradient at top)
- **Reference:** `linear-gradient(to right, #F25022 25%, #7FBA00 50%, #00A4EF 75%, #FFB900 100%)`
- **Native?** No — RHDH theme supports `headerColor1-4` but not a persistent top bar
- **Solution:** Include as a CSS element in the Custom Home Page Plugin, applied globally via theme extension
- **Effort:** 0.5 day (CSS in custom theme)

### Dark Sidebar (#1B1B1F)
- **Reference:** Fixed left sidebar, 220px width, dark background
- **Native?** Partial — RHDH supports sidebar color customization via theme
- **Config:**
  ```yaml
  app:
    branding:
      theme:
        light:
          navigation:
            background: '#1B1B1F'
            color: '#B0B0B0'
            selectedColor: '#FFFFFF'
            indicatorColor: '#00A4EF'
  ```
- **Effort:** 0.5 day

### Microsoft Logo + "Three Horizons" Brand
- **Reference:** MS logo SVG + "Three Horizons" text in sidebar header
- **Native?** Yes — `app.branding.fullLogo` and `app.branding.iconLogo`
- **Config:**
  ```yaml
  app:
    branding:
      fullLogo: /branding/three-horizons-logo.svg
      iconLogo: /branding/ms-icon.svg
  ```
- **Effort:** 0.25 day

### 11-Item Sidebar Navigation
- **Reference:** Home, My Group, Catalog, APIs, Learning Paths, Create, Docs, [divider], Lightspeed, Notifications, Administration, Settings
- **Native?** Mostly — each page plugin adds its own menu item via `menuItems` wiring
- **Gap:** The visual divider between Docs and Lightspeed. RHDH sidebar doesn't support custom dividers natively.
- **Solution:** Use `importance` ordering in menuItems. The divider is cosmetic and can be approximated via plugin ordering.
- **Effort:** 0.5 day

---

## Page-by-Page Analysis

### 1. Home Page

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| Hero Banner (title + subtitle) | No | Custom Home Page Plugin → `HeroBanner` component | Static |
| Global Search Bar | Partial | Use `searchApiRef` in custom component | `searchApiRef` |
| 4 Stat Cards (Components, APIs, Templates, Horizons) | No | Custom Home Page Plugin → `StatCards` component | `catalogApiRef` |
| 3 Horizon Cards (H1, H2, H3) | No | Custom Home Page Plugin → `HorizonCards` component | Static config |
| 4 Quick Access Links | No | Custom Home Page Plugin → `QuickAccess` component | Route links |
| 3 Featured Template Cards | No | Custom Home Page Plugin → `FeaturedTemplates` component | `catalogApiRef` (kind: Template) |

**Verdict:** Needs **Custom Home Page Plugin** (full page, `dynamicRoutes` at `/`)
**Effort:** 3-5 days

### 2. My Group

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| 4 Stat Cards (Components, Members, APIs, Deployments) | No | Custom My Group Plugin → `GroupStats` | `catalogApiRef` |
| Team Components Table | Partial | Custom plugin with catalog filter by owner | `catalogApiRef` |
| Group Header | No | Custom component reading group entity | `catalogApiRef` + `identityApiRef` |

**Verdict:** Needs **Custom My Group Plugin** (full page, `dynamicRoutes` at `/my-group`)
**Effort:** 2-3 days

### 3. Catalog

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| Search Bar | Yes | Built-in catalog search | Native |
| 4 Stat Cards | No | `mountPoint` on catalog page | `catalogApiRef` |
| Entity Table | Yes | Built-in catalog table | Native |
| Filter/Register Buttons | Yes | Built-in | Native |

**Verdict:** 90% native. Add `mountPoint` component for stat cards.
**Effort:** 0.5 day

### 4. APIs

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| Search Bar | Yes | Built-in API docs search | Native |
| API Cards (grid layout) | Partial | API Docs plugin uses table by default; card layout needs customization | `catalogApiRef` |
| Type Badges (OpenAPI, gRPC, GraphQL) | Yes | API entity `spec.type` | Native |

**Verdict:** 80% native. Card grid layout may need `mountPoint` override.
**Effort:** 0.5 day

### 5. Learning Paths

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| 4 Learning Category Cards | No | TechDocs subpage or custom plugin | TechDocs or static |

**Verdict:** Can use TechDocs route. Optional custom plugin for richer card layout.
**Effort:** 1-2 days

### 6. Create

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| Search Bar | Yes | Built-in Scaffolder search | Native |
| 6 Template Cards | Yes | Built-in Scaffolder gallery | Native |

**Verdict:** 100% native. Just create the 6 `template.yaml` files.
**Effort:** 0 (plugin config), 3-5 days (template creation by @template-engineer)

### 7. Docs

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| Search Bar | Yes | TechDocs search | Native |
| 6 Doc Category Cards | Partial | TechDocs default is table; cards need customization | TechDocs |

**Verdict:** 95% native. Card layout is cosmetic.
**Effort:** 0.5 day

### 8. Lightspeed

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| AI Chat Interface | Yes | Enable Lightspeed dynamic plugin | Native |
| 4 Capability Cards | No | Minor `mountPoint` addition | Static |
| Suggested Prompts | Partial | Lightspeed plugin config may support this | Plugin config |

**Verdict:** 100% native (with Lightspeed enabled). Capability cards are cosmetic.
**Effort:** 0.5 day

### 9. Notifications

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| Notification Feed | Yes | Enable Notifications dynamic plugin | Native |
| Color-coded Events | Partial | Plugin supports types; colors need CSS | Plugin config |

**Verdict:** 95% native.
**Effort:** 0.5 day

### 10. Administration

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| RBAC Table | Yes | Enable RBAC Web UI | Native |
| Dynamic Plugins Cards | Partial | Plugin admin panel if available in 1.8 | Native |

**Verdict:** 90% native.
**Effort:** 0.5 day

### 12. Copilot Metrics

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| Active Users Card (total active + engaged) | No | Custom Copilot Metrics Plugin → `ActiveUsersCard` | GitHub REST API `/orgs/{org}/copilot/metrics` |
| Acceptance Rate Chart (suggestions accepted/rejected over time) | No | Custom Plugin → `AcceptanceRateChart` (recharts) | GitHub REST API `copilot_ide_code_completions` |
| Language Breakdown Table (lines suggested/accepted per language) | No | Custom Plugin → `LanguageBreakdown` | GitHub REST API nested `languages` array |
| IDE Usage Chart (VS Code, JetBrains, Neovim breakdown) | No | Custom Plugin → `IdeUsageChart` | GitHub REST API nested `editors` array |
| Team Comparison Table (per-team seat usage + engagement) | No | Custom Plugin → `TeamComparison` | GitHub REST API `/orgs/{org}/team/{slug}/copilot/metrics` |
| Chat Usage Stats (IDE chat + dotcom chat + PR summaries) | No | Custom Plugin → `ChatUsageStats` | GitHub REST API `copilot_ide_chat`, `copilot_dotcom_chat`, `copilot_dotcom_pull_requests` |
| Trend Sparklines (30-day trends for key metrics) | No | Custom Plugin → `TrendSparklines` | GitHub REST API (aggregate last 30 days) |
| Seat Utilization Gauge (assigned vs active seats) | No | Custom Plugin → `SeatUtilization` | GitHub REST API `/orgs/{org}/copilot/billing` |

**Verdict:** Needs **Custom Copilot Metrics Plugin** (full page, `dynamicRoutes` at `/copilot-metrics`).
Requires a **backend plugin** to proxy GitHub REST API calls (auth with org-level PAT or GitHub App).
**Effort:** 4-6 days (frontend 3-4 days, backend proxy 1-2 days)

**GitHub Copilot Metrics API Endpoints (GA — Feb 2026):**
- `GET /orgs/{org}/copilot/metrics` — Org-level daily metrics (up to 100 days)
- `GET /orgs/{org}/team/{team_slug}/copilot/metrics` — Team-level metrics
- `GET /orgs/{org}/copilot/billing` — Seat assignment and billing
- Auth: PAT with `manage_billing:copilot` or `read:org` scope
- Constraint: Only returns data for days with 5+ active Copilot seats

---

### 13. GitHub Advanced Security (GHAS) Metrics

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| Code Scanning Summary (open/fixed/dismissed by severity) | No | Custom GHAS Metrics Plugin → `CodeScanningCard` | GitHub REST API `GET /orgs/{org}/code-scanning/alerts` |
| Secret Scanning Summary (open/resolved alerts, validity status) | No | Custom Plugin → `SecretScanningCard` | GitHub REST API `GET /orgs/{org}/secret-scanning/alerts` |
| Dependabot Alerts Summary (open by severity + ecosystem) | No | Custom Plugin → `DependabotAlertsCard` | GitHub REST API `GET /repos/{owner}/{repo}/dependabot/alerts` (aggregated) |
| Active GHAS Committers (billing/licensing) | No | Custom Plugin → `GhasCommittersCard` | GitHub REST API `GET /orgs/{org}/settings/billing/advanced-security` |
| Security Trend Chart (alerts opened/closed over 30 days) | No | Custom Plugin → `SecurityTrendChart` (recharts) | Aggregate from code-scanning + secret-scanning alerts |
| Severity Breakdown Donut (critical/high/medium/low) | No | Custom Plugin → `SeverityBreakdown` | Code scanning alerts grouped by `rule.security_severity_level` |
| Mean Time To Remediate (MTTR) (avg time from alert open → fixed) | No | Custom Plugin → `MttrMetrics` | Computed from `created_at` vs `fixed_at` on closed alerts |
| Push Protection Bypasses (secret scanning push protection events) | No | Custom Plugin → `PushProtectionCard` | GitHub REST API push protection bypass data |
| Repository Coverage Table (repos with GHAS enabled vs total) | No | Custom Plugin → `RepoCoverageTable` | `GET /orgs/{org}/settings/billing/advanced-security` repo breakdown |

**Verdict:** Needs **Custom GHAS Metrics Plugin** (full page, `dynamicRoutes` at `/ghas-metrics`).
Requires a **backend plugin** to proxy GitHub REST API calls (auth with org-level PAT or GitHub App).
**Effort:** 5-7 days (frontend 3-4 days, backend proxy + aggregation 2-3 days)

**GitHub Advanced Security API Endpoints:**
- `GET /orgs/{org}/code-scanning/alerts` — Org-wide code scanning alerts (state, severity, tool_name filters)
- `GET /orgs/{org}/secret-scanning/alerts` — Org-wide secret scanning alerts (state, secret_type, resolution, validity filters)
- `GET /orgs/{org}/settings/billing/advanced-security` — GHAS billing: total_advanced_security_committers, per-repo breakdown
- `GET /repos/{owner}/{repo}/dependabot/alerts` — Repo-level Dependabot alerts (severity, ecosystem, state filters)
- Auth: PAT with `security_events` scope (code/secret scanning) + `repo` scope (Dependabot) + `admin:org` (billing)
- Note: Secret scanning validity checks require GHES 3.6+ or GHEC; Dependabot is repo-level only (needs aggregation)

---

### 14. Settings

| Element | Native? | Solution | API |
|---------|---------|----------|-----|
| Profile Card | Yes | Built-in User Settings | Native |
| Integrations Card | Partial | Token management is native; integration status cards need mountPoint | Native |
| Appearance Card | Yes | Theme toggle is built-in | Native |
| Starred Entities Card | Yes | Built-in starred entities | Native |

**Verdict:** 100% native.
**Effort:** 0

---

## Total Effort Summary

| Category | Days |
|----------|------|
| Custom Home Page Plugin | 3-5 |
| Custom My Group Plugin | 2-3 |
| Custom Copilot Metrics Plugin (frontend + backend) | 4-6 |
| Custom GHAS Metrics Plugin (frontend + backend) | 5-7 |
| Branding + Theme | 1-2 |
| Catalog Stat Cards mountPoint | 0.5 |
| API Cards Layout | 0.5 |
| Learning Paths (TechDocs route) | 1-2 |
| Enable Dynamic Plugins (Lightspeed, Notifications, RBAC) | 1-2 |
| **Total** | **18-28 days** |

Plus template creation by `@template-engineer`: 3-5 days (parallel)
Plus CI/CD pipeline by `@devops`: 1-2 days (parallel)
Plus testing by `@test`: 2-3 days (sequential, after plugin development)
