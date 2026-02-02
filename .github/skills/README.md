# Skills

> **Location**: `.github/skills/` following
> [awesome-copilot](https://github.com/github/awesome-copilot) best practices

Skills are self-contained folders with instructions and bundled resources
that teach AI agents specialized capabilities. Unlike custom instructions
(which define coding standards), skills enable task-specific workflows
that can include scripts, examples, templates, and reference data.

## Overview

| Skill | Description | Purpose |
|-------|-------------|---------|
| [azure-cli](./azure-cli/) | Azure CLI reference | Azure resource management |
| [terraform-cli](./terraform-cli/) | Terraform CLI reference | Infrastructure as Code |
| [kubectl-cli](./kubectl-cli/) | Kubernetes CLI reference | Cluster management |
| [argocd-cli](./argocd-cli/) | ArgoCD CLI reference | GitOps deployment |
| [helm-cli](./helm-cli/) | Helm CLI reference | Chart management |
| [github-cli](./github-cli/) | GitHub CLI reference | Repository operations |
| [oc-cli](./oc-cli/) | OpenShift CLI reference | OpenShift operations |
| [mcp-cli](./mcp-cli/) | MCP server configuration | AI tool integration |
| [prerequisites](./prerequisites/) | CLI installation guide | Tool setup |
| [validation-scripts](./validation-scripts/) | Validation patterns | Reusable scripts |
| [azure-infrastructure](./azure-infrastructure/) | Azure IaC patterns | Infrastructure design |
| [aro-deployment](./aro-deployment/) | ARO deployment patterns | OpenShift on Azure |
| [openshift-operations](./openshift-operations/) | OpenShift operations | Day-2 operations |
| [database-management](./database-management/) | Database patterns | PostgreSQL/Cosmos |
| [observability-stack](./observability-stack/) | Monitoring patterns | Prometheus/Grafana |
| [ai-foundry-operations](./ai-foundry-operations/) | AI Foundry patterns | Azure AI services |
| [rhdh-portal](./rhdh-portal/) | Developer Hub patterns | Backstage/RHDH |

## Directory Structure

```text
.github/skills/
├── README.md                      # This file
├── azure-cli/                     # Azure CLI reference
├── terraform-cli/                 # Terraform CLI reference
├── kubectl-cli/                   # Kubernetes CLI reference
├── argocd-cli/                    # ArgoCD CLI reference
├── helm-cli/                      # Helm CLI reference
├── github-cli/                    # GitHub CLI reference
├── oc-cli/                        # OpenShift CLI reference
├── mcp-cli/                       # MCP configuration
├── prerequisites/                 # CLI installation guide
├── validation-scripts/            # Validation patterns
├── azure-infrastructure/          # Azure IaC patterns
├── aro-deployment/                # ARO deployment patterns
├── openshift-operations/          # OpenShift operations
├── database-management/           # Database patterns
├── observability-stack/           # Monitoring patterns
├── ai-foundry-operations/         # AI Foundry patterns
└── rhdh-portal/                   # Developer Hub patterns
```

## Progressive Loading Architecture

Skills use three-level loading for efficiency:

| Level            | What's Loaded              | When                             |
| ---------------- | -------------------------- | -------------------------------- |
| 1. Discovery     | `name` and `description`   | Always (lightweight metadata)    |
| 2. Instructions  | Full SKILL.md body         | When request matches description |
| 3. Resources     | Scripts, examples, docs    | Only when Copilot references     |

## Relationship with Agents

```text
┌─────────────────────────────────────────────────────────────┐
│                   .github/agents/                           │
│   (VS Code Chat Agents - *.agent.md files)                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Uses
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Skills                                │
│   (CLI references, command patterns, validation scripts)     │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ Complements
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      agents/ (root)                          │
│   (Detailed agent specifications for accelerator workflows)  │
└─────────────────────────────────────────────────────────────┘
```

- **`.github/agents/`**: VS Code Chat Agents (`*.agent.md`)
- **`.github/skills/`**: CLI references and reusable patterns (`SKILL.md`)
- **`agents/`**: Detailed accelerator workflow specifications

## Adding New Skills

Follow the awesome-copilot agent-skills.instructions.md:

1. Create a folder with the skill name (lowercase, hyphens)
2. Add `SKILL.md` with proper frontmatter:

   ```yaml
   ---
   name: skill-name
   description: >
     Detailed description of WHAT it does, WHEN to use it,
     and relevant KEYWORDS for discovery.
   license: Complete terms in LICENSE.txt
   ---
   ```

3. Add `LICENSE.txt` (Apache 2.0 recommended)
4. Include comprehensive documentation
5. Add bundled resources if needed:
   - `scripts/` - Executable automation
   - `references/` - Documentation for context
   - `assets/` - Static files used as-is
   - `templates/` - Starter code the AI modifies

## Agent to Skills Mapping

### Interactive Agents (24)
| Agent | Primary Skills |
|-------|----------------|
| architect | terraform-cli, azure-cli, kubectl-cli |
| devops | azure-cli, terraform-cli, kubectl-cli, argocd-cli |
| platform | azure-cli, terraform-cli, kubectl-cli, helm-cli |
| ai-foundry | ai-foundry-operations, azure-cli, terraform-cli |
| security | azure-cli, terraform-cli, validation-scripts |
| gitops | argocd-cli, helm-cli, kubectl-cli |
| cost | azure-cli, validation-scripts |
| deployment | terraform-cli, kubectl-cli, argocd-cli |
| documentation | validation-scripts |
| migration | azure-cli, github-cli, terraform-cli |
| observability | observability-stack, helm-cli, kubectl-cli |
| reviewer | terraform-cli, kubectl-cli, validation-scripts |
| sre | kubectl-cli, observability-stack, argocd-cli |
| terraform | terraform-cli, azure-cli, validation-scripts |
| container-registry | azure-cli, terraform-cli, validation-scripts |
| database | database-management, azure-cli, terraform-cli |
| networking | azure-infrastructure, terraform-cli, kubectl-cli |
| governance | azure-cli, terraform-cli, validation-scripts |
| aro | aro-deployment, openshift-operations, oc-cli |
| rhdh | rhdh-portal, helm-cli, kubectl-cli |
| golden-paths | rhdh-portal, github-cli, validation-scripts |
| runners | github-cli, kubectl-cli, helm-cli |
| identity | azure-cli, github-cli, terraform-cli |
| rollback | kubectl-cli, helm-cli, argocd-cli, terraform-cli |

## Related Resources

- [Chat Agents](../agents/) - VS Code Copilot Chat Agents
- [Agent Specifications](../../agents/README.md) - Detailed workflow specs
- [MCP Servers Guide](../../agents/MCP_SERVERS_GUIDE.md) - MCP configuration
- [awesome-copilot](https://github.com/github/awesome-copilot) - Best practices
