# Three Horizons Accelerator - Deployment Manifests

> **Version:** 4.0.0
> **Last Updated:** December 2025
> **Audience:** DevOps Engineers, Platform Engineers

## Overview

This directory contains Helm values and deployment configurations used to install platform services on AKS/ARO clusters.

## Structure

```text
deploy/
└── helm/
    ├── argocd/       # ArgoCD Helm values
    └── monitoring/   # Prometheus / Grafana Helm values
```

## Usage

Helm values are consumed by ArgoCD applications or applied manually:

```bash
# Example: install ArgoCD
helm upgrade --install argocd argo/argo-cd \
  -n argocd --create-namespace \
  -f deploy/helm/argocd/values.yaml

# Example: install monitoring stack
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f deploy/helm/monitoring/values.yaml
```

## 📚 Related Documentation

| Document | Description |
|----------|-------------|
| [Deployment Guide](../docs/guides/DEPLOYMENT_GUIDE.md) | Step-by-step platform deployment |
| [ArgoCD Configuration](../argocd/README.md) | GitOps application definitions |
| [Architecture Guide](../docs/guides/ARCHITECTURE_GUIDE.md) | Platform architecture overview |

---

**Document Version:** 2.0.0
**Last Updated:** December 2025
**Maintainer:** Platform Engineering Team
