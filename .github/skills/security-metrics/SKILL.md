---
name: security-metrics
description: Collect GitHub Advanced Security metrics — code scanning, secret scanning, Dependabot alerts, and security posture KPIs
---

## When to Use
- Audit security posture across GitHub repositories
- Track code scanning (CodeQL/SAST) alert trends
- Monitor secret scanning alerts and remediation SLAs
- Analyze Dependabot vulnerability data and auto-fix rates
- Generate security posture dashboards for RHDH

## Prerequisites
- GitHub CLI (`gh`) authenticated
- `GITHUB_TOKEN` with `security_events`, `secret_scanning_alerts:read` scopes
- GitHub Advanced Security enabled on target repos
- Organization admin or security manager role

## Commands

### Code Scanning (CodeQL / SAST)
```bash
# List open code scanning alerts by severity
gh api /repos/{owner}/{repo}/code-scanning/alerts?state=open --paginate \
  | jq 'group_by(.rule.security_severity_level) | map({severity: .[0].rule.security_severity_level, count: length}) | sort_by(-.count)'

# Alert trend (open vs fixed over time)
gh api /repos/{owner}/{repo}/code-scanning/alerts?state=fixed --paginate \
  | jq '[.[] | {
    number: .number,
    severity: .rule.security_severity_level,
    created: .created_at[:10],
    fixed: .fixed_at[:10],
    mttr_days: ((((.fixed_at | fromdateiso8601) - (.created_at | fromdateiso8601)) / 86400) | round)
  }]'

# MTTR by severity
gh api /repos/{owner}/{repo}/code-scanning/alerts?state=fixed --paginate \
  | jq '[.[] | {severity: .rule.security_severity_level, mttr_days: ((((.fixed_at | fromdateiso8601) - (.created_at | fromdateiso8601)) / 86400) | round)}] | group_by(.severity) | map({severity: .[0].severity, avg_mttr_days: ([.[].mttr_days] | add / length | round), count: length})'

# Alerts by tool (CodeQL, Trivy, etc)
gh api /repos/{owner}/{repo}/code-scanning/alerts?state=open --paginate \
  | jq 'group_by(.tool.name) | map({tool: .[0].tool.name, count: length})'
```

### Secret Scanning
```bash
# List open secret scanning alerts
gh api /repos/{owner}/{repo}/secret-scanning/alerts?state=open --paginate \
  | jq '[.[] | {number: .number, secret_type: .secret_type_display_name, created: .created_at[:10], push_protection_bypassed: .push_protection_bypassed}]'

# Secret scanning summary (by type)
gh api /repos/{owner}/{repo}/secret-scanning/alerts --paginate \
  | jq 'group_by(.secret_type_display_name) | map({type: .[0].secret_type_display_name, total: length, open: [.[] | select(.state == "open")] | length, resolved: [.[] | select(.state == "resolved")] | length})'

# Push protection bypass rate
gh api /repos/{owner}/{repo}/secret-scanning/alerts --paginate \
  | jq '{total: length, bypassed: [.[] | select(.push_protection_bypassed == true)] | length, bypass_rate: ([.[] | select(.push_protection_bypassed == true)] | length) / (length) * 100 | round}'
```

### Dependabot Alerts
```bash
# Open Dependabot alerts by severity
gh api /repos/{owner}/{repo}/dependabot/alerts?state=open --paginate \
  | jq 'group_by(.security_advisory.severity) | map({severity: .[0].security_advisory.severity, count: length}) | sort_by(-.count)'

# Dependabot alerts by ecosystem
gh api /repos/{owner}/{repo}/dependabot/alerts?state=open --paginate \
  | jq 'group_by(.dependency.package.ecosystem) | map({ecosystem: .[0].dependency.package.ecosystem, count: length})'

# Auto-fix rate (Dependabot PRs)
gh api /repos/{owner}/{repo}/dependabot/alerts?state=fixed --paginate \
  | jq '{total_fixed: length, auto_dismissed: [.[] | select(.auto_dismissed_at != null)] | length}'

# MTTR for Dependabot alerts
gh api /repos/{owner}/{repo}/dependabot/alerts?state=fixed --paginate \
  | jq '[.[] | select(.fixed_at != null) | {severity: .security_advisory.severity, mttr_days: ((((.fixed_at | fromdateiso8601) - (.created_at | fromdateiso8601)) / 86400) | round)}] | group_by(.severity) | map({severity: .[0].severity, avg_mttr: ([.[].mttr_days] | add / length | round)})'
```

### Organization-Wide Security Overview
```bash
# Aggregate security alerts across all repos
for repo in $(gh api /orgs/{org}/repos --paginate -q '.[].full_name' | head -30); do
  echo "=== $repo ==="
  code_scanning=$(gh api /repos/$repo/code-scanning/alerts?state=open 2>/dev/null | jq 'length // 0')
  secret_scanning=$(gh api /repos/$repo/secret-scanning/alerts?state=open 2>/dev/null | jq 'length // 0')
  dependabot=$(gh api /repos/$repo/dependabot/alerts?state=open 2>/dev/null | jq 'length // 0')
  echo "{\"repo\": \"$repo\", \"code_scanning\": $code_scanning, \"secret_scanning\": $secret_scanning, \"dependabot\": $dependabot}"
done | jq -s '.'

# GHAS enablement status
gh api /orgs/{org}/repos --paginate \
  | jq '[.[] | {repo: .full_name, ghas: .security_and_analysis.advanced_security.status, secret_scanning: .security_and_analysis.secret_scanning.status, push_protection: .security_and_analysis.secret_scanning_push_protection.status}]'
```

## KPI Definitions

| KPI | Formula | SLA Target |
|-----|---------|------------|
| **Critical MTTR** | Avg days to fix critical alerts | < 7 days |
| **High MTTR** | Avg days to fix high alerts | < 30 days |
| **Secret Remediation** | Avg days to resolve secrets | < 1 day |
| **GHAS Coverage** | Repos with GHAS / total repos × 100 | 100% |
| **Push Protection Bypass** | Bypassed / total × 100 | < 5% |
| **Dependency Freshness** | Repos with 0 critical deps | > 90% |
| **Auto-Fix Rate** | Auto-fixed / total fixed × 100 | > 50% |

## Output Format
1. Alert counts by severity and type
2. MTTR calculations per severity level
3. Trend data (weekly alert open/close rates)
4. Organization security score (composite KPI)
5. Recommendations for top-risk repos

## Best Practices
1. Prioritize critical and high severity alerts
2. Track MTTR as the primary security metric
3. Monitor push protection bypass rate (should trend down)
4. Use Dependabot auto-merge for low-risk patches
5. Enable CodeQL on all repos with supported languages
6. Schedule weekly security posture snapshots
7. Never expose specific vulnerability details in dashboards — show aggregates

## Integration with Agents
Used by: @engineering-intelligence, @security
