#!/bin/bash
# =============================================================================
# THREE HORIZONS ACCELERATOR - TEAM ONBOARDING
# =============================================================================
#
# Onboards a new team to the Three Horizons Platform.
# Creates namespaces, RBAC, GitHub team, quotas, and registers in RHDH.
#
# Usage: ./onboard-team.sh <team-name> [options]
#
# Options:
#   --display-name NAME   Human-readable team name
#   --owner EMAIL         Team owner email
#   --members FILE        File with member emails (one per line)
#   --quota PRESET        Resource quota: small, medium, large, custom
#   --environments ENVS   Comma-separated: dev,staging,prod
#   --templates TEMPLATES Allowed Golden Paths (comma-separated)
#   --slack-channel CH    Slack notification channel
#   --teams-channel CH    MS Teams notification channel
#   --dry-run             Preview changes without applying
#   --help                Show this help message
#
# Examples:
#   ./onboard-team.sh payments --owner john@acme.com --quota medium
#   ./onboard-team.sh checkout --members team-members.txt --environments dev,staging
#
# =============================================================================

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GITOPS_REPO="${GITOPS_REPO:-https://github.com/${GITHUB_ORG}/gitops-config.git}"
GITOPS_DIR="${SCRIPT_DIR}/../.gitops-config"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Defaults
TEAM_NAME=""
DISPLAY_NAME=""
OWNER_EMAIL=""
MEMBERS_FILE=""
QUOTA_PRESET="medium"
ENVIRONMENTS="dev,staging,prod"
TEMPLATES="all"
SLACK_CHANNEL=""
TEAMS_CHANNEL=""
DRY_RUN=false

# =============================================================================
# FUNCTIONS
# =============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  THREE HORIZONS PLATFORM - Team Onboarding${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_step() {
    echo ""
    echo -e "${CYAN}▶ Step $1: $2${NC}"
    echo -e "${CYAN}─────────────────────────────────────────────────────────────────────────${NC}"
}

validate_inputs() {
    if [[ -z "$TEAM_NAME" ]]; then
        log_error "Team name is required"
        echo ""
        echo "Usage: $0 <team-name> [options]"
        exit 1
    fi
    
    # Validate team name format
    if [[ ! "$TEAM_NAME" =~ ^[a-z][a-z0-9-]{2,20}$ ]]; then
        log_error "Team name must be lowercase, 3-21 chars, start with letter"
        exit 1
    fi
    
    # Validate owner email if provided
    if [[ -n "$OWNER_EMAIL" && ! "$OWNER_EMAIL" =~ ^[^@]+@[^@]+\.[^@]+$ ]]; then
        log_error "Invalid owner email format"
        exit 1
    fi
    
    # Validate quota preset
    if [[ ! "$QUOTA_PRESET" =~ ^(small|medium|large|custom)$ ]]; then
        log_error "Quota must be: small, medium, large, or custom"
        exit 1
    fi
    
    # Set display name if not provided
    if [[ -z "$DISPLAY_NAME" ]]; then
        DISPLAY_NAME="${TEAM_NAME^} Team"  # Capitalize first letter
    fi
}

get_quota_values() {
    case "$QUOTA_PRESET" in
        "small")
            CPU_LIMITS="4"
            MEMORY_LIMITS="8Gi"
            PODS_MAX="20"
            PVCS_MAX="5"
            ;;
        "medium")
            CPU_LIMITS="16"
            MEMORY_LIMITS="32Gi"
            PODS_MAX="50"
            PVCS_MAX="20"
            ;;
        "large")
            CPU_LIMITS="64"
            MEMORY_LIMITS="128Gi"
            PODS_MAX="200"
            PVCS_MAX="50"
            ;;
        "custom")
            log_warn "Using custom quota - edit team.yaml after creation"
            CPU_LIMITS="8"
            MEMORY_LIMITS="16Gi"
            PODS_MAX="30"
            PVCS_MAX="10"
            ;;
    esac
}

clone_gitops_repo() {
    log_step "1" "Clone GitOps Repository"
    
    if [[ -d "$GITOPS_DIR" ]]; then
        log_info "GitOps repo already cloned, pulling latest..."
        (cd "$GITOPS_DIR" && git pull)
    else
        log_info "Cloning GitOps repo..."
        git clone "$GITOPS_REPO" "$GITOPS_DIR"
    fi
    
    log_success "GitOps repo ready"
}

create_team_structure() {
    log_step "2" "Create Team Directory Structure"
    
    local team_dir="$GITOPS_DIR/teams/$TEAM_NAME"
    
    if [[ -d "$team_dir" && "$DRY_RUN" == "false" ]]; then
        log_warn "Team directory already exists: $team_dir"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Aborted"
            exit 1
        fi
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create: $team_dir"
    else
        mkdir -p "$team_dir"/{namespaces,apps}
        log_success "Created team directory structure"
    fi
}

generate_team_yaml() {
    log_step "3" "Generate Team Configuration"
    
    get_quota_values
    
    # Parse environments
    IFS=',' read -ra ENV_ARRAY <<< "$ENVIRONMENTS"
    
    # Build namespaces array
    local namespaces_yaml=""
    for env in "${ENV_ARRAY[@]}"; do
        namespaces_yaml="${namespaces_yaml}
      - name: ${TEAM_NAME}-${env}
        environment: ${env}
        role: admin"
    done
    
    local team_yaml="# =============================================================================
# TEAM CONFIGURATION: ${TEAM_NAME}
# =============================================================================
# Generated by Three Horizons Team Onboarding Script
# Date: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
# =============================================================================

apiVersion: threehorizons.io/v1
kind: Team
metadata:
  name: ${TEAM_NAME}
  
spec:
  displayName: \"${DISPLAY_NAME}\"
  description: \"${DISPLAY_NAME} - onboarded to Three Horizons Platform\"
  
  # -------------------------------------------------------------------------
  # Team Members
  # -------------------------------------------------------------------------
  owners:"
  
    if [[ -n "$OWNER_EMAIL" ]]; then
        team_yaml="${team_yaml}
    - email: ${OWNER_EMAIL}
      role: admin"
    fi
    
    team_yaml="${team_yaml}
      
  members: []
  # Add team members here:
  # - email: user@example.com
  #   role: developer
  
  # -------------------------------------------------------------------------
  # GitHub Integration
  # -------------------------------------------------------------------------
  github:
    teamName: ${TEAM_NAME}
    teamSlug: ${TEAM_NAME}
    repositories:
      defaultVisibility: private
      branchProtection: true
    permissions:
      - repo: \"*\"
        permission: push
        
  # -------------------------------------------------------------------------
  # Kubernetes Namespaces
  # -------------------------------------------------------------------------
  kubernetes:
    namespaces:${namespaces_yaml}
      
  # -------------------------------------------------------------------------
  # Resource Quotas
  # -------------------------------------------------------------------------
  quotas:
    preset: ${QUOTA_PRESET}
    cpu_limits: \"${CPU_LIMITS}\"
    memory_limits: \"${MEMORY_LIMITS}\"
    pods_max: ${PODS_MAX}
    pvcs_max: ${PVCS_MAX}
    
  # -------------------------------------------------------------------------
  # Golden Path Templates
  # -------------------------------------------------------------------------
  templates:"

    if [[ "$TEMPLATES" == "all" ]]; then
        team_yaml="${team_yaml}
    allowed: \"*\"  # All templates"
    else
        IFS=',' read -ra TEMPLATE_ARRAY <<< "$TEMPLATES"
        team_yaml="${team_yaml}
    allowed:"
        for tmpl in "${TEMPLATE_ARRAY[@]}"; do
            team_yaml="${team_yaml}
      - ${tmpl}"
        done
    fi
    
    team_yaml="${team_yaml}
    
  # -------------------------------------------------------------------------
  # Notifications
  # -------------------------------------------------------------------------
  notifications:"

    if [[ -n "$SLACK_CHANNEL" ]]; then
        team_yaml="${team_yaml}
    slack:
      channel: \"${SLACK_CHANNEL}\"
      alerts: true
      deployments: true"
    fi
    
    if [[ -n "$TEAMS_CHANNEL" ]]; then
        team_yaml="${team_yaml}
    teams:
      channel: \"${TEAMS_CHANNEL}\"
      alerts: true
      deployments: true"
    fi
    
    team_yaml="${team_yaml}

  # -------------------------------------------------------------------------
  # Observability
  # -------------------------------------------------------------------------
  observability:
    grafana:
      dashboardFolder: \"${DISPLAY_NAME}\"
      defaultDashboards:
        - kubernetes-resources
        - application-overview
    prometheus:
      scrapeNamespaces: true
    jaeger:
      enabled: true
"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create team.yaml:"
        echo ""
        echo "$team_yaml"
        echo ""
    else
        echo "$team_yaml" > "$GITOPS_DIR/teams/$TEAM_NAME/team.yaml"
        log_success "Generated team.yaml"
    fi
}

generate_namespace_manifests() {
    log_step "4" "Generate Namespace Manifests"
    
    IFS=',' read -ra ENV_ARRAY <<< "$ENVIRONMENTS"
    get_quota_values
    
    for env in "${ENV_ARRAY[@]}"; do
        local ns_name="${TEAM_NAME}-${env}"
        local ns_yaml="# =============================================================================
# NAMESPACE: ${ns_name}
# =============================================================================

apiVersion: v1
kind: Namespace
metadata:
  name: ${ns_name}
  labels:
    app.kubernetes.io/managed-by: three-horizons
    three-horizons/team: ${TEAM_NAME}
    three-horizons/environment: ${env}
  annotations:
    scheduler.alpha.kubernetes.io/defaultTolerations: '[]'
    
---
# =============================================================================
# RESOURCE QUOTA
# =============================================================================

apiVersion: v1
kind: ResourceQuota
metadata:
  name: ${ns_name}-quota
  namespace: ${ns_name}
spec:
  hard:
    requests.cpu: \"${CPU_LIMITS}\"
    requests.memory: \"${MEMORY_LIMITS}\"
    limits.cpu: \"${CPU_LIMITS}\"
    limits.memory: \"${MEMORY_LIMITS}\"
    pods: \"${PODS_MAX}\"
    persistentvolumeclaims: \"${PVCS_MAX}\"
    services: \"20\"
    secrets: \"50\"
    configmaps: \"50\"

---
# =============================================================================
# LIMIT RANGE
# =============================================================================

apiVersion: v1
kind: LimitRange
metadata:
  name: ${ns_name}-limits
  namespace: ${ns_name}
spec:
  limits:
    - default:
        cpu: \"500m\"
        memory: \"512Mi\"
      defaultRequest:
        cpu: \"100m\"
        memory: \"128Mi\"
      max:
        cpu: \"4\"
        memory: \"8Gi\"
      min:
        cpu: \"50m\"
        memory: \"64Mi\"
      type: Container
      
---
# =============================================================================
# NETWORK POLICY - Default Deny
# =============================================================================

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: ${ns_name}
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress

---
# =============================================================================
# NETWORK POLICY - Allow Same Namespace
# =============================================================================

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace
  namespace: ${ns_name}
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector: {}
  egress:
    - to:
        - podSelector: {}
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53

---
# =============================================================================
# NETWORK POLICY - Allow Ingress Controller
# =============================================================================

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-ingress-controller
  namespace: ${ns_name}
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: ingress-nginx

---
# =============================================================================
# NETWORK POLICY - Allow Prometheus Scraping
# =============================================================================

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-prometheus
  namespace: ${ns_name}
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: observability
      ports:
        - protocol: TCP
          port: 9090
        - protocol: TCP
          port: 8080
"

        if [[ "$DRY_RUN" == "true" ]]; then
            log_info "[DRY RUN] Would create namespace: $ns_name"
        else
            echo "$ns_yaml" > "$GITOPS_DIR/teams/$TEAM_NAME/namespaces/${ns_name}.yaml"
            log_success "Generated namespace manifest: $ns_name"
        fi
    done
}

create_github_team() {
    log_step "5" "Create GitHub Team"
    
    local github_org="${GITHUB_ORG}"
    
    if [[ -z "$github_org" ]]; then
        log_warn "GITHUB_ORG not set, skipping GitHub team creation"
        return
    fi
    
    # Check if team exists
    local existing=$(gh api "/orgs/$github_org/teams/$TEAM_NAME" 2>/dev/null || echo "")
    
    if [[ -n "$existing" ]]; then
        log_warn "GitHub team already exists: $TEAM_NAME"
        return
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create GitHub team: $TEAM_NAME"
    else
        gh api "/orgs/$github_org/teams" \
            -f name="$TEAM_NAME" \
            -f description="$DISPLAY_NAME - Three Horizons Platform" \
            -f privacy="closed" \
            2>/dev/null
            
        log_success "Created GitHub team: $TEAM_NAME"
        
        # Add owner if specified
        if [[ -n "$OWNER_EMAIL" ]]; then
            # Try to find GitHub username from email
            # This is a simplified approach - in reality, you'd use an identity mapping
            log_info "Owner ($OWNER_EMAIL) should be added manually to the GitHub team"
        fi
    fi
}

create_argocd_project() {
    log_step "6" "Create ArgoCD Project"
    
    local project_yaml="apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: ${TEAM_NAME}
  namespace: argocd
  labels:
    three-horizons/team: ${TEAM_NAME}
spec:
  description: \"Project for ${DISPLAY_NAME}\"
  
  sourceRepos:
    - 'https://github.com/${GITHUB_ORG}/*'
    - 'registry-1.docker.io'
    
  destinations:"

    IFS=',' read -ra ENV_ARRAY <<< "$ENVIRONMENTS"
    for env in "${ENV_ARRAY[@]}"; do
        project_yaml="${project_yaml}
    - namespace: ${TEAM_NAME}-${env}
      server: https://kubernetes.default.svc"
    done
    
    project_yaml="${project_yaml}
      
  clusterResourceWhitelist: []
  
  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota
    - group: ''
      kind: LimitRange
    - group: networking.k8s.io
      kind: NetworkPolicy
      
  roles:
    - name: team-admin
      description: \"Admin access for ${TEAM_NAME}\"
      policies:
        - p, proj:${TEAM_NAME}:team-admin, applications, *, ${TEAM_NAME}/*, allow
        - p, proj:${TEAM_NAME}:team-admin, repositories, get, ${TEAM_NAME}/*, allow
      groups:
        - ${TEAM_NAME}
        
    - name: team-viewer
      description: \"View access for ${TEAM_NAME}\"
      policies:
        - p, proj:${TEAM_NAME}:team-viewer, applications, get, ${TEAM_NAME}/*, allow
"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would create ArgoCD project: $TEAM_NAME"
    else
        echo "$project_yaml" > "$GITOPS_DIR/teams/$TEAM_NAME/argocd-project.yaml"
        log_success "Generated ArgoCD project manifest"
    fi
}

register_in_rhdh() {
    log_step "7" "Register Team in RHDH Catalog"
    
    local catalog_yaml="apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: ${TEAM_NAME}
  description: ${DISPLAY_NAME}
  annotations:
    github.com/team-slug: ${GITHUB_ORG}/${TEAM_NAME}
    argocd.argoproj.io/project: ${TEAM_NAME}
spec:
  type: team
  profile:
    displayName: ${DISPLAY_NAME}
  children: []
  members:"

    if [[ -n "$OWNER_EMAIL" ]]; then
        # Convert email to Backstage user reference
        local user_ref=$(echo "$OWNER_EMAIL" | sed 's/@.*//')
        catalog_yaml="${catalog_yaml}
    - ${user_ref}"
    fi
    
    catalog_yaml="${catalog_yaml}

---
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: ${TEAM_NAME}-apps
  description: \"Applications owned by ${DISPLAY_NAME}\"
spec:
  type: url
  targets:
    - https://github.com/${GITHUB_ORG}/gitops-config/blob/main/teams/${TEAM_NAME}/apps/*/catalog-info.yaml
"

    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would register team in RHDH catalog"
    else
        echo "$catalog_yaml" > "$GITOPS_DIR/teams/$TEAM_NAME/catalog-info.yaml"
        log_success "Generated RHDH catalog entry"
    fi
}

commit_and_push() {
    log_step "8" "Commit and Push to GitOps Repository"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "[DRY RUN] Would commit and push changes"
        return
    fi
    
    cd "$GITOPS_DIR"
    
    git add "teams/$TEAM_NAME/"
    git commit -m "feat(teams): onboard team ${TEAM_NAME}

- Create namespace manifests for: ${ENVIRONMENTS}
- Configure resource quotas (${QUOTA_PRESET})
- Create ArgoCD project
- Register in RHDH catalog

Generated by Three Horizons Team Onboarding Script"

    git push origin main
    
    log_success "Pushed changes to GitOps repository"
}

print_summary() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  ONBOARDING COMPLETE${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}  This was a DRY RUN - no changes were made.${NC}"
        echo ""
        echo "  To apply changes, run without --dry-run:"
        echo "  $0 $TEAM_NAME ${@:2}"
        echo ""
    else
        echo -e "${GREEN}  ✓ Team '$TEAM_NAME' has been onboarded!${NC}"
        echo ""
        echo "  Next Steps:"
        echo ""
        echo "  1. ArgoCD will automatically sync the team namespaces"
        echo "     Check: https://argocd.\${DNS_ZONE}/applications/team-${TEAM_NAME}"
        echo ""
        echo "  2. Add team members to the GitHub team:"
        echo "     gh api /orgs/\${GITHUB_ORG}/teams/${TEAM_NAME}/memberships/USERNAME -f role=member"
        echo ""
        echo "  3. Team can now create applications using Golden Paths in RHDH:"
        echo "     https://developer.\${DNS_ZONE}/catalog?filters[kind]=template"
        echo ""
        echo "  Team Details:"
        echo "  ├─ Name:        ${TEAM_NAME}"
        echo "  ├─ Display:     ${DISPLAY_NAME}"
        echo "  ├─ Owner:       ${OWNER_EMAIL:-Not set}"
        echo "  ├─ Namespaces:  ${ENVIRONMENTS}"
        echo "  ├─ Quota:       ${QUOTA_PRESET}"
        echo "  └─ Templates:   ${TEMPLATES}"
        echo ""
    fi
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    # Parse team name (first argument)
    if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
        TEAM_NAME="$1"
        shift
    fi
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case $1 in
            --display-name)
                DISPLAY_NAME="$2"
                shift 2
                ;;
            --owner)
                OWNER_EMAIL="$2"
                shift 2
                ;;
            --members)
                MEMBERS_FILE="$2"
                shift 2
                ;;
            --quota)
                QUOTA_PRESET="$2"
                shift 2
                ;;
            --environments)
                ENVIRONMENTS="$2"
                shift 2
                ;;
            --templates)
                TEMPLATES="$2"
                shift 2
                ;;
            --slack-channel)
                SLACK_CHANNEL="$2"
                shift 2
                ;;
            --teams-channel)
                TEAMS_CHANNEL="$2"
                shift 2
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --help)
                head -35 "$0" | tail -30
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    print_header
    validate_inputs
    
    clone_gitops_repo
    create_team_structure
    generate_team_yaml
    generate_namespace_manifests
    create_github_team
    create_argocd_project
    register_in_rhdh
    commit_and_push
    
    print_summary
}

main "$@"
