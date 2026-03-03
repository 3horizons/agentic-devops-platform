locals {
  resource_suffix = "${var.app_name}-${var.environment}"
  common_tags = {
    environment = var.environment
    project     = var.app_name
    owner       = "${{ values.owner }}"
    cost-center = var.cost_center
    managed-by  = "terraform"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.resource_suffix}"
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "app" {
  name                     = substr(replace("st${var.app_name}${var.environment}", "-", ""), 0, 24)
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.common_tags
}
