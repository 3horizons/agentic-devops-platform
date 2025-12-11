# Identity Federation Agent

## 🤖 Agent Identity

```yaml
name: identity-federation-agent
version: 1.0.0
horizon: Cross-Cutting
description: |
  Creates and manages identity federation between Azure and GitHub.
  Configures Workload Identity, Federated Credentials, Service Principals,
  OIDC trust relationships, and RBAC assignments for secure CI/CD.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 📋 Related Resources

| Resource Type | Path |
|--------------|------|
| Issue Template | `.github/ISSUE_TEMPLATE/infrastructure.yml` |
| Security Module | `terraform/modules/security/main.tf` |
| Bootstrap Script | `scripts/bootstrap.sh` |
| MCP Servers | `mcp-servers/mcp-config.json` (entra, github) |

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Create Service Principal** | App registration + SP for GitHub | Medium |
| **Configure Federated Credentials** | OIDC trust GitHub → Azure | High |
| **Assign RBAC** | Role assignments on Resource Groups | Medium |
| **Create GitHub App** | GitHub App for Actions auth | High |
| **Configure Workload Identity** | AKS pod identity federation | High |
| **Setup Managed Identity** | User-assigned managed identity | Low |
| **Create GitHub Secrets** | Store Azure credentials in GitHub | Low |

---

## 🔧 MCP Servers Required

```json
{
  "entra": {
    "capabilities": ["az ad app", "az ad sp", "az role assignment"]
  },
  "github": {
    "capabilities": ["gh secret", "gh api", "gh app"]
  },
  "azure": {
    "capabilities": ["az identity", "az aks"]
  }
}
```

---

## 🛠️ Implementation

### 1. Create App Registration for GitHub Actions

```bash
# Create App Registration
APP_NAME="${PROJECT_NAME}-github-actions"
APP_ID=$(az ad app create \
  --display-name "${APP_NAME}" \
  --sign-in-audience "AzureADMyOrg" \
  --query appId -o tsv)

echo "Created App Registration: ${APP_ID}"

# Create Service Principal
az ad sp create --id ${APP_ID}

# Get Service Principal Object ID
SP_OBJECT_ID=$(az ad sp show --id ${APP_ID} --query id -o tsv)
```

### 2. Configure Federated Credentials (OIDC)

```bash
# Federated credential for main branch
cat > federated-credential-main.json << EOF
{
  "name": "github-actions-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${GITHUB_ORG}/${GITHUB_REPO}:ref:refs/heads/main",
  "description": "GitHub Actions - main branch",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

az ad app federated-credential create \
  --id ${APP_ID} \
  --parameters federated-credential-main.json

# Federated credential for pull requests
cat > federated-credential-pr.json << EOF
{
  "name": "github-actions-pr",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${GITHUB_ORG}/${GITHUB_REPO}:pull_request",
  "description": "GitHub Actions - Pull Requests",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

az ad app federated-credential create \
  --id ${APP_ID} \
  --parameters federated-credential-pr.json

# Federated credential for environments
for ENV in dev staging prod; do
  cat > federated-credential-${ENV}.json << EOF
{
  "name": "github-actions-${ENV}",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${GITHUB_ORG}/${GITHUB_REPO}:environment:${ENV}",
  "description": "GitHub Actions - ${ENV} environment",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

  az ad app federated-credential create \
    --id ${APP_ID} \
    --parameters federated-credential-${ENV}.json
done
```

### 3. Assign RBAC Roles

```bash
# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Assign Contributor role on Resource Group
az role assignment create \
  --assignee ${APP_ID} \
  --role "Contributor" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"

# Assign AKS Cluster Admin (if needed)
az role assignment create \
  --assignee ${APP_ID} \
  --role "Azure Kubernetes Service Cluster Admin Role" \
  --scope "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"

# Assign ACR Push (for container builds)
ACR_ID=$(az acr show --name ${ACR_NAME} --query id -o tsv)
az role assignment create \
  --assignee ${APP_ID} \
  --role "AcrPush" \
  --scope ${ACR_ID}

# Assign Key Vault access
KV_ID=$(az keyvault show --name ${KV_NAME} --query id -o tsv)
az role assignment create \
  --assignee ${APP_ID} \
  --role "Key Vault Secrets User" \
  --scope ${KV_ID}
```

### 4. Create GitHub Secrets (OIDC method - no secrets!)

```bash
# Store Azure identifiers in GitHub (these are NOT secrets, just IDs)
gh secret set AZURE_CLIENT_ID --body "${APP_ID}" --repo ${GITHUB_ORG}/${GITHUB_REPO}
gh secret set AZURE_TENANT_ID --body "$(az account show --query tenantId -o tsv)" --repo ${GITHUB_ORG}/${GITHUB_REPO}
gh secret set AZURE_SUBSCRIPTION_ID --body "${SUBSCRIPTION_ID}" --repo ${GITHUB_ORG}/${GITHUB_REPO}

# Note: No AZURE_CLIENT_SECRET needed with OIDC!
```

### 5. GitHub Actions Workflow for OIDC Auth

```yaml
# .github/workflows/deploy.yml
name: Deploy to Azure

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  id-token: write   # Required for OIDC
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ github.ref == 'refs/heads/main' && 'prod' || 'dev' }}
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login (OIDC)
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Deploy Infrastructure
        run: |
          cd terraform
          terraform init
          terraform apply -auto-approve
```

---

## 🔒 AKS Workload Identity Configuration

### Create User-Assigned Managed Identity

```bash
# Create managed identity for AKS workloads
az identity create \
  --name "${APP_NAME}-workload-identity" \
  --resource-group ${RESOURCE_GROUP} \
  --location ${LOCATION}

# Get identity details
IDENTITY_CLIENT_ID=$(az identity show \
  --name "${APP_NAME}-workload-identity" \
  --resource-group ${RESOURCE_GROUP} \
  --query clientId -o tsv)

IDENTITY_OBJECT_ID=$(az identity show \
  --name "${APP_NAME}-workload-identity" \
  --resource-group ${RESOURCE_GROUP} \
  --query principalId -o tsv)
```

### Configure AKS Workload Identity

```bash
# Enable workload identity on AKS (if not already)
az aks update \
  --resource-group ${RESOURCE_GROUP} \
  --name ${AKS_NAME} \
  --enable-oidc-issuer \
  --enable-workload-identity

# Get AKS OIDC issuer URL
AKS_OIDC_ISSUER=$(az aks show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${AKS_NAME} \
  --query "oidcIssuerProfile.issuerUrl" -o tsv)

# Create federated credential for Kubernetes Service Account
cat > federated-credential-k8s.json << EOF
{
  "name": "kubernetes-workload",
  "issuer": "${AKS_OIDC_ISSUER}",
  "subject": "system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}",
  "description": "AKS Workload Identity",
  "audiences": ["api://AzureADTokenExchange"]
}
EOF

# Create the credential on the managed identity
az identity federated-credential create \
  --name "kubernetes-workload" \
  --identity-name "${APP_NAME}-workload-identity" \
  --resource-group ${RESOURCE_GROUP} \
  --issuer ${AKS_OIDC_ISSUER} \
  --subject "system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}" \
  --audiences "api://AzureADTokenExchange"
```

### Create Kubernetes Service Account

```yaml
# k8s/service-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: ${NAMESPACE}
  annotations:
    azure.workload.identity/client-id: ${IDENTITY_CLIENT_ID}
  labels:
    azure.workload.identity/use: "true"
```

---

## 📊 Validation Checklist

```bash
#!/bin/bash
# validate-identity-federation.sh

echo "=== Identity Federation Validation ==="

# Check App Registration exists
echo -n "App Registration: "
az ad app show --id ${APP_ID} &>/dev/null && echo "✅" || echo "❌"

# Check Service Principal exists
echo -n "Service Principal: "
az ad sp show --id ${APP_ID} &>/dev/null && echo "✅" || echo "❌"

# Check Federated Credentials
echo -n "Federated Credentials: "
FC_COUNT=$(az ad app federated-credential list --id ${APP_ID} --query "length(@)" -o tsv)
[[ $FC_COUNT -gt 0 ]] && echo "✅ (${FC_COUNT} configured)" || echo "❌"

# Check RBAC assignments
echo -n "RBAC Assignments: "
ROLE_COUNT=$(az role assignment list --assignee ${APP_ID} --query "length(@)" -o tsv)
[[ $ROLE_COUNT -gt 0 ]] && echo "✅ (${ROLE_COUNT} roles)" || echo "❌"

# Check GitHub secrets
echo -n "GitHub Secrets: "
gh secret list --repo ${GITHUB_ORG}/${GITHUB_REPO} | grep -q "AZURE_CLIENT_ID" && echo "✅" || echo "❌"

# Test OIDC authentication
echo -n "OIDC Auth Test: "
# This would be tested in GitHub Actions
echo "⏳ (test in workflow)"
```

---

## 📋 Issue Template Integration

When user creates issue with identity/federation label:

1. **Collect inputs:**
   - GitHub Organization
   - GitHub Repository  
   - Azure Resource Group
   - Required RBAC roles
   - Environments (dev/staging/prod)

2. **Execute federation setup:**
   - Create App Registration
   - Configure Federated Credentials
   - Assign RBAC roles
   - Store GitHub secrets

3. **Generate workflow:**
   - Create OIDC-enabled workflow
   - Configure environment protection rules

---

## 🔗 Dependencies

| Agent | Purpose |
|-------|---------|
| `infrastructure-agent` | Creates Resource Groups, AKS |
| `security-agent` | Key Vault, RBAC policies |
| `github-runners-agent` | Consumes federated identity |
| `gitops-agent` | Uses identity for ArgoCD |
