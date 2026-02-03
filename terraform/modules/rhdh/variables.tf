# =============================================================================
# THREE HORIZONS ACCELERATOR - RHDH MODULE VARIABLES
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

variable "namespace" {
  description = "Kubernetes namespace for RHDH"
  type        = string
  default     = "rhdh"
}

variable "rhdh_version" {
  description = "RHDH Helm chart version"
  type        = string
  default     = "1.2.0"
}

variable "base_url" {
  description = "Base URL for RHDH (e.g., https://developer.example.com)"
  type        = string
}

variable "postgresql_host" {
  description = "PostgreSQL server hostname"
  type        = string
}

variable "postgresql_database" {
  description = "PostgreSQL database name"
  type        = string
  default     = "rhdh"
}

variable "postgresql_username" {
  description = "PostgreSQL username"
  type        = string
  default     = "rhdh"
}

variable "postgresql_password" {
  description = "PostgreSQL password"
  type        = string
  sensitive   = true
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_app_client_id" {
  description = "GitHub App client ID"
  type        = string
}

variable "github_app_client_secret" {
  description = "GitHub App client secret"
  type        = string
  sensitive   = true
}

variable "github_app_private_key" {
  description = "GitHub App private key (PEM format)"
  type        = string
  sensitive   = true
}

variable "github_app_webhook_secret" {
  description = "GitHub App webhook secret"
  type        = string
  sensitive   = true
}

variable "argocd_url" {
  description = "ArgoCD server URL"
  type        = string
}

variable "argocd_auth_token" {
  description = "ArgoCD authentication token"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure AD tenant ID for authentication"
  type        = string
}

variable "azure_client_id" {
  description = "Azure AD application client ID for RHDH auth"
  type        = string
}

variable "azure_client_secret" {
  description = "Azure AD application client secret"
  type        = string
  sensitive   = true
}

variable "key_vault_name" {
  description = "Key Vault name for secrets"
  type        = string
}

variable "aks_oidc_issuer_url" {
  description = "AKS OIDC issuer URL for workload identity"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
}

variable "replicas" {
  description = "Number of RHDH replicas"
  type        = number
  default     = 2
}

variable "enable_techdocs" {
  description = "Enable TechDocs with Azure Blob Storage"
  type        = bool
  default     = true
}

variable "enable_search" {
  description = "Enable search functionality"
  type        = bool
  default     = true
}

variable "enable_kubernetes_plugin" {
  description = "Enable Kubernetes plugin"
  type        = bool
  default     = true
}

variable "additional_plugins" {
  description = "Additional plugins to enable"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
