# =============================================================================
# THREE HORIZONS PLATFORM - OUTPUTS
# =============================================================================

# -----------------------------------------------------------------------------
# RESOURCE GROUP
# -----------------------------------------------------------------------------

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

# -----------------------------------------------------------------------------
# NETWORKING
# -----------------------------------------------------------------------------

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = module.networking.aks_subnet_id
}

# -----------------------------------------------------------------------------
# AKS CLUSTER
# -----------------------------------------------------------------------------

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = var.kubernetes_platform == "aks" ? module.aks_cluster[0].cluster_name : null
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = var.kubernetes_platform == "aks" ? module.aks_cluster[0].cluster_id : null
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = var.kubernetes_platform == "aks" ? module.aks_cluster[0].cluster_fqdn : null
}

output "aks_kubelet_identity" {
  description = "Kubelet managed identity"
  value       = var.kubernetes_platform == "aks" ? module.aks_cluster[0].kubelet_identity : null
}

output "kube_config" {
  description = "Kubernetes config for kubectl"
  value       = var.kubernetes_platform == "aks" ? module.aks_cluster[0].kube_config : null
  sensitive   = true
}

# -----------------------------------------------------------------------------
# CONTAINER REGISTRY
# -----------------------------------------------------------------------------

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = module.container_registry.acr_name
}

output "acr_login_server" {
  description = "Login server URL for ACR"
  value       = module.container_registry.login_server
}

output "acr_admin_username" {
  description = "Admin username for ACR"
  value       = module.container_registry.admin_username
  sensitive   = true
}

# -----------------------------------------------------------------------------
# DATABASE
# -----------------------------------------------------------------------------

output "postgresql_server_name" {
  description = "Name of the PostgreSQL server"
  value       = module.databases.server_name
}

output "postgresql_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.databases.server_fqdn
}

output "postgresql_connection_string" {
  description = "Connection string for PostgreSQL"
  value       = module.databases.connection_string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# KEY VAULT
# -----------------------------------------------------------------------------

output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = module.security.keyvault_name
}

output "keyvault_uri" {
  description = "URI of the Key Vault"
  value       = module.security.keyvault_uri
}

# -----------------------------------------------------------------------------
# PLATFORM URLS
# -----------------------------------------------------------------------------

output "argocd_url" {
  description = "ArgoCD dashboard URL"
  value       = var.enable_argocd ? module.argocd[0].argocd_url : null
}

output "rhdh_url" {
  description = "Red Hat Developer Hub URL"
  value       = var.enable_rhdh ? module.rhdh[0].rhdh_url : null
}

output "grafana_url" {
  description = "Grafana dashboard URL"
  value       = var.enable_observability ? module.observability[0].grafana_url : null
}

# -----------------------------------------------------------------------------
# AI FOUNDRY (if enabled)
# -----------------------------------------------------------------------------

output "ai_foundry_endpoint" {
  description = "Azure AI Foundry endpoint"
  value       = var.enable_ai_foundry ? module.ai_foundry[0].endpoint : null
}

# -----------------------------------------------------------------------------
# DEFENDER (if enabled)
# -----------------------------------------------------------------------------

output "defender_workspace_id" {
  description = "Defender for Cloud workspace ID"
  value       = var.enable_defender ? module.defender[0].workspace_id : null
}

# -----------------------------------------------------------------------------
# GITHUB RUNNERS (if enabled)
# -----------------------------------------------------------------------------

output "github_runner_scale_set_id" {
  description = "GitHub Runner Scale Set ID"
  value       = var.enable_github_runners ? module.github_runners[0].scale_set_id : null
}

# -----------------------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------------------

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    project     = var.project_name
    environment = var.environment
    location    = var.location
    platform    = var.kubernetes_platform
    
    endpoints = {
      aks_fqdn    = var.kubernetes_platform == "aks" ? module.aks_cluster[0].cluster_fqdn : "N/A"
      acr_server  = module.container_registry.login_server
      keyvault    = module.security.keyvault_uri
      argocd      = var.enable_argocd ? module.argocd[0].argocd_url : "Not deployed"
      rhdh        = var.enable_rhdh ? module.rhdh[0].rhdh_url : "Not deployed"
      grafana     = var.enable_observability ? module.observability[0].grafana_url : "Not deployed"
    }
    
    features = {
      defender     = var.enable_defender
      purview      = var.enable_purview
      ai_foundry   = var.enable_ai_foundry
      github_runners = var.enable_github_runners
    }
  }
}
