variable "environment" {
  type        = string
  description = "Environment name"
  default     = "${{ values.environment }}"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  type        = string
  description = "Azure location"
  default     = "${{ values.azureRegion }}"
}

variable "app_name" {
  type        = string
  description = "Application name"
  default     = "${{ values.appName }}"
}

variable "cost_center" {
  type        = string
  description = "Cost center tag"
  default     = "${{ values.costCenter }}"
}
