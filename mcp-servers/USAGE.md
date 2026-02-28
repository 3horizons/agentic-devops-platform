# MCP Servers Usage Guide

## Overview

Model Context Protocol (MCP) servers provide agents with access to external tools and services. This document defines which agents can access which MCP servers and what operations are permitted.

## Server Access by Agent

| Agent | Allowed MCP Servers | Access Level |
|-------|---------------------|--------------|
| architect | azure, backstage | read-only |
| platform | azure, kubernetes, helm, github, backstage | read-write |
| terraform | azure, terraform | read-write |
| devops | azure, github, kubernetes, helm, docker, git | read-write |
| security | azure, defender, entra | read-only |
| sre | azure, kubernetes, helm | read-write |
| reviewer | github, backstage | read-only |
| template-engineer | github, backstage | read-write |

## Available MCP Servers

### azure
Azure CLI operations for cloud resource management.

**Capabilities:**
- `az resource list` - List resources
- `az resource show` - Show resource details
- `az aks` - AKS operations
- `az acr` - Container Registry operations
- `az keyvault` - Key Vault operations
- `az network` - Network operations
- `az ad` - Azure AD operations
- `az security` - Security operations
- `az purview` - Data governance

**Environment Variables:**
```bash
AZURE_SUBSCRIPTION_ID
ARM_TENANT_ID
```

### github
GitHub CLI and API operations.

**Capabilities:**
- `gh repo` - Repository operations
- `gh secret` - Secrets management
- `gh api` - API calls
- `gh workflow` - Workflow operations
- `gh release` - Release management
- `gh issue` - Issue management
- `gh pr` - Pull request operations
- `gh app` - GitHub App operations

**Environment Variables:**
```bash
GITHUB_TOKEN
GH_TOKEN
```

### terraform
Terraform CLI operations.

**Capabilities:**
- `terraform init` - Initialize working directory
- `terraform plan` - Create execution plan
- `terraform apply` - Apply changes (requires approval)
- `terraform destroy` - Destroy resources (requires approval)
- `terraform state` - State management

**Environment Variables:**
```bash
TF_VAR_environment
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
```

### kubernetes
Kubernetes cluster operations.

**Capabilities:**
- `kubectl get` - List resources
- `kubectl apply` - Apply manifests
- `kubectl delete` - Delete resources
- `kubectl logs` - View logs
- `kubectl exec` - Execute commands
- `kubectl port-forward` - Port forwarding

**Environment Variables:**
```bash
KUBECONFIG
```

### helm
Helm chart operations.

**Capabilities:**
- `helm install` - Install charts
- `helm upgrade` - Upgrade releases
- `helm uninstall` - Remove releases
- `helm repo` - Repository management
- `helm search` - Search charts
- `helm template` - Render templates

### docker
Docker container operations.

**Capabilities:**
- `docker build` - Build images
- `docker push` - Push images
- `docker pull` - Pull images
- `docker run` - Run containers

### defender
Microsoft Defender for Cloud.

**Capabilities:**
- `az security` - Security operations
- `az security pricing` - Pricing plans
- `az security assessment` - Assessments
- `az security alert` - Security alerts

### backstage
RHDH/Backstage MCP Actions — software catalog queries, TechDocs retrieval, and scaffolder operations.

**Transport:** Streamable HTTP (not CLI — connects to a running RHDH instance)

**Endpoint:** `http://devhub.135.18.141.224.nip.io/api/mcp-actions/v1`

**Capabilities:**
- `catalog:query` — Search and filter entities by kind, type, owner, tags
- `catalog:get` — Retrieve entity details with full metadata
- `techdocs:list` — List entities with TechDocs documentation
- `techdocs:get` — Retrieve TechDocs content for an entity

**Environment Variables:**
```bash
RHDH_URL       # http://devhub.135.18.141.224.nip.io
MCP_TOKEN      # Static token for Bearer auth
```

**Required RHDH Plugins (dynamic-plugins.yaml):**
```yaml
# MCP server backend
- package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/backstage-plugin-mcp-actions-backend
  disabled: false
# Software Catalog MCP tool
- package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/red-hat-developer-hub-backstage-plugin-software-catalog-mcp-tool
  disabled: false
# TechDocs MCP tool
- package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/red-hat-developer-hub-backstage-plugin-techdocs-mcp-tool
  disabled: false
```

**Required RHDH app-config:**
```yaml
backend:
  auth:
    externalAccess:
      - type: static
        options:
          token: ${MCP_TOKEN}
          subject: mcp-clients
  actions:
    pluginSources:
      - software-catalog-mcp-tool
      - techdocs-mcp-tool
```

**References:**
- [Red Hat: MCP in RHDH — Chat with your catalog](https://developers.redhat.com/articles/2025/11/10/mcp-red-hat-developer-hub-chat-your-catalog)
- [Backstage MCP Actions Backend](https://github.com/backstage/backstage/tree/master/plugins/mcp-actions-backend)
- [RHDH MCP Integrations](https://github.com/redhat-developer/rhdh-plugins/tree/main/workspaces/mcp-integrations)
- [RHDH Catalog MCP Extras](https://github.com/redhat-developer/rhdh-plugins/tree/main/workspaces/mcp-integrations/plugins/software-catalog-mcp-extras)

### entra
Microsoft Entra ID (Azure AD) operations.

**Capabilities:**
- `az ad app` - Application registration
- `az ad sp` - Service principals
- `az ad group` - Group management
- `az ad user` - User management
- `az role assignment` - RBAC assignments

## Tool Restrictions

### Read-Only Operations (Always Allowed)
```bash
az resource list
az resource show
kubectl get
gh pr view
gh issue view
helm list
terraform state list
terraform state show
```

### Requires Confirmation (ASK FIRST)
```bash
terraform apply
terraform destroy
kubectl apply
kubectl delete
helm install
helm upgrade
helm uninstall
az resource delete
az aks scale
```

### Forbidden Operations (NEVER)
```bash
# Direct production modifications without review
kubectl delete namespace production
terraform destroy -auto-approve

# Secret exposure
kubectl get secret -o yaml
az keyvault secret show --query value

# Privilege escalation
az role assignment create --role Owner
kubectl create clusterrolebinding --clusterrole=cluster-admin
```

## Security Guidelines

### Authentication
- Always use Workload Identity for AKS
- Use Managed Identity for Azure services
- Never store credentials in code or environment variables
- Use short-lived tokens where possible

### Secrets Management
- Store secrets in Azure Key Vault
- Use External Secrets Operator for Kubernetes
- Never log or display secret values
- Rotate credentials regularly

### Access Control
- Follow least privilege principle
- Use namespace-scoped permissions
- Audit RBAC assignments regularly
- Document permission requirements

## Environment Variables

All MCP servers require specific environment variables for authentication:

```bash
# Azure
export AZURE_SUBSCRIPTION_ID="..."
export ARM_TENANT_ID="..."
export ARM_CLIENT_ID="..."  # For service principal

# GitHub
export GITHUB_TOKEN="..."
export GH_TOKEN="..."

# Kubernetes
export KUBECONFIG="~/.kube/config"

# Terraform
export TF_VAR_environment="dev"
export TF_CLI_ARGS_plan="-input=false"
export TF_CLI_ARGS_apply="-input=false"
```

**Important:** Never hardcode credentials in configurations. Use environment variables or secret managers.

## Troubleshooting

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| "Not authenticated" | Missing credentials | Run `az login` or set GITHUB_TOKEN |
| "Permission denied" | Insufficient RBAC | Request appropriate role assignment |
| "Resource not found" | Wrong subscription | Run `az account set -s <subscription>` |
| "Kubectl connection refused" | Invalid KUBECONFIG | Run `az aks get-credentials` |

### Debugging

```bash
# Check Azure authentication
az account show

# Check GitHub authentication
gh auth status

# Check Kubernetes connectivity
kubectl cluster-info

# Check Terraform state
terraform state list
```

## Related Documentation

- [Agent Playbook](../AGENTS.md)
- [Skills Reference](../.github/skills/)
- [Security Guidelines](../SECURITY.md)
