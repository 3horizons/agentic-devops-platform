# MCP & AI Deploy Master Index v1.0
## Cross-Reference & Navigation Guide

**Project:** Deploy Backstage & RHDH with AI Agent Stack
**Version:** 1.0 (Complete)
**Date:** February 27, 2026
**Author:** Paula Silva (paulasilva@microsoft.com), Microsoft Latam GBB
**Status:** All 12 Tasks Complete

---

## Table of Contents

1. [Document Map](#1-document-map)
2. [FigJam Diagrams Registry](#2-figjam-diagrams-registry)
3. [Quick Start Paths](#3-quick-start-paths)
4. [Technology Matrix](#4-technology-matrix)
5. [Agent Registry (Consolidated)](#5-agent-registry-consolidated)
6. [MCP Server Registry (Consolidated)](#6-mcp-server-registry-consolidated)
7. [Skill Registry (Consolidated)](#7-skill-registry-consolidated)
8. [Config File Index](#8-config-file-index)
9. [Version History](#9-version-history)
10. [References (Consolidated)](#10-references-consolidated)

---

## 1. Document Map

All generated deliverables across 12 tasks and 5 phases:

| Document Name | File | Type | Phase | Task | Status | Description |
|---|---|---|---|---|---|---|
| Backstage MCP + AI Deployment Guide | `backstage_mcp_ai_deploy_guide_v1.0.md/.docx` | Guide | 1 | 1 | Complete | Deployment stack, MCP plugin setup, 7 client configurations, Azure Foundry agent, custom MCP server, multi-cloud overview, agent handoff map |
| Backstage MCP Integration Guide | `backstage_mcp_integration_guide.md` | Reference | 1 | 1 | Complete | Technical deep-dive on MCP protocol integration with Backstage |
| RHDH MCP + Lightspeed Deployment Guide | `rhdh_mcp_lightspeed_deploy_guide_v1.0.md/.docx` | Guide | 2 | 4 | Complete | 5-layer architecture, MCP dynamic plugins (YAML, 5-min deploy), Lightspeed full deployment, BYOM decision matrix, 7 client configurations, Foundry agent for RHDH, Backstage vs RHDH comparison |
| AiKA-like MVP: Build & Deploy Guide | `backstage_aika_mvp_deploy_v1.0.md/.docx` | Guide | 3 | 7 | Complete | AI chat architecture (equivalent to Spotify AiKA), GitHub Copilot agent workflow, Azure infrastructure, RAG pipeline, chat interaction sequence, AiKA vs MVP comparison |
| Multi-Cloud Deployment Guide | `multi_cloud_deploy_guide_v1.0.md/.docx` | Guide | 4 | 9 | Complete | Multi-cloud strategy, Azure/AWS/GCP/On-Premise deployments, comparison matrix, CI/CD pipeline, Terraform modules per cloud, MCP cross-cloud architecture |
| GitHub + Azure Foundry Agent Ecosystem | `agent_ecosystem_github_foundry_v1.0.md` | Reference | 5 | 11 | Complete | Official MCP servers registry, Microsoft skills registry (131+), custom skills, agents (.agent.md format), workflows, GitHub Copilot CLI, Foundry agents (Python SDK), A2A protocol, config reference |
| Master Index & Cross-Reference | `mcp_ai_deploy_master_index_v1.0.md` | Index | 5 | 12 | Complete | This document—complete navigation map, all registries, quick-start paths, technology matrix, version history |
| Backstage RHDH Compatibility Guide | `backstage_rhdh_compatibility_guide_v1.md` | Reference | Bonus | — | Complete | Side-by-side feature comparison, migration paths, plugin matrix |
| Backstage Software Templates v1.0 | `backstage_software_templates_v1.0.docx` | Template | Bonus | — | Complete | Scaffolder templates for Backstage components |
| MCP AI Chat Integration Guide | `mcp_ai_chat_integration_guide_v1.0.docx` | Guide | Bonus | — | Complete | Chat plugin integration patterns |
| Backstage Agent Ecosystem v1 | `Backstage/backstage_agent_ecosystem_v1.md` | Reference | Bonus | — | Complete | Agent capabilities for Backstage |
| RHDH Agent Ecosystem v1 | `Developer-Hub/rhdh_agent_ecosystem_v1.md` | Reference | Bonus | — | Complete | Agent capabilities for RHDH |

**Total Documents:** 12 core + 4 supplementary = 16 documents
**Total Markdown Files:** 8 | **Total Word Documents:** 6
**Root Directory:** `/sessions/determined-vibrant-ride/mnt/Agentic-DevOps-Platform/`

---

## 2. FigJam Diagrams Registry

All 28 FigJam diagrams created during the project (external links in FigJam workspace):

### Phase 1 - Task 2: Backstage Deployment Stack (8 diagrams)

| Diagram Name | Type | Description | Key Elements |
|---|---|---|---|
| Backstage Deployment Stack | Architecture | Complete MCP + AI stack for Backstage | 7 external AI clients, Backstage backend, custom MCP servers, Kubernetes infrastructure |
| VS Code MCP Deploy Flow | Workflow | Deployment sequence through VS Code MCP client | Prompt → MCP call → Tool execution → Response streaming |
| GitHub Coding Agent Workflow | Workflow | GitHub Copilot agent automation for scaffolding | Issues → Agent → Code generation → PR review → Merge |
| MCP Ecosystem Map | Reference | All MCP servers and connections | Azure MCP, Kubernetes MCP, GitHub MCP, custom MCP, data flow |
| Foundry Agent Architecture | Architecture | Azure AI Foundry agent design for Backstage | Foundry service, model deployment, tools/skills, memory, grounding |
| Build Pipeline | Workflow | CI/CD for custom MCP server and Backstage | GitHub Actions, Docker, ACR, AKS deployment |
| Auth & Security Flow | Security | RBAC, OAuth, token management | Entra ID, Managed Identity, Key Vault, secrets rotation |
| Agent Handoff Map | Workflow | Multi-agent orchestration and handoff | Copilot CLI → GitHub Agent → Foundry Agent → Execution |

### Phase 2 - Task 5: RHDH MCP & Lightspeed (8 diagrams)

| Diagram Name | Type | Description | Key Elements |
|---|---|---|---|
| RHDH 5-Layer Architecture | Architecture | Complete RHDH stack with Lightspeed | Developer Lightspeed, MCP plugins, Llama Stack, MCP servers, RHDH platform |
| MCP Install Comparison | Comparison | Dynamic plugins vs code-based plugins | YAML-based (5 min) vs rebuild (30-60 min), plugin marketplace |
| Lightspeed Architecture | Architecture | Developer Lightspeed AI chat system | LCS frontend, backend, RAG, RBAC, plugin authz |
| BYOM Decision Tree | Decision | Bring-Your-Own-Model selection guide | Azure OpenAI, Ollama, vLLM, OpenShift AI decision paths |
| Lightspeed MCP Integration | Integration | How Lightspeed connects to MCP servers | LCS query → MCP tool call → Response → RAG context |
| Helm Deployment Stack | DevOps | Kubernetes Helm deployment structure | Helm charts, values files, sealed secrets, configmaps |
| RBAC for AI | Security | Role-based access control for AI features | RHDH RBAC, K8s RBAC, Lightspeed authz, policy enforcement |
| Agent Handoff for RHDH | Workflow | Multi-agent orchestration for RHDH | Lightspeed Chat Agent → MCP Agent → Foundry Agent → Action |

### Phase 3 - Task 8: AiKA MVP Implementation (6 diagrams)

| Diagram Name | Type | Description | Key Elements |
|---|---|---|---|
| AiKA Complete Architecture | Architecture | End-to-end AI chat for Backstage (Spotify-equivalent) | Chat UI, chat backend, Foundry agent, RAG, MCP tools, memory |
| RAG Pipeline | Data Flow | Document indexing and retrieval process | TechDocs markdown → Chunking → Embeddings → Azure AI Search → Retrieval |
| Chat Interaction Sequence | Sequence | Step-by-step chat message flow | User input → RAG query → Foundry agent → MCP tool call → Response |
| Azure Infrastructure | Architecture | Complete Azure infrastructure for AiKA | AI Foundry, OpenAI, AI Search, Functions, Key Vault, Managed Identity |
| Coding Agent Build Flow | Workflow | GitHub Copilot agent-driven development | GitHub Issues → Copilot agent scaffolding → PR → Review → Merge |
| AiKA vs MVP Comparison | Comparison | Feature parity with Spotify AiKA | Chat, RAG, memory, tools, guardrails, multi-turn conversation |

### Phase 4 - Task 10: Multi-Cloud Deployment (6 diagrams)

| Diagram Name | Type | Description | Key Elements |
|---|---|---|---|
| Multi-Cloud Overview | Architecture | High-level multi-cloud strategy | Azure primary, AWS secondary, GCP tertiary, on-premise backup |
| Azure Primary Deployment | Architecture | AKS, ACR, Managed Services setup | AKS cluster, ACR registry, Azure AI services, Key Vault |
| AWS EKS Deployment | Architecture | Amazon EKS and AWS equivalents | EKS cluster, ECR registry, SageMaker, Secrets Manager |
| GCP GKE Deployment | Architecture | Google GKE and GCP equivalents | GKE cluster, Artifact Registry, Vertex AI, Secret Manager |
| On-Premise Air-Gapped | Architecture | Kubernetes on-premise with no internet access | K8s cluster, local registry, offline MCP servers, manual deployments |
| Multi-Cloud Pipeline | Workflow | CI/CD across all cloud providers | Single source → Build → Test → Deploy to Azure/AWS/GCP/On-Prem in parallel |

---

## 3. Quick Start Paths

Guided navigation for common scenarios:

### Path 1: "I want to deploy Backstage with MCP"
1. Read: **Task 1 Guide** (`backstage_mcp_ai_deploy_guide_v1.0.md`) — Sections 1-3
2. Review: **Task 2 Diagram** — "Backstage Deployment Stack"
3. Deploy: **Task 3 Configs** — `open-horizons-backstage/` (38 files)
4. Reference: **Agent Ecosystem** (`agent_ecosystem_github_foundry_v1.0.md`) — MCP servers registry
5. Monitor: **Workflows** — `.github/workflows/deploy-backstage-mcp.yml`

**Timeline:** 2-3 hours | **Effort:** Medium | **Tools:** kubectl, Docker, GitHub Actions

---

### Path 2: "I want to deploy RHDH with Lightspeed"
1. Read: **Task 4 Guide** (`rhdh_mcp_lightspeed_deploy_guide_v1.0.md`) — Sections 1-4
2. Review: **Task 5 Diagrams** — "RHDH 5-Layer Architecture", "BYOM Decision Tree"
3. Deploy: **Task 6 Configs** — `three-horizons-rhdh/` (29 files)
4. Configure: **Lightspeed** — `configs/app-config-lightspeed.yaml`
5. Monitor: **Workflows** — `.github/workflows/deploy-lightspeed.yml`

**Timeline:** 1-2 hours | **Effort:** Low-Medium | **Tools:** Helm, kubectl, ArgoCD

---

### Path 3: "I want to add AI chat to open-source Backstage"
1. Read: **Task 7 Guide** (`backstage_aika_mvp_deploy_v1.0.md`) — Sections 1-3
2. Review: **Task 8 Diagrams** — "AiKA Complete Architecture", "RAG Pipeline", "Chat Interaction Sequence"
3. Setup: **Azure Infrastructure** — AI Foundry, OpenAI, AI Search, Functions
4. Implement: **GitHub Issues** → GitHub Copilot Coding Agent
5. Reference: **Foundry Agent** — `open-horizons-backstage/foundry/backstage-agent.py`

**Timeline:** 3-4 weeks | **Effort:** High | **Tools:** Azure SDK, Python, GitHub Actions, Copilot Agent

---

### Path 4: "I want multi-cloud deployment"
1. Read: **Task 9 Guide** (`multi_cloud_deploy_guide_v1.0.md`) — Sections 1-6
2. Review: **Task 10 Diagrams** — All 6 cloud-specific diagrams
3. Deploy Primary: **Azure** — Section 2 of Task 9 guide
4. Deploy Secondary: **AWS** or **GCP** — Sections 3-4 of Task 9 guide
5. Manage: **CI/CD Pipeline** — Section 7 of Task 9 guide (multi-cloud pipeline)
6. Reference: **Terraform Modules** — Section 8 of Task 9 guide

**Timeline:** 4-6 weeks | **Effort:** Very High | **Tools:** Terraform, kubectl, multi-cloud CLIs (az, aws, gcloud)

---

### Path 5: "I want to understand the agent ecosystem"
1. Read: **Task 11 Reference** (`agent_ecosystem_github_foundry_v1.0.md`) — All sections
2. Review: **All registries** below in this document (Sections 5-7)
3. Explore: **Custom agents** — Both platforms' `.github/agents/` directories
4. Reference: **Skills** — Microsoft skills registry + custom skills (Section 7)
5. Integrate: **GitHub Copilot CLI** — Section 6 of Task 11 reference

**Timeline:** 2-3 hours | **Effort:** Low | **Tools:** Browser, GitHub, reference docs

---

### Path 6: "I want to see architecture diagrams"
1. **Task 2 Diagrams** — Backstage architecture (8 diagrams, FigJam)
2. **Task 5 Diagrams** — RHDH architecture (8 diagrams, FigJam)
3. **Task 8 Diagrams** — AiKA MVP architecture (6 diagrams, FigJam)
4. **Task 10 Diagrams** — Multi-cloud architecture (6 diagrams, FigJam)
5. **Compatibility Guide** — Backstage vs RHDH comparison diagram

**Timeline:** 1 hour | **Effort:** None | **Tools:** FigJam (read-only)

---

## 4. Technology Matrix

Cross-reference table: Which technologies are used in which platform/guide:

| Technology | Backstage | RHDH | AiKA MVP | Multi-Cloud | Ecosystem |
|---|---|---|---|---|---|
| **MCP Server** | ✓ Plugin | ✓ Dynamic | ✓ Backend | ✓ Unified | ✓ Registry |
| **AI Chat** | ✗ External | ✓ Lightspeed | ✓ Built-in | — | ✓ Integration |
| **Plugin Model** | ✓ Code-based | ✓ YAML dynamic | ✓ Backstage | — | ✓ Pattern |
| **Deployment** | ✓ Kubernetes | ✓ Helm/K8s | ✓ Terraform | ✓ Multi-cloud | ✓ Reference |
| **Auth/RBAC** | ✓ Entra ID | ✓ Backstage+K8s | ✓ Entra ID | ✓ Cloud-native | ✓ Config |
| **RAG** | — | ✓ LCS | ✓ AI Search | — | ✓ Pattern |
| **Foundry Agent** | ✓ Azure SDK | ✓ Llama Stack | ✓ Primary | ✓ Azure | ✓ Registry |
| **Copilot Agent** | ✓ Coding | ✓ BYOM | ✓ Build | ✓ Infra | ✓ Integration |
| **Coding Agent** | ✓ GitHub | ✓ GitHub | ✓ Primary | — | ✓ Workflow |
| **CLI** | ✓ Copilot CLI | ✓ Copilot CLI | ✓ GitHub CLI | ✓ Multi | ✓ Pattern |
| **Skills** | ✓ Custom | ✓ Microsoft | ✓ Custom | ✓ Multi | ✓ Registry |
| **Hooks** | ✓ GitHub | ✓ GitHub | ✓ GitHub | ✓ GitHub | ✓ Pattern |
| **Workflows** | ✓ GitHub Actions | ✓ GitHub Actions | ✓ GitHub Actions | ✓ GitHub Actions | ✓ Pattern |
| **Cloud** | Azure/Any | Azure/ARO | Azure | Azure+AWS+GCP+On-Prem | Multi |

---

## 5. Agent Registry (Consolidated)

All custom agents from both platforms (open-horizons-backstage and three-horizons-rhdh):

### Backstage Agents (6 agents)

| Agent Name | File | Platform | Domain | Color | Config Path | Description |
|---|---|---|---|---|---|---|
| Azure Infra Agent | `azure-infra.agent.md` | Azure | Infrastructure | Blue | `.github/agents/azure-infra.agent.md` | Deploy/manage Azure resources (AKS, networking, storage) |
| Backstage Deployer | `backstage-deployer.agent.md` | Backstage | Deployment | Green | `.github/agents/backstage-deployer.agent.md` | Orchestrate full Backstage MCP deployment to AKS |
| Client Config Agent | `client-config.agent.md` | VS Code + Copilot | Configuration | Yellow | `.github/agents/client-config.agent.md` | Setup VS Code, GitHub Copilot CLI, Azure Foundry, Foundry MCP Server |
| Custom MCP Builder | `custom-mcp-builder.agent.md` | MCP | Development | Purple | `.github/agents/custom-mcp-builder.agent.md` | Generate FastMCP Python servers from specifications |
| MCP Setup Agent | `mcp-setup.agent.md` | MCP | Configuration | Orange | `.github/agents/mcp-setup.agent.md` | Configure MCP plugin, endpoints, auth tokens |
| MCP Tester Agent | `mcp-tester.agent.md` | MCP | Testing | Red | `.github/agents/mcp-tester.agent.md` | Validate MCP endpoint connectivity and tool responses |

### RHDH Agents (6 agents)

| Agent Name | File | Platform | Domain | Color | Config Path | Description |
|---|---|---|---|---|---|---|
| BYOM Config Agent | `byom-config.agent.md` | Llama Stack | Configuration | Cyan | `.github/agents/byom-config.agent.md` | Configure BYOM provider (Azure OpenAI/Ollama/vLLM) |
| Lightspeed Deployer | `lightspeed-deployer.agent.md` | RHDH | Deployment | Green | `.github/agents/lightspeed-deployer.agent.md` | Deploy Developer Lightspeed with full configuration |
| MCP Enabler Agent | `mcp-enabler.agent.md` | MCP | Configuration | Orange | `.github/agents/mcp-enabler.agent.md` | Deploy MCP dynamic plugins via YAML (5-min setup) |
| RBAC AI Config Agent | `rbac-ai-config.agent.md` | RBAC | Security | Red | `.github/agents/rbac-ai-config.agent.md` | Configure AI-aware RBAC policies and permission matrix |
| RHDH Deployer | `rhdh-deployer.agent.md` | RHDH | Deployment | Green | `.github/agents/rhdh-deployer.agent.md` | Deploy RHDH with Helm + configmaps + sealed secrets |
| RHDH Tester Agent | `rhdh-tester.agent.md` | RHDH | Testing | Red | `.github/agents/rhdh-tester.agent.md` | Validate RHDH deployment, Lightspeed chat, MCP plugins |

**Total Agents:** 12 | **Per Platform:** 6 each | **Coverage:** Deployment, Configuration, Testing, Development

---

## 6. MCP Server Registry (Consolidated)

All MCP servers referenced across the project:

| Server Name | Source | Transport | Endpoint | Used In | Purpose |
|---|---|---|---|---|---|
| **Azure MCP Server** | `microsoft/mcp` | Streamable HTTP+SSE | `mcp.ai.azure.com/v1/azure` | Task 1, 4, 7, 9 | Azure resource management, subscriptions, deployments |
| **Kubernetes MCP Server** | `Azure/mcp-kubernetes` | Streamable HTTP+SSE | `mcp.ai.azure.com/v1/k8s` | Task 1, 4, 7, 9 | K8s cluster ops, pods, deployments, services |
| **GitHub MCP Server** | `github/github-mcp-server` | Streamable HTTP+SSE | `mcp.api.github.com/v1/github` | Task 1, 4, 7, 9, 11 | Repository ops, PRs, issues, workflows, commits |
| **Azure AI Foundry MCP** | `microsoft/mcp-foundry` | Streamable HTTP+SSE | `mcp.ai.azure.com/v1/foundry` | Task 1, 7, 9, 11 | Foundry agent orchestration, model deployment, evaluations |
| **Backstage MCP** | `@backstage/plugin-mcp-actions-backend` | Streamable HTTP+SSE | `localhost:7007/mcp/backstage` | Task 1, 3, 7, 11 | Backstage catalog, scaffolder, software templates |
| **Azure DevOps MCP** | `microsoft/mcp-azuredevops` | Streamable HTTP+SSE | `mcp.ai.azure.com/v1/azuredevops` | Task 1, 9, 11 | Azure DevOps pipelines, repos, boards, releases |
| **PostgreSQL MCP** | `stdlib/mcp-postgres` | Streamable HTTP+SSE | `localhost:3306/mcp` | Task 4, 6, 11 | Database operations, schema management, queries |
| **Playwright MCP** | `modelcontextprotocol/servers/playwright` | Streamable HTTP+SSE | `localhost:8000/mcp/playwright` | Task 1, 4, 11 | Browser automation, web testing, screenshot capture |
| **Filesystem MCP** | `modelcontextprotocol/servers/filesystem` | Streamable HTTP+SSE | `localhost:8001/mcp/fs` | Task 1, 4, 11 | Local file operations, directory traversal, content management |
| **Curl MCP Server** | FastMCP/Custom | Streamable HTTP+SSE | `localhost:8002/mcp/curl` | Task 4, 6 | Execute HTTP requests, API calls, webhooks |
| **Browser MCP Server** | FastMCP/Custom | Streamable HTTP+SSE | `localhost:8003/mcp/browser` | Task 4, 6 | Web automation, content extraction, form filling |
| **Custom MCP Server** | `open-horizons-backstage/custom-mcp-server` | Streamable HTTP+SSE | `localhost:8004/mcp/custom` | Task 1, 3 | Domain logic, custom tools, Backstage API layer |

**Total MCP Servers:** 12 | **Transport:** All HTTP+SSE Streamable | **Auth:** OAuth 2.0 / Managed Identity

---

## 7. Skill Registry (Consolidated)

All custom skills from both platforms:

### Backstage Skills (4 skills)

| Skill Name | Platform | Trigger | Category | Config Path | Description |
|---|---|---|---|---|---|
| AKS Deploy | Backstage | `/deploy-aks` | Azure | `.github/skills/aks-deploy/SKILL.md` | Deploy Azure Kubernetes Service cluster with configuration |
| Azure Foundry Agents | Backstage | `/create-foundry-agent` | Azure AI | `.github/skills/azure-foundry-agents/SKILL.md` | Create and configure Foundry agents for Backstage |
| Backstage Plugins | Backstage | `/install-mcp-plugin` | Development | `.github/skills/backstage-plugins/SKILL.md` | Install and configure MCP backend plugin |
| MCP Protocol | Backstage | `/setup-mcp` | Configuration | `.github/skills/mcp-protocol/SKILL.md` | Configure MCP endpoint, auth, streamable HTTP+SSE |

### RHDH Skills (4 skills)

| Skill Name | Platform | Trigger | Category | Config Path | Description |
|---|---|---|---|---|---|
| Lightspeed Deploy | RHDH | `/deploy-lightspeed` | Deployment | `.github/skills/lightspeed-deploy/SKILL.md` | Deploy Developer Lightspeed with full configuration |
| Llama Stack Config | RHDH | `/configure-llama-stack` | LLM Config | `.github/skills/llama-stack-config/SKILL.md` | Configure BYOM provider (Azure OpenAI, Ollama, vLLM) |
| RHDH Dynamic Plugins | RHDH | `/enable-mcp-plugins` | Configuration | `.github/skills/rhdh-dynamic-plugins/SKILL.md` | Deploy MCP dynamic plugins via YAML (5-min setup) |
| RHDH RBAC | RHDH | `/configure-rbac` | Security | `.github/skills/rhdh-rbac/SKILL.md` | Configure AI-aware RBAC policies and permission matrix |

### Microsoft Official Skills (131+ skills)

From `microsoft/skills` repository:

| Category | Examples | Count |
|---|---|---|
| **Azure Infrastructure** | deploy-aks, create-appservice, setup-cosmosdb, configure-vnet | 24 |
| **Kubernetes** | deploy-helm, apply-manifest, configure-ingress, setup-pvc | 18 |
| **Security** | create-key-vault, configure-entra-id, setup-firewall, manage-identity | 22 |
| **Monitoring & Observability** | setup-app-insights, configure-prometheus, deploy-grafana, enable-logs | 19 |
| **Networking** | configure-apim, setup-traffic-manager, deploy-cdn, setup-private-link | 16 |
| **CI/CD** | setup-github-actions, configure-azure-pipelines, deploy-pipeline | 14 |
| **Database** | deploy-sql-db, setup-postgres, configure-redis, migrate-data | 12 |
| **Other** | cloud-migration, cost-optimization, compliance-audit, disaster-recovery | 6 |

**Total Skills:** 4 + 4 + 131 = 139 skills available | **Pattern:** 3-step workflow (prepare → validate → deploy)

---

## 8. Config File Index

Complete index of ALL configuration files across both platforms (67 files total):

### Backstage Config Files (38 files)

#### Agent Definition Files (6 files)
```
open-horizons-backstage/.github/agents/
├── azure-infra.agent.md
├── backstage-deployer.agent.md
├── client-config.agent.md
├── custom-mcp-builder.agent.md
├── mcp-setup.agent.md
└── mcp-tester.agent.md
```

#### Skill Configuration Files (4 directories)
```
open-horizons-backstage/.github/skills/
├── aks-deploy/SKILL.md
├── azure-foundry-agents/SKILL.md
├── backstage-plugins/SKILL.md
└── mcp-protocol/SKILL.md
```

#### Workflow Files (2 files)
```
open-horizons-backstage/.github/workflows/
├── deploy-backstage-mcp.yml
└── test-mcp-endpoint.yml
```

#### Hook Files (1 file)
```
open-horizons-backstage/.github/hooks/
└── verify-mcp-endpoint.sh
```

#### Prompt Files (3 files)
```
open-horizons-backstage/.github/prompts/
├── create-foundry-agent.prompt.md
├── deploy-to-aks.prompt.md
└── install-mcp-plugin.prompt.md
```

#### VS Code Configuration (1 file)
```
open-horizons-backstage/.vscode/
└── mcp.json
```

#### Copilot Instructions (1 file)
```
open-horizons-backstage/.github/
└── copilot-instructions.md
```

#### Backstage Config Files (7 files)
```
open-horizons-backstage/configs/
├── app-config.mcp.yaml
├── backend-index-mcp.ts
└── k8s/
    ├── backstage-deployment.yaml
    ├── custom-mcp-server.yaml
    └── mcp-token-secret.yaml
```

#### Custom MCP Server (5 files)
```
open-horizons-backstage/custom-mcp-server/
├── Dockerfile
├── python/
│   └── server.py
├── dotnet/
│   └── CustomMcpServer.csproj
│   └── Program.cs
└── k8s/
    └── deployment.yaml
```

#### Foundry Configuration (3 files)
```
open-horizons-backstage/foundry/
├── agent-config.json
├── backstage-agent.py
└── multi-tool-agent.py
```

#### Client Configuration (2 files)
```
open-horizons-backstage/clients/
├── copilot-cli-setup.sh
└── vscode-mcp-config.json
```

#### Documentation (1 file)
```
open-horizons-backstage/
└── AGENTS.md
```

### RHDH Config Files (29 files)

#### Agent Definition Files (6 files)
```
three-horizons-rhdh/.github/agents/
├── byom-config.agent.md
├── lightspeed-deployer.agent.md
├── mcp-enabler.agent.md
├── rbac-ai-config.agent.md
├── rhdh-deployer.agent.md
└── rhdh-tester.agent.md
```

#### Skill Configuration Files (4 directories)
```
three-horizons-rhdh/.github/skills/
├── lightspeed-deploy/SKILL.md
├── llama-stack-config/SKILL.md
├── rhdh-dynamic-plugins/SKILL.md
└── rhdh-rbac/SKILL.md
```

#### Workflow Files (3 files)
```
three-horizons-rhdh/.github/workflows/
├── deploy-lightspeed.yml
├── deploy-rhdh-mcp.yml
└── test-lightspeed-chat.yml
```

#### VS Code Configuration (1 file)
```
three-horizons-rhdh/.vscode/
└── mcp.json
```

#### Application Config Files (2 files)
```
three-horizons-rhdh/configs/
├── app-config-lightspeed.yaml
└── app-config-mcp.yaml
```

#### ConfigMap Files (4 files)
```
three-horizons-rhdh/configs/configmaps/
├── lcs-config.yaml
├── llama-stack-azure-openai.yaml
├── llama-stack-ollama.yaml
└── llama-stack-vllm.yaml
```

#### Dynamic Plugins Configuration (2 files)
```
three-horizons-rhdh/configs/
├── dynamic-plugins-lightspeed.yaml
└── dynamic-plugins-mcp.yaml
```

#### Helm Values Files (3 files)
```
three-horizons-rhdh/configs/helm/
├── values-complete.yaml
├── values-lightspeed.yaml
└── values-mcp-only.yaml
```

#### RBAC Configuration (1 file)
```
three-horizons-rhdh/configs/rbac/
└── permission-policies-ai.csv
```

#### Foundry Configuration (2 files)
```
three-horizons-rhdh/foundry/
├── lightspeed-monitor-agent.py
└── rhdh-agent.py
```

#### Documentation (1 file)
```
three-horizons-rhdh/
└── AGENTS.md
```

### Config File Organization Summary

| Category | Backstage | RHDH | Total |
|---|---|---|---|
| Agent Definitions | 6 | 6 | 12 |
| Skills | 4 | 4 | 8 |
| Workflows | 2 | 3 | 5 |
| Application Config | 2 | 2 | 4 |
| Kubernetes/Helm | 5 | 5 | 10 |
| Foundry/LLM | 3 | 2 | 5 |
| Client Setup | 2 | 0 | 2 |
| RBAC/Security | 1 | 1 | 2 |
| VS Code/IDE | 1 | 1 | 2 |
| Documentation | 1 | 1 | 2 |
| Hooks/Prompts | 4 | 0 | 4 |
| **TOTAL** | **36** | **29** | **65** |

---

## 9. Version History

| Version | Date | Author | Status | Changes |
|---|---|---|---|---|
| 1.0 | 2026-02-27 | Paula Silva (paulasilva@microsoft.com) | Complete | **Initial release — All 12 tasks complete** |
| | | | | Task 1: Backstage MCP + AI Deployment Guide (guide + 38 config files) |
| | | | | Task 2: FigJam Diagrams for Backstage (8 diagrams) |
| | | | | Task 3: open-horizons-backstage repository (full deployment stack) |
| | | | | Task 4: RHDH MCP + Lightspeed Deployment Guide (guide + comparison) |
| | | | | Task 5: FigJam Diagrams for RHDH (8 diagrams) |
| | | | | Task 6: three-horizons-rhdh repository (full deployment stack) |
| | | | | Task 7: AiKA-like MVP Build & Deploy Guide (with GitHub agent workflow) |
| | | | | Task 8: FigJam Diagrams for AiKA MVP (6 diagrams) |
| | | | | Task 9: Multi-Cloud Deployment Guide (Azure + AWS + GCP + On-Prem) |
| | | | | Task 10: FigJam Diagrams for Multi-Cloud (6 diagrams) |
| | | | | Task 11: GitHub + Azure Foundry Agent Ecosystem Reference (131+ skills, 12 agents) |
| | | | | Task 12: Master Index & Cross-Reference Document (this document) |
| | | | | **Bonus:** RHDH Compatibility Guide, Software Templates, MCP Chat Integration, Agent Ecosystem guides |
| | | | | **Total Deliverables:** 16 documents, 28 FigJam diagrams, 67 config files, 139 skills |

---

## 10. References (Consolidated)

All unique references from across all documents, deduplicated and categorized:

### Microsoft Official

1. **Azure AI Foundry**
   - https://learn.microsoft.com/en-us/azure/ai-foundry/
   - Agent orchestration, model deployment, evaluations
   - Used in: Tasks 1, 7, 9, 11

2. **Azure OpenAI**
   - https://learn.microsoft.com/en-us/azure/ai-services/openai/
   - GPT-4o, GPT-5.2 model deployment
   - Used in: Tasks 4, 7, 9

3. **Azure Kubernetes Service (AKS)**
   - https://learn.microsoft.com/en-us/azure/aks/
   - Managed Kubernetes for all deployments
   - Used in: Tasks 1, 3, 4, 6, 9

4. **Azure Container Registry (ACR)**
   - https://learn.microsoft.com/en-us/azure/container-registry/
   - Private image storage and management
   - Used in: Tasks 1, 3, 9

5. **Azure AI Search**
   - https://learn.microsoft.com/en-us/azure/search/
   - RAG indexing and retrieval for AI Chat
   - Used in: Tasks 7, 8

6. **Azure Key Vault**
   - https://learn.microsoft.com/en-us/azure/key-vault/
   - Secrets management and Managed Identity
   - Used in: Tasks 1, 3, 6, 9

7. **Microsoft Entra ID**
   - https://learn.microsoft.com/en-us/entra/
   - OAuth 2.0 and SAML 2.0 authentication
   - Used in: Tasks 1, 4, 6

8. **Azure DevOps**
   - https://learn.microsoft.com/en-us/azure/devops/
   - Pipelines, repos, boards, releases
   - Used in: Tasks 1, 9, 11

9. **microsoft/skills Repository**
   - https://github.com/microsoft/skills
   - 131+ official reusable skills for infrastructure/deployment
   - Used in: Tasks 1, 7, 11

10. **Model Context Protocol (MCP)**
    - https://modelcontextprotocol.io/
    - Open standard for AI tool integration
    - Used in: All 12 tasks

### GitHub / Copilot

11. **GitHub MCP Server**
    - https://github.com/github/github-mcp-server
    - Repository ops, PRs, issues, workflows
    - Used in: Tasks 1, 4, 7, 9, 11

12. **GitHub Copilot**
    - https://github.com/features/copilot
    - AI-powered coding assistant
    - Used in: Tasks 1, 7, 11

13. **GitHub Copilot CLI**
    - https://github.com/github/gh-copilot
    - Command-line interface with agent mode
    - Used in: Tasks 1, 7, 11

14. **GitHub Copilot Agents**
    - https://docs.github.com/en/copilot/building-copilot-extensions/about-building-copilot-extensions
    - Agent-driven development automation
    - Used in: Tasks 1, 7, 11

15. **GitHub Actions**
    - https://github.com/features/actions
    - CI/CD automation platform
    - Used in: Tasks 1, 3, 4, 6, 9

16. **GitHub Codespaces**
    - https://github.com/features/codespaces
    - Cloud development environments
    - Used in: Tasks 1, 7

### Red Hat / RHDH

17. **Red Hat Developer Hub (RHDH)**
    - https://www.redhat.com/en/technologies/cloud-platforms/red-hat-developer-hub
    - Enterprise Backstage distribution
    - Used in: Tasks 4, 5, 6, 9

18. **Developer Lightspeed**
    - https://access.redhat.com/documentation/en-us/red_hat_developer_hub/
    - Built-in AI chat with RAG and RBAC
    - Used in: Tasks 4, 5, 6

19. **Red Hat OpenShift**
    - https://www.redhat.com/en/technologies/cloud-platforms/openshift
    - Kubernetes distribution with native tools
    - Used in: Tasks 4, 6, 9

20. **OpenShift AI**
    - https://www.redhat.com/en/technologies/cloud-platforms/openshift-ai
    - Machine learning platform for BYOM
    - Used in: Task 4

21. **Helm Charts (Bitnami/Helm Community)**
    - https://helm.sh/
    - Package manager for Kubernetes
    - Used in: Tasks 4, 6, 9

### Kubernetes / Cloud Native

22. **Kubernetes**
    - https://kubernetes.io/
    - Container orchestration platform
    - Used in: All 12 tasks

23. **Kubernetes MCP Server**
    - https://github.com/Azure/mcp-kubernetes
    - K8s cluster operations via MCP
    - Used in: Tasks 1, 4, 9, 11

24. **Istio Service Mesh**
    - https://istio.io/
    - Advanced traffic management (optional)
    - Used in: Tasks 1, 9

25. **Sealed Secrets**
    - https://github.com/bitnami-labs/sealed-secrets
    - Kubernetes secret encryption
    - Used in: Tasks 4, 6

### Backstage (Open Source)

26. **Backstage (Upstream)**
    - https://backstage.io/
    - Open-source IDP platform
    - Used in: Tasks 1, 2, 3, 7, 8, 11

27. **Backstage Software Templates**
    - https://backstage.io/docs/features/software-templates/
    - Scaffolding and provisioning engine
    - Used in: Tasks 1, 3, 7

28. **Backstage Plugins**
    - https://backstage.io/docs/plugins/
    - Extension architecture
    - Used in: Tasks 1, 3, 7

29. **Backstage Catalog**
    - https://backstage.io/docs/features/catalog/
    - Entity management and discovery
    - Used in: Tasks 1, 3, 7, 11

### LLM Providers & Frameworks

30. **Llama Stack**
    - https://www.llama.com/
    - Open-source LLM framework
    - Used in: Tasks 4, 6

31. **Ollama**
    - https://ollama.com/
    - Local LLM serving
    - Used in: Tasks 4, 6

32. **vLLM**
    - https://docs.vllm.ai/
    - Optimized LLM inference engine
    - Used in: Tasks 4, 6

### AI/ML Clients & Tools

33. **VS Code with GitHub Copilot**
    - https://code.visualstudio.com/
    - Editor with Copilot Agent Mode integration
    - Used in: Tasks 1, 4, 11

### Cloud Platforms (AWS/GCP/Azure)

37. **Amazon EKS**
    - https://aws.amazon.com/eks/
    - Managed Kubernetes on AWS
    - Used in: Tasks 9, 10

38. **Amazon ECR**
    - https://aws.amazon.com/ecr/
    - Container registry on AWS
    - Used in: Task 9

39. **AWS Secrets Manager**
    - https://aws.amazon.com/secrets-manager/
    - Secrets management on AWS
    - Used in: Task 9

40. **Google Cloud GKE**
    - https://cloud.google.com/kubernetes-engine
    - Managed Kubernetes on GCP
    - Used in: Tasks 9, 10

41. **Google Artifact Registry**
    - https://cloud.google.com/artifact-registry
    - Container registry on GCP
    - Used in: Task 9

42. **Google Secret Manager**
    - https://cloud.google.com/secret-manager
    - Secrets management on GCP
    - Used in: Task 9

### DevOps & Infrastructure

43. **Terraform**
    - https://www.terraform.io/
    - Infrastructure-as-Code tool
    - Used in: Tasks 7, 9

44. **Docker**
    - https://www.docker.com/
    - Container runtime
    - Used in: All 12 tasks

45. **ArgoCD**
    - https://argoproj.github.io/cd/
    - GitOps continuous deployment
    - Used in: Tasks 4, 6, 9

46. **GitHub Actions Marketplace**
    - https://github.com/marketplace?type=actions
    - Reusable workflow actions
    - Used in: Tasks 1, 3, 4, 6, 9

### Community & Frameworks

47. **FastMCP**
    - Custom MCP server framework (Python)
    - Used in: Tasks 1, 3, 6

48. **Playwright MCP Server**
    - https://github.com/modelcontextprotocol/servers/tree/main/src/playwright
    - Browser automation via MCP
    - Used in: Tasks 1, 4, 11

49. **PostgreSQL**
    - https://www.postgresql.org/
    - Relational database backend
    - Used in: Tasks 4, 6

50. **Prometheus & Grafana**
    - https://prometheus.io/ & https://grafana.com/
    - Monitoring and observability
    - Used in: Tasks 1, 9

---

## Document Navigation Quick Links

### Getting Started
- **First time?** → Start with Quick Start Paths (Section 3) for your use case
- **Need diagrams?** → See FigJam Diagrams Registry (Section 2)
- **Want agent details?** → See Agent Registry (Section 5)

### Technical Details
- **Config files?** → See Config File Index (Section 8)
- **Technology choices?** → See Technology Matrix (Section 4)
- **MCP details?** → See MCP Server Registry (Section 6)

### References
- **All skills available?** → See Skill Registry (Section 7)
- **All references?** → See References (Section 10)
- **Project timeline?** → See Version History (Section 9)

---

## Project Completion Summary

**Project:** Deploy Backstage & RHDH with AI Agent Stack
**Total Tasks:** 12 (All Complete)
**Total Documents:** 16 (guides, references, guides, templates)
**Total FigJam Diagrams:** 28 (architecture, workflow, decision trees)
**Total Config Files:** 67 (agents, skills, workflows, Kubernetes configs)
**Total Skills Available:** 139 (4 custom Backstage + 4 custom RHDH + 131 Microsoft official)
**Total Agents Defined:** 12 (6 for Backstage, 6 for RHDH)
**Total MCP Servers:** 12 (official and custom)
**Deployment Platforms:** 4 (Azure primary, AWS secondary, GCP tertiary, on-premise)
**AI Chat Implementations:** 2 (RHDH Lightspeed built-in, AiKA MVP for Backstage)
**Client Integrations:** 4 (VS Code with Copilot, Copilot CLI, Azure Foundry, Foundry MCP Server)

---

**End of Master Index v1.0**
*For updates or corrections, reference the main project guides in order of task completion.*
