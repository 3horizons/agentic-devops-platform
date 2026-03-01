# ADR-003: Custom Copilot Metrics Plugin Architecture

## Status: Accepted

## Metadata

| Campo | Valor |
|-------|-------|
| **Data** | 2026-03-01 |
| **Decision-makers** | @rhdh-architect, @architect |
| **Consulted** | @platform, @devops, @security |
| **Informed** | @engineering-intelligence, @sre, @docs |

## Context

The Three Horizons Portal reference template includes a "Copilot Metrics" page that displays organization-wide GitHub Copilot usage analytics: active users, suggestion acceptance rates, language breakdown, IDE usage, team comparison, chat usage, trend sparklines, and seat utilization. RHDH 1.8 does not include any plugin for GitHub Copilot metrics visualization. No community Backstage plugin exists for this purpose either.

The data source is the **GitHub Copilot Metrics REST API** (GA since February 2026), which requires authentication with an organization-level PAT or GitHub App with `manage_billing:copilot` or `read:org` scope. Since frontend plugins cannot securely store tokens, a **backend proxy** is required to forward authenticated requests to the GitHub API.

**Decision Framework result:** No existing dynamic plugin provides this view. A custom full-stack dynamic plugin is needed (frontend + backend proxy).

## Decision

Build a **custom full-stack RHDH dynamic plugin** (`@internal/plugin-copilot-metrics`) that provides a Copilot usage dashboard at `/copilot-metrics`. The plugin consists of:

1. **Frontend plugin** — React page with 8 components consuming data from the backend proxy
2. **Backend proxy config** — Backstage proxy configuration in `app-config.yaml` forwarding to `https://api.github.com` with the GitHub PAT injected from Azure Key Vault via External Secrets Operator

### Architecture

```
CopilotMetricsPage (dynamicRoutes: path=/copilot-metrics)
|
+-- MetricsHeader
|   +-- PageTitle                     [Static: "GitHub Copilot Metrics"]
|   +-- DateRangePicker               [State: last 7/14/28 days]
|   +-- RefreshButton                 [Triggers re-fetch]
|
+-- TopRow (Grid: 3 columns)
|   +-- ActiveUsersCard               [Proxy → /copilot/metrics]
|   |   +-- TotalActiveUsers          [Gauge / big-number display]
|   |   +-- EngagedUsersCount         [Percentage of active vs. assigned]
|   |
|   +-- SeatUtilization              [Proxy → /copilot/billing]
|   |   +-- GaugeChart               [Assigned vs. active seats]
|   |   +-- AssignedCount / ActiveCount
|   |
|   +-- AcceptanceRateChart          [Proxy → /copilot/metrics]
|       +-- LineChart (recharts)      [Suggestions accepted % over time]
|       +-- TotalSuggested / TotalAccepted
|
+-- MiddleRow (Grid: 2 columns)
|   +-- LanguageBreakdown            [Proxy → /copilot/metrics → languages]
|   |   +-- DataTable                 [Language, Suggested, Accepted, Rate%]
|   |   +-- HorizontalBarChart       [Top 10 languages by acceptance]
|   |
|   +-- IdeUsageChart                [Proxy → /copilot/metrics → editors]
|       +-- DonutChart (recharts)     [VS Code, JetBrains, Neovim, Other]
|       +-- LegendTable              [Editor, Users, Percentage]
|
+-- BottomRow (Grid: 2 columns)
|   +-- ChatUsageStats               [Proxy → /copilot/metrics]
|   |   +-- StatCard — IDE Chat      [copilot_ide_chat turns + accepts]
|   |   +-- StatCard — Dotcom Chat   [copilot_dotcom_chat turns]
|   |   +-- StatCard — PR Summaries  [copilot_dotcom_pull_requests]
|   |
|   +-- TeamComparison               [Proxy → /team/{slug}/copilot/metrics]
|       +-- DataTable                 [Team, Active, Engaged, Acceptance%]
|       +-- SortableColumns           [By usage, by acceptance rate]
|
+-- TrendSparklines (Grid: 4 columns)
    +-- Sparkline — Active Users      [30-day trend]
    +-- Sparkline — Acceptance Rate   [30-day trend]
    +-- Sparkline — Chat Turns        [30-day trend]
    +-- Sparkline — Lines Suggested   [30-day trend]
```

### Backend Proxy Configuration

```yaml
# In app-config.yaml
proxy:
  endpoints:
    /github-copilot:
      target: https://api.github.com
      headers:
        Authorization: Bearer ${GITHUB_COPILOT_TOKEN}
        Accept: application/vnd.github+json
        X-GitHub-Api-Version: "2022-11-28"
      changeOrigin: true
      pathRewrite:
        "^/api/proxy/github-copilot": ""
      allowedHeaders:
        - Accept
        - Content-Type
```

> **Segurança:** O token `GITHUB_COPILOT_TOKEN` é injetado via External Secrets Operator a partir do Azure Key Vault. Nunca hardcoded no YAML.

### Wiring

```yaml
dynamicPlugins:
  frontend:
    "@internal/plugin-copilot-metrics":
      dynamicRoutes:
        - path: /copilot-metrics
          importName: CopilotMetricsPage
          menuItem:
            icon: AssessmentIcon
            text: Copilot Metrics
```

### Plugin Structure

```
plugins/copilot-metrics/
+-- package.json
+-- tsconfig.json
+-- src/
|   +-- plugin.ts                     # createPlugin + createRoutableExtension
|   +-- index.ts                      # barrel export
|   +-- routes.ts                     # routeRef definitions
|   +-- theme.ts                      # MS_COLORS constants
|   +-- components/
|   |   +-- CopilotMetricsPage.tsx    # Page container with ErrorBoundary
|   |   +-- MetricsHeader.tsx         # Title + date range + refresh
|   |   +-- ActiveUsersCard.tsx       # Total active + engaged users
|   |   +-- SeatUtilization.tsx       # Assigned vs. active seats gauge
|   |   +-- AcceptanceRateChart.tsx   # Line chart: acceptance % over time
|   |   +-- LanguageBreakdown.tsx     # Table + bar chart by language
|   |   +-- IdeUsageChart.tsx         # Donut chart: editor distribution
|   |   +-- ChatUsageStats.tsx        # IDE chat + dotcom chat + PR summaries
|   |   +-- TeamComparison.tsx        # Per-team sortable table
|   |   +-- TrendSparklines.tsx       # 4 sparkline mini-charts
|   +-- hooks/
|   |   +-- useCopilotMetrics.ts      # Proxy → /copilot/metrics
|   |   +-- useCopilotBilling.ts      # Proxy → /copilot/billing
|   |   +-- useTeamMetrics.ts         # Proxy → /team/{slug}/copilot/metrics
|   |   +-- useDateRange.ts           # React state for date filter
|   +-- api/
|       +-- types.ts                  # TypeScript interfaces (CopilotMetricsResponse, etc.)
|       +-- copilotApiClient.ts       # fetchApiRef wrapper for proxy calls
+-- dev/
|   +-- index.tsx                     # Dev harness
+-- dist-dynamic/                     # Generated (do not edit)
```

### Data Flow

```
Browser --> CopilotMetricsPage
                |
                +--> useCopilotMetrics(dateRange) ---> fetchApiRef
                |       |-> GET /api/proxy/github-copilot/orgs/{org}/copilot/metrics
                |       |       ?since=YYYY-MM-DD&until=YYYY-MM-DD
                |       |-> Response: daily metrics array
                |       |   ├── copilot_ide_code_completions { editors[] → languages[] }
                |       |   ├── copilot_ide_chat { editors[] → models[] }
                |       |   ├── copilot_dotcom_chat { models[] }
                |       |   └── copilot_dotcom_pull_requests { repositories[] }
                |       |
                |       +--> ActiveUsersCard    (total_active_users, total_engaged_users)
                |       +--> AcceptanceRateChart (suggestions_count, acceptances_count per day)
                |       +--> LanguageBreakdown  (languages[].name, .total_code_suggestions, .total_code_acceptances)
                |       +--> IdeUsageChart      (editors[].name, total_engaged_users per editor)
                |       +--> ChatUsageStats     (copilot_ide_chat, copilot_dotcom_chat, copilot_dotcom_pull_requests)
                |       +--> TrendSparklines    (aggregate last 28 days per metric)
                |
                +--> useCopilotBilling() ---------> fetchApiRef
                |       |-> GET /api/proxy/github-copilot/orgs/{org}/copilot/billing
                |       |-> Response: { seat_breakdown: { total, active_this_cycle, inactive_this_cycle } }
                |       |
                |       +--> SeatUtilization (assigned = total, active = active_this_cycle)
                |
                +--> useTeamMetrics(teams[]) ------> fetchApiRef (batch)
                        |-> GET /api/proxy/github-copilot/orgs/{org}/team/{slug}/copilot/metrics
                        |   (one call per team, batched via Promise.all)
                        |
                        +--> TeamComparison (team name, active, engaged, acceptance rate per team)
```

### GitHub API Rate Limits

- **Copilot Metrics API:** 30 requests per minute for authenticated users
- **Billing API:** Rate-limited per organization
- **Mitigação:** Implementar cache client-side (5 minutos TTL via `react-query` ou `useAsync` com key). Limite de refresh manual a 1x por minuto.

## Alternatives Considered

### Alternative 1: Use the `@engineering-intelligence` agent's metrics collection scripts

The platform already has `scripts/engineering-intelligence/collect-copilot-metrics.sh` which collects Copilot metrics via CLI.

**Rejected because:**
- Scripts produce JSON files for offline analysis, not a live dashboard
- No RHDH integration — users want an in-portal experience
- Data is batch-collected (every 6h), not interactive
- However, the scripts serve as a **complementary** data source for historical reporting

### Alternative 2: Build an external dashboard (Grafana) and embed via iframe

Create a Grafana dashboard for Copilot metrics and embed it in RHDH via the Grafana dynamic plugin.

**Rejected because:**
- Requires a data pipeline to ingest GitHub API data into Prometheus/InfluxDB
- Added infrastructure complexity (additional services to maintain)
- Grafana embed has limited interactivity (no Backstage API integration)
- RBAC would be disconnected from RHDH roles

### Alternative 3: Use GitHub's built-in Copilot metrics page

Direct users to `github.com/organizations/{org}/settings/copilot/policies`.

**Rejected because:**
- Takes users out of the portal experience
- No customization for Three Horizons branding
- Cannot add team comparison or custom date ranges
- Cannot correlate with other RHDH metrics (catalog entities, DORA, GHAS)

## Consequences

### Positive
- Unified developer portal experience — Copilot metrics alongside catalog, GitOps, and security
- Live data via GitHub REST API (GA, stable, documented)
- Team comparison view not available in GitHub's native UI
- Custom date range filtering for trend analysis
- Follows RHDH dynamic plugin architecture (no RHDH fork)
- RBAC-controlled — only Admin and Team Lead roles see organizational metrics
- Reusable patterns for future metrics plugins

### Negative
- Requires a GitHub PAT or GitHub App with `manage_billing:copilot` scope
- GitHub API rate limits (30 req/min for metrics endpoint) — must implement caching
- Backend proxy adds a hop — increases latency vs. direct API calls
- Custom React code to maintain (~10 components + hooks + charting)
- Chart library dependency (recharts ~400KB) increases bundle size
- Must be regression-tested on RHDH version upgrades
- Team-level metrics require knowledge of team slugs (must be populated in catalog or config)
- Data constraint: metrics only available for days with 5+ active Copilot seats

## Implementation Notes

**For @platform:**
1. Use `scaffold-plugin.sh copilot-metrics ./plugins` to generate boilerplate
2. Install `recharts` for charts: `npm install recharts`
3. Use `fetchApiRef` for all proxy calls — never use raw `fetch()`
4. Implement `copilotApiClient.ts` wrapper per `rhdh-plugin-architecture.instructions.md`
5. Wrap page in `<ErrorBoundary>` from `@backstage/core-components`
6. Use `<Progress>` and `<ResponseErrorPanel>` for loading/error states
7. Use `makeStyles` with `MS_COLORS` for consistent branding
8. Export via `npx @janus-idp/cli package export-dynamic-plugin`
9. Push to ACR: `oras push myacr.azurecr.io/plugins/copilot-metrics:1.0.0`

**For @security:**
- Review proxy config: token should come from Key Vault, not hardcoded
- Validate RBAC: only Admin and Team Lead roles access `/copilot-metrics`
- Ensure no sensitive data (individual user activity) is exposed without consent
- Add rate-limit handling to prevent token exhaustion

**For @devops:**
- Add to `.github/workflows/build-plugins.yaml`
- Trigger on changes to `plugins/copilot-metrics/**`
- Include `recharts` in bundle via `@janus-idp/cli` export

**For @test:**
- Mock `fetchApiRef` to return sample Copilot Metrics API responses
- Test each chart component with varied data (zero, low, high)
- Test date range selector state transitions
- Test error handling (API rate limit, network failure)
- Target >80% code coverage

**Effort estimate:** 4-6 days (frontend 3-4 days, proxy config + API client 1-2 days) + 1 day (tests) + 0.5 day (pipeline)
