---
name: prerequisites
description: 'CLI tools and prerequisites for Three Horizons Accelerator. Use when setting up development environment, validating tool versions, or troubleshooting installation issues.'
---

# Prerequisites Skill

USE FOR:
- Setting up development environment
- Installing required CLI tools
- Validating tool versions
- Troubleshooting installation issues
- Cross-platform installation guidance
- Authentication setup for CLIs

DO NOT USE FOR:
- Specific CLI command usage (use respective CLI skills)
- Application development
- Infrastructure deployment

## Quick Reference

| CLI | Min Version | Purpose | Skill Reference |
|-----|-------------|---------|-----------------|
| `az` | 2.57.0+ | Azure resource management | azure-cli |
| `terraform` | 1.7.0+ | Infrastructure as Code | terraform-cli |
| `kubectl` | 1.29.0+ | Kubernetes management | kubectl-cli |
| `oc` | 4.14+ | OpenShift/ARO operations | oc-cli |
| `helm` | 3.14.0+ | Helm chart management | helm-cli |
| `argocd` | 2.10+ | GitOps deployments | argocd-cli |
| `gh` | 2.43.0+ | GitHub operations | github-cli |
| `jq` | 1.7+ | JSON processing | (utility) |
| `yq` | 4.40+ | YAML processing | (utility) |
| `git` | 2.40+ | Version control | (utility) |
| `node` | 18+ | MCP server runtime | mcp-cli |
| `npx` | (with node) | MCP server execution | mcp-cli |
| `kubelogin` | 0.0.30+ | AKS authentication | kubectl-cli |
| `docker` | 24+ | Container operations | (optional) |

## Installation by Platform

### macOS (Homebrew)

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Core CLIs
brew install azure-cli
brew install terraform
brew install kubernetes-cli
brew install openshift-cli
brew install helm
brew install argocd
brew install gh

# Utilities
brew install jq
brew install yq
brew install git
brew install node

# Azure-specific
brew install Azure/kubelogin/kubelogin

# Optional
brew install docker
```

### Linux (Ubuntu/Debian)

```bash
# Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# kubectl
sudo az aks install-cli

# OpenShift CLI (oc)
OC_VERSION=4.14.0
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/${OC_VERSION}/openshift-client-linux.tar.gz
tar xzf openshift-client-linux.tar.gz
sudo mv oc /usr/local/bin/

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ArgoCD CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Utilities
sudo apt install -y jq git
sudo snap install yq
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# kubelogin
az aks install-cli
```

### Windows (PowerShell/WinGet)

```powershell
# Azure CLI
winget install Microsoft.AzureCLI

# Terraform
winget install Hashicorp.Terraform

# kubectl
az aks install-cli

# OpenShift CLI
# Download from: https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/

# Helm
winget install Helm.Helm

# GitHub CLI
winget install GitHub.cli

# Utilities
winget install jqlang.jq
winget install MikeFarah.yq
winget install Git.Git
winget install OpenJS.NodeJS

# kubelogin
az aks install-cli
```

## Validation Script

Run the validation script to check all prerequisites:

```bash
./scripts/validate-cli-prerequisites.sh
```

### Manual Validation

```bash
# Check all versions
echo "=== CLI Versions ==="
echo "az: $(az version --query '\"azure-cli\"' -o tsv 2>/dev/null || echo 'NOT INSTALLED')"
echo "terraform: $(terraform version -json 2>/dev/null | jq -r '.terraform_version' || echo 'NOT INSTALLED')"
echo "kubectl: $(kubectl version --client -o json 2>/dev/null | jq -r '.clientVersion.gitVersion' || echo 'NOT INSTALLED')"
echo "oc: $(oc version --client 2>/dev/null | grep 'Client Version' | awk '{print $3}' || echo 'NOT INSTALLED')"
echo "helm: $(helm version --short 2>/dev/null || echo 'NOT INSTALLED')"
echo "argocd: $(argocd version --client --short 2>/dev/null || echo 'NOT INSTALLED')"
echo "gh: $(gh version 2>/dev/null | head -1 | awk '{print $3}' || echo 'NOT INSTALLED')"
echo "jq: $(jq --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "yq: $(yq --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "git: $(git --version 2>/dev/null | awk '{print $3}' || echo 'NOT INSTALLED')"
echo "node: $(node --version 2>/dev/null || echo 'NOT INSTALLED')"
echo "docker: $(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',' || echo 'NOT INSTALLED')"
```

## Authentication Setup

### Azure CLI

```bash
# Interactive login
az login

# Service principal login
az login --service-principal \
  --username ${CLIENT_ID} \
  --password ${CLIENT_SECRET} \
  --tenant ${TENANT_ID}

# Set subscription
az account set --subscription ${SUBSCRIPTION_ID}

# Verify
az account show
```

### GitHub CLI

```bash
# Interactive login
gh auth login

# Token-based login
gh auth login --with-token < token.txt

# Verify
gh auth status
```

### kubectl / oc

```bash
# AKS authentication
az aks get-credentials \
  --resource-group ${RESOURCE_GROUP} \
  --name ${CLUSTER_NAME}

# ARO authentication
API_SERVER=$(az aro show -n ${CLUSTER_NAME} -g ${RESOURCE_GROUP} --query apiserverProfile.url -o tsv)
KUBEADMIN_PASSWORD=$(az aro list-credentials -n ${CLUSTER_NAME} -g ${RESOURCE_GROUP} --query kubeadminPassword -o tsv)
oc login ${API_SERVER} -u kubeadmin -p ${KUBEADMIN_PASSWORD}

# Verify
kubectl cluster-info
oc whoami
```

### ArgoCD CLI

```bash
# Login to ArgoCD server
argocd login ${ARGOCD_SERVER} \
  --username admin \
  --password ${ARGOCD_PASSWORD}

# Verify
argocd account get-user-info
```

### Helm

```bash
# Add common repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Verify
helm repo list
```

## Environment Variables

### Required Variables

```bash
# Azure
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_CLIENT_ID="your-client-id"        # For service principal
export AZURE_CLIENT_SECRET="your-secret"        # For service principal

# GitHub
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
export GITHUB_OWNER="your-org"
export GITHUB_REPO="your-repo"

# Kubernetes
export KUBECONFIG="${HOME}/.kube/config"

# Terraform
export TF_VAR_subscription_id="${AZURE_SUBSCRIPTION_ID}"
export TF_VAR_tenant_id="${AZURE_TENANT_ID}"
export ARM_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
export ARM_TENANT_ID="${AZURE_TENANT_ID}"

# ArgoCD
export ARGOCD_SERVER="argocd.example.com"
```

### Environment File Template

Create `.env` file (add to .gitignore):

```bash
# .env
AZURE_SUBSCRIPTION_ID=
AZURE_TENANT_ID=
AZURE_CLIENT_ID=
AZURE_CLIENT_SECRET=
GITHUB_TOKEN=
KUBECONFIG=~/.kube/config
ARGOCD_SERVER=
```

Load environment:

```bash
source .env
# or
export $(cat .env | xargs)
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| `az: command not found` | Install Azure CLI or add to PATH |
| `terraform: command not found` | Install Terraform or add to PATH |
| `KUBECONFIG not set` | Export `KUBECONFIG` variable |
| `oc login failed` | Check API server URL and credentials |
| `helm repo update failed` | Check network connectivity |
| `gh auth failed` | Re-authenticate with `gh auth login` |
| `kubelogin not found` | Install via `az aks install-cli` |

### Version Conflicts

```bash
# Check multiple versions
which -a az
which -a terraform
which -a kubectl

# Use specific version (Homebrew)
brew switch terraform 1.7.0

# Use tfenv for Terraform version management
brew install tfenv
tfenv install 1.7.0
tfenv use 1.7.0
```

### PATH Issues

```bash
# Add to ~/.zshrc or ~/.bashrc
export PATH="/usr/local/bin:$PATH"
export PATH="${HOME}/.local/bin:$PATH"
export PATH="${HOME}/bin:$PATH"

# Reload shell
source ~/.zshrc
```

## Quick Start Script

One-liner to install all prerequisites (macOS):

```bash
curl -sSL https://raw.githubusercontent.com/your-org/three-horizons-accelerator/main/scripts/install-prerequisites.sh | bash
```

Or use the bootstrap script:

```bash
./scripts/bootstrap.sh
```

## Best Practices

1. **Use Version Managers**: tfenv, nvm, kubectx for managing multiple versions
2. **Pin Versions**: Document exact versions that work together
3. **Validate Regularly**: Run validation script after updates
4. **Secure Credentials**: Use environment variables, not hardcoded values
5. **Keep Updated**: Regular updates for security patches
6. **Document Changes**: Track version changes in CHANGELOG

## Related Skills

- [azure-cli](../azure-cli/SKILL.md) - Azure CLI commands
- [terraform-cli](../terraform-cli/SKILL.md) - Terraform commands
- [kubectl-cli](../kubectl-cli/SKILL.md) - Kubernetes commands
- [oc-cli](../oc-cli/SKILL.md) - OpenShift commands
- [helm-cli](../helm-cli/SKILL.md) - Helm commands
- [argocd-cli](../argocd-cli/SKILL.md) - ArgoCD commands
- [github-cli](../github-cli/SKILL.md) - GitHub CLI commands
- [mcp-cli](../mcp-cli/SKILL.md) - MCP configuration
