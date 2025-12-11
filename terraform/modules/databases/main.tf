# =============================================================================
# THREE HORIZONS ACCELERATOR - DATABASES TERRAFORM MODULE
# =============================================================================
#
# Deploys managed database services for the platform.
#
# Components:
#   - Azure Database for PostgreSQL Flexible Server
#   - Azure Cache for Redis
#   - Private endpoints for secure connectivity
#   - Backup and geo-replication (prod)
#
# =============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

# =============================================================================
# VARIABLES
# =============================================================================

variable "customer_name" {
  description = "Customer name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for database services"
  type = object({
    postgres = string
    redis    = string
  })
}

variable "postgresql_config" {
  description = "PostgreSQL configuration"
  type = object({
    enabled             = bool
    sku_name            = string
    storage_mb          = number
    version             = string
    admin_username      = string
    backup_retention_days = number
    geo_redundant_backup = bool
    high_availability   = bool
    databases           = list(string)
  })
  default = {
    enabled              = true
    sku_name             = "GP_Standard_D2s_v3"
    storage_mb           = 32768
    version              = "16"
    admin_username       = "pgadmin"
    backup_retention_days = 7
    geo_redundant_backup = false
    high_availability    = false
    databases            = ["rhdh", "backstage"]
  }
}

variable "redis_config" {
  description = "Redis configuration"
  type = object({
    enabled           = bool
    sku_name          = string
    family            = string
    capacity          = number
    enable_non_ssl_port = bool
    minimum_tls_version = string
    maxmemory_policy  = string
  })
  default = {
    enabled             = true
    sku_name            = "Standard"
    family              = "C"
    capacity            = 1
    enable_non_ssl_port = false
    minimum_tls_version = "1.2"
    maxmemory_policy    = "volatile-lru"
  }
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# LOCALS
# =============================================================================

locals {
  name_prefix = "${var.customer_name}-${var.environment}"
  
  common_tags = merge(var.tags, {
    "three-horizons/customer"    = var.customer_name
    "three-horizons/environment" = var.environment
    "three-horizons/component"   = "databases"
  })
  
  # Production settings
  is_prod = var.environment == "prod"
}

# =============================================================================
# RANDOM PASSWORD GENERATION
# =============================================================================

resource "random_password" "postgresql" {
  count = var.postgresql_config.enabled ? 1 : 0
  
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "redis" {
  count = var.redis_config.enabled ? 1 : 0
  
  length           = 32
  special          = false
}

# =============================================================================
# POSTGRESQL FLEXIBLE SERVER
# =============================================================================

resource "azurerm_postgresql_flexible_server" "main" {
  count = var.postgresql_config.enabled ? 1 : 0
  
  name                   = "psql-${local.name_prefix}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  
  version                = var.postgresql_config.version
  sku_name               = var.postgresql_config.sku_name
  storage_mb             = var.postgresql_config.storage_mb
  
  administrator_login    = var.postgresql_config.admin_username
  administrator_password = random_password.postgresql[0].result
  
  backup_retention_days  = var.postgresql_config.backup_retention_days
  geo_redundant_backup_enabled = local.is_prod && var.postgresql_config.geo_redundant_backup
  
  # High availability (prod only)
  dynamic "high_availability" {
    for_each = local.is_prod && var.postgresql_config.high_availability ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
  }
  
  # Private access via delegated subnet
  delegated_subnet_id = var.subnet_id
  private_dns_zone_id = var.private_dns_zone_ids.postgres
  
  # Maintenance window
  maintenance_window {
    day_of_week  = 0  # Sunday
    start_hour   = 3
    start_minute = 0
  }
  
  # Authentication
  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = true
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }
  
  tags = local.common_tags
  
  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone
    ]
  }
}

# PostgreSQL Databases
resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each = var.postgresql_config.enabled ? toset(var.postgresql_config.databases) : []
  
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main[0].id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# PostgreSQL Configuration
resource "azurerm_postgresql_flexible_server_configuration" "configs" {
  for_each = var.postgresql_config.enabled ? {
    "log_checkpoints"           = "on"
    "log_connections"           = "on"
    "log_disconnections"        = "on"
    "log_lock_waits"            = "on"
    "log_min_duration_statement" = "1000"
    "shared_preload_libraries"  = "pg_stat_statements"
    "track_activity_query_size" = "4096"
    "work_mem"                  = "32768"
    "maintenance_work_mem"      = "524288"
    "effective_cache_size"      = "1572864"
  } : {}
  
  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main[0].id
  value     = each.value
}

# PostgreSQL Firewall Rule (allow Azure services)
resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  count = var.postgresql_config.enabled ? 1 : 0
  
  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.main[0].id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# =============================================================================
# REDIS CACHE
# =============================================================================

resource "azurerm_redis_cache" "main" {
  count = var.redis_config.enabled ? 1 : 0
  
  name                = "redis-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  capacity            = var.redis_config.capacity
  family              = var.redis_config.family
  sku_name            = var.redis_config.sku_name
  
  enable_non_ssl_port = var.redis_config.enable_non_ssl_port
  minimum_tls_version = var.redis_config.minimum_tls_version
  
  redis_configuration {
    maxmemory_policy = var.redis_config.maxmemory_policy
    
    # Enable AOF persistence for Standard/Premium
    aof_backup_enabled = var.redis_config.sku_name != "Basic"
  }
  
  # Zones for Premium SKU
  zones = var.redis_config.sku_name == "Premium" && local.is_prod ? ["1", "2", "3"] : null
  
  public_network_access_enabled = false
  
  tags = local.common_tags
}

# Redis Private Endpoint
resource "azurerm_private_endpoint" "redis" {
  count = var.redis_config.enabled ? 1 : 0
  
  name                = "pe-redis-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  
  private_service_connection {
    name                           = "redis-connection"
    private_connection_resource_id = azurerm_redis_cache.main[0].id
    is_manual_connection           = false
    subresource_names              = ["redisCache"]
  }
  
  private_dns_zone_group {
    name                 = "redis-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_ids.redis]
  }
  
  tags = local.common_tags
}

# =============================================================================
# KEY VAULT SECRETS
# =============================================================================

data "azurerm_client_config" "current" {}

# Store PostgreSQL connection string
resource "azurerm_key_vault_secret" "postgresql_connection_string" {
  count = var.postgresql_config.enabled ? 1 : 0
  
  name         = "postgresql-connection-string"
  value        = "postgresql://${var.postgresql_config.admin_username}:${random_password.postgresql[0].result}@${azurerm_postgresql_flexible_server.main[0].fqdn}:5432/postgres?sslmode=require"
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

# Store PostgreSQL admin password
resource "azurerm_key_vault_secret" "postgresql_password" {
  count = var.postgresql_config.enabled ? 1 : 0
  
  name         = "postgresql-admin-password"
  value        = random_password.postgresql[0].result
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

# Store Redis connection string
resource "azurerm_key_vault_secret" "redis_connection_string" {
  count = var.redis_config.enabled ? 1 : 0
  
  name         = "redis-connection-string"
  value        = azurerm_redis_cache.main[0].primary_connection_string
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

# Store Redis primary key
resource "azurerm_key_vault_secret" "redis_primary_key" {
  count = var.redis_config.enabled ? 1 : 0
  
  name         = "redis-primary-key"
  value        = azurerm_redis_cache.main[0].primary_access_key
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "postgresql_server_id" {
  description = "PostgreSQL server ID"
  value       = var.postgresql_config.enabled ? azurerm_postgresql_flexible_server.main[0].id : null
}

output "postgresql_server_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = var.postgresql_config.enabled ? azurerm_postgresql_flexible_server.main[0].fqdn : null
}

output "postgresql_admin_username" {
  description = "PostgreSQL admin username"
  value       = var.postgresql_config.enabled ? var.postgresql_config.admin_username : null
}

output "postgresql_databases" {
  description = "Created PostgreSQL databases"
  value       = var.postgresql_config.enabled ? var.postgresql_config.databases : []
}

output "redis_id" {
  description = "Redis cache ID"
  value       = var.redis_config.enabled ? azurerm_redis_cache.main[0].id : null
}

output "redis_hostname" {
  description = "Redis hostname"
  value       = var.redis_config.enabled ? azurerm_redis_cache.main[0].hostname : null
}

output "redis_ssl_port" {
  description = "Redis SSL port"
  value       = var.redis_config.enabled ? azurerm_redis_cache.main[0].ssl_port : null
}

output "redis_private_ip" {
  description = "Redis private endpoint IP"
  value       = var.redis_config.enabled ? azurerm_private_endpoint.redis[0].private_service_connection[0].private_ip_address : null
}

output "key_vault_secret_names" {
  description = "Names of secrets stored in Key Vault"
  value = {
    postgresql_connection_string = var.postgresql_config.enabled ? azurerm_key_vault_secret.postgresql_connection_string[0].name : null
    postgresql_password          = var.postgresql_config.enabled ? azurerm_key_vault_secret.postgresql_password[0].name : null
    redis_connection_string      = var.redis_config.enabled ? azurerm_key_vault_secret.redis_connection_string[0].name : null
    redis_primary_key            = var.redis_config.enabled ? azurerm_key_vault_secret.redis_primary_key[0].name : null
  }
}
