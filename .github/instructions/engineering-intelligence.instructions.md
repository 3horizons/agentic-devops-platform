---
applyTo: "**/engineering-intelligence/**,**/dashboards/**,**/metrics/**"
---

# Engineering Intelligence Code Standards

## Data Collection Patterns

### API Calls
- Always use authenticated requests (`GITHUB_TOKEN` from Key Vault)
- Implement pagination for all list endpoints (`--paginate` or cursor-based)
- Respect rate limits: check `X-RateLimit-Remaining` header
- Use conditional requests with `If-None-Match` (ETags) to reduce API calls
- Prefer GraphQL over REST when querying related objects (PRs + reviews + commits)
- Set reasonable timeouts (30s for API calls, 5min for batch operations)

### Data Privacy
- **NEVER** expose individual developer metrics — always aggregate to team level
- **NEVER** store GitHub tokens in code, env vars, or config files — use Azure Key Vault
- **NEVER** include source code content in metrics — only metadata (counts, timestamps, labels)
- Anonymize contributor data when exporting outside the organization
- Comply with LGPD (Brazil) for any PII in metric payloads

### Data Storage
- Store metric snapshots in PostgreSQL with timestamp partitioning
- Use Redis for cache (TTL: 15min for real-time dashboards, 1h for trends)
- Retain raw data for 90 days, aggregated data for 2 years
- Use structured JSON columns for flexible metric schemas

## Dashboard Development

### RHDH Plugin Standards
- Plugins MUST follow Backstage Plugin API conventions
- Use `createPlugin()` and `createRoutableExtension()` for registration
- Backend plugins proxy GitHub API calls (never call from browser)
- Frontend uses React 18+ with TypeScript strict mode
- Style with Material UI 5 (consistent with RHDH theme)

### Chart Standards
- Use Recharts or Nivo for React charting (consistent with Backstage ecosystem)
- Always include: title, axis labels, legend, tooltip, loading state, error state
- Color palette: Microsoft logo colors (Blue #00A4EF, Green #7FBA00, Yellow #FFB900, Red #F25022)
- Gauge charts for DORA classification (Elite=green, High=blue, Medium=yellow, Low=red)
- Line charts for trends, bar charts for comparisons, heatmaps for team×metric matrices

### Metric Naming Conventions
```
ei_<domain>_<metric>_<unit>
```
Examples:
- `ei_dora_deploy_frequency_per_week`
- `ei_copilot_acceptance_rate_percent`
- `ei_security_mttr_critical_days`
- `ei_productivity_pr_cycle_time_hours`

### API Endpoint Naming
```
/api/engineering-intelligence/v1/<domain>/<metric>
```
Examples:
- `/api/engineering-intelligence/v1/dora/summary`
- `/api/engineering-intelligence/v1/copilot/adoption`
- `/api/engineering-intelligence/v1/security/posture`
- `/api/engineering-intelligence/v1/productivity/throughput`

## Testing Requirements

### Unit Tests
- Minimum 80% code coverage for metric calculation logic
- Mock all GitHub API responses (never call real APIs in tests)
- Test edge cases: empty data, single data point, rate limit errors

### Integration Tests
- Validate RHDH plugin loads correctly with mock data
- Test chart rendering with various data shapes
- Verify API proxy authentication flow

### Data Validation
- Validate metric ranges (e.g., acceptance rate between 0-100%)
- Check for data freshness (alert if data > 24h old)
- Verify pagination completeness (no missing pages)

## Security Requirements
- All API calls via backend proxy (never expose GitHub token to browser)
- Use Workload Identity for Azure Key Vault access
- Encrypt data at rest (PostgreSQL TDE)
- TLS 1.2+ for all API communication
- RBAC on dashboard access (match RHDH roles: Admin, Developer, Viewer)
