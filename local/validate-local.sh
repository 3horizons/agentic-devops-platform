#!/bin/bash
# =============================================================================
# validate-local.sh — Local Demo Validation
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config/local.env"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'
ERRORS=0

pass() { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo -e "  ${YELLOW}!${NC} $1"; }
header() { echo -e "\n${BLUE}━━━ $1 ━━━${NC}"; }

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ${BOLD}THREE HORIZONS — Local Demo Validation${NC}${BLUE}                  ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"

# --- Cluster ---
header "Cluster Health"
if kubectl cluster-info --context "kind-${CLUSTER_NAME}" &>/dev/null; then
  pass "Cluster reachable: kind-${CLUSTER_NAME}"
else
  fail "Cannot connect to cluster"
fi

NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [[ "$NODE_COUNT" -ge 3 ]]; then
  pass "Nodes: $NODE_COUNT (expected >= 3)"
else
  fail "Nodes: $NODE_COUNT (expected >= 3)"
fi

READY_NODES=$(kubectl get nodes --no-headers 2>/dev/null | grep -c " Ready" || true)
if [[ "$READY_NODES" -eq "$NODE_COUNT" ]]; then
  pass "All nodes Ready"
else
  fail "$READY_NODES/$NODE_COUNT nodes Ready"
fi

# --- Namespaces ---
header "Namespaces"
for ns in $NS_ARGOCD $NS_MONITORING $NS_CERT_MANAGER $NS_INGRESS $NS_DATABASES; do
  if kubectl get namespace "$ns" &>/dev/null; then
    pass "Namespace: $ns"
  else
    fail "Namespace missing: $ns"
  fi
done

# --- Pod Health ---
header "Pod Health"
for ns in $NS_CERT_MANAGER $NS_INGRESS $NS_ARGOCD $NS_MONITORING $NS_DATABASES; do
  TOTAL=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | wc -l | tr -d ' ')
  RUNNING=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | grep -cE "Running|Completed" || true)
  FAILING=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | grep -c "CrashLoopBackOff" || true)

  if [[ "$FAILING" -gt 0 ]]; then
    fail "$ns: $FAILING pods in CrashLoopBackOff"
  elif [[ "$RUNNING" -eq "$TOTAL" && "$TOTAL" -gt 0 ]]; then
    pass "$ns: $RUNNING/$TOTAL pods healthy"
  else
    warn "$ns: $RUNNING/$TOTAL pods ready"
  fi
done

# --- Services ---
header "Key Services"

# ArgoCD
if kubectl get svc argocd-server -n "$NS_ARGOCD" &>/dev/null; then
  pass "ArgoCD Server service exists"
else
  fail "ArgoCD Server service missing"
fi

# Grafana
if kubectl get svc monitoring-grafana -n "$NS_MONITORING" &>/dev/null 2>&1 || \
   kubectl get svc kube-prometheus-stack-grafana -n "$NS_MONITORING" &>/dev/null 2>&1; then
  pass "Grafana service exists"
else
  fail "Grafana service missing"
fi

# Prometheus
if kubectl get svc monitoring-prometheus -n "$NS_MONITORING" &>/dev/null 2>&1 || \
   kubectl get svc kube-prometheus-stack-prometheus -n "$NS_MONITORING" &>/dev/null 2>&1; then
  pass "Prometheus service exists"
else
  fail "Prometheus service missing"
fi

# cert-manager
if [[ "$CERT_MANAGER_ENABLED" == "true" ]]; then
  if kubectl get clusterissuer selfsigned-issuer &>/dev/null; then
    pass "cert-manager ClusterIssuer: selfsigned-issuer"
  else
    fail "cert-manager ClusterIssuer missing"
  fi
fi

# PostgreSQL
if kubectl get svc postgresql -n "$NS_DATABASES" &>/dev/null; then
  pass "PostgreSQL service exists"
else
  fail "PostgreSQL service missing"
fi

# Redis
if kubectl get svc redis -n "$NS_DATABASES" &>/dev/null; then
  pass "Redis service exists"
else
  fail "Redis service missing"
fi

# --- Gatekeeper ---
if [[ "$GATEKEEPER_ENABLED" == "true" ]]; then
  header "Gatekeeper (OPA)"
  if kubectl get pods -n "$NS_GATEKEEPER" --no-headers 2>/dev/null | grep -q "Running"; then
    pass "Gatekeeper controller running"
  else
    fail "Gatekeeper controller not running"
  fi
fi

# --- RHDH ---
if [[ "$RHDH_ENABLED" == "true" ]]; then
  header "Developer Portal (${PORTAL_TYPE:-backstage})"
  if kubectl get svc -n "$NS_RHDH" --no-headers 2>/dev/null | grep -qE "rhdh|backstage"; then
    pass "Developer portal service exists"
  else
    warn "Developer portal service not found (may not be installed)"
  fi
fi

# --- AWX ---
if [[ "${AWX_ENABLED:-false}" == "true" ]]; then
  header "AWX (Ansible Automation)"
  if kubectl get pods -n awx --no-headers 2>/dev/null | grep -q "Running"; then
    pass "AWX pods running"
    if kubectl get svc awx-demo-service -n awx &>/dev/null; then
      pass "AWX service exists"
    else
      fail "AWX service missing"
    fi
  else
    warn "AWX not running (may still be starting — takes 3-5 min)"
  fi
fi

# --- Summary ---
echo ""
if [[ "$ERRORS" -eq 0 ]]; then
  echo -e "${GREEN}━━━ All validations passed! ━━━${NC}"
  echo ""
  echo -e "  ${BOLD}Access URLs:${NC}"
  echo -e "  ArgoCD:     https://localhost:8443"
  echo -e "  Grafana:    http://localhost:3000"
  echo -e "  Prometheus: http://localhost:9090"
  echo ""
  exit 0
else
  echo -e "${RED}━━━ $ERRORS validation(s) failed ━━━${NC}"
  echo ""
  echo -e "  Run ${BOLD}kubectl get pods -A${NC} to inspect pod status"
  echo -e "  Run ${BOLD}kubectl describe pod <pod> -n <ns>${NC} for details"
  echo ""
  exit 1
fi
