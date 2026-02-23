# =============================================================================
# AGENTIC DEVOPS PLATFORM — ARO CLUSTER MODULE
# =============================================================================
# Deploys Azure Red Hat OpenShift (ARO) for RHDH deployments.
# Region: Central US or East US only.
# =============================================================================

resource "azurerm_resource_group" "aro" {
  name     = "${var.customer_name}-${var.environment}-aro-rg"
  location = var.location

  tags = merge(var.tags, {
    component   = "aro-cluster"
    environment = var.environment
    managed-by  = "terraform"
  })
}

# --- Virtual Network for ARO ---
resource "azurerm_virtual_network" "aro" {
  name                = "${var.customer_name}-${var.environment}-aro-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.aro.location
  resource_group_name = azurerm_resource_group.aro.name
  tags                = azurerm_resource_group.aro.tags
}

resource "azurerm_subnet" "master" {
  name                                          = "master-subnet"
  resource_group_name                           = azurerm_resource_group.aro.name
  virtual_network_name                          = azurerm_virtual_network.aro.name
  address_prefixes                              = [var.master_subnet_cidr]
  private_link_service_network_policies_enabled = false
}

resource "azurerm_subnet" "worker" {
  name                 = "worker-subnet"
  resource_group_name  = azurerm_resource_group.aro.name
  virtual_network_name = azurerm_virtual_network.aro.name
  address_prefixes     = [var.worker_subnet_cidr]
}

# --- Service Principals for ARO ---
data "azuread_client_config" "current" {}

resource "azuread_application" "aro_cluster" {
  display_name = "${var.customer_name}-${var.environment}-aro-cluster-sp"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "aro_cluster" {
  client_id = azuread_application.aro_cluster.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "aro_cluster" {
  service_principal_id = azuread_service_principal.aro_cluster.id
}

# --- ARO Cluster ---
resource "azurerm_redhat_openshift_cluster" "aro" {
  name                = "${var.customer_name}-${var.environment}-aro"
  location            = azurerm_resource_group.aro.location
  resource_group_name = azurerm_resource_group.aro.name

  cluster_profile {
    domain          = "${var.customer_name}${var.environment}"
    version         = var.openshift_version
    pull_secret     = var.pull_secret
    fips_enabled    = false
  }

  network_profile {
    pod_cidr     = var.pod_cidr
    service_cidr = var.service_cidr
  }

  main_profile {
    vm_size                    = var.master_vm_size
    encryption_at_host_enabled = false
    subnet_id                  = azurerm_subnet.master.id
  }

  worker_profile {
    vm_size                    = var.worker_vm_size
    disk_size_gb               = var.worker_disk_size_gb
    node_count                 = var.worker_node_count
    encryption_at_host_enabled = false
    subnet_id                  = azurerm_subnet.worker.id
  }

  api_server_profile {
    visibility = var.api_server_visibility
  }

  ingress_profile {
    visibility = var.ingress_visibility
  }

  service_principal {
    client_id     = azuread_application.aro_cluster.client_id
    client_secret = azuread_service_principal_password.aro_cluster.value
  }

  tags = azurerm_resource_group.aro.tags
}
