---
name: dora-metrics
description: Calculate DORA (DevOps Research and Assessment) four key metrics from GitHub data — deployment frequency, lead time, MTTR, change failure rate
---

## When to Use
- Calculate the four DORA metrics for engineering teams
- Classify team performance (Elite, High, Medium, Low)
- Generate trend reports for leadership
- Benchmark against industry standards (DORA State of DevOps Report)
- Feed data into RHDH engineering intelligence dashboards

## Prerequisites
- GitHub CLI (`gh`) authenticated
- Access to deployment, PR, and issue data
- Historical data (minimum 30 days recommended, 90 days ideal)

## DORA Metric Definitions

### 1. Deployment Frequency (DF)
**Definition**: How often code is deployed to production.

```bash
# Count production deployments in last 90 days
SINCE=$(date -d '-90 days' -Iseconds)

gh api /repos/{owner}/{repo}/deployments --paginate \
  | jq --arg since "$SINCE" '
    [.[] | select(.environment == "production" and .created_at > $since)] |
    {
      total_deployments: length,
      days: 90,
      frequency_per_day: (length / 90 | . * 100 | round / 100),
      frequency_per_week: (length / 13 | . * 100 | round / 100),
      classification: (
        if (length / 90) >= 1 then "Elite"
        elif (length / 7) >= 1 then "High"
        elif (length / 30) >= 1 then "Medium"
        else "Low"
        end
      )
    }'

# Alternative: Use releases as deployment proxy
gh release list --limit 100 --json tagName,createdAt,isPrerelease \
  | jq --arg since "$SINCE" '
    [.[] | select(.isPrerelease == false and .createdAt > $since)] |
    {
      total_releases: length,
      frequency_per_week: (length / 13 | . * 100 | round / 100),
      classification: (
        if (length / 90) >= 1 then "Elite"
        elif (length / 13) >= 1 then "High"
        elif (length / 3) >= 1 then "Medium"
        else "Low"
        end
      )
    }'
```

### 2. Lead Time for Changes (LT)
**Definition**: Time from first commit to production deployment.

```bash
# Calculate lead time from PR merge timestamps
gh api graphql -f query='
query($owner: String!, $repo: String!) {
  repository(owner: $owner, name: $repo) {
    pullRequests(first: 100, states: MERGED, orderBy: {field: UPDATED_AT, direction: DESC}) {
      nodes {
        number
        createdAt
        mergedAt
        commits(first: 1) {
          nodes { commit { authoredDate } }
        }
      }
    }
  }
}' -f owner=OWNER -f repo=REPO \
  | jq '
    [.data.repository.pullRequests.nodes[] |
      {
        pr: .number,
        first_commit: .commits.nodes[0].commit.authoredDate,
        merged_at: .mergedAt,
        lead_time_hours: (((.mergedAt | fromdateiso8601) - (.commits.nodes[0].commit.authoredDate | fromdateiso8601)) / 3600 | round)
      }
    ] |
    {
      total_prs: length,
      median_lead_time_hours: (sort_by(.lead_time_hours) | .[length/2].lead_time_hours),
      p90_lead_time_hours: (sort_by(.lead_time_hours) | .[(length * 0.9 | floor)].lead_time_hours),
      avg_lead_time_hours: ([.[].lead_time_hours] | add / length | round),
      classification: (
        [.[].lead_time_hours] | add / length |
        if . < 1 then "Elite"
        elif . < 168 then "High"
        elif . < 720 then "Medium"
        else "Low"
        end
      )
    }'
```

### 3. Mean Time to Recovery (MTTR)
**Definition**: Time from incident detection to service restoration.

```bash
# MTTR from incident issues (labeled as "incident" or "bug/production")
gh issue list --state closed --label "incident" --limit 100 --json number,createdAt,closedAt,title \
  | jq '
    [.[] |
      {
        issue: .number,
        title: .title,
        created: .createdAt,
        closed: .closedAt,
        recovery_hours: (((.closedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 3600 | round)
      }
    ] |
    {
      total_incidents: length,
      median_mttr_hours: (sort_by(.recovery_hours) | .[length/2].recovery_hours),
      avg_mttr_hours: ([.[].recovery_hours] | add / length | round),
      classification: (
        [.[].recovery_hours] | add / length |
        if . < 1 then "Elite"
        elif . < 24 then "High"
        elif . < 168 then "Medium"
        else "Low"
        end
      )
    }'

# Alternative: MTTR from deployment rollbacks
gh api /repos/{owner}/{repo}/deployments --paginate \
  | jq '[.[] | select(.environment == "production")] |
    [range(1; length) as $i |
      select(.[$i].description | test("rollback|hotfix|revert"; "i")) |
      {
        deployment: .[$i].id,
        recovery_hours: (((.[$i].created_at | fromdateiso8601) - (.[$i-1].created_at | fromdateiso8601)) / 3600 | round)
      }
    ]'
```

### 4. Change Failure Rate (CFR)
**Definition**: Percentage of deployments causing failures requiring rollback or hotfix.

```bash
# Change failure rate from deployments
TOTAL=$(gh api /repos/{owner}/{repo}/deployments --paginate | jq '[.[] | select(.environment == "production")] | length')

FAILURES=$(gh api /repos/{owner}/{repo}/deployments --paginate | jq '[.[] | select(.environment == "production" and (.description | test("rollback|hotfix|revert|failure"; "i")))] | length')

echo "{
  \"total_deployments\": $TOTAL,
  \"failed_deployments\": $FAILURES,
  \"change_failure_rate\": $(echo "scale=1; $FAILURES * 100 / $TOTAL" | bc),
  \"classification\": $(if [ $(echo "$FAILURES * 100 / $TOTAL" | bc) -le 5 ]; then echo '"Elite"'; elif [ $(echo "$FAILURES * 100 / $TOTAL" | bc) -le 10 ]; then echo '"High"'; elif [ $(echo "$FAILURES * 100 / $TOTAL" | bc) -le 15 ]; then echo '"Medium"'; else echo '"Low"'; fi)
}"

# Alternative: hotfix PRs as failure proxy
TOTAL_PRS=$(gh pr list --state merged --limit 500 --json number | jq 'length')
HOTFIX_PRS=$(gh pr list --state merged --limit 500 --json number,labels | jq '[.[] | select(.labels[]?.name | test("hotfix|bugfix|revert"; "i"))] | length')

echo "{\"total_prs\": $TOTAL_PRS, \"hotfix_prs\": $HOTFIX_PRS, \"cfr_percent\": $(echo "scale=1; $HOTFIX_PRS * 100 / $TOTAL_PRS" | bc)}"
```

## Composite DORA Score
```bash
# Generate composite DORA report
cat <<'SCRIPT' > /tmp/dora-report.sh
#!/usr/bin/env bash
set -euo pipefail

ORG="${1:?Usage: dora-report.sh <org> <repo>}"
REPO="${2:?Usage: dora-report.sh <org> <repo>}"

echo "📊 DORA Metrics Report — $ORG/$REPO"
echo "Date: $(date -Iseconds)"
echo "Period: Last 90 days"
echo "================================"

# Classification scoring: Elite=4, High=3, Medium=2, Low=1
score=0

echo ""
echo "1️⃣ Deployment Frequency"
df_class=$(gh api /repos/$ORG/$REPO/deployments --paginate 2>/dev/null | jq -r '[.[] | select(.environment == "production")] | if (length / 90) >= 1 then "Elite" elif (length / 13) >= 1 then "High" elif (length / 3) >= 1 then "Medium" else "Low" end' 2>/dev/null || echo "N/A")
echo "   Classification: $df_class"

echo ""
echo "2️⃣ Lead Time for Changes"
echo "   (requires GraphQL analysis)"

echo ""
echo "3️⃣ Mean Time to Recovery"
echo "   (requires incident label data)"

echo ""
echo "4️⃣ Change Failure Rate"
echo "   (requires deployment status data)"

echo ""
echo "================================"
echo "Overall DORA Performance: Composite analysis pending"
SCRIPT
chmod +x /tmp/dora-report.sh
```

## DORA Classification Table

| Metric | Elite | High | Medium | Low |
|--------|-------|------|--------|-----|
| **Deploy Frequency** | Multiple/day | Weekly–Daily | Monthly–Weekly | Monthly+ |
| **Lead Time** | < 1 hour | < 1 week | 1 week–1 month | > 1 month |
| **MTTR** | < 1 hour | < 1 day | < 1 week | > 1 week |
| **Change Failure Rate** | 0–5% | 5–10% | 10–15% | > 15% |

## Output Format
1. Individual metric values with classification
2. Historical trend (weekly for 12 weeks)
3. Composite DORA score (4=Elite, 3=High, 2=Medium, 1=Low average)
4. Comparison with previous period
5. Recommendations for improvement

## Best Practices
1. Use at least 90 days of data for reliable metrics
2. Clearly define what constitutes a "deployment" in your org
3. Label incident issues consistently for MTTR calculation
4. Distinguish between planned releases and hotfixes for CFR
5. Track DORA metrics per team, not per individual
6. Share results in retrospectives to drive improvement
7. Don't game the metrics — focus on the practices that improve them

## Integration with Agents
Used by: @engineering-intelligence, @sre, @devops
