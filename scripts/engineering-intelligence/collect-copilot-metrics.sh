#!/usr/bin/env bash
set -euo pipefail

#=============================================================================
# collect-copilot-metrics.sh
# Collect GitHub Copilot usage metrics from the organization Metrics API
#
# Usage:
#   ./scripts/engineering-intelligence/collect-copilot-metrics.sh \
#     --org <github-org> \
#     --output <json|summary>
#
# Prerequisites:
#   - gh CLI authenticated
#   - GITHUB_TOKEN with manage_billing:copilot, read:org scopes
#   - Organization must have Copilot Business or Enterprise
#=============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

ORG=""
OUTPUT_FORMAT="json"
OUTPUT_DIR="${SCRIPT_DIR}/../../data/engineering-intelligence"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} --org <org> [--output <json|summary>]

Options:
  --org       GitHub organization name (required)
  --output    Output format: json or summary (default: json)
  --help      Show this help message

Examples:
  ${SCRIPT_NAME} --org 3horizons
  ${SCRIPT_NAME} --org 3horizons --output summary
EOF
  exit 0
}

log_info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*" >&2; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --org)     ORG="$2"; shift 2 ;;
    --output)  OUTPUT_FORMAT="$2"; shift 2 ;;
    --help)    usage ;;
    *)         log_error "Unknown option: $1"; usage ;;
  esac
done

[[ -z "$ORG" ]] && { log_error "--org is required"; usage; }

command -v gh  >/dev/null 2>&1 || { log_error "gh CLI not found"; exit 1; }
command -v jq  >/dev/null 2>&1 || { log_error "jq not found"; exit 1; }

gh auth status >/dev/null 2>&1 || { log_error "gh not authenticated"; exit 1; }
log_ok "GitHub CLI authenticated"

mkdir -p "$OUTPUT_DIR"

# ── Copilot Metrics API ──────────────────────────────────────────────────────
log_info "Collecting Copilot metrics for org: ${ORG}..."

METRICS_RAW=$(gh api "/orgs/${ORG}/copilot/metrics" 2>/dev/null || echo "[]")

if [[ "$METRICS_RAW" == "[]" || "$METRICS_RAW" == *"Not Found"* ]]; then
  log_error "Could not fetch Copilot metrics. Ensure Copilot Business/Enterprise is enabled and token has manage_billing:copilot scope."
  exit 1
fi

log_ok "Raw metrics retrieved"

# ── Aggregate Metrics ────────────────────────────────────────────────────────
log_info "Processing metrics..."

COPILOT_SUMMARY=$(echo "$METRICS_RAW" | jq '{
  period: {
    start: (.[0].date // "unknown"),
    end: (.[-1].date // "unknown"),
    days: length
  },
  users: {
    total_active: ([.[].total_active_users] | max // 0),
    total_engaged: ([.[].total_engaged_users] | max // 0),
    avg_active: ([.[].total_active_users] | add / length | round)
  },
  code_completions: {
    total_suggestions: ([.[].copilot_ide_code_completions.total_code_suggestions // 0] | add),
    total_acceptances: ([.[].copilot_ide_code_completions.total_code_acceptances // 0] | add),
    total_lines_suggested: ([.[].copilot_ide_code_completions.total_code_lines_suggested // 0] | add),
    total_lines_accepted: ([.[].copilot_ide_code_completions.total_code_lines_accepted // 0] | add),
    acceptance_rate: (
      if ([.[].copilot_ide_code_completions.total_code_suggestions // 0] | add) > 0
      then (([.[].copilot_ide_code_completions.total_code_acceptances // 0] | add) / ([.[].copilot_ide_code_completions.total_code_suggestions // 0] | add) * 100 | . * 10 | round / 10)
      else 0
      end
    )
  },
  chat: {
    total_chats: ([.[].copilot_ide_chat.total_chats // 0] | add),
    total_insertions: ([.[].copilot_ide_chat.total_chat_insertion_events // 0] | add),
    chat_active_users: ([.[].copilot_ide_chat.total_engaged_users // 0] | max)
  },
  pr_summaries: {
    total_created: ([.[].copilot_dotcom_pull_requests.total_pr_summaries_created // 0] | add),
    pr_users: ([.[].copilot_dotcom_pull_requests.total_engaged_users // 0] | max)
  }
}')

# ── Language Breakdown ───────────────────────────────────────────────────────
log_info "Analyzing language breakdown..."

LANGUAGES=$(echo "$METRICS_RAW" | jq '[
  .[].copilot_ide_code_completions.languages // [] | .[] |
  {language: .name, suggestions: .total_code_suggestions, acceptances: .total_code_acceptances}
] | group_by(.language) | map({
  language: .[0].language,
  total_suggestions: ([.[].suggestions] | add),
  total_acceptances: ([.[].acceptances] | add),
  acceptance_rate: (if ([.[].suggestions] | add) > 0 then (([.[].acceptances] | add) / ([.[].suggestions] | add) * 100 | round) else 0 end)
}) | sort_by(-.total_suggestions) | .[0:15]')

# ── Editor Breakdown ─────────────────────────────────────────────────────────
log_info "Analyzing editor breakdown..."

EDITORS=$(echo "$METRICS_RAW" | jq '[
  .[].copilot_ide_code_completions.editors // [] | .[] |
  {editor: .name, suggestions: .total_code_suggestions, users: .total_engaged_users}
] | group_by(.editor) | map({
  editor: .[0].editor,
  total_suggestions: ([.[].suggestions] | add),
  max_users: ([.[].users] | max)
}) | sort_by(-.total_suggestions)')

# ── Daily Trend ──────────────────────────────────────────────────────────────
log_info "Calculating daily trends..."

DAILY_TREND=$(echo "$METRICS_RAW" | jq '[.[] | {
  date: .date,
  active_users: .total_active_users,
  suggestions: (.copilot_ide_code_completions.total_code_suggestions // 0),
  acceptances: (.copilot_ide_code_completions.total_code_acceptances // 0),
  acceptance_rate: (
    if (.copilot_ide_code_completions.total_code_suggestions // 0) > 0
    then ((.copilot_ide_code_completions.total_code_acceptances // 0) / (.copilot_ide_code_completions.total_code_suggestions // 0) * 100 | round)
    else 0
    end
  )
}]')

# ── Billing / Seat Info ──────────────────────────────────────────────────────
log_info "Checking seat utilization..."

BILLING=$(gh api "/orgs/${ORG}/copilot/billing" 2>/dev/null | jq '{
  seat_management: .seat_management_setting,
  plan_type: .plan_type,
  seats: .seat_breakdown
}' 2>/dev/null || echo '{"seat_management": "unknown", "plan_type": "unknown", "seats": {}}')

# ── Compose Final Result ─────────────────────────────────────────────────────
RESULT=$(jq -n \
  --arg org "$ORG" \
  --arg ts "$TIMESTAMP" \
  --argjson summary "$COPILOT_SUMMARY" \
  --argjson languages "$LANGUAGES" \
  --argjson editors "$EDITORS" \
  --argjson trend "$DAILY_TREND" \
  --argjson billing "$BILLING" \
  '{
    org: $org,
    collected_at: $ts,
    summary: $summary,
    languages: $languages,
    editors: $editors,
    daily_trend: $trend,
    billing: $billing
  }')

OUTPUT_FILE="${OUTPUT_DIR}/copilot-metrics-$(date +%Y%m%d-%H%M%S).json"
echo "$RESULT" | jq '.' > "$OUTPUT_FILE"
log_ok "Copilot metrics saved to: ${OUTPUT_FILE}"

# ── Summary ──────────────────────────────────────────────────────────────────
if [[ "$OUTPUT_FORMAT" == "summary" ]]; then
  echo ""
  echo "========================================"
  echo "🤖 GitHub Copilot Analytics Summary"
  echo "========================================"
  echo "Organization: ${ORG}"
  echo ""
  echo "$COPILOT_SUMMARY" | jq -r '"Active Users: \(.users.total_active)
Acceptance Rate: \(.code_completions.acceptance_rate)%
Total Suggestions: \(.code_completions.total_suggestions)
Total Acceptances: \(.code_completions.total_acceptances)
Lines Accepted: \(.code_completions.total_lines_accepted)
Chat Sessions: \(.chat.total_chats)
PR Summaries: \(.pr_summaries.total_created)"'
  echo ""
  echo "Top Languages:"
  echo "$LANGUAGES" | jq -r '.[:5][] | "  \(.language): \(.acceptance_rate)% acceptance (\(.total_suggestions) suggestions)"'
  echo ""
  echo "Full data: ${OUTPUT_FILE}"
fi

log_ok "Copilot collection complete!"
