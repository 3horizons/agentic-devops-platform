# Secret Management

The Three Horizons platform uses **Azure Key Vault** as the single source of truth for all secrets, with **External Secrets Operator (ESO)** synchronizing vault entries to Kubernetes. No static secrets are stored in code, environment variables, or Git repositories.

---

## Architecture

```
Azure Key Vault (source of truth)
        |
        | Workload Identity (OIDC federation)
        v
External Secrets Operator (ESO 0.9.9)
        |
        v
ClusterSecretStore (cluster-wide Key Vault connection)
        |
        v
ExternalSecret (per-namespace declarative mapping)
        |
        v
Kubernetes Secret (auto-synced, auto-refreshed)
        |
        v
Application Pod (mounted as volume or env var)
```

Key principles:

- **No static credentials anywhere** -- Workload Identity for all authentication
- **Single source of truth** -- Azure Key Vault holds all secrets
- **Declarative sync** -- ExternalSecret resources define what to sync
- **Automatic refresh** -- ESO polls Key Vault at configurable intervals
- **Audit trail** -- Key Vault access logs track every secret read

---

## Azure Key Vault Configuration

Key Vault is provisioned by the `security` Terraform module with these settings:

| Setting | Value | Notes |
|---------|-------|-------|
| Access model | RBAC-based | No legacy access policies |
| Soft delete | Enabled, 90-day retention | Cannot be disabled |
| Purge protection | Enabled | Cannot be disabled after creation |
| Network access | Private endpoint only | No public access |
| TLS | 1.2+ enforced | All API calls |
| SKU | Standard | Premium for HSM-backed keys |

### Terraform Configuration

```hcl
resource "azurerm_key_vault" "main" {
  name                          = "${var.naming_prefix}-kv"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = {
    environment = var.environment
    project     = var.project_name
    owner       = var.owner
    cost-center = var.cost_center
  }
}
```

### Secret Naming Convention

Secrets are organized with a consistent naming convention:

```
<environment>-<service>-<secret-name>
```

| Example | Purpose |
|---------|---------|
| `dev-rhdh-database-password` | RHDH PostgreSQL password in dev |
| `prod-argocd-github-token` | ArgoCD GitHub token in production |
| `staging-redis-connection-string` | Redis connection string in staging |
| `prod-ai-foundry-api-key` | Azure AI Foundry API key in production |
| `prod-backend-auth-secret` | RHDH backend authentication secret |
| `prod-github-app-client-secret` | GitHub App OAuth client secret |

### Creating Secrets in Key Vault

```bash
# Create a secret
az keyvault secret set \
  --vault-name "${VAULT_NAME}" \
  --name "prod-myservice-database-password" \
  --value "${PASSWORD}" \
  --tags environment=prod service=myservice

# List secrets (names only, never values)
az keyvault secret list --vault-name "${VAULT_NAME}" --output table

# Verify a secret exists (do NOT output the value)
az keyvault secret show \
  --vault-name "${VAULT_NAME}" \
  --name "prod-myservice-database-password" \
  --query "name" --output tsv
```

---

## External Secrets Operator (ESO)

ESO runs in the `external-secrets` namespace and authenticates to Azure Key Vault using Workload Identity (no static credentials). It is deployed by the `external-secrets` Terraform module via Helm chart version 0.9.9.

### ESO Components

| Component | Namespace | Purpose |
|-----------|-----------|---------|
| ESO Controller | `external-secrets` | Reconciles ExternalSecret resources |
| Webhook | `external-secrets` | Validates ExternalSecret and SecretStore CRDs |
| Cert Controller | `external-secrets` | Manages webhook TLS certificates |
| Service Account | `external-secrets` | Workload Identity for Key Vault auth |

### ClusterSecretStore

A single ClusterSecretStore connects ESO to Key Vault across all namespaces:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: azure-key-vault
spec:
  provider:
    azurekv:
      authType: WorkloadIdentity
      vaultUrl: https://<vault-name>.vault.azure.net
      serviceAccountRef:
        name: external-secrets-sa
        namespace: external-secrets
```

The ClusterSecretStore is defined in `argocd/secrets/cluster-secret-store.yaml` and deployed via ArgoCD.

### Verifying ClusterSecretStore Health

```bash
# Check store status
kubectl get clustersecretstore azure-key-vault

# Expected output:
# NAME               AGE   STATUS   CAPABILITIES   READY
# azure-key-vault    10d   Valid    ReadWrite       True
```

---

## Using ExternalSecrets

### Creating an ExternalSecret

Each application defines ExternalSecret resources to pull specific secrets from Key Vault:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-credentials
  namespace: my-service
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: azure-key-vault
    kind: ClusterSecretStore
  target:
    name: database-credentials
    creationPolicy: Owner
  data:
    - secretKey: DB_HOST
      remoteRef:
        key: prod-myservice-database-host
    - secretKey: DB_PASSWORD
      remoteRef:
        key: prod-myservice-database-password
    - secretKey: DB_NAME
      remoteRef:
        key: prod-myservice-database-name
```

### Using Synced Secrets in Pods

**As environment variables:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-service
spec:
  template:
    spec:
      containers:
        - name: my-service
          envFrom:
            - secretRef:
                name: database-credentials
```

**As mounted volumes (preferred for rotation):**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-service
spec:
  template:
    spec:
      containers:
        - name: my-service
          volumeMounts:
            - name: secrets
              mountPath: /etc/secrets
              readOnly: true
      volumes:
        - name: secrets
          secret:
            secretName: database-credentials
```

Volume-mounted secrets automatically update when ESO refreshes the secret. Environment variables require a pod restart.

### Template Secrets

ESO supports template syntax for constructing complex secret values:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: database-url
  namespace: my-service
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: azure-key-vault
    kind: ClusterSecretStore
  target:
    name: database-url
    template:
      data:
        DATABASE_URL: "postgresql://{{ .user }}:{{ .password }}@{{ .host }}:5432/{{ .dbname }}?sslmode=require"
  data:
    - secretKey: user
      remoteRef:
        key: prod-myservice-database-user
    - secretKey: password
      remoteRef:
        key: prod-myservice-database-password
    - secretKey: host
      remoteRef:
        key: prod-myservice-database-host
    - secretKey: dbname
      remoteRef:
        key: prod-myservice-database-name
```

---

## Secret Rotation

### Automatic Refresh

- ESO polls Key Vault at the configured `refreshInterval` (default: 1 hour)
- When a secret is updated in Key Vault, ESO updates the corresponding Kubernetes Secret
- Volume-mounted secrets are automatically updated by the kubelet
- Environment variable-based secrets require a pod restart (use a deployment rollout)

### Rotation Strategy

| Secret Type | Rotation Period | Method |
|-------------|----------------|--------|
| Database passwords | 90 days | Update in Key Vault, ESO auto-syncs |
| API keys | 90 days | Update in Key Vault, ESO auto-syncs |
| GitHub tokens | 1 year | Regenerate in GitHub App settings |
| TLS certificates | Auto-renewed | cert-manager handles renewal |
| Session secrets | 180 days | Update in Key Vault, restart RHDH pods |

### Rotation Procedure

1. Generate a new secret value
2. Update the secret in Azure Key Vault
3. Wait for ESO refresh interval (or trigger manual sync)
4. Verify the Kubernetes Secret is updated
5. If using environment variables, perform a rolling restart

```bash
# Update a secret in Key Vault
az keyvault secret set \
  --vault-name "${VAULT_NAME}" \
  --name "prod-myservice-database-password" \
  --value "${NEW_PASSWORD}"

# Force ESO to refresh immediately
kubectl annotate externalsecret database-credentials \
  -n my-service \
  force-sync=$(date +%s) --overwrite

# Verify the Kubernetes Secret was updated
kubectl get secret database-credentials -n my-service -o jsonpath='{.metadata.resourceVersion}'

# Rolling restart (if using env vars)
kubectl rollout restart deployment/my-service -n my-service
```

---

## Secret Detection and Prevention

Multiple layers prevent secrets from entering the codebase:

### Pre-Commit Hooks

Two pre-commit hooks scan staged files before every commit:

**detect-secrets:**

```yaml
# In .pre-commit-config.yaml
- repo: https://github.com/Yelp/detect-secrets
  hooks:
    - id: detect-secrets
      args: ['--baseline', '.secrets.baseline']
```

The `.secrets.baseline` file tracks known false positives with 13+ detectors configured (AWS, Azure, GitHub, Slack, generic high-entropy strings, etc.).

**gitleaks:**

```yaml
- repo: https://github.com/gitleaks/gitleaks
  hooks:
    - id: gitleaks
```

### CI Pipeline Scanning

- **GHAS Secret Scanning**: Runs on every push and PR, detects 200+ token patterns
- **Push Protection**: Blocks pushes containing detected secrets before they reach the remote repository

### Setting Up Pre-Commit Hooks

```bash
# Install and configure all pre-commit hooks
./scripts/setup-pre-commit.sh --install-tools

# Run hooks manually
pre-commit run detect-secrets --all-files
pre-commit run gitleaks --all-files
```

---

## Prohibited Practices

The following are explicitly forbidden by platform policy:

| Practice | Why It Is Forbidden | Alternative |
|----------|-------------------|-------------|
| Secrets in Git repos | Permanent exposure risk | Use Azure Key Vault + ESO |
| Hardcoded secrets in code | Visible in source control | Use ExternalSecret resources |
| Secrets in Dockerfiles | Baked into image layers | Mount as volumes at runtime |
| `kubectl get secret -o yaml` | Outputs base64-encoded values to terminal | Use ESO to manage secrets declaratively |
| `az keyvault secret show --query value` | Outputs raw secret value to logs | Verify existence with `--query name` only |
| Service principal secrets | Static credentials with expiry | Use Workload Identity instead |
| Secrets in environment variables in CI | May leak in logs | Use OIDC federation for Azure, `${{ secrets.* }}` for GitHub |

---

## Platform Secrets Reference

These are the secrets stored in Key Vault for core platform services:

| Secret Name Pattern | Used By | Purpose |
|--------------------|---------|---------|
| `*-backend-auth-secret` | RHDH | Backend plugin authentication |
| `*-auth-session-secret` | RHDH | User session encryption |
| `*-github-app-client-id` | RHDH | GitHub OAuth client ID |
| `*-github-app-client-secret` | RHDH | GitHub OAuth client secret |
| `*-postgres-password` | RHDH, services | PostgreSQL connection password |
| `*-redis-connection-string` | Services | Redis connection string |
| `*-argocd-github-token` | ArgoCD | GitHub repo access |
| `*-ai-foundry-api-key` | Lightspeed | Azure AI Foundry API key |
| `*-grafana-admin-password` | Grafana | Admin dashboard access |

---

## Troubleshooting

### Common Issues

| Symptom | Cause | Resolution |
|---------|-------|------------|
| ExternalSecret shows `SecretSyncedError` | Key Vault secret does not exist | Verify secret name in Key Vault |
| ExternalSecret shows `Unauthorized` | Workload Identity not configured | Check service account annotations |
| ClusterSecretStore shows `InvalidConfig` | Wrong vault URL or auth config | Verify `vaultUrl` and `serviceAccountRef` |
| Secret not updating after Key Vault change | Refresh interval not elapsed | Wait for interval or force sync |
| Pod cannot read mounted secret | Incorrect volume mount path | Check `volumeMounts` and `volumes` configuration |

### Diagnostic Commands

```bash
# Check ExternalSecret status
kubectl describe externalsecret <name> -n <namespace>

# Verify ClusterSecretStore health
kubectl get clustersecretstore

# Check if Key Vault secret exists
az keyvault secret list --vault-name <vault> --query "[].name" -o tsv

# View ESO controller logs
kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets

# Check ESO webhook logs
kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets-webhook

# Verify Workload Identity configuration
kubectl get serviceaccount external-secrets-sa -n external-secrets -o yaml
```
