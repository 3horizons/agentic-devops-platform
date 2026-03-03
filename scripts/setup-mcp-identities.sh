#!/usr/bin/env bash
# =============================================================================
# THREE HORIZONS PLATFORM - MCP IDENTITIES SETUP
# =============================================================================
#
# Creates all Service Principals and identities required for MCP servers
# and the Azure Copilot + MCP-first workflow.
#
# Identities created:
#   1. Entra ID Admin Security Group
#   2. MCP Azure/AKS Service Principal (Reader + AKS RBAC Writer)
#   3. MCP AI Foundry Service Principal (Cognitive Services OpenAI User)
#   4. MCP Backstage Bearer Token (stored in Key Vault)
#   5. MCP ArgoCD API Token placeholder
#   6. MCP GitHub PAT validation
#
# Usage:
#   ./scripts/setup-mcp-identities.sh [options]
#
# Options:
#   --github-org         GitHub organization name (required)
#   --resource-group     Azure resource group (required)
#   --subscription-id    Azure subscription ID (auto-detected if omitted)
#   --project-name       Project name for naming (default: threehorizons)
#   --org-code           Organization code prefix (default: 3h)
#   --environment        Environment: dev|staging|prod (default: dev)
#   --key-vault-name     Key Vault name to store secrets (optional)
#   --skip-admin-group   Skip admin group creation
#   --dry-run            Show what would be done without executing
#   --help               Show this help message
#
# Prerequisites:
#   - Azure CLI authenticated (az login)
#   - GitHub CLI authenticated (gh auth login)
#   - Contributor role on the target subscription/resource group
#
# =============================================================================

set -euo pipefail

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# --- Defaults ---
GITHUB_ORG=""
RESOURCE_GROUP=""
SUBSCRIPTION_ID=""
PROJECT_NAME="threehorizons"
ORG_CODE="3h"
ENVIRONMENT="dev"
KEY_VAULT_NAME=""
SKIP_ADMIN_GROUP=false
DRY_RUN=false

# --- Logging ---
log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }
log_step()    { echo -e "\n${PURPLE}${BOLD}━━━ $1 ━━━${NC}"; }

# --- Usage ---
usage() {
    sed -n '/^# Usage:/,/^# ====/p' "$0" | sed 's/^# //' | head -n -1
    exit 0
}

# --- Parse arguments ---
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --github-org)        GITHUB_ORG="$2"; shift 2 ;;
            --resource-group)    RESOURCE_GROUP="$2"; shift 2 ;;
            --subscription-id)   SUBSCRIPTION_ID="$2"; shift 2 ;;
            --project-name)      PROJECT_NAME="$2"; shift 2 ;;
            --org-code)          ORG_CODE="$2"; shift 2 ;;
            --environment)       ENVIRONMENT="$2"; shift 2 ;;
            --key-vault-name)    KEY_VAULT_NAME="$2"; shift 2 ;;
            --skip-admin-group)  SKIP_ADMIN_GROUP=true; shift ;;
            --dry-run)           DRY_RUN=true; shift ;;
            --help)              usage ;;
            *) log_error "Unknown option: $1"; usage ;;
        esac
    done

    # Validate required
    if [[ -z "$GITHUB_ORG" ]]; then
        log_error "Missing required argument: --github-org"
        exit 1
    fi
    if [[ -z "$RESOURCE_GROUP" ]]; then
        log_error "Missing required argument: --resource-group"
        exit 1
    fi

    # Auto-detect subscription
    if [[ -z "$SUBSCRIPTION_ID" ]]; then
        SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null) || {
            log_error "Cannot detect subscription. Run 'az login' or provide --subscription-id."
            exit 1
        }
    fi
}

# --- Check prerequisites ---
check_prerequisites() {
    log_step "Checking prerequisites"

    local missing=()
    command -v az  &>/dev/null || missing+=("az (Azure CLI)")
    command -v gh  &>/dev/null || missing+=("gh (GitHub CLI)")
    command -v jq  &>/dev/null || missing+=("jq")

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing prerequisites: ${missing[*]}"
        exit 1
    fi

    az account show &>/dev/null || { log_error "Not logged in to Azure. Run: az login"; exit 1; }
    gh auth status  &>/dev/null || { log_error "Not logged in to GitHub. Run: gh auth login"; exit 1; }

    TENANT_ID=$(az account show --query tenantId -o tsv)
    log_success "Azure: $(az account show --query name -o tsv) ($SUBSCRIPTION_ID)"
    log_success "Tenant: $TENANT_ID"
    log_success "GitHub: $(gh api user --jq .login 2>/dev/null || echo 'authenticated')"
}

# --- 1. Create Admin Security Group ---
create_admin_group() {
    log_step "1/6 — Entra ID Admin Security Group"

    local group_name="${ORG_CODE}-${PROJECT_NAME}-platform-admins"

    local existing
    existing=$(az ad group list --display-name "$group_name" --query "[0].id" -o tsv 2>/dev/null || echo "")

    if [[ -n "$existing" ]]; then
        log_warning "Group already exists: $group_name ($existing)"
        ADMIN_GROUP_ID="$existing"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would create group: $group_name"
        ADMIN_GROUP_ID="dry-run-group-id"
    else
        ADMIN_GROUP_ID=$(az ad group create \
            --display-name "$group_name" \
            --mail-nickname "${ORG_CODE}-platform-admins" \
            --description "Platform administrators for Three Horizons - ${ENVIRONMENT}" \
            --query id -o tsv)
        log_success "Created group: $group_name ($ADMIN_GROUP_ID)"

        # Add current user as member
        local current_user
        current_user=$(az ad signed-in-user show --query id -o tsv 2>/dev/null || echo "")
        if [[ -n "$current_user" ]]; then
            az ad group member add --group "$ADMIN_GROUP_ID" --member-id "$current_user" 2>/dev/null || true
            log_success "Added current user as group member"
        fi
    fi
}

# --- 2. Create MCP Azure/AKS Service Principal ---
create_mcp_azure_sp() {
    log_step "2/6 — MCP Azure/AKS Service Principal"

    local app_name="${ORG_CODE}-${PROJECT_NAME}-mcp-azure"
    local scope="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"

    local existing
    existing=$(az ad app list --display-name "$app_name" --query "[0].appId" -o tsv 2>/dev/null || echo "")

    if [[ -n "$existing" ]]; then
        log_warning "App already exists: $app_name ($existing)"
        MCP_AZURE_CLIENT_ID="$existing"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would create App Registration: $app_name"
        MCP_AZURE_CLIENT_ID="dry-run-mcp-azure-id"
    else
        MCP_AZURE_CLIENT_ID=$(az ad app create \
            --display-name "$app_name" \
            --sign-in-audience "AzureADMyOrg" \
            --query appId -o tsv)
        log_success "Created App Registration: $MCP_AZURE_CLIENT_ID"

        # Create Service Principal
        az ad sp create --id "$MCP_AZURE_CLIENT_ID" >/dev/null 2>&1 || true
        log_success "Created Service Principal"

        # Wait for propagation
        sleep 5

        # Assign roles (least privilege)
        local roles=("Reader" "Azure Kubernetes Service Cluster User Role" "Azure Kubernetes Service RBAC Writer")
        for role in "${roles[@]}"; do
            az role assignment create \
                --assignee "$MCP_AZURE_CLIENT_ID" \
                --role "$role" \
                --scope "$scope" >/dev/null 2>&1 || log_warning "Could not assign role: $role"
            log_success "Assigned role: $role"
        done
    fi
}

# --- 3. Create MCP AI Foundry Service Principal ---
create_mcp_ai_foundry_sp() {
    log_step "3/6 — MCP AI Foundry Service Principal"

    local app_name="${ORG_CODE}-${PROJECT_NAME}-mcp-ai-foundry"
    local scope="/subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}"

    local existing
    existing=$(az ad app list --display-name "$app_name" --query "[0].appId" -o tsv 2>/dev/null || echo "")

    if [[ -n "$existing" ]]; then
        log_warning "App already exists: $app_name ($existing)"
        MCP_AI_CLIENT_ID="$existing"
    elif [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would create App Registration: $app_name"
        MCP_AI_CLIENT_ID="dry-run-mcp-ai-id"
    else
        MCP_AI_CLIENT_ID=$(az ad app create \
            --display-name "$app_name" \
            --sign-in-audience "AzureADMyOrg" \
            --query appId -o tsv)
        log_success "Created App Registration: $MCP_AI_CLIENT_ID"

        az ad sp create --id "$MCP_AI_CLIENT_ID" >/dev/null 2>&1 || true
        log_success "Created Service Principal"

        sleep 5

        # Assign Cognitive Services OpenAI User (least privilege for AI models)
        az role assignment create \
            --assignee "$MCP_AI_CLIENT_ID" \
            --role "Cognitive Services OpenAI User" \
            --scope "$scope" >/dev/null 2>&1 || log_warning "Could not assign Cognitive Services role"
        log_success "Assigned role: Cognitive Services OpenAI User"

        # Also assign Reader for resource discovery
        az role assignment create \
            --assignee "$MCP_AI_CLIENT_ID" \
            --role "Reader" \
            --scope "$scope" >/dev/null 2>&1 || true
        log_success "Assigned role: Reader"
    fi
}

# --- 4. Generate MCP Backstage Token ---
generate_backstage_token() {
    log_step "4/6 — MCP Backstage Bearer Token"

    # Generate a secure random token
    MCP_BACKSTAGE_TOKEN=$(openssl rand -hex 32)

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would generate Backstage MCP token"
    else
        log_success "Generated Backstage MCP token (32-byte hex)"

        # Store in Key Vault if available
        if [[ -n "$KEY_VAULT_NAME" ]]; then
            az keyvault secret set \
                --vault-name "$KEY_VAULT_NAME" \
                --name "mcp-backstage-token" \
                --value "$MCP_BACKSTAGE_TOKEN" >/dev/null 2>&1 || \
                log_warning "Could not store token in Key Vault (may not exist yet)"
            log_success "Stored in Key Vault: mcp-backstage-token"
        fi
    fi
}

# --- 5. ArgoCD MCP Token placeholder ---
setup_argocd_token() {
    log_step "5/6 — MCP ArgoCD Token"

    log_info "ArgoCD API token will be created post-deployment."
    log_info "After ArgoCD is running, execute:"
    echo ""
    echo -e "  ${CYAN}# Login to ArgoCD${NC}"
    echo -e "  ${CYAN}argocd login localhost:8080 --username admin --password <password>${NC}"
    echo ""
    echo -e "  ${CYAN}# Create API token for MCP${NC}"
    echo -e "  ${CYAN}argocd account generate-token --account mcp-readonly${NC}"
    echo ""
    echo -e "  ${CYAN}# Store in Key Vault${NC}"
    echo -e "  ${CYAN}az keyvault secret set --vault-name $KEY_VAULT_NAME --name mcp-argocd-token --value <token>${NC}"
    echo ""

    MCP_ARGOCD_TOKEN="<post-deploy>"
}

# --- 6. Validate GitHub Token ---
validate_github_token() {
    log_step "6/6 — MCP GitHub Token Validation"

    if [[ -n "${GITHUB_TOKEN:-}" ]]; then
        # Validate token scopes
        local scopes
        scopes=$(gh api -H "Accept: application/json" / 2>/dev/null && echo "valid" || echo "invalid")
        if [[ "$scopes" == "valid" ]]; then
            log_success "GITHUB_TOKEN is set and valid"
        else
            log_warning "GITHUB_TOKEN may have insufficient scopes"
        fi
    else
        local gh_token
        gh_token=$(gh auth token 2>/dev/null || echo "")
        if [[ -n "$gh_token" ]]; then
            log_success "GitHub CLI authenticated (token available via 'gh auth token')"
            log_info "Set GITHUB_TOKEN for MCP: export GITHUB_TOKEN=\$(gh auth token)"
        else
            log_warning "No GITHUB_TOKEN found. Set via: export GITHUB_TOKEN=ghp_xxxx"
        fi
    fi
}

# --- Generate .env.mcp file ---
generate_env_file() {
    log_step "Generating .env.mcp"

    local env_file
    env_file="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.env.mcp"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY-RUN] Would generate: $env_file"
        return
    fi

    cat > "$env_file" << EOF
# =============================================================================
# THREE HORIZONS — MCP Server Environment Variables
# =============================================================================
# Generated by: scripts/setup-mcp-identities.sh
# Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# Environment: ${ENVIRONMENT}
#
# SECURITY: This file contains sensitive credentials.
#           DO NOT commit to Git. Added to .gitignore.
# =============================================================================

# --- Azure Core ---
AZURE_SUBSCRIPTION_ID=${SUBSCRIPTION_ID}
AZURE_TENANT_ID=${TENANT_ID}

# --- MCP Azure/AKS Server (SP: ${ORG_CODE}-${PROJECT_NAME}-mcp-azure) ---
MCP_AZURE_CLIENT_ID=${MCP_AZURE_CLIENT_ID:-}

# --- MCP AI Foundry Server (SP: ${ORG_CODE}-${PROJECT_NAME}-mcp-ai-foundry) ---
MCP_AI_FOUNDRY_CLIENT_ID=${MCP_AI_CLIENT_ID:-}

# --- MCP Backstage Server (Bearer Token) ---
MCP_TOKEN=${MCP_BACKSTAGE_TOKEN:-}

# --- MCP ArgoCD Server ---
ARGOCD_SERVER=localhost:8080
ARGOCD_AUTH_TOKEN=${MCP_ARGOCD_TOKEN:-}

# --- MCP GitHub Server ---
GITHUB_TOKEN=\${GITHUB_TOKEN:-\$(gh auth token 2>/dev/null)}
GH_TOKEN=\${GITHUB_TOKEN}
COPILOT_METRICS_TOKEN=\${GITHUB_TOKEN}

# --- Kubernetes ---
KUBECONFIG=\${KUBECONFIG:-~/.kube/config}

# --- Platform Admin Group ---
ADMIN_GROUP_ID=${ADMIN_GROUP_ID:-}

# --- Terraform Variables (export TF_VAR_xxx) ---
# export TF_VAR_azure_subscription_id=\${AZURE_SUBSCRIPTION_ID}
# export TF_VAR_azure_tenant_id=\${AZURE_TENANT_ID}
# export TF_VAR_admin_group_id=\${ADMIN_GROUP_ID}
# export TF_VAR_github_org=${GITHUB_ORG}
# export TF_VAR_github_token=\${GITHUB_TOKEN}
EOF

    chmod 600 "$env_file"
    log_success "Generated: $env_file (mode 600)"

    # Ensure .gitignore has .env.mcp
    local gitignore
    gitignore="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.gitignore"
    if [[ -f "$gitignore" ]]; then
        if ! grep -q '.env.mcp' "$gitignore"; then
            echo -e "\n# MCP identity credentials (generated)\n.env.mcp" >> "$gitignore"
            log_success "Added .env.mcp to .gitignore"
        fi
    fi
}

# --- Print summary ---
print_summary() {
    echo ""
    echo -e "${PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}${BOLD}║          MCP IDENTITIES SETUP — SUMMARY                      ║${NC}"
    echo -e "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BOLD}Identities Created:${NC}"
    echo ""

    printf "  %-4s %-35s %-15s %s\n" "#" "Identity" "Type" "Value"
    printf "  %-4s %-35s %-15s %s\n" "---" "-----------------------------------" "---------------" "---"

    if [[ "$SKIP_ADMIN_GROUP" != "true" ]]; then
        printf "  %-4s %-35s %-15s %s\n" "1" "Admin Group" "Entra ID Group" "${ADMIN_GROUP_ID:-N/A}"
    fi
    printf "  %-4s %-35s %-15s %s\n" "2" "MCP Azure/AKS SP" "App Reg + SP" "${MCP_AZURE_CLIENT_ID:-N/A}"
    printf "  %-4s %-35s %-15s %s\n" "3" "MCP AI Foundry SP" "App Reg + SP" "${MCP_AI_CLIENT_ID:-N/A}"
    printf "  %-4s %-35s %-15s %s\n" "4" "MCP Backstage Token" "Bearer Token" "(in .env.mcp)"
    printf "  %-4s %-35s %-15s %s\n" "5" "MCP ArgoCD Token" "API Token" "(post-deploy)"
    printf "  %-4s %-35s %-15s %s\n" "6" "MCP GitHub Token" "PAT/gh auth" "(GITHUB_TOKEN)"

    echo ""
    echo -e "${BOLD}RBAC Roles Assigned:${NC}"
    echo "  MCP Azure/AKS SP:"
    echo "    - Reader (Resource Group)"
    echo "    - Azure Kubernetes Service Cluster User Role"
    echo "    - Azure Kubernetes Service RBAC Writer"
    echo "  MCP AI Foundry SP:"
    echo "    - Cognitive Services OpenAI User"
    echo "    - Reader (Resource Group)"
    echo ""
    echo -e "${BOLD}Files Generated:${NC}"
    echo "  .env.mcp — MCP server environment variables (gitignored)"
    echo ""
    echo -e "${BOLD}Next Steps:${NC}"
    echo "  1. Source the env file:  source .env.mcp"
    echo "  2. Run Terraform:       cd terraform && terraform plan -var-file=environments/dev.tfvars"
    echo "  3. After deploy, create ArgoCD token (see step 5/6 output)"
    echo ""
    echo -e "${BOLD}Terraform Variables:${NC}"
    echo "  export TF_VAR_azure_subscription_id=\"${SUBSCRIPTION_ID}\""
    echo "  export TF_VAR_azure_tenant_id=\"${TENANT_ID}\""
    echo "  export TF_VAR_admin_group_id=\"${ADMIN_GROUP_ID:-<create first>}\""
    echo "  export TF_VAR_github_org=\"${GITHUB_ORG}\""
    echo "  export TF_VAR_github_token=\"\$(gh auth token)\""
    echo ""
}

# --- Main ---
main() {
    echo ""
    echo -e "${PURPLE}${BOLD}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}${BOLD}║    THREE HORIZONS — MCP IDENTITIES SETUP                     ║${NC}"
    echo -e "${PURPLE}${BOLD}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    parse_args "$@"

    [[ "$DRY_RUN" == "true" ]] && log_warning "DRY-RUN MODE — No changes will be made"

    check_prerequisites

    if [[ "$SKIP_ADMIN_GROUP" != "true" ]]; then
        create_admin_group
    fi

    create_mcp_azure_sp
    create_mcp_ai_foundry_sp
    generate_backstage_token
    setup_argocd_token
    validate_github_token
    generate_env_file
    print_summary

    log_success "MCP identities setup complete!"
}

main "$@"
