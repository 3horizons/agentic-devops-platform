---
name: "Database Agent"
version: "1.0.0"
horizon: "H1"
status: "stable"
last_updated: "2025-12-15"
mcp_servers:
  - azure
  - terraform
  - kubernetes
dependencies:
  - databases
  - purview
---

# Database Agent

## 🤖 Agent Identity

```yaml
name: database-agent
version: 1.0.0
horizon: H1 - Foundation
description: |
  Provisions and configures managed databases for the platform.
  Azure PostgreSQL Flexible Server, Azure Cache for Redis,
  Cosmos DB, and Azure SQL as needed.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 📁 Terraform Module
**Primary Module:** `terraform/modules/databases/main.tf`

## 📋 Related Resources
| Resource Type | Path |
|--------------|------|
| Terraform Module | `terraform/modules/databases/main.tf` |
| Issue Template | `.github/ISSUE_TEMPLATE/database.yml` |
| Sizing Config | `config/sizing-profiles.yaml` |
| Purview Integration | `terraform/modules/purview/main.tf` |

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Create PostgreSQL** | Flexible Server setup | Medium |
| **Create Redis Cache** | Azure Cache for Redis | Low |
| **Create Cosmos DB** | NoSQL database | Medium |
| **Create SQL Database** | Azure SQL | Medium |
| **Configure HA** | High availability setup | Medium |
| **Setup Backup** | Backup policies | Low |
| **Create Databases** | Individual databases | Low |
| **Manage Users** | Database users/roles | Low |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "azure": {
      "required": true,
      "capabilities": [
        "az postgres flexible-server",
        "az redis",
        "az cosmosdb",
        "az sql"
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
primary_label: "agent:database"
required_labels:
  - horizon:h1
action_labels:
  - action:create-postgres
  - action:create-redis
  - action:create-cosmosdb
  - action:create-sql
```

---

## 📋 Issue Template

```markdown
---
title: "[H1] Database Setup - {PROJECT_NAME}"
labels: agent:database, horizon:h1, env:dev
---

## Prerequisites
- [ ] Resource Group created
- [ ] VNet and subnets configured
- [ ] Key Vault for secrets

## Configuration

```yaml
databases:
  resource_group: "${PROJECT}-${ENV}-rg"
  location: "brazilsouth"
  
  # PostgreSQL Flexible Server
  postgresql:
    enabled: true
    name: "${PROJECT}-${ENV}-postgres"
    version: "16"
    sku: "Standard_D2ds_v5"
    storage_gb: 128
    
    # High Availability
    ha:
      enabled: true
      mode: "ZoneRedundant"  # or SameZone
      
    # Network
    network:
      delegated_subnet: "services-subnet"
      private_dns_zone: true
      
    # Backup
    backup:
      retention_days: 7
      geo_redundant: false
      
    # Databases to create
    databases:
      - name: "rhdh"
        charset: "UTF8"
      - name: "argocd"
        charset: "UTF8"
      - name: "apps"
        charset: "UTF8"
        
    # Admin
    admin_user: "pgadmin"
    # Password from Key Vault
    
  # Redis Cache
  redis:
    enabled: true
    name: "${PROJECT}-${ENV}-redis"
    sku: "Premium"
    capacity: 1
    family: "P"
    
    # Features
    features:
      non_ssl_port: false
      minimum_tls: "1.2"
      
    # Network
    network:
      private_endpoint: true
      
  # Cosmos DB (optional)
  cosmosdb:
    enabled: false
    name: "${PROJECT}-${ENV}-cosmos"
    api: "sql"  # sql, mongodb, cassandra, gremlin, table
```

## Acceptance Criteria
- [ ] PostgreSQL server created
- [ ] Databases created (rhdh, argocd, apps)
- [ ] Redis cache running
- [ ] Private endpoints configured
- [ ] Credentials in Key Vault
- [ ] Connectivity from AKS verified
```

---

## 🛠️ Tools & Commands

### Create PostgreSQL Flexible Server

```bash
# Get subnet ID
SUBNET_ID=$(az network vnet subnet show \
  --name services-subnet \
  --vnet-name ${VNET_NAME} \
  --resource-group ${RG_NAME} \
  --query id -o tsv)

# Create private DNS zone
az network private-dns zone create \
  --resource-group ${RG_NAME} \
  --name "${PROJECT}.postgres.database.azure.com"

az network private-dns link vnet create \
  --resource-group ${RG_NAME} \
  --zone-name "${PROJECT}.postgres.database.azure.com" \
  --name postgres-dns-link \
  --virtual-network ${VNET_NAME} \
  --registration-enabled false

# Generate password
POSTGRES_PASSWORD=$(openssl rand -base64 24)

# Store in Key Vault
az keyvault secret set \
  --vault-name ${KV_NAME} \
  --name "postgres-admin-password" \
  --value "${POSTGRES_PASSWORD}"

# Create server
az postgres flexible-server create \
  --name ${POSTGRES_NAME} \
  --resource-group ${RG_NAME} \
  --location ${LOCATION} \
  --version 16 \
  --sku-name Standard_D2ds_v5 \
  --storage-size 128 \
  --admin-user pgadmin \
  --admin-password "${POSTGRES_PASSWORD}" \
  --subnet ${SUBNET_ID} \
  --private-dns-zone "${PROJECT}.postgres.database.azure.com" \
  --high-availability ZoneRedundant \
  --backup-retention 7

# Create databases
az postgres flexible-server db create \
  --resource-group ${RG_NAME} \
  --server-name ${POSTGRES_NAME} \
  --database-name rhdh

az postgres flexible-server db create \
  --resource-group ${RG_NAME} \
  --server-name ${POSTGRES_NAME} \
  --database-name argocd

az postgres flexible-server db create \
  --resource-group ${RG_NAME} \
  --server-name ${POSTGRES_NAME} \
  --database-name apps
```

### Create Redis Cache

```bash
# Create Redis
az redis create \
  --name ${REDIS_NAME} \
  --resource-group ${RG_NAME} \
  --location ${LOCATION} \
  --sku Premium \
  --vm-size P1 \
  --minimum-tls-version 1.2

# Get access key
REDIS_KEY=$(az redis list-keys \
  --name ${REDIS_NAME} \
  --resource-group ${RG_NAME} \
  --query primaryKey -o tsv)

# Store in Key Vault
az keyvault secret set \
  --vault-name ${KV_NAME} \
  --name "redis-primary-key" \
  --value "${REDIS_KEY}"

# Create private endpoint
REDIS_ID=$(az redis show --name ${REDIS_NAME} --resource-group ${RG_NAME} --query id -o tsv)

az network private-endpoint create \
  --name ${REDIS_NAME}-pe \
  --resource-group ${RG_NAME} \
  --vnet-name ${VNET_NAME} \
  --subnet private-endpoints-subnet \
  --private-connection-resource-id ${REDIS_ID} \
  --group-id redisCache \
  --connection-name redis-connection
```

### Create Kubernetes Secrets

```bash
# Create ExternalSecret for PostgreSQL
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: postgres-credentials
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: azure-keyvault
    kind: ClusterSecretStore
  target:
    name: postgres-credentials
  data:
    - secretKey: password
      remoteRef:
        key: postgres-admin-password
EOF

# Create ExternalSecret for Redis
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: redis-credentials
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: azure-keyvault
    kind: ClusterSecretStore
  target:
    name: redis-credentials
  data:
    - secretKey: primary-key
      remoteRef:
        key: redis-primary-key
EOF
```

---

## ✅ Validation Criteria

```yaml
validation:
  postgresql:
    - status: "Ready"
    - ha_enabled: true
    - databases_count: 3
    - private_endpoint: true
    - connectivity_test: "successful"
    
  redis:
    - status: "Running"
    - tls_minimum: "1.2"
    - private_endpoint: true
    - ping_test: "PONG"
    
  secrets:
    - keyvault_secrets: ["postgres-admin-password", "redis-primary-key"]
    - k8s_externalsecrets: ["postgres-credentials", "redis-credentials"]
```

---

## 💬 Agent Communication

### On Success
```markdown
✅ **Database Infrastructure Complete**

**PostgreSQL Flexible Server:**
- Name: ${postgres_name}
- Version: 16
- SKU: Standard_D2ds_v5
- Storage: 128 GB
- HA: Zone Redundant ✅

**Databases Created:**
| Database | Charset |
|----------|---------|
| rhdh | UTF8 |
| argocd | UTF8 |
| apps | UTF8 |

**Redis Cache:**
- Name: ${redis_name}
- SKU: Premium P1
- TLS: 1.2

**Network:**
- Private Endpoints: ✅ Configured
- DNS Zones: ✅ Linked

**Secrets:**
- ✅ postgres-admin-password → Key Vault
- ✅ redis-primary-key → Key Vault
- ✅ ExternalSecrets → Kubernetes

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `networking-agent` | **Prerequisite** |
| `security-agent` | **Prerequisite** |
| `rhdh-portal-agent` | **Post** |

---

**Spec Version:** 1.0.0
