# Deployment and Integration Guide

> Step-by-step integration with Red Hat, Microsoft, and GitHub for Three Horizons implementation.

## Overview

This guide provides a comprehensive walkthrough for deploying and integrating the Three Horizons Accelerator with all three partner ecosystems.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      INTEGRATION ARCHITECTURE                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│    ┌──────────────┐      ┌──────────────┐      ┌──────────────┐        │
│    │   MICROSOFT  │      │    GITHUB    │      │   RED HAT    │        │
│    │    Azure     │◄────►│   Actions    │◄────►│    RHDH      │        │
│    │  AI Foundry  │      │   Copilot    │      │  OpenShift   │        │
│    └──────────────┘      └──────────────┘      └──────────────┘        │
│           │                     │                     │                 │
│           └─────────────────────┼─────────────────────┘                │
│                                 │                                       │
│                    ┌────────────▼────────────┐                         │
│                    │   Three Horizons        │                         │
│                    │     Accelerator         │                         │
│                    └─────────────────────────┘                         │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Pre-Deployment Checklist

### Microsoft Azure

| Requirement | Validation | Notes |
|-------------|------------|-------|
| Azure Subscription | `az account show` | Owner or Contributor required |
| Resource Providers | See registration script | 15+ providers needed |
| Quota Availability | Check in Azure Portal | 20+ vCPUs minimum |
| Azure AD Tenant | `az ad signed-in-user show` | For identity management |
| Key Vault Access | Admin role on subscription | For secrets management |

### GitHub

| Requirement | Validation | Notes |
|-------------|------------|-------|
| Organization Access | `gh org list` | Team or Enterprise plan |
| Repository Created | `gh repo view` | For accelerator code |
| Copilot License | Check in settings | For AI agents |
| Actions Enabled | Organization settings | For CI/CD |
| Secrets Access | Repository settings | For credentials |

### Red Hat

| Requirement | Validation | Notes |
|-------------|------------|-------|
| Red Hat Account | registry.redhat.io access | For container images |
| Pull Secret | Download from cloud.redhat.com | For ARO (if chosen) |
| RHDH License | Red Hat subscription | For Developer Hub |

---

## Phase 1: Foundation Setup

### 1.1 Clone and Configure Repository

```bash
# Clone the accelerator
git clone https://github.com/YOUR_ORG/three-horizons-accelerator-v4.git
cd three-horizons-accelerator-v4

# Make scripts executable
chmod +x scripts/*.sh

# Validate CLI prerequisites
./scripts/validate-cli-prerequisites.sh
```

### 1.2 Azure Authentication

```bash
# Login to Azure
az login

# Set subscription
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# Verify
az account show --query "{Name:name, ID:id, TenantId:tenantId}"
```

### 1.3 GitHub Authentication

```bash
# Login to GitHub
gh auth login

# Verify
gh auth status

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### 1.4 Configure Variables

```bash
# Copy example files
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit with your values
vi terraform/terraform.tfvars
```

**Key Variables:**

```hcl
# terraform/terraform.tfvars
project_name     = "threehorizons"
environment      = "dev"
location         = "eastus2"
platform_choice  = "aks"  # or "aro"

# Networking
vnet_cidr        = "10.0.0.0/16"

# Features
enable_h1        = true
enable_h2        = true
enable_h3        = false  # Enable when ready

# Tags
tags = {
  Project     = "Three Horizons"
  Environment = "Development"
  Owner       = "Platform Team"
}
```

---

## Phase 2: Microsoft Azure Integration

### 2.1 Register Resource Providers

```bash
# Run provider registration
./scripts/register-providers.sh

# Or manually
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.Network
az provider register --namespace Microsoft.Compute
az provider register --namespace Microsoft.Storage
az provider register --namespace Microsoft.DBforPostgreSQL
az provider register --namespace Microsoft.Cache
az provider register --namespace Microsoft.DocumentDB
az provider register --namespace Microsoft.CognitiveServices
az provider register --namespace Microsoft.MachineLearningServices
az provider register --namespace Microsoft.Security
az provider register --namespace Microsoft.Purview
```

### 2.2 Create Service Principal (Optional)

```bash
# For CI/CD pipelines (if not using OIDC)
az ad sp create-for-rbac \
  --name "three-horizons-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID" \
  --sdk-auth

# Store output in GitHub Secrets:
# - AZURE_CLIENT_ID
# - AZURE_CLIENT_SECRET
# - AZURE_TENANT_ID
# - AZURE_SUBSCRIPTION_ID
```

### 2.3 Setup Workload Identity Federation (Recommended)

```bash
# Run identity federation script
./scripts/setup-identity-federation.sh \
  --github-org "YOUR_ORG" \
  --github-repo "three-horizons-accelerator-v4" \
  --azure-subscription "YOUR_SUBSCRIPTION_ID"
```

### 2.4 Deploy Azure Infrastructure

```bash
# Initialize Terraform
cd terraform
terraform init

# Plan deployment
terraform plan -var-file=terraform.tfvars -out=tfplan

# Apply (H1 Foundation)
terraform apply tfplan

# Verify outputs
terraform output -json > ../deployment-outputs.json
```

### 2.5 Configure Azure Services

#### Azure Container Registry

```bash
# Get ACR credentials
ACR_NAME=$(terraform output -raw acr_name)

# Login to ACR
az acr login --name $ACR_NAME

# Verify
az acr repository list --name $ACR_NAME
```

#### Azure Key Vault

```bash
# Get Key Vault name
KV_NAME=$(terraform output -raw keyvault_name)

# Add secrets
az keyvault secret set --vault-name $KV_NAME --name "db-password" --value "SECURE_PASSWORD"

# Verify
az keyvault secret list --vault-name $KV_NAME
```

---

## Phase 3: GitHub Integration

### 3.1 Configure Repository Secrets

```bash
# Set secrets via CLI
gh secret set AZURE_CLIENT_ID --body "YOUR_CLIENT_ID"
gh secret set AZURE_TENANT_ID --body "YOUR_TENANT_ID"
gh secret set AZURE_SUBSCRIPTION_ID --body "YOUR_SUBSCRIPTION_ID"

# For non-OIDC
gh secret set ARM_CLIENT_SECRET --body "YOUR_SECRET"
```

### 3.2 Setup Branch Protection

```bash
# Run branch protection script
./scripts/setup-branch-protection.sh \
  --repo "YOUR_ORG/three-horizons-accelerator-v4" \
  --branch "main" \
  --required-reviews 1
```

### 3.3 Enable GitHub Actions

```yaml
# .github/workflows/infrastructure.yml is pre-configured
# Verify workflow exists
gh workflow list

# Enable if disabled
gh workflow enable infrastructure.yml
```

### 3.4 Configure GitHub App (Optional)

```bash
# For advanced automation
./scripts/setup-github-app.sh \
  --org "YOUR_ORG" \
  --app-name "three-horizons-bot"
```

### 3.5 Validate GitHub Integration

```bash
# Test workflow (dry-run)
gh workflow run infrastructure.yml \
  -f environment=dev \
  -f action=plan

# Check status
gh run list --workflow=infrastructure.yml
```

---

## Phase 4: Red Hat Integration

### 4.1 Red Hat Account Setup

1. Create account at [cloud.redhat.com](https://cloud.redhat.com)
2. Download pull secret from [console.redhat.com/openshift/install/pull-secret](https://console.redhat.com/openshift/install/pull-secret)
3. Store pull secret in Azure Key Vault

```bash
# Store pull secret
az keyvault secret set \
  --vault-name $KV_NAME \
  --name "redhat-pull-secret" \
  --file pull-secret.json
```

### 4.2 Configure RHDH (Red Hat Developer Hub)

```bash
# Get RHDH configuration
cd terraform
terraform output -raw rhdh_config > ../rhdh-config.yaml

# Apply RHDH configuration
kubectl apply -f ../rhdh-config.yaml
```

### 4.3 Register Golden Path Templates

```bash
# Register all templates
./scripts/bootstrap.sh --register-templates

# Or register individually
for template in golden-paths/**/*.yaml; do
  kubectl apply -f $template
done
```

### 4.4 Configure OpenShift (ARO Only)

If using ARO instead of AKS:

```bash
# Deploy ARO cluster
./scripts/deploy-aro.sh \
  --resource-group $RG_NAME \
  --cluster-name $ARO_NAME \
  --pull-secret-file pull-secret.json

# Get kubeconfig
az aro get-admin-kubeconfig \
  --resource-group $RG_NAME \
  --name $ARO_NAME \
  --file kubeconfig-aro

# Install OpenShift GitOps operator
oc apply -f argocd/openshift-gitops-subscription.yaml
```

### 4.5 Validate Red Hat Integration

```bash
# Check RHDH status
kubectl get pods -n rhdh

# Access RHDH portal
RHDH_URL=$(kubectl get ingress rhdh -n rhdh -o jsonpath='{.spec.rules[0].host}')
echo "RHDH Portal: https://$RHDH_URL"

# Verify templates registered
curl -s https://$RHDH_URL/api/catalog/entities | jq '.[] | select(.kind=="Template")'
```

---

## Phase 5: ArgoCD GitOps Setup

### 5.1 Install ArgoCD

```bash
# ArgoCD is installed via Terraform
# Verify installation
kubectl get pods -n argocd

# Get admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Get ArgoCD URL
ARGOCD_URL=$(kubectl get ingress argocd-server -n argocd -o jsonpath='{.spec.rules[0].host}')
echo "ArgoCD: https://$ARGOCD_URL"
```

### 5.2 Configure Repository Credentials

```bash
# Add repository credential
argocd login $ARGOCD_URL --username admin --password $ARGOCD_PASSWORD

# Add GitHub repository
argocd repo add https://github.com/YOUR_ORG/three-horizons-accelerator-v4.git \
  --username git \
  --password $GITHUB_TOKEN
```

### 5.3 Deploy App of Apps

```bash
# Apply root application
kubectl apply -f argocd/app-of-apps/root-application.yaml

# Verify sync
argocd app list
argocd app get root-application
```

### 5.4 Validate GitOps Flow

```bash
# Make a change
git add .
git commit -m "Test GitOps sync"
git push origin main

# Watch sync
argocd app sync root-application --watch
```

---

## Phase 6: Observability Integration

### 6.1 Verify Monitoring Stack

```bash
# Check Prometheus
kubectl get pods -n monitoring -l app=prometheus

# Check Grafana
kubectl get pods -n monitoring -l app=grafana

# Check Loki
kubectl get pods -n monitoring -l app=loki
```

### 6.2 Access Dashboards

```bash
# Get Grafana URL
GRAFANA_URL=$(kubectl get ingress grafana -n monitoring -o jsonpath='{.spec.rules[0].host}')
echo "Grafana: https://$GRAFANA_URL"

# Get admin password
GRAFANA_PASSWORD=$(kubectl get secret grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 -d)
```

### 6.3 Import Dashboards

```bash
# Dashboards are auto-imported via Terraform/ArgoCD
# Verify in Grafana UI

# Manual import if needed
for dashboard in grafana/dashboards/*.json; do
  curl -X POST -H "Content-Type: application/json" \
    -u admin:$GRAFANA_PASSWORD \
    -d @$dashboard \
    https://$GRAFANA_URL/api/dashboards/db
done
```

---

## Phase 7: AI Foundry Integration (H3)

### 7.1 Enable H3 Deployment

```bash
# Update variables
cd terraform
sed -i 's/enable_h3 = false/enable_h3 = true/' terraform.tfvars

# Apply H3
terraform plan -var-file=terraform.tfvars -target=module.ai_foundry -out=h3plan
terraform apply h3plan
```

### 7.2 Configure AI Foundry

```bash
# Get AI Foundry endpoint
AI_ENDPOINT=$(terraform output -raw ai_foundry_endpoint)

# Store API key in Key Vault
AI_KEY=$(terraform output -raw ai_foundry_key)
az keyvault secret set --vault-name $KV_NAME --name "ai-foundry-key" --value $AI_KEY
```

### 7.3 Deploy AI Agents

```bash
# Deploy SRE agent
kubectl apply -f agents/h3-innovation/sre-agent-deployment.yaml

# Verify
kubectl get pods -n ai-agents
```

---

## Post-Deployment Validation

### Complete Validation Script

```bash
# Run full validation
./scripts/validate-deployment.sh --environment dev --verbose

# Expected output:
# ✓ Azure resources validated
# ✓ Kubernetes cluster healthy
# ✓ ArgoCD synced
# ✓ RHDH accessible
# ✓ Observability operational
# ✓ (Optional) AI Foundry connected
#
# Deployment validation: PASSED
```

### Health Check Endpoints

| Component | Endpoint | Expected |
|-----------|----------|----------|
| AKS API | `kubectl cluster-info` | Running |
| ArgoCD | `https://argocd.domain/healthz` | OK |
| RHDH | `https://rhdh.domain/health` | OK |
| Grafana | `https://grafana.domain/api/health` | OK |
| Prometheus | `https://prometheus.domain/-/healthy` | OK |

---

## Troubleshooting Common Issues

### Azure Deployment Failures

| Issue | Cause | Resolution |
|-------|-------|------------|
| Quota exceeded | Insufficient vCPU quota | Request quota increase |
| Provider not registered | Missing resource provider | Run registration script |
| Permission denied | Insufficient RBAC | Verify Owner/Contributor role |

### GitHub Integration Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| Workflow fails | Missing secrets | Configure repository secrets |
| OIDC fails | Misconfigured federation | Re-run identity federation script |
| Actions disabled | Organization policy | Enable in organization settings |

### ArgoCD Sync Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| Sync failed | Invalid manifests | Check `argocd app logs` |
| Out of sync | Manual changes | `argocd app sync --force` |
| Permission denied | RBAC misconfiguration | Verify ArgoCD service account |

---

**Document Owner:** Platform Engineering Team  
**Last Updated:** February 2026  
**Review Cycle:** Quarterly
