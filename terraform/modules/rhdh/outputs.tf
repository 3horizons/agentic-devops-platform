output "namespace" {
  description = "RHDH namespace"
  value       = kubernetes_namespace.rhdh.metadata[0].name
}

output "url" {
  description = "RHDH URL"
  value       = var.base_url
}

output "service_account" {
  description = "RHDH service account name"
  value       = "rhdh"
}

output "managed_identity_client_id" {
  description = "RHDH managed identity client ID"
  value       = azurerm_user_assigned_identity.rhdh.client_id
}

output "storage_account_name" {
  description = "TechDocs storage account name"
  value       = var.enable_techdocs ? azurerm_storage_account.techdocs[0].name : null
}

output "storage_container_name" {
  description = "TechDocs storage container name"
  value       = var.enable_techdocs ? azurerm_storage_container.techdocs[0].name : null
}
