---
name: copilot-metrics
description: Collect and analyze GitHub Copilot usage metrics — adoption, acceptance rate, language breakdown, and productivity impact
---

## When to Use
- Measure GitHub Copilot adoption across the organization
- Track acceptance rate trends (suggestions accepted vs shown)
- Analyze usage by language, editor, and team
- Calculate estimated productivity gains (time saved)
- Generate executive reports on AI developer tool ROI

## Prerequisites
- GitHub CLI (`gh`) authenticated
- `GITHUB_TOKEN` with `manage_billing:copilot`, `read:org`, `read:enterprise` scopes
- Organization must have GitHub Copilot Business or Enterprise
- Caller must be org owner or have Copilot admin permissions

## Commands

### Organization-Level Copilot Metrics
```bash
# Get Copilot metrics for the organization (last 28 days)
gh api /orgs/{org}/copilot/metrics \
  | jq '[.[] | {
    date: .date,
    total_active_users: .total_active_users,
    total_engaged_users: .total_engaged_users,
    copilot_ide_code_completions: .copilot_ide_code_completions,
    copilot_ide_chat: .copilot_ide_chat,
    copilot_dotcom_chat: .copilot_dotcom_chat,
    copilot_dotcom_pull_requests: .copilot_dotcom_pull_requests
  }]'

# Detailed code completions metrics
gh api /orgs/{org}/copilot/metrics \
  | jq '[.[] | {
    date: .date,
    suggestions_shown: .copilot_ide_code_completions.total_code_suggestions,
    suggestions_accepted: .copilot_ide_code_completions.total_code_acceptances,
    lines_suggested: .copilot_ide_code_completions.total_code_lines_suggested,
    lines_accepted: .copilot_ide_code_completions.total_code_lines_accepted,
    acceptance_rate: (if .copilot_ide_code_completions.total_code_suggestions > 0 then ((.copilot_ide_code_completions.total_code_acceptances / .copilot_ide_code_completions.total_code_suggestions) * 100 | round) else 0 end)
  }]'
```

### Language Breakdown
```bash
# Copilot usage by programming language
gh api /orgs/{org}/copilot/metrics \
  | jq '[.[] | .copilot_ide_code_completions.languages // [] | .[] | {
    language: .name,
    suggestions: .total_code_suggestions,
    acceptances: .total_code_acceptances,
    acceptance_rate: (if .total_code_suggestions > 0 then ((.total_code_acceptances / .total_code_suggestions) * 100 | round) else 0 end)
  }] | group_by(.language) | map({
    language: .[0].language,
    total_suggestions: [.[].suggestions] | add,
    total_acceptances: [.[].acceptances] | add,
    avg_acceptance_rate: ([.[].acceptance_rate] | add / length | round)
  }) | sort_by(-.total_suggestions)'
```

### Editor Breakdown
```bash
# Copilot usage by IDE/editor
gh api /orgs/{org}/copilot/metrics \
  | jq '[.[] | .copilot_ide_code_completions.editors // [] | .[] | {
    editor: .name,
    suggestions: .total_code_suggestions,
    acceptances: .total_code_acceptances,
    active_users: .total_engaged_users
  }] | group_by(.editor) | map({
    editor: .[0].editor,
    total_suggestions: [.[].suggestions] | add,
    total_acceptances: [.[].acceptances] | add,
    avg_active_users: ([.[].active_users] | add / length | round)
  }) | sort_by(-.total_suggestions)'
```

### Team-Level Metrics
```bash
# List teams with Copilot access
gh api /orgs/{org}/copilot/billing/seats --paginate \
  | jq '[.seats[] | {login: .assignee.login, team: .assigning_team.name, last_activity: .last_activity_at, editor: .last_activity_editor}]'

# Get Copilot metrics for a specific team
gh api /orgs/{org}/team/{team_slug}/copilot/metrics \
  | jq '[.[] | {
    date: .date,
    active_users: .total_active_users,
    suggestions: .copilot_ide_code_completions.total_code_suggestions,
    acceptances: .copilot_ide_code_completions.total_code_acceptances
  }]'
```

### Copilot Chat Metrics
```bash
# IDE Chat usage
gh api /orgs/{org}/copilot/metrics \
  | jq '[.[] | {
    date: .date,
    chat_active_users: .copilot_ide_chat.total_engaged_users,
    chat_turns: .copilot_ide_chat.total_chats,
    chat_insertions: .copilot_ide_chat.total_chat_insertion_events,
    chat_copy_events: .copilot_ide_chat.total_chat_copy_events
  }]'

# PR Summary usage (Copilot for PRs)
gh api /orgs/{org}/copilot/metrics \
  | jq '[.[] | {
    date: .date,
    pr_summaries_created: .copilot_dotcom_pull_requests.total_pr_summaries_created,
    pr_users: .copilot_dotcom_pull_requests.total_engaged_users
  }]'
```

### Billing & Seat Management
```bash
# Copilot billing seats summary
gh api /orgs/{org}/copilot/billing \
  | jq '{
    seat_breakdown: .seat_breakdown,
    seat_management_setting: .seat_management_setting,
    plan_type: .plan_type
  }'

# Active vs inactive seats
gh api /orgs/{org}/copilot/billing/seats --paginate \
  | jq '{
    total: (.seats | length),
    active_last_7d: [.seats[] | select(.last_activity_at > (now - 604800 | todate))] | length,
    inactive_30d: [.seats[] | select(.last_activity_at < (now - 2592000 | todate) or .last_activity_at == null)] | length
  }'
```

### Trend Calculations
```bash
# Week-over-week acceptance rate trend
gh api /orgs/{org}/copilot/metrics \
  | jq '
    def weekly_avg: group_by(.date[:10] | strptime("%Y-%m-%d") | mktime / 604800 | floor)
      | map({
          week: .[0].date[:10],
          avg_acceptance: ([.[] | if .copilot_ide_code_completions.total_code_suggestions > 0 then ((.copilot_ide_code_completions.total_code_acceptances / .copilot_ide_code_completions.total_code_suggestions) * 100) else 0 end] | add / length | round),
          total_users: ([.[] | .total_active_users] | max)
        });
    weekly_avg'
```

## KPI Definitions

| KPI | Formula | Target |
|-----|---------|--------|
| **Acceptance Rate** | `acceptances / suggestions × 100` | > 30% |
| **Active User Rate** | `active_users / total_seats × 100` | > 80% |
| **Lines Saved/Day** | `lines_accepted / active_users / working_days` | > 50 |
| **Chat Adoption** | `chat_users / total_seats × 100` | > 40% |
| **PR Summary Adoption** | `pr_summary_users / pr_authors × 100` | > 25% |
| **ROI (Hours Saved)** | `lines_accepted × 0.001 hours` | Positive trend |

## Output Format
1. Raw API response (JSON)
2. Calculated KPIs with targets
3. Trend data (daily/weekly)
4. Language and editor breakdown
5. Executive summary with recommendations

## Best Practices
1. Collect metrics daily via scheduled workflow
2. Store snapshots for trend analysis (PostgreSQL)
3. Always show team aggregates, never individual developer stats
4. Compare against industry benchmarks (30% acceptance rate is good)
5. Correlate Copilot adoption with PR cycle time improvements
6. Track chat vs completions adoption separately
7. Monitor seat utilization to optimize license costs

## Integration with Agents
Used by: @engineering-intelligence, @devops
