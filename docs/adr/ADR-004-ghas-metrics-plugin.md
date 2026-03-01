# ADR-004: Custom GHAS Metrics Plugin Architecture

## Status: Accepted

## Metadata

| Campo | Valor |
|-------|-------|
| **Data** | 2026-03-01 |
| **Decision-makers** | @rhdh-architect, @architect |
| **Consulted** | @platform, @devops, @security |
| **Informed** | @engineering-intelligence, @sre, @docs |

## Context

The Three Horizons Portal reference template includes a "GHAS Metrics" page that displays organization-wide GitHub Advanced Security analytics: code scanning alerts by severity, secret scanning alerts with remediation status, Dependabot vulnerability summaries, GHAS billing/committers, security trends over time, severity breakdown, MTTR (Mean Time To Remediate), push protection bypass stats, and repository coverage. RHDH 1.8 does not include any plugin for GHAS metrics visualization. No community Backstage plugin exists for this purpose either.

The data source is a combination of **GitHub REST APIs** for code scanning, secret scanning, Dependabot, and GHAS billing. These endpoints require authentication with PATs scoped for `security_events` (code/secret scanning), `repo` (Dependabot), and `admin:org` (billing). A **backend proxy** is required for secure token management. Additionally, Dependabot alerts are only available at the **repo level**, so the backend must aggregate data across all organization repositories.

**Decision Framework result:** No existing dynamic plugin provides this view. A custom full-stack dynamic plugin is needed (frontend + backend proxy + backend aggregation logic).

## Decision

Build a **custom full-stack RHDH dynamic plugin** (`@internal/plugin-ghas-metrics`) that provides a security dashboard at `/ghas-metrics`. The plugin consists of:

1. **Frontend plugin** — React page with 9 components consuming aggregated data from the backend proxy
2. **Backend proxy config** — Backstage proxy configuration in `app-config.yaml` forwarding to `https://api.github.com` with the GitHub PAT injected from Azure Key Vault
3. **Backend aggregation** — A backend plugin module that aggregates repo-level Dependabot alerts and computes MTTR metrics, exposed via a dedicated Backstage backend endpoint

### Architecture

```
GhasMetricsPage (dynamicRoutes: path=/ghas-metrics)
|
+-- SecurityHeader
|   +-- PageTitle                     [Static: "GitHub Advanced Security Metrics"]
|   +-- DateRangePicker               [State: last 7/14/28/90 days]
|   +-- RefreshButton                 [Triggers re-fetch]
|   +-- SeverityFilter                [critical/high/medium/low toggle]
|
+-- SummaryRow (Grid: 4 columns)
|   +-- CodeScanningCard              [Proxy → /code-scanning/alerts]
|   |   +-- OpenAlerts (big number)
|   |   +-- SeverityBadge (critical, high, medium, low)
|   |   +-- FixedThisPeriod count
|   |
|   +-- SecretScanningCard            [Proxy → /secret-scanning/alerts]
|   |   +-- OpenSecrets (big number)
|   |   +-- ResolvedCount
|   |   +-- ValidityStatus (valid, invalid, unknown)
|   |
|   +-- DependabotAlertsCard          [Backend → aggregated]
|   |   +-- OpenVulnerabilities (big number)
|   |   +-- EcosystemBreakdown (npm, pip, maven, etc.)
|   |   +-- CriticalCount highlight
|   |
|   +-- GhasCommittersCard            [Proxy → /billing/advanced-security]
|       +-- ActiveCommitters (big number)
|       +-- MaxCommitters (purchased)
|       +-- UtilizationGauge
|
+-- ChartsRow (Grid: 2 columns)
|   +-- SecurityTrendChart            [Proxy → alerts with dates]
|   |   +-- AreaChart (recharts)      [Opened vs Closed over time]
|   |   +-- Net Open trend line
|   |
|   +-- SeverityBreakdown             [Proxy → code-scanning/alerts]
|       +-- DonutChart (recharts)     [critical/high/medium/low distribution]
|       +-- LegendTable with counts
|
+-- DetailsRow (Grid: 2 columns)
|   +-- MttrMetrics                   [Backend → computed]
|   |   +-- StatCard — Code Scanning MTTR (hours/days)
|   |   +-- StatCard — Secret Scanning MTTR
|   |   +-- StatCard — Dependabot MTTR
|   |   +-- TrendIndicator (improving/degrading)
|   |
|   +-- PushProtectionCard            [Proxy → secret-scanning push protection]
|       +-- BypassCount (big number)
|       +-- BypassReasons table
|       +-- BlockedCount (push protection success)
|
+-- RepoCoverageTable (full width)
    +-- DataTable
    |   +-- Column: Repository Name
    |   +-- Column: Code Scanning (enabled ✓ / disabled ✗)
    |   +-- Column: Secret Scanning (enabled ✓ / disabled ✗)
    |   +-- Column: Dependabot (enabled ✓ / disabled ✗)
    |   +-- Column: Push Protection (enabled ✓ / disabled ✗)
    |   +-- Column: Open Alerts Count
    +-- CoverageSummary bar (% of repos with full GHAS)
```

### Backend Proxy Configuration

```yaml
# In app-config.yaml
proxy:
  endpoints:
    /github-security:
      target: https://api.github.com
      headers:
        Authorization: Bearer ${GITHUB_SECURITY_TOKEN}
        Accept: application/vnd.github+json
        X-GitHub-Api-Version: "2022-11-28"
      changeOrigin: true
      pathRewrite:
        "^/api/proxy/github-security": ""
      allowedHeaders:
        - Accept
        - Content-Type
```

> **Segurança:** O token `GITHUB_SECURITY_TOKEN` é injetado via External Secrets Operator a partir do Azure Key Vault. Requer scopes: `security_events`, `repo`, `admin:org`. Nunca hardcoded no YAML.

### Backend Plugin Module (Aggregation)

Dependabot alerts are repo-level only; MTTR requer computação sobre alertas fechados. Um backend plugin module expõe um endpoint REST dedicado:

```
GET /api/ghas-metrics/org/{org}/summary
  → Agrega code scanning + secret scanning + Dependabot por repo
  → Computa MTTR (created_at → fixed_at em alertas fechados)
  → Constrói repo coverage matrix
  → Cache: 10 minutos TTL (em memória)

GET /api/ghas-metrics/org/{org}/dependabot
  → Lista todos os repos, agrega Dependabot alerts por severidade e ecossistema

GET /api/ghas-metrics/org/{org}/mttr
  → Computa Mean Time To Remediate por tipo de alerta
```

```
plugins/ghas-metrics-backend/
+-- package.json
+-- src/
|   +-- plugin.ts                 # createBackendPlugin
|   +-- router.ts                 # Express router (/api/ghas-metrics/*)
|   +-- service/
|   |   +-- GhasAggregator.ts     # Aggregation logic
|   |   +-- MttrCalculator.ts     # MTTR computation
|   |   +-- RepoScanner.ts       # Repo-level data fetcher
|   +-- types.ts                  # TypeScript interfaces
```

### Wiring

```yaml
dynamicPlugins:
  frontend:
    "@internal/plugin-ghas-metrics":
      dynamicRoutes:
        - path: /ghas-metrics
          importName: GhasMetricsPage
          menuItem:
            icon: SecurityIcon
            text: GHAS Metrics
```

### Frontend Plugin Structure

```
plugins/ghas-metrics/
+-- package.json
+-- tsconfig.json
+-- src/
|   +-- plugin.ts                     # createPlugin + createRoutableExtension
|   +-- index.ts                      # barrel export
|   +-- routes.ts                     # routeRef definitions
|   +-- theme.ts                      # MS_COLORS + severity colors
|   +-- components/
|   |   +-- GhasMetricsPage.tsx       # Page container with ErrorBoundary
|   |   +-- SecurityHeader.tsx        # Title + date range + severity filter
|   |   +-- CodeScanningCard.tsx      # Open alerts by severity
|   |   +-- SecretScanningCard.tsx    # Secret alerts + remediation status
|   |   +-- DependabotAlertsCard.tsx  # Vulnerabilities by ecosystem
|   |   +-- GhasCommittersCard.tsx    # Active committers gauge
|   |   +-- SecurityTrendChart.tsx    # Opened vs. closed area chart
|   |   +-- SeverityBreakdown.tsx     # Donut chart: severity distribution
|   |   +-- MttrMetrics.tsx           # Mean Time To Remediate stats
|   |   +-- PushProtectionCard.tsx    # Push protection bypass stats
|   |   +-- RepoCoverageTable.tsx     # GHAS enablement per repo
|   +-- hooks/
|   |   +-- useCodeScanningAlerts.ts  # Proxy → /code-scanning/alerts
|   |   +-- useSecretScanningAlerts.ts # Proxy → /secret-scanning/alerts
|   |   +-- useDependabotSummary.ts   # Backend → /api/ghas-metrics/dependabot
|   |   +-- useGhasBilling.ts         # Proxy → /billing/advanced-security
|   |   +-- useGhasSummary.ts         # Backend → /api/ghas-metrics/summary
|   |   +-- useMttrMetrics.ts         # Backend → /api/ghas-metrics/mttr
|   |   +-- useDateRange.ts           # React state for date filter
|   +-- api/
|       +-- types.ts                  # TypeScript interfaces
|       +-- ghasApiClient.ts          # fetchApiRef wrapper for proxy + backend calls
+-- dev/
|   +-- index.tsx                     # Dev harness
+-- dist-dynamic/                     # Generated (do not edit)
```

### Data Flow

```
Browser --> GhasMetricsPage
                |
                +--> useCodeScanningAlerts(dateRange) ---> fetchApiRef
                |       |-> GET /api/proxy/github-security/orgs/{org}/code-scanning/alerts
                |       |       ?state=open&per_page=100
                |       |   + GET with ?state=fixed&sort=updated&since=YYYY-MM-DD
                |       |-> Response: alerts[] { rule.severity, state, created_at, fixed_at, tool.name }
                |       |
                |       +--> CodeScanningCard (open count by severity)
                |       +--> SeverityBreakdown (distribution chart)
                |       +--> SecurityTrendChart (opened/closed timeline)
                |
                +--> useSecretScanningAlerts(dateRange) -> fetchApiRef
                |       |-> GET /api/proxy/github-security/orgs/{org}/secret-scanning/alerts
                |       |       ?state=open&per_page=100
                |       |-> Response: alerts[] { secret_type, state, validity, created_at, resolved_at }
                |       |
                |       +--> SecretScanningCard (open, resolved, validity status)
                |       +--> SecurityTrendChart (merge with code scanning timeline)
                |
                +--> useDependabotSummary() ----------> fetchApiRef
                |       |-> GET /api/ghas-metrics/org/{org}/dependabot
                |       |-> Response (aggregated): { total, by_severity, by_ecosystem, repos[] }
                |       |
                |       +--> DependabotAlertsCard (total, ecosystem breakdown)
                |
                +--> useGhasBilling() -----------------> fetchApiRef
                |       |-> GET /api/proxy/github-security/orgs/{org}/settings/billing/advanced-security
                |       |-> Response: { total_advanced_security_committers, maximum_advanced_security_committers,
                |       |               repositories[] { name, advanced_security_committers, advanced_security_committers_breakdown } }
                |       |
                |       +--> GhasCommittersCard (active, max, utilization %)
                |       +--> RepoCoverageTable (repos with GHAS features enabled)
                |
                +--> useMttrMetrics(dateRange) ---------> fetchApiRef
                        |-> GET /api/ghas-metrics/org/{org}/mttr?since=YYYY-MM-DD
                        |-> Response: { code_scanning_mttr_hours, secret_scanning_mttr_hours,
                        |               dependabot_mttr_hours, trend: "improving" | "degrading" | "stable" }
                        |
                        +--> MttrMetrics (MTTR per alert type + trend)
                        +--> PushProtectionCard (derived from secret scanning push protection events)
```

### GitHub API Rate Limits & Pagination

- **Code scanning:** 1000 results per query, paginated via `Link` header. Rate: 30 req/min para APIs de security.
- **Secret scanning:** Similar pagination. Inclui filtro `validity`.
- **Dependabot:** Apenas repo-level. Backend deve iterar todos os repos da org.
- **Billing:** Uma única chamada, sem paginação.
- **Mitigação:** Backend aggregation module implementa cache em memória (10 min TTL). Frontend usa `react-query` com stale-while-revalidate. Dependabot scan é o mais custoso (1 call por repo); limitar a repos com GHAS habilitado.

### Severity Color Mapping

```typescript
export const SEVERITY_COLORS = {
  critical: '#D32F2F',  // Red 700
  high: '#F57C00',      // Orange 700
  medium: '#FFB900',    // Microsoft Yellow
  low: '#7FBA00',       // Microsoft Green
  info: '#00A4EF',      // Microsoft Blue
} as const;
```

## Alternatives Considered

### Alternative 1: Use GitHub's native Security Overview

Direct users to `github.com/orgs/{org}/security/overview`.

**Rejected because:**
- Takes users out of the portal experience
- No Three Horizons branding or customization
- Cannot correlate with catalog data (which components have alerts)
- No MTTR computation or custom date ranges
- No push protection aggregation

### Alternative 2: Build a Grafana dashboard with GitHub data pipeline

Ingest GitHub security data into Prometheus/InfluxDB and build a Grafana dashboard, embedded in RHDH via the Grafana plugin.

**Rejected because:**
- Requires an additional data pipeline (ETL from GitHub to time-series DB)
- Infrastructure overhead (InfluxDB/Loki instance, cron jobs)
- Grafana embed has limited interactivity
- RBAC disconnected from RHDH roles
- Significant DevOps overhead to maintain the pipeline

### Alternative 3: Use the `@engineering-intelligence` agent scripts as data source

The platform already has `scripts/engineering-intelligence/collect-security-metrics.sh`.

**Rejected because:**
- Scripts produce batch JSON files, not a live dashboard
- No RHDH integration
- Useful as a **complementary** source for historical reporting, not real-time dashboard

### Alternative 4: Use only the Backstage proxy without backend aggregation

Frontend directly calls all GitHub APIs through the proxy, including per-repo Dependabot calls.

**Rejected because:**
- Dependabot iteration over all repos would cause hundreds of API calls from the browser
- Rate limit exhaustion risk
- Latency unacceptable (tens of seconds for large orgs)
- MTTR computation requires server-side aggregation
- Backend aggregation + caching is the responsible choice

## Consequences

### Positive
- Unified security posture view in the developer portal
- MTTR metrics not available in GitHub's native UI — high value for security teams
- Repo coverage table helps identify gaps in GHAS enablement
- Push protection bypass tracking adds accountability
- Backend aggregation eliminates browser-side API rate limit issues
- Follows RHDH dynamic plugin architecture (no fork)
- RBAC-controlled — only Admin and Security Team roles see organizational security data

### Negative
- Most complex plugin in the Three Horizons portal (frontend + backend + aggregation)
- Requires a GitHub PAT with broad scopes (`security_events`, `repo`, `admin:org`)
- Backend module adds maintenance burden (API changes, pagination handling)
- Dependabot aggregation is O(n) in number of repos — can be slow for large orgs (mitigated by caching)
- Chart library dependency (recharts ~400KB) shared with Copilot Metrics plugin
- Must handle GitHub API pagination robustly (Link headers, 100 items per page)
- 5-7 days development effort (highest of all custom plugins)

## Implementation Notes

**For @platform:**
1. Use `scaffold-plugin.sh ghas-metrics ./plugins` to generate frontend boilerplate
2. Create backend plugin: `scaffold-plugin.sh ghas-metrics-backend ./plugins --backend`
3. Install `recharts` for charts: `npm install recharts`
4. Use `fetchApiRef` for all API calls — never use raw `fetch()`
5. Implement `ghasApiClient.ts` wrapper per `rhdh-plugin-architecture.instructions.md`
6. Backend router: use `express.Router()` with auth middleware from `@backstage/backend-common`
7. Implement pagination helper for GitHub API (follow `Link: <url>; rel="next"` headers)
8. Wrap page in `<ErrorBoundary>` from `@backstage/core-components`
9. Use `<Progress>` and `<ResponseErrorPanel>` for loading/error states
10. Use `makeStyles` with `MS_COLORS` and `SEVERITY_COLORS` for branding
11. Export both plugins via `npx @janus-idp/cli package export-dynamic-plugin`
12. Push to ACR: `oras push myacr.azurecr.io/plugins/ghas-metrics:1.0.0` (frontend + backend)

**For @security:**
- Review proxy config: token should come from Key Vault, not hardcoded
- Validate RBAC: only Admin and Security roles access `/ghas-metrics`
- Ensure Dependabot data does not expose private repo names to unauthorized users
- Review push protection bypass data — potential PII in bypass reasons
- Validate token scopes are minimal (only what's needed)

**For @devops:**
- Add to `.github/workflows/build-plugins.yaml`
- Trigger on changes to `plugins/ghas-metrics/**` and `plugins/ghas-metrics-backend/**`
- Include `recharts` in bundle via `@janus-idp/cli` export
- Backend plugin needs separate OCI artifact

**For @test:**
- Mock `fetchApiRef` with sample GitHub API responses for all endpoints
- Test backend aggregation with mock data (10, 50, 200 repos)
- Test pagination handling (multi-page responses)
- Test MTTR computation with edge cases (zero alerts, all open, all fixed)
- Test severity filter state management
- Test error handling (API rate limit 403, network failure, empty org)
- Target >80% code coverage (frontend + backend)

**Effort estimate:** 5-7 days (frontend 3-4 days, backend + aggregation 2-3 days) + 1.5 days (tests) + 0.5 day (pipeline)
