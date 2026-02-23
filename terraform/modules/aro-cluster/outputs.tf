# =============================================================================
# ARO CLUSTER MODULE — OUTPUTS
# =============================================================================

output "cluster_id" {
  description = "ARO cluster resource ID"
  value       = azurerm_redhat_openshift_cluster.aro.id
}

output "cluster_name" {
  description = "ARO cluster name"
  value       = azurerm_redhat_openshift_cluster.aro.name
}

output "api_server_url" {
  description = "ARO API server URL"
  value       = azurerm_redhat_openshift_cluster.aro.api_server_profile[0].url
}

output "console_url" {
  description = "ARO web console URL"
  value       = azurerm_redhat_openshift_cluster.aro.console_url
}

output "ingress_ip" {
  description = "ARO ingress IP (if public)"
  value       = azurerm_redhat_openshift_cluster.aro.ingress_profile[0].ip
}

output "resource_group_name" {
  description = "Resource group name"
  value       = azurerm_resource_group.aro.name
}

output "location" {
  description = "Azure region"
  value       = azurerm_resource_group.aro.location
}
