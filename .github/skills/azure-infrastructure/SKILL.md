````skill
---
name: azure-infrastructure
description: 'Azure infrastructure provisioning for Three Horizons Accelerator. Use when deploying AKS clusters, networking, security, container registries, Key Vault. Covers resource groups, VNets, subnets, NSGs, private endpoints, managed identities, RBAC, and Defender for Cloud.'
license: Complete terms in LICENSE.txt
---

# Azure Infrastructure Skill

Comprehensive skill for provisioning and managing Azure infrastructure for the Three Horizons Accelerator platform.

**Version:** 1.0.0

---

## Overview

This skill encapsulates all tools required for Azure infrastructure provisioning:
- **MCP Servers**: azure, bash, filesystem
- **Scripts**: validate-*.sh, bootstrap.sh, platform-bootstrap.sh
- **Terraform Modules**: aks-cluster, networking, security, container-registry, naming
- **Golden Paths**: infrastructure-provisioning

---

## MCP Server Configuration

### Azure MCP Server

```json
{
  "azure": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-azure"],
    "description": "Azure CLI operations",
    "env": {
      "AZURE_SUBSCRIPTION_ID": "${AZURE_SUBSCRIPTION_ID}"
    },
    "capabilities": [
      "az group",
      "az aks",
      "az acr", 
      "az keyvault",
      "az network",
      "az identity",
      "az role",
      "az security",
      "az monitor"
    ]
  }
}
```

### Bash MCP Server

```json
{
  "bash": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-bash"],
    "description": "Shell command execution",
    "capabilities": ["bash", "sh", "curl", "jq", "yq"]
  }
}
```

---

## Core Commands

### Resource Group Management

```bash
# Create resource group with tags
az group create \
  --name rg-${PROJECT}-${ENV}-${LOCATION_SHORT} \
  --location ${LOCATION} \
  --tags Environment=${ENV} Project=${PROJECT} ManagedBy=Terraform

# Validate resource group exists
az group show --name ${RESOURCE_GROUP} --query "properties.provisioningState" -o tsv

# List resources in group
az resource list --resource-group ${RESOURCE_GROUP} --output table
```

### AKS Cluster Provisioning

```bash
# Create production-grade AKS cluster
az aks create \
  --resource-group ${RESOURCE_GROUP} \
  --name aks-${PROJECT}-${ENV}-${LOCATION_SHORT} \
  --location ${LOCATION} \
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
  --enable-defender \
  --enable-azure-monitor-metrics \
  --vnet-subnet-id ${SUBNET_ID} \
  --tags Environment=${ENV} Project=${PROJECT}

# Get cluster credentials
az aks get-credentials \
  --resource-group ${RESOURCE_GROUP} \
  --name ${AKS_CLUSTER_NAME}
```

### Networking

```bash
# Create VNet with subnets
az network vnet create \
  --resource-group ${RESOURCE_GROUP} \
  --name vnet-${PROJECT}-${ENV}-${LOCATION_SHORT} \
  --address-prefix 10.0.0.0/16 \
  --location ${LOCATION}

# Create AKS subnet
az network vnet subnet create \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name snet-aks \
  --address-prefixes 10.0.1.0/24

# Create Private Endpoints subnet
az network vnet subnet create \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name snet-private-endpoints \
  --address-prefixes 10.0.2.0/24 \
  --disable-private-endpoint-network-policies true
```

### Container Registry

```bash
# Create Premium ACR
az acr create \
  --resource-group ${RESOURCE_GROUP} \
  --name cr${PROJECT}${ENV}${LOCATION_SHORT} \
  --sku Premium \
  --admin-enabled false

# Attach ACR to AKS
az aks update \
  --resource-group ${RESOURCE_GROUP} \
  --name ${AKS_CLUSTER_NAME} \
  --attach-acr ${ACR_NAME}
```

### Key Vault

```bash
# Create Key Vault with RBAC
az keyvault create \
  --resource-group ${RESOURCE_GROUP} \
  --name kv-${PROJECT}-${ENV} \
  --location ${LOCATION} \
  --enable-rbac-authorization \
  --enable-purge-protection \
  --sku premium

# Assign Key Vault Secrets User role
az role assignment create \
  --assignee ${IDENTITY_PRINCIPAL_ID} \
  --role "Key Vault Secrets User" \
  --scope ${KEYVAULT_ID}
```

### Managed Identity

```bash
# Create User-Assigned Managed Identity
az identity create \
  --resource-group ${RESOURCE_GROUP} \
  --name id-${PROJECT}-${ENV}

# Create Federated Credential for Workload Identity
az identity federated-credential create \
  --name ${FED_CRED_NAME} \
  --identity-name ${IDENTITY_NAME} \
  --resource-group ${RESOURCE_GROUP} \
  --issuer ${AKS_OIDC_ISSUER} \
  --subject system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT_NAME}
```

---

## Scripts Reference

### Bootstrap Script

**Path:** `scripts/bootstrap.sh`

```bash
# Initialize platform infrastructure
./scripts/bootstrap.sh \
  --environment ${ENV} \
  --location ${LOCATION} \
  --project ${PROJECT}
```

### Platform Bootstrap

**Path:** `scripts/platform-bootstrap.sh`

```bash
# Full platform initialization
./scripts/platform-bootstrap.sh \
  --config config/sizing-profiles.yaml \
  --environment production
```

### Validation Scripts

**Path:** `scripts/validate-*.sh`

```bash
# Validate CLI prerequisites
./scripts/validate-cli-prerequisites.sh

# Validate naming conventions
./scripts/validate-naming.sh --resource-group ${RESOURCE_GROUP}

# Validate configuration
./scripts/validate-config.sh --config terraform/terraform.tfvars

# Validate deployment
./scripts/validate-deployment.sh \
  --resource-group ${RESOURCE_GROUP} \
  --cluster ${AKS_CLUSTER_NAME}
```

---

## Terraform Modules Reference

### AKS Cluster Module

**Path:** `terraform/modules/aks-cluster/`

```hcl
module "aks" {
  source = "./modules/aks-cluster"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  cluster_name        = local.aks_cluster_name
  kubernetes_version  = var.kubernetes_version
  
  default_node_pool = {
    name                = "system"
    vm_size             = "Standard_D4s_v3"
    node_count          = 3
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    vnet_subnet_id      = module.networking.aks_subnet_id
  }
  
  identity_type = "UserAssigned"
  identity_ids  = [azurerm_user_assigned_identity.aks.id]
  
  workload_identity_enabled = true
  oidc_issuer_enabled       = true
  
  tags = local.tags
}
```

### Networking Module

**Path:** `terraform/modules/networking/`

```hcl
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_name           = local.vnet_name
  address_space       = var.vnet_address_space
  
  subnets = {
    aks = {
      address_prefixes = ["10.0.1.0/24"]
    }
    private_endpoints = {
      address_prefixes                          = ["10.0.2.0/24"]
      private_endpoint_network_policies_enabled = false
    }
    databases = {
      address_prefixes = ["10.0.3.0/24"]
      delegation = {
        name = "postgresql"
        service_delegation = {
          name = "Microsoft.DBforPostgreSQL/flexibleServers"
        }
      }
    }
  }
  
  tags = local.tags
}
```

### Security Module

**Path:** `terraform/modules/security/`

```hcl
module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  key_vault_name      = local.key_vault_name
  
  enable_purge_protection     = true
  enable_rbac_authorization   = true
  soft_delete_retention_days  = 90
  
  network_acls = {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = var.allowed_ip_ranges
    virtual_network_subnet_ids = [
      module.networking.aks_subnet_id
    ]
  }
  
  tags = local.tags
}
```

### Container Registry Module

**Path:** `terraform/modules/container-registry/`

```hcl
module "acr" {
  source = "./modules/container-registry"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  registry_name       = local.acr_name
  sku                 = "Premium"
  
  admin_enabled                 = false
  public_network_access_enabled = false
  zone_redundancy_enabled       = true
  
  georeplications = var.enable_geo_replication ? [
    {
      location                = "westus2"
      zone_redundancy_enabled = true
    }
  ] : []
  
  tags = local.tags
}
```

### Naming Module

**Path:** `terraform/modules/naming/`

```hcl
module "naming" {
  source = "./modules/naming"

  project_name = var.project_name
  environment  = var.environment
  location     = var.location
}

# Outputs
output "resource_group_name" { value = module.naming.resource_group_name }
output "aks_cluster_name"    { value = module.naming.aks_cluster_name }
output "acr_name"            { value = module.naming.acr_name }
output "key_vault_name"      { value = module.naming.key_vault_name }
output "vnet_name"           { value = module.naming.vnet_name }
```

---

## Golden Path Templates Reference

### Infrastructure Provisioning

**Path:** `golden-paths/h1-foundation/infrastructure-provisioning/`

```yaml
# cookiecutter.json
{
  "project_name": "myproject",
  "environment": "dev",
  "location": "eastus",
  "platform_choice": "aks",
  "enable_private_cluster": true,
  "kubernetes_version": "1.30"
}
```

---

## Error Handling

### Common Errors and Solutions

#### Quota Exceeded

```bash
# Error: OperationNotAllowed - Quota exceeded
# Solution: Request quota increase or use smaller VM size

az vm list-usage --location ${LOCATION} --output table
az quota show --scope /subscriptions/${SUBSCRIPTION_ID}/providers/Microsoft.Compute/locations/${LOCATION}
```

#### Subnet Already In Use

```bash
# Error: SubnetAlreadyInUse
# Solution: Check for existing resources in subnet

az network vnet subnet show \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name ${SUBNET_NAME} \
  --query "ipConfigurations"
```

#### RBAC Permission Denied

```bash
# Error: AuthorizationFailed
# Solution: Check role assignments

az role assignment list \
  --assignee ${PRINCIPAL_ID} \
  --scope ${RESOURCE_ID} \
  --output table
```

#### Private Endpoint DNS Resolution

```bash
# Error: Cannot resolve private endpoint
# Solution: Create private DNS zone and link to VNet

az network private-dns zone create \
  --resource-group ${RESOURCE_GROUP} \
  --name privatelink.azurecr.io

az network private-dns link vnet create \
  --resource-group ${RESOURCE_GROUP} \
  --zone-name privatelink.azurecr.io \
  --name acr-dns-link \
  --virtual-network ${VNET_NAME} \
  --registration-enabled false
```

---

## Pre-Deployment Checklist

- [ ] Azure CLI installed and authenticated (`az login`)
- [ ] Correct subscription selected (`az account set -s ${SUBSCRIPTION_ID}`)
- [ ] Required Resource Providers registered
- [ ] Sufficient quota for VM sizes
- [ ] Network address space doesn't conflict with on-premises
- [ ] Naming conventions validated
- [ ] Tags strategy defined

## Post-Deployment Validation

```bash
# Run full validation suite
export RESOURCE_GROUP="rg-${PROJECT}-${ENV}"
export CLUSTER_NAME="aks-${PROJECT}-${ENV}"
export ACR_NAME="cr${PROJECT}${ENV}"
export KEYVAULT_NAME="kv-${PROJECT}-${ENV}"

./scripts/validate-deployment.sh
```

---

## Related Skills

- [azure-cli](../azure-cli/) - Azure CLI command reference
- [terraform-cli](../terraform-cli/) - Terraform CLI reference
- [kubectl-cli](../kubectl-cli/) - Kubernetes CLI reference
- [validation-scripts](../validation-scripts/) - Validation patterns

---

## References

- [Azure AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
- [Azure Landing Zones](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/well-architected/)

````
