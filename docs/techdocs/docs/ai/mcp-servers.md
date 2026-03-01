# MCP Servers

The **Model Context Protocol (MCP)** provides a standardized interface between AI agents and platform tools. The Three Horizons platform deploys **15 MCP servers** that give Copilot agents and Developer Lightspeed safe, controlled access to infrastructure, deployment, and operational tools.

---

## What Is MCP?

MCP is a protocol for AI-tool communication that defines how language models can discover, invoke, and receive results from external tools. Each MCP server exposes a set of tool definitions that agents can call during conversations, enabling them to perform real actions on infrastructure and services while maintaining strict safety boundaries.

Key principles:

- **Standardized interface** -- All tools follow the same request/response pattern
- **Explicit boundaries** -- Every operation is classified as safe, confirmation-required, or forbidden
- **Audit trail** -- All tool invocations are logged
- **Least privilege** -- Servers run with minimum required permissions

---

## Architecture

```text
Copilot Agent / Lightspeed Chat
        |
        v
MCP Client (Agent Runtime)
        |
        v
MCP Server (Tool Provider)
        |
        +--> Azure CLI (az)
        +--> Kubernetes CLI (kubectl)
        +--> Terraform CLI
        +--> Helm CLI
        +--> GitHub CLI (gh)
        +--> Docker CLI
        +--> Git CLI
        +--> Bash Shell
        +--> Filesystem Operations
        +--> RHDH/Backstage API (Streamable HTTP)
```

MCP servers are launched as child processes by the agent runtime using `npx`. The exception is the `backstage` server, which connects to the RHDH API via Streamable HTTP transport.

---

## Available MCP Servers (15)

All servers are configured in `mcp-servers/mcp-config.json`. The access matrix is documented in `mcp-servers/USAGE.md`.

### Infrastructure Servers

| Server | Command | Capabilities | Primary Agents |
| ------ | ------- | ------------ | -------------- |
| **azure** | `npx @anthropic/mcp-azure` | `az resource`, `az aks`, `az acr`, `az keyvault`, `az network`, `az ad`, `az security`, `az purview` | `@terraform`, `@sre`, `@deploy` |
| **terraform** | `npx @anthropic/mcp-terraform` | `terraform init`, `terraform plan`, `terraform apply`, `terraform destroy`, `terraform state` | `@terraform`, `@architect` |
| **kubernetes** | `npx @anthropic/mcp-kubernetes` | `kubectl get`, `kubectl apply`, `kubectl delete`, `kubectl logs`, `kubectl exec`, `kubectl port-forward` | `@sre`, `@deploy`, `@devops` |
| **helm** | `npx @anthropic/mcp-helm` | `helm install`, `helm upgrade`, `helm uninstall`, `helm repo`, `helm search`, `helm template` | `@deploy`, `@platform` |

### Development Servers

| Server | Command | Capabilities | Primary Agents |
| ------ | ------- | ------------ | -------------- |
| **github** | `npx @anthropic/mcp-github` | `gh repo`, `gh secret`, `gh api`, `gh auth`, `gh workflow`, `gh release`, `gh issue`, `gh pr`, `gh app`, `gh extension` | `@devops`, `@reviewer`, `@engineering-intelligence` |
| **docker** | `npx @anthropic/mcp-docker` | `docker build`, `docker push`, `docker pull`, `docker run` | `@devops`, `@deploy` |
| **git** | `npx @anthropic/mcp-git` | `git clone`, `git push`, `git pull`, `git commit`, `git branch` | `@devops`, `@reviewer` |

### Utility Servers

| Server | Command | Capabilities | Primary Agents |
| ------ | ------- | ------------ | -------------- |
| **bash** | `npx @anthropic/mcp-bash` | `bash`, `sh`, `curl`, `jq`, `yq` | All agents |
| **filesystem** | `npx @anthropic/mcp-filesystem` | `read`, `write`, `list`, `delete` | All agents |

### Security and Governance Servers

| Server | Command | Capabilities | Primary Agents |
| ------ | ------- | ------------ | -------------- |
| **defender** | `npx @anthropic/mcp-azure` | `az security`, `az security pricing`, `az security assessment`, `az security alert` | `@security` |
| **purview** | `npx @anthropic/mcp-azure` | `az purview`, `az purview account`, `az purview scan` | `@security`, `@architect` |
| **entra** | `npx @anthropic/mcp-azure` | `az ad app`, `az ad sp`, `az ad group`, `az ad user`, `az role assignment` | `@security`, `@onboarding` |

### Intelligence Servers

| Server | Command | Capabilities | Primary Agents |
| ------ | ------- | ------------ | -------------- |
| **copilot** | `npx @anthropic/mcp-github` | `gh copilot`, `gh copilot explain`, `gh copilot suggest` | `@engineering-intelligence` |
| **engineering-intelligence** | `npx @anthropic/mcp-github` | GitHub REST/GraphQL APIs for DORA, Copilot, GHAS metrics | `@engineering-intelligence` |

### Backstage/RHDH Server

| Server | Transport | Capabilities | Primary Agents |
| ------ | --------- | ------------ | -------------- |
| **backstage** | Streamable HTTP | `catalog:query`, `catalog:get`, `techdocs:list`, `techdocs:get` | `@platform`, `@rhdh-architect` |

The `backstage` MCP server uses a different transport mechanism, connecting to the RHDH API at `https://devhub.3horizons.ai/api/mcp-actions/v1` via Streamable HTTP with bearer token authentication. Its plugins include:

- `@backstage/plugin-mcp-actions-backend` -- server-side MCP action handler
- `@red-hat-developer-hub/backstage-plugin-software-catalog-mcp-tool` -- catalog queries
- `@red-hat-developer-hub/backstage-plugin-techdocs-mcp-tool` -- TechDocs retrieval

---

## Access Control Matrix

MCP servers enforce a three-tier access control model to prevent destructive or unsafe operations.

### Always Allowed (Read-Only)

These operations are safe and do not modify state. Agents can execute them without user confirmation:

```text
az resource list / show
az aks show / get-upgrades
kubectl get / describe / logs / top
gh pr view / issue view / api (GET requests)
helm list / status / get
terraform state list / show / output
docker inspect / images
git log / diff / status / branch --list
catalog:query / catalog:get / techdocs:list / techdocs:get
```

### Requires Confirmation (Write Operations)

These operations modify state and require explicit user confirmation before execution:

```text
terraform apply / destroy
kubectl apply / delete / scale / rollout restart
helm install / upgrade / uninstall
az resource delete / az aks scale
docker build / push
git commit / push / merge
az postgres flexible-server restart
```

When an agent needs to execute a confirmation-required operation, it will:

1. Describe what the operation will do
2. Show the exact command or API call
3. Ask for explicit user approval
4. Only proceed after confirmation

### Forbidden (Never Allowed)

These operations are blocked at the MCP server level and cannot be executed by any agent under any circumstances:

```text
kubectl delete namespace production
terraform destroy -auto-approve
kubectl get secret -o yaml            (exposes secret values)
az keyvault secret show --query value (exposes secret values)
az role assignment create --role Owner (privilege escalation)
rm -rf /                              (destructive filesystem)
Expose individual developer metrics   (privacy violation)
Access source code content via metrics (scope violation)
Store tokens in files                 (security violation)
```

---

## Configuration

### Server Configuration Format

Each server entry in `mcp-config.json` defines:

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-<tool>"],
      "description": "Human-readable description",
      "env": {
        "ENV_VAR": "${SECRET_FROM_KEYVAULT}"
      },
      "capabilities": ["command1", "command2"]
    }
  }
}
```

| Field | Purpose |
| ----- | ------- |
| `command` | The binary to execute (typically `npx`) |
| `args` | Arguments passed to the command (MCP package name) |
| `description` | What the server does |
| `env` | Environment variables (secrets resolved from Key Vault) |
| `capabilities` | List of supported operations |

### Environment Variables

Credentials are loaded from environment variables, which are populated from Azure Key Vault at runtime:

| Variable | Source | Used By |
| -------- | ------ | ------- |
| `AZURE_SUBSCRIPTION_ID` | Key Vault | azure, defender, purview, entra |
| `GITHUB_TOKEN` | Key Vault | github, copilot, engineering-intelligence |
| `COPILOT_METRICS_TOKEN` | Key Vault | engineering-intelligence |
| `KUBECONFIG` | AKS credential | kubernetes |
| `TF_VAR_environment` | Pipeline variable | terraform |
| `MCP_TOKEN` | Key Vault | backstage |

---

## Agent-to-MCP Mapping

Each Copilot agent declares which MCP servers it can access in its `.agent.md` frontmatter under the `tools` section:

```yaml
---
name: sre
tools:
  - mcp: kubernetes
  - mcp: azure
  - mcp: bash
  - mcp: helm
---
```

The full access matrix is documented in `mcp-servers/USAGE.md`. A summary:

| Agent | MCP Servers |
| ----- | ----------- |
| @architect | `terraform`, `azure`, `kubernetes`, `bash`, `filesystem` |
| @platform | `helm`, `kubernetes`, `bash`, `filesystem`, `backstage` |
| @devops | `github`, `docker`, `git`, `helm`, `kubernetes`, `bash` |
| @sre | `kubernetes`, `azure`, `bash`, `helm` |
| @terraform | `terraform`, `azure`, `bash`, `filesystem` |
| @security | `defender`, `purview`, `entra`, `azure`, `kubernetes` |
| @deploy | `kubernetes`, `helm`, `azure`, `docker`, `git`, `bash` |
| @engineering-intelligence | `github`, `copilot`, `engineering-intelligence`, `bash` |
| @rhdh-architect | `backstage`, `kubernetes`, `bash`, `filesystem` |

---

## AI Foundry Integration

The `azure` MCP server provides access to Azure AI Foundry resources deployed by the `ai-foundry` Terraform module:

### Available Models

| Model | Deployment | Region | Purpose |
| ----- | ---------- | ------ | ------- |
| GPT-4o | `gpt-4o` | eastus2 | Complex reasoning, code generation |
| GPT-4o-mini | `gpt-4o-mini` | eastus2 | Fast responses, simple Q&A |
| text-embedding-3-large | `text-embedding-3-large` | eastus2 | Document embeddings for RAG |

### Azure AI Search

AI Search provides vector indexing for the RAG pipeline used by Developer Lightspeed:

- Indexes platform documentation, TechDocs, runbooks, and policies
- Supports hybrid search (keyword + vector)
- Private endpoint access only

### Content Safety

Azure AI Content Safety filters are enabled on all AI interactions:

- Hate speech detection and blocking
- Self-harm content detection
- Violence content detection
- Sexual content detection

---

## Adding a New MCP Server

To add a new MCP server:

**Step 1.** Define the server in `mcp-servers/mcp-config.json`:

```json
{
  "my-new-server": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-my-tool"],
    "description": "Description of the new server",
    "env": {
      "API_KEY": "${MY_TOOL_API_KEY}"
    },
    "capabilities": ["command1", "command2"]
  }
}
```

**Step 2.** Define access control -- Specify allowed, denied, and confirmation-required operations

**Step 3.** Update the access matrix in `mcp-servers/USAGE.md`

**Step 4.** Add the MCP reference to relevant agent `.agent.md` files

**Step 5.** Store credentials in Azure Key Vault

**Step 6.** Test the server with the `@test` agent: `@test Validate MCP server my-new-server`

---

## Security Considerations

- MCP servers run with the minimum required permissions (least privilege)
- Credentials are loaded from Azure Key Vault at runtime (never hardcoded)
- All tool invocations are logged for audit purposes
- Destructive operations are blocked or require explicit confirmation
- Network access follows the same private endpoint restrictions as the platform
- Secret values are never returned in tool responses
- The forbidden operation list cannot be overridden by agents or users

---

## Troubleshooting

### Common Issues

| Issue | Cause | Resolution |
| ----- | ----- | ---------- |
| Agent cannot invoke tool | MCP server not listed in agent `tools` | Add the MCP server to the agent frontmatter |
| Authentication failure | Missing or expired credentials | Verify Key Vault secret and ESO sync |
| Command timeout | Slow network or large response | Check network connectivity; increase timeout |
| Forbidden operation error | Operation is in the deny list | Use an alternative approach; operation is blocked by design |
| Backstage MCP not responding | RHDH API unavailable or token expired | Check RHDH pod health and MCP_TOKEN secret |

### Diagnostic Commands

```bash
# Verify MCP config is valid JSON
python3 -m json.tool mcp-servers/mcp-config.json

# Check agent MCP server references
./scripts/validate-agents.sh

# Verify Key Vault secrets exist for MCP env vars
az keyvault secret list --vault-name ${VAULT_NAME} --query "[].name" -o tsv
```
