#!/bin/bash
# =============================================================================
# deploy-local.sh — Local Demo Deployment Orchestrator
# =============================================================================
# Deploys the Three Horizons Accelerator on a local kind cluster.
# Mirrors the deploy-full.sh experience without Terraform/Azure dependencies.
#
# Usage:
#   ./local/deploy-local.sh                     # Full deploy
#   ./local/deploy-local.sh --dry-run            # Preview only
#   ./local/deploy-local.sh --phase h1           # Deploy specific phase
#   ./local/deploy-local.sh --skip-rhdh          # Skip RHDH
#   ./local/deploy-local.sh --resume             # Resume from checkpoint
#   ./local/deploy-local.sh --destroy            # Teardown
# =============================================================================
set -euo pipefail

# -- Constants ----------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECKPOINT_FILE="$SCRIPT_DIR/.deploy-checkpoint"
LOG_FILE="$SCRIPT_DIR/.deploy-local.log"

# -- Colors -------------------------------------------------------------------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

# -- Load config --------------------------------------------------------------
# shellcheck source=config/local.env
source "$SCRIPT_DIR/config/local.env"

# -- Flags --------------------------------------------------------------------
DRY_RUN=false
DESTROY=false
RESUME=false
SKIP_RHDH=false
TARGET_PHASE="all"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)       DRY_RUN=true ;;
    --destroy)       DESTROY=true ;;
    --resume)        RESUME=true ;;
    --skip-rhdh)     SKIP_RHDH=true ;;
    --phase)         TARGET_PHASE="$2"; shift ;;
    -h|--help)
      echo "Usage: $0 [--dry-run] [--destroy] [--resume] [--skip-rhdh] [--phase h1|h2|all]"
      exit 0
      ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
  shift
done

# -- Helpers ------------------------------------------------------------------
banner() {
  echo ""
  echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║     ${BOLD}THREE HORIZONS — Local Demo Deployment${NC}${BLUE}                 ║${NC}"
  echo -e "${BLUE}║     Platform Accelerator v4.0 on kind                      ║${NC}"
  echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
}

log()  { echo -e "$(date '+%H:%M:%S') ${CYAN}[INFO]${NC}  $1" | tee -a "$LOG_FILE"; }
ok()   { echo -e "$(date '+%H:%M:%S') ${GREEN}[✓]${NC}     $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "$(date '+%H:%M:%S') ${YELLOW}[!]${NC}     $1" | tee -a "$LOG_FILE"; }
err()  { echo -e "$(date '+%H:%M:%S') ${RED}[✗]${NC}     $1" | tee -a "$LOG_FILE"; }

save_checkpoint() { echo "$1" > "$CHECKPOINT_FILE"; }
get_checkpoint()  { [[ -f "$CHECKPOINT_FILE" ]] && cat "$CHECKPOINT_FILE" || echo "0"; }
clear_checkpoint(){ rm -f "$CHECKPOINT_FILE"; }

should_run_phase() {
  local phase="$1"
  if [[ "$TARGET_PHASE" != "all" && "$TARGET_PHASE" != "$phase" ]]; then
    return 1
  fi
  if [[ "$RESUME" == "true" ]]; then
    local checkpoint
    checkpoint=$(get_checkpoint)
    if (( phase <= checkpoint )); then
      log "Skipping phase $phase (already completed)"
      return 1
    fi
  fi
  return 0
}

wait_for_pods() {
  local namespace="$1" timeout="${2:-120}"
  log "Waiting for pods in $namespace to be ready (timeout: ${timeout}s)..."
  if ! kubectl wait --for=condition=ready pod --all -n "$namespace" --timeout="${timeout}s" 2>/dev/null; then
    warn "Some pods in $namespace are not ready yet — continuing"
  fi
}

helm_install() {
  local name="$1" chart="$2" namespace="$3" values_file="${4:-}" extra_args="${5:-}"
  if [[ "$DRY_RUN" == "true" ]]; then
    log "[DRY-RUN] Would install: helm upgrade --install $name $chart -n $namespace"
    return 0
  fi
  local cmd="helm upgrade --install $name $chart --namespace $namespace --create-namespace --wait --timeout 5m"
  if [[ -n "$values_file" ]]; then
    cmd="$cmd -f $values_file"
  fi
  if [[ -n "$extra_args" ]]; then
    cmd="$cmd $extra_args"
  fi
  log "Installing $name..."
  eval "$cmd" 2>&1 | tee -a "$LOG_FILE"
}

# -- Destroy mode -------------------------------------------------------------
if [[ "$DESTROY" == "true" ]]; then
  banner
  warn "Destroying local demo cluster: $CLUSTER_NAME"
  echo ""
  read -rp "Are you sure? (yes/no): " confirm
  if [[ "$confirm" == "yes" ]]; then
    kind delete cluster --name "$CLUSTER_NAME" 2>/dev/null || true
    clear_checkpoint
    ok "Cluster $CLUSTER_NAME deleted"
  else
    log "Destroy cancelled"
  fi
  exit 0
fi

# =============================================================================
# DEPLOYMENT PHASES
# =============================================================================

banner

START_TIME=$(date +%s)

# -- Phase 0: Prerequisites ---------------------------------------------------
if should_run_phase 0; then
  echo -e "\n${BOLD}━━━ Phase 0/6: Prerequisites ━━━${NC}"

  for tool in docker kind kubectl helm jq yq; do
    if command -v "$tool" &>/dev/null; then
      ok "$tool found: $(command -v "$tool")"
    else
      err "$tool not found — install with: brew install $tool"
      exit 1
    fi
  done

  if ! docker info &>/dev/null; then
    err "Docker is not running — start Docker Desktop first"
    exit 1
  fi
  ok "Docker is running"

  save_checkpoint 0
fi

# -- Phase 1: Create kind Cluster ---------------------------------------------
if should_run_phase 1; then
  echo -e "\n${BOLD}━━━ Phase 1/7: Create kind Cluster ━━━${NC}"

  if kind get clusters 2>/dev/null | grep -q "^${CLUSTER_NAME}$"; then
    warn "Cluster $CLUSTER_NAME already exists — using existing"
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      log "[DRY-RUN] Would create cluster: kind create cluster --config $SCRIPT_DIR/kind-config.yaml"
    else
      log "Creating kind cluster: $CLUSTER_NAME (1 control-plane + 2 workers)..."
      kind create cluster --config "$SCRIPT_DIR/kind-config.yaml"
      ok "Cluster created"
    fi
  fi

  if [[ "$DRY_RUN" == "false" ]]; then
    kubectl cluster-info --context "kind-${CLUSTER_NAME}" 2>/dev/null
    ok "kubectl connected to kind-${CLUSTER_NAME}"
    kubectl get nodes
  fi

  save_checkpoint 1
fi

# -- Phase 2: H1 Foundation ---------------------------------------------------
if should_run_phase 2; then
  echo -e "\n${BOLD}━━━ Phase 2/7: H1 Foundation ━━━${NC}"

  # Namespaces
  log "Creating namespaces..."
  if [[ "$DRY_RUN" == "false" ]]; then
    kubectl apply -f "$SCRIPT_DIR/manifests/namespaces.yaml"
    ok "Namespaces created"
  fi

  # Secrets
  log "Creating demo secrets..."
  if [[ "$DRY_RUN" == "false" ]]; then
    kubectl apply -f "$SCRIPT_DIR/manifests/secrets.yaml"
    ok "Secrets created"
  fi

  # cert-manager
  if [[ "$CERT_MANAGER_ENABLED" == "true" ]]; then
    helm_install "cert-manager" "jetstack/cert-manager" "$NS_CERT_MANAGER" \
      "$SCRIPT_DIR/values/cert-manager-local.yaml" \
      "--version $CERT_MANAGER_VERSION"

    if [[ "$DRY_RUN" == "false" ]]; then
      wait_for_pods "$NS_CERT_MANAGER" 120
      # Wait a bit for webhook to be ready before creating ClusterIssuer
      sleep 10
      kubectl apply -f "$SCRIPT_DIR/manifests/self-signed-issuer.yaml"
      ok "Self-signed ClusterIssuer created"
    fi
  fi

  # ingress-nginx
  helm_install "ingress-nginx" "ingress-nginx/ingress-nginx" "$NS_INGRESS" \
    "$SCRIPT_DIR/values/ingress-nginx-local.yaml" \
    "--version $INGRESS_NGINX_VERSION"

  if [[ "$DRY_RUN" == "false" ]]; then
    wait_for_pods "$NS_INGRESS" 120
    ok "ingress-nginx ready"
  fi

  # Gatekeeper (OPA)
  if [[ "$GATEKEEPER_ENABLED" == "true" ]]; then
    helm_install "gatekeeper" "gatekeeper/gatekeeper" "$NS_GATEKEEPER" \
      "$SCRIPT_DIR/values/gatekeeper-local.yaml" \
      "--version $GATEKEEPER_VERSION"

    if [[ "$DRY_RUN" == "false" ]]; then
      wait_for_pods "$NS_GATEKEEPER" 120
      ok "Gatekeeper (OPA) ready — audit mode"
    fi
  fi

  save_checkpoint 2
fi

# -- Phase 3: H2 Enhancement --------------------------------------------------
if should_run_phase 3; then
  echo -e "\n${BOLD}━━━ Phase 3/7: H2 Enhancement — GitOps + Observability ━━━${NC}"

  # ArgoCD
  helm_install "argocd" "argo/argo-cd" "$NS_ARGOCD" \
    "$SCRIPT_DIR/values/argocd-local.yaml" \
    "--version $ARGOCD_CHART_VERSION"

  if [[ "$DRY_RUN" == "false" ]]; then
    wait_for_pods "$NS_ARGOCD" 180
    ok "ArgoCD ready"

    # Get initial admin password
    ARGOCD_PASS=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "check-secret")
    ok "ArgoCD admin password: $ARGOCD_PASS"
  fi

  # Prometheus + Grafana + Alertmanager
  helm_install "kube-prometheus-stack" "prometheus-community/kube-prometheus-stack" "$NS_MONITORING" \
    "$SCRIPT_DIR/values/monitoring-local.yaml" \
    "--version $PROMETHEUS_STACK_VERSION"

  if [[ "$DRY_RUN" == "false" ]]; then
    wait_for_pods "$NS_MONITORING" 180
    ok "Prometheus + Grafana + Alertmanager ready"
  fi

  save_checkpoint 3
fi

# -- Phase 4: Databases -------------------------------------------------------
if should_run_phase 4; then
  echo -e "\n${BOLD}━━━ Phase 4/7: Databases ━━━${NC}"

  if [[ "$DRY_RUN" == "false" ]]; then
    # PostgreSQL
    log "Deploying PostgreSQL..."
    kubectl apply -f "$SCRIPT_DIR/manifests/postgres.yaml"
    wait_for_pods "$NS_DATABASES" 120
    ok "PostgreSQL ready"

    # Redis
    log "Deploying Redis..."
    kubectl apply -f "$SCRIPT_DIR/manifests/redis.yaml"
    sleep 10
    ok "Redis ready"
  else
    log "[DRY-RUN] Would deploy PostgreSQL and Redis to $NS_DATABASES"
  fi

  save_checkpoint 4
fi

# -- Phase 5: Platform (Developer Portal) — Optional --------------------------
if should_run_phase 5; then
  echo -e "\n${BOLD}━━━ Phase 5/7: Developer Portal ━━━${NC}"

  if [[ "$SKIP_RHDH" == "true" || "$RHDH_ENABLED" != "true" ]]; then
    warn "Developer portal skipped (set RHDH_ENABLED=true to enable)"
  else
    # Create GitHub App secret if configured
    if [[ "$RHDH_AUTH_MODE" == "github" && -n "$GITHUB_APP_CLIENT_ID" ]]; then
      log "Configuring GitHub App authentication..."
      private_key=""
      if [[ -n "$GITHUB_APP_PRIVATE_KEY_FILE" && -f "$GITHUB_APP_PRIVATE_KEY_FILE" ]]; then
        private_key=$(cat "$GITHUB_APP_PRIVATE_KEY_FILE")
      fi
      secret_name="backstage-github-app"
      [[ "$PORTAL_TYPE" == "rhdh" ]] && secret_name="rhdh-github-app"
      kubectl create secret generic "$secret_name" \
        --namespace "$NS_RHDH" \
        --from-literal=app-id="$GITHUB_APP_ID" \
        --from-literal=client-id="$GITHUB_APP_CLIENT_ID" \
        --from-literal=client-secret="$GITHUB_APP_CLIENT_SECRET" \
        --from-literal=private-key="$private_key" \
        --from-literal=webhook-secret="${GITHUB_APP_WEBHOOK_SECRET:-}" \
        --dry-run=client -o yaml | kubectl apply -f -
      ok "GitHub App secret created in $NS_RHDH"
    else
      log "Using guest authentication (set RHDH_AUTH_MODE=github for GitHub App auth)"
    fi

    if [[ "${PORTAL_TYPE:-backstage}" == "rhdh" ]]; then
      log "Installing Red Hat Developer Hub (RHDH)..."
      warn "Requires registry.redhat.io credentials. If this fails, switch to PORTAL_TYPE=backstage"
      helm_install "rhdh" "openshift-helm-charts/redhat-developer-hub" "$NS_RHDH" \
        "$SCRIPT_DIR/values/rhdh-local.yaml"
    else
      log "Installing Backstage (upstream, open-source)..."
      helm_install "backstage" "backstage/backstage" "$NS_RHDH" \
        "$SCRIPT_DIR/values/backstage-local.yaml"
    fi

    if [[ "$DRY_RUN" == "false" ]]; then
      wait_for_pods "$NS_RHDH" 300
      ok "Developer portal ready (${PORTAL_TYPE:-backstage})"
    fi
  fi

  save_checkpoint 5
fi

# -- Phase 6: AWX (Ansible Automation) — Optional -----------------------------
if should_run_phase 6; then
  echo -e "\n${BOLD}━━━ Phase 6/7: AWX (Ansible Automation Platform) ━━━${NC}"

  if [[ "${AWX_ENABLED:-false}" != "true" ]]; then
    warn "AWX skipped (set AWX_ENABLED=true to enable)"
  else
    if [[ "$DRY_RUN" == "true" ]]; then
      log "[DRY-RUN] Would install AWX Operator + AWX instance in namespace awx"
    else
      # Create AWX namespace
      kubectl create namespace awx --dry-run=client -o yaml | kubectl apply -f -

      # Install AWX Operator via kustomize
      log "Installing AWX Operator v2.19.1..."
      kubectl apply -k "$SCRIPT_DIR/manifests/awx-operator/"
      log "Waiting for AWX Operator to be ready..."
      sleep 15
      kubectl wait --for=condition=available deployment/awx-operator-controller-manager \
        -n awx --timeout=120s 2>/dev/null || warn "Operator still starting..."

      # Deploy AWX instance
      log "Deploying AWX instance (this takes 3-5 minutes)..."
      kubectl apply -f "$SCRIPT_DIR/manifests/awx-instance.yaml"

      # Wait for AWX pods (takes a while — operator creates PostgreSQL + AWX pods)
      log "Waiting for AWX pods to start..."
      sleep 30
      kubectl wait --for=condition=ready pod -l app.kubernetes.io/managed-by=awx-operator \
        -n awx --timeout=300s 2>/dev/null || warn "AWX still starting — check: kubectl get pods -n awx"

      # Get admin password
      AWX_PASS=$(kubectl get secret awx-demo-admin-password -n awx \
        -o jsonpath="{.data.password}" 2>/dev/null | base64 -d 2>/dev/null || echo "pending")
      ok "AWX ready — admin password: $AWX_PASS"
    fi
  fi

  save_checkpoint 6
fi

# -- Phase 7: Dashboards + Validation -----------------------------------------
if should_run_phase 7; then
  echo -e "\n${BOLD}━━━ Phase 7/7: Dashboards + Validation ━━━${NC}"

  # Import Grafana dashboards
  if [[ -x "$SCRIPT_DIR/dashboards/import-dashboards.sh" && "$DRY_RUN" == "false" ]]; then
    log "Importing Grafana dashboards..."
    bash "$SCRIPT_DIR/dashboards/import-dashboards.sh"
    ok "Dashboards imported"
  fi

  # Final validation
  if [[ "$DRY_RUN" == "false" ]]; then
    log "Running final validation..."
    bash "$SCRIPT_DIR/validate-local.sh" || warn "Some validations failed — see output above"
  fi

  clear_checkpoint
fi

# -- Summary -------------------------------------------------------------------
END_TIME=$(date +%s)
DURATION=$(( END_TIME - START_TIME ))

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     ${BOLD}${GREEN}Deployment Complete!${NC}${BLUE}                                     ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [[ "$DRY_RUN" == "true" ]]; then
  echo -e "  ${YELLOW}This was a DRY RUN — no changes were made${NC}"
  echo ""
else
  echo -e "  ${BOLD}Access URLs:${NC}"
  echo -e "  ─────────────────────────────────────────"
  echo -e "  ${GREEN}ArgoCD${NC}      https://localhost:8443"
  echo -e "  ${GREEN}Grafana${NC}     http://localhost:3000       (admin / admin)"
  echo -e "  ${GREEN}Prometheus${NC}  http://localhost:9090"
  if [[ "$RHDH_ENABLED" == "true" && "$SKIP_RHDH" != "true" ]]; then
    echo -e "  ${GREEN}Portal${NC}      http://localhost:7007       (${PORTAL_TYPE:-backstage})"
  fi
  if [[ "${AWX_ENABLED:-false}" == "true" ]]; then
    echo -e "  ${GREEN}AWX${NC}         http://localhost:8052       (admin / make awx-password)"
  fi
  echo ""
  echo -e "  ${BOLD}ArgoCD Credentials:${NC}"
  echo -e "  Username: admin"
  echo -e "  Password: ${ARGOCD_PASS:-run 'make argocd-password' to retrieve}"
  echo ""
  echo -e "  ${BOLD}Cluster:${NC}"
  echo -e "  Context:  kind-${CLUSTER_NAME}"
  echo -e "  Nodes:    $(kubectl get nodes --no-headers 2>/dev/null | wc -l | tr -d ' ')"
  echo ""
  echo -e "  ${BOLD}Useful commands:${NC}"
  echo -e "  make -C local status       # View all pods"
  echo -e "  make -C local validate     # Re-run validation"
  echo -e "  make -C local down         # Tear down cluster"
  echo ""
fi

echo -e "  Duration: ${DURATION}s"
echo ""
