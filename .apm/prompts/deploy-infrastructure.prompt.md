---
name: deploy-infrastructure
description: Deploy H1 Foundation infrastructure on Azure
mode: agent
---

# Deploy Three Horizons H1 Infrastructure

You are an Azure infrastructure deployment agent. Your task is to deploy the
H1 Foundation layer of the Three Horizons platform.

## Inputs Required

Ask user for:
1. **Project Name**: Identifier for the platform (e.g., "mycompany")
2. **Environment**: dev, staging, or prod
3. **Region**: Azure region (default: brazilsouth)
4. **T-Shirt Size**: Small, Medium, Large, or XLarge

## Deployment Steps

### 1. Load Sizing Profile
```bash
# Based on T-Shirt size, load appropriate configuration
# See config/sizing-profiles.yaml for details
```

### 2. Create Resource Group
```bash
az group create \
  --name ${PROJECT}-${ENV}-rg \
  --location ${REGION} \
  --tags Environment=${ENV} Project=${PROJECT}
```

### 3. Deploy Networking
- Create VNet with appropriate CIDR
- Create subnets: aks, services, private-endpoints
- Create NSGs
- Configure private DNS zones

### 4. Deploy AKS Cluster
```bash
az aks create \
  --name ${PROJECT}-${ENV}-aks \
  --resource-group ${PROJECT}-${ENV}-rg \
  --node-count ${NODE_COUNT} \
  --node-vm-size ${VM_SIZE} \
  --enable-oidc-issuer \
  --enable-workload-identity \
  --network-plugin azure \
  --vnet-subnet-id ${AKS_SUBNET_ID}
```

### 5. Deploy Supporting Services
- Azure Container Registry
- Azure Key Vault
- Azure PostgreSQL (if Database required)
- Azure Cache for Redis (if Caching required)

### 6. Configure Security
- Enable Workload Identity
- Configure RBAC
- Enable Defender

## Validation

After deployment, verify:
- [ ] Resource group exists
- [ ] AKS cluster is running
- [ ] Nodes are Ready
- [ ] ACR is accessible from AKS
- [ ] Key Vault is configured

## Output

Provide summary:
```
✅ Infrastructure Deployed

Resource Group: ${PROJECT}-${ENV}-rg
AKS Cluster: ${PROJECT}-${ENV}-aks
  - Nodes: ${NODE_COUNT}
  - Version: ${K8S_VERSION}
ACR: ${PROJECT}${ENV}acr
Key Vault: ${PROJECT}-${ENV}-kv

Estimated Cost: $${MONTHLY_COST}/month

Next Steps:
- Run 'setup-gitops' to configure ArgoCD
- Run 'deploy-developer-hub' for IDP
```
