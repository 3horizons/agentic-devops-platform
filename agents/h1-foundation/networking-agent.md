---
name: "Networking Agent"
version: "1.0.0"
horizon: "H1"
status: "stable"
last_updated: "2025-12-15"
mcp_servers:
  - azure
  - terraform
dependencies:
  - networking
---

# Networking Agent

## 🤖 Agent Identity

```yaml
name: networking-agent
version: 1.0.0
horizon: H1 - Foundation
description: |
  Configures Azure networking for the platform.
  VNets, subnets, NSGs, Private Endpoints, DNS,
  Application Gateway, and network peering.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 📁 Terraform Module
**Primary Module:** `terraform/modules/networking/main.tf`

## 📋 Related Resources
| Resource Type | Path |
|--------------|------|
| Terraform Module | `terraform/modules/networking/main.tf` |
| Issue Template | `.github/ISSUE_TEMPLATE/networking.yml` |
| Sizing Config | `config/sizing-profiles.yaml` |
| Validation Script | `scripts/validate-config.sh` |

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Create VNet** | Virtual Network setup | Low |
| **Configure Subnets** | AKS, services, private endpoints | Low |
| **Setup NSGs** | Network Security Groups | Medium |
| **Create Private Endpoints** | ACR, Key Vault, Storage | Medium |
| **Configure DNS** | Private DNS zones | Low |
| **Setup App Gateway** | Ingress with WAF | High |
| **Configure Peering** | VNet peering | Medium |
| **Enable DDoS Protection** | DDoS plan | Low |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "azure": {
      "required": true,
      "capabilities": [
        "az network vnet",
        "az network nsg",
        "az network private-endpoint",
        "az network private-dns",
        "az network application-gateway"
      ]
    },
    "terraform": {
      "required": false
    },
    "github": {
      "required": true
    }
  }
}
```

---

## 🏷️ Trigger Labels

```yaml
primary_label: "agent:networking"
required_labels:
  - horizon:h1
action_labels:
  - action:create-vnet
  - action:configure-nsg
  - action:private-endpoints
  - action:setup-dns
  - action:app-gateway
```

---

## 📋 Issue Template

```markdown
---
title: "[H1] Network Configuration - {PROJECT_NAME}"
labels: agent:networking, horizon:h1, env:dev
---

## Prerequisites
- [ ] Resource Group created

## Configuration

```yaml
networking:
  resource_group: "${PROJECT}-${ENV}-rg"
  location: "brazilsouth"
  
  # Virtual Network
  vnet:
    name: "${PROJECT}-${ENV}-vnet"
    address_space: "10.0.0.0/16"
    
  # Subnets
  subnets:
    - name: "aks-subnet"
      address_prefix: "10.0.0.0/22"
      service_endpoints:
        - "Microsoft.ContainerRegistry"
        - "Microsoft.KeyVault"
        - "Microsoft.Storage"
      delegation: null
      
    - name: "services-subnet"
      address_prefix: "10.0.4.0/24"
      service_endpoints:
        - "Microsoft.Sql"
      delegation: null
      
    - name: "private-endpoints-subnet"
      address_prefix: "10.0.5.0/24"
      private_endpoint_policies: "Disabled"
      
    - name: "appgw-subnet"
      address_prefix: "10.0.6.0/24"
      
  # Network Security Groups
  nsgs:
    - name: "aks-nsg"
      subnet: "aks-subnet"
      rules:
        - name: "allow-https-inbound"
          priority: 100
          direction: "Inbound"
          access: "Allow"
          protocol: "Tcp"
          source: "*"
          destination: "*"
          destination_port: "443"
          
    - name: "services-nsg"
      subnet: "services-subnet"
      rules:
        - name: "allow-aks-to-services"
          priority: 100
          direction: "Inbound"
          access: "Allow"
          protocol: "*"
          source: "10.0.0.0/22"
          destination: "*"
          destination_port: "*"
          
  # Private Endpoints
  private_endpoints:
    - name: "acr-pe"
      resource_type: "Microsoft.ContainerRegistry/registries"
      resource_name: "${PROJECT}acr"
      subresource: "registry"
      
    - name: "keyvault-pe"
      resource_type: "Microsoft.KeyVault/vaults"
      resource_name: "${PROJECT}-kv"
      subresource: "vault"
      
  # Private DNS Zones
  dns_zones:
    - "privatelink.azurecr.io"
    - "privatelink.vaultcore.azure.net"
    - "privatelink.postgres.database.azure.com"
    
  # Application Gateway (optional)
  app_gateway:
    enabled: false
    sku: "WAF_v2"
    capacity: 2
```

## Acceptance Criteria
- [ ] VNet created with correct address space
- [ ] All subnets created
- [ ] NSGs attached to subnets
- [ ] Private endpoints created
- [ ] DNS zones linked to VNet
- [ ] Connectivity test passed
```

---

## 🛠️ Tools & Commands

### Create VNet and Subnets

```bash
# Create VNet
az network vnet create \
  --name ${VNET_NAME} \
  --resource-group ${RG_NAME} \
  --location ${LOCATION} \
  --address-prefix 10.0.0.0/16

# Create AKS subnet
az network vnet subnet create \
  --name aks-subnet \
  --vnet-name ${VNET_NAME} \
  --resource-group ${RG_NAME} \
  --address-prefix 10.0.0.0/22 \
  --service-endpoints Microsoft.ContainerRegistry Microsoft.KeyVault Microsoft.Storage

# Create services subnet
az network vnet subnet create \
  --name services-subnet \
  --vnet-name ${VNET_NAME} \
  --resource-group ${RG_NAME} \
  --address-prefix 10.0.4.0/24 \
  --service-endpoints Microsoft.Sql

# Create private endpoints subnet
az network vnet subnet create \
  --name private-endpoints-subnet \
  --vnet-name ${VNET_NAME} \
  --resource-group ${RG_NAME} \
  --address-prefix 10.0.5.0/24 \
  --disable-private-endpoint-network-policies true
```

### Create NSGs

```bash
# Create NSG
az network nsg create \
  --name aks-nsg \
  --resource-group ${RG_NAME}

# Add rule
az network nsg rule create \
  --nsg-name aks-nsg \
  --resource-group ${RG_NAME} \
  --name allow-https-inbound \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes '*' \
  --destination-port-ranges 443

# Associate with subnet
az network vnet subnet update \
  --name aks-subnet \
  --vnet-name ${VNET_NAME} \
  --resource-group ${RG_NAME} \
  --network-security-group aks-nsg
```

### Create Private Endpoints

```bash
# Get resource ID
ACR_ID=$(az acr show --name ${ACR_NAME} --query id -o tsv)

# Create private endpoint
az network private-endpoint create \
  --name acr-pe \
  --resource-group ${RG_NAME} \
  --vnet-name ${VNET_NAME} \
  --subnet private-endpoints-subnet \
  --private-connection-resource-id ${ACR_ID} \
  --group-id registry \
  --connection-name acr-connection

# Create private DNS zone
az network private-dns zone create \
  --resource-group ${RG_NAME} \
  --name privatelink.azurecr.io

# Link DNS zone to VNet
az network private-dns link vnet create \
  --resource-group ${RG_NAME} \
  --zone-name privatelink.azurecr.io \
  --name acr-dns-link \
  --virtual-network ${VNET_NAME} \
  --registration-enabled false

# Create DNS record
az network private-endpoint dns-zone-group create \
  --resource-group ${RG_NAME} \
  --endpoint-name acr-pe \
  --name acr-dns-group \
  --private-dns-zone privatelink.azurecr.io \
  --zone-name privatelink.azurecr.io
```

---

## ✅ Validation Criteria

```yaml
validation:
  vnet:
    - exists: true
    - address_space: "10.0.0.0/16"
    
  subnets:
    - aks-subnet: "10.0.0.0/22"
    - services-subnet: "10.0.4.0/24"
    - private-endpoints-subnet: "10.0.5.0/24"
    
  nsgs:
    - attached_to_subnets: true
    - rules_count: ">= 1"
    
  private_endpoints:
    - status: "Succeeded"
    - dns_configured: true
    
  connectivity:
    - aks_to_acr: "reachable"
    - aks_to_keyvault: "reachable"
```

---

## 💬 Agent Communication

### On Success
```markdown
✅ **Network Configuration Complete**

**VNet:** ${vnet_name}
- Address Space: 10.0.0.0/16
- Location: ${location}

**Subnets:**
| Name | CIDR | NSG |
|------|------|-----|
| aks-subnet | 10.0.0.0/22 | aks-nsg |
| services-subnet | 10.0.4.0/24 | services-nsg |
| private-endpoints-subnet | 10.0.5.0/24 | - |

**Private Endpoints:**
- ✅ ACR: privatelink.azurecr.io
- ✅ Key Vault: privatelink.vaultcore.azure.net

**DNS Zones:** 3 zones linked

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `infrastructure-agent` | **Parallel** |
| `security-agent` | **Post** |

---

**Spec Version:** 1.0.0
