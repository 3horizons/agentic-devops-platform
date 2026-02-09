# MCP Servers Configuration Guide

> Setup guide for Model Context Protocol (MCP) servers required by Three Horizons agents

## Overview

MCP (Model Context Protocol) servers provide the tools and capabilities that AI agents use to interact with infrastructure, cloud services, and development tools. This guide covers the setup and configuration of all MCP servers used by the Three Horizons agents.

---

## Required MCP Servers

| MCP Server | Priority | Used By | Purpose |
|------------|----------|---------|---------|
| **Kubernetes** | Critical | 15 agents | Cluster management, deployments |
| **Azure** | Critical | 13 agents | Azure resource management |
| **GitHub** | Critical | 10 agents | Repository, Actions, Issues |
| **Helm** | High | 6 agents | Chart deployments |
| **Terraform** | High | 4 agents | Infrastructure provisioning |
| **Git** | Medium | 2 agents | Repository operations |
| **Azure-AI** | High | 2 agents | AI Foundry, OpenAI |
| **Prometheus** | Low | 1 agent | Metrics queries |

---

## Server Configuration Files

All MCP server configurations are stored in:

```
mcp-servers/
├── azure-mcp-server.json
├── kubernetes-mcp-server.json
├── github-mcp-server.json
├── helm-mcp-server.json
├── terraform-mcp-server.json
├── git-mcp-server.json
├── azure-ai-mcp-server.json
└── prometheus-mcp-server.json
```

---

## Kubernetes MCP Server

**Used by:** 15 agents (most common)

### Prerequisites

```bash
# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl && sudo mv kubectl /usr/local/bin/

# Configure kubeconfig
az aks get-credentials --resource-group <rg-name> --name <aks-name>
```

### Configuration

```json
{
  "name": "kubernetes",
  "version": "1.0.0",
  "description": "Kubernetes cluster management",
  "capabilities": [
    "kubectl_get",
    "kubectl_apply",
    "kubectl_delete",
    "kubectl_logs",
    "kubectl_exec",
    "kubectl_port_forward",
    "kubectl_rollout",
    "namespace_management",
    "secret_management",
    "configmap_management"
  ],
  "authentication": {
    "type": "kubeconfig",
    "path": "~/.kube/config"
  },
  "environment": {
    "KUBECONFIG": "~/.kube/config"
  }
}
```

### Capabilities

| Capability | Description | Example |
|------------|-------------|---------|
| `kubectl_get` | Retrieve resources | `kubectl get pods -n argocd` |
| `kubectl_apply` | Apply manifests | `kubectl apply -f deployment.yaml` |
| `kubectl_delete` | Delete resources | `kubectl delete pod <name>` |
| `kubectl_logs` | View pod logs | `kubectl logs -f <pod>` |
| `kubectl_exec` | Execute in pod | `kubectl exec -it <pod> -- bash` |
| `kubectl_rollout` | Manage rollouts | `kubectl rollout restart deployment` |

---

## Azure MCP Server

**Used by:** 13 agents

### Prerequisites

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Set subscription
az account set --subscription <subscription-id>
```

### Configuration

```json
{
  "name": "azure",
  "version": "1.0.0",
  "description": "Azure resource management",
  "capabilities": [
    "resource_group_management",
    "aks_management",
    "keyvault_management",
    "acr_management",
    "network_management",
    "database_management",
    "identity_management",
    "defender_management",
    "policy_management",
    "cost_management"
  ],
  "authentication": {
    "type": "azure-cli",
    "subscription": "${AZURE_SUBSCRIPTION_ID}"
  },
  "environment": {
    "AZURE_SUBSCRIPTION_ID": "<subscription-id>",
    "AZURE_TENANT_ID": "<tenant-id>",
    "AZURE_CLIENT_ID": "<client-id>",
    "AZURE_CLIENT_SECRET": "<client-secret>"
  }
}
```

### Environment Variables

```bash
export AZURE_SUBSCRIPTION_ID="your-subscription-id"
export AZURE_TENANT_ID="your-tenant-id"
export AZURE_CLIENT_ID="your-client-id"        # Optional: for service principal
export AZURE_CLIENT_SECRET="your-client-secret" # Optional: for service principal
```

---

## GitHub MCP Server

**Used by:** 10 agents

### Prerequisites

```bash
# Install GitHub CLI
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update && sudo apt install gh

# Authenticate
gh auth login
```

### Configuration

```json
{
  "name": "github",
  "version": "1.0.0",
  "description": "GitHub repository and workflow management",
  "capabilities": [
    "repository_management",
    "issue_management",
    "pr_management",
    "workflow_management",
    "secrets_management",
    "actions_management",
    "releases_management",
    "webhook_management"
  ],
  "authentication": {
    "type": "token",
    "token": "${GITHUB_TOKEN}"
  },
  "environment": {
    "GITHUB_TOKEN": "<github-pat>",
    "GITHUB_ORG": "<organization>"
  }
}
```

### Required Token Scopes

| Scope | Purpose |
|-------|---------|
| `repo` | Full repository access |
| `workflow` | GitHub Actions workflows |
| `admin:org` | Organization management |
| `write:packages` | Package publishing |
| `delete:packages` | Package deletion |

---

## Helm MCP Server

**Used by:** 6 agents

### Prerequisites

```bash
# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Add common repositories
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Configuration

```json
{
  "name": "helm",
  "version": "1.0.0",
  "description": "Helm chart management",
  "capabilities": [
    "helm_install",
    "helm_upgrade",
    "helm_uninstall",
    "helm_rollback",
    "helm_list",
    "helm_repo_add",
    "helm_repo_update",
    "helm_search",
    "helm_template"
  ],
  "authentication": {
    "type": "kubeconfig",
    "path": "~/.kube/config"
  },
  "environment": {
    "KUBECONFIG": "~/.kube/config",
    "HELM_CACHE_HOME": "~/.cache/helm",
    "HELM_CONFIG_HOME": "~/.config/helm"
  }
}
```

---

## Terraform MCP Server

**Used by:** 4 agents

### Prerequisites

```bash
# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### Configuration

```json
{
  "name": "terraform",
  "version": "1.0.0",
  "description": "Infrastructure as Code management",
  "capabilities": [
    "terraform_init",
    "terraform_plan",
    "terraform_apply",
    "terraform_destroy",
    "terraform_import",
    "terraform_state",
    "terraform_output",
    "terraform_validate"
  ],
  "authentication": {
    "type": "azure-cli"
  },
  "environment": {
    "ARM_SUBSCRIPTION_ID": "${AZURE_SUBSCRIPTION_ID}",
    "ARM_TENANT_ID": "${AZURE_TENANT_ID}",
    "ARM_CLIENT_ID": "${AZURE_CLIENT_ID}",
    "ARM_CLIENT_SECRET": "${AZURE_CLIENT_SECRET}",
    "TF_VAR_environment": "dev"
  }
}
```

### Backend Configuration

For state management, configure Azure Storage:

```bash
# Create storage account for Terraform state
az storage account create \
  --name tfstate$RANDOM \
  --resource-group rg-terraform-state \
  --location brazilsouth \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name <storage-account-name>
```

---

## Git MCP Server

**Used by:** 2 agents (Migration, Golden Paths)

### Prerequisites

```bash
# Install Git
sudo apt install git

# Configure Git
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Configuration

```json
{
  "name": "git",
  "version": "1.0.0",
  "description": "Git repository operations",
  "capabilities": [
    "git_clone",
    "git_pull",
    "git_push",
    "git_commit",
    "git_branch",
    "git_merge",
    "git_rebase",
    "git_tag"
  ],
  "authentication": {
    "type": "ssh",
    "key_path": "~/.ssh/id_rsa"
  },
  "environment": {
    "GIT_SSH_COMMAND": "ssh -i ~/.ssh/id_rsa"
  }
}
```

---

## Azure AI MCP Server

**Used by:** 2 agents (AI Foundry, Multi-Agent)

### Prerequisites

```bash
# Install Azure AI SDK
pip install azure-ai-ml azure-identity openai

# Configure AI Foundry connection
az ml workspace show --name <workspace-name> --resource-group <rg-name>
```

### Configuration

```json
{
  "name": "azure-ai",
  "version": "1.0.0",
  "description": "Azure AI Foundry and OpenAI management",
  "capabilities": [
    "workspace_management",
    "model_deployment",
    "endpoint_management",
    "compute_management",
    "dataset_management",
    "experiment_management",
    "openai_completion",
    "openai_embedding"
  ],
  "authentication": {
    "type": "azure-identity"
  },
  "environment": {
    "AZURE_AI_WORKSPACE": "<workspace-name>",
    "AZURE_AI_RESOURCE_GROUP": "<resource-group>",
    "AZURE_OPENAI_ENDPOINT": "https://<resource>.openai.azure.com/",
    "AZURE_OPENAI_API_KEY": "<api-key>",
    "AZURE_OPENAI_API_VERSION": "2024-02-15-preview"
  }
}
```

---

## Prometheus MCP Server

**Used by:** 1 agent (SRE Agent)

### Prerequisites

```bash
# Port-forward to Prometheus (if running in-cluster)
kubectl port-forward svc/prometheus-server 9090:80 -n observability
```

### Configuration

```json
{
  "name": "prometheus",
  "version": "1.0.0",
  "description": "Prometheus metrics queries",
  "capabilities": [
    "query_instant",
    "query_range",
    "series",
    "labels",
    "label_values",
    "alerts",
    "rules"
  ],
  "authentication": {
    "type": "none"
  },
  "environment": {
    "PROMETHEUS_URL": "http://localhost:9090"
  }
}
```

---

## Complete Environment Setup

Create a `.env` file with all required variables:

```bash
# Azure
export AZURE_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
export AZURE_TENANT_ID="00000000-0000-0000-0000-000000000000"
export AZURE_CLIENT_ID="00000000-0000-0000-0000-000000000000"
export AZURE_CLIENT_SECRET="your-secret"

# GitHub
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxx"
export GITHUB_ORG="your-organization"

# Kubernetes
export KUBECONFIG="~/.kube/config"

# Azure AI
export AZURE_OPENAI_ENDPOINT="https://your-resource.openai.azure.com/"
export AZURE_OPENAI_API_KEY="your-api-key"

# Terraform
export ARM_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}"
export ARM_TENANT_ID="${AZURE_TENANT_ID}"
export ARM_CLIENT_ID="${AZURE_CLIENT_ID}"
export ARM_CLIENT_SECRET="${AZURE_CLIENT_SECRET}"
```

Load the environment:

```bash
source .env
```

---

## Validation Script

Run this script to validate all MCP servers are configured correctly:

```bash
#!/bin/bash
# scripts/validate-mcp-servers.sh

echo "Validating MCP Server configurations..."

# Azure
echo -n "Azure CLI: "
az account show &>/dev/null && echo "✅" || echo "❌"

# Kubernetes
echo -n "Kubernetes: "
kubectl cluster-info &>/dev/null && echo "✅" || echo "❌"

# GitHub
echo -n "GitHub CLI: "
gh auth status &>/dev/null && echo "✅" || echo "❌"

# Helm
echo -n "Helm: "
helm version &>/dev/null && echo "✅" || echo "❌"

# Terraform
echo -n "Terraform: "
terraform version &>/dev/null && echo "✅" || echo "❌"

# Git
echo -n "Git: "
git --version &>/dev/null && echo "✅" || echo "❌"

echo "Validation complete!"
```

---

## Troubleshooting

### Azure Authentication Issues

```bash
# Re-authenticate
az logout
az login

# Check current subscription
az account show
```

### Kubernetes Connection Issues

```bash
# Refresh credentials
az aks get-credentials --resource-group <rg> --name <aks> --overwrite-existing

# Test connection
kubectl get nodes
```

### GitHub Token Issues

```bash
# Re-authenticate
gh auth logout
gh auth login

# Verify scopes
gh auth status
```

---

## Next Steps

After configuring MCP servers:

1. **Validate setup** - Run `./scripts/validate-mcp-servers.sh` (included above)
2. **Start deployment** - Follow [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md)
3. **Choose agents** - Browse the [INDEX.md](./INDEX.md) to find needed agents
4. **Check dependencies** - Review [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md)

---

## Related Documentation

### Agent Documentation
- [README.md](./README.md) - Agents overview
- [INDEX.md](./INDEX.md) - Complete agent index
- [DEPLOYMENT_SEQUENCE.md](./DEPLOYMENT_SEQUENCE.md) - Deployment order
- [TERRAFORM_MODULES_REFERENCE.md](./TERRAFORM_MODULES_REFERENCE.md) - Terraform modules
- [DEPENDENCY_GRAPH.md](./DEPENDENCY_GRAPH.md) - Visual dependencies

### Main Guides
- [Deployment Guide](../../guides/DEPLOYMENT_GUIDE.md) - Full deployment instructions
- [Troubleshooting Guide](../../guides/TROUBLESHOOTING_GUIDE.md) - Problem resolution

---

**Version:** 4.0.0
**Last Updated:** December 2025
