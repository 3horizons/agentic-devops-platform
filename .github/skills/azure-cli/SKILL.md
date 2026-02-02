---
name: azure-cli
description: 'Azure CLI (az) reference for cloud infrastructure. Use when asked to create Azure resources, manage AKS/ACR/Key Vault, setup networking, configure RBAC. Covers az aks, az acr, az keyvault, az network, az identity commands.'
license: Complete terms in LICENSE.txt
---

# Azure CLI (az)

USE FOR:
- `az` commands and Azure resource management
- Creating, updating, deleting Azure resources
- AKS cluster operations (`az aks`)
- ACR registry management (`az acr`)
- Key Vault operations (`az keyvault`)
- Networking configuration (`az network`)
- RBAC and identity management (`az role`, `az identity`)
- Resource group and subscription management

DO NOT USE FOR:
- Terraform-based infrastructure (use terraform-cli)
- Kubernetes pod/deployment management (use kubectl-cli)
- OpenShift-specific operations (use oc-cli)
- GitHub operations (use github-cli)
- ARM templates authoring (use azure-infrastructure skill)

Comprehensive reference for Azure CLI - manage Azure resources from the command line.

**Version:** 2.70.0+ (current as of 2026)

## Prerequisites

### Installation

```bash
# macOS
brew install azure-cli

# Linux (Debian/Ubuntu)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Linux (RHEL/CentOS)
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf install azure-cli

# Windows
winget install Microsoft.AzureCLI

# Verify installation
az --version
```

### Authentication

```bash
# Interactive login
az login

# Login with device code (for remote terminals)
az login --use-device-code

# Login with service principal
az login --service-principal \
  --username $APP_ID \
  --password $CLIENT_SECRET \
  --tenant $TENANT_ID

# Login with managed identity
az login --identity

# Login with specific tenant
az login --tenant $TENANT_ID

# Check current account
az account show

# List all subscriptions
az account list --output table

# Set subscription
az account set --subscription $SUBSCRIPTION_ID
```

## CLI Structure

```
az                          # Root command
├── account                 # Subscription management
├── aks                     # Azure Kubernetes Service
├── acr                     # Container Registry
├── network                 # Networking
├── keyvault                # Key Vault
├── identity                # Managed Identities
├── policy                  # Azure Policy
├── role                    # RBAC
├── group                   # Resource Groups
├── resource                # Generic resources
├── deployment              # Terraform deployments
├── monitor                 # Monitoring
├── ad                      # Entra ID (Azure AD)
└── extension               # CLI extensions
```

## Resource Groups

### Create Resource Group

```bash
# Basic creation
az group create --name rg-myproject-dev-eastus --location eastus

# With tags
az group create \
  --name rg-myproject-dev-eastus \
  --location eastus \
  --tags Environment=dev Project=myproject Owner=team@company.com
```

### List Resource Groups

```bash
# List all
az group list --output table

# Filter by tag
az group list --tag Environment=dev --output table

# Filter by location
az group list --query "[?location=='eastus']" --output table
```

### Delete Resource Group

```bash
# Delete with confirmation
az group delete --name rg-myproject-dev-eastus

# Delete without confirmation
az group delete --name rg-myproject-dev-eastus --yes --no-wait
```

## Azure Kubernetes Service (AKS)

### Create AKS Cluster

```bash
# Basic cluster
az aks create \
  --resource-group rg-myproject-dev-eastus \
  --name aks-myproject-dev-eastus \
  --node-count 3 \
  --generate-ssh-keys

# Production cluster with best practices
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --location $LOCATION \
  --kubernetes-version 1.30 \
  --node-count 3 \
  --node-vm-size Standard_D4s_v3 \
  --enable-managed-identity \
  --enable-workload-identity \
  --enable-oidc-issuer \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 10 \
  --network-plugin azure \
  --network-policy azure \
  --enable-private-cluster \
  --private-dns-zone system \
  --enable-defender \
  --enable-azure-monitor-metrics \
  --tags Environment=$ENV Project=$PROJECT
```

### Get Credentials

```bash
# Get kubeconfig
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME

# Admin credentials (not recommended for production)
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --admin

# Overwrite existing context
az aks get-credentials \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --overwrite-existing
```

### Manage AKS

```bash
# List clusters
az aks list --output table

# Show cluster details
az aks show \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME

# Get upgrade versions
az aks get-upgrades \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --output table

# Upgrade cluster
az aks upgrade \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --kubernetes-version 1.31

# Scale node pool
az aks scale \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --node-count 5

# Stop cluster (save costs)
az aks stop \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME

# Start cluster
az aks start \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME
```

### Node Pools

```bash
# List node pools
az aks nodepool list \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --output table

# Add node pool
az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name gpupool \
  --node-count 2 \
  --node-vm-size Standard_NC6s_v3 \
  --node-taints "gpu=true:NoSchedule"

# Scale node pool
az aks nodepool scale \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name nodepool1 \
  --node-count 5

# Delete node pool
az aks nodepool delete \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name gpupool
```

### AKS OIDC & Workload Identity

```bash
# Get OIDC issuer URL
az aks show \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --query "oidcIssuerProfile.issuerUrl" \
  --output tsv

# Create federated credential
az identity federated-credential create \
  --name $FED_IDENTITY_NAME \
  --identity-name $USER_ASSIGNED_IDENTITY_NAME \
  --resource-group $RESOURCE_GROUP \
  --issuer $AKS_OIDC_ISSUER \
  --subject system:serviceaccount:$NAMESPACE:$SERVICE_ACCOUNT_NAME
```

## Container Registry (ACR)

### Create ACR

```bash
# Basic SKU
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic

# Premium with geo-replication
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Premium \
  --admin-enabled false
```

### ACR Operations

```bash
# Login to ACR
az acr login --name $ACR_NAME

# List repositories
az acr repository list --name $ACR_NAME --output table

# Show tags
az acr repository show-tags \
  --name $ACR_NAME \
  --repository myapp \
  --output table

# Delete image
az acr repository delete \
  --name $ACR_NAME \
  --image myapp:v1.0.0 \
  --yes
```

### Attach ACR to AKS

```bash
# Attach ACR to AKS (grants pull permission)
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --attach-acr $ACR_NAME

# Detach ACR
az aks update \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --detach-acr $ACR_NAME
```

## Key Vault

### Create Key Vault

```bash
# Create Key Vault
az keyvault create \
  --resource-group $RESOURCE_GROUP \
  --name $KEYVAULT_NAME \
  --location $LOCATION \
  --enable-rbac-authorization \
  --enable-purge-protection \
  --sku premium
```

### Secret Management

```bash
# Set secret
az keyvault secret set \
  --vault-name $KEYVAULT_NAME \
  --name mySecret \
  --value "secret-value"

# Get secret
az keyvault secret show \
  --vault-name $KEYVAULT_NAME \
  --name mySecret \
  --query value \
  --output tsv

# List secrets
az keyvault secret list \
  --vault-name $KEYVAULT_NAME \
  --output table

# Delete secret
az keyvault secret delete \
  --vault-name $KEYVAULT_NAME \
  --name mySecret
```

### Key Management

```bash
# Create key
az keyvault key create \
  --vault-name $KEYVAULT_NAME \
  --name myKey \
  --kty RSA \
  --size 4096

# List keys
az keyvault key list \
  --vault-name $KEYVAULT_NAME \
  --output table
```

## Networking

### Virtual Network

```bash
# Create VNet
az network vnet create \
  --resource-group $RESOURCE_GROUP \
  --name vnet-myproject-dev-eastus \
  --address-prefix 10.0.0.0/16 \
  --location $LOCATION

# Create subnet
az network vnet subnet create \
  --resource-group $RESOURCE_GROUP \
  --vnet-name vnet-myproject-dev-eastus \
  --name snet-aks \
  --address-prefixes 10.0.1.0/24

# List VNets
az network vnet list \
  --resource-group $RESOURCE_GROUP \
  --output table

# Show VNet
az network vnet show \
  --resource-group $RESOURCE_GROUP \
  --name vnet-myproject-dev-eastus
```

### Network Security Groups

```bash
# Create NSG
az network nsg create \
  --resource-group $RESOURCE_GROUP \
  --name nsg-aks

# Add rule
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name nsg-aks \
  --name AllowHTTPS \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 443

# List rules
az network nsg rule list \
  --resource-group $RESOURCE_GROUP \
  --nsg-name nsg-aks \
  --output table
```

### Private Endpoints

```bash
# Create private endpoint
az network private-endpoint create \
  --resource-group $RESOURCE_GROUP \
  --name pe-keyvault \
  --vnet-name vnet-myproject-dev-eastus \
  --subnet snet-private-endpoints \
  --private-connection-resource-id $KEYVAULT_ID \
  --group-ids vault \
  --connection-name keyvault-connection

# Create private DNS zone
az network private-dns zone create \
  --resource-group $RESOURCE_GROUP \
  --name privatelink.vaultcore.azure.net

# Link DNS to VNet
az network private-dns link vnet create \
  --resource-group $RESOURCE_GROUP \
  --zone-name privatelink.vaultcore.azure.net \
  --name keyvault-dns-link \
  --virtual-network vnet-myproject-dev-eastus \
  --registration-enabled false
```

## Managed Identity

### User-Assigned Identity

```bash
# Create identity
az identity create \
  --resource-group $RESOURCE_GROUP \
  --name id-myproject-dev

# Get identity info
az identity show \
  --resource-group $RESOURCE_GROUP \
  --name id-myproject-dev \
  --query "{clientId:clientId, principalId:principalId}" \
  --output json

# List identities
az identity list \
  --resource-group $RESOURCE_GROUP \
  --output table
```

### Role Assignment

```bash
# Assign role to identity
az role assignment create \
  --assignee $IDENTITY_CLIENT_ID \
  --role "Key Vault Secrets User" \
  --scope $KEYVAULT_ID

# Assign role at resource group
az role assignment create \
  --assignee $IDENTITY_CLIENT_ID \
  --role "Contributor" \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP

# List role assignments
az role assignment list \
  --assignee $IDENTITY_CLIENT_ID \
  --output table
```

## Azure Policy

### Policy Operations

```bash
# List policy definitions
az policy definition list \
  --query "[?contains(displayName, 'Kubernetes')]" \
  --output table

# Create policy assignment
az policy assignment create \
  --name "require-https" \
  --policy "/providers/Microsoft.Authorization/policyDefinitions/$POLICY_ID" \
  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP

# List assignments
az policy assignment list \
  --resource-group $RESOURCE_GROUP \
  --output table

# Check compliance
az policy state summarize \
  --resource-group $RESOURCE_GROUP
```

## Monitoring

### Log Analytics

```bash
# Create workspace
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name law-myproject-dev \
  --location $LOCATION

# Get workspace ID
az monitor log-analytics workspace show \
  --resource-group $RESOURCE_GROUP \
  --workspace-name law-myproject-dev \
  --query customerId \
  --output tsv

# Query logs
az monitor log-analytics query \
  --workspace $WORKSPACE_ID \
  --analytics-query "AzureActivity | limit 10"
```

### Diagnostic Settings

```bash
# Enable diagnostics on AKS
az monitor diagnostic-settings create \
  --name aks-diagnostics \
  --resource $AKS_ID \
  --logs '[{"category":"kube-apiserver","enabled":true}]' \
  --workspace $WORKSPACE_ID
```

## Entra ID (Azure AD)

### Application Registration

```bash
# Create app registration
az ad app create \
  --display-name "myapp-dev" \
  --sign-in-audience AzureADMyOrg

# Create service principal
az ad sp create \
  --id $APP_ID

# Create client secret
az ad app credential reset \
  --id $APP_ID \
  --years 1
```

### Group Management

```bash
# List groups
az ad group list --output table

# Get group members
az ad group member list \
  --group $GROUP_ID \
  --output table

# Add member to group
az ad group member add \
  --group $GROUP_ID \
  --member-id $USER_ID
```

## Extensions

### Manage Extensions

```bash
# List installed
az extension list --output table

# List available
az extension list-available --output table

# Install extension
az extension add --name aks-preview
az extension add --name azure-devops

# Update extension
az extension update --name aks-preview

# Remove extension
az extension remove --name aks-preview
```

## Output Formats

```bash
# Table (human-readable)
az account list --output table

# JSON (default)
az account list --output json

# TSV (tab-separated)
az account list --output tsv

# YAML
az account list --output yaml

# None (no output)
az group create ... --output none
```

## JMESPath Queries

```bash
# Filter by property
az aks list --query "[?location=='eastus']"

# Select specific fields
az aks list --query "[].{Name:name, Location:location, Version:kubernetesVersion}"

# Get first result
az aks list --query "[0]"

# Complex filter
az aks list --query "[?provisioningState=='Succeeded' && tags.Environment=='dev']"

# Extract single value
az aks show -g $RG -n $NAME --query "identity.principalId" --output tsv
```

## Common Workflows

### Deploy AKS with ACR

```bash
# 1. Create resource group
az group create --name $RG --location $LOCATION

# 2. Create ACR
az acr create --resource-group $RG --name $ACR --sku Premium

# 3. Create AKS with workload identity
az aks create \
  --resource-group $RG \
  --name $AKS \
  --enable-managed-identity \
  --enable-workload-identity \
  --enable-oidc-issuer \
  --attach-acr $ACR \
  --network-plugin azure

# 4. Get credentials
az aks get-credentials --resource-group $RG --name $AKS
```

### Setup Key Vault with AKS

```bash
# 1. Create Key Vault
az keyvault create --resource-group $RG --name $KV --enable-rbac-authorization

# 2. Create managed identity
az identity create --resource-group $RG --name $IDENTITY

# 3. Assign Key Vault role
az role assignment create \
  --assignee $(az identity show -g $RG -n $IDENTITY --query principalId -o tsv) \
  --role "Key Vault Secrets User" \
  --scope $(az keyvault show --name $KV --query id -o tsv)

# 4. Create federated credential
az identity federated-credential create \
  --name fed-credential \
  --identity-name $IDENTITY \
  --resource-group $RG \
  --issuer $(az aks show -g $RG -n $AKS --query oidcIssuerProfile.issuerUrl -o tsv) \
  --subject system:serviceaccount:default:my-service-account
```

## Best Practices

1. **Always use `--output` for scripts**: Use `--output tsv` or `--output json` for reliable parsing
2. **Use resource IDs**: Store and reference resources by ID, not name
3. **Enable RBAC**: Use `--enable-rbac-authorization` for Key Vault
4. **Managed Identity**: Prefer managed identity over service principals
5. **Tags**: Always tag resources for cost management and organization
6. **Query for IDs**: Use `--query id --output tsv` to get resource IDs

## References

- [Azure CLI Documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [JMESPath Tutorial](https://jmespath.org/tutorial.html)
