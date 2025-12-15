# Quick Start Guide - Three Horizons Accelerator

🌐 **Language / Idioma:** [English](#) | [Português](QUICKSTART.pt-BR.md) | [Español](QUICKSTART.es.md)

---

## ⚡ Deploy in 15 Minutes

This guide will help you deploy the Three Horizons platform quickly.

---

## 📋 Prerequisites Checklist

### Required Tools

```bash
# Check all tools at once
echo "=== Checking Prerequisites ===" && \
az version --query '"Azure CLI: " + "azure-cli"' -o tsv && \
terraform version | head -1 && \
kubectl version --client -o yaml | grep gitVersion && \
helm version --short && \
gh --version | head -1
```

**Minimum Versions:**
| Tool | Minimum Version | Install Command |
|------|-----------------|-----------------|
| Azure CLI | 2.50.0 | `curl -sL https://aka.ms/InstallAzureCLIDeb \| sudo bash` |
| Terraform | 1.5.0 | `brew install terraform` or [Download](https://terraform.io/downloads) |
| kubectl | 1.28 | `az aks install-cli` |
| Helm | 3.12 | `brew install helm` |
| GitHub CLI | 2.30 | `brew install gh` |

### Required Permissions

- **Azure**: Contributor role on target subscription
- **GitHub**: Admin access to target organization
- **Entra ID**: Application Administrator (for Workload Identity)

---

## 🚀 Step-by-Step Deployment

### Step 1: Authenticate (2 min)

```bash
# Azure Login
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"

# GitHub Login
gh auth login

# Verify
az account show --query name -o tsv
gh auth status
```

### Step 2: Clone and Configure (3 min)

```bash
# Clone accelerator
git clone https://github.com/YOUR_ORG/three-horizons-accelerator-v4.git
cd three-horizons-accelerator-v4

# Make scripts executable
chmod +x scripts/*.sh

# Validate prerequisites
./scripts/validate-cli-prerequisites.sh

# Copy and edit configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

**Edit `terraform/terraform.tfvars`:**

```hcl
# Required - Change these values
project_name        = "threehorizons"        # Your project name (lowercase, no spaces)
environment         = "dev"                   # dev, staging, or prod
location            = "brazilsouth"           # Azure region
subscription_id     = "xxxxxxxx-xxxx-xxxx"   # Your Azure subscription ID
github_org          = "your-github-org"       # Your GitHub organization

# Optional - Customize as needed
aks_node_count      = 3                       # 3 for dev, 5+ for prod
enable_h2           = true                    # Enable ArgoCD/RHDH
enable_h3           = false                   # Enable AI Foundry (add later)

# Tags
tags = {
  Project     = "ThreeHorizons"
  Environment = "Dev"
  Owner       = "your-email@company.com"
}
```

### Step 3: Deploy H1 Foundation (10 min)

```bash
cd terraform

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan -out=tfplan

# Apply (confirm with 'yes')
terraform apply tfplan
```

**Expected Output:**
```
Apply complete! Resources: 23 added, 0 changed, 0 destroyed.

Outputs:
aks_cluster_name = "threehorizons-dev-aks"
acr_login_server = "threehorizonsdev.azurecr.io"
keyvault_name    = "threehorizons-dev-kv"
resource_group   = "threehorizons-dev-rg"
```

### Step 4: Connect to AKS

```bash
# Get AKS credentials
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group) \
  --name $(terraform output -raw aks_cluster_name)

# Verify connection
kubectl get nodes
kubectl get namespaces
```

---

## 🎯 Quick Commands Reference

### Deploy by Horizon

```bash
# H1 Only (Foundation)
./scripts/platform-bootstrap.sh --horizon h1 --environment dev

# H1 + H2 (with ArgoCD/RHDH)
./scripts/platform-bootstrap.sh --horizon h2 --environment dev

# Full Platform (H1 + H2 + H3)
./scripts/platform-bootstrap.sh --environment dev
```

### Useful Shortcuts

```bash
# Check deployment status
kubectl get pods -A | grep -v Running

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Open: https://localhost:8080

# Get ArgoCD password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Access Grafana
kubectl port-forward svc/grafana -n observability 3000:80
# Open: http://localhost:3000 (admin/admin)
```

---

## ✅ Verification Checklist

After deployment, verify these components:

### H1 Foundation
- [ ] AKS cluster is running: `kubectl get nodes`
- [ ] ACR is accessible: `az acr list -o table`
- [ ] Key Vault created: `az keyvault list -o table`
- [ ] VNet configured: `az network vnet list -o table`

### H2 Enhancement (if enabled)
- [ ] ArgoCD running: `kubectl get pods -n argocd`
- [ ] RHDH accessible: `kubectl get pods -n rhdh`
- [ ] Prometheus running: `kubectl get pods -n observability`
- [ ] Grafana accessible: `kubectl get pods -n observability`

### H3 Innovation (if enabled)
- [ ] AI Foundry deployed: `az cognitiveservices account list`
- [ ] OpenAI available: Check Azure Portal

---

## 🔧 Common Issues & Solutions

### Issue: Terraform init fails

```bash
# Clear cache and retry
rm -rf .terraform .terraform.lock.hcl
terraform init -upgrade
```

### Issue: AKS cluster not ready

```bash
# Check node status
kubectl describe nodes

# Check for pending pods
kubectl get pods -A --field-selector=status.phase!=Running
```

### Issue: ArgoCD not accessible

```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Restart if needed
kubectl rollout restart deployment argocd-server -n argocd
```

### Issue: Permission denied

```bash
# Verify Azure role
az role assignment list --assignee $(az account show --query user.name -o tsv) -o table

# Verify GitHub permissions
gh api /user --jq '.login'
```

---

## 📊 Resource Summary

### What Gets Deployed (H1)

| Resource | Name Pattern | Count |
|----------|--------------|-------|
| Resource Group | `{project}-{env}-rg` | 1 |
| AKS Cluster | `{project}-{env}-aks` | 1 |
| Container Registry | `{project}{env}acr` | 1 |
| Key Vault | `{project}-{env}-kv` | 1 |
| Virtual Network | `{project}-{env}-vnet` | 1 |
| Managed Identity | `{project}-{env}-identity` | 2-3 |
| NSG | `{project}-{env}-nsg-*` | 3 |

### Estimated Deployment Time

| Component | Time |
|-----------|------|
| Resource Group | 10 sec |
| VNet + Subnets | 30 sec |
| AKS Cluster | 5-8 min |
| ACR | 1 min |
| Key Vault | 30 sec |
| **Total H1** | **~10 min** |

---

## 🚀 Next Steps

After successful deployment:

1. **Register Golden Path Templates**
   ```bash
   ./scripts/bootstrap.sh --register-templates
   ```

2. **Create Your First Application**
   - Access RHDH portal
   - Select "H1: Basic Microservice" template
   - Follow the wizard

3. **Configure Notifications**
   - Edit `argocd/notifications.yaml`
   - Add your Teams/Slack webhooks

4. **Enable H3 (AI Foundry)**
   ```bash
   terraform apply -var="enable_h3=true"
   ```

---

## 📞 Need Help?

| Resource | Link |
|----------|------|
| Full Documentation | [README.md](README.md) |
| Troubleshooting | [docs/guides/TROUBLESHOOTING_GUIDE.md](docs/guides/TROUBLESHOOTING_GUIDE.md) |
| GitHub Issues | [Create Issue](https://github.com/paulanunes85/three-horizons-accelerator-v4/issues) |

---

**Version:** 4.0.0
**Last Updated:** December 2025
