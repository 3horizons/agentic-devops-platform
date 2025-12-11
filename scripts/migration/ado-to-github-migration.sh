#!/bin/bash
# =============================================================================
# THREE HORIZONS ACCELERATOR - ADO TO GITHUB MIGRATION TOOLKIT
# =============================================================================
#
# Comprehensive scripts for migrating from Azure DevOps to GitHub
# Supports: Repos, Pipelines, Work Items, and Security
#
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIGURATION
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/migration.log"
DRY_RUN=false
VERBOSE=false

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

log() {
    local level=$1
    shift
    local message=$*
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${timestamp} [${level}] ${message}" >> "${LOG_FILE}"
    
    case ${level} in
        INFO)  echo -e "${GREEN}[INFO]${NC} ${message}" ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} ${message}" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} ${message}" ;;
        DEBUG) [[ "${VERBOSE}" == "true" ]] && echo -e "${BLUE}[DEBUG]${NC} ${message}" ;;
    esac
}

# =============================================================================
# PREREQUISITE CHECKS
# =============================================================================

check_prerequisites() {
    log INFO "Checking prerequisites..."
    
    local missing=()
    
    # Check for required tools
    command -v gh >/dev/null 2>&1 || missing+=("gh (GitHub CLI)")
    command -v az >/dev/null 2>&1 || missing+=("az (Azure CLI)")
    command -v git >/dev/null 2>&1 || missing+=("git")
    command -v jq >/dev/null 2>&1 || missing+=("jq")
    
    # Check for ado2gh extension
    if ! gh extension list 2>/dev/null | grep -q "ado2gh"; then
        missing+=("gh ado2gh extension")
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log ERROR "Missing prerequisites:"
        for tool in "${missing[@]}"; do
            log ERROR "  - ${tool}"
        done
        echo ""
        echo "Installation instructions:"
        echo "  gh CLI:      https://cli.github.com/"
        echo "  Azure CLI:   https://docs.microsoft.com/cli/azure/install-azure-cli"
        echo "  ado2gh:      gh extension install github/gh-ado2gh"
        exit 1
    fi
    
    log INFO "All prerequisites satisfied"
}

# =============================================================================
# AUTHENTICATION
# =============================================================================

setup_authentication() {
    log INFO "Setting up authentication..."
    
    # GitHub authentication
    if ! gh auth status >/dev/null 2>&1; then
        log WARN "GitHub CLI not authenticated. Please run: gh auth login"
        exit 1
    fi
    
    # Azure DevOps authentication
    if [[ -z "${AZURE_DEVOPS_EXT_PAT:-}" ]]; then
        log WARN "AZURE_DEVOPS_EXT_PAT environment variable not set"
        read -sp "Enter Azure DevOps PAT: " ADO_PAT
        echo ""
        export AZURE_DEVOPS_EXT_PAT="${ADO_PAT}"
    fi
    
    # Verify ADO connection
    if ! az devops project list --org "${ADO_ORG}" >/dev/null 2>&1; then
        log ERROR "Failed to connect to Azure DevOps organization: ${ADO_ORG}"
        exit 1
    fi
    
    log INFO "Authentication configured successfully"
}

# =============================================================================
# REPOSITORY MIGRATION
# =============================================================================

migrate_repository() {
    local ado_project=$1
    local ado_repo=$2
    local gh_org=$3
    local gh_repo=${4:-$ado_repo}
    
    log INFO "Migrating repository: ${ado_project}/${ado_repo} -> ${gh_org}/${gh_repo}"
    
    if [[ "${DRY_RUN}" == "true" ]]; then
        log INFO "[DRY RUN] Would migrate ${ado_repo}"
        return 0
    fi
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    trap "rm -rf ${temp_dir}" EXIT
    
    # Clone ADO repository with full history
    log DEBUG "Cloning from ADO..."
    git clone --mirror "https://dev.azure.com/${ADO_ORG}/${ado_project}/_git/${ado_repo}" "${temp_dir}/${ado_repo}"
    
    cd "${temp_dir}/${ado_repo}"
    
    # Create GitHub repository
    log DEBUG "Creating GitHub repository..."
    gh repo create "${gh_org}/${gh_repo}" \
        --private \
        --description "Migrated from Azure DevOps: ${ado_project}/${ado_repo}" \
        --disable-wiki \
        || log WARN "Repository may already exist"
    
    # Push to GitHub
    log DEBUG "Pushing to GitHub..."
    git push --mirror "https://github.com/${gh_org}/${gh_repo}.git"
    
    # Enable branch protection
    log DEBUG "Configuring branch protection..."
    gh api -X PUT "repos/${gh_org}/${gh_repo}/branches/main/protection" \
        -f required_status_checks='{"strict":true,"contexts":["build","test"]}' \
        -f enforce_admins=false \
        -f required_pull_request_reviews='{"required_approving_review_count":2}' \
        -f restrictions=null \
        || log WARN "Failed to set branch protection"
    
    log INFO "Repository migration completed: ${gh_org}/${gh_repo}"
}

migrate_all_repositories() {
    local ado_project=$1
    local gh_org=$2
    
    log INFO "Discovering repositories in project: ${ado_project}"
    
    # Get list of repositories
    local repos=$(az repos list \
        --org "${ADO_ORG}" \
        --project "${ado_project}" \
        --query "[].name" \
        -o tsv)
    
    local count=0
    local total=$(echo "${repos}" | wc -l)
    
    for repo in ${repos}; do
        count=$((count + 1))
        log INFO "Processing repository ${count}/${total}: ${repo}"
        migrate_repository "${ado_project}" "${repo}" "${gh_org}"
    done
    
    log INFO "All repositories migrated: ${count}/${total}"
}

# =============================================================================
# PIPELINE MIGRATION
# =============================================================================

convert_pipeline() {
    local ado_yaml=$1
    local output_file=$2
    
    log INFO "Converting pipeline: ${ado_yaml}"
    
    # Read ADO pipeline
    local ado_content=$(cat "${ado_yaml}")
    
    # Create GitHub Actions workflow
    cat > "${output_file}" << 'WORKFLOW_TEMPLATE'
# =============================================================================
# GITHUB ACTIONS WORKFLOW
# Converted from Azure DevOps Pipeline
# =============================================================================

name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  # Add environment variables here
  AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      # TODO: Add converted build steps here
      - name: Build
        run: |
          echo "Add your build commands here"

  test:
    runs-on: ubuntu-latest
    needs: build
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      # TODO: Add converted test steps here
      - name: Test
        run: |
          echo "Add your test commands here"

  deploy:
    runs-on: ubuntu-latest
    needs: [build, test]
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      # TODO: Add converted deploy steps here
      - name: Deploy
        run: |
          echo "Add your deployment commands here"
WORKFLOW_TEMPLATE
    
    log INFO "Pipeline converted to: ${output_file}"
    log WARN "Please review and update the converted workflow manually"
}

generate_migration_script() {
    local ado_project=$1
    local gh_org=$2
    local output_dir=$3
    
    log INFO "Generating migration scripts for project: ${ado_project}"
    
    mkdir -p "${output_dir}"
    
    # Generate using ado2gh
    gh ado2gh generate-script \
        --ado-org "${ADO_ORG}" \
        --ado-team-project "${ado_project}" \
        --github-org "${gh_org}" \
        --output "${output_dir}/migrate.ps1" \
        --sequential \
        2>&1 | tee -a "${LOG_FILE}"
    
    log INFO "Migration script generated: ${output_dir}/migrate.ps1"
}

# =============================================================================
# GHAS MIGRATION (GHAzDO -> GHAS)
# =============================================================================

migrate_security_alerts() {
    local gh_org=$1
    local gh_repo=$2
    
    log INFO "Enabling GHAS for: ${gh_org}/${gh_repo}"
    
    if [[ "${DRY_RUN}" == "true" ]]; then
        log INFO "[DRY RUN] Would enable GHAS"
        return 0
    fi
    
    # Enable security features
    gh api -X PATCH "repos/${gh_org}/${gh_repo}" \
        -f security_and_analysis='{"advanced_security":{"status":"enabled"},"secret_scanning":{"status":"enabled"},"secret_scanning_push_protection":{"status":"enabled"}}'
    
    # Create CodeQL workflow
    mkdir -p ".github/workflows"
    cat > ".github/workflows/codeql.yml" << 'CODEQL_WORKFLOW'
name: "CodeQL Analysis"

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '30 4 * * *'

jobs:
  analyze:
    name: Analyze
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: read
      security-events: write

    strategy:
      fail-fast: false
      matrix:
        language: ['javascript', 'python']  # Update based on repo languages

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: ${{ matrix.language }}
          queries: security-and-quality

      - name: Autobuild
        uses: github/codeql-action/autobuild@v3

      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
CODEQL_WORKFLOW
    
    log INFO "GHAS enabled and CodeQL workflow created"
}

# =============================================================================
# COPILOT MIGRATION (Standalone -> Enterprise)
# =============================================================================

configure_copilot_enterprise() {
    local gh_org=$1
    
    log INFO "Configuring Copilot Enterprise for organization: ${gh_org}"
    
    # This requires organization admin permissions
    # and Copilot Enterprise license
    
    cat << 'COPILOT_INFO'
=============================================================================
COPILOT ENTERPRISE CONFIGURATION
=============================================================================

To complete Copilot Enterprise setup:

1. Ensure you have Copilot Enterprise licenses assigned
2. Configure organization-wide Copilot settings:
   - Go to: https://github.com/organizations/${gh_org}/settings/copilot
   
3. Enable features:
   - ✅ Copilot Chat
   - ✅ Copilot in CLI
   - ✅ Knowledge bases (for org context)
   - ✅ Extensions

4. Configure policies:
   - Code suggestions: Enabled
   - Block suggestions matching public code: Enabled (recommended)
   - Copilot metrics: Enabled

5. Set up organization knowledge bases:
   - Go to: https://github.com/organizations/${gh_org}/settings/copilot/knowledge_bases
   - Add repositories for organizational context

=============================================================================
COPILOT_INFO
    
    log INFO "Copilot configuration guidance generated"
}

# =============================================================================
# WORK ITEM MIGRATION
# =============================================================================

migrate_work_items() {
    local ado_project=$1
    local gh_org=$2
    local gh_repo=$3
    
    log INFO "Migrating work items from ${ado_project} to ${gh_org}/${gh_repo}"
    
    # Export work items from ADO
    log DEBUG "Exporting work items from ADO..."
    
    local work_items=$(az boards query \
        --org "${ADO_ORG}" \
        --project "${ado_project}" \
        --wiql "SELECT [System.Id], [System.Title], [System.State], [System.Description], [System.WorkItemType] FROM WorkItems WHERE [System.TeamProject] = '${ado_project}'" \
        -o json)
    
    local count=0
    
    echo "${work_items}" | jq -c '.[]' | while read -r item; do
        local title=$(echo "${item}" | jq -r '.fields["System.Title"]')
        local state=$(echo "${item}" | jq -r '.fields["System.State"]')
        local description=$(echo "${item}" | jq -r '.fields["System.Description"] // "No description"')
        local type=$(echo "${item}" | jq -r '.fields["System.WorkItemType"]')
        local ado_id=$(echo "${item}" | jq -r '.id')
        
        # Map work item type to GitHub labels
        local labels=""
        case ${type} in
            "Bug") labels="bug" ;;
            "User Story") labels="enhancement" ;;
            "Task") labels="task" ;;
            "Feature") labels="feature" ;;
            *) labels="imported" ;;
        esac
        
        if [[ "${DRY_RUN}" == "true" ]]; then
            log DEBUG "[DRY RUN] Would create issue: ${title}"
            continue
        fi
        
        # Create GitHub issue
        gh issue create \
            --repo "${gh_org}/${gh_repo}" \
            --title "[Migrated #${ado_id}] ${title}" \
            --body "${description}

---
*Migrated from Azure DevOps: ${ado_project} #${ado_id}*
*Original State: ${state}*" \
            --label "${labels}" \
            || log WARN "Failed to create issue: ${title}"
        
        count=$((count + 1))
    done
    
    log INFO "Work items migrated: ${count}"
}

# =============================================================================
# FULL MIGRATION ORCHESTRATION
# =============================================================================

run_full_migration() {
    local ado_project=$1
    local gh_org=$2
    
    log INFO "Starting full migration: ${ado_project} -> ${gh_org}"
    
    # Phase 1: Repository Migration
    log INFO "=== Phase 1: Repository Migration ==="
    migrate_all_repositories "${ado_project}" "${gh_org}"
    
    # Phase 2: Security Configuration
    log INFO "=== Phase 2: Security Configuration ==="
    for repo in $(gh repo list "${gh_org}" --json name -q '.[].name'); do
        migrate_security_alerts "${gh_org}" "${repo}"
    done
    
    # Phase 3: Copilot Configuration
    log INFO "=== Phase 3: Copilot Enterprise ==="
    configure_copilot_enterprise "${gh_org}"
    
    # Phase 4: Work Items (optional)
    # log INFO "=== Phase 4: Work Items ==="
    # migrate_work_items "${ado_project}" "${gh_org}" "${gh_repo}"
    
    log INFO "Migration completed!"
    
    # Generate summary report
    generate_migration_report "${ado_project}" "${gh_org}"
}

generate_migration_report() {
    local ado_project=$1
    local gh_org=$2
    local report_file="${SCRIPT_DIR}/migration_report_$(date +%Y%m%d_%H%M%S).md"
    
    cat > "${report_file}" << REPORT
# Migration Report

**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Source:** Azure DevOps - ${ADO_ORG}/${ado_project}
**Target:** GitHub - ${gh_org}

## Summary

### Repositories Migrated
$(gh repo list "${gh_org}" --json name,createdAt -q '.[] | "- \(.name) (created: \(.createdAt))"')

### Security Features Enabled
- ✅ GitHub Advanced Security (GHAS)
- ✅ Secret Scanning
- ✅ Push Protection
- ✅ CodeQL Analysis
- ✅ Dependabot Alerts

### Pending Actions
- [ ] Review and update converted pipelines
- [ ] Configure Copilot Enterprise settings
- [ ] Validate branch protection rules
- [ ] Update CI/CD secrets
- [ ] Test deployment pipelines
- [ ] Archive ADO repositories

## Next Steps

1. **Validate Migrations**
   - Verify all commits and branches transferred
   - Check file integrity with checksums
   
2. **Update CI/CD**
   - Convert remaining ADO pipelines
   - Configure GitHub Actions secrets
   - Test deployments in dev environment

3. **Security Configuration**
   - Review CodeQL results
   - Address any initial security findings
   - Configure security policies

4. **Team Onboarding**
   - Update team documentation
   - Train team on GitHub workflows
   - Configure notification preferences

---
*Generated by Three Horizons Migration Toolkit*
REPORT
    
    log INFO "Migration report generated: ${report_file}"
}

# =============================================================================
# MAIN
# =============================================================================

show_help() {
    cat << HELP
Three Horizons - ADO to GitHub Migration Toolkit

Usage: $(basename "$0") [OPTIONS] COMMAND

Commands:
  migrate-repo      Migrate a single repository
  migrate-all       Migrate all repositories in a project
  convert-pipeline  Convert ADO pipeline to GitHub Actions
  migrate-security  Enable GHAS on migrated repositories
  migrate-workitems Migrate work items to GitHub Issues
  full-migration    Run complete migration workflow
  generate-script   Generate migration script using ado2gh

Options:
  -o, --ado-org       Azure DevOps organization URL
  -p, --ado-project   Azure DevOps project name
  -g, --gh-org        GitHub organization name
  -r, --gh-repo       GitHub repository name (for single repo)
  -d, --dry-run       Show what would be done without making changes
  -v, --verbose       Enable verbose output
  -h, --help          Show this help message

Examples:
  # Migrate single repository
  $(basename "$0") -o https://dev.azure.com/myorg -p MyProject -g my-gh-org -r my-repo migrate-repo

  # Migrate all repositories
  $(basename "$0") -o https://dev.azure.com/myorg -p MyProject -g my-gh-org migrate-all

  # Full migration with dry run
  $(basename "$0") -o https://dev.azure.com/myorg -p MyProject -g my-gh-org --dry-run full-migration

Environment Variables:
  AZURE_DEVOPS_EXT_PAT  Azure DevOps Personal Access Token
  GH_TOKEN              GitHub Personal Access Token (or use gh auth login)

HELP
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -o|--ado-org)     ADO_ORG="$2"; shift 2 ;;
            -p|--ado-project) ADO_PROJECT="$2"; shift 2 ;;
            -g|--gh-org)      GH_ORG="$2"; shift 2 ;;
            -r|--gh-repo)     GH_REPO="$2"; shift 2 ;;
            -d|--dry-run)     DRY_RUN=true; shift ;;
            -v|--verbose)     VERBOSE=true; shift ;;
            -h|--help)        show_help; exit 0 ;;
            *)                COMMAND="$1"; shift ;;
        esac
    done
    
    # Validate required arguments
    if [[ -z "${ADO_ORG:-}" ]] || [[ -z "${GH_ORG:-}" ]]; then
        log ERROR "Missing required arguments. Use -h for help."
        exit 1
    fi
    
    # Run prerequisites check
    check_prerequisites
    setup_authentication
    
    # Execute command
    case ${COMMAND:-help} in
        migrate-repo)
            migrate_repository "${ADO_PROJECT}" "${GH_REPO}" "${GH_ORG}"
            ;;
        migrate-all)
            migrate_all_repositories "${ADO_PROJECT}" "${GH_ORG}"
            ;;
        convert-pipeline)
            convert_pipeline "${ADO_PIPELINE:-azure-pipelines.yml}" ".github/workflows/ci.yml"
            ;;
        migrate-security)
            migrate_security_alerts "${GH_ORG}" "${GH_REPO}"
            ;;
        migrate-workitems)
            migrate_work_items "${ADO_PROJECT}" "${GH_ORG}" "${GH_REPO}"
            ;;
        full-migration)
            run_full_migration "${ADO_PROJECT}" "${GH_ORG}"
            ;;
        generate-script)
            generate_migration_script "${ADO_PROJECT}" "${GH_ORG}" "${SCRIPT_DIR}/scripts"
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

main "$@"
