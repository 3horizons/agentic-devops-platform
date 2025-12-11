# Azure Naming Conventions - Quick Reference

## Three Horizons Platform Standard

| Resource | Pattern | Example |
|----------|---------|---------|
| Resource Group | `rg-{project}-{env}-{region}` | `rg-threehorizons-prd-brs` |
| Virtual Network | `vnet-{project}-{env}-{region}` | `vnet-threehorizons-prd-brs` |
| Subnet | `snet-{project}-{env}-{region}-{purpose}` | `snet-threehorizons-prd-brs-aks` |
| NSG | `nsg-{project}-{env}-{region}` | `nsg-threehorizons-prd-brs` |
| AKS Cluster | `aks-{project}-{env}-{region}` | `aks-threehorizons-prd-brs` |
| Container Registry | `cr{project}{env}{region}` | `crthreehorizonsprdbrs` |
| Storage Account | `st{project}{env}{region}{###}` | `stthreehorizonsprdbrs001` |
| Key Vault | `kv-{project}-{env}-{region}` | `kv-threehorizons-prd-brs` |
| PostgreSQL | `psql-{project}-{env}-{region}` | `psql-threehorizons-prd-brs` |
| Log Analytics | `log-{project}-{env}-{region}` | `log-threehorizons-prd-brs` |
| App Insights | `appi-{project}-{env}-{region}` | `appi-threehorizons-prd-brs` |
| OpenAI Service | `oai-{project}-{env}-{region}` | `oai-threehorizons-prd-brs` |
| Purview | `pview-{project}-{env}-{region}` | `pview-threehorizons-prd-brs` |
| Managed Identity | `id-{project}-{env}-{region}` | `id-threehorizons-prd-brs` |

## Environment Codes

| Environment | Code | Description |
|-------------|------|-------------|
| Development | `dev` | Development environment |
| Staging | `stg` | Pre-production staging |
| Production | `prd` | Production environment |
| Sandbox | `sbx` | Experimentation |
| Test | `tst` | Testing environment |

## Region Codes (LATAM Focus)

| Region | Code | Location |
|--------|------|----------|
| Brazil South | `brs` | São Paulo |
| Brazil Southeast | `brse` | Rio de Janeiro |
| East US | `eus` | Virginia |
| East US 2 | `eus2` | Virginia |
| South Central US | `scus` | Texas |
| West US 2 | `wus2` | Washington |

## Critical Naming Rules ⚠️

### Storage Account
- **Max Length:** 24 characters
- **Allowed:** Lowercase letters and numbers ONLY
- **No hyphens, no underscores**
- **Globally unique**

```
✅ stthreehorizonsprdbrs001
❌ st-threehorizons-prd
❌ st_threehorizons_prd
```

### Container Registry (ACR)
- **Max Length:** 50 characters
- **Allowed:** Alphanumeric ONLY (letters and numbers)
- **No hyphens, no underscores**
- **Globally unique**

```
✅ crthreehorizonsprdbrs
❌ cr-threehorizons-prd
❌ acr_threehorizons
```

### Key Vault
- **Max Length:** 24 characters
- **Allowed:** Alphanumeric and hyphens
- **Must start with letter**
- **Cannot end with hyphen**
- **Globally unique**

```
✅ kv-threehorizons-prd
❌ kv_threehorizons (underscore)
❌ 1kv-threehorizons (starts with number)
```

### AKS Node Pool
- **Max Length:** 12 characters (Linux), 6 characters (Windows)
- **Allowed:** Lowercase alphanumeric
- **Must start with letter**

```
✅ system
✅ user001
❌ system-pool (hyphen)
❌ 01system (starts with number)
```

### PostgreSQL Server
- **Max Length:** 63 characters
- **Allowed:** Lowercase, numbers, hyphens
- **Cannot start or end with hyphen**
- **Globally unique**

```
✅ psql-threehorizons-prd-brs
❌ -psql-threehorizons (starts with hyphen)
❌ PSQL-threehorizons (uppercase)
```

## Terraform Naming Module Usage

```hcl
module "naming" {
  source = "./modules/naming"

  project_name = "threehorizons"
  environment  = "prd"
  location     = "brazilsouth"
  instance     = "001"
}

# Resource examples
resource "azurerm_resource_group" "main" {
  name     = module.naming.resource_group  # rg-threehorizons-prd-brs
  location = var.location
}

resource "azurerm_storage_account" "main" {
  name = module.naming.storage_account  # stthreehorizonsprdbrs001
  # ...
}

resource "azurerm_container_registry" "main" {
  name = module.naming.container_registry  # crthreehorizonsprdbrs
  # ...
}
```

## CAF Abbreviations Reference

| Resource Type | Abbreviation |
|--------------|--------------|
| API Management | `apim` |
| App Configuration | `appcs` |
| App Service | `app` |
| Application Gateway | `agw` |
| Application Insights | `appi` |
| Azure AI Search | `srch` |
| Azure Cosmos DB | `cosmos` |
| Azure Firewall | `afw` |
| Azure Kubernetes Service | `aks` |
| Azure OpenAI | `oai` |
| Azure SQL Database | `sqldb` |
| Container Instance | `ci` |
| Container Registry | `cr` |
| Data Lake Store | `dls` |
| Event Hub | `evh` |
| Function App | `func` |
| Key Vault | `kv` |
| Load Balancer (internal) | `lbi` |
| Load Balancer (external) | `lbe` |
| Log Analytics Workspace | `log` |
| Managed Identity | `id` |
| MySQL Database | `mysql` |
| Network Security Group | `nsg` |
| PostgreSQL Server | `psql` |
| Private Endpoint | `pe` |
| Public IP | `pip` |
| Redis Cache | `redis` |
| Resource Group | `rg` |
| Route Table | `rt` |
| Service Bus | `sb` |
| SQL Server | `sql` |
| Storage Account | `st` |
| Subnet | `snet` |
| Virtual Machine | `vm` |
| Virtual Network | `vnet` |
| VPN Gateway | `vpng` |
| WAF Policy | `waf` |

## Tags Standard

All resources should include these tags:

```hcl
tags = {
  Project     = "Three Horizons"
  Environment = "Production"
  Region      = "brazilsouth"
  ManagedBy   = "Terraform"
  CostCenter  = "IT-Platform"
  Owner       = "Platform Team"
}
```

## References

- [Azure CAF Naming Convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure Resource Name Rules](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules)
- [CAF Abbreviation Examples](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
