# Deployment Runbook

## Overview

This runbook provides procedures for deploying the Three Horizons Platform. Use this for initial deployments, updates, and environment provisioning.

> 🤖 **Copilot Agents can help!**
> - Ask `@onboarding` for a guided first-time setup
> - Ask `@terraform` to validate your `.tfvars` before applying
> - Ask `@devops` to help with ArgoCD sync issues during deployment
> - Ask `@sre` to verify platform health after deployment

## Prerequisites

### Required Tools

```bash
# Verify all tools are installed
./scripts/validate-cli-prerequisites.sh
```

Required versions:
- Terraform >= 1.6.0
- Azure CLI >= 2.50.0
- kubectl >= 1.28.0
- Helm >= 3.12.0
- GitHub CLI >= 2.30.0

### Required Access

- [ ] Azure subscription with Contributor access
- [ ] GitHub organization admin (for initial setup)
- [ ] Azure AD permissions for app registrations
- [ ] Key Vault access policies

## Pre-Deployment Checklist

- [ ] Configuration files prepared (`terraform.tfvars`)
- [ ] Azure quotas verified (vCPUs, public IPs)
- [ ] Network CIDR ranges confirmed (no conflicts)
- [ ] DNS zone delegation configured (if applicable)
- [ ] GitHub secrets configured
- [ ] Team notified of deployment window

## Deployment Procedures

### H1: Foundation Deployment

**Estimated Time**: 45-60 minutes

```bash
# 1. Initialize Terraform
cd terraform
terraform init

# 2. Validate configuration
terraform validate
./scripts/validate-config.sh --config terraform.tfvars

# 3. Plan deployment
terraform plan -out=h1.tfplan

# 4. Review plan carefully
# Verify resources to be created

# 5. Apply H1 Foundation
terraform apply h1.tfplan

# 6. Configure kubectl
az aks get-credentials -g <resource-group> -n <cluster-name>

# 7. Verify H1
./scripts/validate-deployment.sh --horizon h1
```

**Verification Checklist**:
- [ ] AKS cluster running with all nodes Ready
- [ ] Key Vault accessible
- [ ] ACR created and accessible
- [ ] Networking configured (VNet, subnets, NSGs)
- [ ] Storage classes available

### H2: Enhancement Deployment

**Estimated Time**: 50-70 minutes

```bash
# 1. Deploy ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Configure ArgoCD
kubectl apply -f argocd/apps/

# 3. Deploy External Secrets Operator
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace

# 4. Configure ClusterSecretStore
kubectl apply -f argocd/secrets/cluster-secret-store.yaml

# 5. Deploy Observability Stack
# Via ArgoCD application

# 6. Verify H2
./scripts/validate-deployment.sh --horizon h2
```

**Verification Checklist**:
- [ ] ArgoCD UI accessible
- [ ] All ArgoCD applications synced
- [ ] External Secrets syncing from Key Vault
- [ ] Prometheus collecting metrics
- [ ] Grafana dashboards loading
- [ ] Gatekeeper policies active

### H3: Innovation Deployment

**Estimated Time**: 35-45 minutes

```bash
# 1. Enable AI Foundry module
# In terraform.tfvars:
# enable_ai_foundry = true

# 2. Plan and apply
terraform plan -out=h3.tfplan
terraform apply h3.tfplan

# 3. Verify AI services
az cognitiveservices account show -g <rg> -n <openai-name>

# 4. Test connectivity
kubectl run ai-test --image=curlimages/curl --rm -it -- \
  curl -H "api-key: $OPENAI_KEY" https://<endpoint>/openai/deployments

# 5. Verify H3
./scripts/validate-deployment.sh --horizon h3
```

**Verification Checklist**:
- [ ] Azure OpenAI service accessible
- [ ] AI Search service running
- [ ] Model deployments available
- [ ] Private endpoints configured
- [ ] Secrets synced to cluster

## Post-Deployment Tasks

### 1. Configure DNS Records

```bash
# Get ingress IP
INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Create DNS records
az network dns record-set a add-record \
  -g <dns-rg> -z <domain> \
  -n argocd -a $INGRESS_IP

az network dns record-set a add-record \
  -g <dns-rg> -z <domain> \
  -n grafana -a $INGRESS_IP
```

### 2. Configure ArgoCD Admin Password

```bash
# Get initial password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Change password via CLI
argocd login <argocd-url>
argocd account update-password
```

### 3. Register Golden Paths

```bash
# Apply golden paths to RHDH
kubectl apply -f golden-paths/
```

### 4. Notify Stakeholders

Send deployment completion notification:
- Deployment status
- Service URLs
- Known issues (if any)
- Next steps

## Troubleshooting Deployment Issues

### Terraform State Lock

```bash
# If state is locked
terraform force-unlock <lock-id>
```

### Azure Resource Provider Not Registered

```bash
# Register required providers
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.KeyVault
az provider register --namespace Microsoft.CognitiveServices
```

### Quota Exceeded

```bash
# Check current usage
az vm list-usage --location <region> -o table

# Request quota increase via Azure Portal
```

### Pod Scheduling Failures

```bash
# Check events
kubectl get events -A --sort-by='.lastTimestamp'

# Check node resources
kubectl describe nodes | grep -A5 "Allocated resources"
```

## Cleanup Procedures

### Remove H3 Only

```bash
terraform destroy -target=module.ai_foundry
```

### Remove H2 Only

```bash
kubectl delete -f argocd/apps/
helm uninstall external-secrets -n external-secrets
kubectl delete namespace argocd
```

### Full Teardown

```bash
# WARNING: Destroys all resources
terraform destroy

# Verify cleanup
az group list --query "[?starts_with(name, 'rg-')]" -o table
```

## References

- [Deployment Guide](../guides/DEPLOYMENT_GUIDE.md)
- [Validate Deployment Script](../../.github/skills/validation-scripts/scripts/validate-deployment.sh)
- [Rollback Runbook](rollback-runbook.md)
