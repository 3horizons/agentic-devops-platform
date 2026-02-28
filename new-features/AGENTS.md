# RHDH Agents Guide

This repository contains agents and workflows for Red Hat Developer Hub (RHDH) deployment and AI feature configuration. RHDH extends Backstage with enterprise-grade capabilities and AI-powered Developer Lightspeed features.

## Key Differences: RHDH vs Backstage

### 1. Dynamic Plugins (YAML-Only)
- **Backstage**: Requires code changes + npm install + rebuild
- **RHDH**: All plugins configured in `dynamic-plugins.yaml`
- **Agent Tool**: `mcp-enabler.agent.md` — Edit `dynamic-plugins.yaml` to enable/disable MCP plugins
- **Config File**: `configs/dynamic-plugins-mcp.yaml` (4 MCP plugins pre-configured)

### 2. Developer Lightspeed
- **What**: AI-powered chat, code generation, and documentation assistant
- **Components**:
  - Lightspeed Chat Service (LCS) — FastAPI backend
  - Llama Stack — Model orchestration (Azure OpenAI / Ollama / vLLM)
  - RAG Engine — Retrieval-augmented generation for docs/code
- **Agent Tool**: `lightspeed-deployer.agent.md` — Deploy Lightspeed stack to Kubernetes
- **BYOM Configuration**: `byom-config.agent.md` — Choose Azure OpenAI vs Ollama vs vLLM

### 3. Built-in RBAC with AI Feature Granularity
- **Backstage**: Basic role-based access control
- **RHDH**: CSV-based permission policies with AI-specific actions:
  - `lightspeed.chat` — Access Lightspeed chat
  - `lightspeed.chat.history.delete` — Delete conversation history
  - `mcp.tools.execute` — Execute MCP tools
- **Agent Tool**: `rbac-ai-config.agent.md` — Edit `configs/rbac/permission-policies-ai.csv`
- **Example**: All developers can chat with Lightspeed; only admins can delete history

### 4. Helm-Based Deployment (No Kustomize)
- **Backstage**: kustomize overlays
- **RHDH**: Helm charts with environment-specific values files
- **Helm Values**:
  - `configs/helm/values-mcp-only.yaml` — MCP plugins only
  - `configs/helm/values-lightspeed.yaml` — Lightspeed stack
  - `configs/helm/values-complete.yaml` — MCP + Lightspeed

## Agent Workflows

### Deploy RHDH to Kubernetes
```
rhdh-deployer.agent.md
├── Target: AKS or ARO
├── Tool: azure CLI + kubectl
└── Helm chart: redhat-developer-hub/rhdh
```

### Enable Dynamic MCP Plugins
```
mcp-enabler.agent.md
├── Edit: dynamic-plugins.yaml
├── Plugins: 4 MCP servers (Filesystem, Git, Kubernetes, GitHub)
└── Tool: GitHub API
```

### Deploy Lightspeed Stack
```
lightspeed-deployer.agent.md
├── Deploy LCS (Lightspeed Chat Service)
├── Deploy Llama Stack (with BYOM provider)
├── Deploy RAG engine
└── Tool: kubectl + helm
```

### Configure BYOM Provider
```
byom-config.agent.md
├── Decision Tree:
│   ├── Azure OpenAI → configs/configmaps/llama-stack-azure-openai.yaml
│   ├── Ollama → configs/configmaps/llama-stack-ollama.yaml
│   └── vLLM → configs/configmaps/llama-stack-vllm.yaml
└── Tool: Azure CLI (for credential setup)
```

### Configure RBAC for AI
```
rbac-ai-config.agent.md
├── Edit: permission-policies-ai.csv
├── Rows: [subject, action, resource, effect]
└── Examples:
    ├── developers | lightspeed.chat | chat | allow
    ├── admins | lightspeed.chat.history.delete | chat | allow
    └── all | mcp.tools.execute | * | allow
```

### Test MCP + Lightspeed
```
rhdh-tester.agent.md
├── Validation:
│   ├── MCP plugins enabled in UI
│   ├── Lightspeed chat responsive
│   └── LCS ↔ Llama Stack connectivity
└── Tools: backstage API + kubectl logs
```

## GitHub Workflows

### deploy-rhdh-mcp.yml
- Trigger: Push to `configs/helm/values-mcp-only.yaml`
- Steps: Build → Push Helm chart → Deploy to AKS/ARO
- Output: RHDH instance with 4 MCP plugins enabled

### deploy-lightspeed.yml
- Trigger: Push to `configs/helm/values-lightspeed.yaml`
- Steps: Build → Deploy LCS → Deploy Llama Stack → Deploy RAG
- Output: Full Lightspeed stack + RHDH instance

### test-lightspeed-chat.yml
- Trigger: Scheduled daily (9 AM UTC)
- Steps:
  1. Authenticate to RHDH
  2. Send test query to Lightspeed chat
  3. Assert response time < 5s
  4. Report metrics to monitoring system
- Output: Chat endpoint health + response time metrics

## File Structure

```
three-horizons-rhdh/
├── AGENTS.md                           # This file
├── .github/
│   ├── agents/
│   │   ├── rhdh-deployer.agent.md
│   │   ├── mcp-enabler.agent.md
│   │   ├── lightspeed-deployer.agent.md
│   │   ├── byom-config.agent.md
│   │   ├── rbac-ai-config.agent.md
│   │   └── rhdh-tester.agent.md
│   ├── skills/
│   │   ├── rhdh-dynamic-plugins/SKILL.md
│   │   ├── lightspeed-deploy/SKILL.md
│   │   ├── llama-stack-config/SKILL.md
│   │   └── rhdh-rbac/SKILL.md
│   └── workflows/
│       ├── deploy-rhdh-mcp.yml
│       ├── deploy-lightspeed.yml
│       └── test-lightspeed-chat.yml
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
├── .vscode/
│   └── mcp.json
└── foundry/
    ├── rhdh-agent.py
    └── lightspeed-monitor-agent.py
```

## Quick Start

1. **Deploy RHDH + MCP**: Run `deploy-rhdh-mcp.yml` workflow
2. **Add Lightspeed**: Run `deploy-lightspeed.yml` workflow
3. **Validate**: Run `rhdh-tester.agent.md` agent
4. **Configure RBAC**: Use `rbac-ai-config.agent.md` to define permissions
5. **Monitor Lightspeed**: View metrics from `lightspeed-monitor-agent.py`

## Notes

- All dynamic plugins configured via YAML; no code changes needed
- Lightspeed supports pluggable BYOM providers (bring your own model)
- RBAC policies updated via CSV; no database migrations required
- Helm-based deployment enables GitOps + ArgoCD integration
- MCP servers provide filesystem, Git, Kubernetes, GitHub access to agents

