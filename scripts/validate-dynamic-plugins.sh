#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# validate-dynamic-plugins.sh
# Validates that all 9 RHDH dynamic plugins load and respond without errors.
#
# Usage:
#   ./scripts/validate-dynamic-plugins.sh [--base-url URL]
#
# Options:
#   --base-url URL   RHDH base URL (default: https://rhdh.example.com)
#   --token TOKEN    Bearer token for authenticated endpoints
#   --timeout SECS   HTTP timeout in seconds (default: 10)
#   --help           Show usage
# =============================================================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly DEFAULT_BASE_URL="https://rhdh.example.com"
readonly DEFAULT_TIMEOUT=10

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

BASE_URL="${DEFAULT_BASE_URL}"
TOKEN=""
TIMEOUT="${DEFAULT_TIMEOUT}"
PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

usage() {
  cat <<EOF
Usage: ${SCRIPT_NAME} [OPTIONS]

Validates RHDH dynamic plugin pages load without errors.

Options:
  --base-url URL   RHDH base URL (default: ${DEFAULT_BASE_URL})
  --token TOKEN    Bearer token for authenticated endpoints
  --timeout SECS   HTTP timeout in seconds (default: ${DEFAULT_TIMEOUT})
  --help           Show this message
EOF
}

log_pass() { echo -e "  ${GREEN}✓${NC} $1"; ((PASS_COUNT++)); }
log_fail() { echo -e "  ${RED}✗${NC} $1"; ((FAIL_COUNT++)); }
log_warn() { echo -e "  ${YELLOW}⚠${NC} $1"; ((WARN_COUNT++)); }
log_info() { echo -e "${BLUE}►${NC} $1"; }

check_endpoint() {
  local name="$1"
  local path="$2"
  local expected_status="${3:-200}"

  local curl_args=(-s -o /dev/null -w "%{http_code}" --connect-timeout "${TIMEOUT}" --max-time "$((TIMEOUT * 3))")
  if [[ -n "${TOKEN}" ]]; then
    curl_args+=(-H "Authorization: Bearer ${TOKEN}")
  fi

  local url="${BASE_URL}${path}"
  local status_code
  status_code=$(curl "${curl_args[@]}" "${url}" 2>/dev/null || echo "000")

  if [[ "${status_code}" == "${expected_status}" ]]; then
    log_pass "${name} — ${path} (HTTP ${status_code})"
  elif [[ "${status_code}" == "000" ]]; then
    log_fail "${name} — ${path} (connection refused / timeout)"
  elif [[ "${status_code}" == "302" || "${status_code}" == "301" ]]; then
    log_warn "${name} — ${path} (HTTP ${status_code} redirect — may require auth)"
  elif [[ "${status_code}" == "401" || "${status_code}" == "403" ]]; then
    log_warn "${name} — ${path} (HTTP ${status_code} — plugin loaded but requires auth)"
  else
    log_fail "${name} — ${path} (HTTP ${status_code}, expected ${expected_status})"
  fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base-url) BASE_URL="$2"; shift 2 ;;
    --token)    TOKEN="$2"; shift 2 ;;
    --timeout)  TIMEOUT="$2"; shift 2 ;;
    --help)     usage; exit 0 ;;
    *)          echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

# Remove trailing slash
BASE_URL="${BASE_URL%/}"

echo ""
echo "=============================================="
echo " RHDH Dynamic Plugins Validation"
echo "=============================================="
echo " Base URL : ${BASE_URL}"
echo " Timeout  : ${TIMEOUT}s"
echo " Auth     : $([ -n "${TOKEN}" ] && echo 'Bearer token' || echo 'None')"
echo "=============================================="
echo ""

# --- Health check ---
log_info "Backend health check"
check_endpoint "Backend health" "/api/proxy/health" "200"
check_endpoint "Backend readiness" "/.well-known/openid-configuration" "200"
echo ""

# --- Plugin 1: Catalog ---
log_info "Plugin 1: @backstage/plugin-catalog"
check_endpoint "Catalog page" "/catalog" "200"
check_endpoint "Catalog entities API" "/api/catalog/entities?limit=1" "200"
echo ""

# --- Plugin 2: API Docs ---
log_info "Plugin 2: @backstage/plugin-api-docs"
check_endpoint "API Explorer page" "/api-docs" "200"
echo ""

# --- Plugin 3: Scaffolder ---
log_info "Plugin 3: @backstage/plugin-scaffolder"
check_endpoint "Create page" "/create" "200"
check_endpoint "Scaffolder templates API" "/api/scaffolder/v2/templates" "200"
echo ""

# --- Plugin 4: TechDocs ---
log_info "Plugin 4: @backstage/plugin-techdocs"
check_endpoint "Docs index page" "/docs" "200"
echo ""

# --- Plugin 5: Lightspeed ---
log_info "Plugin 5: @backstage-community/plugin-lightspeed"
check_endpoint "Lightspeed page" "/lightspeed" "200"
echo ""

# --- Plugin 6: Notifications ---
log_info "Plugin 6: @backstage-community/plugin-notifications"
check_endpoint "Notifications page" "/notifications" "200"
echo ""

# --- Plugin 7: RBAC ---
log_info "Plugin 7: @janus-idp/plugin-rbac"
check_endpoint "RBAC admin page" "/admin/rbac" "200"
echo ""

# --- Plugin 8: User Settings ---
log_info "Plugin 8: @backstage/plugin-user-settings"
check_endpoint "Settings page" "/settings" "200"
echo ""

# --- Plugin 9: Topology ---
log_info "Plugin 9: @janus-idp/plugin-topology"
check_endpoint "Topology (entity tab)" "/catalog/default/component/example/kubernetes" "200"
echo ""

# --- Summary ---
echo "=============================================="
echo " Validation Summary"
echo "=============================================="
echo -e "  ${GREEN}Passed${NC} : ${PASS_COUNT}"
echo -e "  ${RED}Failed${NC} : ${FAIL_COUNT}"
echo -e "  ${YELLOW}Warns${NC}  : ${WARN_COUNT}"
echo "=============================================="

if [[ "${FAIL_COUNT}" -gt 0 ]]; then
  echo -e "\n${RED}Some plugin pages failed validation.${NC}"
  echo "Check that:"
  echo "  1. RHDH is running and accessible at ${BASE_URL}"
  echo "  2. dynamic-plugins-config.yaml is mounted as a ConfigMap"
  echo "  3. All plugin packages exist in ./dynamic-plugins/dist/"
  echo "  4. Azure OpenAI secrets (AZURE_OPENAI_ENDPOINT, AZURE_OPENAI_KEY) are set"
  exit 1
else
  echo -e "\n${GREEN}All plugin pages validated successfully.${NC}"
  exit 0
fi
