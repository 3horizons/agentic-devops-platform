# Copilot Integration

GitHub Copilot is deeply integrated into the Three Horizons platform, providing AI-assisted code generation, **19 specialized chat agents**, **4 chat modes**, **10 reusable prompts**, **19 operational skills**, and usage analytics through Engineering Intelligence dashboards.

---

## GitHub Copilot Setup

### Organization-Level Configuration

1. Enable GitHub Copilot Business or Enterprise for your GitHub organization
2. Assign Copilot seats to developers via GitHub organization settings
3. Configure Copilot policies (allow/block suggestions from public code)
4. Enable Copilot Chat in IDE settings (VS Code, JetBrains, Neovim)

### IDE Configuration

Copilot works in any supported IDE. For the best experience with the Three Horizons agents:

- **VS Code** (recommended): Install the GitHub Copilot and GitHub Copilot Chat extensions. The `.github/agents/` and `.github/chatmodes/` directories are automatically loaded.
- **JetBrains**: Install the GitHub Copilot plugin from the marketplace
- **CLI**: Use the `gh copilot` command for terminal-based assistance

```bash
# Verify Copilot CLI is available
gh copilot --version

# Get a code explanation
gh copilot explain "kubectl get pods -A --field-selector=status.phase=Pending"

# Get a command suggestion
gh copilot suggest "scale AKS node pool to 5 nodes"
```

---

## Copilot Chat Agents (19)

The platform provides 19 specialized Copilot Chat agents in `.github/agents/`. Each agent is defined in a `.agent.md` file with YAML frontmatter specifying `tools`, `infer`, `skills`, `handoffs`, and a three-tier boundary system.

### Agent Catalog

| Agent | Invoke With | Domain |
| ----- | ----------- | ------ |
| `@architect` | `@architect Design a microservice` | System architecture, AI Foundry, multi-agent design |
| `@platform` | `@platform Register a Golden Path` | RHDH portal, IDP, developer experience |
| `@devops` | `@devops Set up GitOps` | CI/CD, pipelines, GitOps, MLOps |
| `@sre` | `@sre Create runbook` | Observability, SLOs, incident response |
| `@terraform` | `@terraform Create AKS module` | Infrastructure as Code |
| `@security` | `@security Scan for vulnerabilities` | Compliance, policies, scanning |
| `@reviewer` | `@reviewer Review this PR` | Code review, quality gates |
| `@deploy` | `@deploy Deploy to dev` | End-to-end deployment orchestration |
| `@test` | `@test Generate tests` | Testing, validation, QA |
| `@docs` | `@docs Generate API docs` | Documentation |
| `@onboarding` | `@onboarding Set up new team` | Team onboarding guidance |
| `@template-engineer` | `@template-engineer Create template` | Golden Path / Software Template creation |
| `@context-architect` | `@context-architect Plan changes` | Multi-file change planning, dependency tracing |
| `@github-integration` | `@github-integration Setup GHAS` | GitHub App, org discovery, Actions, Packages |
| `@ado-integration` | `@ado-integration Migrate from ADO` | Azure DevOps PAT, repos, pipelines, boards |
| `@hybrid-scenarios` | `@hybrid-scenarios Scenario A` | GitHub + ADO coexistence (scenarios A/B/C) |
| `@azure-portal-deploy` | `@azure-portal-deploy Provision AKS` | Azure portal AKS, Key Vault, PostgreSQL, ACR |
| `@engineering-intelligence` | `@engineering-intelligence Collect DORA metrics` | DORA metrics, Copilot analytics, GHAS security posture |
| `@rhdh-architect` | `@rhdh-architect Design a custom plugin` | RHDH/Backstage plugin architecture, ADRs |

### Agent Boundary System

Each agent enforces a three-tier boundary model:

| Tier | Policy | Examples |
| ---- | ------ | -------- |
| **ALWAYS** | Safe actions the agent performs without asking | Read files, query APIs, analyze code, generate suggestions |
| **ASK FIRST** | Actions that require explicit user confirmation | Apply Terraform changes, deploy to staging, modify configurations |
| **NEVER** | Forbidden actions the agent will refuse to perform | Delete production namespaces, expose secrets, bypass security policies |

### Agent File Structure

Each agent is defined in `.github/agents/<name>.agent.md`:

```yaml
---
name: sre
description: Site Reliability Engineering agent for observability, SLOs, and incident response
tools:
  - mcp: kubernetes
  - mcp: azure
  - mcp: bash
skills:
  - kubectl-operations
  - prometheus-queries
  - alert-management
handoffs:
  - agent: terraform
    when: Infrastructure changes needed
  - agent: security
    when: Security incident detected
  - agent: platform
    when: RHDH dashboard configuration needed
infer:
  - context: kubernetes
  - context: monitoring
---

# @sre Agent

You are the SRE agent for the Three Horizons platform...

## ALWAYS (Safe Actions)
- Query Prometheus metrics
- Read Kubernetes pod logs
- Check ArgoCD sync status
...

## ASK FIRST (Confirmation Required)
- Scale deployments
- Restart pods
- Modify alert thresholds
...

## NEVER (Forbidden)
- Delete production namespaces
- Access secret values
- Modify RBAC without approval
...
```

---

## Orchestration Flows

Agents are designed to collaborate through handoff patterns. When an agent encounters a task outside its domain, it hands off to the appropriate specialist.

### Key Orchestration Flows

```text
Deployment:   @onboarding --> @architect --> @terraform --> @deploy --> @sre
Security:     @reviewer --> @security --> @devops (remediate) --> @test
Templates:    @platform --> @template-engineer --> @devops --> @security
Multi-file:   Any agent --> @context-architect --> @test --> @docs
Hybrid:       @github-integration + @ado-integration --> @hybrid-scenarios --> @deploy
Intelligence: @engineering-intelligence --> @platform (RHDH dashboard) --> @sre (SLO)
RHDH Portal:  @rhdh-architect --> @platform --> @deploy --> @sre
```

### Handoff Example

When you ask `@deploy` to deploy a new service:

1. `@deploy` checks if infrastructure exists; if not, hands off to `@terraform`
2. `@terraform` creates the required Azure resources and hands back to `@deploy`
3. `@deploy` configures ArgoCD applications and triggers the deployment
4. `@deploy` hands off to `@sre` for monitoring and health verification
5. `@sre` configures alerts and confirms the service is healthy

---

## Chat Modes (4)

Chat modes provide persistent context for entire conversations. Activate a mode by selecting it in the Copilot Chat panel.

| Mode | File | Focus |
| ---- | ---- | ----- |
| **Architect** | `.github/chatmodes/architect.chatmode.md` | System design, infrastructure planning, technology selection |
| **Reviewer** | `.github/chatmodes/reviewer.chatmode.md` | Code review, best practices, quality assessment |
| **SRE** | `.github/chatmodes/sre.chatmode.md` | Operational health, incident analysis, SLO tracking |
| **Engineering Intelligence** | `.github/chatmodes/engineering-intelligence.chatmode.md` | DORA metrics, developer productivity, security posture |

### Using Chat Modes

Chat modes set the context for the entire conversation. Unlike agents (which are invoked per-message), a chat mode applies to all messages in the session:

```text
[Architect Mode]
User: I need to design a new event-driven microservice
Copilot: Based on the Three Horizons architecture, I recommend...
         (responds with architecture-focused guidance)

[SRE Mode]
User: What is the current error budget for the RHDH portal?
Copilot: Let me check the SLO burn rates...
         (responds with operational metrics focus)
```

---

## Reusable Prompts (10)

Reusable prompts in `.github/prompts/` provide structured templates for common tasks. Invoke them with the `/` prefix in Copilot Chat.

| Prompt | File | Purpose |
| ------ | ---- | ------- |
| `/deploy-platform` | `deploy-platform.prompt.md` | End-to-end platform deployment guide |
| `/create-service` | `create-service.prompt.md` | Create a new service from a Golden Path template |
| `/review-code` | `review-code.prompt.md` | Structured code review with quality checks |
| `/generate-tests` | `generate-tests.prompt.md` | Generate unit and integration tests |
| `/generate-docs` | `generate-docs.prompt.md` | Generate API documentation and TechDocs |
| `/deploy-service` | `deploy-service.prompt.md` | Deploy a service to a specific environment |
| `/troubleshoot-incident` | `troubleshoot-incident.prompt.md` | Structured incident investigation |
| `/collect-metrics` | `collect-metrics.prompt.md` | Collect Engineering Intelligence metrics |
| `/generate-dashboard` | `generate-dashboard.prompt.md` | Generate Grafana dashboard JSON |
| `/audit-security-posture` | `audit-security-posture.prompt.md` | Audit GHAS security posture |

### Using Prompts

```text
User: /deploy-service
Copilot: I'll help you deploy a service. Please provide:
         1. Service name
         2. Target environment (dev/staging/prod)
         3. Image tag or Git SHA
         ...
```

---

## Operational Skills (19)

Skills in `.github/skills/` are reusable CLI operation sequences that agents can invoke. Each skill encapsulates a common operational pattern.

Skills cover operations including:

- `kubectl` operations (get, describe, logs, exec)
- Helm chart management (install, upgrade, rollback)
- Terraform workflow (init, plan, apply)
- Azure CLI operations (resource management, identity)
- GitHub CLI operations (PR, issue, workflow management)
- Prometheus query patterns
- ArgoCD sync and rollback
- Certificate management
- Secret rotation
- Health check verification

---

## Copilot Metrics and Analytics

### Metrics Collection

The Engineering Intelligence system collects Copilot usage metrics every 6 hours via the `engineering-intelligence.yml` workflow.

```bash
# Manual collection
./scripts/engineering-intelligence/collect-copilot-metrics.sh
```

### Tracked Metrics

| Metric | API Endpoint | Description |
| ------ | ------------ | ----------- |
| Acceptance Rate | `/orgs/{org}/copilot/metrics` | Percentage of suggestions accepted |
| Lines Suggested | `/orgs/{org}/copilot/metrics` | Total lines of code suggested |
| Lines Accepted | `/orgs/{org}/copilot/metrics` | Lines accepted from suggestions |
| Active Users | `/orgs/{org}/copilot/metrics` | Developers actively using Copilot |
| Seat Utilization | `/orgs/{org}/copilot/billing` | Percentage of assigned seats used |
| Language Breakdown | `/orgs/{org}/copilot/metrics` | Acceptance rate per language |
| Editor Breakdown | `/orgs/{org}/copilot/metrics` | Usage per IDE (VS Code, JetBrains, etc.) |

### RHDH Copilot Metrics Plugin

Copilot metrics are displayed in the RHDH portal through a dedicated Engineering Intelligence plugin tab. The plugin fetches data via the `/github-copilot` proxy endpoint configured in `app-config-rhdh.yaml`:

```yaml
proxy:
  endpoints:
    '/github-copilot':
      target: https://api.github.com
      headers:
        Authorization: Bearer ${GITHUB_COPILOT_TOKEN}
        Accept: application/vnd.github+json
        X-GitHub-Api-Version: "2022-11-28"
      changeOrigin: true
      allowedMethods:
        - GET
```

### Viewing Metrics

Copilot metrics are available through:

1. **RHDH Dashboard** -- Engineering Intelligence plugin tab in the developer portal
2. **Grafana** -- Dedicated Copilot analytics panels on the Engineering Intelligence dashboard
3. **GitHub API** -- Raw metrics via `gh api /orgs/{org}/copilot/usage`
4. **GitHub UI** -- Organization settings > Copilot > Usage

---

## Agent Validation

Agent specifications are validated automatically by the `validate-agents.yml` GitHub Actions workflow whenever files in `.github/agents/` are modified.

Validation checks:

- YAML frontmatter is valid and contains required fields
- All referenced MCP servers exist in `mcp-config.json`
- Handoff targets reference existing agents
- Boundary tiers (ALWAYS/ASK FIRST/NEVER) are defined
- Skills reference existing skill definitions

Run validation locally:

```bash
./scripts/validate-agents.sh
```

---

## Best Practices

### For Developers

- **Use agents for domain-specific tasks** -- Each agent has specialized knowledge and boundaries; `@terraform` for IaC, `@sre` for operations, `@security` for compliance
- **Leverage handoffs** -- Let agents delegate to specialists instead of trying one agent for everything
- **Review all suggestions** -- Always review Copilot suggestions before accepting, especially for security-sensitive code
- **Provide context** -- Include relevant file paths and requirements in your prompts
- **Use chat modes** -- Switch to the appropriate mode for extended conversations

### For Platform Administrators

- **Monitor seat utilization** -- Reassign unused seats to maximize ROI
- **Track acceptance rates** -- Low rates may indicate need for training or better prompts
- **Review language breakdown** -- Identify which languages benefit most from Copilot
- **Audit agent usage** -- Ensure agents are being used within their defined boundaries
- **Update agent specs** -- Keep agent knowledge current as the platform evolves
