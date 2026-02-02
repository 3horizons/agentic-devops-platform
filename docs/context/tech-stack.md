# Technology Stack

> Complete technology inventory with versions, integrations, and requirements.

## Overview

The Three Horizons Accelerator integrates technologies from three major partners to deliver an enterprise-grade platform:

| Partner | Technologies |
|---------|-------------|
| **Microsoft** | Azure (AKS, Key Vault, ACR, AI Foundry, Defender, Purview) |
| **Red Hat** | OpenShift (ARO), Developer Hub (RHDH), enterprise operators |
| **GitHub** | Actions, Copilot, repository management, issue tracking |

---

## Core Infrastructure

### Kubernetes Platform (Choose One)

#### Azure Kubernetes Service (AKS)

| Component | Version | Purpose |
|-----------|---------|---------|
| AKS | 1.29+ | Managed Kubernetes |
| Azure CNI Overlay | Latest | Container networking |
| Azure Disk CSI | v1.29+ | Persistent storage |
| Azure AD Workload Identity | v1.2+ | Pod identity |
| KEDA | 2.12+ | Event-driven autoscaling |

#### Azure Red Hat OpenShift (ARO)

| Component | Version | Purpose |
|-----------|---------|---------|
| ARO | 4.14+ | Managed OpenShift |
| OVN-Kubernetes | Latest | SDN networking |
| ODF (OpenShift Data Foundation) | 4.14+ | Storage |
| OpenShift GitOps | 1.11+ | ArgoCD Operator |
| OpenShift Pipelines | 1.14+ | Tekton CI/CD |

### Networking

| Component | Version | Purpose |
|-----------|---------|---------|
| Azure Virtual Network | N/A | Network isolation |
| Azure Private Link | N/A | Private endpoints |
| Azure Load Balancer | Standard | Traffic distribution |
| Azure Application Gateway | v2 | Ingress controller (optional) |
| Network Security Groups | N/A | Firewall rules |
| Azure Firewall | Premium (optional) | Centralized egress |

### Security

| Component | Version | Purpose |
|-----------|---------|---------|
| Azure Key Vault | N/A | Secrets management |
| External Secrets Operator | 0.9+ | Kubernetes secrets sync |
| Azure Defender for Cloud | N/A | Security posture |
| Azure Policy | N/A | Compliance enforcement |
| Azure AD | N/A | Identity provider |
| Workload Identity | v1.2+ | Pod-level identity |

### Storage

| Component | Version | Purpose |
|-----------|---------|---------|
| Azure Container Registry | Premium | Container images |
| Azure Blob Storage | N/A | Object storage |
| Azure Files | N/A | Shared file storage |
| Azure Managed Disks | Premium SSD v2 | Block storage |

---

## H2 Enhancement Stack

### GitOps

| Component | Version | Purpose |
|-----------|---------|---------|
| ArgoCD | 2.10+ | GitOps continuous delivery |
| Argo Rollouts | 1.6+ | Progressive delivery |
| Kustomize | 5.3+ | Configuration management |
| Helm | 3.14+ | Package management |
| ApplicationSets | 0.4+ | Dynamic app generation |

### Developer Portal

| Component | Version | Purpose |
|-----------|---------|---------|
| Red Hat Developer Hub | 1.2+ | Self-service portal |
| Backstage | 1.22+ | Core platform |
| TechDocs | Latest | Documentation |
| Software Catalog | Latest | Service registry |

### Observability

| Component | Version | Purpose |
|-----------|---------|---------|
| Prometheus | 2.50+ | Metrics collection |
| Grafana | 10.3+ | Visualization |
| Loki | 2.9+ | Log aggregation |
| Tempo | 2.4+ | Distributed tracing |
| AlertManager | 0.27+ | Alert routing |

### CI/CD

| Component | Version | Purpose |
|-----------|---------|---------|
| GitHub Actions | N/A | Pipeline orchestration |
| Actions Runner Controller | 0.9+ | Self-hosted runners |
| Trivy | 0.49+ | Container scanning |
| OPA Gatekeeper | 3.15+ | Policy enforcement |

---

## H3 Innovation Stack

### AI & Machine Learning

| Component | Version | Purpose |
|-----------|---------|---------|
| Azure AI Foundry | N/A | AI development platform |
| Azure OpenAI Service | N/A | LLM access (GPT-4o, o1) |
| Azure AI Search | N/A | Vector search |
| Azure Machine Learning | N/A | Model training/deployment |
| Cosmos DB | N/A | Vector store |

### Agent Framework

| Component | Version | Purpose |
|-----------|---------|---------|
| GitHub Copilot | N/A | AI coding assistant |
| MCP Servers | 15 configured | Model Context Protocol |
| Semantic Kernel | 1.0+ | AI orchestration |
| LangChain | 0.1+ | LLM chaining |

---

## Infrastructure as Code

### Terraform

| Component | Version | Purpose |
|-----------|---------|---------|
| Terraform | 1.7+ | Infrastructure provisioning |
| AzureRM Provider | 3.90+ | Azure resources |
| AzureAD Provider | 2.47+ | Entra ID resources |
| Kubernetes Provider | 2.25+ | K8s resources |
| Helm Provider | 2.12+ | Helm releases |
| Random Provider | 3.6+ | Random generation |
| TLS Provider | 4.0+ | Certificate management |

### Modules Inventory

| Module | Location | Resources |
|--------|----------|-----------|
| `aks-cluster` | `terraform/modules/aks-cluster` | AKS, node pools, identities |
| `networking` | `terraform/modules/networking` | VNet, subnets, NSGs |
| `security` | `terraform/modules/security` | Key Vault, identities |
| `container-registry` | `terraform/modules/container-registry` | ACR, geo-replication |
| `databases` | `terraform/modules/databases` | PostgreSQL, Redis, Cosmos |
| `observability` | `terraform/modules/observability` | Prometheus, Grafana, Loki |
| `argocd` | `terraform/modules/argocd` | ArgoCD installation |
| `rhdh` | `terraform/modules/rhdh` | Developer Hub |
| `ai-foundry` | `terraform/modules/ai-foundry` | AI Foundry, OpenAI |
| `defender` | `terraform/modules/defender` | Defender for Cloud |
| `purview` | `terraform/modules/purview` | Microsoft Purview |
| `github-runners` | `terraform/modules/github-runners` | Actions runners |
| `external-secrets` | `terraform/modules/external-secrets` | ESO operator |
| `cost-management` | `terraform/modules/cost-management` | Budgets, alerts |
| `disaster-recovery` | `terraform/modules/disaster-recovery` | Backup, DR |
| `naming` | `terraform/modules/naming` | Naming conventions |

---

## CLI Requirements

### Required Tools

| Tool | Minimum Version | Install Command |
|------|----------------|-----------------|
| `az` (Azure CLI) | 2.57.0+ | `brew install azure-cli` |
| `terraform` | 1.7.0+ | `brew install terraform` |
| `kubectl` | 1.29.0+ | `brew install kubectl` |
| `helm` | 3.14.0+ | `brew install helm` |
| `gh` (GitHub CLI) | 2.43.0+ | `brew install gh` |
| `argocd` | 2.10.0+ | `brew install argocd` |
| `jq` | 1.7+ | `brew install jq` |
| `yq` | 4.40+ | `brew install yq` |

### Optional Tools

| Tool | Version | Purpose |
|------|---------|---------|
| `oc` (OpenShift CLI) | 4.14+ | ARO management |
| `kustomize` | 5.3+ | Standalone kustomize |
| `trivy` | 0.49+ | Local scanning |
| `k9s` | 0.31+ | Kubernetes TUI |

### Validation Script

```bash
# Run prerequisite validation
./scripts/validate-cli-prerequisites.sh

# Expected output:
# ✓ az version 2.57.0 >= 2.57.0
# ✓ terraform version 1.7.0 >= 1.7.0
# ✓ kubectl version 1.29.0 >= 1.29.0
# ✓ helm version 3.14.0 >= 3.14.0
# ✓ gh version 2.43.0 >= 2.43.0
# ✓ argocd version 2.10.0 >= 2.10.0
# All prerequisites satisfied!
```

---

## GitHub Requirements

### Repository Configuration

| Requirement | Value |
|-------------|-------|
| Plan | Team or Enterprise |
| Visibility | Private (recommended) |
| Branch Protection | Required for main |
| Required Reviews | 1+ for production |
| CODEOWNERS | Platform team |

### GitHub Apps & Integrations

| Integration | Purpose |
|-------------|---------|
| GitHub Actions | CI/CD pipelines |
| GitHub Copilot | AI assistance |
| Dependabot | Dependency updates |
| Code Scanning | Security analysis |
| Secret Scanning | Credential detection |

### Repository Secrets

| Secret | Purpose |
|--------|---------|
| `AZURE_CLIENT_ID` | Azure service principal |
| `AZURE_TENANT_ID` | Azure AD tenant |
| `AZURE_SUBSCRIPTION_ID` | Target subscription |
| `ARM_CLIENT_SECRET` | SP secret (or use OIDC) |
| `ACR_LOGIN_SERVER` | Container registry URL |
| `ARGOCD_SERVER` | ArgoCD endpoint |

---

## Azure Requirements

### Subscription Requirements

| Requirement | Minimum |
|-------------|---------|
| Subscription Type | Pay-As-You-Go or EA |
| Resource Providers | See list below |
| Quotas | 20+ vCPUs per region |
| Permissions | Owner or Contributor + UAA |

### Required Resource Providers

```bash
# Register required providers
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
az provider register --namespace Microsoft.RedHatOpenShift  # For ARO
```

### Quota Requirements

| Resource Type | Dev | Staging | Prod |
|---------------|-----|---------|------|
| Standard D-series vCPUs | 12 | 20 | 40+ |
| Premium SSD Storage (GB) | 256 | 512 | 1024+ |
| Public IP Addresses | 2 | 4 | 6+ |
| Load Balancers | 1 | 2 | 3+ |

---

## Network Requirements

### CIDR Ranges (Default)

| Network | CIDR | Hosts |
|---------|------|-------|
| VNet | 10.0.0.0/16 | 65,536 |
| AKS Subnet | 10.0.0.0/22 | 1,024 |
| Services Subnet | 10.0.4.0/24 | 256 |
| Private Endpoints | 10.0.5.0/24 | 256 |
| Pod CIDR (overlay) | 10.244.0.0/16 | 65,536 |
| Service CIDR | 10.0.8.0/22 | 1,024 |

### Required Outbound Access

| Destination | Port | Purpose |
|-------------|------|---------|
| `*.microsoft.com` | 443 | Azure APIs |
| `*.azure.com` | 443 | Azure services |
| `ghcr.io` | 443 | GitHub Container Registry |
| `*.github.com` | 443 | GitHub APIs |
| `registry.redhat.io` | 443 | Red Hat images |
| `quay.io` | 443 | Quay images |

---

## Compatibility Matrix

### Tested Combinations

| AKS Version | Terraform | ArgoCD | RHDH | Status |
|-------------|-----------|--------|------|--------|
| 1.29.x | 1.7.x | 2.10.x | 1.2.x | ✓ Tested |
| 1.30.x | 1.8.x | 2.11.x | 1.3.x | ✓ Tested |
| 1.31.x | 1.9.x | 2.12.x | 1.4.x | ✓ Tested |

| ARO Version | Terraform | GitOps Operator | RHDH | Status |
|-------------|-----------|-----------------|------|--------|
| 4.14.x | 1.7.x | 1.11.x | 1.2.x | ✓ Tested |
| 4.15.x | 1.8.x | 1.12.x | 1.3.x | ✓ Tested |
| 4.16.x | 1.9.x | 1.13.x | 1.4.x | ✓ Tested |

---

**Document Owner:** Platform Engineering Team  
**Last Updated:** February 2026  
**Review Cycle:** Monthly
