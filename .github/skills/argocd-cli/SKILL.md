---
name: argocd-cli
description: 'ArgoCD CLI reference for GitOps continuous delivery. Use when asked to deploy apps, sync manifests, check sync status, configure repos, rollback deployments. Covers argocd app sync, argocd app get, argocd repo add, argocd proj create.'
license: Complete terms in LICENSE.txt
---

# ArgoCD CLI

USE FOR:
- `argocd` commands and GitOps operations
- Syncing applications (`argocd app sync`)
- Checking application status (`argocd app get`)
- Managing Git repositories (`argocd repo add`)
- Creating projects (`argocd proj create`)
- Rolling back deployments (`argocd app rollback`)
- Managing application sets and sync policies
- ArgoCD RBAC configuration

DO NOT USE FOR:
- Direct Kubernetes manifest application (use kubectl-cli)
- Helm chart management outside ArgoCD (use helm-cli)
- Flux-based GitOps workflows
- CI/CD pipeline execution (use github-cli)
- Infrastructure provisioning (use terraform-cli)

Comprehensive reference for ArgoCD CLI - declarative GitOps continuous delivery tool.

**Version:** 2.13+ (current as of 2026)

## Prerequisites

### Installation

```bash
# macOS
brew install argocd

# Linux
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Windows
choco install argocd-cli

# Verify
argocd version
```

### Authentication

```bash
# Login to ArgoCD server
argocd login argocd.example.com

# Login with SSO
argocd login argocd.example.com --sso

# Login with username/password
argocd login argocd.example.com --username admin --password $ARGOCD_PASSWORD

# Login insecure (self-signed cert)
argocd login argocd.example.com --insecure

# Login with gRPC-web (required for some load balancers)
argocd login argocd.example.com --grpc-web

# Get initial admin password (from Kubernetes)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Logout
argocd logout argocd.example.com

# Check current context
argocd context
```

## CLI Structure

```
argocd                      # Root command
├── app                     # Application management
├── appset                  # ApplicationSet management  
├── repo                    # Repository management
├── cluster                 # Cluster management
├── proj                    # Project management
├── account                 # Account management
├── cert                    # Certificate management
├── gpg                     # GPG key management
├── admin                   # Administrative commands
├── login                   # Login to server
├── logout                  # Logout
├── context                 # Context management
└── version                 # Version info
```

## Application Management

### Create Application

```bash
# Create from Git repository
argocd app create my-app \
  --repo https://github.com/org/repo.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-namespace

# Create with Helm
argocd app create my-app \
  --repo https://github.com/org/repo.git \
  --path helm-chart \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-namespace \
  --helm-set image.tag=v1.0.0

# Create with Kustomize
argocd app create my-app \
  --repo https://github.com/org/repo.git \
  --path overlays/prod \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-namespace

# Create in project
argocd app create my-app \
  --repo https://github.com/org/repo.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-namespace \
  --project my-project

# Create with revision
argocd app create my-app \
  --repo https://github.com/org/repo.git \
  --revision main \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-namespace

# Create with auto-sync
argocd app create my-app \
  --repo https://github.com/org/repo.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-namespace \
  --sync-policy automated \
  --auto-prune \
  --self-heal
```

### List Applications

```bash
# List all apps
argocd app list

# List in specific project
argocd app list --project my-project

# Output format
argocd app list -o wide
argocd app list -o json
argocd app list -o yaml
argocd app list -o name
```

### Get Application

```bash
# Get app details
argocd app get my-app

# Get with specific output
argocd app get my-app -o json
argocd app get my-app -o yaml

# Show resource tree
argocd app get my-app --show-params

# Get multiple apps
argocd app get my-app-1 my-app-2
```

### Sync Application

```bash
# Sync app
argocd app sync my-app

# Force sync
argocd app sync my-app --force

# Prune resources
argocd app sync my-app --prune

# Dry run
argocd app sync my-app --dry-run

# Sync specific resources
argocd app sync my-app --resource :Deployment:nginx

# Sync with specific revision
argocd app sync my-app --revision v1.0.0

# Async sync (don't wait)
argocd app sync my-app --async

# Replace resources
argocd app sync my-app --replace

# Retry on failure
argocd app sync my-app --retry-limit 3

# Sync local manifests
argocd app sync my-app --local ./manifests
```

### Wait for Application

```bash
# Wait for sync
argocd app wait my-app

# Wait for healthy
argocd app wait my-app --health

# Wait with timeout
argocd app wait my-app --timeout 300

# Wait for sync + health
argocd app wait my-app --sync --health
```

### Diff Application

```bash
# Show diff
argocd app diff my-app

# Local diff
argocd app diff my-app --local ./manifests

# Diff with specific revision
argocd app diff my-app --revision v1.0.0
```

### Delete Application

```bash
# Delete app
argocd app delete my-app

# Delete without confirmation
argocd app delete my-app -y

# Cascade delete (delete resources)
argocd app delete my-app --cascade

# Non-cascade (keep resources)
argocd app delete my-app --cascade=false
```

### Application History

```bash
# Show history
argocd app history my-app

# Rollback to revision
argocd app rollback my-app 1

# Rollback with prune
argocd app rollback my-app 1 --prune
```

### Set Application Properties

```bash
# Set parameter
argocd app set my-app -p image.tag=v2.0.0

# Set Helm values
argocd app set my-app --helm-set replicas=3

# Set Helm values file
argocd app set my-app --values values-prod.yaml

# Change destination namespace
argocd app set my-app --dest-namespace new-namespace

# Change target revision
argocd app set my-app --revision develop

# Enable auto-sync
argocd app set my-app --sync-policy automated

# Enable self-heal
argocd app set my-app --self-heal

# Enable auto-prune
argocd app set my-app --auto-prune
```

### Unset Application Properties

```bash
# Unset parameter
argocd app unset my-app -p image.tag

# Disable auto-sync
argocd app unset my-app --sync-policy

# Disable self-heal
argocd app unset my-app --self-heal

# Disable auto-prune
argocd app unset my-app --auto-prune
```

### Application Resources

```bash
# List resources
argocd app resources my-app

# Delete resource
argocd app delete-resource my-app --kind Deployment --name nginx

# Patch resource
argocd app patch-resource my-app \
  --kind Deployment \
  --name nginx \
  --patch '{"spec":{"replicas":5}}'

# Get resource manifests
argocd app manifests my-app

# Get live manifests
argocd app manifests my-app --source live

# Terminate operation
argocd app terminate-op my-app
```

### Application Actions

```bash
# List actions
argocd app actions list my-app

# Run action
argocd app actions run my-app restart --kind Deployment --name nginx
```

## ApplicationSets

### List ApplicationSets

```bash
# List all appsets
argocd appset list

# Output format
argocd appset list -o json
argocd appset list -o yaml
```

### Get ApplicationSet

```bash
# Get appset
argocd appset get my-appset

# Output format
argocd appset get my-appset -o json
```

### Create ApplicationSet

```bash
# Create from file
argocd appset create -f appset.yaml
```

### Delete ApplicationSet

```bash
# Delete appset
argocd appset delete my-appset

# Without confirmation
argocd appset delete my-appset -y
```

## Repository Management

### Add Repository

```bash
# Add HTTPS repo
argocd repo add https://github.com/org/repo.git

# Add with credentials
argocd repo add https://github.com/org/repo.git \
  --username myuser \
  --password mypassword

# Add with personal access token
argocd repo add https://github.com/org/repo.git \
  --username x-access-token \
  --password $GITHUB_TOKEN

# Add SSH repo
argocd repo add git@github.com:org/repo.git \
  --ssh-private-key-path ~/.ssh/id_rsa

# Add with TLS client cert
argocd repo add https://github.com/org/repo.git \
  --tls-client-cert-path /path/to/cert \
  --tls-client-cert-key-path /path/to/key

# Add Helm repository
argocd repo add https://charts.example.com \
  --type helm \
  --name my-charts

# Add OCI Helm repository
argocd repo add oci://ghcr.io/org \
  --type helm \
  --name my-oci-charts \
  --enable-oci
```

### List Repositories

```bash
# List repos
argocd repo list

# Output format
argocd repo list -o json
argocd repo list -o yaml
```

### Get Repository

```bash
# Get repo details
argocd repo get https://github.com/org/repo.git
```

### Remove Repository

```bash
# Remove repo
argocd repo rm https://github.com/org/repo.git
```

## Cluster Management

### Add Cluster

```bash
# Add cluster (uses current kubeconfig context)
argocd cluster add my-cluster-context

# Add with name
argocd cluster add my-cluster-context --name my-cluster

# Add in-cluster
argocd cluster add https://kubernetes.default.svc

# Add with service account
argocd cluster add my-cluster-context --service-account argocd-manager
```

### List Clusters

```bash
# List clusters
argocd cluster list

# Output format
argocd cluster list -o json
argocd cluster list -o yaml
```

### Get Cluster

```bash
# Get cluster details
argocd cluster get https://kubernetes.default.svc
argocd cluster get my-cluster
```

### Remove Cluster

```bash
# Remove cluster
argocd cluster rm https://my-cluster-api:6443
```

### Rotate Credentials

```bash
# Rotate cluster credentials
argocd cluster rotate-auth https://my-cluster-api:6443
```

## Project Management

### Create Project

```bash
# Create project
argocd proj create my-project

# Create with description
argocd proj create my-project --description "My Project"

# Create with source repos
argocd proj create my-project \
  --src https://github.com/org/repo1.git \
  --src https://github.com/org/repo2.git

# Create with destinations
argocd proj create my-project \
  --dest https://kubernetes.default.svc,my-namespace \
  --dest https://kubernetes.default.svc,another-namespace

# Create from file
argocd proj create -f project.yaml
```

### List Projects

```bash
# List projects
argocd proj list

# Output format
argocd proj list -o json
argocd proj list -o yaml
```

### Get Project

```bash
# Get project details
argocd proj get my-project
```

### Edit Project

```bash
# Add source repo
argocd proj add-source my-project https://github.com/org/repo.git

# Remove source repo
argocd proj remove-source my-project https://github.com/org/repo.git

# Add destination
argocd proj add-destination my-project https://kubernetes.default.svc my-namespace

# Remove destination
argocd proj remove-destination my-project https://kubernetes.default.svc my-namespace

# Allow cluster resource
argocd proj allow-cluster-resource my-project '*' '*'

# Deny cluster resource
argocd proj deny-cluster-resource my-project '' ClusterRole

# Allow namespace resource
argocd proj allow-namespace-resource my-project '*' '*'

# Add role
argocd proj role add my-project developer

# Remove role
argocd proj role delete my-project developer

# Add role policy
argocd proj role add-policy my-project developer \
  -a get \
  -p allow \
  -o my-app

# Create role token
argocd proj role create-token my-project developer
```

### Delete Project

```bash
# Delete project
argocd proj delete my-project
```

## Account Management

### Account Commands

```bash
# List accounts
argocd account list

# Get account
argocd account get admin

# Get current user
argocd account get-user-info

# Update password
argocd account update-password

# Generate token
argocd account generate-token --account admin

# Delete token
argocd account delete-token admin token-id

# Can I?
argocd account can-i get applications '*'
argocd account can-i sync applications 'my-app'
```

## Admin Commands

### Settings

```bash
# Get settings
argocd admin settings resource-overrides list
argocd admin settings rbac validate
```

### Cluster Operations

```bash
# Generate cluster config
argocd admin cluster generate-spec

# Statistics
argocd admin cluster stats
```

### App Operations

```bash
# Validate app
argocd admin app generate-spec ./manifests

# Get app diff stats
argocd admin app diff-reconcile-results
```

### Export/Import

```bash
# Export all
argocd admin export > backup.yaml

# Import
argocd admin import < backup.yaml
```

### Initial Password

```bash
# Get initial password
argocd admin initial-password

# Reset admin password
argocd admin initial-password reset
```

## Certificate Management

```bash
# List certificates
argocd cert list

# Add TLS certificate
argocd cert add-tls my-server.com --from /path/to/cert.pem

# Add SSH known hosts
argocd cert add-ssh --batch <<EOF
github.com ssh-rsa AAAAB3...
EOF

# Remove certificate
argocd cert rm my-server.com
```

## Context Management

```bash
# List contexts
argocd context

# Switch context
argocd context my-context

# Delete context
argocd context --delete my-context
```

## Common Workflows

### Deploy New Application

```bash
# 1. Add repository
argocd repo add https://github.com/org/repo.git \
  --username x-access-token \
  --password $GITHUB_TOKEN

# 2. Create project
argocd proj create my-project \
  --src https://github.com/org/repo.git \
  --dest https://kubernetes.default.svc,my-namespace

# 3. Create application
argocd app create my-app \
  --repo https://github.com/org/repo.git \
  --path manifests \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace my-namespace \
  --project my-project \
  --sync-policy automated \
  --auto-prune \
  --self-heal

# 4. Verify sync
argocd app wait my-app --sync --health
```

### Promote to Production

```bash
# 1. Sync with new revision
argocd app sync my-app-prod --revision v2.0.0

# 2. Wait for healthy
argocd app wait my-app-prod --health --timeout 300

# 3. Verify
argocd app get my-app-prod
```

### Rollback Application

```bash
# 1. Check history
argocd app history my-app

# 2. Rollback to previous revision
argocd app rollback my-app 2

# 3. Verify
argocd app wait my-app --sync --health
```

### Debug Sync Issues

```bash
# 1. Check app status
argocd app get my-app

# 2. Check diff
argocd app diff my-app

# 3. Check resources
argocd app resources my-app

# 4. Force sync if needed
argocd app sync my-app --force --prune

# 5. Check events
kubectl -n argocd logs -l app.kubernetes.io/name=argocd-application-controller
```

## Sync Policies

### Automated Sync

```yaml
# Application with auto-sync
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
spec:
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
```

### Sync Waves

```yaml
# Resource with sync wave
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-1"  # Deploy first
```

### Sync Hooks

```yaml
# Pre-sync hook
metadata:
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
```

## Best Practices

1. **Use Projects**: Organize apps into projects for access control
2. **Enable auto-sync**: Use automated sync with self-heal and prune
3. **Use sync waves**: Order deployments with annotations
4. **Health checks**: Define custom health checks for CRDs
5. **RBAC**: Use project roles for team access
6. **Declarative setup**: Store app definitions in Git (App of Apps pattern)
7. **Secrets management**: Use External Secrets or Sealed Secrets
8. **Multi-cluster**: Use ApplicationSets for multi-cluster deployments
9. **Monitoring**: Monitor sync status with Prometheus metrics
10. **Backup**: Regularly export ArgoCD configuration

## References

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD CLI Reference](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/)
- [ApplicationSet Documentation](https://argo-cd.readthedocs.io/en/stable/user-guide/application-set/)
