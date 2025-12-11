# =============================================================================
# THREE HORIZONS ACCELERATOR - DEFENDER FOR CLOUD TERRAFORM MODULE
# =============================================================================
#
# Deploys Microsoft Defender for Cloud with enterprise security posture.
#
# Components:
#   - Defender CSPM (Cloud Security Posture Management)
#   - Defender for Containers
#   - Defender for Servers (P1/P2)
#   - Defender for Databases (SQL, PostgreSQL, Cosmos DB)
#   - Defender for Key Vault, Storage, App Service, DNS, ARM
#   - Defender for AI (preview)
#   - Regulatory Compliance (CIS, NIST, PCI DSS, ISO 27001, LGPD)
#   - Governance Rules for auto-remediation
#   - Continuous Export to Log Analytics
#
# Sizing Profiles:
#   - Small:  Free CSPM + Containers (~$100/mo)
#   - Medium: Standard CSPM + P1 Servers (~$500/mo)
#   - Large:  Full CSPM + P2 Servers + all workloads (~$2,000/mo)
#   - XLarge: Enterprise + regulatory compliance + JIT (~$5,000/mo)
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

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "customer_name" {
  description = "Customer name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "sizing_profile" {
  description = "Sizing profile: small, medium, large, xlarge"
  type        = string
  default     = "medium"
  
  validation {
    condition     = contains(["small", "medium", "large", "xlarge"], var.sizing_profile)
    error_message = "Sizing profile must be small, medium, large, or xlarge."
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for continuous export"
  type        = string
}

variable "security_contact_email" {
  description = "Email for security alerts"
  type        = string
}

variable "security_contact_phone" {
  description = "Phone for security alerts (optional)"
  type        = string
  default     = ""
}

variable "aks_cluster_ids" {
  description = "AKS cluster resource IDs for Defender for Containers"
  type        = list(string)
  default     = []
}

variable "regulatory_compliance_standards" {
  description = "Regulatory compliance standards to enable"
  type        = list(string)
  default     = ["Azure-CIS-1.4.0"]
  
  # Available: Azure-CIS-1.4.0, NIST-SP-800-53-Rev5, PCI-DSS-4.0, 
  #            ISO-27001-2013, SOC-2-Type-2, LGPD
}

variable "enable_jit_access" {
  description = "Enable Just-In-Time VM access"
  type        = bool
  default     = true
}

variable "auto_provisioning_settings" {
  description = "Auto-provisioning settings for agents"
  type = object({
    log_analytics_agent = bool
    vulnerability_assessment = bool
    defender_for_containers = bool
  })
  default = {
    log_analytics_agent = true
    vulnerability_assessment = true
    defender_for_containers = true
  }
}

variable "governance_rules" {
  description = "Governance rules for auto-remediation"
  type = list(object({
    name        = string
    description = string
    owner_email = string
    grace_period_days = number
    severity    = string  # High, Medium, Low
  }))
  default = []
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
  # Pricing configurations by sizing profile
  pricing_config = {
    small = {
      cspm                = "Free"
      containers          = "Standard"
      servers             = "Free"
      servers_plan        = null
      sql_servers         = "Free"
      app_services        = "Free"
      storage             = "Free"
      key_vaults          = "Free"
      dns                 = "Free"
      arm                 = "Free"
      open_source_dbs     = "Free"
      cosmos_dbs          = "Free"
      ai                  = "Free"
    }
    medium = {
      cspm                = "Standard"
      containers          = "Standard"
      servers             = "Standard"
      servers_plan        = "P1"
      sql_servers         = "Standard"
      app_services        = "Standard"
      storage             = "Free"
      key_vaults          = "Standard"
      dns                 = "Free"
      arm                 = "Standard"
      open_source_dbs     = "Standard"
      cosmos_dbs          = "Free"
      ai                  = "Free"
    }
    large = {
      cspm                = "Standard"
      containers          = "Standard"
      servers             = "Standard"
      servers_plan        = "P2"
      sql_servers         = "Standard"
      app_services        = "Standard"
      storage             = "Standard"
      key_vaults          = "Standard"
      dns                 = "Standard"
      arm                 = "Standard"
      open_source_dbs     = "Standard"
      cosmos_dbs          = "Standard"
      ai                  = "Standard"
    }
    xlarge = {
      cspm                = "Standard"
      containers          = "Standard"
      servers             = "Standard"
      servers_plan        = "P2"
      sql_servers         = "Standard"
      app_services        = "Standard"
      storage             = "Standard"
      key_vaults          = "Standard"
      dns                 = "Standard"
      arm                 = "Standard"
      open_source_dbs     = "Standard"
      cosmos_dbs          = "Standard"
      ai                  = "Standard"
    }
  }
  
  current_pricing = local.pricing_config[var.sizing_profile]
  
  # Compliance standards by profile
  compliance_by_profile = {
    small  = ["Azure-CIS-1.4.0"]
    medium = ["Azure-CIS-1.4.0", "NIST-SP-800-53-Rev5"]
    large  = ["Azure-CIS-1.4.0", "NIST-SP-800-53-Rev5", "PCI-DSS-4.0", "ISO-27001-2013"]
    xlarge = ["Azure-CIS-1.4.0", "NIST-SP-800-53-Rev5", "PCI-DSS-4.0", "ISO-27001-2013", "SOC-2-Type-2", "LGPD"]
  }
  
  effective_compliance = length(var.regulatory_compliance_standards) > 0 ? var.regulatory_compliance_standards : local.compliance_by_profile[var.sizing_profile]
  
  common_tags = merge(var.tags, {
    "three-horizons/customer"    = var.customer_name
    "three-horizons/environment" = var.environment
    "three-horizons/component"   = "defender-for-cloud"
    "three-horizons/sizing"      = var.sizing_profile
  })
}

# =============================================================================
# SECURITY CONTACT
# =============================================================================

resource "azurerm_security_center_contact" "main" {
  email               = var.security_contact_email
  phone               = var.security_contact_phone != "" ? var.security_contact_phone : null
  alert_notifications = true
  alerts_to_admins    = true
}

# =============================================================================
# DEFENDER PRICING TIERS
# =============================================================================

# Cloud Security Posture Management (CSPM)
resource "azurerm_security_center_subscription_pricing" "cspm" {
  tier          = local.current_pricing.cspm
  resource_type = "CloudPosture"
  
  dynamic "extension" {
    for_each = local.current_pricing.cspm == "Standard" ? [1] : []
    content {
      name = "SensitiveDataDiscovery"
    }
  }
  
  dynamic "extension" {
    for_each = local.current_pricing.cspm == "Standard" ? [1] : []
    content {
      name = "ContainerRegistriesVulnerabilityAssessments"
    }
  }
  
  dynamic "extension" {
    for_each = local.current_pricing.cspm == "Standard" ? [1] : []
    content {
      name = "AgentlessVmScanning"
    }
  }
}

# Defender for Containers
resource "azurerm_security_center_subscription_pricing" "containers" {
  tier          = local.current_pricing.containers
  resource_type = "Containers"
  
  dynamic "extension" {
    for_each = local.current_pricing.containers == "Standard" ? [1] : []
    content {
      name = "ContainerRegistriesVulnerabilityAssessments"
    }
  }
}

# Defender for Servers
resource "azurerm_security_center_subscription_pricing" "servers" {
  tier          = local.current_pricing.servers
  resource_type = "VirtualMachines"
  
  dynamic "extension" {
    for_each = local.current_pricing.servers == "Standard" && local.current_pricing.servers_plan != null ? [1] : []
    content {
      name = "MdeDesignatedSubscription"
    }
  }
  
  subplan = local.current_pricing.servers_plan
}

# Defender for SQL Servers
resource "azurerm_security_center_subscription_pricing" "sql_servers" {
  tier          = local.current_pricing.sql_servers
  resource_type = "SqlServers"
}

# Defender for App Services
resource "azurerm_security_center_subscription_pricing" "app_services" {
  tier          = local.current_pricing.app_services
  resource_type = "AppServices"
}

# Defender for Storage
resource "azurerm_security_center_subscription_pricing" "storage" {
  tier          = local.current_pricing.storage
  resource_type = "StorageAccounts"
  
  dynamic "extension" {
    for_each = local.current_pricing.storage == "Standard" ? [1] : []
    content {
      name = "OnUploadMalwareScanning"
      additional_extension_properties = {
        CapGBPerMonthPerStorageAccount = "5000"
      }
    }
  }
  
  dynamic "extension" {
    for_each = local.current_pricing.storage == "Standard" ? [1] : []
    content {
      name = "SensitiveDataDiscovery"
    }
  }
}

# Defender for Key Vault
resource "azurerm_security_center_subscription_pricing" "key_vaults" {
  tier          = local.current_pricing.key_vaults
  resource_type = "KeyVaults"
}

# Defender for DNS
resource "azurerm_security_center_subscription_pricing" "dns" {
  tier          = local.current_pricing.dns
  resource_type = "Dns"
}

# Defender for ARM
resource "azurerm_security_center_subscription_pricing" "arm" {
  tier          = local.current_pricing.arm
  resource_type = "Arm"
}

# Defender for Open Source Databases
resource "azurerm_security_center_subscription_pricing" "open_source_dbs" {
  tier          = local.current_pricing.open_source_dbs
  resource_type = "OpenSourceRelationalDatabases"
}

# Defender for Cosmos DB
resource "azurerm_security_center_subscription_pricing" "cosmos_dbs" {
  tier          = local.current_pricing.cosmos_dbs
  resource_type = "CosmosDbs"
}

# Defender for AI (Preview)
resource "azurerm_security_center_subscription_pricing" "ai" {
  tier          = local.current_pricing.ai
  resource_type = "Api"
}

# =============================================================================
# AUTO-PROVISIONING SETTINGS
# =============================================================================

resource "azurerm_security_center_auto_provisioning" "log_analytics" {
  auto_provision = var.auto_provisioning_settings.log_analytics_agent ? "On" : "Off"
}

# =============================================================================
# REGULATORY COMPLIANCE (via azapi for full control)
# =============================================================================

resource "azapi_resource" "regulatory_compliance" {
  for_each = toset(local.effective_compliance)
  
  type      = "Microsoft.Security/regulatoryComplianceStandards@2019-01-01-preview"
  name      = each.value
  parent_id = "/subscriptions/${var.subscription_id}"
  
  body = jsonencode({
    properties = {
      state = "Enabled"
    }
  })
}

# =============================================================================
# CONTINUOUS EXPORT TO LOG ANALYTICS
# =============================================================================

resource "azurerm_security_center_automation" "export_to_log_analytics" {
  name                = "ExportToLogAnalytics-${var.customer_name}"
  location            = "eastus"  # Global resource
  resource_group_name = "rg-${var.customer_name}-${var.environment}-security"
  
  scopes = ["/subscriptions/${var.subscription_id}"]
  
  action {
    type              = "LogAnalytics"
    resource_id       = var.log_analytics_workspace_id
  }
  
  source {
    event_source = "Alerts"
    rule_set {
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "High"
        property_type  = "String"
      }
    }
    rule_set {
      rule {
        property_path  = "Severity"
        operator       = "Equals"
        expected_value = "Medium"
        property_type  = "String"
      }
    }
  }
  
  source {
    event_source = "SecureScores"
  }
  
  source {
    event_source = "SecureScoreControls"
  }
  
  source {
    event_source = "RegulatoryComplianceAssessment"
  }
  
  tags = local.common_tags
}

# =============================================================================
# GOVERNANCE RULES (auto-remediation)
# =============================================================================

resource "azapi_resource" "governance_rules" {
  for_each = { for rule in var.governance_rules : rule.name => rule }
  
  type      = "Microsoft.Security/governanceRules@2022-01-01-preview"
  name      = each.value.name
  parent_id = "/subscriptions/${var.subscription_id}"
  
  body = jsonencode({
    properties = {
      displayName       = each.value.name
      description       = each.value.description
      isDisabled        = false
      rulePriority      = 100
      sourceResourceType = "Assessments"
      conditionSets = [
        {
          conditions = [
            {
              property = "$.Status.Severity"
              value    = each.value.severity
              operator = "Equals"
            }
          ]
        }
      ]
      ownerSource = {
        type  = "ByTag"
        value = "owner"
      }
      governanceEmailNotification = {
        disableManagerEmailNotification = false
        disableOwnerEmailNotification   = false
      }
      remediationTimeframe = "P${each.value.grace_period_days}D"
    }
  })
}

# =============================================================================
# DEFENDER FOR CONTAINERS - AKS INTEGRATION
# =============================================================================

resource "azapi_update_resource" "defender_for_aks" {
  for_each = toset(var.aks_cluster_ids)
  
  type        = "Microsoft.ContainerService/managedClusters@2023-08-01"
  resource_id = each.value
  
  body = jsonencode({
    properties = {
      securityProfile = {
        defender = {
          logAnalyticsWorkspaceResourceId = var.log_analytics_workspace_id
          securityMonitoring = {
            enabled = true
          }
        }
      }
    }
  })
}

# =============================================================================
# JUST-IN-TIME VM ACCESS POLICY (xlarge profile)
# =============================================================================

resource "azapi_resource" "jit_policy" {
  count = var.sizing_profile == "xlarge" && var.enable_jit_access ? 1 : 0
  
  type      = "Microsoft.Security/locations/jitNetworkAccessPolicies@2020-01-01"
  name      = "default"
  parent_id = "/subscriptions/${var.subscription_id}/resourceGroups/rg-${var.customer_name}-${var.environment}-compute/providers/Microsoft.Security/locations/brazilsouth"
  
  body = jsonencode({
    properties = {
      virtualMachines = []
      requests        = []
    }
  })
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "defender_status" {
  description = "Defender for Cloud pricing status by resource type"
  value = {
    cspm            = local.current_pricing.cspm
    containers      = local.current_pricing.containers
    servers         = "${local.current_pricing.servers} (${local.current_pricing.servers_plan != null ? local.current_pricing.servers_plan : "N/A"})"
    sql_servers     = local.current_pricing.sql_servers
    app_services    = local.current_pricing.app_services
    storage         = local.current_pricing.storage
    key_vaults      = local.current_pricing.key_vaults
    dns             = local.current_pricing.dns
    arm             = local.current_pricing.arm
    open_source_dbs = local.current_pricing.open_source_dbs
    cosmos_dbs      = local.current_pricing.cosmos_dbs
    ai              = local.current_pricing.ai
  }
}

output "compliance_standards" {
  description = "Enabled regulatory compliance standards"
  value       = local.effective_compliance
}

output "security_contact" {
  description = "Security contact email"
  value       = var.security_contact_email
}

output "sizing_profile" {
  description = "Active sizing profile"
  value       = var.sizing_profile
}

output "estimated_monthly_cost" {
  description = "Estimated monthly cost range"
  value = {
    small  = "$100-200"
    medium = "$500-1,000"
    large  = "$2,000-3,000"
    xlarge = "$5,000-10,000"
  }[var.sizing_profile]
}

output "continuous_export_id" {
  description = "Continuous export automation ID"
  value       = azurerm_security_center_automation.export_to_log_analytics.id
}
