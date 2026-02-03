# GitHub Copilot Agents - Implementation Plan

## Overview

This document outlines the implementation plan to align the Three Horizons Accelerator v4 repository with GitHub Copilot Agents best practices. Execute each phase sequentially, validating results before proceeding.

**Repository:** three-horizons-accelerator-v4
**Current Conformance:** 88%
**Target Conformance:** 98%

---

## Phase 1: Agent Frontmatter Standardization

### Objective
Update all agent files to include standard YAML frontmatter properties.

### Tasks

#### 1.1 Update Agent Frontmatter Format

For each file in `.github/agents/*.agent.md`, add the following properties:

```yaml
---
name: <agent-name>
description: <one-line description>
tools: ["read", "search", "edit", "execute"]  # Select appropriate tools
infer: false  # Set to true only for general-purpose agents
---
```

**Tool Selection Guidelines:**
| Agent Type | Recommended Tools |
|------------|-------------------|
| Planning/Research | `["read", "search"]` |
| Documentation | `["read", "search", "edit"]` |
| Code Review | `["read", "search"]` |
| Implementation | `["read", "search", "edit", "execute"]` |
| Testing | `["read", "search", "edit", "execute"]` |

#### 1.2 Files to Update

Execute for each agent:

```bash
# List of agents to update:
.github/agents/platform.agent.md
.github/agents/terraform.agent.md
.github/agents/reviewer.agent.md
.github/agents/security.agent.md
.github/agents/sre.agent.md
.github/agents/devops.agent.md
.github/agents/architect.agent.md
```

**Example transformation for `reviewer.agent.md`:**

```yaml
# BEFORE
---
name: reviewer
description: 'Code Review specialist for thorough code analysis...'
skills:
  - terraform-cli
  - github-cli
---

# AFTER
---
name: reviewer
description: 'Code Review specialist for thorough code analysis, security review, and best practices validation'
tools: ["read", "search"]
infer: false
skills:
  - terraform-cli
  - github-cli
---
```

### Validation
- [ ] All agents have `tools` array
- [ ] All specialized agents have `infer: false`
- [ ] YAML frontmatter is valid (no syntax errors)

---

## Phase 2: Three-Tier Boundaries Implementation

### Objective
Add consistent three-tier boundaries section to all agents.

### Tasks

#### 2.1 Standard Boundaries Template

Add this section to every agent file after the "Capabilities" or "Core Responsibilities" section:

```markdown
## Boundaries

- ✅ **ALWAYS**: [List of safe autonomous actions]
- ⚠️ **ASK FIRST**: [List of actions requiring human approval]
- 🚫 **NEVER**: [List of forbidden actions]
```

#### 2.2 Boundaries by Agent Type

**Platform Agent:**
```markdown
## Boundaries

- ✅ **ALWAYS**:
  - Read and analyze RHDH configurations
  - Validate templates against official documentation
  - Generate configuration snippets following best practices
  - Check health status of platform components

- ⚠️ **ASK FIRST**:
  - Modify RHDH Helm values
  - Update Golden Path templates
  - Change authentication providers
  - Modify plugin configurations

- 🚫 **NEVER**:
  - Apply changes directly to production clusters
  - Modify secrets or credentials inline
  - Delete or disable existing templates without backup
  - Change RBAC permissions without review
```

**Terraform Agent:**
```markdown
## Boundaries

- ✅ **ALWAYS**:
  - Run `terraform fmt` and `terraform validate`
  - Use Azure Verified Modules when available
  - Include variable descriptions and validation rules
  - Mark sensitive outputs appropriately
  - Apply consistent resource tagging

- ⚠️ **ASK FIRST**:
  - Create new modules or significant refactoring
  - Modify state backend configuration
  - Change provider versions
  - Add new resource types not in existing patterns

- 🚫 **NEVER**:
  - Execute `terraform apply` without explicit confirmation
  - Execute `terraform destroy` without explicit confirmation
  - Hardcode secrets or credentials
  - Modify production state files directly
  - Remove existing resources without confirmation
```

**Security Agent:**
```markdown
## Boundaries

- ✅ **ALWAYS**:
  - Scan for security vulnerabilities
  - Review RBAC configurations
  - Validate encryption settings
  - Check compliance against security baselines
  - Report findings with severity levels

- ⚠️ **ASK FIRST**:
  - Modify network security groups
  - Change Key Vault access policies
  - Update Defender configurations
  - Modify identity/authentication settings

- 🚫 **NEVER**:
  - Disable security controls
  - Expose secrets in logs or outputs
  - Bypass authentication mechanisms
  - Grant elevated privileges without approval
  - Access production data directly
```

**Reviewer Agent:**
```markdown
## Boundaries

- ✅ **ALWAYS**:
  - Analyze code for quality, security, and best practices
  - Provide actionable feedback with severity levels
  - Reference project conventions and standards
  - Suggest improvements with code examples

- ⚠️ **ASK FIRST**:
  - Before marking critical security issues
  - When recommending architectural changes
  - If suggesting dependency updates

- 🚫 **NEVER**:
  - Modify any files (read-only agent)
  - Approve changes automatically
  - Skip security review categories
  - Ignore critical findings
```

**SRE Agent:**
```markdown
## Boundaries

- ✅ **ALWAYS**:
  - Monitor cluster and application health
  - Analyze logs and metrics
  - Document incident timelines
  - Provide troubleshooting guidance
  - Calculate SLO/error budget status

- ⚠️ **ASK FIRST**:
  - Execute rollback procedures
  - Scale resources up or down
  - Modify alert thresholds
  - Change deployment configurations

- 🚫 **NEVER**:
  - Delete production workloads
  - Modify database data directly
  - Disable monitoring or alerting
  - Execute destructive commands without confirmation
```

**DevOps Agent:**
```markdown
## Boundaries

- ✅ **ALWAYS**:
  - Create and review CI/CD workflows
  - Validate Kubernetes manifests
  - Check ArgoCD sync status
  - Review Helm chart configurations

- ⚠️ **ASK FIRST**:
  - Deploy infrastructure changes
  - Modify GitHub Actions secrets
  - Update ArgoCD applications
  - Change deployment strategies

- 🚫 **NEVER**:
  - Push directly to main/master branch
  - Delete namespaces or clusters
  - Modify production without PR approval
  - Bypass branch protection rules
```

**Architect Agent:**
```markdown
## Boundaries

- ✅ **ALWAYS**:
  - Analyze system architecture
  - Provide design recommendations
  - Reference Azure Well-Architected Framework
  - Create architecture diagrams (Mermaid)
  - Document trade-offs and decisions

- ⚠️ **ASK FIRST**:
  - Before recommending significant changes
  - When proposing new technology adoption
  - If suggesting breaking changes

- 🚫 **NEVER**:
  - Implement changes directly (planning only)
  - Make decisions without documenting rationale
  - Skip security or compliance considerations
```

### Validation
- [ ] All agents have Boundaries section
- [ ] Three tiers consistently formatted
- [ ] Boundaries are specific and actionable

---

## Phase 3: Skills Structure Creation

### Objective
Create dedicated SKILL.md files in `.github/skills/` directory.

### Tasks

#### 3.1 Create Skills Directory Structure

```bash
mkdir -p .github/skills/terraform-cli
mkdir -p .github/skills/kubectl-cli
mkdir -p .github/skills/azure-cli
mkdir -p .github/skills/argocd-cli
mkdir -p .github/skills/helm-cli
mkdir -p .github/skills/validation-scripts
mkdir -p .github/skills/github-actions-debugging
```

#### 3.2 Create SKILL.md Files

**`.github/skills/terraform-cli/SKILL.md`:**
```markdown
---
name: terraform-cli
description: Terraform CLI operations for Azure infrastructure management
license: MIT
---

## When to Use
Use when working with Terraform configurations for Azure resources.

## Prerequisites
- Terraform >= 1.5.0
- Azure CLI authenticated
- Access to Terraform state backend

## Commands

### Validation
```bash
terraform fmt -check -recursive
terraform validate
```

### Planning
```bash
terraform init
terraform plan -var-file=environments/${ENVIRONMENT}.tfvars -out=tfplan
```

### Security Scanning
```bash
tfsec .
checkov -d .
```

## Best Practices
- Always run `terraform plan` before `apply`
- Use `-out=tfplan` to save plan for review
- Never commit `.tfstate` files
- Use workspaces or separate state files per environment

## Output Format
Provide:
1. Command executed
2. Exit code and summary
3. Key findings or changes
4. Next steps
```

**`.github/skills/kubectl-cli/SKILL.md`:**
```markdown
---
name: kubectl-cli
description: Kubernetes CLI operations for cluster management
license: MIT
---

## When to Use
Use when interacting with Kubernetes clusters (AKS or ARO).

## Prerequisites
- kubectl installed
- KUBECONFIG configured
- Appropriate RBAC permissions

## Commands

### Cluster Status
```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods -A | grep -v Running
```

### Resource Management
```bash
kubectl apply -f <manifest.yaml> --dry-run=client
kubectl apply -f <manifest.yaml>
kubectl delete -f <manifest.yaml>
```

### Troubleshooting
```bash
kubectl describe pod <pod-name> -n <namespace>
kubectl logs -f <pod-name> -n <namespace>
kubectl get events --sort-by='.lastTimestamp' -n <namespace>
```

## Best Practices
- Always use `--dry-run=client` before applying
- Specify namespace explicitly (`-n <namespace>`)
- Use labels for resource selection
- Check events when pods fail to start

## Output Format
Provide:
1. Command executed
2. Relevant output (filtered for readability)
3. Interpretation of results
4. Recommended actions
```

**`.github/skills/azure-cli/SKILL.md`:**
```markdown
---
name: azure-cli
description: Azure CLI operations for cloud resource management
license: MIT
---

## When to Use
Use when managing Azure resources, checking status, or validating configurations.

## Prerequisites
- Azure CLI installed
- Authenticated (`az login`)
- Correct subscription selected

## Commands

### Authentication
```bash
az account show
az account set --subscription <subscription-id>
```

### Resource Management
```bash
az resource list --resource-group <rg-name> -o table
az resource show --ids <resource-id>
```

### AKS Operations
```bash
az aks get-credentials --resource-group <rg> --name <cluster>
az aks show --resource-group <rg> --name <cluster>
```

### Key Vault
```bash
az keyvault secret list --vault-name <kv-name>
az keyvault secret show --vault-name <kv-name> --name <secret-name>
```

## Best Practices
- Use Managed Identity or Workload Identity
- Never expose credentials in commands
- Use `-o table` for readable output
- Use `-o json` for parsing with jq

## Output Format
Provide:
1. Command executed
2. Summary of results
3. Any warnings or issues found
4. Recommendations
```

**`.github/skills/github-actions-debugging/SKILL.md`:**
```markdown
---
name: github-actions-debugging
description: Debug failing GitHub Actions workflows
license: MIT
---

## When to Use
Use when a GitHub Actions workflow fails and you need to identify root cause.

## Inputs to Collect
- Workflow run URL or ID
- Job name and step that failed
- Relevant log snippets
- Recent commits or PR changes

## Procedure

### 1. Identify Failure
```bash
gh run view <run-id> --log-failed
gh run view <run-id> --json conclusion,jobs
```

### 2. Classify Failure Type
- **Dependency**: Package install failures, version conflicts
- **Build**: Compilation errors, missing files
- **Test**: Test failures, coverage thresholds
- **Lint**: Code style violations
- **Security**: Vulnerability scan failures
- **Auth**: Secret access issues, token expiration
- **Environment**: Missing tools, wrong versions

### 3. Analyze Logs
```bash
gh run view <run-id> --log | grep -A 10 "error\|failed\|Error"
```

### 4. Check Recent Changes
```bash
gh pr view <pr-number> --json files,commits
git log --oneline -10
```

## Output Format
```markdown
## Root Cause
- [Brief description]

## Evidence
- [Log snippets, error messages]

## Fix
- [Specific changes needed]

## Validation
- [Commands to verify fix]
```
```

#### 3.3 Create Validation Scripts Skill

**`.github/skills/validation-scripts/SKILL.md`:**
```markdown
---
name: validation-scripts
description: Project validation and health check scripts
license: MIT
---

## When to Use
Use when validating deployments, checking configurations, or running health checks.

## Available Scripts

### Infrastructure Validation
```bash
./scripts/validate-deployment.sh --environment <env>
```

### Configuration Validation
```bash
./scripts/validate-config.sh --environment <env>
```

### CLI Prerequisites
```bash
./scripts/validate-cli-prerequisites.sh
```

## Script Standards
All validation scripts follow these patterns:
- Exit code 0 = success
- Exit code 1 = failure
- Verbose output with timestamps
- JSON output option (`--output json`)

## Output Format
Provide:
1. Script executed with parameters
2. Summary of checks performed
3. Pass/fail status for each check
4. Remediation steps for failures
```

### Validation
- [ ] All skill directories created
- [ ] Each skill has valid SKILL.md with YAML frontmatter
- [ ] Skills are referenced correctly in agents

---

## Phase 4: Agent Handoffs Configuration

### Objective
Configure agent-to-agent handoffs for multi-step workflows.

### Tasks

#### 4.1 Add Handoffs to Planner/Architect Agent

Update `.github/agents/architect.agent.md`:

```yaml
---
name: architect
description: 'Solution Architecture specialist for system design and technical decisions'
tools: ["read", "search"]
infer: false
handoffs:
  - label: "Implement Plan"
    agent: devops
    prompt: "Implement the architecture plan outlined above. Follow the phases in order."
    send: false
  - label: "Review Security"
    agent: security
    prompt: "Review the proposed architecture for security concerns."
    send: false
  - label: "Create Infrastructure"
    agent: terraform
    prompt: "Create Terraform configurations based on the architecture above."
    send: false
---
```

#### 4.2 Add Handoffs to DevOps Agent

Update `.github/agents/devops.agent.md`:

```yaml
---
name: devops
description: 'DevOps specialist for CI/CD, Terraform, and Kubernetes'
tools: ["read", "search", "edit", "execute"]
infer: false
handoffs:
  - label: "Security Review"
    agent: security
    prompt: "Review the changes for security concerns before deployment."
    send: false
  - label: "Code Review"
    agent: reviewer
    prompt: "Review the code changes for quality and best practices."
    send: false
  - label: "Monitor Deployment"
    agent: sre
    prompt: "Monitor the deployment and verify service health."
    send: false
---
```

#### 4.3 Add Handoffs to Terraform Agent

Update `.github/agents/terraform.agent.md`:

```yaml
---
name: terraform
description: 'Azure Terraform IaC specialist'
tools: ["read", "search", "edit", "execute"]
infer: false
handoffs:
  - label: "Security Review"
    agent: security
    prompt: "Review the Terraform changes for security compliance."
    send: false
  - label: "Code Review"
    agent: reviewer
    prompt: "Review the Terraform code for best practices."
    send: false
---
```

### Validation
- [ ] Handoffs configured for workflow agents
- [ ] Agent references are valid
- [ ] Prompts are clear and specific

---

## Phase 5: AGENTS.md Creation

### Objective
Create a root-level AGENTS.md file as the agent playbook.

### Tasks

#### 5.1 Create AGENTS.md

Create `AGENTS.md` in repository root:

```markdown
# Three Horizons Accelerator - Agent Playbook

## Overview

This repository uses GitHub Copilot custom agents for DevOps automation. Each agent is specialized for specific tasks following the "one agent, one job" principle.

## Available Agents

| Agent | Purpose | Tools | Invoke With |
|-------|---------|-------|-------------|
| `@architect` | Solution design, WAF review | read, search | Architecture questions |
| `@platform` | RHDH, Golden Paths, IDP | read, search, edit | Platform configuration |
| `@terraform` | Azure IaC management | read, search, edit, execute | Terraform tasks |
| `@devops` | CI/CD, K8s, ArgoCD | read, search, edit, execute | Pipeline tasks |
| `@security` | Compliance, vulnerabilities | read, search | Security review |
| `@sre` | Operations, SLOs, incidents | read, search, execute | Troubleshooting |
| `@reviewer` | Code review, best practices | read, search | PR review |

## Workflow Patterns

### New Feature Implementation
1. `@architect` - Design and plan
2. `@terraform` - Infrastructure changes
3. `@devops` - CI/CD and deployment
4. `@reviewer` - Code review
5. `@security` - Security review
6. `@sre` - Monitoring setup

### Infrastructure Change
1. `@architect` - Review impact
2. `@terraform` - Create/modify modules
3. `@security` - Compliance check
4. `@reviewer` - Code review

### Incident Response
1. `@sre` - Initial triage
2. `@devops` - Implement fix
3. `@security` - If security-related
4. `@reviewer` - Review fix

## Commands Reference

### Build & Test
```bash
terraform init && terraform validate
./scripts/validate-deployment.sh --environment dev
```

### Security Scanning
```bash
tfsec .
gitleaks detect
trivy image <image>
```

### Kubernetes
```bash
kubectl get pods -A | grep -v Running
argocd app list
```

## Agent Selection Guide

| Task Type | Recommended Agent |
|-----------|-------------------|
| "Design a solution for..." | `@architect` |
| "Create Terraform for..." | `@terraform` |
| "Deploy/configure..." | `@devops` |
| "Review this code..." | `@reviewer` |
| "Check security of..." | `@security` |
| "Troubleshoot/debug..." | `@sre` |
| "Setup Golden Path..." | `@platform` |

## Best Practices

1. **Be specific**: Provide context, file paths, and expected outcomes
2. **One task at a time**: Don't combine unrelated requests
3. **Provide examples**: Reference existing patterns in the codebase
4. **Validate outputs**: Always review agent suggestions before applying
```

### Validation
- [ ] AGENTS.md created at repository root
- [ ] All agents documented
- [ ] Workflows clearly described
- [ ] Commands are accurate

---

## Phase 6: Prompts Enhancement

### Objective
Update prompt files with missing best practice elements.

### Tasks

#### 6.1 Add Tools Specification to Prompts

Update each prompt in `.github/prompts/` to include tools:

**`create-service.prompt.md`:**
```yaml
---
name: create-service
description: Create a new microservice using Golden Path templates
mode: agent
tools: ["read", "search", "edit", "execute"]
---
```

**`generate-tests.prompt.md`:**
```yaml
---
name: generate-tests
description: Generate comprehensive test suites for code
mode: agent
tools: ["read", "search", "edit", "execute"]
---
```

**`review-code.prompt.md`:**
```yaml
---
name: review-code
description: Perform comprehensive code review
mode: agent
tools: ["read", "search"]
---
```

#### 6.2 Add Scope and Non-Goals Sections

Add to each prompt after the inputs section:

```markdown
## Scope

✅ **In Scope:**
- [List of included tasks]

🚫 **Out of Scope:**
- [List of excluded tasks]

## Acceptance Criteria

- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]
```

### Validation
- [ ] All prompts have tools specification
- [ ] Scope sections added
- [ ] Acceptance criteria defined

---

## Phase 7: MCP Configuration Enhancement

### Objective
Document and refine MCP server access controls.

### Tasks

#### 7.1 Create MCP Usage Documentation

Create `mcp-servers/USAGE.md`:

```markdown
# MCP Servers Usage Guide

## Server Access by Agent

| Agent | Allowed MCP Servers |
|-------|---------------------|
| architect | azure (read-only queries) |
| platform | azure, kubernetes, helm |
| terraform | azure, terraform |
| devops | azure, github, kubernetes, helm, docker |
| security | azure, defender, entra |
| sre | azure, kubernetes, helm |
| reviewer | github (read-only) |

## Tool Restrictions

### Read-Only Operations
- `az resource list`
- `az resource show`
- `kubectl get`
- `gh pr view`

### Requires Confirmation
- `terraform apply`
- `terraform destroy`
- `kubectl apply`
- `kubectl delete`
- `az resource delete`

## Environment Variables

All MCP servers use environment variables for credentials:
- `AZURE_SUBSCRIPTION_ID`
- `GITHUB_TOKEN`
- `KUBECONFIG`
- `TF_VAR_environment`

Never hardcode credentials in configurations.
```

#### 7.2 Add Read-Only Server Variants

Update `mcp-servers/mcp-config.json` to add read-only variants:

```json
{
  "azure-readonly": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-azure"],
    "description": "Azure CLI read-only operations",
    "env": {
      "AZURE_SUBSCRIPTION_ID": "${AZURE_SUBSCRIPTION_ID}"
    },
    "capabilities": ["az resource list", "az resource show", "az aks show", "az keyvault secret list"]
  }
}
```

### Validation
- [ ] MCP usage documentation created
- [ ] Read-only variants configured
- [ ] Agent-to-MCP mapping documented

---

## Phase 8: Final Validation

### Objective
Validate all changes and ensure conformance.

### Tasks

#### 8.1 Structure Validation Checklist

```bash
# Verify file structure
ls -la .github/
ls -la .github/agents/
ls -la .github/prompts/
ls -la .github/instructions/
ls -la .github/skills/
ls -la mcp-servers/
```

#### 8.2 YAML Validation

```bash
# Validate YAML frontmatter in all files
for file in .github/agents/*.md .github/prompts/*.md .github/skills/*/*.md; do
  echo "Checking $file..."
  head -20 "$file" | grep -A 10 "^---"
done
```

#### 8.3 Conformance Checklist

**Repository Structure:**
- [ ] `.github/copilot-instructions.md` present
- [ ] `.github/instructions/*.instructions.md` with applyTo
- [ ] `.github/agents/*.agent.md` with standard frontmatter
- [ ] `.github/skills/*/SKILL.md` created
- [ ] `.github/prompts/*.prompt.md` enhanced
- [ ] `AGENTS.md` at repository root
- [ ] `mcp-servers/USAGE.md` created

**Agent Configuration:**
- [ ] All agents have `tools` array
- [ ] All agents have `infer` property
- [ ] All agents have Boundaries section
- [ ] Workflow agents have handoffs

**Documentation:**
- [ ] Agent playbook complete
- [ ] MCP usage documented
- [ ] Skills documented

---

## Execution Order

1. **Phase 1**: Agent Frontmatter (30 min)
2. **Phase 2**: Three-Tier Boundaries (45 min)
3. **Phase 3**: Skills Creation (60 min)
4. **Phase 4**: Handoffs Configuration (30 min)
5. **Phase 5**: AGENTS.md Creation (30 min)
6. **Phase 6**: Prompts Enhancement (30 min)
7. **Phase 7**: MCP Documentation (30 min)
8. **Phase 8**: Final Validation (15 min)

**Total Estimated Time:** 4.5 hours

---

## Success Criteria

- All agents follow standard frontmatter format
- Three-tier boundaries implemented in all agents
- Skills properly documented in `.github/skills/`
- Agent handoffs configured for workflows
- AGENTS.md serves as comprehensive playbook
- MCP server usage documented and controlled
- Target conformance: 98%
