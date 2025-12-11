# =============================================================================
# THREE HORIZONS ACCELERATOR - AI FOUNDRY TERRAFORM MODULE
# =============================================================================
#
# Deploys Azure AI services for H3 Innovation workloads.
#
# Components:
#   - Azure OpenAI Service
#   - Azure AI Search
#   - Azure AI Content Safety
#   - Model deployments (GPT-4o, embeddings)
#   - Private endpoints
#
# =============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75"
    }
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.9"
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
  description = "Private DNS zone IDs"
  type = object({
    openai             = string
    cognitiveservices  = string
    search             = string
  })
}

variable "openai_config" {
  description = "Azure OpenAI configuration"
  type = object({
    enabled          = bool
    sku_name         = string
    models = list(object({
      name           = string
      model_name     = string
      model_version  = string
      capacity       = number
      rai_policy     = string
    }))
  })
  default = {
    enabled  = true
    sku_name = "S0"
    models = [
      {
        name          = "gpt-4o"
        model_name    = "gpt-4o"
        model_version = "2024-05-13"
        capacity      = 30
        rai_policy    = "Microsoft.Default"
      },
      {
        name          = "gpt-4o-mini"
        model_name    = "gpt-4o-mini"
        model_version = "2024-07-18"
        capacity      = 100
        rai_policy    = "Microsoft.Default"
      },
      {
        name          = "text-embedding-3-large"
        model_name    = "text-embedding-3-large"
        model_version = "1"
        capacity      = 100
        rai_policy    = "Microsoft.Default"
      }
    ]
  }
}

variable "ai_search_config" {
  description = "Azure AI Search configuration"
  type = object({
    enabled                      = bool
    sku_name                     = string
    replica_count                = number
    partition_count              = number
    semantic_search_sku          = string
    public_network_access_enabled = bool
  })
  default = {
    enabled                       = true
    sku_name                      = "standard"
    replica_count                 = 1
    partition_count               = 1
    semantic_search_sku           = "standard"
    public_network_access_enabled = false
  }
}

variable "content_safety_config" {
  description = "Azure AI Content Safety configuration"
  type = object({
    enabled  = bool
    sku_name = string
  })
  default = {
    enabled  = true
    sku_name = "S0"
  }
}

variable "key_vault_id" {
  description = "Key Vault ID for storing secrets"
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = ""
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
    "three-horizons/component"   = "ai-foundry"
    "three-horizons/horizon"     = "H3"
  })
}

# =============================================================================
# AZURE OPENAI SERVICE
# =============================================================================

resource "azurerm_cognitive_account" "openai" {
  count = var.openai_config.enabled ? 1 : 0
  
  name                = "oai-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.openai_config.sku_name
  
  custom_subdomain_name = "oai-${replace(local.name_prefix, "-", "")}"
  
  public_network_access_enabled = false
  
  network_acls {
    default_action = "Deny"
    ip_rules       = []
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.common_tags
  
  lifecycle {
    ignore_changes = [
      customer_managed_key
    ]
  }
}

# OpenAI Model Deployments
resource "azurerm_cognitive_deployment" "models" {
  for_each = var.openai_config.enabled ? {
    for model in var.openai_config.models : model.name => model
  } : {}
  
  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.openai[0].id
  
  model {
    format  = "OpenAI"
    name    = each.value.model_name
    version = each.value.model_version
  }
  
  scale {
    type     = "Standard"
    capacity = each.value.capacity
  }
  
  rai_policy_name = each.value.rai_policy
}

# OpenAI Private Endpoint
resource "azurerm_private_endpoint" "openai" {
  count = var.openai_config.enabled ? 1 : 0
  
  name                = "pe-oai-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  
  private_service_connection {
    name                           = "openai-connection"
    private_connection_resource_id = azurerm_cognitive_account.openai[0].id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }
  
  private_dns_zone_group {
    name                 = "openai-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_ids.openai]
  }
  
  tags = local.common_tags
}

# =============================================================================
# AZURE AI SEARCH
# =============================================================================

resource "azurerm_search_service" "main" {
  count = var.ai_search_config.enabled ? 1 : 0
  
  name                = "srch-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.ai_search_config.sku_name
  
  replica_count   = var.ai_search_config.replica_count
  partition_count = var.ai_search_config.partition_count
  
  public_network_access_enabled = var.ai_search_config.public_network_access_enabled
  
  semantic_search_sku = var.ai_search_config.semantic_search_sku
  
  local_authentication_enabled = true
  authentication_failure_mode  = "http403"
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.common_tags
}

# AI Search Private Endpoint
resource "azurerm_private_endpoint" "search" {
  count = var.ai_search_config.enabled ? 1 : 0
  
  name                = "pe-srch-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  
  private_service_connection {
    name                           = "search-connection"
    private_connection_resource_id = azurerm_search_service.main[0].id
    is_manual_connection           = false
    subresource_names              = ["searchService"]
  }
  
  private_dns_zone_group {
    name                 = "search-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_ids.search]
  }
  
  tags = local.common_tags
}

# =============================================================================
# AZURE AI CONTENT SAFETY
# =============================================================================

resource "azurerm_cognitive_account" "content_safety" {
  count = var.content_safety_config.enabled ? 1 : 0
  
  name                = "cs-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "ContentSafety"
  sku_name            = var.content_safety_config.sku_name
  
  custom_subdomain_name = "cs-${replace(local.name_prefix, "-", "")}"
  
  public_network_access_enabled = false
  
  network_acls {
    default_action = "Deny"
    ip_rules       = []
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.common_tags
}

# Content Safety Private Endpoint
resource "azurerm_private_endpoint" "content_safety" {
  count = var.content_safety_config.enabled ? 1 : 0
  
  name                = "pe-cs-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  
  private_service_connection {
    name                           = "content-safety-connection"
    private_connection_resource_id = azurerm_cognitive_account.content_safety[0].id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }
  
  private_dns_zone_group {
    name                 = "cs-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_ids.cognitiveservices]
  }
  
  tags = local.common_tags
}

# =============================================================================
# ROLE ASSIGNMENTS
# =============================================================================

# Grant AI Search access to OpenAI (for integrated vectorization)
resource "azurerm_role_assignment" "search_to_openai" {
  count = var.openai_config.enabled && var.ai_search_config.enabled ? 1 : 0
  
  scope                = azurerm_cognitive_account.openai[0].id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_search_service.main[0].identity[0].principal_id
}

# =============================================================================
# KEY VAULT SECRETS
# =============================================================================

# Store OpenAI endpoint and key
resource "azurerm_key_vault_secret" "openai_endpoint" {
  count = var.openai_config.enabled ? 1 : 0
  
  name         = "openai-endpoint"
  value        = azurerm_cognitive_account.openai[0].endpoint
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

resource "azurerm_key_vault_secret" "openai_key" {
  count = var.openai_config.enabled ? 1 : 0
  
  name         = "openai-api-key"
  value        = azurerm_cognitive_account.openai[0].primary_access_key
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

# Store AI Search endpoint and key
resource "azurerm_key_vault_secret" "search_endpoint" {
  count = var.ai_search_config.enabled ? 1 : 0
  
  name         = "search-endpoint"
  value        = "https://${azurerm_search_service.main[0].name}.search.windows.net"
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

resource "azurerm_key_vault_secret" "search_admin_key" {
  count = var.ai_search_config.enabled ? 1 : 0
  
  name         = "search-admin-key"
  value        = azurerm_search_service.main[0].primary_key
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

# Store Content Safety endpoint and key
resource "azurerm_key_vault_secret" "content_safety_endpoint" {
  count = var.content_safety_config.enabled ? 1 : 0
  
  name         = "content-safety-endpoint"
  value        = azurerm_cognitive_account.content_safety[0].endpoint
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

resource "azurerm_key_vault_secret" "content_safety_key" {
  count = var.content_safety_config.enabled ? 1 : 0
  
  name         = "content-safety-api-key"
  value        = azurerm_cognitive_account.content_safety[0].primary_access_key
  key_vault_id = var.key_vault_id
  
  tags = local.common_tags
}

# =============================================================================
# DIAGNOSTIC SETTINGS
# =============================================================================

resource "azurerm_monitor_diagnostic_setting" "openai" {
  count = var.openai_config.enabled && var.log_analytics_workspace_id != "" ? 1 : 0
  
  name                       = "openai-diagnostics"
  target_resource_id         = azurerm_cognitive_account.openai[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  enabled_log {
    category = "Audit"
  }
  
  enabled_log {
    category = "RequestResponse"
  }
  
  enabled_log {
    category = "Trace"
  }
  
  metric {
    category = "AllMetrics"
  }
}

resource "azurerm_monitor_diagnostic_setting" "search" {
  count = var.ai_search_config.enabled && var.log_analytics_workspace_id != "" ? 1 : 0
  
  name                       = "search-diagnostics"
  target_resource_id         = azurerm_search_service.main[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  enabled_log {
    category = "OperationLogs"
  }
  
  metric {
    category = "AllMetrics"
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "openai_id" {
  description = "Azure OpenAI account ID"
  value       = var.openai_config.enabled ? azurerm_cognitive_account.openai[0].id : null
}

output "openai_endpoint" {
  description = "Azure OpenAI endpoint"
  value       = var.openai_config.enabled ? azurerm_cognitive_account.openai[0].endpoint : null
}

output "openai_principal_id" {
  description = "Azure OpenAI managed identity principal ID"
  value       = var.openai_config.enabled ? azurerm_cognitive_account.openai[0].identity[0].principal_id : null
}

output "openai_deployments" {
  description = "Azure OpenAI model deployments"
  value = var.openai_config.enabled ? {
    for name, deployment in azurerm_cognitive_deployment.models : name => {
      id   = deployment.id
      name = deployment.name
    }
  } : {}
}

output "search_id" {
  description = "Azure AI Search ID"
  value       = var.ai_search_config.enabled ? azurerm_search_service.main[0].id : null
}

output "search_endpoint" {
  description = "Azure AI Search endpoint"
  value       = var.ai_search_config.enabled ? "https://${azurerm_search_service.main[0].name}.search.windows.net" : null
}

output "search_principal_id" {
  description = "Azure AI Search managed identity principal ID"
  value       = var.ai_search_config.enabled ? azurerm_search_service.main[0].identity[0].principal_id : null
}

output "content_safety_id" {
  description = "Azure AI Content Safety ID"
  value       = var.content_safety_config.enabled ? azurerm_cognitive_account.content_safety[0].id : null
}

output "content_safety_endpoint" {
  description = "Azure AI Content Safety endpoint"
  value       = var.content_safety_config.enabled ? azurerm_cognitive_account.content_safety[0].endpoint : null
}

output "private_endpoint_ips" {
  description = "Private endpoint IPs"
  value = {
    openai         = var.openai_config.enabled ? azurerm_private_endpoint.openai[0].private_service_connection[0].private_ip_address : null
    search         = var.ai_search_config.enabled ? azurerm_private_endpoint.search[0].private_service_connection[0].private_ip_address : null
    content_safety = var.content_safety_config.enabled ? azurerm_private_endpoint.content_safety[0].private_service_connection[0].private_ip_address : null
  }
}

output "key_vault_secrets" {
  description = "Key Vault secret names"
  value = {
    openai_endpoint       = var.openai_config.enabled ? azurerm_key_vault_secret.openai_endpoint[0].name : null
    openai_key            = var.openai_config.enabled ? azurerm_key_vault_secret.openai_key[0].name : null
    search_endpoint       = var.ai_search_config.enabled ? azurerm_key_vault_secret.search_endpoint[0].name : null
    search_admin_key      = var.ai_search_config.enabled ? azurerm_key_vault_secret.search_admin_key[0].name : null
    content_safety_endpoint = var.content_safety_config.enabled ? azurerm_key_vault_secret.content_safety_endpoint[0].name : null
    content_safety_key    = var.content_safety_config.enabled ? azurerm_key_vault_secret.content_safety_key[0].name : null
  }
}
