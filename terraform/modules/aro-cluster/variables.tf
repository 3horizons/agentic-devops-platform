# =============================================================================
# ARO CLUSTER MODULE — VARIABLES
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
  description = "Azure region — Central US or East US only"
  type        = string

  validation {
    condition     = contains(["centralus", "eastus"], var.location)
    error_message = "Only Central US (centralus) and East US (eastus) are supported for ARO deployments."
  }
}

variable "openshift_version" {
  description = "OpenShift version for ARO"
  type        = string
  default     = "4.14"
}

variable "pull_secret" {
  description = "Red Hat pull secret for registry.redhat.io (JSON string)"
  type        = string
  sensitive   = true
}

variable "vnet_cidr" {
  description = "CIDR for ARO virtual network"
  type        = string
  default     = "10.0.0.0/22"
}

variable "master_subnet_cidr" {
  description = "CIDR for master subnet"
  type        = string
  default     = "10.0.0.0/23"
}

variable "worker_subnet_cidr" {
  description = "CIDR for worker subnet"
  type        = string
  default     = "10.0.2.0/23"
}

variable "pod_cidr" {
  description = "CIDR for pod network"
  type        = string
  default     = "10.128.0.0/14"
}

variable "service_cidr" {
  description = "CIDR for service network"
  type        = string
  default     = "172.30.0.0/16"
}

variable "master_vm_size" {
  description = "VM size for master nodes"
  type        = string
  default     = "Standard_D8s_v3"
}

variable "worker_vm_size" {
  description = "VM size for worker nodes"
  type        = string
  default     = "Standard_D4s_v3"
}

variable "worker_node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "worker_disk_size_gb" {
  description = "Worker node OS disk size in GB"
  type        = number
  default     = 128
}

variable "api_server_visibility" {
  description = "API server visibility (Public or Private)"
  type        = string
  default     = "Public"

  validation {
    condition     = contains(["Public", "Private"], var.api_server_visibility)
    error_message = "Must be Public or Private."
  }
}

variable "ingress_visibility" {
  description = "Ingress visibility (Public or Private)"
  type        = string
  default     = "Public"

  validation {
    condition     = contains(["Public", "Private"], var.ingress_visibility)
    error_message = "Must be Public or Private."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
