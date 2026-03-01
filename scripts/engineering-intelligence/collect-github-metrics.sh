#!/usr/bin/env bash
set -euo pipefail

#=============================================================================
# collect-github-metrics.sh
# Collect engineering metrics from GitHub APIs (PRs, Deployments, Workflows)
#
# Usage:
#   ./scripts/engineering-intelligence/collect-github-metrics.sh \
#     --org <github-org> \
#     --repo <repo-name> \
#     --period <30|60|90> \
#     --output <json|summary>
#
# Prerequisites:
#   - gh CLI authenticated (gh auth status)
#   - jq installed
#   - GITHUB_TOKEN with repo, read:org scopes
#=============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Defaults
ORG=""
REPO=""
PERIOD=90
OUTPUT_FORMAT="json"
OUTPUT_DIR="${SCRIPT_DIR}/../../data/engineering-intelligence"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} --org <org> [--repo <repo>] [--period <days>] [--output <json|summary>]

Options:
  --org       GitHub organization name (required)
  --repo      Specific repository (optional, default: all org repos)
  --period    Collection period in days (default: 90)
  --output    Output format: json or summary (default: json)
  --help      Show this help message

Examples:
  ${SCRIPT_NAME} --org 3horizons --repo agentic-devops-platform --period 90
  ${SCRIPT_NAME} --org 3horizons --output summary
EOF
  exit 0
}

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --org)     ORG="$2"; shift 2 ;;
    --repo)    REPO="$2"; shift 2 ;;
    --period)  PERIOD="$2"; shift 2 ;;
    --output)  OUTPUT_FORMAT="$2"; shift 2 ;;
    --help)    usage ;;
    *)         log_error "Unknown option: $1"; usage ;;
  esac
done

[[ -z "$ORG" ]] && { log_error "--org is required"; usage; }

# Validate prerequisites
command -v gh  >/dev/null 2>&1 || { log_error "gh CLI not found. Install: https://cli.github.com"; exit 1; }
command -v jq  >/dev/null 2>&1 || { log_error "jq not found. Install: sudo apt install jq"; exit 1; }

log_info "Checking GitHub authentication..."
gh auth status >/dev/null 2>&1 || { log_error "gh not authenticated. Run: gh auth login"; exit 1; }
log_ok "GitHub CLI authenticated"

# Check rate limit
RATE_REMAINING=$(gh api /rate_limit | jq '.resources.core.remaining')
log_info "API rate limit remaining: ${RATE_REMAINING}"
[[ "$RATE_REMAINING" -lt 100 ]] && log_warn "Low rate limit! Consider waiting."

SINCE=$(date -d "-${PERIOD} days" -Iseconds 2>/dev/null || date -v-"${PERIOD}"d -Iseconds)

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Determine repos to scan
if [[ -n "$REPO" ]]; then
  REPOS=("${ORG}/${REPO}")
else
  log_info "Discovering repos in org: ${ORG}..."
  mapfile -t REPOS < <(gh api "/orgs/${ORG}/repos" --paginate -q '.[].full_name' | head -50)
  log_ok "Found ${#REPOS[@]} repositories"
fi

# Initialize result object
RESULT=$(jq -n \
  --arg org "$ORG" \
  --arg period "${PERIOD}d" \
  --arg collected_at "$TIMESTAMP" \
  --arg since "$SINCE" \
  '{org: $org, period: $period, collected_at: $collected_at, since: $since, repos: [], pr_metrics: {}, deployment_metrics: {}, workflow_metrics: {}, contributor_metrics: {}}')

for repo in "${REPOS[@]}"; do
  log_info "Collecting metrics for: ${repo}..."
  owner="${repo%%/*}"
  name="${repo##*/}"

  # --- PR Metrics ---
  log_info "  📋 Pull Request metrics..."
  pr_data=$(gh pr list --repo "$repo" --state merged --limit 200 --json number,createdAt,mergedAt,additions,deletions,changedFiles,author 2>/dev/null || echo "[]")

  pr_count=$(echo "$pr_data" | jq 'length')
  pr_cycle_times=$(echo "$pr_data" | jq '[.[] | {hours: (((.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 3600)}] | if length > 0 then {avg: ([.[].hours] | add / length | . * 10 | round / 10), median: (sort_by(.hours) | .[length/2].hours | . * 10 | round / 10), p90: (sort_by(.hours) | .[(length * 0.9 | floor)].hours | . * 10 | round / 10)} else {avg: 0, median: 0, p90: 0} end' 2>/dev/null || echo '{"avg":0,"median":0,"p90":0}')

  # --- Deployment Metrics ---
  log_info "  🚀 Deployment metrics..."
  deploy_data=$(gh api "/repos/${repo}/deployments" --paginate 2>/dev/null | jq --arg since "$SINCE" '[.[] | select(.created_at > $since)]' 2>/dev/null || echo "[]")
  deploy_count=$(echo "$deploy_data" | jq 'length')
  deploy_per_week=$(echo "$deploy_data" | jq "length / (${PERIOD} / 7) | . * 10 | round / 10")

  # --- Workflow Metrics ---
  log_info "  ⚙️ Workflow metrics..."
  workflow_data=$(gh run list --repo "$repo" --limit 200 --json status,conclusion,createdAt,updatedAt,name 2>/dev/null || echo "[]")
  workflow_total=$(echo "$workflow_data" | jq 'length')
  workflow_success=$(echo "$workflow_data" | jq '[.[] | select(.conclusion == "success")] | length')
  workflow_success_rate=$(echo "$workflow_data" | jq 'if length > 0 then ([.[] | select(.conclusion == "success")] | length) / length * 100 | round else 0 end')

  # --- Contributor Metrics ---
  log_info "  👥 Contributor metrics..."
  contributor_count=$(echo "$pr_data" | jq '[.[].author.login] | unique | length')

  # Aggregate per repo
  RESULT=$(echo "$RESULT" | jq \
    --arg repo "$repo" \
    --argjson pr_count "$pr_count" \
    --argjson pr_cycle "$pr_cycle_times" \
    --argjson deploys "$deploy_count" \
    --argjson deploy_week "$deploy_per_week" \
    --argjson wf_total "$workflow_total" \
    --argjson wf_success "$workflow_success" \
    --argjson wf_rate "$workflow_success_rate" \
    --argjson contributors "$contributor_count" \
    '.repos += [{
      repo: $repo,
      pr_count: $pr_count,
      pr_cycle_time: $pr_cycle,
      deployments: $deploys,
      deployments_per_week: $deploy_week,
      workflow_runs: $wf_total,
      workflow_success: $wf_success,
      workflow_success_rate: $wf_rate,
      active_contributors: $contributors
    }]')

  log_ok "  Collected: ${pr_count} PRs, ${deploy_count} deploys, ${workflow_total} runs, ${contributor_count} contributors"
done

# Write output
OUTPUT_FILE="${OUTPUT_DIR}/github-metrics-$(date +%Y%m%d-%H%M%S).json"
echo "$RESULT" | jq '.' > "$OUTPUT_FILE"
log_ok "Metrics saved to: ${OUTPUT_FILE}"

# Summary output
if [[ "$OUTPUT_FORMAT" == "summary" ]]; then
  echo ""
  echo "========================================"
  echo "📊 Engineering Metrics Summary"
  echo "========================================"
  echo "Organization: ${ORG}"
  echo "Period: Last ${PERIOD} days"
  echo "Repos scanned: ${#REPOS[@]}"
  echo ""
  echo "$RESULT" | jq -r '.repos[] | "  \(.repo): \(.pr_count) PRs (avg \(.pr_cycle_time.avg)h), \(.deployments) deploys, \(.workflow_success_rate)% CI success"'
  echo ""
  echo "Full data: ${OUTPUT_FILE}"
fi

log_ok "Collection complete!"
