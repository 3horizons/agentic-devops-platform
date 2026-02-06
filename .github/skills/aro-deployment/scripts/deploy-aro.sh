#!/bin/bash
# =============================================================================
# THREE HORIZONS PLATFORM - ARO DEPLOYMENT
# =============================================================================
#
# Deploys Azure Red Hat OpenShift (ARO) cluster with platform components
#
# Usage: ./scripts/deploy-aro.sh [options]
#
# Prerequisites:
#   - Azure CLI authenticated with ARO permissions
#   - Red Hat pull secret from cloud.redhat.com
#   - Sufficient Azure quota for ARO
#
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Defaults
DRY_RUN=false
WORKER_COUNT=3
WORKER_VM_SIZE="Standard_D4s_v3"
MASTER_VM_SIZE="Standard_D8s_v3"
VNET_CIDR="10.0.0.0/16"
MASTER_SUBNET_CIDR="10.0.0.0/23"
WORKER_SUBNET_CIDR="10.0.2.0/23"

# Logging
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()    { echo -e "${PURPLE}[STEP]${NC} $1"; }

# Usage
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS]

Deploy Azure Red Hat OpenShift (ARO) cluster.

OPTIONS:
    --cluster-name      ARO cluster name (required)
    --resource-group    Azure resource group (required)
    --location          Azure region (default: eastus)
    --pull-secret       Path to Red Hat pull secret file (required)
    --vnet-name         Virtual network name (default: {cluster}-vnet)
    --domain            Cluster domain (default: {cluster})
    --worker-count      Number of worker nodes (default: 3)
    --worker-size       Worker VM size (default: Standard_D4s_v3)
    --master-size       Master VM size (default: Standard_D8s_v3)
    --sizing-profile    Sizing profile: small, medium, large, xlarge
    --enable-gitops     Install OpenShift GitOps operator
    --enable-rhdh       Install Red Hat Developer Hub
    --dry-run           Show what would be done
    --help              Show this help message

EXAMPLES:
    # Basic deployment
    $(basename "$0") --cluster-name aro-prod --resource-group rg-aro \\
        --location brazilsouth --pull-secret ./pull-secret.txt

    # Full platform deployment
    $(basename "$0") --cluster-name aro-prod --resource-group rg-aro \\
        --location brazilsouth --pull-secret ./pull-secret.txt \\
        --sizing-profile large --enable-gitops --enable-rhdh

EOF
    exit 0
}

# Parse arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --cluster-name)
                CLUSTER_NAME="$2"
                shift 2
                ;;
            --resource-group)
                RESOURCE_GROUP="$2"
                shift 2
                ;;
            --location)
                LOCATION="$2"
                shift 2
                ;;
            --pull-secret)
                PULL_SECRET_FILE="$2"
                shift 2
                ;;
            --vnet-name)
                VNET_NAME="$2"
                shift 2
                ;;
            --domain)
                DOMAIN="$2"
                shift 2
                ;;
            --worker-count)
                WORKER_COUNT="$2"
                shift 2
                ;;
            --worker-size)
                WORKER_VM_SIZE="$2"
                shift 2
                ;;
            --master-size)
                MASTER_VM_SIZE="$2"
                shift 2
                ;;
            --sizing-profile)
                SIZING_PROFILE="$2"
                shift 2
                ;;
            --enable-gitops)
                ENABLE_GITOPS=true
                shift
                ;;
            --enable-rhdh)
                ENABLE_RHDH=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                usage
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                ;;
        esac
    done
    
    # Validate required args
    [[ -z "${CLUSTER_NAME:-}" ]] && { log_error "Missing: --cluster-name"; exit 1; }
    [[ -z "${RESOURCE_GROUP:-}" ]] && { log_error "Missing: --resource-group"; exit 1; }
    [[ -z "${PULL_SECRET_FILE:-}" ]] && { log_error "Missing: --pull-secret"; exit 1; }
    
    # Set defaults
    LOCATION="${LOCATION:-eastus}"
    VNET_NAME="${VNET_NAME:-${CLUSTER_NAME}-vnet}"
    DOMAIN="${DOMAIN:-${CLUSTER_NAME}}"
    ENABLE_GITOPS="${ENABLE_GITOPS:-false}"
    ENABLE_RHDH="${ENABLE_RHDH:-false}"
    
    # Apply sizing profile
    if [[ -n "${SIZING_PROFILE:-}" ]]; then
        apply_sizing_profile
    fi
}

# Apply sizing profile
apply_sizing_profile() {
    case $SIZING_PROFILE in
        small)
            WORKER_COUNT=3
            WORKER_VM_SIZE="Standard_D4s_v3"
            MASTER_VM_SIZE="Standard_D8s_v3"
            ;;
        medium)
            WORKER_COUNT=5
            WORKER_VM_SIZE="Standard_D8s_v3"
            MASTER_VM_SIZE="Standard_D8s_v3"
            ;;
        large)
            WORKER_COUNT=10
            WORKER_VM_SIZE="Standard_D16s_v3"
            MASTER_VM_SIZE="Standard_D16s_v3"
            ;;
        xlarge)
            WORKER_COUNT=20
            WORKER_VM_SIZE="Standard_D32s_v3"
            MASTER_VM_SIZE="Standard_D16s_v3"
            ;;
        *)
            log_error "Unknown sizing profile: $SIZING_PROFILE"
            exit 1
            ;;
    esac
    log_info "Applied sizing profile: $SIZING_PROFILE (${WORKER_COUNT} workers, ${WORKER_VM_SIZE})"
}

# Check prerequisites
check_prerequisites() {
    log_step "Checking prerequisites..."
    
    local missing=()
    command -v az &>/dev/null || missing+=("az (Azure CLI)")
    command -v oc &>/dev/null || missing+=("oc (OpenShift CLI)")
    command -v jq &>/dev/null || missing+=("jq")
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing prerequisites: ${missing[*]}"
        echo ""
        echo "Install OpenShift CLI:"
        echo "  brew install openshift-cli"
        echo "  # or download from https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/"
        exit 1
    fi
    
    # Check Azure login
    if ! az account show &>/dev/null; then
        log_error "Not logged in to Azure. Run: az login"
        exit 1
    fi
    
    # Check pull secret file
    if [[ ! -f "$PULL_SECRET_FILE" ]]; then
        log_error "Pull secret file not found: $PULL_SECRET_FILE"
        echo "Download from: https://cloud.redhat.com/openshift/install/pull-secret"
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

# Register providers
register_providers() {
    log_step "Registering Azure resource providers..."
    
    local providers=(
        "Microsoft.RedHatOpenShift"
        "Microsoft.Compute"
        "Microsoft.Storage"
        "Microsoft.Authorization"
        "Microsoft.Network"
    )
    
    for provider in "${providers[@]}"; do
        log_info "Registering: $provider"
        if [[ "$DRY_RUN" != "true" ]]; then
            az provider register -n "$provider" --wait 2>/dev/null || true
        fi
    done
    
    log_success "Providers registered"
}

# Create resource group
create_resource_group() {
    log_step "Creating resource group: $RESOURCE_GROUP"
    
    if az group show --name "$RESOURCE_GROUP" &>/dev/null; then
        log_warning "Resource group already exists"
    else
        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY-RUN] Would create resource group"
        else
            az group create --name "$RESOURCE_GROUP" --location "$LOCATION" >/dev/null
            log_success "Resource group created"
        fi
    fi
}

# Create virtual network
create_vnet() {
    log_step "Creating virtual network: $VNET_NAME"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would create VNet with subnets"
        return
    fi
    
    # Create VNet
    az network vnet create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$VNET_NAME" \
        --address-prefixes "$VNET_CIDR" >/dev/null
    
    # Create master subnet
    az network vnet subnet create \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --name master-subnet \
        --address-prefixes "$MASTER_SUBNET_CIDR" \
        --service-endpoints Microsoft.ContainerRegistry >/dev/null
    
    # Create worker subnet
    az network vnet subnet create \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --name worker-subnet \
        --address-prefixes "$WORKER_SUBNET_CIDR" \
        --service-endpoints Microsoft.ContainerRegistry >/dev/null
    
    # Disable private link policies on master subnet
    az network vnet subnet update \
        --resource-group "$RESOURCE_GROUP" \
        --vnet-name "$VNET_NAME" \
        --name master-subnet \
        --disable-private-link-service-network-policies true >/dev/null
    
    log_success "VNet and subnets created"
}

# Create service principal
create_service_principal() {
    log_step "Creating service principal for ARO..."
    
    SP_NAME="${CLUSTER_NAME}-sp"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would create service principal: $SP_NAME"
        SP_CLIENT_ID="dry-run-client-id"
        SP_CLIENT_SECRET="dry-run-secret"
        return
    fi
    
    # Check if SP exists
    EXISTING_SP=$(az ad sp list --display-name "$SP_NAME" --query "[0].appId" -o tsv 2>/dev/null || echo "")
    
    if [[ -n "$EXISTING_SP" ]]; then
        log_warning "Service principal already exists: $EXISTING_SP"
        SP_CLIENT_ID="$EXISTING_SP"
        echo ""
        log_warning "You need to provide the existing SP secret or create a new one"
        read -sp "Enter SP client secret (or press Enter to create new): " SP_CLIENT_SECRET
        echo ""
        
        if [[ -z "$SP_CLIENT_SECRET" ]]; then
            SP_CLIENT_SECRET=$(az ad sp credential reset --id "$SP_CLIENT_ID" --query password -o tsv)
        fi
    else
        SUBSCRIPTION_ID=$(az account show --query id -o tsv)
        SP_INFO=$(az ad sp create-for-rbac \
            --name "$SP_NAME" \
            --role Contributor \
            --scopes "/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}")
        
        SP_CLIENT_ID=$(echo "$SP_INFO" | jq -r '.appId')
        SP_CLIENT_SECRET=$(echo "$SP_INFO" | jq -r '.password')
        
        log_success "Service principal created: $SP_CLIENT_ID"
    fi
}

# Create ARO cluster
create_aro_cluster() {
    log_step "Creating ARO cluster: $CLUSTER_NAME"
    log_warning "This process takes 30-45 minutes..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would create ARO cluster with:"
        echo "  Workers: $WORKER_COUNT x $WORKER_VM_SIZE"
        echo "  Masters: 3 x $MASTER_VM_SIZE"
        return
    fi
    
    # Check if cluster exists
    if az aro show --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" &>/dev/null; then
        log_warning "ARO cluster already exists"
        return
    fi
    
    az aro create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CLUSTER_NAME" \
        --vnet "$VNET_NAME" \
        --master-subnet master-subnet \
        --worker-subnet worker-subnet \
        --worker-count "$WORKER_COUNT" \
        --worker-vm-size "$WORKER_VM_SIZE" \
        --master-vm-size "$MASTER_VM_SIZE" \
        --client-id "$SP_CLIENT_ID" \
        --client-secret "$SP_CLIENT_SECRET" \
        --pull-secret @"$PULL_SECRET_FILE" \
        --domain "$DOMAIN"
    
    log_success "ARO cluster created!"
}

# Get cluster credentials
get_credentials() {
    log_step "Getting cluster credentials..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would retrieve credentials"
        return
    fi
    
    # Get API server URL
    API_SERVER=$(az aro show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CLUSTER_NAME" \
        --query apiserverProfile.url -o tsv)
    
    # Get kubeadmin password
    KUBEADMIN_PASSWORD=$(az aro list-credentials \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CLUSTER_NAME" \
        --query kubeadminPassword -o tsv)
    
    # Get console URL
    CONSOLE_URL=$(az aro show \
        --resource-group "$RESOURCE_GROUP" \
        --name "$CLUSTER_NAME" \
        --query consoleProfile.url -o tsv)
    
    log_success "Credentials retrieved"
    
    # Login with oc
    log_info "Logging in to cluster..."
    oc login "$API_SERVER" \
        --username kubeadmin \
        --password "$KUBEADMIN_PASSWORD" \
        --insecure-skip-tls-verify=true
    
    log_success "Logged in to cluster"
}

# Install OpenShift GitOps
install_gitops() {
    if [[ "$ENABLE_GITOPS" != "true" ]]; then
        return
    fi
    
    log_step "Installing OpenShift GitOps operator..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would install GitOps operator"
        return
    fi
    
    cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-operators
spec:
  channel: latest
  installPlanApproval: Automatic
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
    
    log_info "Waiting for GitOps operator..."
    sleep 30
    
    oc wait --for=condition=Ready pod \
        -l app.kubernetes.io/name=openshift-gitops-operator \
        -n openshift-operators \
        --timeout=300s || log_warning "GitOps operator may still be installing"
    
    # Get ArgoCD route
    ARGOCD_ROUTE=$(oc get route openshift-gitops-server \
        -n openshift-gitops \
        -o jsonpath='{.spec.host}' 2>/dev/null || echo "pending")
    
    log_success "GitOps operator installed"
    log_info "ArgoCD URL: https://${ARGOCD_ROUTE}"
}

# Install RHDH
install_rhdh() {
    if [[ "$ENABLE_RHDH" != "true" ]]; then
        return
    fi
    
    log_step "Installing Red Hat Developer Hub..."
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would install RHDH operator"
        return
    fi
    
    # Create namespace
    oc new-project rhdh 2>/dev/null || true
    
    # Install RHDH operator
    cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh
  namespace: openshift-operators
spec:
  channel: fast
  installPlanApproval: Automatic
  name: rhdh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
    
    log_info "Waiting for RHDH operator..."
    sleep 60
    
    log_success "RHDH operator installed"
    log_info "Create Backstage CR in 'rhdh' namespace to deploy Developer Hub"
}

# Print summary
print_summary() {
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ARO DEPLOYMENT COMPLETE${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    echo "Cluster Details:"
    echo "  Name:          $CLUSTER_NAME"
    echo "  Resource Group: $RESOURCE_GROUP"
    echo "  Location:      $LOCATION"
    echo "  Workers:       $WORKER_COUNT x $WORKER_VM_SIZE"
    echo ""
    
    if [[ "$DRY_RUN" != "true" ]]; then
        echo "Access:"
        echo "  Console:       $CONSOLE_URL"
        echo "  API Server:    $API_SERVER"
        echo "  Username:      kubeadmin"
        echo "  Password:      $KUBEADMIN_PASSWORD"
        echo ""
        
        if [[ "$ENABLE_GITOPS" == "true" ]]; then
            echo "GitOps:"
            echo "  ArgoCD URL:    https://${ARGOCD_ROUTE}"
        fi
    fi
    
    echo ""
    echo "Next steps:"
    echo "  1. oc login $API_SERVER -u kubeadmin -p <password>"
    echo "  2. Configure OAuth: oc edit oauth cluster"
    echo "  3. Install operators: GitOps, RHDH, Pipelines"
    echo "  4. Run: ./scripts/setup-github-app.sh --target rhdh"
}

# Main
main() {
    echo ""
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║  THREE HORIZONS - ARO DEPLOYMENT                           ║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    parse_args "$@"
    
    [[ "$DRY_RUN" == "true" ]] && log_warning "DRY-RUN MODE"
    
    check_prerequisites
    register_providers
    create_resource_group
    create_vnet
    create_service_principal
    create_aro_cluster
    get_credentials
    install_gitops
    install_rhdh
    print_summary
    
    log_success "ARO deployment complete!"
}

main "$@"
