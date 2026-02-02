---
name: helm-cli
description: 'Helm CLI reference for Kubernetes package management. Use when asked to deploy, upgrade, rollback Helm releases, manage repositories, inspect charts.'
license: Complete terms in LICENSE.txt
---

# Helm CLI Skill

> **Domain:** Kubernetes Package Management  
> **Category:** CLI Operations  
> **Version:** 3.0+

## Overview

This skill provides comprehensive Helm CLI reference for managing Kubernetes applications through Helm charts. Use this when deploying, upgrading, or managing Helm releases in AKS clusters.

---

## USE FOR

- When user asks to run `helm` commands
- Deploy Helm charts (ArgoCD, Prometheus, Grafana, cert-manager, external-secrets)
- Upgrade existing Helm releases with new values
- Rollback failed Helm deployments to previous revision
- List or inspect Helm releases in namespaces
- Add, update, or remove Helm repositories
- Template Helm charts to generate Kubernetes manifests
- Troubleshoot Helm release failures

## DO NOT USE FOR

- Creating raw Kubernetes manifests (use kubectl-cli skill)
- Azure resource provisioning (use azure-cli skill)
- OpenShift-specific operations (use oc-cli skill)
- ArgoCD application management (use argocd-cli skill)
- Terraform infrastructure code (use terraform-cli skill)

---

## Core Commands

### Repository Management

```bash
# Add official Helm repositories
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add jetstack https://charts.jetstack.io  # cert-manager

# Update repository index
helm repo update

# List configured repositories
helm repo list

# Search for charts
helm search repo argocd
helm search repo prometheus --versions  # Show all versions
```

### Installation

```bash
# Install chart with default values
helm install my-release repo/chart-name -n namespace --create-namespace

# Install with custom values file
helm install my-release repo/chart-name \
  -n namespace \
  -f values.yaml \
  --create-namespace

# Install with inline values
helm install my-release repo/chart-name \
  -n namespace \
  --set key1=value1 \
  --set key2=value2

# Install specific version
helm install my-release repo/chart-name \
  --version 5.2.0 \
  -n namespace

# Dry-run to see generated manifests
helm install my-release repo/chart-name \
  -n namespace \
  --dry-run --debug

# Generate manifests without installing (useful for GitOps)
helm template my-release repo/chart-name \
  -n namespace \
  -f values.yaml \
  > manifests.yaml
```

### Upgrade & Rollback

```bash
# Upgrade release with new values
helm upgrade my-release repo/chart-name \
  -n namespace \
  -f values.yaml

# Upgrade or install if not exists
helm upgrade --install my-release repo/chart-name \
  -n namespace \
  -f values.yaml

# Rollback to previous revision
helm rollback my-release -n namespace

# Rollback to specific revision
helm rollback my-release 3 -n namespace

# View rollback history
helm history my-release -n namespace
```

### Inspection

```bash
# List all releases
helm list -A  # All namespaces
helm list -n namespace

# Get release status
helm status my-release -n namespace

# Get release values
helm get values my-release -n namespace
helm get values my-release -n namespace --all  # Include defaults

# Get release manifests
helm get manifest my-release -n namespace

# Get release notes
helm get notes my-release -n namespace

# Show chart information
helm show chart repo/chart-name
helm show values repo/chart-name  # Default values
helm show readme repo/chart-name
```

### Uninstallation

```bash
# Uninstall release
helm uninstall my-release -n namespace

# Uninstall and keep history
helm uninstall my-release -n namespace --keep-history
```

---

## Common Helm Charts

### ArgoCD

```bash
# Add repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install ArgoCD
helm install argocd argo/argo-cd \
  -n argocd \
  --create-namespace \
  -f argocd-values.yaml

# Example values for Azure integration
cat <<EOF > argocd-values.yaml
server:
  service:
    type: LoadBalancer
  extraArgs:
    - --insecure  # For Azure App Gateway
redis-ha:
  enabled: true
controller:
  replicas: 1
EOF

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### Prometheus + Grafana Stack

```bash
# Add repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
helm install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --create-namespace \
  -f prometheus-values.yaml

# Example values
cat <<EOF > prometheus-values.yaml
prometheus:
  prometheusSpec:
    retention: 30d
    storageSpec:
      volumeClaimTemplate:
        spec:
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 50Gi
grafana:
  enabled: true
  adminPassword: "changeme"
  persistence:
    enabled: true
    size: 10Gi
alertmanager:
  enabled: true
EOF
```

### Cert-Manager

```bash
# Add repository
helm repo add jetstack https://charts.jetstack.io
helm repo update

# Install cert-manager with CRDs
helm install cert-manager jetstack/cert-manager \
  -n cert-manager \
  --create-namespace \
  --set installCRDs=true
```

### External Secrets Operator

```bash
# Add repository
helm repo add external-secrets https://charts.external-secrets.io
helm repo update

# Install operator
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets-system \
  --create-namespace
```

### NGINX Ingress Controller

```bash
# Add repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# Install for AKS
helm install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  --create-namespace \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz
```

---

## Best Practices

### 1. Always Use Named Releases

```bash
# ✅ Good - explicit name
helm install argocd argo/argo-cd -n argocd

# ❌ Bad - auto-generated name
helm install argo/argo-cd -n argocd
```

### 2. Pin Chart Versions

```bash
# ✅ Good - pinned version
helm install argocd argo/argo-cd --version 5.51.6 -n argocd

# ⚠️ Risky - latest version (may break)
helm install argocd argo/argo-cd -n argocd
```

### 3. Use Values Files

```bash
# ✅ Good - values file (version controlled)
helm install my-app repo/chart -f values.yaml

# ❌ Bad - inline values (hard to track)
helm install my-app repo/chart --set a=1 --set b=2 --set c=3
```

### 4. Dry-Run Before Installation

```bash
# Always test first
helm install my-release repo/chart -n namespace --dry-run --debug
```

### 5. Use Namespaces

```bash
# ✅ Good - isolated namespace
helm install argocd argo/argo-cd -n argocd --create-namespace

# ❌ Bad - default namespace
helm install argocd argo/argo-cd
```

### 6. Use helm template for GitOps

```bash
# Generate manifests for GitOps (ArgoCD, Flux)
helm template my-release repo/chart -f values.yaml > manifests.yaml

# Commit to Git
git add manifests.yaml
git commit -m "Add my-release manifests"
```

---

## Troubleshooting

### Failed Installation

```bash
# Check release status
helm status my-release -n namespace

# View installation logs
helm history my-release -n namespace

# Rollback if needed
helm rollback my-release -n namespace
```

### Chart Not Found

```bash
# Update repository index
helm repo update

# Search with full name
helm search repo prometheus-community/kube-prometheus-stack

# List all charts in repo
helm search repo prometheus-community
```

### Values Not Applied

```bash
# Verify values were applied
helm get values my-release -n namespace

# Compare with chart defaults
helm show values repo/chart-name

# Debug with dry-run
helm upgrade my-release repo/chart-name -f values.yaml --dry-run --debug
```

### Permission Errors

```bash
# Check Kubernetes context
kubectl config current-context

# Verify RBAC permissions
kubectl auth can-i create deployments -n namespace
```

---

## Integration with GitOps

### ArgoCD Pattern

**Don't use Helm directly** - let ArgoCD manage Helm releases:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://charts.example.com
    chart: my-chart
    targetRevision: 1.0.0
    helm:
      releaseName: my-release
      valueFiles:
        - values.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: my-namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

**When to use Helm directly:**
- Initial ArgoCD installation (bootstrap)
- Debugging/testing before GitOps
- Emergency fixes (then commit to Git)

---

## Security Considerations

### 1. Don't Store Secrets in Values

```bash
# ❌ Bad - secrets in values.yaml
helm install my-app repo/chart -f values.yaml  # Contains passwords

# ✅ Good - use External Secrets Operator
# Reference secrets from Azure Key Vault via ESO
```

### 2. Verify Chart Sources

```bash
# Only use trusted repositories
helm repo add bitnami https://charts.bitnami.com/bitnami  # ✅ Official
helm repo add random-repo https://random.com/charts       # ❌ Untrusted
```

### 3. Review Generated Manifests

```bash
# Always review before applying
helm template my-release repo/chart -f values.yaml | less

# Check for security issues
helm template my-release repo/chart | grep -i "privileged\|hostNetwork\|hostPath"
```

---

## Common Helm Values Patterns

### Resource Limits

```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### Persistence

```yaml
persistence:
  enabled: true
  storageClass: "managed-premium"
  size: 10Gi
  accessMode: ReadWriteOnce
```

### Service Configuration

```yaml
service:
  type: ClusterIP  # or LoadBalancer, NodePort
  port: 80
  annotations:
    service.beta.kubernetes.io/azure-load-balancer-internal: "true"
```

### Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: app-tls
      hosts:
        - app.example.com
```

---

## References

- [Helm Documentation](https://helm.sh/docs/)
- [Artifact Hub](https://artifacthub.io/) - Helm chart registry
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [ArgoCD Helm Integration](https://argo-cd.readthedocs.io/en/stable/user-guide/helm/)

---

**Skill Version:** 1.0.0  
**Last Updated:** 2026-02-02
