# =============================================================================
# THREE HORIZONS ACCELERATOR - GITHUB RUNNERS TERRAFORM MODULE
# =============================================================================
#
# Deploys self-hosted GitHub Actions runners on AKS using Actions Runner Controller.
#
# Components:
#   - Actions Runner Controller (ARC) v2
#   - Runner Scale Sets for autoscaling
#   - Workload identity for Azure access
#   - Runner groups for team isolation
#
# =============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.75"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.11"
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

variable "namespace" {
  description = "Kubernetes namespace for runners"
  type        = string
  default     = "github-runners"
}

variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID for runner authentication"
  type        = string
  sensitive   = true
}

variable "github_app_installation_id" {
  description = "GitHub App installation ID"
  type        = string
  sensitive   = true
}

variable "github_app_private_key" {
  description = "GitHub App private key (PEM format)"
  type        = string
  sensitive   = true
}

variable "runner_groups" {
  description = "Runner scale set configurations"
  type = map(object({
    min_runners     = number
    max_runners     = number
    runner_group    = string
    labels          = list(string)
    node_selector   = map(string)
    tolerations     = list(object({
      key      = string
      operator = string
      value    = string
      effect   = string
    }))
    resources = object({
      cpu_request    = string
      cpu_limit      = string
      memory_request = string
      memory_limit   = string
    })
    container_mode = string  # "dind" or "kubernetes"
  }))
  default = {
    "default" = {
      min_runners   = 1
      max_runners   = 10
      runner_group  = "default"
      labels        = ["self-hosted", "linux", "x64"]
      node_selector = {}
      tolerations   = []
      resources = {
        cpu_request    = "500m"
        cpu_limit      = "2000m"
        memory_request = "1Gi"
        memory_limit   = "4Gi"
      }
      container_mode = "dind"
    }
  }
}

variable "controller_replicas" {
  description = "Number of controller replicas"
  type        = number
  default     = 2
}

variable "acr_login_server" {
  description = "Azure Container Registry login server for custom runner images"
  type        = string
  default     = ""
}

variable "custom_runner_image" {
  description = "Custom runner image (if not using default)"
  type        = string
  default     = ""
}

variable "azure_credentials" {
  description = "Azure credentials for runners (workload identity)"
  type = object({
    client_id     = string
    tenant_id     = string
    subscription_id = string
  })
  default = null
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
  
  common_labels = {
    "app.kubernetes.io/name"       = "github-runners"
    "app.kubernetes.io/instance"   = local.name_prefix
    "app.kubernetes.io/component"  = "cicd"
    "app.kubernetes.io/managed-by" = "terraform"
    "three-horizons/customer"      = var.customer_name
    "three-horizons/environment"   = var.environment
  }
}

# =============================================================================
# NAMESPACE
# =============================================================================

resource "kubernetes_namespace" "runners" {
  metadata {
    name = var.namespace
    
    labels = merge(local.common_labels, {
      "app.kubernetes.io/part-of" = "github-actions"
    })
  }
}

# =============================================================================
# GITHUB APP SECRET
# =============================================================================

resource "kubernetes_secret" "github_app" {
  metadata {
    name      = "github-app-credentials"
    namespace = kubernetes_namespace.runners.metadata[0].name
    
    labels = local.common_labels
  }
  
  data = {
    github_app_id              = var.github_app_id
    github_app_installation_id = var.github_app_installation_id
    github_app_private_key     = var.github_app_private_key
  }
  
  type = "Opaque"
}

# =============================================================================
# ACTIONS RUNNER CONTROLLER (ARC) - OPERATOR
# =============================================================================

resource "helm_release" "arc_controller" {
  name       = "arc-controller"
  namespace  = kubernetes_namespace.runners.metadata[0].name
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set-controller"
  version    = "0.9.3"
  
  values = [yamlencode({
    replicaCount = var.controller_replicas
    
    serviceAccount = {
      create = true
      name   = "arc-controller"
    }
    
    podLabels = local.common_labels
    
    resources = {
      requests = {
        cpu    = "100m"
        memory = "256Mi"
      }
      limits = {
        cpu    = "500m"
        memory = "512Mi"
      }
    }
    
    # High availability
    affinity = {
      podAntiAffinity = {
        preferredDuringSchedulingIgnoredDuringExecution = [
          {
            weight = 100
            podAffinityTerm = {
              labelSelector = {
                matchLabels = {
                  "app.kubernetes.io/name" = "gha-runner-scale-set-controller"
                }
              }
              topologyKey = "kubernetes.io/hostname"
            }
          }
        ]
      }
    }
    
    # Metrics for HPA and monitoring
    metrics = {
      controllerManagerAddr = ":8080"
      listenerAddr          = ":8080"
      listenerEndpoint      = "/metrics"
    }
  })]
  
  depends_on = [kubernetes_namespace.runners]
}

# =============================================================================
# RUNNER SCALE SETS
# =============================================================================

resource "helm_release" "runner_scale_sets" {
  for_each = var.runner_groups
  
  name       = "arc-runner-${each.key}"
  namespace  = kubernetes_namespace.runners.metadata[0].name
  repository = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart      = "gha-runner-scale-set"
  version    = "0.9.3"
  
  values = [yamlencode({
    githubConfigUrl = "https://github.com/${var.github_org}"
    
    githubConfigSecret = kubernetes_secret.github_app.metadata[0].name
    
    runnerGroup = each.value.runner_group
    
    # Runner image
    template = {
      spec = {
        containers = [
          {
            name  = "runner"
            image = var.custom_runner_image != "" ? var.custom_runner_image : "ghcr.io/actions/actions-runner:latest"
            command = ["/home/runner/run.sh"]
            
            env = concat(
              [
                {
                  name  = "ACTIONS_RUNNER_CONTAINER_HOOKS"
                  value = "/home/runner/k8s/index.js"
                },
                {
                  name  = "ACTIONS_RUNNER_POD_NAME"
                  valueFrom = {
                    fieldRef = {
                      fieldPath = "metadata.name"
                    }
                  }
                }
              ],
              # Azure credentials if provided
              var.azure_credentials != null ? [
                {
                  name  = "AZURE_CLIENT_ID"
                  value = var.azure_credentials.client_id
                },
                {
                  name  = "AZURE_TENANT_ID"
                  value = var.azure_credentials.tenant_id
                },
                {
                  name  = "AZURE_SUBSCRIPTION_ID"
                  value = var.azure_credentials.subscription_id
                }
              ] : []
            )
            
            resources = {
              requests = {
                cpu    = each.value.resources.cpu_request
                memory = each.value.resources.memory_request
              }
              limits = {
                cpu    = each.value.resources.cpu_limit
                memory = each.value.resources.memory_limit
              }
            }
            
            volumeMounts = each.value.container_mode == "dind" ? [
              {
                name      = "work"
                mountPath = "/home/runner/_work"
              }
            ] : []
          }
        ]
        
        # Docker-in-Docker sidecar
        initContainers = each.value.container_mode == "dind" ? [] : null
        
        volumes = each.value.container_mode == "dind" ? [
          {
            name = "work"
            emptyDir = {}
          }
        ] : []
        
        nodeSelector = each.value.node_selector
        
        tolerations = each.value.tolerations
        
        # Service account for workload identity
        serviceAccountName = "arc-runner-${each.key}"
      }
    }
    
    # Autoscaling configuration
    minRunners = each.value.min_runners
    maxRunners = each.value.max_runners
    
    # Container mode
    containerMode = {
      type = each.value.container_mode
      kubernetesModeWorkVolumeClaim = each.value.container_mode == "kubernetes" ? {
        accessModes      = ["ReadWriteOnce"]
        storageClassName = "managed-csi"
        resources = {
          requests = {
            storage = "10Gi"
          }
        }
      } : null
    }
    
    # Labels for runner selection
    listenerTemplate = {
      metadata = {
        labels = merge(local.common_labels, {
          "runner-group" = each.value.runner_group
        })
      }
    }
  })]
  
  depends_on = [helm_release.arc_controller]
}

# =============================================================================
# SERVICE ACCOUNTS FOR WORKLOAD IDENTITY
# =============================================================================

resource "kubernetes_service_account" "runner" {
  for_each = var.runner_groups
  
  metadata {
    name      = "arc-runner-${each.key}"
    namespace = kubernetes_namespace.runners.metadata[0].name
    
    labels = merge(local.common_labels, {
      "runner-group" = each.value.runner_group
    })
    
    annotations = var.azure_credentials != null ? {
      "azure.workload.identity/client-id" = var.azure_credentials.client_id
    } : {}
  }
}

# =============================================================================
# NETWORK POLICIES
# =============================================================================

resource "kubernetes_network_policy" "runners" {
  metadata {
    name      = "runner-network-policy"
    namespace = kubernetes_namespace.runners.metadata[0].name
  }
  
  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "github-runners"
      }
    }
    
    policy_types = ["Ingress", "Egress"]
    
    # Allow all egress (runners need internet access)
    egress {
      to {
        ip_block {
          cidr = "0.0.0.0/0"
        }
      }
    }
    
    # Ingress from controller only
    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "gha-runner-scale-set-controller"
          }
        }
      }
    }
  }
}

# =============================================================================
# RESOURCE QUOTAS
# =============================================================================

resource "kubernetes_resource_quota" "runners" {
  metadata {
    name      = "runner-quota"
    namespace = kubernetes_namespace.runners.metadata[0].name
  }
  
  spec {
    hard = {
      "requests.cpu"    = "50"
      "requests.memory" = "100Gi"
      "limits.cpu"      = "100"
      "limits.memory"   = "200Gi"
      "pods"            = "100"
    }
  }
}

# =============================================================================
# POD DISRUPTION BUDGET
# =============================================================================

resource "kubernetes_pod_disruption_budget_v1" "controller" {
  metadata {
    name      = "arc-controller-pdb"
    namespace = kubernetes_namespace.runners.metadata[0].name
  }
  
  spec {
    min_available = 1
    
    selector {
      match_labels = {
        "app.kubernetes.io/name" = "gha-runner-scale-set-controller"
      }
    }
  }
  
  depends_on = [helm_release.arc_controller]
}

# =============================================================================
# SERVICE MONITOR (Prometheus)
# =============================================================================

resource "kubernetes_manifest" "service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      name      = "arc-controller"
      namespace = kubernetes_namespace.runners.metadata[0].name
      labels    = local.common_labels
    }
    spec = {
      selector = {
        matchLabels = {
          "app.kubernetes.io/name" = "gha-runner-scale-set-controller"
        }
      }
      endpoints = [
        {
          port     = "metrics"
          interval = "30s"
          path     = "/metrics"
        }
      ]
    }
  }
  
  depends_on = [helm_release.arc_controller]
}

# =============================================================================
# OUTPUTS
# =============================================================================

output "namespace" {
  description = "Runners namespace"
  value       = kubernetes_namespace.runners.metadata[0].name
}

output "controller_service_account" {
  description = "Controller service account name"
  value       = "arc-controller"
}

output "runner_service_accounts" {
  description = "Runner service account names by group"
  value = {
    for name, sa in kubernetes_service_account.runner : name => sa.metadata[0].name
  }
}

output "runner_groups" {
  description = "Configured runner groups"
  value = {
    for name, group in var.runner_groups : name => {
      runner_group = group.runner_group
      min_runners  = group.min_runners
      max_runners  = group.max_runners
      labels       = group.labels
    }
  }
}

output "github_org" {
  description = "GitHub organization for runners"
  value       = var.github_org
}
