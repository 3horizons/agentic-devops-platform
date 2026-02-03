---
name: argocd-cli
description: ArgoCD CLI operations for GitOps workflows
version: "1.0.0"
license: MIT
tools_required: ["argocd"]
min_versions:
  argocd: "2.8.0"
---

## When to Use
- ArgoCD application management
- Sync status verification
- Application diff preview
- GitOps workflow operations

## Prerequisites
- ArgoCD CLI installed
- Authenticated to ArgoCD server
- Appropriate RBAC permissions

## Commands

### Authentication
```bash
# Login to ArgoCD
argocd login <ARGOCD_SERVER> --username admin --password <password>

# Current context
argocd context
```

### Application Operations
```bash
# List applications
argocd app list

# Get application status
argocd app get <app-name>

# Show application diff
argocd app diff <app-name>

# Sync application
argocd app sync <app-name>

# Sync with prune
argocd app sync <app-name> --prune
```

### Health & Status
```bash
# Application health
argocd app get <app-name> -o json | jq '.status.health.status'

# Sync status
argocd app get <app-name> -o json | jq '.status.sync.status'

# Resources status
argocd app resources <app-name>
```

## Best Practices
1. ALWAYS diff before sync
2. Use --prune carefully in production
3. Verify health after sync
4. Use projects for access control
5. Enable auto-sync only for non-prod environments

## Output Format
1. Command executed
2. Sync/health status
3. Any drift detected
4. Recommended actions

## Integration with Agents
Used by: @gitops, @devops, @validation
