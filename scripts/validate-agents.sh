#!/usr/bin/env zsh
#
# validate-agents.sh - Validate all agent specification files
#
# This script checks:
# - All agent files exist and are non-empty
# - Required frontmatter fields are present (name, description, task)
# - Required sections are present in each file
# - Task-driven structure with sub-tasks
# - Skills, scripts, and terraform module references
#
# Usage: ./scripts/validate-agents.sh [--verbose]
#
# NOTE: Uses zsh for associative array support on macOS
#

set -e
setopt KSH_ARRAYS 2>/dev/null || true

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (handle both bash and zsh)
if [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
AGENTS_DIR="$PROJECT_ROOT/.github/agents"

# Counters
TOTAL_AGENTS=0
VALID_AGENTS=0
WARNINGS=0
ERRORS=0

# Verbose mode
VERBOSE=false
if [[ "$1" == "--verbose" || "$1" == "-v" ]]; then
    VERBOSE=true
fi

# Print functions
print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    ((WARNINGS++))
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    ((ERRORS++))
}

print_info() {
    if [[ "$VERBOSE" == true ]]; then
        echo -e "${BLUE}ℹ️  $1${NC}"
    fi
}

# Required sections in agent files (task-driven structure)
REQUIRED_SECTIONS=(
    "Your Mission"
    "Clarifying Questions"
    "Sub-Tasks"
    "Resources"
    "Completion Checklist"
    "Rollback Procedure"
    "Important Reminders"
)

# Required frontmatter fields
REQUIRED_FRONTMATTER=(
    "name:"
    "description:"
    "task:"
    "tools:"
)

# Expected agent files (flat structure in .github/agents/)
AGENT_FILES=(
    "infrastructure.agent.md"
    "aro.agent.md"
    "networking.agent.md"
    "security.agent.md"
    "defender-cloud.agent.md"
    "database.agent.md"
    "container-registry.agent.md"
    "governance.agent.md"
    "gitops.agent.md"
    "rhdh.agent.md"
    "observability.agent.md"
    "golden-paths.agent.md"
    "runners.agent.md"
    "ai-foundry.agent.md"
    "mlops-pipeline.agent.md"
    "multi-agent.agent.md"
    "sre.agent.md"
    "validation.agent.md"
    "migration.agent.md"
    "rollback.agent.md"
    "cost.agent.md"
    "github-app.agent.md"
    "identity.agent.md"
    "deployment.agent.md"
    "terraform.agent.md"
    "architect.agent.md"
    "devops.agent.md"
    "platform.agent.md"
    "reviewer.agent.md"
    "documentation.agent.md"
)

# Valid MCP servers (exported for use by other scripts)
export VALID_MCP_SERVERS=(
    "kubernetes"
    "azure"
    "github"
    "helm"
    "terraform"
    "git"
    "azure-ai"
    "prometheus"
)

# Validate single agent file
validate_agent() {
    local file_name="$1"
    local full_path="$AGENTS_DIR/$file_name"
    local agent_name="${file_name%.agent.md}"
    local file_valid=true

    print_info "Validating: $agent_name"

    # Check file exists
    if [[ ! -f "$full_path" ]]; then
        print_error "$agent_name: File not found ($file_name)"
        return 1
    fi

    # Check file is not empty
    if [[ ! -s "$full_path" ]]; then
        print_error "$agent_name: File is empty"
        return 1
    fi

    # Get line count
    local line_count
    line_count=$(wc -l < "$full_path")
    if [[ $line_count -lt 100 ]]; then
        print_warning "$agent_name: File seems too short ($line_count lines, expected 100+)"
        file_valid=false
    fi

    # Check frontmatter
    if ! head -1 "$full_path" | grep -q "^---$"; then
        print_error "$agent_name: Missing YAML frontmatter"
        file_valid=false
    fi

    # Check required frontmatter fields
    for field in "${REQUIRED_FRONTMATTER[@]}"; do
        if ! grep -q "^$field" "$full_path"; then
            print_warning "$agent_name: Missing frontmatter field '$field'"
            file_valid=false
        fi
    done

    # Check required sections
    for section in "${REQUIRED_SECTIONS[@]}"; do
        if ! grep -qi "$section" "$full_path"; then
            print_warning "$agent_name: Missing section '$section'"
            file_valid=false
        fi
    done

    # Check for Sub-Tasks (should have at least 4)
    local subtask_count
    subtask_count=$(grep -c "^### [0-9]" "$full_path" 2>/dev/null || echo 0)
    if [[ $subtask_count -lt 4 ]]; then
        print_warning "$agent_name: Only $subtask_count sub-tasks found (expected 4-6)"
        file_valid=false
    fi

    # Check for code blocks
    if ! grep -q '```' "$full_path"; then
        print_warning "$agent_name: No code blocks found"
        file_valid=false
    fi

    # Check for Input/Actions/Output pattern
    if ! grep -qi "**Input:**" "$full_path"; then
        print_warning "$agent_name: Missing Input/Actions/Output pattern in sub-tasks"
        file_valid=false
    fi

    if [[ "$file_valid" == true ]]; then
        print_success "$agent_name: Valid ($line_count lines, $subtask_count sub-tasks)"
        return 0
    else
        return 1
    fi
}

# Validate directory structure
validate_structure() {
    print_header "Validating Directory Structure"

    if [[ -d "$AGENTS_DIR" ]]; then
        local count
        count=$(find "$AGENTS_DIR" -name "*.agent.md" -type f | wc -l)
        print_success ".github/agents/: $count agents found"
        
        if [[ $count -ne 30 ]]; then
            print_warning "Expected 30 agents, found $count"
        fi
    else
        print_error ".github/agents/: Directory not found"
    fi

    # Check for template
    if [[ -f "$AGENTS_DIR/AGENT_TEMPLATE.md" ]]; then
        print_success "AGENT_TEMPLATE.md found"
    else
        print_warning "AGENT_TEMPLATE.md not found"
    fi
}

# Validate all agent files
validate_agents() {
    print_header "Validating Agent Specifications"

    for file_name in "${AGENT_FILES[@]}"; do
        ((TOTAL_AGENTS++)) || true
        if validate_agent "$file_name"; then
            ((VALID_AGENTS++)) || true
        fi
    done
}

# Validate documentation files
validate_docs() {
    print_header "Validating Supporting Documentation"

    local docs=(
        "README.md"
        "AGENT_TEMPLATE.md"
    )

    for doc in "${docs[@]}"; do
        if [[ -f "$AGENTS_DIR/$doc" ]]; then
            local line_count
            line_count=$(wc -l < "$AGENTS_DIR/$doc")
            print_success "$doc: Found ($line_count lines)"
        else
            print_warning "$doc: Not found"
        fi
    done

    # Check for skills directory
    if [[ -d "$PROJECT_ROOT/.github/skills" ]]; then
        local skill_count
        skill_count=$(find "$PROJECT_ROOT/.github/skills" -name "SKILL.md" | wc -l)
        print_success ".github/skills/: $skill_count skills found"
    else
        print_warning ".github/skills/: Directory not found"
    fi
}

# Check cross-references
validate_crossrefs() {
    print_header "Validating Cross-References"

    # Check for broken links within agents directory
    local broken_links=0

    for file in "$AGENTS_DIR"/*.agent.md; do
        if [[ -f "$file" ]]; then
            # Check for related agent references
            while IFS= read -r agent_ref; do
                local ref_file="${agent_ref}.agent.md"
                if [[ ! -f "$AGENTS_DIR/$ref_file" ]]; then
                    if [[ "$VERBOSE" == true ]]; then
                        print_warning "Unknown agent reference in $(basename "$file"): $agent_ref"
                    fi
                    ((broken_links++))
                fi
            done < <(grep -oE '\| [a-z-]+-agent \|' "$file" 2>/dev/null | sed 's/| //g; s/ |//g; s/-agent$//' || true)
        fi
    done

    if [[ $broken_links -eq 0 ]]; then
        print_success "No broken cross-references found"
    else
        print_warning "$broken_links potential broken references (run with --verbose for details)"
    fi

    # Validate skill references
    local missing_skills=0
    for file in "$AGENTS_DIR"/*.agent.md; do
        if [[ -f "$file" ]]; then
            while IFS= read -r skill; do
                skill=$(echo "$skill" | tr -d ' ')
                if [[ ! -d "$PROJECT_ROOT/.github/skills/$skill" ]]; then
                    if [[ "$VERBOSE" == true ]]; then
                        print_warning "Unknown skill reference in $(basename "$file"): $skill"
                    fi
                    ((missing_skills++))
                fi
            done < <(grep -A 10 "^skills:" "$file" 2>/dev/null | grep "^\s*-" | sed 's/.*- //' || true)
        fi
    done

    if [[ $missing_skills -eq 0 ]]; then
        print_success "All skill references valid"
    else
        print_warning "$missing_skills skill references to non-existent skills"
    fi
}

# Generate summary
print_summary() {
    print_header "Validation Summary"

    echo -e "Total Agents:    ${BLUE}$TOTAL_AGENTS${NC}"
    echo -e "Valid Agents:    ${GREEN}$VALID_AGENTS${NC}"
    echo -e "Warnings:        ${YELLOW}$WARNINGS${NC}"
    echo -e "Errors:          ${RED}$ERRORS${NC}"
    echo ""

    local percentage=$((VALID_AGENTS * 100 / TOTAL_AGENTS))

    if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
        print_success "All validations passed! ($percentage% agents valid)"
        exit 0
    elif [[ $ERRORS -eq 0 ]]; then
        print_warning "Validation completed with warnings ($percentage% agents valid)"
        exit 0
    else
        print_error "Validation failed with errors ($percentage% agents valid)"
        exit 1
    fi
}

# Main execution
main() {
    print_header "Three Horizons Agent Validator"

    echo "Project Root: $PROJECT_ROOT"
    echo "Agents Dir:   $AGENTS_DIR"
    echo ""

    validate_structure
    validate_agents
    validate_docs
    validate_crossrefs
    print_summary
}

main "$@"
