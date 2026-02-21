# =============================================================================
# THREE HORIZONS ACCELERATOR — Local Demo Makefile
# =============================================================================
# Usage:
#   make up         Deploy full local demo
#   make down       Tear down cluster
#   make status     Show all pods
#   make argocd     Open ArgoCD (port-forward)
#   make grafana    Open Grafana (port-forward)
# =============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help
LOCAL_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

.PHONY: help up down status validate reset logs \
        argocd grafana prometheus rhdh argocd-password \
        add-helm-repos

help: ## Show available targets
	@echo ""
	@echo "Three Horizons Accelerator — Local Demo"
	@echo "════════════════════════════════════════"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""

# ---------------------------------------------------------------------------
# Lifecycle
# ---------------------------------------------------------------------------

add-helm-repos: ## Add required Helm repositories
	@helm repo add jetstack https://charts.jetstack.io 2>/dev/null || true
	@helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
	@helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true
	@helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
	@helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts 2>/dev/null || true
	@helm repo add backstage https://backstage.github.io/charts 2>/dev/null || true
	@helm repo update
	@echo "✓ Helm repos ready"

up: add-helm-repos ## Deploy full local demo
	@chmod +x $(LOCAL_DIR)deploy-local.sh
	@bash $(LOCAL_DIR)deploy-local.sh

dry-run: add-helm-repos ## Preview deployment (no changes)
	@chmod +x $(LOCAL_DIR)deploy-local.sh
	@bash $(LOCAL_DIR)deploy-local.sh --dry-run

down: ## Tear down the local cluster
	@chmod +x $(LOCAL_DIR)teardown-local.sh
	@bash $(LOCAL_DIR)teardown-local.sh

reset: down up ## Destroy and rebuild from scratch

resume: add-helm-repos ## Resume deployment from last checkpoint
	@bash $(LOCAL_DIR)deploy-local.sh --resume

# ---------------------------------------------------------------------------
# Observability
# ---------------------------------------------------------------------------

status: ## Show all pods across namespaces
	@kubectl get pods -A --sort-by=.metadata.namespace 2>/dev/null || echo "Cluster not running"

nodes: ## Show cluster nodes
	@kubectl get nodes -o wide 2>/dev/null || echo "Cluster not running"

validate: ## Run full validation suite
	@chmod +x $(LOCAL_DIR)validate-local.sh
	@bash $(LOCAL_DIR)validate-local.sh

logs: ## Tail logs for a component (usage: make logs NS=argocd POD=argocd-server)
	@kubectl logs -f -n $(NS) -l app.kubernetes.io/name=$(POD) --tail=50 2>/dev/null || \
		echo "Usage: make logs NS=argocd POD=argocd-server"

# ---------------------------------------------------------------------------
# Port Forwards (access services)
# ---------------------------------------------------------------------------

argocd: ## Port-forward ArgoCD UI → https://localhost:8443
	@echo "ArgoCD UI → https://localhost:8443"
	@echo "Password: $$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d 2>/dev/null || echo 'run: make argocd-password')"
	@kubectl port-forward svc/argocd-server -n argocd 8443:443

grafana: ## Port-forward Grafana → http://localhost:3000
	@echo "Grafana → http://localhost:3000  (admin / admin)"
	@kubectl port-forward svc/monitoring-grafana -n observability 3000:80 2>/dev/null || \
		kubectl port-forward svc/kube-prometheus-stack-grafana -n observability 3000:80

prometheus: ## Port-forward Prometheus → http://localhost:9090
	@echo "Prometheus → http://localhost:9090"
	@kubectl port-forward svc/monitoring-kube-prometheus-prometheus -n observability 9090:9090 2>/dev/null || \
		kubectl port-forward svc/kube-prometheus-stack-prometheus -n observability 9090:9090

portal: ## Port-forward Developer Portal (Backstage or RHDH) → http://localhost:7007
	@echo "Developer Portal → http://localhost:7007"
	@kubectl port-forward svc/backstage -n rhdh 7007:7007 2>/dev/null || \
		kubectl port-forward svc/rhdh-redhat-developer-hub -n rhdh 7007:7007 2>/dev/null || \
		echo "Portal not installed. Set RHDH_ENABLED=true in local/config/local.env"

rhdh: portal ## Alias for portal (backward compat)

argocd-password: ## Show ArgoCD admin password
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' 2>/dev/null | base64 -d && echo "" || \
		echo "Secret not found — is ArgoCD installed?"

# ---------------------------------------------------------------------------
# Dashboards
# ---------------------------------------------------------------------------

dashboards: ## Import Grafana dashboards
	@chmod +x $(LOCAL_DIR)dashboards/import-dashboards.sh
	@bash $(LOCAL_DIR)dashboards/import-dashboards.sh
