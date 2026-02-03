---
name: aro-deployment
description: Azure Red Hat OpenShift cluster deployment operations
version: "1.0.0"
license: MIT
tools_required: ["az", "oc"]
---

## When to Use
- ARO cluster provisioning
- Cluster configuration
- OpenShift-specific setup

## Prerequisites
- Azure CLI authenticated
- OpenShift CLI installed
- ARO resource provider registered
- Sufficient quota for Worker VMs

## Commands

### Pre-deployment Checks
```bash
# Check ARO resource provider
az provider show -n Microsoft.RedHatOpenShift --query "registrationState"

# Check quota
az vm list-usage --location eastus2 -o table
```

### Cluster Deployment
```bash
# Create resource group
az group create --name rg-aro --location eastus2

# Create virtual network
az network vnet create \
  --name vnet-aro \
  --resource-group rg-aro \
  --address-prefixes 10.0.0.0/22

# Create master subnet
az network vnet subnet create \
  --name master-subnet \
  --resource-group rg-aro \
  --vnet-name vnet-aro \
  --address-prefixes 10.0.0.0/23

# Create worker subnet
az network vnet subnet create \
  --name worker-subnet \
  --resource-group rg-aro \
  --vnet-name vnet-aro \
  --address-prefixes 10.0.2.0/23

# Create ARO cluster
az aro create \
  --name aro-cluster \
  --resource-group rg-aro \
  --vnet vnet-aro \
  --master-subnet master-subnet \
  --worker-subnet worker-subnet \
  --pull-secret @pull-secret.txt
```

### Post-deployment
```bash
# Get cluster credentials
az aro list-credentials --name aro-cluster --resource-group rg-aro

# Get console URL
az aro show --name aro-cluster --resource-group rg-aro --query "consoleProfile.url" -o tsv

# Get API server URL
az aro show --name aro-cluster --resource-group rg-aro --query "apiserverProfile.url" -o tsv
```

## Best Practices
1. Configure pull-secret for Red Hat registry access
2. Enable private cluster for production
3. Integrate with Azure AD for authentication
4. Configure appropriate worker VM SKUs

## Output Format
1. Deployment steps completed
2. Cluster credentials
3. Console and API URLs
4. Next steps for configuration

## Integration with Agents
Used by: @aro-platform, @infrastructure
