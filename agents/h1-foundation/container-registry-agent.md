---
name: "Container Registry Agent"
version: "1.0.0"
horizon: "H1"
status: "stable"
last_updated: "2025-12-15"
mcp_servers:
  - azure
  - kubernetes
dependencies:
  - container-registry
  - networking
---

# Container Registry Agent

## 🤖 Agent Identity

```yaml
name: container-registry-agent
version: 1.0.0
horizon: H1 - Foundation
description: |
  Manages Azure Container Registry (ACR) setup and configuration.
  Creates registry, configures geo-replication, sets up retention
  policies, and integrates with AKS.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 📁 Terraform Module
**Primary Module:** `terraform/modules/container-registry/main.tf`

## 📋 Related Resources
| Resource Type | Path |
|--------------|------|
| Terraform Module | `terraform/modules/container-registry/main.tf` |
| Issue Template | `.github/ISSUE_TEMPLATE/container-registry.yml` |
| Sizing Config | `config/sizing-profiles.yaml` |

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Create ACR** | Provision container registry | Low |
| **Configure SKU** | Basic, Standard, Premium | Low |
| **Setup Geo-replication** | Multi-region replication | Medium |
| **Configure Retention** | Image retention policies | Low |
| **Enable Content Trust** | Image signing | Medium |
| **Attach to AKS** | AKS pull permissions | Low |
| **Import Images** | Import base images | Low |
| **Setup Webhooks** | Event notifications | Low |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "azure": {
      "required": true,
      "capabilities": [
        "az acr create",
        "az acr update",
        "az acr import",
        "az acr repository"
      ]
    },
    "kubernetes": {
      "required": true,
      "capabilities": ["kubectl"]
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
primary_label: "agent:acr"
required_labels:
  - horizon:h1
```

---

## 📋 Issue Template

```markdown
---
title: "[H1] Setup Container Registry - {PROJECT_NAME}"
labels: agent:acr, horizon:h1, env:dev
---

## Prerequisites
- [ ] Resource Group created
- [ ] (Optional) VNet for private endpoint

## Configuration

```yaml
acr:
  name: "${PROJECT}${ENV}acr"  # Must be globally unique
  resource_group: "${PROJECT}-${ENV}-rg"
  location: "brazilsouth"
  
  # SKU (Basic, Standard, Premium)
  sku: "Premium"
  
  # Admin access (not recommended for production)
  admin_enabled: false
  
  # Network
  network:
    public_access: false  # Premium only
    private_endpoint: true
    
  # Geo-replication (Premium only)
  geo_replication:
    enabled: true
    locations:
      - "eastus"
      
  # Retention policy
  retention:
    enabled: true
    days: 30
    
  # Content trust (image signing)
  content_trust:
    enabled: true
    
  # Import base images
  import_images:
    - source: "mcr.microsoft.com/dotnet/aspnet:8.0"
      destination: "dotnet/aspnet:8.0"
    - source: "mcr.microsoft.com/dotnet/sdk:8.0"
      destination: "dotnet/sdk:8.0"
      
  # AKS integration
  aks_integration:
    cluster_name: "${PROJECT}-${ENV}-aks"
    attach: true
```

## Acceptance Criteria
- [ ] ACR created with Premium SKU
- [ ] Private endpoint configured
- [ ] Geo-replication enabled
- [ ] Retention policy set
- [ ] AKS attached
- [ ] Base images imported
```

---

## 🛠️ Tools & Commands

### Create ACR

```bash
# Create ACR
az acr create \
  --name ${ACR_NAME} \
  --resource-group ${RG_NAME} \
  --location ${LOCATION} \
  --sku Premium \
  --admin-enabled false

# Verify
az acr show --name ${ACR_NAME} --query "{name:name, sku:sku.name, status:provisioningState}"
```

### Configure Network

```bash
# Disable public access
az acr update \
  --name ${ACR_NAME} \
  --public-network-enabled false

# Create private endpoint (requires networking-agent)
ACR_ID=$(az acr show --name ${ACR_NAME} --query id -o tsv)

az network private-endpoint create \
  --name ${ACR_NAME}-pe \
  --resource-group ${RG_NAME} \
  --vnet-name ${VNET_NAME} \
  --subnet private-endpoints-subnet \
  --private-connection-resource-id ${ACR_ID} \
  --group-id registry \
  --connection-name acr-connection
```

### Setup Geo-replication

```bash
# Add replication
az acr replication create \
  --registry ${ACR_NAME} \
  --location eastus

# List replications
az acr replication list --registry ${ACR_NAME} -o table
```

### Configure Retention

```bash
# Enable retention policy
az acr config retention update \
  --registry ${ACR_NAME} \
  --status enabled \
  --days 30 \
  --type UntaggedManifests
```

### Attach to AKS

```bash
# Attach ACR to AKS (grants AcrPull)
az aks update \
  --name ${AKS_NAME} \
  --resource-group ${RG_NAME} \
  --attach-acr ${ACR_NAME}

# Verify
az aks check-acr --name ${AKS_NAME} --resource-group ${RG_NAME} --acr ${ACR_NAME}.azurecr.io
```

### Import Base Images

```bash
# Import from MCR
az acr import \
  --name ${ACR_NAME} \
  --source mcr.microsoft.com/dotnet/aspnet:8.0 \
  --image dotnet/aspnet:8.0

az acr import \
  --name ${ACR_NAME} \
  --source mcr.microsoft.com/dotnet/sdk:8.0 \
  --image dotnet/sdk:8.0

# List repositories
az acr repository list --name ${ACR_NAME} -o table
```

### Setup Webhook

```bash
# Create webhook for CI/CD notifications
az acr webhook create \
  --name cicdwebhook \
  --registry ${ACR_NAME} \
  --uri "https://api.github.com/repos/${ORG}/${REPO}/dispatches" \
  --actions push delete \
  --headers "Authorization=Bearer ${GITHUB_TOKEN}" "Accept=application/vnd.github+json"
```

---

## ✅ Validation Criteria

```yaml
validation:
  acr:
    - exists: true
    - sku: "Premium"
    - provisioning_state: "Succeeded"
    
  network:
    - public_access: false
    - private_endpoint: "Succeeded"
    
  geo_replication:
    - locations_count: ">= 2"
    
  retention:
    - enabled: true
    - days: 30
    
  aks_integration:
    - attached: true
    - pull_test: "successful"
    
  images:
    - imported_count: ">= 2"
```

---

## 💬 Agent Communication

### On Success
```markdown
✅ **Container Registry Configured**

**ACR:** ${acr_name}.azurecr.io
- SKU: Premium
- Location: ${location}

**Network:**
- Public Access: ❌ Disabled
- Private Endpoint: ✅ Configured

**Geo-replication:**
| Location | Status |
|----------|--------|
| brazilsouth | ✅ Primary |
| eastus | ✅ Replica |

**Policies:**
- Retention: 30 days
- Content Trust: Enabled

**AKS Integration:** ✅ Attached to ${aks_name}

**Imported Images:**
- dotnet/aspnet:8.0
- dotnet/sdk:8.0

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `networking-agent` | **Prerequisite** (for PE) |
| `infrastructure-agent` | **Parallel** |
| `security-agent` | **Post** |

---

**Spec Version:** 1.0.0
