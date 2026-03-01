# Agent System — Three Horizons Accelerator

## Overview

The Three Horizons Accelerator uses **GitHub Copilot Chat Agents** — a role-based AI assistant system that operates directly within VS Code / GitHub Copilot Chat. The platform includes 19 specialized agents for interactive development assistance.

## Architecture

```text
.github/
├── agents/          # 17 role-based chat agents (.agent.md)
├── chatmodes/       # 3 chat modes (.chatmode.md)
├── instructions/    # 3 code-generation instructions (.instructions.md)
├── prompts/         # 7 reusable prompts (.prompt.md)
├── skills/          # 15 operational skill sets
└── ISSUE_TEMPLATE/  # 27 issue templates
```

## Chat Agents

| Agent | File | Role |
|-------|------|------|
| **Architect** | [architect.agent.md](.github/agents/architect.agent.md) | System architecture, AI Foundry, multi-agent design |
| **DevOps** | [devops.agent.md](.github/agents/devops.agent.md) | CI/CD, GitOps, MLOps, Golden Paths, pipelines |
| **Docs** | [docs.agent.md](.github/agents/docs.agent.md) | Documentation generation and maintenance |
| **Onboarding** | [onboarding.agent.md](.github/agents/onboarding.agent.md) | New team member onboarding and guidance |
| **Platform** | [platform.agent.md](.github/agents/platform.agent.md) | RHDH portal, platform services, developer experience |
| **Reviewer** | [reviewer.agent.md](.github/agents/reviewer.agent.md) | Code review, PR analysis, quality checks |
| **Security** | [security.agent.md](.github/agents/security.agent.md) | Security policies, scanning, compliance |
| **SRE** | [sre.agent.md](.github/agents/sre.agent.md) | Reliability engineering, incident response, monitoring |
| **Terraform** | [terraform.agent.md](.github/agents/terraform.agent.md) | Infrastructure as Code, Terraform modules |
| **Test** | [test.agent.md](.github/agents/test.agent.md) | Test generation, validation, quality assurance |
| **Deploy** | [deploy.agent.md](.github/agents/deploy.agent.md) | Deployment orchestration, end-to-end platform deployment |
| **Azure Portal Deploy** | [azure-portal-deploy.agent.md](.github/agents/azure-portal-deploy.agent.md) | Azure AKS provisioning, Key Vault, PostgreSQL, ACR, Helm |
| **GitHub Integration** | [github-integration.agent.md](.github/agents/github-integration.agent.md) | GitHub App, org discovery, GHAS, Actions, Packages, supply chain |
| **ADO Integration** | [ado-integration.agent.md](.github/agents/ado-integration.agent.md) | Azure DevOps PAT, repos, pipelines, boards, Copilot Standalone |
| **Hybrid Scenarios** | [hybrid-scenarios.agent.md](.github/agents/hybrid-scenarios.agent.md) | GitHub + ADO coexistence scenarios A/B/C, dual auth, hybrid templates |
| **Template Engineer** | [template-engineer.agent.md](.github/agents/template-engineer.agent.md) | Software Template expert for RHDH, Golden Path creation, devcontainer configs |
| **Context Architect** | [context-architect.agent.md](.github/agents/context-architect.agent.md) | Multi-file change planning/execution, dependency tracing, codebase context mapping |
| **Engineering Intelligence** | [engineering-intelligence.agent.md](.github/agents/engineering-intelligence.agent.md) | DORA metrics, Copilot analytics, GHAS security posture, developer productivity |
| **RHDH Architect** | [rhdh-architect.agent.md](.github/agents/rhdh-architect.agent.md) | RHDH/Backstage plugin architecture, frontend wiring, component specs, ADRs |

### How to Use

In VS Code with GitHub Copilot Chat, mention an agent by name:

```text
@deploy Deploy the platform to dev environment
@architect Design a microservice architecture for order processing
@devops Set up GitOps deployment with ArgoCD
@terraform Create a new AKS module with private networking
@security Review security posture for the platform
@sre Create an incident response runbook
```

## Chat Modes

| Mode | File | Purpose |
|------|------|---------|
| **Architect** | [architect.chatmode.md](.github/chatmodes/architect.chatmode.md) | Architecture design sessions |
| **Reviewer** | [reviewer.chatmode.md](.github/chatmodes/reviewer.chatmode.md) | Code review sessions |
| **SRE** | [sre.chatmode.md](.github/chatmodes/sre.chatmode.md) | Operations and incident response |

## Prompts

| Prompt | File | Purpose |
|--------|------|---------|
| **Deploy Platform** | [deploy-platform.prompt.md](.github/prompts/deploy-platform.prompt.md) | **Deploy the Three Horizons platform** |
| Create Service | [create-service.prompt.md](.github/prompts/create-service.prompt.md) | Scaffold a new microservice |
| Deploy Service | [deploy-service.prompt.md](.github/prompts/deploy-service.prompt.md) | Deploy a service to AKS |
| Generate Docs | [generate-docs.prompt.md](.github/prompts/generate-docs.prompt.md) | Generate documentation |
| Generate Tests | [generate-tests.prompt.md](.github/prompts/generate-tests.prompt.md) | Generate test suites |
| Review Code | [review-code.prompt.md](.github/prompts/review-code.prompt.md) | Perform code review |
| Troubleshoot | [troubleshoot-incident.prompt.md](.github/prompts/troubleshoot-incident.prompt.md) | Troubleshoot incidents |

## Instructions

| Instruction | File | Applies To |
|-------------|------|------------|
| Kubernetes | [kubernetes.instructions.md](.github/instructions/kubernetes.instructions.md) | `*.yaml`, `*.yml`, `kubernetes/**`, `helm/**` |
| Python | [python.instructions.md](.github/instructions/python.instructions.md) | `*.py`, `python/**` |
| Terraform | [terraform.instructions.md](.github/instructions/terraform.instructions.md) | `*.tf`, `terraform/**`, `*.tfvars` |

## Skills

The 15 skills in [.github/skills/](.github/skills/) provide domain-specific knowledge that agents can reference:

| Skill | Description |
|-------|-------------|
| `ai-foundry-operations` | Azure AI Foundry and OpenAI operations |
| `argocd-cli` | ArgoCD CLI for GitOps workflows |
| `azure-cli` | Azure CLI resource management |
| `azure-infrastructure` | Azure infrastructure patterns |
| `codespaces-golden-paths` | GitHub Codespaces devcontainer configs per Golden Path |
| `database-management` | Database ops and health monitoring |
| `github-cli` | GitHub CLI for repos and workflows |
| `helm-cli` | Helm CLI for Kubernetes packages |
| `kubectl-cli` | Kubernetes CLI for AKS |
| `mcp-cli` | Model Context Protocol server reference |
| `observability-stack` | Prometheus, Grafana, observability |
| `prerequisites` | CLI tool validation and setup |
| `terraform-cli` | Terraform CLI for Azure infra |
| `validation-scripts` | Validation scripts for deployments |
| `deploy-orchestration` | End-to-end platform deployment orchestration |

## Agent Orchestration & Handoffs

All 19 agents are interconnected via YAML `handoffs:` in their frontmatter. Key orchestration flows:

### Deployment Flow
```
@onboarding → @architect → @terraform → @deploy → @sre
                                           ↓
                              @azure-portal-deploy
                              @github-integration
                              @ado-integration
```

### Security Flow
```
@reviewer → @security → @devops (remediate) → @test
                ↓
           @terraform (IaC fixes)
           @sre (incident response)
           @context-architect (multi-file fixes)
```

### Template Flow
```
@platform → @template-engineer → @devops (CI/CD) → @security (review)
                    ↓
              @github-integration
              @ado-integration
              @hybrid-scenarios
```

### Multi-File Change Flow
```
Any agent → @context-architect → @test → @docs
                    ↓
              @terraform (IaC)
              @devops (pipelines)
              @security (review)
              @deploy (deployment)
```

### Hybrid Integration Flow
```
@github-integration + @ado-integration → @hybrid-scenarios → @deploy
```

### RHDH Portal Customization Flow
```
@rhdh-architect → @platform → @deploy → @sre
       ↓
   @template-engineer
   @devops (CI/CD)
   @security (RBAC)
```

### Entry Points (user-invoked)
| Agent | When to use |
|-------|-------------|
| `@onboarding` | First time setup, getting started |
| `@deploy` | Full platform deployment |
| `@architect` | Design decisions, ADRs |
| `@context-architect` | Multi-file codebase changes |

## Related Documentation

- [Deployment Guide](docs/guides/DEPLOYMENT_GUIDE.md)
- [Architecture Guide](docs/guides/ARCHITECTURE_GUIDE.md)
- [MCP Servers Usage](mcp-servers/USAGE.md)
- [Golden Paths](golden-paths/README.md)
- [Contributing](CONTRIBUTING.md)
