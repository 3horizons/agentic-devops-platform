---
name: github-metrics
description: Collect engineering metrics from GitHub REST and GraphQL APIs — PRs, deployments, releases, contributors, and workflow runs
---

## When to Use
- Collect PR cycle time, review latency, and throughput metrics
- Gather deployment frequency and release cadence
- Measure CI/CD pipeline health (success rate, duration)
- Analyze contributor activity and code velocity
- Feed data into DORA metrics calculations

## Prerequisites
- GitHub CLI (`gh`) authenticated with org admin or read scope
- `GITHUB_TOKEN` with `repo`, `read:org`, `read:packages` scopes
- `jq` for JSON processing
- `curl` for direct API calls (fallback)

## Commands

### Authentication Check
```bash
# Verify token scopes
gh auth status
gh api /rate_limit | jq '.resources.core'
```

### Pull Request Metrics
```bash
# List merged PRs in last 30 days with timestamps
gh api graphql -f query='
query($owner: String!, $repo: String!) {
  repository(owner: $owner, name: $repo) {
    pullRequests(first: 100, states: MERGED, orderBy: {field: UPDATED_AT, direction: DESC}) {
      nodes {
        number title createdAt mergedAt
        additions deletions changedFiles
        reviews(first: 10) { nodes { submittedAt state author { login } } }
        commits(first: 1) { nodes { commit { authoredDate } } }
        author { login }
      }
      pageInfo { hasNextPage endCursor }
    }
  }
}' -f owner=OWNER -f repo=REPO | jq '.data.repository.pullRequests.nodes'

# PR cycle time calculation (created → merged)
gh pr list --state merged --limit 100 --json number,createdAt,mergedAt \
  | jq '[.[] | {number, cycle_hours: (((.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 3600)}]'

# Review turnaround time
gh pr list --state merged --limit 50 --json number,createdAt,reviews \
  | jq '[.[] | {number, first_review_hours: (if .reviews | length > 0 then (((.reviews[0].submittedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 3600) else null end)}]'
```

### Deployment Metrics
```bash
# List deployments per environment
gh api /repos/{owner}/{repo}/deployments --paginate \
  | jq '[.[] | {id, environment: .environment, created_at: .created_at, creator: .creator.login}]'

# Deployment frequency (last 90 days)
gh api /repos/{owner}/{repo}/deployments --paginate \
  | jq --arg since "$(date -d '-90 days' -Iseconds)" \
    '[.[] | select(.created_at > $since)] | group_by(.created_at[:10]) | map({date: .[0].created_at[:10], count: length})'

# Deployment statuses (success/failure rate)
gh api /repos/{owner}/{repo}/deployments --paginate \
  | jq '.[0:20] | .[].id' \
  | xargs -I {} gh api /repos/{owner}/{repo}/deployments/{}/statuses \
  | jq '[.[] | .state] | group_by(.) | map({state: .[0], count: length})'
```

### Release Metrics
```bash
# Release cadence
gh release list --limit 50 --json tagName,createdAt,isPrerelease \
  | jq '[.[] | select(.isPrerelease == false)]'

# Time between releases
gh release list --limit 20 --json tagName,createdAt \
  | jq '[range(1; length) as $i | {from: .[$i].tagName, to: .[$i-1].tagName, days: (((.[$i-1].createdAt | fromdateiso8601) - (.[$i].createdAt | fromdateiso8601)) / 86400)}]'
```

### CI/CD Workflow Metrics
```bash
# Workflow run success rate (last 30 days)
gh run list --limit 200 --json status,conclusion,createdAt,name,headBranch \
  | jq 'group_by(.name) | map({workflow: .[0].name, total: length, success: [.[] | select(.conclusion == "success")] | length, failure: [.[] | select(.conclusion == "failure")] | length}) | map(. + {success_rate: ((.success / .total) * 100 | round)})'

# Average workflow duration
gh run list --limit 100 --json databaseId,createdAt,updatedAt,name,conclusion \
  | jq '[.[] | select(.conclusion == "success") | {name, duration_min: ((((.updatedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 60) | round)}] | group_by(.name) | map({workflow: .[0].name, avg_duration_min: ([.[].duration_min] | add / length | round)})'
```

### Contributor Activity
```bash
# Contributor stats (additions, deletions, commits per author)
gh api /repos/{owner}/{repo}/stats/contributors \
  | jq '[.[] | {author: .author.login, total_commits: .total, weeks: (.weeks | length)}] | sort_by(-.total_commits)'

# Commit activity (last 52 weeks)
gh api /repos/{owner}/{repo}/stats/commit_activity \
  | jq '[.[-12:] | .[] | {week: (.week | todate), total: .total, days: .days}]'
```

### Organization-Wide Metrics
```bash
# List all repos in org with activity
gh api /orgs/{org}/repos --paginate -q '.[].full_name' | head -50

# Aggregate PRs across repos (last 7 days)
for repo in $(gh api /orgs/{org}/repos --paginate -q '.[].full_name' | head -20); do
  echo "=== $repo ==="
  gh pr list --repo "$repo" --state merged --json number,mergedAt --limit 50 \
    | jq --arg repo "$repo" '{repo: $repo, merged_count: length}'
done | jq -s '.'
```

## Rate Limiting
```bash
# Check rate limit status
gh api /rate_limit | jq '{
  core: {remaining: .resources.core.remaining, reset: (.resources.core.reset | todate)},
  graphql: {remaining: .resources.graphql.remaining, reset: (.resources.graphql.reset | todate)},
  search: {remaining: .resources.search.remaining, reset: (.resources.search.reset | todate)}
}'

# Best practice: Use conditional requests with ETags
# Best practice: Use GraphQL to batch multiple queries
# Best practice: Implement exponential backoff on 403/429
```

## Output Format
1. Raw JSON data from APIs
2. Calculated metrics (cycle time, throughput, rates)
3. Trend data (week-over-week, month-over-month)
4. Summary with actionable insights

## Best Practices
1. Always paginate — use `--paginate` flag or cursor-based pagination
2. Cache responses in Redis (TTL 15min) to avoid rate limits
3. Use GraphQL for complex queries (reduces API calls)
4. Collect data at org level, then drill down to repo/team
5. Store snapshots in PostgreSQL for historical trends
6. Never expose individual developer metrics publicly — aggregate to team level
7. Schedule collection via cron (every 6 hours for dashboards)

## Integration with Agents
Used by: @engineering-intelligence, @sre, @devops
