# =============================================================================
# THREE HORIZONS ACCELERATOR - RHDH INFRASTRUCTURE TERRAFORM MODULE
# =============================================================================
#
# Deploys Red Hat Developer Hub (Backstage) infrastructure on AKS.
#
# Components:
#   - RHDH Helm deployment
#   - PostgreSQL database integration
#   - Azure Blob Storage for TechDocs
#   - Workload identity configuration
#   - GitHub integration
#   - ArgoCD integration
#
# =============================================================================

# NOTE: Terraform block is in versions.tf

# =============================================================================
# LOCALS
# =============================================================================

locals {
  name_prefix = "${var.customer_name}-${var.environment}"

  common_tags = merge(var.tags, {
    "three-horizons/customer"    = var.customer_name
    "three-horizons/environment" = var.environment
    "three-horizons/component"   = "rhdh"
  })

  common_labels = {
    "app.kubernetes.io/name"       = "rhdh"
    "app.kubernetes.io/instance"   = local.name_prefix
    "app.kubernetes.io/component"  = "developer-portal"
    "app.kubernetes.io/managed-by" = "terraform"
    "three-horizons/customer"      = var.customer_name
    "three-horizons/environment"   = var.environment
  }
}

# =============================================================================
# STORAGE ACCOUNT FOR TECHDOCS
# =============================================================================

resource "azurerm_storage_account" "techdocs" {
  count = var.enable_techdocs ? 1 : 0

  name                     = "st${replace(local.name_prefix, "-", "")}techdocs"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = var.environment == "prod" ? "GRS" : "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    container_delete_retention_policy {
      days = 30
    }
  }

  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]

    virtual_network_subnet_ids = [var.subnet_id]
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "techdocs" {
  count = var.enable_techdocs ? 1 : 0

  name                  = "techdocs"
  storage_account_name  = azurerm_storage_account.techdocs[0].name
  container_access_type = "private"
}

# =============================================================================
# MANAGED IDENTITY FOR RHDH
# =============================================================================

resource "azurerm_user_assigned_identity" "rhdh" {
  name                = "id-${local.name_prefix}-rhdh"
  resource_group_name = var.resource_group_name
  location            = var.location

  tags = local.common_tags
}

# Federated credential for workload identity
resource "azurerm_federated_identity_credential" "rhdh" {
  name                = "rhdh-federated"
  resource_group_name = var.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = var.aks_oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.rhdh.id
  subject             = "system:serviceaccount:${var.namespace}:rhdh"
}

# Key Vault access for RHDH identity
resource "azurerm_role_assignment" "rhdh_keyvault" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.KeyVault/vaults/${var.key_vault_name}"
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.rhdh.principal_id
}

# Storage Blob access for TechDocs
resource "azurerm_role_assignment" "rhdh_storage" {
  count = var.enable_techdocs ? 1 : 0

  scope                = azurerm_storage_account.techdocs[0].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.rhdh.principal_id
}

data "azurerm_client_config" "current" {}

# =============================================================================
# KUBERNETES NAMESPACE
# =============================================================================

resource "kubernetes_namespace" "rhdh" {
  metadata {
    name = var.namespace

    labels = merge(local.common_labels, {
      "app.kubernetes.io/part-of" = "three-horizons"
    })
  }
}

# =============================================================================
# KUBERNETES SECRETS
# =============================================================================

resource "kubernetes_secret" "rhdh_secrets" {
  metadata {
    name      = "rhdh-secrets"
    namespace = kubernetes_namespace.rhdh.metadata[0].name
    labels    = local.common_labels
  }

  data = {
    # Database
    POSTGRES_HOST     = var.postgresql_host
    POSTGRES_PORT     = "5432"
    POSTGRES_USER     = var.postgresql_username
    POSTGRES_PASSWORD = var.postgresql_password
    POSTGRES_DB       = var.postgresql_database

    # GitHub App
    GITHUB_APP_ID             = var.github_app_id
    GITHUB_APP_CLIENT_ID      = var.github_app_client_id
    GITHUB_APP_CLIENT_SECRET  = var.github_app_client_secret
    GITHUB_APP_PRIVATE_KEY    = var.github_app_private_key
    GITHUB_APP_WEBHOOK_SECRET = var.github_app_webhook_secret

    # Azure AD
    AZURE_TENANT_ID     = var.azure_tenant_id
    AZURE_CLIENT_ID     = var.azure_client_id
    AZURE_CLIENT_SECRET = var.azure_client_secret

    # ArgoCD
    ARGOCD_AUTH_TOKEN = var.argocd_auth_token

    # Storage (if TechDocs enabled)
    AZURE_STORAGE_ACCOUNT = var.enable_techdocs ? azurerm_storage_account.techdocs[0].name : ""
    AZURE_STORAGE_KEY     = var.enable_techdocs ? azurerm_storage_account.techdocs[0].primary_access_key : ""
  }

  type = "Opaque"
}

# =============================================================================
# RHDH APP-CONFIG CONFIGMAP
# =============================================================================

resource "kubernetes_config_map" "rhdh_config" {
  metadata {
    name      = "rhdh-app-config"
    namespace = kubernetes_namespace.rhdh.metadata[0].name
    labels    = local.common_labels
  }

  data = {
    "app-config.yaml" = yamlencode({
      app = {
        title   = "${var.customer_name} Developer Portal"
        baseUrl = var.base_url
      }

      organization = {
        name = var.customer_name
      }

      backend = {
        baseUrl = var.base_url
        listen = {
          port = 7007
        }
        csp = {
          connect-src = ["'self'", "http:", "https:"]
        }
        cors = {
          origin      = var.base_url
          methods     = ["GET", "HEAD", "PATCH", "POST", "PUT", "DELETE"]
          credentials = true
        }
        database = {
          client = "pg"
          connection = {
            host     = "$${POSTGRES_HOST}"
            port     = "$${POSTGRES_PORT}"
            user     = "$${POSTGRES_USER}"
            password = "$${POSTGRES_PASSWORD}"
            database = "$${POSTGRES_DB}"
            ssl = {
              rejectUnauthorized = true
            }
          }
        }
      }

      integrations = {
        github = [
          {
            host = "github.com"
            apps = [
              {
                appId         = "$${GITHUB_APP_ID}"
                clientId      = "$${GITHUB_APP_CLIENT_ID}"
                clientSecret  = "$${GITHUB_APP_CLIENT_SECRET}"
                privateKey    = "$${GITHUB_APP_PRIVATE_KEY}"
                webhookSecret = "$${GITHUB_APP_WEBHOOK_SECRET}"
              }
            ]
          }
        ]
      }

      auth = {
        environment = var.environment
        providers = {
          microsoft = {
            development = {
              clientId     = "$${AZURE_CLIENT_ID}"
              clientSecret = "$${AZURE_CLIENT_SECRET}"
              tenantId     = "$${AZURE_TENANT_ID}"
            }
          }
          github = {
            development = {
              clientId     = "$${GITHUB_APP_CLIENT_ID}"
              clientSecret = "$${GITHUB_APP_CLIENT_SECRET}"
            }
          }
        }
      }

      catalog = {
        import = {
          entityFilename        = "catalog-info.yaml"
          pullRequestBranchName = "backstage-integration"
        }
        rules = [
          { allow = ["Component", "System", "API", "Resource", "Location", "Template", "Group", "User", "Domain"] }
        ]
        locations = [
          {
            type   = "url"
            target = "https://github.com/${var.github_org}/software-templates/blob/main/all-templates.yaml"
          },
          {
            type   = "url"
            target = "https://github.com/${var.github_org}/software-catalog/blob/main/all.yaml"
          }
        ]
      }

      scaffolder = {
        defaultAuthor = {
          name  = "RHDH Scaffolder"
          email = "scaffolder@${var.customer_name}.com"
        }
        defaultCommitMessage = "Initial commit from RHDH scaffolder"
      }

      techdocs = var.enable_techdocs ? {
        builder   = "external"
        generator = { runIn = "local" }
        publisher = {
          type = "azureBlobStorage"
          azureBlobStorage = {
            containerName = "techdocs"
            credentials = {
              accountName = "$${AZURE_STORAGE_ACCOUNT}"
              accountKey  = "$${AZURE_STORAGE_KEY}"
            }
          }
        }
      } : { builder = "local" }

      kubernetes = var.enable_kubernetes_plugin ? {
        serviceLocatorMethod = { type = "multiTenant" }
        clusterLocatorMethods = [
          {
            type = "config"
            clusters = [
              {
                url                 = "https://kubernetes.default.svc"
                name                = "local-cluster"
                authProvider        = "serviceAccount"
                skipTLSVerify       = false
                skipMetricsLookup   = false
                serviceAccountToken = "$${KUBERNETES_SERVICE_ACCOUNT_TOKEN}"
                caData              = "$${KUBERNETES_CA_DATA}"
              }
            ]
          }
        ]
      } : null

      argocd = {
        baseUrl = var.argocd_url
        appLocatorMethods = [
          {
            type = "config"
            instances = [
              {
                name  = "argocd"
                url   = var.argocd_url
                token = "$${ARGOCD_AUTH_TOKEN}"
              }
            ]
          }
        ]
      }

      search = var.enable_search ? {
        pg = {
          highlightOptions = {
            useHighlight      = true
            maxWord           = 35
            minWord           = 15
            shortWord         = 3
            highlightAll      = false
            maxFragments      = 0
            fragmentDelimiter = " ... "
          }
        }
      } : null
    })
  }
}

# =============================================================================
# RHDH HELM RELEASE
# =============================================================================

resource "helm_release" "rhdh" {
  name       = "rhdh"
  namespace  = kubernetes_namespace.rhdh.metadata[0].name
  repository = "https://redhat-developer.github.io/rhdh-chart"
  chart      = "backstage"
  version    = var.rhdh_version

  values = [yamlencode({
    global = {
      clusterRouterBase = replace(var.base_url, "https://", "")
    }

    upstream = {
      backstage = {
        replicas = var.replicas

        image = {
          registry   = "quay.io"
          repository = "rhdh/rhdh-hub-rhel9"
          tag        = "1.2"
        }

        appConfig = {
          configMaps = [
            { name = kubernetes_config_map.rhdh_config.metadata[0].name }
          ]
        }

        extraEnvVarsSecrets = [
          kubernetes_secret.rhdh_secrets.metadata[0].name
        ]

        extraEnvVars = [
          {
            name = "KUBERNETES_SERVICE_ACCOUNT_TOKEN"
            valueFrom = {
              secretKeyRef = {
                name = "rhdh-token"
                key  = "token"
              }
            }
          }
        ]

        podLabels = merge(local.common_labels, {
          "azure.workload.identity/use" = "true"
        })

        serviceAccount = {
          create = true
          name   = "rhdh"
          annotations = {
            "azure.workload.identity/client-id" = azurerm_user_assigned_identity.rhdh.client_id
          }
        }

        resources = {
          requests = {
            cpu    = "500m"
            memory = "1Gi"
          }
          limits = {
            cpu    = "2000m"
            memory = "4Gi"
          }
        }

        readinessProbe = {
          httpGet = {
            path = "/healthcheck"
            port = 7007
          }
          initialDelaySeconds = 30
          periodSeconds       = 10
          timeoutSeconds      = 5
          failureThreshold    = 3
        }

        livenessProbe = {
          httpGet = {
            path = "/healthcheck"
            port = 7007
          }
          initialDelaySeconds = 60
          periodSeconds       = 30
          timeoutSeconds      = 5
          failureThreshold    = 3
        }
      }

      postgresql = {
        enabled = false # Using external PostgreSQL
      }

      ingress = {
        enabled   = true
        className = "nginx"
        annotations = {
          "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
          "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
          "nginx.ingress.kubernetes.io/proxy-body-size"    = "50m"
          "nginx.ingress.kubernetes.io/proxy-read-timeout" = "600"
          "nginx.ingress.kubernetes.io/proxy-send-timeout" = "600"
        }
        host = replace(var.base_url, "https://", "")
        tls = {
          enabled    = true
          secretName = "rhdh-tls"
        }
      }
    }
  })]

  depends_on = [
    kubernetes_namespace.rhdh,
    kubernetes_secret.rhdh_secrets,
    kubernetes_config_map.rhdh_config
  ]
}

# =============================================================================
# SERVICE ACCOUNT TOKEN SECRET
# =============================================================================

resource "kubernetes_secret" "rhdh_token" {
  metadata {
    name      = "rhdh-token"
    namespace = kubernetes_namespace.rhdh.metadata[0].name

    annotations = {
      "kubernetes.io/service-account.name" = "rhdh"
    }

    labels = local.common_labels
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [helm_release.rhdh]
}

# =============================================================================
# CLUSTER ROLE FOR KUBERNETES PLUGIN
# =============================================================================

resource "kubernetes_cluster_role" "rhdh_read" {
  metadata {
    name   = "rhdh-kubernetes-read"
    labels = local.common_labels
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "configmaps", "secrets", "namespaces", "events"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "statefulsets", "daemonsets"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  rule {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "rhdh_read" {
  metadata {
    name   = "rhdh-kubernetes-read"
    labels = local.common_labels
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.rhdh_read.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "rhdh"
    namespace = var.namespace
  }

  depends_on = [helm_release.rhdh]
}

# =============================================================================
# POD DISRUPTION BUDGET
# =============================================================================

resource "kubernetes_pod_disruption_budget_v1" "rhdh" {
  metadata {
    name      = "rhdh-pdb"
    namespace = kubernetes_namespace.rhdh.metadata[0].name
    labels    = local.common_labels
  }

  spec {
    min_available = var.replicas > 1 ? 1 : 0

    selector {
      match_labels = {
        "app.kubernetes.io/name"     = "backstage"
        "app.kubernetes.io/instance" = "rhdh"
      }
    }
  }

  depends_on = [helm_release.rhdh]
}

# =============================================================================
# OUTPUTS
# =============================================================================


