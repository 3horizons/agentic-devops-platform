# =============================================================================
# THREE HORIZONS ACCELERATOR - CONTAINER REGISTRY TERRAFORM MODULE
# =============================================================================
#
# Deploys Azure Container Registry with enterprise features.
#
# Components:
#   - Azure Container Registry (Premium for geo-replication)
#   - Private endpoint connectivity
#   - Retention policies
#   - Security scanning integration
#   - Workload identity access
#
# =============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75"
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

variable "sku" {
  description = "ACR SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Premium"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for ACR"
  type        = string
}

variable "geo_replication_locations" {
  description = "Locations for geo-replication (Premium only)"
  type        = list(string)
  default     = []
}

variable "retention_policy_days" {
  description = "Days to retain untagged manifests"
  type        = number
  default     = 30
}

variable "enable_content_trust" {
  description = "Enable content trust (image signing)"
  type        = bool
  default     = true
}

variable "enable_defender" {
  description = "Enable Microsoft Defender for container images"
  type        = bool
  default     = true
}

variable "aks_kubelet_identity_object_id" {
  description = "AKS kubelet managed identity object ID for ACR pull"
  type        = string
}

variable "github_actions_identity_ids" {
  description = "Managed identity IDs for GitHub Actions push access"
  type        = list(string)
  default     = []
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
  name_prefix = "${var.customer_name}${var.environment}"
  
  # ACR names must be alphanumeric only
  acr_name = replace("cr${local.name_prefix}", "-", "")
  
  common_tags = merge(var.tags, {
    "three-horizons/customer"    = var.customer_name
    "three-horizons/environment" = var.environment
    "three-horizons/component"   = "container-registry"
  })
}

# =============================================================================
# AZURE CONTAINER REGISTRY
# =============================================================================

resource "azurerm_container_registry" "main" {
  name                = local.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false
  
  # Network rules (Premium only)
  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" ? [1] : []
    content {
      default_action = "Deny"
      
      # Allow Azure services
      ip_rule = []
      
      virtual_network {
        action    = "Allow"
        subnet_id = var.subnet_id
      }
    }
  }
  
  # Content trust (Premium only)
  trust_policy {
    enabled = var.sku == "Premium" ? var.enable_content_trust : false
  }
  
  # Retention policy (Premium only)
  retention_policy {
    enabled = var.sku == "Premium"
    days    = var.retention_policy_days
  }
  
  # Quarantine policy for security scanning
  quarantine_policy_enabled = var.sku == "Premium"
  
  # Export policy
  export_policy_enabled = true
  
  # Zone redundancy (Premium in supported regions)
  zone_redundancy_enabled = var.sku == "Premium" && var.environment == "prod"
  
  # Data endpoint (Premium only)
  data_endpoint_enabled = var.sku == "Premium"
  
  # Public network access
  public_network_access_enabled = false
  
  # Encryption
  encryption {
    enabled = false  # Use platform-managed keys by default
  }
  
  identity {
    type = "SystemAssigned"
  }
  
  tags = local.common_tags
}

# =============================================================================
# GEO-REPLICATION (Premium only)
# =============================================================================

resource "azurerm_container_registry_replication" "replicas" {
  for_each = var.sku == "Premium" ? toset(var.geo_replication_locations) : []
  
  name                  = each.key
  container_registry_id = azurerm_container_registry.main.id
  location              = each.key
  
  zone_redundancy_enabled = var.environment == "prod"
  
  tags = local.common_tags
}

# =============================================================================
# PRIVATE ENDPOINT
# =============================================================================

resource "azurerm_private_endpoint" "acr" {
  name                = "pe-${local.acr_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  
  private_service_connection {
    name                           = "acr-connection"
    private_connection_resource_id = azurerm_container_registry.main.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
  
  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
  
  tags = local.common_tags
}

# =============================================================================
# ROLE ASSIGNMENTS
# =============================================================================

# AKS Kubelet identity - AcrPull
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = var.aks_kubelet_identity_object_id
}

# GitHub Actions identities - AcrPush
resource "azurerm_role_assignment" "github_actions_push" {
  for_each = toset(var.github_actions_identity_ids)
  
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = each.value
}

# =============================================================================
# SCOPE MAPS AND TOKENS (for fine-grained access)
# =============================================================================

resource "azurerm_container_registry_scope_map" "ci_push" {
  name                    = "ci-push-scope"
  container_registry_name = azurerm_container_registry.main.name
  resource_group_name     = var.resource_group_name
  
  actions = [
    "repositories/*/content/read",
    "repositories/*/content/write",
    "repositories/*/metadata/read",
    "repositories/*/metadata/write"
  ]
}

resource "azurerm_container_registry_scope_map" "readonly" {
  name                    = "readonly-scope"
  container_registry_name = azurerm_container_registry.main.name
  resource_group_name     = var.resource_group_name
  
  actions = [
    "repositories/*/content/read",
    "repositories/*/metadata/read"
  ]
}

# =============================================================================
# WEBHOOKS (for CI/CD integration)
# =============================================================================

resource "azurerm_container_registry_webhook" "image_push" {
  name                = "imagepush"
  resource_group_name = var.resource_group_name
  registry_name       = azurerm_container_registry.main.name
  location            = var.location
  
  service_uri = "https://placeholder.webhook.url/image-pushed"  # Configure in tfvars
  status      = "disabled"  # Enable after configuring actual URL
  scope       = "*:*"
  actions     = ["push"]
  
  custom_headers = {
    "Content-Type" = "application/json"
  }
  
  tags = local.common_tags
  
  lifecycle {
    ignore_changes = [service_uri, status]
  }
}

# =============================================================================
# TASKS (for automated builds - Premium only)
# =============================================================================

resource "azurerm_container_registry_task" "purge_old_images" {
  count = var.sku == "Premium" ? 1 : 0
  
  name                  = "purge-old-images"
  container_registry_id = azurerm_container_registry.main.id
  
  platform {
    os = "Linux"
  }
  
  encoded_step {
    task_content = base64encode(<<-EOT
      version: v1.1.0
      steps:
        - cmd: acr purge --filter '*:.*' --ago 90d --untagged --keep 10
          disableWorkingDirectoryOverride: true
          timeout: 3600
    EOT
    )
  }
  
  timer_trigger {
    name     = "weekly-purge"
    schedule = "0 0 * * 0"  # Weekly on Sunday at midnight
    enabled  = true
  }
  
  tags = local.common_tags
}

# =============================================================================
# DIAGNOSTIC SETTINGS
# =============================================================================

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = ""
}

resource "azurerm_monitor_diagnostic_setting" "acr" {
  count = var.log_analytics_workspace_id != "" ? 1 : 0
  
  name                       = "acr-diagnostics"
  target_resource_id         = azurerm_container_registry.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  enabled_log {
    category = "ContainerRegistryRepositoryEvents"
  }
  
  enabled_log {
    category = "ContainerRegistryLoginEvents"
  }
  
  metric {
    category = "AllMetrics"
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "id" {
  description = "Container Registry ID"
  value       = azurerm_container_registry.main.id
}

output "name" {
  description = "Container Registry name"
  value       = azurerm_container_registry.main.name
}

output "login_server" {
  description = "Container Registry login server"
  value       = azurerm_container_registry.main.login_server
}

output "admin_username" {
  description = "Container Registry admin username (if enabled)"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "identity_principal_id" {
  description = "Container Registry managed identity principal ID"
  value       = azurerm_container_registry.main.identity[0].principal_id
}

output "private_endpoint_ip" {
  description = "Private endpoint IP address"
  value       = azurerm_private_endpoint.acr.private_service_connection[0].private_ip_address
}

output "scope_map_ids" {
  description = "Scope map IDs for token creation"
  value = {
    ci_push  = azurerm_container_registry_scope_map.ci_push.id
    readonly = azurerm_container_registry_scope_map.readonly.id
  }
}
