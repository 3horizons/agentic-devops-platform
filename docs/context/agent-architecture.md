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

### Workflow Agents (23 Total)

Located in `agents/` with specifications organized by horizon:

#### H1 Foundation (8 Agents)

| Agent | File | Dependencies |
|-------|------|--------------|
| Infrastructure | `h1-foundation/infrastructure-agent.md` | Base module, no deps |
| Networking | `h1-foundation/networking-agent.md` | Infrastructure |
| Security | `h1-foundation/security-agent.md` | Networking |
| Container Registry | `h1-foundation/container-registry-agent.md` | Security |
| Database | `h1-foundation/database-agent.md` | Networking, Security |
| Defender Cloud | `h1-foundation/defender-cloud-agent.md` | Infrastructure |
| ARO Platform | `h1-foundation/aro-platform-agent.md` | Networking, Security (alt to AKS) |
| Purview Governance | `h1-foundation/purview-governance-agent.md` | Infrastructure |

#### H2 Enhancement (5 Agents)

| Agent | File | Dependencies |
|-------|------|--------------|
| GitOps | `h2-enhancement/gitops-agent.md` | H1 Foundation complete |
| Observability | `h2-enhancement/observability-agent.md` | GitOps |
| RHDH Portal | `h2-enhancement/rhdh-portal-agent.md` | GitOps |
| Golden Paths | `h2-enhancement/golden-paths-agent.md` | RHDH Portal |
| GitHub Runners | `h2-enhancement/github-runners-agent.md` | Container Registry |

#### H3 Innovation (4 Agents)

| Agent | File | Dependencies |
|-------|------|--------------|
| AI Foundry | `h3-innovation/ai-foundry-agent.md` | H2 Enhancement complete |
| MLOps Pipeline | `h3-innovation/mlops-pipeline-agent.md` | AI Foundry |
| SRE Agent Setup | `h3-innovation/sre-agent-setup.md` | Observability, AI Foundry |
| Multi-Agent Setup | `h3-innovation/multi-agent-setup.md` | All H3 agents |

#### Cross-Cutting (6 Agents)

| Agent | File | Dependencies |
|-------|------|--------------|
| Validation | `cross-cutting/validation-agent.md` | None (runs anytime) |
| Migration | `cross-cutting/migration-agent.md` | None (standalone) |
| Rollback | `cross-cutting/rollback-agent.md` | None (emergency use) |
| Cost Optimization | `cross-cutting/cost-optimization-agent.md` | Infrastructure |
| GitHub App | `cross-cutting/github-app-agent.md` | None (setup task) |
| Identity Federation | `cross-cutting/identity-federation-agent.md` | None (setup task) |

---

## Skills System

Skills provide domain-specific knowledge and command patterns for agents.

### Available Skills (7 Total)

Located in `.github/skills/`:

| Skill | File | Commands |
|-------|------|----------|
| Azure CLI | `azure-cli/SKILL.md` | `az aks`, `az acr`, `az keyvault`, `az network` |
| Terraform CLI | `terraform-cli/SKILL.md` | `terraform init`, `plan`, `apply`, `destroy` |
| Kubectl CLI | `kubectl-cli/SKILL.md` | `kubectl get`, `apply`, `delete`, `logs` |
| ArgoCD CLI | `argocd-cli/SKILL.md` | `argocd app sync`, `argocd app get` |
| Helm CLI | `helm-cli/SKILL.md` | `helm install`, `upgrade`, `list` |
| GitHub CLI | `github-cli/SKILL.md` | `gh repo`, `gh issue`, `gh pr`, `gh workflow` |
| Validation Scripts | `validation-scripts/SKILL.md` | Deployment validation patterns |

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
