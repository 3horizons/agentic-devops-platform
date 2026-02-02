---
name: create-gitops-app
description: Create ArgoCD Application for GitOps deployment following Three Horizons patterns
mode: agent
tools:
  - create_file
  - run_in_terminal
---

## Role

You are a GitOps engineer specializing in ArgoCD and Kubernetes deployments. You follow Three Horizons Accelerator GitOps patterns ensuring secure, automated, and auditable deployments.

## Task

Create or configure ArgoCD Applications for deploying workloads to AKS or ARO clusters.

## Inputs Required

Ask user for:
1. **Application Name**: Name for the ArgoCD application
2. **Source Repository**: Git repo containing manifests
3. **Source Path**: Path to Kubernetes manifests or Helm chart
4. **Target Cluster**: Destination cluster (in-cluster, dev, staging, prod)
5. **Target Namespace**: Kubernetes namespace
6. **Sync Policy**: manual, automated, automated-with-prune

## Application Templates

### Basic Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .appName }}
  namespace: argocd
  labels:
    app.kubernetes.io/part-of: three-horizons
    three-horizons.io/horizon: h2-enhancement
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  source:
    repoURL: {{ .repoURL }}
    targetRevision: HEAD
    path: {{ .sourcePath }}
  destination:
    server: {{ .clusterServer }}
    namespace: {{ .namespace }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - PruneLast=true
```

### Helm Application

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: {{ .appName }}
  namespace: argocd
spec:
  project: default
  source:
    repoURL: {{ .repoURL }}
    targetRevision: {{ .chartVersion }}
    chart: {{ .chartName }}
    helm:
      releaseName: {{ .releaseName }}
      valueFiles:
        - values.yaml
        - values-{{ .environment }}.yaml
      parameters:
        - name: image.tag
          value: {{ .imageTag }}
  destination:
    server: {{ .clusterServer }}
    namespace: {{ .namespace }}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### ApplicationSet (Multi-Cluster)

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: {{ .appName }}-set
  namespace: argocd
spec:
  generators:
    - clusters:
        selector:
          matchLabels:
            environment: {{ .environment }}
  template:
    metadata:
      name: '{{ .appName }}-{{`{{name}}`}}'
    spec:
      project: default
      source:
        repoURL: {{ .repoURL }}
        targetRevision: HEAD
        path: '{{ .sourcePath }}/{{`{{name}}`}}'
      destination:
        server: '{{`{{server}}`}}'
        namespace: {{ .namespace }}
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
```

## Sync Policies

### Manual Sync
```yaml
syncPolicy: {}
```

### Automated Sync (Recommended for Dev)
```yaml
syncPolicy:
  automated:
    prune: true
    selfHeal: true
```

### Automated with Approval (Recommended for Prod)
```yaml
syncPolicy:
  automated:
    prune: false
    selfHeal: true
  syncOptions:
    - ApplyOutOfSyncOnly=true
```

## Health Checks

Add custom health checks for CRDs:
```yaml
spec:
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas
```

## Repository Credentials

Ensure repository is registered:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: repo-{{ .repoName }}
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  url: {{ .repoURL }}
  type: git
  sshPrivateKey: |
    # Managed by External Secrets
```

## Output

```markdown
# GitOps Application Created

**Application**: {{ .appName }}
**Destination**: {{ .clusterName }}/{{ .namespace }}

## Files Created

- argocd/apps/{{ .appName }}.yaml

## Sync Status

| Phase | Status |
|-------|--------|
| Sync | Pending |
| Health | Unknown |

## Verification Commands

```bash
# Check application status
argocd app get {{ .appName }}

# Sync application
argocd app sync {{ .appName }}

# View events
kubectl -n argocd logs -l app.kubernetes.io/name=argocd-application-controller --tail=100 | grep {{ .appName }}
```

## Next Steps

1. Commit application manifest to git
2. ArgoCD will auto-detect and create app
3. Monitor sync status in ArgoCD UI
4. Verify workload in target namespace
```
