# RHDH Helm Configuration (AKS Dev)

This folder is the source of truth for RHDH RBAC and app configuration used in AKS dev deployments.

## Files

- `values-aks-dev.yaml`: RHDH Helm values (auth, permissions, plugins, catalog, branding)
- `rbac-policies-configmap.yaml`: File-based RBAC policies (`rbac-policies.csv`)

## Important RBAC Behavior

RHDH roles loaded from `rbac-policies.csv` are configuration-managed.

- You can view them in the RBAC UI.
- Editing those roles in UI is blocked by design.
- To change role permissions or user/group mapping, edit `rbac-policies-configmap.yaml`.

If RBAC UI shows `source does not match originating role ... CONFIGURATION`, update this file instead of using UI edit.

## Apply Changes

1. Apply RBAC ConfigMap:

```bash
kubectl apply -f deploy/helm/rhdh/rbac-policies-configmap.yaml
```

1. Apply updated RHDH values through your Helm/GitOps flow.

2. Restart RHDH deployment if needed to refresh loaded configuration:

```bash
kubectl -n rhdh rollout restart deploy/rhdh-developer-hub
kubectl -n rhdh rollout status deploy/rhdh-developer-hub --timeout=300s
```
