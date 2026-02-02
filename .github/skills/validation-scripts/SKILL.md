---
name: validation-scripts
description: 'Reusable validation patterns for infrastructure deployments. Use when asked to validate Azure resources, check K8s cluster health, verify Terraform state, detect drift, run compliance checks.'
license: Complete terms in LICENSE.txt
---

# Validation Scripts

Comprehensive validation patterns and reusable scripts for Three Horizons Accelerator deployments.

## USE FOR

- Validate Azure resource deployment status
- Check Kubernetes cluster health and connectivity
- Verify Terraform state consistency
- Detect infrastructure drift
- Run compliance and security checks
- Validate networking configuration
- Verify RBAC permissions
- Check GitOps sync status

## DO NOT USE FOR

- Creating new Azure resources (use azure-cli skill)
- Deploying Kubernetes workloads (use kubectl-cli skill)
- Writing Terraform code (use terraform-cli skill)
- Configuring ArgoCD applications (use argocd-cli skill)

## Overview

This skill provides validation patterns for:

- **Azure Infrastructure**: Resource groups, AKS, ACR, Key Vault, networking
- **Kubernetes Clusters**: Health, workloads, network policies, RBAC
- **Terraform**: State, configuration, drift detection
- **GitOps**: ArgoCD sync status, application health
- **Security**: Compliance, secrets management, identity

## Directory Structure

```
validation-scripts/
├── SKILL.md                    # This file
└── scripts/
    ├── validate-azure.sh       # Azure infrastructure validation
    ├── validate-kubernetes.sh  # Kubernetes cluster validation
    └── validate-terraform.sh   # Terraform state validation
```

## Azure Infrastructure Validation

### Resource Group Validation

```bash
#!/bin/bash
set -euo pipefail

validate_resource_group() {
  local rg_name=$1
  
  echo "Validating resource group: $rg_name"
  
  # Check existence
  if ! az group show --name "$rg_name" --output none 2>/dev/null; then
    echo "❌ Resource group '$rg_name' does not exist"
    return 1
  fi
  
  # Check provisioning state
  local state=$(az group show --name "$rg_name" --query "properties.provisioningState" -o tsv)
  if [[ "$state" != "Succeeded" ]]; then
    echo "❌ Resource group provisioning state: $state"
    return 1
  fi
  
  # Check tags
  local tags=$(az group show --name "$rg_name" --query "tags" -o json)
  if [[ "$tags" == "null" || "$tags" == "{}" ]]; then
    echo "⚠️  Resource group has no tags"
  fi
  
  echo "✅ Resource group '$rg_name' is valid"
  return 0
}
```

### AKS Cluster Validation

```bash
#!/bin/bash
set -euo pipefail

validate_aks_cluster() {
  local rg_name=$1
  local cluster_name=$2
  
  echo "Validating AKS cluster: $cluster_name"
  
  # Check existence
  if ! az aks show --resource-group "$rg_name" --name "$cluster_name" --output none 2>/dev/null; then
    echo "❌ AKS cluster '$cluster_name' does not exist"
    return 1
  fi
  
  # Get cluster info
  local cluster_info=$(az aks show --resource-group "$rg_name" --name "$cluster_name" -o json)
  
  # Check provisioning state
  local state=$(echo "$cluster_info" | jq -r '.provisioningState')
  if [[ "$state" != "Succeeded" ]]; then
    echo "❌ Cluster provisioning state: $state"
    return 1
  fi
  
  # Check power state
  local power_state=$(echo "$cluster_info" | jq -r '.powerState.code')
  if [[ "$power_state" != "Running" ]]; then
    echo "❌ Cluster power state: $power_state"
    return 1
  fi
  
  # Check OIDC issuer
  local oidc_issuer=$(echo "$cluster_info" | jq -r '.oidcIssuerProfile.issuerUrl // empty')
  if [[ -z "$oidc_issuer" ]]; then
    echo "⚠️  OIDC issuer not enabled (workload identity won't work)"
  else
    echo "✅ OIDC issuer enabled: $oidc_issuer"
  fi
  
  # Check workload identity
  local workload_identity=$(echo "$cluster_info" | jq -r '.securityProfile.workloadIdentity.enabled // false')
  if [[ "$workload_identity" != "true" ]]; then
    echo "⚠️  Workload identity not enabled"
  else
    echo "✅ Workload identity enabled"
  fi
  
  # Check Defender
  local defender=$(echo "$cluster_info" | jq -r '.securityProfile.defender.logAnalyticsWorkspaceResourceId // empty')
  if [[ -z "$defender" ]]; then
    echo "⚠️  Microsoft Defender not enabled"
  else
    echo "✅ Microsoft Defender enabled"
  fi
  
  # Check node pools
  local node_pools=$(echo "$cluster_info" | jq -r '.agentPoolProfiles | length')
  echo "ℹ️  Node pools: $node_pools"
  
  # Validate each node pool
  echo "$cluster_info" | jq -r '.agentPoolProfiles[] | "\(.name): \(.count) nodes (\(.provisioningState))"' | while read -r line; do
    echo "   - $line"
  done
  
  echo "✅ AKS cluster '$cluster_name' is valid"
  return 0
}
```

### ACR Validation

```bash
validate_acr() {
  local acr_name=$1
  
  echo "Validating ACR: $acr_name"
  
  # Check existence
  if ! az acr show --name "$acr_name" --output none 2>/dev/null; then
    echo "❌ ACR '$acr_name' does not exist"
    return 1
  fi
  
  # Get ACR info
  local acr_info=$(az acr show --name "$acr_name" -o json)
  
  # Check provisioning state
  local state=$(echo "$acr_info" | jq -r '.provisioningState')
  if [[ "$state" != "Succeeded" ]]; then
    echo "❌ ACR provisioning state: $state"
    return 1
  fi
  
  # Check SKU
  local sku=$(echo "$acr_info" | jq -r '.sku.name')
  echo "ℹ️  ACR SKU: $sku"
  
  # Check admin user
  local admin_enabled=$(echo "$acr_info" | jq -r '.adminUserEnabled')
  if [[ "$admin_enabled" == "true" ]]; then
    echo "⚠️  Admin user is enabled (not recommended for production)"
  else
    echo "✅ Admin user disabled"
  fi
  
  # Check public network access
  local public_access=$(echo "$acr_info" | jq -r '.publicNetworkAccess')
  if [[ "$public_access" == "Enabled" ]]; then
    echo "⚠️  Public network access enabled"
  else
    echo "✅ Public network access disabled"
  fi
  
  echo "✅ ACR '$acr_name' is valid"
  return 0
}
```

### Key Vault Validation

```bash
validate_keyvault() {
  local kv_name=$1
  
  echo "Validating Key Vault: $kv_name"
  
  # Check existence
  if ! az keyvault show --name "$kv_name" --output none 2>/dev/null; then
    echo "❌ Key Vault '$kv_name' does not exist"
    return 1
  fi
  
  # Get KV info
  local kv_info=$(az keyvault show --name "$kv_name" -o json)
  
  # Check RBAC authorization
  local rbac=$(echo "$kv_info" | jq -r '.properties.enableRbacAuthorization')
  if [[ "$rbac" != "true" ]]; then
    echo "⚠️  RBAC authorization not enabled (using access policies)"
  else
    echo "✅ RBAC authorization enabled"
  fi
  
  # Check purge protection
  local purge_protection=$(echo "$kv_info" | jq -r '.properties.enablePurgeProtection // false')
  if [[ "$purge_protection" != "true" ]]; then
    echo "⚠️  Purge protection not enabled"
  else
    echo "✅ Purge protection enabled"
  fi
  
  # Check soft delete
  local soft_delete=$(echo "$kv_info" | jq -r '.properties.enableSoftDelete')
  if [[ "$soft_delete" != "true" ]]; then
    echo "⚠️  Soft delete not enabled"
  else
    echo "✅ Soft delete enabled"
  fi
  
  # Check public network access
  local public_access=$(echo "$kv_info" | jq -r '.properties.publicNetworkAccess')
  if [[ "$public_access" == "Enabled" ]]; then
    echo "⚠️  Public network access enabled"
  fi
  
  echo "✅ Key Vault '$kv_name' is valid"
  return 0
}
```

### Network Validation

```bash
validate_networking() {
  local rg_name=$1
  local vnet_name=$2
  
  echo "Validating VNet: $vnet_name"
  
  # Check VNet existence
  if ! az network vnet show --resource-group "$rg_name" --name "$vnet_name" --output none 2>/dev/null; then
    echo "❌ VNet '$vnet_name' does not exist"
    return 1
  fi
  
  # Get VNet info
  local vnet_info=$(az network vnet show --resource-group "$rg_name" --name "$vnet_name" -o json)
  
  # Check provisioning state
  local state=$(echo "$vnet_info" | jq -r '.provisioningState')
  if [[ "$state" != "Succeeded" ]]; then
    echo "❌ VNet provisioning state: $state"
    return 1
  fi
  
  # List subnets
  echo "ℹ️  Subnets:"
  echo "$vnet_info" | jq -r '.subnets[] | "   - \(.name): \(.addressPrefix)"'
  
  # Check for private endpoints subnet
  local pe_subnet=$(echo "$vnet_info" | jq -r '.subnets[] | select(.name | contains("private-endpoint"))')
  if [[ -z "$pe_subnet" ]]; then
    echo "⚠️  No private endpoints subnet found"
  else
    echo "✅ Private endpoints subnet found"
  fi
  
  echo "✅ VNet '$vnet_name' is valid"
  return 0
}
```

## Kubernetes Cluster Validation

### Cluster Health

```bash
#!/bin/bash
set -euo pipefail

validate_cluster_health() {
  echo "Validating Kubernetes cluster health..."
  
  # Check API server
  if ! kubectl cluster-info &>/dev/null; then
    echo "❌ Cannot connect to Kubernetes API server"
    return 1
  fi
  echo "✅ API server is reachable"
  
  # Check nodes
  local not_ready=$(kubectl get nodes --no-headers | grep -v "Ready" | wc -l)
  if [[ "$not_ready" -gt 0 ]]; then
    echo "❌ $not_ready nodes are not ready"
    kubectl get nodes -o wide
    return 1
  fi
  echo "✅ All nodes are ready"
  
  # Check system pods
  local failed_pods=$(kubectl get pods -n kube-system --no-headers | grep -vE "Running|Completed" | wc -l)
  if [[ "$failed_pods" -gt 0 ]]; then
    echo "⚠️  $failed_pods system pods are not running"
    kubectl get pods -n kube-system | grep -vE "Running|Completed"
  else
    echo "✅ All system pods are running"
  fi
  
  # Check component status
  kubectl get componentstatuses 2>/dev/null || echo "ℹ️  Component status not available (normal in newer K8s)"
  
  return 0
}
```

### Workload Validation

```bash
validate_workloads() {
  local namespace=${1:-default}
  
  echo "Validating workloads in namespace: $namespace"
  
  # Check deployments
  local failed_deployments=$(kubectl get deployments -n "$namespace" --no-headers 2>/dev/null | awk '$2 != $4 {print $1}')
  if [[ -n "$failed_deployments" ]]; then
    echo "⚠️  Deployments not fully available:"
    echo "$failed_deployments" | while read -r dep; do
      echo "   - $dep"
    done
  else
    echo "✅ All deployments are available"
  fi
  
  # Check pods
  local failed_pods=$(kubectl get pods -n "$namespace" --no-headers 2>/dev/null | grep -vE "Running|Completed|Succeeded" | wc -l)
  if [[ "$failed_pods" -gt 0 ]]; then
    echo "⚠️  $failed_pods pods are not running"
    kubectl get pods -n "$namespace" | grep -vE "Running|Completed|Succeeded"
  else
    echo "✅ All pods are running"
  fi
  
  # Check for restart loops
  local restarts=$(kubectl get pods -n "$namespace" -o jsonpath='{range .items[*]}{.metadata.name}{" "}{.status.containerStatuses[*].restartCount}{"\n"}{end}' 2>/dev/null | awk '$2 > 5 {print $1": "$2" restarts"}')
  if [[ -n "$restarts" ]]; then
    echo "⚠️  Pods with high restart counts:"
    echo "$restarts"
  fi
  
  return 0
}
```

### Network Policy Validation

```bash
validate_network_policies() {
  local namespace=${1:-default}
  
  echo "Validating network policies in namespace: $namespace"
  
  # Check if network policies exist
  local np_count=$(kubectl get networkpolicies -n "$namespace" --no-headers 2>/dev/null | wc -l)
  if [[ "$np_count" -eq 0 ]]; then
    echo "⚠️  No network policies defined in namespace '$namespace'"
  else
    echo "✅ $np_count network policies defined"
    kubectl get networkpolicies -n "$namespace" -o wide
  fi
  
  return 0
}
```

### RBAC Validation

```bash
validate_rbac() {
  local namespace=${1:-default}
  local service_account=${2:-default}
  
  echo "Validating RBAC for service account: $service_account in namespace: $namespace"
  
  # Check if SA exists
  if ! kubectl get sa "$service_account" -n "$namespace" &>/dev/null; then
    echo "❌ Service account '$service_account' does not exist"
    return 1
  fi
  
  # List role bindings
  echo "ℹ️  Role bindings for SA:"
  kubectl get rolebindings -n "$namespace" -o json 2>/dev/null | \
    jq -r ".items[] | select(.subjects[]?.name == \"$service_account\") | \"   - \\(.metadata.name): \\(.roleRef.name)\""
  
  # List cluster role bindings
  echo "ℹ️  Cluster role bindings for SA:"
  kubectl get clusterrolebindings -o json 2>/dev/null | \
    jq -r ".items[] | select(.subjects[]?.name == \"$service_account\" and .subjects[]?.namespace == \"$namespace\") | \"   - \\(.metadata.name): \\(.roleRef.name)\""
  
  return 0
}
```

### Resource Quotas Validation

```bash
validate_resource_quotas() {
  local namespace=${1:-default}
  
  echo "Validating resource quotas in namespace: $namespace"
  
  # Check quotas
  local quotas=$(kubectl get resourcequotas -n "$namespace" --no-headers 2>/dev/null | wc -l)
  if [[ "$quotas" -eq 0 ]]; then
    echo "⚠️  No resource quotas defined"
  else
    echo "✅ Resource quotas defined:"
    kubectl get resourcequotas -n "$namespace" -o wide
  fi
  
  # Check limit ranges
  local limits=$(kubectl get limitranges -n "$namespace" --no-headers 2>/dev/null | wc -l)
  if [[ "$limits" -eq 0 ]]; then
    echo "⚠️  No limit ranges defined"
  else
    echo "✅ Limit ranges defined:"
    kubectl get limitranges -n "$namespace" -o wide
  fi
  
  return 0
}
```

## Terraform Validation

### State Validation

```bash
#!/bin/bash
set -euo pipefail

validate_terraform_state() {
  echo "Validating Terraform state..."
  
  # Check if initialized
  if [[ ! -d ".terraform" ]]; then
    echo "❌ Terraform not initialized. Run: terraform init"
    return 1
  fi
  echo "✅ Terraform initialized"
  
  # Validate configuration
  if ! terraform validate -json > /tmp/validate.json 2>&1; then
    echo "❌ Terraform configuration invalid:"
    cat /tmp/validate.json | jq -r '.diagnostics[] | "   - \(.summary)"'
    return 1
  fi
  echo "✅ Terraform configuration valid"
  
  # Check format
  if ! terraform fmt -check -recursive > /dev/null 2>&1; then
    echo "⚠️  Terraform files not formatted. Run: terraform fmt -recursive"
  else
    echo "✅ Terraform files formatted"
  fi
  
  # Check state
  if ! terraform state list > /dev/null 2>&1; then
    echo "⚠️  Cannot access Terraform state"
  else
    local resource_count=$(terraform state list | wc -l)
    echo "✅ Terraform state accessible ($resource_count resources)"
  fi
  
  return 0
}
```

### Drift Detection

```bash
detect_terraform_drift() {
  echo "Detecting Terraform drift..."
  
  # Run plan to detect drift
  if terraform plan -detailed-exitcode -out=/tmp/drift.tfplan > /tmp/drift.log 2>&1; then
    echo "✅ No drift detected - infrastructure matches state"
    return 0
  else
    local exit_code=$?
    if [[ "$exit_code" -eq 2 ]]; then
      echo "⚠️  Drift detected - changes required:"
      terraform show -no-color /tmp/drift.tfplan | grep -E "^(  #|Plan:)"
      return 1
    else
      echo "❌ Error running Terraform plan"
      cat /tmp/drift.log
      return 2
    fi
  fi
}
```

### Provider Validation

```bash
validate_terraform_providers() {
  echo "Validating Terraform providers..."
  
  # List providers
  terraform providers -json > /tmp/providers.json 2>/dev/null
  
  # Check if locked
  if [[ ! -f ".terraform.lock.hcl" ]]; then
    echo "⚠️  Provider lock file missing. Run: terraform init"
  else
    echo "✅ Provider lock file exists"
  fi
  
  # List installed providers
  echo "ℹ️  Installed providers:"
  terraform version -json | jq -r '.provider_selections // {} | to_entries[] | "   - \(.key): \(.value)"'
  
  return 0
}
```

## GitOps Validation

### ArgoCD Sync Status

```bash
validate_argocd_applications() {
  echo "Validating ArgoCD applications..."
  
  # Check ArgoCD CLI
  if ! command -v argocd &>/dev/null; then
    echo "⚠️  ArgoCD CLI not installed"
    return 0
  fi
  
  # List applications
  local apps=$(argocd app list -o json 2>/dev/null)
  if [[ -z "$apps" || "$apps" == "[]" ]]; then
    echo "ℹ️  No ArgoCD applications found"
    return 0
  fi
  
  # Check each application
  echo "$apps" | jq -r '.[] | "\(.metadata.name)|\(.status.sync.status)|\(.status.health.status)"' | while IFS='|' read -r name sync health; do
    local status_icon="✅"
    if [[ "$sync" != "Synced" || "$health" != "Healthy" ]]; then
      status_icon="❌"
    fi
    echo "   $status_icon $name: sync=$sync, health=$health"
  done
  
  # Count issues
  local not_synced=$(echo "$apps" | jq -r '[.[] | select(.status.sync.status != "Synced")] | length')
  local not_healthy=$(echo "$apps" | jq -r '[.[] | select(.status.health.status != "Healthy")] | length')
  
  if [[ "$not_synced" -gt 0 ]]; then
    echo "⚠️  $not_synced applications not synced"
  fi
  if [[ "$not_healthy" -gt 0 ]]; then
    echo "⚠️  $not_healthy applications not healthy"
  fi
  
  return 0
}
```

### Repository Validation

```bash
validate_argocd_repos() {
  echo "Validating ArgoCD repositories..."
  
  # List repositories
  local repos=$(argocd repo list -o json 2>/dev/null)
  if [[ -z "$repos" || "$repos" == "[]" ]]; then
    echo "ℹ️  No ArgoCD repositories configured"
    return 0
  fi
  
  # Check each repository
  echo "$repos" | jq -r '.[] | "\(.repo)|\(.connectionState.status)"' | while IFS='|' read -r repo status; do
    if [[ "$status" == "Successful" ]]; then
      echo "   ✅ $repo"
    else
      echo "   ❌ $repo (status: $status)"
    fi
  done
  
  return 0
}
```

## Full Validation Suite

### Run All Validations

```bash
#!/bin/bash
set -euo pipefail

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-}"
CLUSTER_NAME="${CLUSTER_NAME:-}"
ACR_NAME="${ACR_NAME:-}"
KEYVAULT_NAME="${KEYVAULT_NAME:-}"
VNET_NAME="${VNET_NAME:-}"

run_full_validation() {
  local errors=0
  
  echo "═══════════════════════════════════════════════════════════"
  echo "       Three Horizons Accelerator - Validation Suite       "
  echo "═══════════════════════════════════════════════════════════"
  echo ""
  
  # Azure validations
  if [[ -n "$RESOURCE_GROUP" ]]; then
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                 Azure Infrastructure                       ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    
    validate_resource_group "$RESOURCE_GROUP" || ((errors++))
    
    if [[ -n "$CLUSTER_NAME" ]]; then
      validate_aks_cluster "$RESOURCE_GROUP" "$CLUSTER_NAME" || ((errors++))
    fi
    
    if [[ -n "$ACR_NAME" ]]; then
      validate_acr "$ACR_NAME" || ((errors++))
    fi
    
    if [[ -n "$KEYVAULT_NAME" ]]; then
      validate_keyvault "$KEYVAULT_NAME" || ((errors++))
    fi
    
    if [[ -n "$VNET_NAME" ]]; then
      validate_networking "$RESOURCE_GROUP" "$VNET_NAME" || ((errors++))
    fi
  fi
  
  # Kubernetes validations
  if kubectl cluster-info &>/dev/null; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                 Kubernetes Cluster                         ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    
    validate_cluster_health || ((errors++))
    validate_workloads "argocd" || true
    validate_workloads "observability" || true
  fi
  
  # Terraform validations
  if [[ -f "main.tf" ]]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                 Terraform State                            ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    
    validate_terraform_state || ((errors++))
  fi
  
  # GitOps validations
  if command -v argocd &>/dev/null; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                 GitOps (ArgoCD)                            ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    
    validate_argocd_applications || ((errors++))
    validate_argocd_repos || ((errors++))
  fi
  
  # Summary
  echo ""
  echo "═══════════════════════════════════════════════════════════"
  if [[ "$errors" -eq 0 ]]; then
    echo "✅ All validations passed!"
  else
    echo "❌ $errors validation(s) failed"
  fi
  echo "═══════════════════════════════════════════════════════════"
  
  return $errors
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  run_full_validation
fi
```

## Usage

### Validate Single Component

```bash
# Azure
./scripts/validate-azure.sh --resource-group rg-myproject-prod

# Kubernetes
./scripts/validate-kubernetes.sh --namespace argocd

# Terraform
./scripts/validate-terraform.sh --check-drift
```

### Run Full Suite

```bash
export RESOURCE_GROUP="rg-threehorizons-prod"
export CLUSTER_NAME="aks-threehorizons-prod"
export ACR_NAME="crthreehorizonsprod"
export KEYVAULT_NAME="kv-threehorizons-prod"
export VNET_NAME="vnet-threehorizons-prod"

./scripts/validation-scripts/validate-all.sh
```

## Best Practices

1. **Run validations in CI/CD**: Include validation as post-deployment step
2. **Set thresholds**: Define acceptable warning counts
3. **Alert on failures**: Integrate with monitoring/alerting
4. **Version validation scripts**: Keep scripts in version control
5. **Document requirements**: Document what each validation checks
6. **Idempotent checks**: Validations should be safe to run repeatedly
7. **Clear output**: Use consistent icons and messages
8. **Return codes**: Use proper exit codes for automation

## References

- [Azure Validation Best Practices](https://learn.microsoft.com/en-us/azure/architecture/best-practices/)
- [Kubernetes Health Checks](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [HashiCorp Terraform Testing](https://developer.hashicorp.com/terraform/language/tests)
