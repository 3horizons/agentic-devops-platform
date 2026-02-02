# Agent Architecture

> AI agent design, execution modes, orchestration patterns, and integration guidelines.

## Overview

The Three Horizons Accelerator uses **23 AI agents** for intelligent deployment orchestration. These agents are organized by horizon and designed to work both independently and as part of coordinated workflows.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         AGENT ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐     │
│  │  Chat Agents    │    │ Workflow Agents │    │   MCP Servers   │     │
│  │  (14 agents)    │◄──►│  (23 specs)     │◄──►│  (15 servers)   │     │
│  │  .github/agents │    │  agents/        │    │  mcp-servers/   │     │
│  └─────────────────┘    └─────────────────┘    └─────────────────┘     │
│          │                      │                      │               │
│          ▼                      ▼                      ▼               │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │                         CLI SKILLS                               │   │
│  │   azure-cli │ terraform-cli │ kubectl-cli │ argocd-cli │ helm   │   │
│  └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Execution Modes

The accelerator supports two primary execution modes:

### 1. Agent Mode (Interactive Chat)

| Aspect | Description |
|--------|-------------|
| **Trigger** | User invokes agent in GitHub Copilot Chat |
| **Location** | `.github/agents/*.agent.md` |
| **Interaction** | Conversational, multi-turn |
| **Actions** | Execute commands, modify files, provide guidance |

**Example Usage:**
```
User: @deployment Deploy H1 Foundation to dev environment
Agent: I'll deploy the H1 Foundation. Let me validate prerequisites first...
```

### 2. Coding Agent Mode (Issue-Driven)

| Aspect | Description |
|--------|-------------|
| **Trigger** | Assign @copilot to a GitHub Issue |
| **Location** | `.github/ISSUE_TEMPLATE/*.yml` |
| **Interaction** | Asynchronous, structured input |
| **Actions** | Create Pull Request with implementation |

**Example Flow:**
1. User creates issue using template
2. Assigns `@copilot` to issue
3. Copilot creates branch and PR
4. User reviews and merges

---

## Agent Inventory

### Chat Agents (14 Total)

Located in `.github/agents/`:

| Agent | File | Purpose |
|-------|------|---------|
| Architect | `architect.agent.md` | System design and architecture decisions |
| DevOps | `devops.agent.md` | CI/CD pipeline configuration |
| Platform | `platform.agent.md` | Platform engineering tasks |
| Deployment | `deployment.agent.md` | Three Horizons deployment orchestration |
| Terraform | `terraform.agent.md` | Infrastructure as Code operations |
| Security | `security.agent.md` | Security configuration and compliance |
| Observability | `observability.agent.md` | Monitoring and alerting setup |
| SRE | `sre.agent.md` | Site reliability engineering |
| Reviewer | `reviewer.agent.md` | Code review assistance |
| Documentation | `documentation.agent.md` | Documentation generation |
| AI Foundry | `ai-foundry.agent.md` | Azure AI integration |
| GitOps | `gitops.agent.md` | ArgoCD and GitOps patterns |
| Cost | `cost.agent.md` | Cost optimization |
| Migration | `migration.agent.md` | ADO to GitHub migration |

### All Agents (30 Total)

All agents are located in `.github/agents/` with a flat structure:

| Agent | File | Purpose |
|-------|------|---------|
| AI Foundry | `ai-foundry.agent.md` | Azure AI Foundry, models, RAG |
| Architect | `architect.agent.md` | System architecture design |
| ARO | `aro.agent.md` | Azure Red Hat OpenShift |
| Container Registry | `container-registry.agent.md` | ACR deployment |
| Cost | `cost.agent.md` | FinOps, cost optimization |
| Database | `database.agent.md` | PostgreSQL/Cosmos DB |
| Defender Cloud | `defender-cloud.agent.md` | Microsoft Defender |
| Deployment | `deployment.agent.md` | Interactive deployment |
| DevOps | `devops.agent.md` | CI/CD pipelines |
| Documentation | `documentation.agent.md` | Doc creation/updates |
| GitHub App | `github-app.agent.md` | GitHub App config |
| GitOps | `gitops.agent.md` | ArgoCD operations |
| Golden Paths | `golden-paths.agent.md` | Software templates |
| Governance | `governance.agent.md` | Purview compliance |
| Identity | `identity.agent.md` | Workload identity |
| Infrastructure | `infrastructure.agent.md` | Core infrastructure |
| Migration | `migration.agent.md` | ADO to GitHub |
| MLOps Pipeline | `mlops-pipeline.agent.md` | ML pipelines |
| Multi-Agent | `multi-agent.agent.md` | AI agent orchestration |
| Networking | `networking.agent.md` | VNet/NSG/endpoints |
| Observability | `observability.agent.md` | Monitoring/alerting |
| Platform | `platform.agent.md` | Platform engineering |
| Reviewer | `reviewer.agent.md` | Code/infra review |
| RHDH | `rhdh.agent.md` | Developer Hub |
| Rollback | `rollback.agent.md` | Deployment rollback |
| Runners | `runners.agent.md` | GitHub runners |
| Security | `security.agent.md` | Security scanning |
| SRE | `sre.agent.md` | Site reliability |
| Terraform | `terraform.agent.md` | Infrastructure as Code |
| Validation | `validation.agent.md` | Deployment validation |

---

## Skills System

Skills provide domain-specific knowledge and command patterns for agents.

### Available Skills (17 Total)

Located in `.github/skills/`:

| Skill | File | Purpose |
|-------|------|---------|
| AI Foundry Operations | `ai-foundry-operations/SKILL.md` | Azure AI Foundry deployment |
| ArgoCD CLI | `argocd-cli/SKILL.md` | GitOps continuous delivery |
| ARO Deployment | `aro-deployment/SKILL.md` | Azure Red Hat OpenShift |
| Azure CLI | `azure-cli/SKILL.md` | Azure resource management |
| Azure Infrastructure | `azure-infrastructure/SKILL.md` | Infrastructure provisioning |
| Database Management | `database-management/SKILL.md` | PostgreSQL/Cosmos DB |
| GitHub CLI | `github-cli/SKILL.md` | Repository/workflow management |
| Helm CLI | `helm-cli/SKILL.md` | Kubernetes package management |
| Kubectl CLI | `kubectl-cli/SKILL.md` | Cluster operations |
| MCP CLI | `mcp-cli/SKILL.md` | Model Context Protocol |
| OC CLI | `oc-cli/SKILL.md` | OpenShift CLI |
| Observability Stack | `observability-stack/SKILL.md` | Monitoring setup |
| OpenShift Operations | `openshift-operations/SKILL.md` | ARO operations |
| Prerequisites | `prerequisites/SKILL.md` | Tool validation |
| RHDH Portal | `rhdh-portal/SKILL.md` | Developer Hub |
| Terraform CLI | `terraform-cli/SKILL.md` | Infrastructure as Code |
| Validation Scripts | `validation-scripts/SKILL.md` | Deployment validation |

### Skill Structure

```markdown
# Skill Name

## Description
What the skill provides and when to use it.

## Commands
### Command Category
- `command pattern` - Description and examples

## Parameters
Required and optional parameters for each command.

## Examples
Real-world usage examples with expected output.

## Error Handling
Common errors and recovery procedures.
```

---

## MCP Servers

Model Context Protocol (MCP) servers provide tool capabilities to agents.

### Configured Servers (15 Total)

Located in `mcp-servers/mcp-config.json`:

| Server | Capabilities |
|--------|-------------|
| azure | `az aks`, `az acr`, `az keyvault`, `az network` |
| github | `gh repo`, `gh issue`, `gh pr`, `gh workflow` |
| terraform | `terraform init`, `plan`, `apply`, `destroy` |
| kubernetes | `kubectl get`, `apply`, `delete`, `logs` |
| helm | `helm install`, `upgrade`, `list` |
| docker | `docker build`, `push`, `pull` |
| git | `git clone`, `commit`, `push`, `branch` |
| bash | Shell command execution |
| filesystem | File read/write operations |
| defender | Defender for Cloud APIs |
| purview | Microsoft Purview APIs |
| entra | Entra ID (Azure AD) operations |
| aro | OpenShift-specific commands |
| copilot | Copilot API integration |
| openshift | `oc` command execution |

---

## Agent Design Patterns

### 1. Task-Based Execution

Agents follow a deterministic task-based pattern:

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Validate    │───►│   Execute    │───►│   Verify     │
│  Preconditions│    │   Tasks      │    │   Results    │
└──────────────┘    └──────────────┘    └──────────────┘
```

### 2. Skill-Driven Actions

Agents invoke skills for domain-specific operations:

```yaml
# Agent task definition
- task: Deploy AKS Cluster
  skill: terraform-cli
  commands:
    - terraform init
    - terraform plan -var-file=environments/dev.tfvars
    - terraform apply -auto-approve
  validation:
    - terraform output -json
```

### 3. Dependency-Aware Sequencing

Agents validate dependencies before execution:

```yaml
# Dependency check
dependencies:
  required:
    - infrastructure-agent: completed
    - networking-agent: completed
  optional:
    - defender-cloud-agent: available
```

### 4. Error Recovery

Agents implement structured error handling:

```yaml
error_handling:
  on_failure:
    - log_error
    - notify_team
    - trigger_rollback (if configured)
  retry_policy:
    max_attempts: 3
    backoff: exponential
```

---

## Issue Template Integration

GitHub Issue templates provide structured input for Coding Agent mode.

### Template Categories (28 Total)

| Category | Templates | Purpose |
|----------|-----------|---------|
| Infrastructure | 6 | AKS, ARO, networking, security |
| Deployment | 5 | Environment deployments |
| Database | 4 | PostgreSQL, Redis, Cosmos |
| Security | 3 | Key Vault, identities, policies |
| Observability | 3 | Prometheus, Grafana, alerts |
| AI Foundry | 4 | AI Foundry, OpenAI, agents |
| Cross-Cutting | 3 | Migration, validation, cost |

### Template Structure

```yaml
name: Deploy H1 Foundation
description: Deploy foundation infrastructure for Three Horizons
assignees:
  - copilot
body:
  - type: dropdown
    id: environment
    attributes:
      label: Target Environment
      options:
        - dev
        - staging
        - production
  - type: dropdown
    id: platform
    attributes:
      label: Kubernetes Platform
      options:
        - AKS
        - ARO
  - type: checkboxes
    id: components
    attributes:
      label: Components to Deploy
      options:
        - label: Networking (VNet, Subnets, NSGs)
        - label: Security (Key Vault, Managed Identities)
        - label: Container Registry (ACR)
        - label: Kubernetes Cluster
```

---

## Orchestration Flow

### Deployment Sequence

```
┌─────────────────────────────────────────────────────────────────────────┐
│                      DEPLOYMENT ORCHESTRATION                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌─────────────┐                                                        │
│  │ Validation  │  ← validation-agent runs first                         │
│  │   Agent     │                                                        │
│  └──────┬──────┘                                                        │
│         │                                                                │
│  ═══════╪═══════════════════ H1 FOUNDATION ══════════════════════════  │
│         │                                                                │
│  ┌──────▼──────┐    ┌─────────────┐    ┌─────────────┐                 │
│  │Infrastructure│───►│  Networking │───►│  Security   │                 │
│  │    Agent    │    │    Agent    │    │    Agent    │                 │
│  └─────────────┘    └──────┬──────┘    └──────┬──────┘                 │
│                            │                   │                         │
│                     ┌──────▼──────┐    ┌──────▼──────┐                 │
│                     │  Database   │    │  Container  │                 │
│                     │    Agent    │    │  Registry   │                 │
│                     └─────────────┘    └─────────────┘                 │
│                                                                          │
│  ═══════════════════════════ H2 ENHANCEMENT ════════════════════════   │
│                                                                          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                 │
│  │   GitOps    │───►│Observability│───►│    RHDH     │                 │
│  │    Agent    │    │    Agent    │    │    Agent    │                 │
│  └─────────────┘    └─────────────┘    └──────┬──────┘                 │
│                                               │                          │
│                                        ┌──────▼──────┐                  │
│                                        │Golden Paths │                  │
│                                        │    Agent    │                  │
│                                        └─────────────┘                  │
│                                                                          │
│  ═══════════════════════════ H3 INNOVATION ═════════════════════════   │
│                                                                          │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                 │
│  │ AI Foundry  │───►│   MLOps     │───►│ Multi-Agent │                 │
│  │    Agent    │    │    Agent    │    │    Agent    │                 │
│  └─────────────┘    └─────────────┘    └─────────────┘                 │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Parallel Execution

Certain agents can run in parallel when there are no inter-dependencies:

```
H1 Parallel Groups:
├── Group 1: Infrastructure (must run first)
├── Group 2: Networking, Defender Cloud, Purview (after Group 1)
├── Group 3: Security, Database (after Group 2)
└── Group 4: Container Registry (after Group 3)

H2 Parallel Groups:
├── Group 1: GitOps (must run first after H1)
├── Group 2: Observability, RHDH (after Group 1)
└── Group 3: Golden Paths, GitHub Runners (after Group 2)
```

---

## Best Practices

### Agent Development

1. **Single Responsibility** - Each agent handles one domain
2. **Idempotent Operations** - Safe to re-run without side effects
3. **Explicit Dependencies** - Declare all prerequisites
4. **Validation First** - Check preconditions before execution
5. **Clear Outputs** - Report status and next steps

### Skill Usage

1. **Prefer Skills** - Use skills over raw commands
2. **Parameter Validation** - Validate inputs before execution
3. **Error Context** - Include troubleshooting hints
4. **Version Awareness** - Check tool versions

### MCP Integration

1. **Minimal Permissions** - Request only needed capabilities
2. **Connection Handling** - Graceful reconnection
3. **Context Management** - Clear context between sessions

---

## Related Documentation

- [Dependency Graph](../../agents/DEPENDENCY_GRAPH.md) - Visual dependencies
- [Deployment Sequence](../../agents/DEPLOYMENT_SEQUENCE.md) - Step-by-step order
- [MCP Servers Guide](../../agents/MCP_SERVERS_GUIDE.md) - Server configuration
- [Agent Index](../../agents/INDEX.md) - Complete catalog

---

**Document Owner:** Platform Engineering Team  
**Last Updated:** February 2026  
**Review Cycle:** Monthly
