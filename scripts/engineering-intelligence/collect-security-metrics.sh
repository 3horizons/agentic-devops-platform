#!/usr/bin/env bash
set -euo pipefail

#=============================================================================
# collect-security-metrics.sh
# Collect GitHub Advanced Security metrics — Code Scanning, Secret Scanning,
# Dependabot alerts across the organization
#
# Usage:
#   ./scripts/engineering-intelligence/collect-security-metrics.sh \
#     --org <github-org> \
#     [--repo <repo>] \
#     --output <json|summary>
#
# Prerequisites:
#   - gh CLI authenticated
#   - GITHUB_TOKEN with security_events, secret_scanning_alerts:read scopes
#   - GHAS enabled on target repos
#=============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

ORG=""
REPO=""
OUTPUT_FORMAT="json"
OUTPUT_DIR="${SCRIPT_DIR}/../../data/engineering-intelligence"

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} --org <org> [--repo <repo>] [--output <json|summary>]

Options:
  --org       GitHub organization name (required)
  --repo      Specific repository (optional, default: all org repos)
  --output    Output format: json or summary (default: json)
  --help      Show this help message
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
    --repo)    REPO="$2"; shift 2 ;;
    --output)  OUTPUT_FORMAT="$2"; shift 2 ;;
    --help)    usage ;;
    *)         log_error "Unknown option: $1"; usage ;;
  esac
done

[[ -z "$ORG" ]] && { log_error "--org is required"; usage; }

command -v gh  >/dev/null 2>&1 || { log_error "gh CLI not found"; exit 1; }
command -v jq  >/dev/null 2>&1 || { log_error "jq not found"; exit 1; }
gh auth status >/dev/null 2>&1 || { log_error "gh not authenticated"; exit 1; }

mkdir -p "$OUTPUT_DIR"

# Determine repos
if [[ -n "$REPO" ]]; then
  REPOS=("${ORG}/${REPO}")
else
  log_info "Discovering repos in org: ${ORG}..."
  mapfile -t REPOS < <(gh api "/orgs/${ORG}/repos" --paginate -q '.[].full_name' | head -50)
  log_ok "Found ${#REPOS[@]} repositories"
fi

# Initialize totals
TOTAL_CODE_SCANNING_OPEN=0
TOTAL_CODE_SCANNING_FIXED=0
TOTAL_SECRET_OPEN=0
TOTAL_SECRET_RESOLVED=0
TOTAL_DEPENDABOT_OPEN=0
TOTAL_DEPENDABOT_FIXED=0
REPO_RESULTS="[]"

for repo in "${REPOS[@]}"; do
  log_info "Scanning: ${repo}..."

  # Code Scanning
  cs_open=$(gh api "/repos/${repo}/code-scanning/alerts?state=open" --paginate 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
  cs_fixed=$(gh api "/repos/${repo}/code-scanning/alerts?state=fixed" --paginate 2>/dev/null | jq 'length' 2>/dev/null || echo 0)

  cs_by_severity=$(gh api "/repos/${repo}/code-scanning/alerts?state=open" --paginate 2>/dev/null | jq 'group_by(.rule.security_severity_level) | map({severity: .[0].rule.security_severity_level, count: length})' 2>/dev/null || echo '[]')

  # Secret Scanning
  ss_open=$(gh api "/repos/${repo}/secret-scanning/alerts?state=open" --paginate 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
  ss_resolved=$(gh api "/repos/${repo}/secret-scanning/alerts?state=resolved" --paginate 2>/dev/null | jq 'length' 2>/dev/null || echo 0)

  # Dependabot
  dep_open=$(gh api "/repos/${repo}/dependabot/alerts?state=open" --paginate 2>/dev/null | jq 'length' 2>/dev/null || echo 0)
  dep_fixed=$(gh api "/repos/${repo}/dependabot/alerts?state=fixed" --paginate 2>/dev/null | jq 'length' 2>/dev/null || echo 0)

  dep_by_severity=$(gh api "/repos/${repo}/dependabot/alerts?state=open" --paginate 2>/dev/null | jq 'group_by(.security_advisory.severity) | map({severity: .[0].security_advisory.severity, count: length})' 2>/dev/null || echo '[]')

  # Accumulate
  TOTAL_CODE_SCANNING_OPEN=$((TOTAL_CODE_SCANNING_OPEN + cs_open))
  TOTAL_CODE_SCANNING_FIXED=$((TOTAL_CODE_SCANNING_FIXED + cs_fixed))
  TOTAL_SECRET_OPEN=$((TOTAL_SECRET_OPEN + ss_open))
  TOTAL_SECRET_RESOLVED=$((TOTAL_SECRET_RESOLVED + ss_resolved))
  TOTAL_DEPENDABOT_OPEN=$((TOTAL_DEPENDABOT_OPEN + dep_open))
  TOTAL_DEPENDABOT_FIXED=$((TOTAL_DEPENDABOT_FIXED + dep_fixed))

  REPO_RESULTS=$(echo "$REPO_RESULTS" | jq \
    --arg repo "$repo" \
    --argjson cs_open "$cs_open" --argjson cs_fixed "$cs_fixed" \
    --argjson ss_open "$ss_open" --argjson ss_resolved "$ss_resolved" \
    --argjson dep_open "$dep_open" --argjson dep_fixed "$dep_fixed" \
    --argjson cs_sev "$cs_by_severity" --argjson dep_sev "$dep_by_severity" \
    '. += [{repo: $repo, code_scanning: {open: $cs_open, fixed: $cs_fixed, by_severity: $cs_sev}, secret_scanning: {open: $ss_open, resolved: $ss_resolved}, dependabot: {open: $dep_open, fixed: $dep_fixed, by_severity: $dep_sev}}]')

  log_ok "  CS: ${cs_open} open / ${cs_fixed} fixed | SS: ${ss_open} open | Dep: ${dep_open} open"
done

# Compose result
RESULT=$(jq -n \
  --arg org "$ORG" \
  --arg ts "$TIMESTAMP" \
  --argjson repos "$REPO_RESULTS" \
  --argjson cs_open "$TOTAL_CODE_SCANNING_OPEN" \
  --argjson cs_fixed "$TOTAL_CODE_SCANNING_FIXED" \
  --argjson ss_open "$TOTAL_SECRET_OPEN" \
  --argjson ss_resolved "$TOTAL_SECRET_RESOLVED" \
  --argjson dep_open "$TOTAL_DEPENDABOT_OPEN" \
  --argjson dep_fixed "$TOTAL_DEPENDABOT_FIXED" \
  '{
    org: $org,
    collected_at: $ts,
    totals: {
      code_scanning: {open: $cs_open, fixed: $cs_fixed},
      secret_scanning: {open: $ss_open, resolved: $ss_resolved},
      dependabot: {open: $dep_open, fixed: $dep_fixed},
      total_open_alerts: ($cs_open + $ss_open + $dep_open)
    },
    repos: $repos
  }')

OUTPUT_FILE="${OUTPUT_DIR}/security-metrics-$(date +%Y%m%d-%H%M%S).json"
echo "$RESULT" | jq '.' > "$OUTPUT_FILE"
log_ok "Security metrics saved to: ${OUTPUT_FILE}"

if [[ "$OUTPUT_FORMAT" == "summary" ]]; then
  echo ""
  echo "========================================"
  echo "🔒 Security Posture Summary"
  echo "========================================"
  echo "Organization: ${ORG}"
  echo "Repos scanned: ${#REPOS[@]}"
  echo ""
  echo "Code Scanning:   ${TOTAL_CODE_SCANNING_OPEN} open / ${TOTAL_CODE_SCANNING_FIXED} fixed"
  echo "Secret Scanning: ${TOTAL_SECRET_OPEN} open / ${TOTAL_SECRET_RESOLVED} resolved"
  echo "Dependabot:      ${TOTAL_DEPENDABOT_OPEN} open / ${TOTAL_DEPENDABOT_FIXED} fixed"
  echo "────────────────────────────────────────"
  echo "Total Open Alerts: $((TOTAL_CODE_SCANNING_OPEN + TOTAL_SECRET_OPEN + TOTAL_DEPENDABOT_OPEN))"
  echo ""
  echo "Full data: ${OUTPUT_FILE}"
fi

log_ok "Security collection complete!"
