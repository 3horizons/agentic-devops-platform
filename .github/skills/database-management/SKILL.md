````skill
---
name: database-management
description: 'Database management for Three Horizons Accelerator. Use when deploying Azure Database for PostgreSQL, Cosmos DB, database migrations, backup configuration. Covers database provisioning, connection management, security hardening, performance tuning.'
license: Complete terms in LICENSE.txt
---

# Database Management Skill

Comprehensive skill for database operations in the Three Horizons Accelerator platform.

**Version:** 1.0.0

---

## Overview

This skill encapsulates all tools required for database operations:
- **MCP Servers**: azure, terraform
- **Terraform Modules**: databases
- **Services**: Azure Database for PostgreSQL Flexible Server, Cosmos DB

---

## MCP Server Configuration

### Azure MCP Server

```json
{
  "azure": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-azure"],
    "capabilities": [
      "az postgres flexible-server",
      "az cosmosdb",
      "az sql"
    ]
  }
}
```

---

## Azure Database for PostgreSQL

### Create PostgreSQL Flexible Server

```bash
# Create PostgreSQL Flexible Server
az postgres flexible-server create \
  --resource-group ${RESOURCE_GROUP} \
  --name psql-${PROJECT}-${ENV}-${LOCATION_SHORT} \
  --location ${LOCATION} \
  --admin-user ${ADMIN_USER} \
  --admin-password "${ADMIN_PASSWORD}" \
  --sku-name Standard_D4ds_v4 \
  --tier GeneralPurpose \
  --storage-size 128 \
  --version 16 \
  --vnet ${VNET_NAME} \
  --subnet snet-databases \
  --private-dns-zone ${PRIVATE_DNS_ZONE_ID} \
  --high-availability ZoneRedundant \
  --backup-retention 35 \
  --geo-redundant-backup Enabled \
  --tags Environment=${ENV} Project=${PROJECT}
```

### Configure PostgreSQL

```bash
# Configure server parameters
az postgres flexible-server parameter set \
  --resource-group ${RESOURCE_GROUP} \
  --server-name ${POSTGRES_SERVER} \
  --name log_connections \
  --value on

az postgres flexible-server parameter set \
  --resource-group ${RESOURCE_GROUP} \
  --server-name ${POSTGRES_SERVER} \
  --name shared_preload_libraries \
  --value "pg_stat_statements"

# Enable extensions
az postgres flexible-server parameter set \
  --resource-group ${RESOURCE_GROUP} \
  --server-name ${POSTGRES_SERVER} \
  --name azure.extensions \
  --value "CITEXT,UUID-OSSP,PGCRYPTO"
```

### Create Database

```bash
# Create database
az postgres flexible-server db create \
  --resource-group ${RESOURCE_GROUP} \
  --server-name ${POSTGRES_SERVER} \
  --database-name ${DATABASE_NAME}

# List databases
az postgres flexible-server db list \
  --resource-group ${RESOURCE_GROUP} \
  --server-name ${POSTGRES_SERVER} \
  --output table
```

### Configure Firewall (for non-VNet access)

```bash
# Add firewall rule
az postgres flexible-server firewall-rule create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${POSTGRES_SERVER} \
  --rule-name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Allow specific IP
az postgres flexible-server firewall-rule create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${POSTGRES_SERVER} \
  --rule-name AllowMyIP \
  --start-ip-address ${MY_IP} \
  --end-ip-address ${MY_IP}
```

### Connection String

```bash
# Get connection string
CONNECTION_STRING="host=${POSTGRES_SERVER}.postgres.database.azure.com \
  port=5432 \
  dbname=${DATABASE_NAME} \
  user=${ADMIN_USER} \
  password=${ADMIN_PASSWORD} \
  sslmode=require"

# Connect via psql
psql "host=${POSTGRES_SERVER}.postgres.database.azure.com \
  port=5432 \
  dbname=${DATABASE_NAME} \
  user=${ADMIN_USER} \
  sslmode=require"
```

---

## Azure Cosmos DB

### Create Cosmos DB Account

```bash
# Create Cosmos DB account (NoSQL API)
az cosmosdb create \
  --resource-group ${RESOURCE_GROUP} \
  --name cosmos-${PROJECT}-${ENV}-${LOCATION_SHORT} \
  --locations regionName=${LOCATION} failoverPriority=0 isZoneRedundant=true \
  --default-consistency-level Session \
  --enable-automatic-failover true \
  --enable-multiple-write-locations false \
  --capabilities EnableServerless \
  --tags Environment=${ENV} Project=${PROJECT}

# With provisioned throughput
az cosmosdb create \
  --resource-group ${RESOURCE_GROUP} \
  --name cosmos-${PROJECT}-${ENV}-${LOCATION_SHORT} \
  --locations regionName=${LOCATION} failoverPriority=0 \
  --locations regionName=westus2 failoverPriority=1 \
  --enable-automatic-failover true \
  --tags Environment=${ENV} Project=${PROJECT}
```

### Create Database and Container

```bash
# Create database
az cosmosdb sql database create \
  --resource-group ${RESOURCE_GROUP} \
  --account-name ${COSMOS_ACCOUNT} \
  --name ${DATABASE_NAME}

# Create container
az cosmosdb sql container create \
  --resource-group ${RESOURCE_GROUP} \
  --account-name ${COSMOS_ACCOUNT} \
  --database-name ${DATABASE_NAME} \
  --name ${CONTAINER_NAME} \
  --partition-key-path "/partitionKey" \
  --throughput 400
```

### Get Connection Keys

```bash
# Get connection string
az cosmosdb keys list \
  --resource-group ${RESOURCE_GROUP} \
  --name ${COSMOS_ACCOUNT} \
  --type connection-strings

# Get primary key
az cosmosdb keys list \
  --resource-group ${RESOURCE_GROUP} \
  --name ${COSMOS_ACCOUNT} \
  --output tsv --query primaryMasterKey
```

---

## Terraform Module Reference

**Path:** `terraform/modules/databases/`

```hcl
module "databases" {
  source = "./modules/databases"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  
  # PostgreSQL Configuration
  postgresql = {
    enabled              = true
    name                 = local.postgresql_name
    administrator_login  = var.db_admin_user
    administrator_password = var.db_admin_password
    sku_name             = "GP_Standard_D4ds_v4"
    storage_mb           = 131072
    version              = "16"
    zone                 = "1"
    high_availability    = {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
    backup_retention_days        = 35
    geo_redundant_backup_enabled = true
    
    # Networking
    delegated_subnet_id = module.networking.database_subnet_id
    private_dns_zone_id = azurerm_private_dns_zone.postgresql.id
  }
  
  # Cosmos DB Configuration
  cosmosdb = {
    enabled = var.enable_cosmosdb
    name    = local.cosmosdb_name
    offer_type = "Standard"
    kind       = "GlobalDocumentDB"
    
    consistency_policy = {
      consistency_level = "Session"
    }
    
    geo_locations = [
      {
        location          = var.location
        failover_priority = 0
        zone_redundant    = true
      }
    ]
    
    capabilities = var.cosmosdb_serverless ? ["EnableServerless"] : []
  }
  
  tags = local.tags
}
```

---

## Kubernetes Secrets for Database

### External Secrets Configuration

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: postgresql-credentials
  namespace: my-app
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: azure-keyvault
  target:
    name: postgresql-credentials
    creationPolicy: Owner
  data:
    - secretKey: host
      remoteRef:
        key: postgresql-host
    - secretKey: username
      remoteRef:
        key: postgresql-username
    - secretKey: password
      remoteRef:
        key: postgresql-password
    - secretKey: database
      remoteRef:
        key: postgresql-database
```

### Application Configuration

```yaml
# Deployment with database connection
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  template:
    spec:
      containers:
        - name: app
          env:
            - name: DATABASE_HOST
              valueFrom:
                secretKeyRef:
                  name: postgresql-credentials
                  key: host
            - name: DATABASE_USER
              valueFrom:
                secretKeyRef:
                  name: postgresql-credentials
                  key: username
            - name: DATABASE_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: postgresql-credentials
                  key: password
            - name: DATABASE_NAME
              valueFrom:
                secretKeyRef:
                  name: postgresql-credentials
                  key: database
            - name: DATABASE_URL
              value: "postgresql://$(DATABASE_USER):$(DATABASE_PASSWORD)@$(DATABASE_HOST):5432/$(DATABASE_NAME)?sslmode=require"
```

---

## Database Migrations

### Using Kubernetes Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  namespace: my-app
spec:
  template:
    spec:
      containers:
        - name: migration
          image: ${ACR_NAME}.azurecr.io/my-app:${VERSION}
          command: ["python", "manage.py", "migrate"]
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: postgresql-credentials
                  key: url
      restartPolicy: Never
  backoffLimit: 3
```

### Using ArgoCD PreSync Hook

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
        - name: migration
          image: ${ACR_NAME}.azurecr.io/my-app:${VERSION}
          command: ["alembic", "upgrade", "head"]
          envFrom:
            - secretRef:
                name: postgresql-credentials
      restartPolicy: Never
```

---

## Backup and Restore

### PostgreSQL Backup

```bash
# Manual backup (point-in-time restore is automatic)
# PITR is enabled by default with 7-35 days retention

# Create on-demand backup
az postgres flexible-server backup create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${POSTGRES_SERVER} \
  --backup-name manual-backup-$(date +%Y%m%d)

# List backups
az postgres flexible-server backup list \
  --resource-group ${RESOURCE_GROUP} \
  --name ${POSTGRES_SERVER} \
  --output table
```

### PostgreSQL Restore

```bash
# Restore to point in time
az postgres flexible-server restore \
  --resource-group ${RESOURCE_GROUP} \
  --name ${NEW_SERVER_NAME} \
  --source-server ${POSTGRES_SERVER} \
  --restore-time "2024-01-15T10:00:00Z"

# Restore from geo-backup
az postgres flexible-server geo-restore \
  --resource-group ${RESOURCE_GROUP} \
  --name ${NEW_SERVER_NAME} \
  --source-server ${POSTGRES_SERVER} \
  --location ${ALTERNATE_LOCATION}
```

---

## Error Handling

### Common Errors and Solutions

#### Connection Timeout

```bash
# Error: Connection timed out
# Solution: Check VNet integration and firewall rules

az postgres flexible-server show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${POSTGRES_SERVER} \
  --query "network"

# Verify connectivity from pod
kubectl run psql-test --image=postgres:16 --rm -it -- \
  psql "host=${POSTGRES_HOST} port=5432 user=${USER} dbname=postgres sslmode=require"
```

#### SSL Certificate Error

```bash
# Error: SSL certificate verify failed
# Solution: Use correct SSL mode

# For Azure PostgreSQL
sslmode=require  # Minimum recommended
sslmode=verify-full  # For production with CA cert
```

#### Insufficient Storage

```bash
# Error: FATAL: could not write lock file
# Solution: Increase storage

az postgres flexible-server update \
  --resource-group ${RESOURCE_GROUP} \
  --name ${POSTGRES_SERVER} \
  --storage-size 256
```

---

## Pre-Deployment Checklist

- [ ] VNet with dedicated database subnet configured
- [ ] Subnet delegation for PostgreSQL configured
- [ ] Private DNS zone created and linked to VNet
- [ ] Admin credentials stored in Key Vault
- [ ] Backup retention policy defined
- [ ] Geo-redundancy requirements documented

## Post-Deployment Validation

```bash
# Validate PostgreSQL connectivity
az postgres flexible-server connect \
  --name ${POSTGRES_SERVER} \
  --admin-user ${ADMIN_USER} \
  --admin-password "${ADMIN_PASSWORD}" \
  --database-name postgres

# Check server status
az postgres flexible-server show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${POSTGRES_SERVER} \
  --query "state" -o tsv

# Verify high availability
az postgres flexible-server show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${POSTGRES_SERVER} \
  --query "highAvailability"
```

---

## Related Skills

- [azure-cli](../azure-cli/) - Azure CLI command reference
- [terraform-cli](../terraform-cli/) - Terraform CLI reference
- [azure-infrastructure](../azure-infrastructure/) - Infrastructure provisioning

---

## References

- [Azure Database for PostgreSQL](https://learn.microsoft.com/en-us/azure/postgresql/)
- [Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/)
- [PostgreSQL Best Practices](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-best-practices)

````
