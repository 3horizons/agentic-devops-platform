# =============================================================================
# THREE HORIZONS ACCELERATOR - SECURITY TERRAFORM MODULE
# =============================================================================
#
# Deploys security infrastructure for the platform.
#
# Components:
#   - Azure Key Vault with RBAC
#   - User-assigned managed identities
#   - Workload identity for AKS
#   - Role assignments
#
# =============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 2.45"
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

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL for workload identity"
  type        = string
}

variable "key_vault_config" {
  description = "Key Vault configuration"
  type = object({
    sku_name                    = string
    soft_delete_retention_days  = number
    purge_protection_enabled    = bool
    enable_rbac_authorization   = bool
    public_network_access_enabled = bool
    network_acls = object({
      bypass                     = string
      default_action             = string
      ip_rules                   = list(string)
      virtual_network_subnet_ids = list(string)
    })
  })
  default = {
    sku_name                      = "standard"
    soft_delete_retention_days    = 90
    purge_protection_enabled      = true
    enable_rbac_authorization     = true
    public_network_access_enabled = false
    network_acls = {
      bypass                     = "AzureServices"
      default_action             = "Deny"
      ip_rules                   = []
      virtual_network_subnet_ids = []
    }
  }
}

variable "admin_group_id" {
  description = "Azure AD group ID for Key Vault administrators"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for Key Vault"
  type        = string
}

variable "workload_identities" {
  description = "Workload identities to create"
  type = map(object({
    namespace           = string
    service_account     = string
    key_vault_role      = string  # "Key Vault Secrets User", "Key Vault Certificates User", etc.
    additional_role_assignments = list(object({
      scope                = string
      role_definition_name = string
    }))
  }))
  default = {
    "rhdh" = {
      namespace           = "rhdh"
      service_account     = "rhdh"
      key_vault_role      = "Key Vault Secrets User"
      additional_role_assignments = []
    }
    "argocd" = {
      namespace           = "argocd"
      service_account     = "argocd-server"
      key_vault_role      = "Key Vault Secrets User"
      additional_role_assignments = []
    }
    "external-secrets" = {
      namespace           = "external-secrets"
      service_account     = "external-secrets"
      key_vault_role      = "Key Vault Secrets User"
      additional_role_assignments = []
    }
  }
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
    "three-horizons/component"   = "security"
  })
}

# =============================================================================
# DATA SOURCES
# =============================================================================

data "azurerm_client_config" "current" {}

# =============================================================================
# KEY VAULT
# =============================================================================

resource "azurerm_key_vault" "main" {
  name                = substr("kv-${local.name_prefix}", 0, 24)
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  
  sku_name = var.key_vault_config.sku_name
  
  soft_delete_retention_days = var.key_vault_config.soft_delete_retention_days
  purge_protection_enabled   = var.key_vault_config.purge_protection_enabled
  enable_rbac_authorization  = var.key_vault_config.enable_rbac_authorization
  
  public_network_access_enabled = var.key_vault_config.public_network_access_enabled
  
  network_acls {
    bypass                     = var.key_vault_config.network_acls.bypass
    default_action             = var.key_vault_config.network_acls.default_action
    ip_rules                   = var.key_vault_config.network_acls.ip_rules
    virtual_network_subnet_ids = var.key_vault_config.network_acls.virtual_network_subnet_ids
  }
  
  tags = local.common_tags
}

# Key Vault Private Endpoint
resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-kv-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  
  private_service_connection {
    name                           = "kv-connection"
    private_connection_resource_id = azurerm_key_vault.main.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  
  private_dns_zone_group {
    name                 = "kv-dns-zone-group"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
  
  tags = local.common_tags
}

# Key Vault Administrator role for admin group
resource "azurerm_role_assignment" "kv_admin" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.admin_group_id
}

# Key Vault Administrator role for current deployment identity
resource "azurerm_role_assignment" "kv_admin_deployer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

# =============================================================================
# USER-ASSIGNED MANAGED IDENTITIES
# =============================================================================

resource "azurerm_user_assigned_identity" "workload" {
  for_each = var.workload_identities
  
  name                = "id-${each.key}-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = local.common_tags
}

# Key Vault role assignments for workload identities
resource "azurerm_role_assignment" "workload_kv" {
  for_each = var.workload_identities
  
  scope                = azurerm_key_vault.main.id
  role_definition_name = each.value.key_vault_role
  principal_id         = azurerm_user_assigned_identity.workload[each.key].principal_id
}

# Additional role assignments for workload identities
resource "azurerm_role_assignment" "workload_additional" {
  for_each = {
    for item in flatten([
      for name, identity in var.workload_identities : [
        for idx, assignment in identity.additional_role_assignments : {
          key                  = "${name}-${idx}"
          principal_id         = azurerm_user_assigned_identity.workload[name].principal_id
          scope                = assignment.scope
          role_definition_name = assignment.role_definition_name
        }
      ]
    ]) : item.key => item
  }
  
  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

# =============================================================================
# FEDERATED IDENTITY CREDENTIALS (Workload Identity)
# =============================================================================

resource "azurerm_federated_identity_credential" "workload" {
  for_each = var.workload_identities
  
  name                = "federated-${each.key}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.workload[each.key].id
  
  audience = ["api://AzureADTokenExchange"]
  issuer   = var.aks_oidc_issuer_url
  subject  = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
}

# =============================================================================
# EXTERNAL SECRETS OPERATOR IDENTITY (for cluster-wide secret management)
# =============================================================================

resource "azurerm_user_assigned_identity" "external_secrets" {
  name                = "id-external-secrets-${local.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  
  tags = local.common_tags
}

resource "azurerm_role_assignment" "external_secrets_kv" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.external_secrets.principal_id
}

resource "azurerm_federated_identity_credential" "external_secrets" {
  name                = "federated-external-secrets"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.external_secrets.id
  
  audience = ["api://AzureADTokenExchange"]
  issuer   = var.aks_oidc_issuer_url
  subject  = "system:serviceaccount:external-secrets:external-secrets"
}

# =============================================================================
# AZURE AD APPLICATION FOR GITHUB SSO (Optional)
# =============================================================================

resource "azuread_application" "github_sso" {
  display_name = "GitHub-SSO-${local.name_prefix}"
  
  web {
    redirect_uris = [
      "https://argocd.${var.customer_name}.com/api/dex/callback",
      "https://rhdh.${var.customer_name}.com/api/auth/microsoft/handler/frame"
    ]
    
    implicit_grant {
      access_token_issuance_enabled = false
      id_token_issuance_enabled     = true
    }
  }
  
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph
    
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
    
    resource_access {
      id   = "5f8c59db-677d-491f-a6b8-5f174b11ec1d" # Group.Read.All
      type = "Scope"
    }
  }
  
  group_membership_claims = ["SecurityGroup"]
  
  optional_claims {
    id_token {
      name = "groups"
    }
  }
  
  tags = ["three-horizons", var.environment]
}

resource "azuread_service_principal" "github_sso" {
  client_id = azuread_application.github_sso.client_id
  
  app_role_assignment_required = false
  
  tags = ["three-horizons", var.environment]
}

resource "azuread_application_password" "github_sso" {
  application_id = azuread_application.github_sso.id
  display_name   = "GitHub SSO Secret"
  end_date       = timeadd(timestamp(), "8760h") # 1 year
  
  lifecycle {
    ignore_changes = [end_date]
  }
}

# Store Azure AD app credentials in Key Vault
resource "azurerm_key_vault_secret" "aad_client_id" {
  name         = "aad-client-id"
  value        = azuread_application.github_sso.client_id
  key_vault_id = azurerm_key_vault.main.id
  
  tags = local.common_tags
  
  depends_on = [azurerm_role_assignment.kv_admin_deployer]
}

resource "azurerm_key_vault_secret" "aad_client_secret" {
  name         = "aad-client-secret"
  value        = azuread_application_password.github_sso.value
  key_vault_id = azurerm_key_vault.main.id
  
  tags = local.common_tags
  
  depends_on = [azurerm_role_assignment.kv_admin_deployer]
}

# =============================================================================
# DIAGNOSTIC SETTINGS
# =============================================================================

resource "azurerm_monitor_diagnostic_setting" "key_vault" {
  name                       = "kv-diagnostics"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.tags["log_analytics_workspace_id"] != null ? var.tags["log_analytics_workspace_id"] : null
  
  enabled_log {
    category = "AuditEvent"
  }
  
  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }
  
  metric {
    category = "AllMetrics"
  }
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.main.vault_uri
}

output "workload_identity_client_ids" {
  description = "Workload identity client IDs"
  value = {
    for name, identity in azurerm_user_assigned_identity.workload : name => identity.client_id
  }
}

output "workload_identity_principal_ids" {
  description = "Workload identity principal IDs"
  value = {
    for name, identity in azurerm_user_assigned_identity.workload : name => identity.principal_id
  }
}

output "external_secrets_client_id" {
  description = "External Secrets Operator client ID"
  value       = azurerm_user_assigned_identity.external_secrets.client_id
}

output "aad_application_id" {
  description = "Azure AD application ID for SSO"
  value       = azuread_application.github_sso.client_id
}

output "aad_tenant_id" {
  description = "Azure AD tenant ID"
  value       = var.tenant_id
}

output "private_endpoint_ip" {
  description = "Key Vault private endpoint IP"
  value       = azurerm_private_endpoint.key_vault.private_service_connection[0].private_ip_address
}
