# 🚀 Cowork Tasks — Deploy Backstage & RHDH with AI Agent Stack

> **Focus:** Deploy using Azure AI Foundry + GitHub Copilot + VS Code + Multi-Cloud
> **Stack:** Microsoft Azure AI Foundry · GitHub Copilot (Agent Mode, CLI, SDK) · MCP Servers · Skills · Agentic Workflows
> **Clients:** VS Code · GitHub Copilot CLI · Azure Foundry · Foundry MCP Server
> **Target:** Azure (primary) · AWS · GCP · On-Premise
> **Author:** paulasilva@microsoft.com
> **Created:** 2026-02-27

---

## 🎯 Core Principle

Every task in this document answers ONE question:
**"How do I use GitHub Copilot + Azure AI Foundry + MCP to actually DEPLOY and CONFIGURE Backstage/RHDH with full AI integration across multi-cloud?"**

This is NOT documentation about what MCP is. This is **operational deployment guides** using the Microsoft + GitHub agentic stack.

---

## 🛠️ The Deployment Stack

```
┌─────────────────────────────────────────────────────────────────┐
│                    DEVELOPMENT ENVIRONMENT                       │
│  VS Code + GitHub Copilot Agent Mode + MCP Servers              │
│  GitHub Copilot CLI (GA Feb 2026) + Skills + Custom Agents      │
│  GitHub Copilot SDK (Technical Preview Jan 2026)                │
├─────────────────────────────────────────────────────────────────┤
│                    AGENTIC ORCHESTRATION                         │
│  GitHub Coding Agent (async PRs from issues)                    │
│  GitHub Agentic Workflows (AI in GitHub Actions)                │
│  Azure AI Foundry Agent Service (hosted agents + memory)        │
│  Foundry MCP Server (mcp.ai.azure.com) + Foundry Tools          │
├─────────────────────────────────────────────────────────────────┤
│                    MCP SERVER ECOSYSTEM                          │
│  Official: Azure MCP (microsoft/mcp) · GitHub MCP · AKS MCP    │
│           Kubernetes MCP (Azure/mcp-kubernetes) · Foundry MCP   │
│  Custom:  Backstage MCP · RHDH MCP · Combined DevOps MCP       │
├─────────────────────────────────────────────────────────────────┤
│                    SKILLS & AGENTS                               │
│  microsoft/skills (131 skills: Azure SDKs, Foundry, AKS, etc.) │
│  github/awesome-copilot (community agents, skills, hooks)       │
│  Custom: backstage-deploy, rhdh-deploy, mcp-setup, lightspeed  │
├─────────────────────────────────────────────────────────────────┤
│                    MULTI-CLOUD DEPLOYMENT                        │
│  Azure (primary): AKS · ACR · Key Vault · Foundry · AI Search  │
│  AWS: EKS · ECR · Secrets Manager                               │
│  GCP: GKE · Artifact Registry · Secret Manager                  │
│  On-Premise: OpenShift · k3s · Harbor                           │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Task Index

| # | Task | Focus | Output |
|---|------|-------|--------|
| **PHASE 1: BACKSTAGE (Open Horizons)** |||
| 1 | Backstage MCP + AI Deployment Guide | Complete guide: deploy Backstage with MCP on Azure using GitHub agents | DOCX + MD |
| 2 | Backstage Deployment Diagrams | Architecture, flows, handoffs, multi-cloud | 8 FigJam |
| 3 | Backstage Config Files & Agent Definitions | Every file needed to deploy | Config files |
| **PHASE 2: RHDH (Three Horizons)** |||
| 4 | RHDH MCP + Lightspeed Deployment Guide | Complete guide: deploy RHDH with MCP + Lightspeed on Azure | DOCX + MD |
| 5 | RHDH Deployment Diagrams | Architecture, Lightspeed, BYOM, multi-cloud | 8 FigJam |
| 6 | RHDH Config Files & Agent Definitions | Every file needed to deploy | Config files |
| **PHASE 3: AiKA-LIKE MVP** |||
| 7 | AiKA MVP for Backstage — Build & Deploy Guide | How to build AND deploy using Foundry + GitHub agents | DOCX + MD |
| 8 | AiKA MVP Diagrams | Architecture, RAG pipeline, Azure infra, sprints | 6 FigJam |
| **PHASE 4: MULTI-CLOUD** |||
| 9 | Multi-Cloud Deployment Guide | Deploy Backstage + RHDH on AWS, GCP, On-Prem | DOCX + MD |
| 10 | Multi-Cloud Diagrams | Per-cloud architecture, comparison matrix | 6 FigJam |
| **PHASE 5: AGENT ECOSYSTEM** |||
| 11 | GitHub + Foundry Agent Ecosystem | All agents, skills, MCP servers, workflows | MD + files |
| 12 | Master Index | Cross-reference everything | MD |

---

## TASK 1 — Backstage (Open Horizons) MCP + AI Deployment Guide

### 📎 Output
- `backstage_mcp_ai_deploy_guide_v1.0.docx` + `.md`

### 📝 Instructions

Create a **deployment-focused technical guide** for Backstage upstream on Azure, using the full Microsoft + GitHub agentic stack. Every section answers "how to deploy this" not "what this is".

Use `ms-docx-creator` skill for DOCX. Also save as `.md`.

**CRITICAL CONTEXT (include in document):**

Platform details:
- Backstage upstream = Open Horizons project
- Repository: `open-horizons-backstage` on GitHub
- Backstage requires: static plugins → code changes → image rebuild → redeploy
- MCP Server plugin: `@backstage/plugin-mcp-actions-backend` (GA since Backstage v1.40)
- MCP Endpoint: `/api/mcp-actions/v1` (Streamable HTTP + SSE transport)
- No native in-portal AI chat (AiKA = Spotify Portal SaaS only, not available in open-source)

Official MCP Servers to use:
- Azure MCP Server: `github.com/microsoft/mcp` — manages Azure resources via AI
- Azure Kubernetes MCP: `github.com/Azure/mcp-kubernetes` — bridge between AI tools and K8s
- GitHub MCP Server: Built into Copilot CLI, also available standalone
- Foundry MCP Server: `mcp.ai.azure.com` — cloud-hosted, Entra ID auth, model catalog + agents
- Backstage MCP Server: `@backstage/plugin-mcp-actions-backend` — catalog + techdocs queries

Official Skills to use (from `github.com/microsoft/skills`):
- azure-skills plugin: 18 skills for AI, storage, diagnostics, cost, compliance, RBAC
- 3-step workflow: azure-prepare → azure-validate → azure-deploy
- mcp-builder skill: Generate MCP server projects
- deep-wiki plugin: Generate AGENTS.md, documentation, onboarding guides

GitHub Copilot capabilities:
- Agent Mode (VS Code): Multi-step autonomous coding with MCP support
- Coding Agent: Assign GitHub issues → gets PR back (async, cloud-based)
- Copilot CLI (GA Feb 27, 2026): Terminal agent with plugins, skills, custom agents, hooks
- Copilot SDK (Technical Preview Jan 2026): Embed agent loop in any app (Node.js, Python, Go, .NET)
- Custom agents: `.agent.md` files with own tools, MCP servers, instructions
- Skills: `.github/skills/` folders with `SKILL.md` files, auto-triggered by intent
- Hooks: `preToolUse` / `postToolUse` for policy enforcement
- Agentic Workflows: AI-powered GitHub Actions with natural language instructions
- Models: Claude Opus 4.6, Claude Sonnet 4.6, GPT-5.3-Codex, Gemini 3 Pro

Azure AI Foundry capabilities:
- Foundry Agent Service: Managed agents with MCP tool support, memory, A2A protocol
- Foundry MCP Server: `mcp.ai.azure.com` — cloud-hosted, Entra auth, zero local setup
- Foundry Tools: 1,400+ connectors (SAP, Salesforce, UiPath, etc.)
- Agent Memory (Public Preview): Long-term memory across sessions
- Agent-to-Agent (A2A) Tool: Inter-agent communication
- Control Plane: Unified guardrails, identity, observability, security
- Models: GPT-5.2, Codex Max (GA), reasoning models, open-source fine-tuning

**DOCUMENT STRUCTURE:**

#### Section 1 — Deployment Stack Overview
- The complete stack diagram (from above)
- How each layer works together for Backstage deployment
- Why this stack: GitHub for code → Foundry for AI → Azure for infra → MCP for connectivity

#### Section 2 — Pre-Deployment: Repository Setup with GitHub Agents

**2.1 — AGENTS.md for the Repository**
Create root `AGENTS.md` that teaches all agents about:
- Backstage architecture (app, backend, packages structure)
- Plugin installation pattern (yarn add → edit index.ts → rebuild)
- MCP integration points
- app-config.yaml structure
- Build and deploy pipeline

**2.2 — Install Official Skills**
```bash
# In Copilot CLI
/plugin marketplace add microsoft/skills
/plugin install azure-skills@skills
/plugin install deep-wiki@skills

# Or manually copy to repo
git clone https://github.com/microsoft/skills.git
cp -r skills/.github/skills/azure-kubernetes-service your-project/.github/skills/
cp -r skills/.github/skills/mcp-builder your-project/.github/skills/
cp -r skills/.github/skills/azure-container-registry your-project/.github/skills/
```

**2.3 — Configure MCP Servers in VS Code**
```json
// .vscode/mcp.json — THE COMPLETE SETUP
{
  "servers": {
    // 1. Azure MCP — manage Azure resources
    "azure": {
      "type": "http",
      "url": "https://mcp.ai.azure.com",
      "headers": { "Authorization": "Bearer ${AZURE_TOKEN}" }
    },
    // 2. Kubernetes MCP — manage AKS clusters
    "kubernetes": {
      "command": "npx",
      "args": ["-y", "@azure/mcp-kubernetes", "--access-level", "readwrite"]
    },
    // 3. GitHub MCP — repo management
    "github": {
      "command": "npx",
      "args": ["-y", "@github/mcp-server"]
    },
    // 4. Backstage MCP — catalog + techdocs queries
    "backstage": {
      "type": "http",
      "url": "https://backstage.yourdomain.com/api/mcp-actions/v1",
      "headers": { "Authorization": "Bearer ${MCP_ACCESS_TOKEN}" }
    }
  }
}
```

**2.4 — Custom Agents for Deployment**
Create `.github/agents/` directory with deployment-specific agents:
```markdown
<!-- .github/agents/backstage-deployer.agent.md -->
---
name: backstage-deployer
description: Deploy Backstage with MCP to Azure Kubernetes Service
tools:
  - azure
  - kubernetes
  - github
---
# Backstage Deployer Agent

You deploy Backstage instances to Azure Kubernetes Service.

## Workflow
1. Use Azure MCP to verify AKS cluster is ready
2. Use GitHub MCP to get latest code from main branch
3. Build container image and push to ACR
4. Use Kubernetes MCP to apply deployment manifests
5. Verify pod health and MCP endpoint connectivity

## Context
- Backstage requires image rebuild for any plugin change
- MCP endpoint: /api/mcp-actions/v1
- Auth: Static token in Kubernetes secret
```

#### Section 3 — Deploy MCP Server Plugin (Step-by-Step with GitHub Agents)

**3.1 — Using GitHub Copilot Agent Mode (VS Code)**
```
# In VS Code Copilot Chat (Agent Mode), with MCP servers running:

Prompt: "Install the @backstage/plugin-mcp-actions-backend plugin in my Backstage 
backend. Update packages/backend/src/index.ts and app-config.yaml with static token 
auth. The token should come from a Kubernetes secret called backstage-mcp-token."

# Copilot Agent Mode will:
# 1. Run: yarn --cwd packages/backend add @backstage/plugin-mcp-actions-backend
# 2. Edit packages/backend/src/index.ts to add: backend.add(import('@backstage/plugin-mcp-actions-backend'));
# 3. Edit app-config.yaml to add externalAccess config
# 4. Suggest k8s secret manifest
# 5. Run build to verify
```

**3.2 — Using GitHub Copilot CLI**
```bash
# In terminal with GitHub Copilot CLI (GA):
copilot "Install the MCP actions backend plugin in my Backstage project.
I need static token auth configured. Create all necessary files."

# Or use background delegation:
& copilot "Install MCP plugin, build the backend, and create a PR with the changes"
# Terminal is free, work continues in background
# Check status: /resume
```

**3.4 — Build & Deploy Pipeline**
```
# Using Copilot Agent Mode + Azure MCP + Kubernetes MCP:

Prompt: "Build the updated Backstage backend image, push to ACR 
backstageregistry.azurecr.io, and deploy to AKS cluster backstage-prod 
in resource group backstage-rg. Use Kubernetes MCP to verify the deployment 
and test the MCP endpoint."

# Copilot will use:
# - Azure MCP → verify ACR and AKS exist
# - Terminal → docker build + docker push
# - Kubernetes MCP → kubectl apply, kubectl rollout status
# - Backstage MCP → test endpoint after deployment
```

**3.5 — GitHub Agentic Workflow (CI/CD)**
```yaml
# .github/workflows/deploy-backstage-mcp.yml
name: Deploy Backstage with MCP
on:
  push:
    branches: [main]
    paths:
      - 'packages/backend/**'
      - 'app-config.yaml'

permissions:
  contents: read
  pull-requests: write

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Backend
        run: |
          yarn install --frozen-lockfile
          yarn build:backend --config ../../app-config.yaml
      
      - name: Build and Push Image
        uses: azure/docker-login@v1
        with:
          login-server: ${{ vars.ACR_LOGIN_SERVER }}
          username: ${{ secrets.ACR_USERNAME }}
          password: ${{ secrets.ACR_PASSWORD }}
      - run: |
          docker build -t ${{ vars.ACR_LOGIN_SERVER }}/backstage:${{ github.sha }} .
          docker push ${{ vars.ACR_LOGIN_SERVER }}/backstage:${{ github.sha }}
      
      - name: Deploy to AKS
        uses: azure/k8s-deploy@v4
        with:
          namespace: backstage
          manifests: k8s/
          images: ${{ vars.ACR_LOGIN_SERVER }}/backstage:${{ github.sha }}
      
      - name: Verify MCP Endpoint
        run: |
          sleep 30
          curl -sf -H "Authorization: Bearer ${{ secrets.MCP_TOKEN }}" \
            https://backstage.yourdomain.com/api/mcp-actions/v1 || exit 1
```

#### Section 4 — Configure External AI Clients (Microsoft Stack Only)

For EACH client, provide:
1. Complete config file
2. Setup command
3. Verification step
4. Example query

**Clients:** VS Code with GitHub Copilot Agent Mode, GitHub Copilot CLI, Azure AI Foundry Agent, Foundry MCP Server

Include full config snippets (same as previous research — refer to the MCP integration guide document already created).

#### Section 5 — Azure AI Foundry Agent for Backstage

**5.1 — Create Foundry Agent with Backstage MCP**
```python
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

client = AIProjectClient(
    credential=DefaultAzureCredential(),
    endpoint=os.environ["AZURE_FOUNDRY_PROJECT_ENDPOINT"]
)

agent = client.agents.create_agent(
    model="gpt-4o",
    name="backstage-portal-assistant",
    instructions="""You are an AI assistant for the Backstage developer portal.
    Help developers find services, understand documentation, query the catalog,
    and troubleshoot issues. Always use MCP tools for live data.""",
    tools=[
        {
            "type": "mcp",
            "mcp": {
                "server_label": "backstage",
                "server_url": "https://backstage.yourdomain.com/api/mcp-actions/v1",
                "allowed_tools": ["catalog-query", "techdocs-query"],
                "approval_mode": "never_require"
            }
        },
        {
            "type": "mcp",
            "mcp": {
                "server_label": "github",
                "server_url": "https://api.githubcopilot.com/mcp/",
                "approval_mode": "always_require"
            }
        }
    ]
)
```

**5.2 — Foundry Agent with Memory (cross-session)**
Reference: Agent Memory is Public Preview since Dec 2025.
Agents remember user preferences, past queries, context across sessions.

**5.3 — Multi-Tool Agent (Backstage + GitHub + Azure)**
```python
agent = client.agents.create_agent(
    model="gpt-4o",
    name="devops-assistant",
    instructions="You help with DevOps tasks across Backstage, GitHub, and Azure.",
    tools=[
        {"type": "mcp", "mcp": {"server_label": "backstage", "server_url": "..."}},
        {"type": "mcp", "mcp": {"server_label": "github", "server_url": "https://api.githubcopilot.com/mcp/"}},
        {"type": "mcp", "mcp": {"server_label": "azure", "server_url": "https://mcp.ai.azure.com"}},
    ]
)
```

#### Section 6 — Custom MCP Server: Build & Deploy on Azure

**6.1 — Build Custom MCP Server using Copilot Agent Mode**
```
Prompt: "Create a Python MCP server that combines:
1. Backstage catalog queries (via REST API)
2. GitHub repo stats (via GitHub API)
3. Azure resource health (via Azure SDK)
Deploy it as Azure Container App with Entra ID auth."
```

**6.2 — Deploy to Azure Container Apps**
```bash
# Using Azure MCP + Copilot CLI:
az containerapp up \
  -g backstage-rg -n backstage-combined-mcp \
  --environment mcp-env \
  --source . \
  --env-vars API_KEYS=${MCP_API_KEY}
```

**6.3 — Deploy to AKS (alongside Backstage)**
```yaml
# k8s/custom-mcp-server.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backstage-combined-mcp
  namespace: backstage
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: mcp-server
          image: backstageregistry.azurecr.io/combined-mcp:latest
          ports:
            - containerPort: 8080
          env:
            - name: BACKSTAGE_URL
              value: "http://backstage-backend:7007"
            - name: BACKSTAGE_TOKEN
              valueFrom:
                secretKeyRef:
                  name: backstage-mcp-token
                  key: token
```

#### Section 7 — Multi-Cloud Deployment Overview (Azure Primary)

| Cloud | K8s Service | Registry | Secrets | Specifics |
|-------|------------|----------|---------|-----------|
| Azure (primary) | AKS | ACR | Key Vault | Managed Identity, Entra ID |
| AWS | EKS | ECR | Secrets Manager | IRSA for auth |
| GCP | GKE | Artifact Registry | Secret Manager | Workload Identity |
| On-Prem | OpenShift / k3s | Harbor | HashiCorp Vault | Air-gapped option |

Brief overview per cloud — full details in Task 9.

#### Section 8 — Agent Handoff Map for Deployment
Which of the 15 agents in `open-horizons-backstage` handles each step:
- `architect` → Design MCP integration, choose custom MCP server language
- `backstage-expert` → MCP plugin installation, app-config changes
- `security` → Token generation, Entra ID config, secret management
- `devops` → CI/CD pipeline (GitHub Actions workflow)
- `deploy` → AKS deployment orchestration
- `azure-portal-deploy` → Azure infrastructure (AKS, ACR, Key Vault)
- `platform` → IDE client configs, team onboarding
- `github-integration` → GitHub MCP server, Copilot agent configs
- `docs` → MCP endpoint documentation, usage guides
- `sre` → Monitoring, health checks, MCP endpoint validation
- `test` → E2E testing of MCP tools and client connections

#### Section 9 — References (Cite ALL with URLs)
**Azure AI Foundry:**
- Foundry MCP Server: https://devblogs.microsoft.com/foundry/announcing-foundry-mcp-server-preview-speeding-up-ai-dev-with-microsoft-foundry/
- MCP in Foundry Agents: https://learn.microsoft.com/en-us/azure/ai-foundry/agents/how-to/tools-classic/model-context-protocol
- MCP + Foundry Python: https://learn.microsoft.com/en-us/agent-framework/user-guide/model-context-protocol/using-mcp-with-foundry-agents
- Foundry What's New Dec/Jan: https://devblogs.microsoft.com/foundry/whats-new-in-microsoft-foundry-dec-2025-jan-2026/

**GitHub Platform:**
- Copilot CLI GA: https://github.blog/changelog/2026-02-25-github-copilot-cli-is-now-generally-available/
- Copilot SDK: https://github.blog/news-insights/company-news/build-an-agent-into-any-app-with-the-github-copilot-sdk/
- Copilot Coding Agent: https://github.com/newsroom/press-releases/coding-agent-for-github-copilot
- Copilot Agent Mode + MCP: https://docs.github.com/en/copilot/tutorials/enhance-agent-mode-with-mcp
- MCP in VS Code: https://docs.github.com/copilot/customizing-copilot/using-model-context-protocol/extending-copilot-chat-with-mcp
- Agent Skills: https://code.visualstudio.com/docs/copilot/customization/agent-skills
- Copilot Agents: https://github.com/features/copilot/agents

**Official Microsoft MCP + Skills:**
- microsoft/mcp (catalog): https://github.com/microsoft/mcp
- microsoft/skills (131 skills): https://github.com/microsoft/skills
- Azure MCP Server docs: https://learn.microsoft.com/en-us/azure/developer/azure-mcp-server/get-started
- Azure/mcp-kubernetes: https://github.com/Azure/mcp-kubernetes
- AKS MCP tools: https://learn.microsoft.com/en-us/azure/developer/azure-mcp-server/tools/azure-kubernetes
- Context-Driven Dev blog: https://devblogs.microsoft.com/all-things-azure/context-driven-development-agent-skills-for-microsoft-foundry-and-azure/
- github/awesome-copilot: https://github.com/github/awesome-copilot

**Backstage + RHDH MCP:**
- Backstage MCP plugin: https://backstage.io/api/stable/modules/_backstage_plugin-mcp-actions-backend.html
- RHDH MCP blog: https://developers.redhat.com/articles/2025/11/10/mcp-red-hat-developer-hub-chat-your-catalog
- RHDH MCP plugins: https://github.com/redhat-developer/rhdh-plugins/tree/main/workspaces/mcp-integrations
- MCP Specification: https://modelcontextprotocol.io/specification/2025-11-25

**Azure Infrastructure:**
- Deploy MCP on AKS: https://learn.microsoft.com/en-us/azure/aks/openwebsearch-on-aks
- Host MCP on Container Apps: https://techcommunity.microsoft.com/blog/appsonazureblog/host-remote-mcp-servers-in-azure-container-apps/4403550
- Copilot SDK + K8s Sidecar: https://techcommunity.microsoft.com/blog/azuredevcommunityblog/building-a-dual-sidecar-pod-combining-github-copilot-sdk-with-skill-server-on-ku/4497080

---

## TASK 2 — Backstage Deployment Diagrams (FigJam)

### 📎 Output
- 8 FigJam diagrams

### 📝 Instructions

Create **8 FigJam diagrams** using `Figma:generate_diagram`. Microsoft brand colors. **FLAT NODES ONLY** (no subgraphs).

**Color palette:**
- Blue `stroke:#0078D4,stroke-width:3px` — Azure/core
- Red `stroke:#E81123,stroke-width:3px` — security
- Green `stroke:#107C10,stroke-width:3px` — GitHub/testing
- Yellow `stroke:#FFB900,stroke-width:3px` — delivery
- Purple `stroke:#5C2D91,stroke-width:3px` — AI/external
- Teal `stroke:#008272,stroke-width:3px` — infrastructure

**CRITICAL:** `flowchart LR` or `TB` only. No `subgraph`. All text in `"quotes"`. `style` per node.

**Diagram 1: Complete Deployment Stack**
- 5 layers: Dev Environment (VS Code + Copilot) → Agentic Orchestration (Coding Agent + Foundry) → MCP Servers (Azure + GitHub + K8s + Backstage) → Skills (microsoft/skills + custom) → Multi-Cloud (AKS + EKS + GKE + On-Prem)

**Diagram 2: VS Code → Copilot Agent Mode → MCP → Deploy Flow**
- Developer in VS Code → Copilot Agent Mode → selects MCP tools → Azure MCP (create resources) → K8s MCP (deploy pods) → Backstage MCP (verify) → GitHub MCP (commit)

**Diagram 3: GitHub Coding Agent Async Workflow**
- Create Issue → Assign to Copilot → Agent creates branch → Implements changes → Runs tests → Opens PR → Human reviews → Merge → CI/CD → Deploy

**Diagram 4: MCP Server Ecosystem Map**
- Central: Backstage Instance
- Connected MCP servers: Azure MCP, GitHub MCP, Kubernetes MCP, Foundry MCP, Custom Combined MCP
- Each with their capabilities listed

**Diagram 5: Azure AI Foundry Agent Architecture**
- Foundry Agent Service → Tools: [Backstage MCP, GitHub MCP, Azure MCP, AI Search]
- Memory: Cross-session persistence
- Models: GPT-4o / GPT-5.2
- Control Plane: Guardrails, identity, observability

**Diagram 6: Build & Deploy Pipeline (GitHub Actions)**
- Push to main → Build backend → Docker build → Push ACR → Deploy AKS → Verify MCP → Notify

**Diagram 7: Authentication & Security Flow**
- Three auth paths for MCP: Static Token (today), Entra ID (Foundry), Device Auth (roadmap)
- K8s secrets flow, Managed Identity, Key Vault integration

**Diagram 8: Agent Handoff for Deployment**
- All 15 agents in open-horizons-backstage showing who handles each deployment step
- Arrows: architect → backstage-expert → security → devops → deploy → sre

---

## TASK 3 — Backstage Config Files & Agent Definitions

### 📎 Output
All files below — complete, production-ready, copy-paste.

### 📝 Instructions

Create ALL files in this structure:

```
open-horizons-backstage/
├── AGENTS.md                              # Root — teaches agents about the repo
├── .github/
│   ├── copilot-instructions.md            # Global Copilot behavior
│   ├── agents/
│   │   ├── backstage-deployer.agent.md    # Deploy Backstage to AKS
│   │   ├── mcp-setup.agent.md             # Install + configure MCP plugins
│   │   ├── azure-infra.agent.md           # Provision Azure infrastructure
│   │   ├── client-config.agent.md         # Generate IDE MCP client configs
│   │   ├── custom-mcp-builder.agent.md    # Build custom MCP servers
│   │   └── mcp-tester.agent.md            # Validate MCP endpoint + tools
│   ├── skills/
│   │   ├── backstage-plugins/SKILL.md     # How to install Backstage plugins
│   │   ├── mcp-protocol/SKILL.md          # MCP protocol knowledge
│   │   ├── aks-deploy/SKILL.md            # AKS deployment patterns
│   │   └── azure-foundry-agents/SKILL.md  # Azure AI Foundry agent patterns
│   ├── prompts/
│   │   ├── install-mcp-plugin.prompt.md
│   │   ├── deploy-to-aks.prompt.md
│   │   └── create-foundry-agent.prompt.md
│   ├── hooks/
│   │   └── verify-mcp-endpoint.sh         # Post-deploy hook to test MCP
│   └── workflows/
│       ├── deploy-backstage-mcp.yml       # CI/CD for Backstage + MCP
│       └── test-mcp-endpoint.yml          # Scheduled MCP health check
├── .vscode/
│   └── mcp.json                           # All MCP servers for VS Code
├── configs/
│   ├── app-config.mcp.yaml               # MCP section for app-config
│   ├── backend-index-mcp.ts              # Backend registration code
│   └── k8s/
│       ├── mcp-token-secret.yaml
│       ├── backstage-deployment.yaml
│       └── custom-mcp-server.yaml
├── clients/
│   ├── vscode-mcp-config.json
│   └── copilot-cli-setup.sh
├── foundry/
│   ├── backstage-agent.py                 # Foundry agent with Backstage MCP
│   ├── multi-tool-agent.py                # Agent with all MCP servers
│   └── agent-config.json
└── custom-mcp-server/
    ├── python/server.py                   # Python MCP server
    ├── dotnet/Program.cs                  # C# MCP server
    ├── Dockerfile
    └── k8s/deployment.yaml
```

Each file must be:
- Complete (not placeholder or TODO)
- Include all imports, dependencies, proper error handling
- Reference official docs in comments
- Follow Microsoft coding standards

---

## TASK 4 — RHDH (Three Horizons) MCP + Lightspeed Deployment Guide

### 📎 Output
- `rhdh_mcp_lightspeed_deploy_guide_v1.0.docx` + `.md`

### 📝 Instructions

Same deployment-focused approach as Task 1 but for **RHDH (Three Horizons)**. Key differences:
- RHDH = dynamic plugins → YAML only → no code → no rebuild → pod restart
- RHDH has **Developer Lightspeed** (in-portal AI chat) — Backstage does NOT
- RHDH has built-in RBAC — Backstage requires community plugin
- Deploy target: AKS or ARO (Azure Red Hat OpenShift)

**CRITICAL CONTEXT:**

RHDH MCP Installation (5 min, YAML only):
```yaml
# dynamic-plugins.yaml
plugins:
  - package: "@backstage/plugin-mcp-actions-backend@^1.0.0"
    disabled: false
  - package: "@red-hat-developer-hub/backstage-plugin-mcp-catalog@^1.0.0"
    disabled: false
  - package: "@red-hat-developer-hub/backstage-plugin-mcp-techdocs@^1.0.0"
    disabled: false
  - package: "@red-hat-developer-hub/backstage-plugin-software-catalog-mcp-extras@^1.0.0"
    disabled: false
```

Developer Lightspeed (RHDH-exclusive, Developer Preview since v1.7):
- Architecture: Frontend + Backend plugins + LCS sidecar + Llama Stack sidecar + RAG init container
- BYOM: Azure OpenAI, OpenAI, Ollama, vLLM, OpenShift AI
- Features: Chat in portal, RAG on docs with citations, MCP integration, RBAC, chat history, feedback

**DOCUMENT STRUCTURE:**

Same structure as Task 1 (Sections 1-9) BUT with these RHDH-specific additions:

#### RHDH-Specific Section: Developer Lightspeed Full Deployment
- Complete sidecar deployment using Helm
- LCS ConfigMap (Lightspeed Core Service)
- Llama Stack ConfigMap (per BYOM provider: Azure OpenAI, Ollama, vLLM)
- RAG init container configuration
- RBAC policies for AI features (permission-policies.csv)
- Custom suggested prompts
- Step-by-step using Copilot Agent Mode:
```
Prompt: "Deploy Developer Lightspeed in my RHDH instance on AKS. 
Use Azure OpenAI as the LLM provider. Configure RBAC so all developers 
can chat but only admins can delete history. Enable RAG on TechDocs."
```

#### RHDH-Specific Section: BYOM Decision Matrix
| Provider | When to Use | Setup | Cost | Air-Gapped |
|----------|-------------|-------|------|------------|
| Azure OpenAI | Enterprise Azure customers | 10 min | Pay-per-use | No |
| Ollama | Air-gapped, cost-sensitive, dev/test | 30 min | Free | Yes |
| vLLM | High-performance inference | 1 hour | Infra only | Yes |
| OpenShift AI | Red Hat managed AI | 30 min | Subscription | Yes |

#### RHDH-Specific Section: Side-by-Side Comparison
Complete comparison table: Backstage vs RHDH for every deployment aspect.

Include ALL references from Task 1 PLUS:
- RHDH Lightspeed: https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.8/html-single/interacting_with_red_hat_developer_lightspeed_for_red_hat_developer_hub/index
- RHDH MCP Plugins: https://github.com/redhat-developer/rhdh-plugins/tree/main/workspaces/mcp-integrations
- Developer Lightspeed Product: https://developers.redhat.com/products/rhdh/developer-lightspeed

---

## TASK 5 — RHDH Deployment Diagrams (FigJam)

### 📎 Output
- 8 FigJam diagrams

### 📝 Instructions

Same rules as Task 2. RHDH-specific diagrams:

1. **RHDH 5-Layer Architecture** — Same as Backstage BUT with Layer 4 (Lightspeed) highlighted
2. **MCP Install Comparison** — Side-by-side: Backstage (6 steps, 30-60 min) vs RHDH (3 steps, 5 min)
3. **Developer Lightspeed Full Architecture** — User → Frontend → Backend → LCS → Llama Stack → LLM (BYOM)
4. **BYOM Provider Decision Tree** — Flowchart: Air-gapped? → Ollama. Enterprise Azure? → Azure OpenAI. etc.
5. **Lightspeed + MCP Integration** — Chat query → LCS → Llama Stack → MCP tool call → Catalog → Response with citations
6. **RHDH Helm Deployment Stack** — Helm chart → Pod (Backstage + LCS sidecar + Llama Stack sidecar + RAG init)
7. **RBAC for AI Features** — User → RBAC check → Lightspeed/MCP permissions
8. **Agent Handoff for RHDH Deployment** — 15 agents, rhdh-expert as hub

---

## TASK 6 — RHDH Config Files & Agent Definitions

### 📎 Output
Same structure as Task 3 but for RHDH. Key differences:

```
three-horizons-rhdh/
├── AGENTS.md
├── .github/
│   ├── agents/
│   │   ├── rhdh-deployer.agent.md         # Deploy RHDH to AKS/ARO
│   │   ├── mcp-enabler.agent.md           # Enable MCP dynamic plugins
│   │   ├── lightspeed-deployer.agent.md   # Deploy Lightspeed stack
│   │   ├── byom-config.agent.md           # Configure BYOM provider
│   │   ├── rbac-ai-config.agent.md        # Configure RBAC for AI
│   │   └── rhdh-tester.agent.md           # Validate MCP + Lightspeed
│   ├── skills/
│   │   ├── rhdh-dynamic-plugins/SKILL.md
│   │   ├── lightspeed-deploy/SKILL.md
│   │   ├── llama-stack-config/SKILL.md
│   │   └── rhdh-rbac/SKILL.md
│   └── workflows/
│       ├── deploy-rhdh-mcp.yml
│       ├── deploy-lightspeed.yml
│       └── test-lightspeed-chat.yml
├── .vscode/mcp.json                       # Same MCP servers as Backstage
├── configs/
│   ├── dynamic-plugins-mcp.yaml
│   ├── dynamic-plugins-lightspeed.yaml
│   ├── app-config-mcp.yaml
│   ├── app-config-lightspeed.yaml
│   ├── configmaps/
│   │   ├── lcs-config.yaml
│   │   ├── llama-stack-azure-openai.yaml
│   │   ├── llama-stack-ollama.yaml
│   │   └── llama-stack-vllm.yaml
│   ├── helm/
│   │   ├── values-mcp-only.yaml
│   │   ├── values-lightspeed.yaml
│   │   └── values-complete.yaml
│   └── rbac/
│       └── permission-policies-ai.csv
├── foundry/
│   ├── rhdh-agent.py
│   └── lightspeed-monitor-agent.py
└── custom-mcp-server/
    └── (same as Backstage)
```

---

## TASK 7 — AiKA-like MVP: Build & Deploy Guide

### 📎 Output
- `backstage_aika_mvp_deploy_v1.0.docx` + `.md`

### 📝 Instructions

**The big question:** Can we build an AiKA-equivalent for open-source Backstage using Azure AI Foundry + GitHub Agents? **YES.**

This document shows HOW TO BUILD AND DEPLOY it, not just what it is.

**Architecture:**
```
Backstage Frontend (AI Chat Plugin)
  ↓ REST API
Backstage Backend (AI Chat Backend Plugin)
  ↓ Azure SDK
Azure AI Foundry Agent Service
  ├── Model: GPT-4o / GPT-5.2 (Azure OpenAI)
  ├── Knowledge: Azure AI Search (TechDocs + Catalog indexed)
  ├── MCP Tools: Backstage MCP (/api/mcp-actions/v1)
  ├── Memory: Foundry Agent Memory (cross-session)
  └── Control: Content filtering, grounding, guardrails
```

**HOW TO BUILD using GitHub Agents:**

Step 1: Create GitHub Issues and assign to Copilot Coding Agent:
```
Issue 1: "Scaffold Backstage frontend plugin @internal/plugin-ai-chat with React chat UI, 
streaming responses (SSE), markdown rendering, citation links, suggested prompts"

Issue 2: "Scaffold Backstage backend plugin @internal/plugin-ai-chat-backend with Azure 
Foundry SDK integration, chat session management, MCP tool proxying"

Issue 3: "Create Azure Function for indexing TechDocs + Catalog into Azure AI Search.
Run daily. Use text-embedding-3-large, hybrid search, 512 token chunks."

Issue 4: "Create Terraform for Azure infrastructure: AI Foundry Project, OpenAI deployment,
AI Search service, Function App, Key Vault, Managed Identity"

Issue 5: "Create Foundry agent with Backstage MCP + AI Search RAG + memory"
```

Step 2: Review PRs from Coding Agent, iterate via comments

Step 3: Use Copilot Agent Mode in VS Code for integration work:
```
Prompt: "Wire the AI Chat backend to call the Foundry agent. When the agent 
uses the catalog-query MCP tool, proxy it through our Backstage MCP endpoint. 
Stream the response back to the frontend via SSE."
```

Step 4: Deploy using GitHub Actions + Azure MCP

**Development Timeline:** 6 weeks with 1-2 developers + Copilot agents

**Feature comparison with AiKA:** Include full table.

**Azure Infrastructure (Terraform):**
- Azure AI Foundry Project
- Azure OpenAI Service (GPT-4o)
- Azure AI Search (RAG index)
- Azure Functions (TechDocs indexer)
- Azure Key Vault
- Azure Monitor
- All with Managed Identity

Include ALL references from previous tasks plus Copilot SDK documentation.

---

## TASK 8 — AiKA MVP Diagrams (FigJam)

### 📎 Output
- 6 FigJam diagrams

### 📝 Instructions

1. **MVP Complete Architecture** — Full stack with Azure services
2. **RAG Pipeline** — TechDocs → Azure Function → Chunking → Embedding → AI Search → Response
3. **Chat Interaction Sequence** — User → Plugin → Foundry Agent → MCP/RAG → Stream back
4. **Azure Infrastructure** — All Azure services connected
5. **GitHub Coding Agent Build Flow** — Issues → Agent → PRs → Review → Merge → Deploy
6. **AiKA vs MVP Feature Comparison** — Visual grid

---

## TASK 9 — Multi-Cloud Deployment Guide

### 📎 Output
- `multi_cloud_deploy_guide_v1.0.docx` + `.md`

### 📝 Instructions

Complete guide to deploy Backstage + RHDH with MCP across **Azure (primary), AWS, GCP, and On-Premise**.

**For EACH cloud, cover:**
1. Kubernetes service setup (AKS / EKS / GKE / OpenShift / k3s)
2. Container registry (ACR / ECR / Artifact Registry / Harbor)
3. Secrets management (Key Vault / Secrets Manager / Secret Manager / Vault)
4. MCP server deployment (same MCP, different infra)
5. Auth integration (Entra ID / IAM Roles / Workload Identity / LDAP)
6. CI/CD pipeline (GitHub Actions with cloud-specific deploy steps)
7. Monitoring (Azure Monitor / CloudWatch / Cloud Monitoring / Prometheus)

**Using GitHub Copilot Agent Mode for each cloud:**
```
# Azure (primary)
Prompt: "Deploy Backstage with MCP to AKS using Azure MCP server for resource management"

# AWS  
Prompt: "Deploy Backstage with MCP to EKS. Use IRSA for auth, ECR for images, 
Secrets Manager for MCP tokens. Create GitHub Actions workflow."

# GCP
Prompt: "Deploy Backstage with MCP to GKE. Use Workload Identity, Artifact Registry, 
Secret Manager. Create deployment manifests."

# On-Premise
Prompt: "Deploy RHDH with MCP to OpenShift on-premise. Use Ollama for air-gapped 
Lightspeed. Harbor for images. HashiCorp Vault for secrets."
```

**Multi-cloud MCP architecture:**
All clouds use the SAME MCP endpoint format. AI clients don't care where Backstage runs.
The custom MCP server is cloud-agnostic — just change the deployment target.

**Terraform modules per cloud** — show complete infrastructure as code.

---

## TASK 10 — Multi-Cloud Diagrams (FigJam)

### 📎 Output
- 6 FigJam diagrams

### 📝 Instructions

1. **Multi-Cloud Overview** — 4 columns: Azure, AWS, GCP, On-Prem with equivalent services
2. **Azure Primary Architecture** — Full AKS + ACR + Foundry + AI Search stack
3. **AWS Architecture** — EKS + ECR + Secrets Manager
4. **GCP Architecture** — GKE + Artifact Registry + Secret Manager
5. **On-Premise Architecture** — OpenShift + Harbor + Vault + Ollama (air-gapped)
6. **GitHub Actions Multi-Cloud Pipeline** — Single workflow deploying to all clouds

---

## TASK 11 — GitHub + Foundry Agent Ecosystem (Complete)

### 📎 Output
- `agent_ecosystem_github_foundry_v1.0.md`
- All agent, skill, MCP config files

### 📝 Instructions

Create the **complete agent ecosystem** document with every file needed.

**Structure:**

1. **Official MCP Servers Registry**

| Server | Source | URL | Use Case |
|--------|--------|-----|----------|
| Azure MCP | microsoft/mcp | mcp.ai.azure.com | Azure resource management |
| AKS MCP | Azure/mcp-kubernetes | Local STDIO | K8s cluster management |
| GitHub MCP | Built into Copilot CLI | api.githubcopilot.com/mcp/ | Repo, issues, PRs |
| Foundry MCP | Azure AI Foundry | mcp.ai.azure.com | Model catalog, agents, evals |
| Microsoft Learn MCP | Microsoft | learn.microsoft.com/api/mcp | Official docs grounding |
| Backstage MCP | @backstage/plugin | Self-hosted | Catalog + TechDocs queries |
| RHDH MCP | rhdh-plugins | Self-hosted | Same + MCP Extras |

2. **Official Skills Registry** (from microsoft/skills)

| Skill | Domain | Install |
|-------|--------|---------|
| azure-kubernetes-service | AKS management | `cp -r skills/azure-kubernetes-service .github/skills/` |
| azure-container-registry | ACR management | `cp -r skills/azure-container-registry .github/skills/` |
| mcp-builder | Create MCP servers | `/plugin install deep-wiki@skills` |
| azure-identity | Entra ID, Managed Identity | from microsoft/skills |
| azure-key-vault | Secrets management | from microsoft/skills |
| azure-ai-search | RAG, vector search | from microsoft/skills |
| azure-openai | LLM integration | from microsoft/skills |
| azure-functions | Serverless | from microsoft/skills |
| azure-monitor | Observability | from microsoft/skills |

3. **Custom Skills to Create**

| Skill | Purpose |
|-------|---------|
| backstage-plugins | Install/configure Backstage plugins |
| rhdh-dynamic-plugins | Enable RHDH dynamic plugins |
| mcp-protocol | MCP protocol patterns |
| lightspeed-deploy | Deploy Lightspeed stack |
| llama-stack-config | Configure Llama Stack BYOM |
| backstage-aika-mvp | Build AiKA-like features |

4. **Custom Agents to Create**

For both repos. Each with `.agent.md`, tools, MCP servers, skills.

5. **Agentic Workflows** (GitHub Actions with AI)

Workflows that use Copilot Coding Agent for automated tasks.

6. **Copilot CLI Plugins**

How to create installable plugins bundling agents + skills + MCP servers.

7. **Foundry Agents**

Python code for each Foundry agent with MCP tools.

---

## TASK 12 — Master Index & Cross-Reference

### 📎 Output
- `mcp_ai_deploy_master_index_v1.0.md`

### 📝 Instructions

Cross-reference ALL deliverables from Tasks 1-11:

1. **Document Map** — Every DOCX, MD, diagram with description
2. **Quick Start Paths:**
   - "Connect VS Code Copilot to Backstage" → Task 1 Section 4 + Task 3 clients/vscode-mcp.json
   - "Deploy MCP on RHDH" → Task 4 Section 3 + Task 6 dynamic-plugins-mcp.yaml
   - "Get AI chat in RHDH" → Task 4 Lightspeed Section + Task 6 values-lightspeed.yaml
   - "Build AiKA for Backstage" → Task 7 + Task 8 + Task 3 foundry/
   - "Deploy to AWS" → Task 9 AWS Section
   - "Set up Copilot CLI with all MCP" → Task 11 Section 1
3. **Technology Matrix** — What's available per platform
4. **Agent Registry** — All agents with purpose, platform, tools
5. **MCP Server Registry** — Official + custom
6. **Skill Registry** — Official + custom
7. **Config File Index** — Every file, path, purpose, task source
8. **References** — All URLs consolidated

---

## 📌 Execution Summary

```
Total tasks: 12
DOCX files: 4 (Tasks 1, 4, 7, 9)
Markdown files: 6+ (Tasks 1, 4, 7, 9, 11, 12)
FigJam diagrams: 28 (Tasks 2, 5, 8, 10)
Config files: 60+ (Tasks 3, 6, 11)
Agent definitions: 15+ (Tasks 3, 6, 11)
Skill definitions: 10+ (Tasks 3, 6, 11)
GitHub workflows: 6+ (Tasks 3, 6)
Foundry agents: 4+ (Tasks 3, 6, 7)

Execution order:
Phase 1: Tasks 1-3 (Backstage: guide + diagrams + configs)
Phase 2: Tasks 4-6 (RHDH: guide + diagrams + configs)
Phase 3: Tasks 7-8 (AiKA MVP: guide + diagrams)
Phase 4: Tasks 9-10 (Multi-cloud: guide + diagrams)
Phase 5: Tasks 11-12 (Agent ecosystem + master index)
```
