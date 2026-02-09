# Agent System — Three Horizons Accelerator

## Overview

The Three Horizons Accelerator uses **GitHub Copilot Chat Agents** (v2) — a role-based AI assistant system that operates directly within VS Code / GitHub Copilot Chat. These agents replace the legacy infrastructure-specific agents (v1) with a streamlined set of 10 role-based agents.

## Architecture

```text
.github/
├── agents/          # 10 role-based chat agents (.agent.md)
├── chatmodes/       # 3 chat modes (.chatmode.md)
├── instructions/    # 3 code-generation instructions (.instructions.md)
├── prompts/         # 6 reusable prompts (.prompt.md)
├── skills/          # 17 operational skill sets
└── ISSUE_TEMPLATE/  # 28 issue templates
```

## Chat Agents (v2)

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

### How to Use

In VS Code with GitHub Copilot Chat, mention an agent by name:

```text
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
| Create Service | [create-service.prompt.md](.github/prompts/create-service.prompt.md) | Scaffold a new microservice |
| Deploy Service | [deploy-service.prompt.md](.github/prompts/deploy-service.prompt.md) | Deploy a service to AKS/ARO |
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

The 17 skills in [.github/skills/](.github/skills/) provide domain-specific knowledge that agents can reference:

| Skill | Description |
|-------|-------------|
| `ai-foundry-operations` | Azure AI Foundry and OpenAI operations |
| `argocd-cli` | ArgoCD CLI for GitOps workflows |
| `aro-deployment` | Azure Red Hat OpenShift deployment |
| `azure-cli` | Azure CLI resource management |
| `azure-infrastructure` | Azure infrastructure patterns |
| `database-management` | Database ops and health monitoring |
| `github-cli` | GitHub CLI for repos and workflows |
| `helm-cli` | Helm CLI for Kubernetes packages |
| `kubectl-cli` | Kubernetes CLI for AKS/ARO |
| `mcp-cli` | Model Context Protocol server reference |
| `observability-stack` | Prometheus, Grafana, observability |
| `oc-cli` | OpenShift CLI for ARO |
| `openshift-operations` | OpenShift admin operations |
| `prerequisites` | CLI tool validation and setup |
| `rhdh-portal` | Red Hat Developer Hub portal |
| `terraform-cli` | Terraform CLI for Azure infra |
| `validation-scripts` | Validation scripts for deployments |

## Legacy Agent System (v1)

The original v1 agent system contained 23 infrastructure-specific agents organized by horizon. These have been archived to [docs/legacy/agents_v1/](docs/legacy/agents_v1/) for reference.

| Resource | Link |
|----------|------|
| V1 Agent Index | [docs/legacy/agents_v1/README.md](docs/legacy/agents_v1/README.md) |
| V1 Full Index | [docs/legacy/agents_v1/INDEX.md](docs/legacy/agents_v1/INDEX.md) |
| Deployment Sequence | [docs/legacy/agents_v1/DEPLOYMENT_SEQUENCE.md](docs/legacy/agents_v1/DEPLOYMENT_SEQUENCE.md) |
| MCP Servers Guide | [docs/legacy/agents_v1/MCP_SERVERS_GUIDE.md](docs/legacy/agents_v1/MCP_SERVERS_GUIDE.md) |
| Dependency Graph | [docs/legacy/agents_v1/DEPENDENCY_GRAPH.md](docs/legacy/agents_v1/DEPENDENCY_GRAPH.md) |
| Terraform Module Ref | [docs/legacy/agents_v1/TERRAFORM_MODULES_REFERENCE.md](docs/legacy/agents_v1/TERRAFORM_MODULES_REFERENCE.md) |

### V1 → V2 Agent Mapping

| V1 Agent (legacy) | V2 Agent |
|-------------------|----------|
| infrastructure-agent | @terraform |
| networking-agent | @terraform |
| security-agent | @security |
| database-agent | @terraform |
| container-registry-agent | @devops |
| defender-cloud-agent | @security |
| aro-platform-agent | @platform |
| purview-governance-agent | @security |
| gitops-agent | @devops |
| observability-agent | @sre |
| rhdh-portal-agent | @platform |
| golden-paths-agent | @devops |
| github-runners-agent | @devops |
| ai-foundry-agent | @architect |
| mlops-pipeline-agent | @devops |
| sre-agent | @sre |
| multi-agent | @architect |
| validation-agent | @test |
| migration-agent | @devops |
| rollback-agent | @sre |
| cost-optimization-agent | @architect |
| github-app-agent | @devops |
| identity-federation-agent | @security |

## Related Documentation

- [Deployment Guide](docs/guides/DEPLOYMENT_GUIDE.md)
- [Architecture Guide](docs/guides/ARCHITECTURE_GUIDE.md)
- [MCP Servers Usage](mcp-servers/USAGE.md)
- [Golden Paths](golden-paths/README.md)
- [Contributing](CONTRIBUTING.md)
