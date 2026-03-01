# Infrastructure Architecture

The platform infrastructure is built on Microsoft Azure using Terraform, organized into 15 modules with strict dependency ordering and security-first defaults. All resources target the `brazilsouth` region for LGPD compliance, with `eastus2` used for AI Foundry model availability.

## Azure Kubernetes Service (AKS)

AKS is the compute backbone of the platform, running all workloads including RHDH, ArgoCD, and application services.

**Key configuration**:

- Kubernetes version 1.29+
- **System node pool**: Dedicated to cluster services (CoreDNS, kube-proxy, Calico)
- **User node pool**: Application workloads with auto-scaling enabled
- Calico network policy for pod-level network segmentation
- Workload Identity enabled for secure Azure service access
- Azure Policy addon for runtime compliance enforcement
- Microsoft Defender for Containers enabled in standard/enterprise modes

**Sizing by deployment mode**:

| Mode | Nodes | VM Size | Zones |
|------|-------|---------|-------|
| Express | 3 | Standard_D4s_v5 | Single |
| Standard | 5 | Standard_D4s_v5 | Multi-zone |
| Enterprise | 10 | Standard_D8s_v5 | Multi-zone |

## Networking

The networking module provisions an isolated virtual network with purpose-specific subnets:

- **AKS Nodes Subnet** -- Cluster node networking
- **AKS Pods Subnet** -- Pod overlay networking (Azure CNI)
- **Private Endpoints Subnet** -- PaaS service connectivity (Key Vault, PostgreSQL, Redis, ACR)
- **Bastion Subnet** -- Secure administrative access
- **Application Gateway Subnet** -- Ingress and WAF (enterprise mode)

NSGs enforce deny-by-default rules on all subnets. Private DNS zones resolve private endpoint FQDNs within the VNet. Route tables direct traffic through Azure Firewall when configured.

## Databases

- **PostgreSQL Flexible Server v16** -- Primary relational database for RHDH catalog and application data. Configured with geo-redundant backup, private endpoint access, and TLS 1.2+ enforcement.
- **Redis Cache** -- In-memory cache for session management and application caching. TLS 1.2+ enforced with private endpoint connectivity.

Both services are accessible only through private endpoints within the VNet.

## Key Vault

Azure Key Vault serves as the single source of truth for all secrets, certificates, and encryption keys. Configuration includes:

- RBAC-based access model (no access policies)
- Soft delete and purge protection enabled
- Private endpoint access only
- Integrated with External Secrets Operator via Workload Identity

## Container Registry

Azure Container Registry (ACR) stores container images with tier selection based on deployment mode:

| Mode | ACR Tier | Geo-Replication |
|------|----------|-----------------|
| Express | Basic | No |
| Standard | Standard | No |
| Enterprise | Premium | Yes |

AKS nodes authenticate to ACR via the AcrPull role assigned to the kubelet managed identity.

## Module Dependency Chain

Infrastructure modules must be deployed in this order:

```
networking --> security --> aks-cluster --> databases
                                       --> container-registry
                                       --> ai-foundry
                                       --> observability --> argocd
                                                        --> external-secrets
                                                        --> github-runners
```

All modules follow a consistent structure: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, and `README.md`. Feature flags (`enable_*` variables) control which modules are activated for a given deployment.
