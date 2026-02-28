# GitHub + Azure AI Foundry Agent Ecosystem Reference
**Version:** 1.0
**Date:** February 27, 2026
**Author:** Paula Silva (paulasilva@microsoft.com), Microsoft Latam GBB
**Project:** Backstage & RHDH with AI Agent Stack Deployment (Task 11 of 12)

---

## Table of Contents

1. [Official MCP Servers Registry](#1-official-mcp-servers-registry)
2. [Official Skills Registry (microsoft/skills)](#2-official-skills-registry-microsoftskills)
3. [Custom Skills to Create](#3-custom-skills-to-create)
4. [Custom Agents (.agent.md format)](#4-custom-agents-agentmd-format)
5. [Agentic Workflows (.github/workflows/)](#5-agentic-workflows-githubworkflows)
6. [GitHub Copilot CLI Integration](#6-github-copilot-cli-integration)
7. [Azure AI Foundry Agents (Python SDK)](#7-azure-ai-foundry-agents-python-sdk)
8. [Agent Memory & A2A Protocol](#8-agent-memory--a2a-protocol)
9. [Configuration Quick Reference](#9-configuration-quick-reference)
10. [References](#10-references)

---

## 1. Official MCP Servers Registry

The Model Context Protocol (MCP) enables standardized communication between AI agents and external tools/systems. Below is the comprehensive registry of official Microsoft MCP servers available for integration.

| Server Name | Source | Transport | Endpoint Pattern | Use Case |
|---|---|---|---|---|
| **Azure MCP Server** | `microsoft/mcp` | Streamable HTTP + SSE | `mcp.ai.azure.com/v1/azure` | Azure resource management, subscriptions, resource groups, deployments |
| **Kubernetes MCP Server** | `Azure/mcp-kubernetes` | Streamable HTTP + SSE | `mcp.ai.azure.com/v1/k8s` | K8s cluster operations, pods, deployments, services, manifests |
| **GitHub MCP Server** | `github/github-mcp-server` | Streamable HTTP + SSE | `mcp.api.github.com/v1/github` | Repository management, PRs, issues, workflows, commits |
| **Azure AI Foundry MCP** | `microsoft/mcp-foundry` | Streamable HTTP + SSE | `mcp.ai.azure.com/v1/foundry` | Foundry agent orchestration, model deployment, evaluations |
| **Backstage MCP** | `@backstage/plugin-mcp-actions-backend` | Streamable HTTP + SSE | `localhost:7007/mcp/backstage` | Backstage catalog, scaffolder, software templates |
| **Azure DevOps MCP** | `microsoft/mcp-azuredevops` | Streamable HTTP + SSE | `mcp.ai.azure.com/v1/azuredevops` | Azure DevOps pipelines, repos, boards, releases |
| **PostgreSQL MCP** | `stdlib/mcp-postgres` | Streamable HTTP + SSE | `localhost:3306/mcp` | Database operations, schema management, queries |
| **Playwright MCP** | `modelcontextprotocol/servers/playwright` | Streamable HTTP + SSE | `localhost:8000/mcp/playwright` | Browser automation, web testing, screenshot capture |
| **Filesystem MCP** | `modelcontextprotocol/servers/filesystem` | Streamable HTTP + SSE | `localhost:8001/mcp/fs` | Local file operations, directory traversal, content management |

### Transport Protocol Details

All official MCP servers use **Streamable HTTP + Server-Sent Events (SSE)**:
- **Streamable HTTP:** Request/response model supporting long-lived connections
- **SSE:** Server-Sent Events for real-time updates and tool notifications
- **Authentication:** OAuth 2.0, managed identities, service principals
- **Rate Limiting:** 1000 req/min per server (Foundry tier dependent)

---

## 2. Official Skills Registry (microsoft/skills)

The `microsoft/skills` repository provides 131+ official reusable skills following a 3-step workflow pattern for infrastructure and deployment tasks.

### Workflow Pattern: azure-prepare → azure-validate → azure-deploy

All skills follow this standardized workflow:

1. **azure-prepare:** Validate inputs, check prerequisites, prepare configuration
2. **azure-validate:** Run pre-flight checks, validate permissions, test connectivity
3. **azure-deploy:** Execute deployment, monitor progress, report results

### Skill File Structure

```
.github/skills/SKILL_NAME/SKILL.md
```

**YAML Frontmatter Example:**
```yaml
---
id: deploy-aks
name: Deploy Azure Kubernetes Service
description: Deploy AKS cluster with specified configuration
trigger: /deploy-aks
category: Azure Infrastructure
steps:
  - name: azure-prepare
    description: Validate AKS prerequisites
  - name: azure-validate
    description: Verify cluster configuration
  - name: azure-deploy
    description: Deploy AKS cluster
version: "1.0.0"
requires:
  - mcp: azure
  - permissions: ['Microsoft.ContainerService/managedClusters/write']
---
```

### Key Skill Categories

| Category | Skills | Count |
|---|---|---|
| **Azure Infrastructure** | deploy-aks, create-appservice, setup-cosmosdb, configure-vnet | 24 |
| **Kubernetes** | deploy-helm, apply-manifest, configure-ingress, setup-persistent-volume | 18 |
| **Security** | create-key-vault, configure-entra-id, setup-firewall, manage-identity | 22 |
| **Monitoring & Observability** | setup-app-insights, configure-prometheus, deploy-grafana, enable-log-analytics | 19 |
| **Networking** | configure-apim, setup-traffic-manager, deploy-cdn, setup-private-link | 16 |
| **CI/CD** | setup-github-actions, configure-azure-pipelines, deploy-release-pipeline | 14 |
| **Database** | deploy-sql-database, setup-postgres, configure-redis, migrate-data | 12 |
| **DevOps Tools** | deploy-backstage, setup-rhdh, configure-mcp-server | 8 |
| **Multi-Cloud** | aws-deploy-ec2, gcp-deploy-gke, deploy-multi-cloud-agent | 6 |

### Example Official Skills

```markdown
# Skill: deploy-aks
ID: deploy-aks
Trigger: /deploy-aks
Category: Azure Infrastructure

## Parameters
- `resourceGroup` (required): Target resource group
- `clusterName` (required): AKS cluster name
- `kubernetesVersion` (required): K8s version (e.g., "1.28.0")
- `nodeCount` (required): Initial node count
- `vmSize` (required): VM SKU (e.g., "Standard_D4s_v3")
- `enableManagedIdentity` (optional): Enable managed identity (default: true)
- `enableAzurePolicy` (optional): Enable Azure Policy add-on (default: true)

## Step: azure-prepare
Validate parameters, check resource group exists, verify permissions

## Step: azure-validate
Pre-flight checks: verify subnet availability, check naming conventions, validate K8s version

## Step: azure-deploy
Deploy AKS cluster using Azure CLI/SDK, configure add-ons, setup RBAC
```

---

## 3. Custom Skills to Create

Custom skills extend the official registry with Backstage, RHDH, and AI-specific capabilities.

### Backstage Skills (Open Horizons)

#### Skill: backstage-plugins
```yaml
---
id: backstage-plugins
name: Install Backstage Plugin
description: Install and configure Backstage plugin with MCP integration
trigger: /backstage-install-plugin
category: Backstage Infrastructure
---
```
**File Path:** `.github/skills/backstage-plugins/SKILL.md`
**Commands:**
- `/backstage-install-plugin <plugin-name>`
- `/backstage-list-plugins`
- `/backstage-configure-plugin <plugin-name>`

#### Skill: mcp-protocol
```yaml
---
id: mcp-protocol
name: Setup MCP Server
description: Install and verify MCP server endpoint
trigger: /mcp-setup
category: MCP Integration
---
```
**File Path:** `.github/skills/mcp-protocol/SKILL.md`
**Commands:**
- `/mcp-setup <server-name>`
- `/mcp-verify-endpoint <endpoint-url>`
- `/mcp-list-tools <server-name>`

#### Skill: aks-deploy
```yaml
---
id: aks-deploy
name: Deploy AKS for Backstage
description: Deploy AKS cluster pre-configured for Backstage
trigger: /aks-deploy-backstage
category: Kubernetes Infrastructure
---
```
**File Path:** `.github/skills/aks-deploy/SKILL.md`
**Commands:**
- `/aks-deploy-backstage <cluster-name>`
- `/aks-configure-backstage <cluster-name>`
- `/aks-verify-backstage <cluster-name>`

#### Skill: azure-foundry-agents
```yaml
---
id: azure-foundry-agents
name: Create Foundry Agent
description: Create and configure Azure AI Foundry agent
trigger: /foundry-create-agent
category: Azure AI Foundry
---
```
**File Path:** `.github/skills/azure-foundry-agents/SKILL.md`
**Commands:**
- `/foundry-create-agent <agent-name>`
- `/foundry-configure-tools <agent-name>`
- `/foundry-test-agent <agent-name>`

### RHDH Skills (Three Horizons)

#### Skill: rhdh-dynamic-plugins
```yaml
---
id: rhdh-dynamic-plugins
name: Configure RHDH Dynamic Plugins
description: Configure dynamic plugin YAML for RHDH
trigger: /rdhh-configure-plugins
category: RHDH Configuration
---
```
**File Path:** `.github/skills/rdhh-dynamic-plugins/SKILL.md`
**Commands:**
- `/rdhh-configure-plugins <plugin-config>`
- `/rdhh-list-dynamic-plugins`
- `/rdhh-enable-mcp-plugin`

#### Skill: lightspeed-deploy
```yaml
---
id: lightspeed-deploy
name: Deploy Red Hat Developer Lightspeed
description: Deploy Lightspeed with IDE integration
trigger: /lightspeed-deploy
category: Developer Experience
---
```
**File Path:** `.github/skills/lightspeed-deploy/SKILL.md`
**Commands:**
- `/lightspeed-deploy <rhdh-endpoint>`
- `/lightspeed-configure-ide <ide-type>`
- `/lightspeed-test-chat`

#### Skill: llama-stack-config
```yaml
---
id: llama-stack-config
name: Configure Llama Stack Sidecar
description: Setup Llama Stack as sidecar service with RHDH
trigger: /llama-stack-configure
category: AI Infrastructure
---
```
**File Path:** `.github/skills/llama-stack-config/SKILL.md`
**Commands:**
- `/llama-stack-configure <deployment-type>`
- `/llama-stack-verify-sidecar`
- `/llama-stack-test-endpoint`

#### Skill: rdhh-rbac
```yaml
---
id: rdhh-rbac
name: Configure RHDH RBAC for AI Features
description: Setup permission policies for AI features in RHDH
trigger: /rdhh-set-rbac
category: Security & RBAC
---
```
**File Path:** `.github/skills/rdhh-rbac/SKILL.md`
**Commands:**
- `/rdhh-set-rbac <group> <permissions>`
- `/rdhh-list-ai-policies`
- `/rdhh-test-permissions <user>`

---

## 4. Custom Agents (.agent.md format)

Custom agents orchestrate skills, MCP servers, and tools to accomplish complex deployment scenarios.

### Backstage Agents (Open Horizons)

#### Agent: backstage-deployer
**File Path:** `.github/agents/backstage-deployer.agent.md`

```yaml
---
id: backstage-deployer
name: Backstage Full Deployment Orchestrator
description: >
  End-to-end Backstage deployment: AKS provisioning, plugin installation,
  MCP server setup, PostgreSQL integration, TLS configuration
model: gpt-4o
tools:
  - type: skill
    skill: aks-deploy
  - type: skill
    skill: backstage-plugins
  - type: skill
    skill: mcp-protocol
  - type: mcp
    mcp: azure
  - type: mcp
    mcp: kubernetes
  - type: mcp
    mcp: backstage
mcp_servers:
  - azure
  - kubernetes
  - backstage
  - github
---
```

**Instructions Summary:**
1. Validate deployment parameters (cluster name, region, resource group)
2. Provision AKS cluster using `aks-deploy` skill
3. Install Backstage plugins using `backstage-plugins` skill
4. Setup MCP servers using `mcp-protocol` skill
5. Configure PostgreSQL database with Kubernetes MCP
6. Deploy Backstage Helm chart
7. Verify all components and report health status

#### Agent: mcp-setup
**File Path:** `.github/agents/mcp-setup.agent.md`

```yaml
---
id: mcp-setup
name: MCP Plugin Installation Specialist
description: >
  MCP server discovery, installation, endpoint verification,
  and Backstage plugin configuration
model: gpt-4o
tools:
  - type: skill
    skill: mcp-protocol
  - type: mcp
    mcp: backstage
  - type: mcp
    mcp: kubernetes
mcp_servers:
  - backstage
  - kubernetes
---
```

**Instructions Summary:**
1. Identify MCP servers to install (Azure, GitHub, K8s, PostgreSQL, Playwright)
2. Install MCP Backstage plugin
3. Configure MCP server endpoints in Backstage `app-config.yaml`
4. Verify endpoint connectivity and tool availability
5. Register tools with Backstage scaffolder
6. Test MCP integration with sample workflows

#### Agent: azure-infra
**File Path:** `.github/agents/azure-infra.agent.md`

```yaml
---
id: azure-infra
name: Azure Infrastructure Provisioner
description: >
  Provision Azure infrastructure: AKS, ACR, Key Vault, networking,
  managed identities, monitoring
model: gpt-4o
tools:
  - type: skill
    skill: aks-deploy
  - type: skill
    skill: azure-foundry-agents
  - type: mcp
    mcp: azure
  - type: mcp
    mcp: kubernetes
mcp_servers:
  - azure
  - kubernetes
---
```

**Instructions Summary:**
1. Create resource group and networking (VNet, subnets, NSGs)
2. Deploy AKS cluster with managed identity
3. Create ACR and link to AKS
4. Setup Key Vault with certificates and secrets
5. Configure App Insights and Log Analytics
6. Deploy managed identity workload for Backstage
7. Verify all resources and permissions

#### Agent: client-config
**File Path:** `.github/agents/client-config.agent.md`

```yaml
---
id: client-config
name: IDE Client MCP Configuration
description: >
  Configure local IDE clients (VS Code, JetBrains) with MCP server
  connections for agent interaction
model: gpt-4o
tools:
  - type: skill
    skill: mcp-protocol
  - type: mcp
    mcp: filesystem
mcp_servers:
  - filesystem
---
```

**Instructions Summary:**
1. Detect IDE type and version
2. Generate MCP server configuration files
3. Setup authentication tokens
4. Configure environment variables
5. Provide IDE plugin installation instructions
6. Generate quick-start guide for /deploy and /diagnose commands

#### Agent: custom-mcp-builder
**File Path:** `.github/agents/custom-mcp-builder.agent.md`

```yaml
---
id: custom-mcp-builder
name: Custom MCP Server Scaffolder
description: >
  Create custom MCP servers from templates, setup server
  infrastructure, configure tools and resources
model: gpt-4o
tools:
  - type: mcp
    mcp: filesystem
  - type: mcp
    mcp: github
mcp_servers:
  - filesystem
  - github
---
```

**Instructions Summary:**
1. Scaffold MCP server project structure
2. Configure transport layer (HTTP/SSE)
3. Define tools and resource schemas
4. Setup authentication and rate limiting
5. Generate test suite
6. Provide deployment documentation

#### Agent: mcp-tester
**File Path:** `.github/agents/mcp-tester.agent.md`

```yaml
---
id: mcp-tester
name: MCP Endpoint Testing & Validation
description: >
  Health checks, load testing, and validation of MCP server endpoints
  and tool availability
model: gpt-4o
tools:
  - type: skill
    skill: mcp-protocol
  - type: mcp
    mcp: playwright
mcp_servers:
  - playwright
---
```

**Instructions Summary:**
1. Verify endpoint connectivity and response times
2. Test tool discovery and schema validation
3. Perform authentication flow validation
4. Execute load testing
5. Generate health report with metrics
6. Identify and report issues

### RHDH Agents (Three Horizons)

#### Agent: rdhh-deployer
**File Path:** `.github/agents/rdhh-deployer.agent.md`

```yaml
---
id: rdhh-deployer
name: RHDH Full Deployment Orchestrator
description: >
  Deploy Red Hat Developer Hub with Lightspeed, dynamic plugins,
  BYOM integration, and AI RBAC policies
model: gpt-4o
tools:
  - type: skill
    skill: rdhh-dynamic-plugins
  - type: skill
    skill: lightspeed-deploy
  - type: skill
    skill: llama-stack-config
  - type: skill
    skill: rdhh-rbac
  - type: mcp
    mcp: kubernetes
  - type: mcp
    mcp: azure
mcp_servers:
  - kubernetes
  - azure
  - github
---
```

**Instructions Summary:**
1. Validate RHDH prerequisites and cluster readiness
2. Deploy RHDH Helm chart with custom values
3. Configure dynamic plugins (Lightspeed, MCP, BYOM)
4. Deploy Lightspeed service and endpoints
5. Setup Llama Stack sidecar
6. Configure AI feature RBAC policies
7. Verify deployment and integration

#### Agent: mcp-enabler
**File Path:** `.github/agents/mcp-enabler.agent.md`

```yaml
---
id: mcp-enabler
name: RHDH MCP Dynamic Plugin Configuration
description: >
  Enable and configure MCP servers as dynamic plugins within RHDH,
  manage tool exposure in UI
model: gpt-4o
tools:
  - type: skill
    skill: rdhh-dynamic-plugins
  - type: mcp
    mcp: kubernetes
  - type: mcp
    mcp: backstage
mcp_servers:
  - kubernetes
  - backstage
---
```

**Instructions Summary:**
1. Generate dynamic plugin YAML for MCP servers
2. Apply plugin configuration to RDHH deployment
3. Reload plugin system
4. Test tool availability in RDHH UI
5. Configure tool visibility and permissions
6. Generate user documentation

#### Agent: lightspeed-deployer
**File Path:** `.github/agents/lightspeed-deployer.agent.md`

```yaml
---
id: lightspeed-deployer
name: Lightspeed + Llama Stack Deployment
description: >
  Deploy Red Hat Developer Lightspeed with Llama Stack,
  IDE integration, and model provider configuration
model: gpt-4o
tools:
  - type: skill
    skill: lightspeed-deploy
  - type: skill
    skill: llama-stack-config
  - type: mcp
    mcp: kubernetes
mcp_servers:
  - kubernetes
---
```

**Instructions Summary:**
1. Deploy Lightspeed service to Kubernetes
2. Configure IDE plugins (VS Code, JetBrains)
3. Setup Llama Stack sidecar service
4. Configure model provider (local or cloud)
5. Verify chat functionality
6. Generate IDE configuration scripts
7. Setup monitoring and logging

#### Agent: byom-config
**File Path:** `.github/agents/byom-config.agent.md`

```yaml
---
id: byom-config
name: BYOM Model Provider Configuration
description: >
  Configure Bring-Your-Own-Model (BYOM) providers for RDHH
  including Azure OpenAI, local models, and multi-model setups
model: gpt-4o
tools:
  - type: skill
    skill: llama-stack-config
  - type: mcp
    mcp: azure
mcp_servers:
  - azure
---
```

**Instructions Summary:**
1. Validate model provider credentials
2. Configure Azure OpenAI endpoint
3. Setup local model endpoints
4. Configure model fallback chains
5. Test model connectivity
6. Setup cost monitoring and rate limiting
7. Generate configuration documentation

#### Agent: rbac-ai-config
**File Path:** `.github/agents/rbac-ai-config.agent.md`

```yaml
---
id: rbac-ai-config
name: AI Feature RBAC Configuration
description: >
  Configure role-based access control for RDHH AI features
  (Lightspeed, MCP tools, BYOM models)
model: gpt-4o
tools:
  - type: skill
    skill: rdhh-rbac
  - type: mcp
    mcp: kubernetes
mcp_servers:
  - kubernetes
---
```

**Instructions Summary:**
1. Define AI feature access policies
2. Configure user and group permissions
3. Setup model usage limits by role
4. Configure MCP tool exposure rules
5. Test RBAC enforcement
6. Generate policy documentation
7. Setup audit logging

#### Agent: rdhh-tester
**File Path:** `.github/agents/rdhh-tester.agent.md`

```yaml
---
id: rdhh-tester
name: RDHH Integration Testing & Validation
description: >
  Comprehensive testing of RDHH deployment: Lightspeed chat,
  MCP tool execution, BYOM models, RBAC enforcement
model: gpt-4o
tools:
  - type: skill
    skill: lightspeed-deploy
  - type: mcp
    mcp: playwright
  - type: mcp
    mcp: kubernetes
mcp_servers:
  - playwright
  - kubernetes
---
```

**Instructions Summary:**
1. Test Lightspeed chat functionality
2. Validate MCP tool discovery and execution
3. Test model provider connectivity
4. Verify RBAC permission enforcement
5. Performance testing and benchmarking
6. Generate test report
7. Identify and document issues

---

## 5. Agentic Workflows (.github/workflows/)

GitHub Actions workflows orchestrate agent execution, MCP server deployment, and validation pipelines.

### Workflow: deploy-backstage-mcp.yml

**File Path:** `.github/workflows/deploy-backstage-mcp.yml`

```yaml
name: Deploy Backstage with MCP Integration

on:
  workflow_dispatch:
    inputs:
      cluster_name:
        description: AKS cluster name
        required: true
      region:
        description: Azure region
        required: true
      environment:
        description: Deployment environment
        type: choice
        options: [dev, staging, prod]
        required: true

jobs:
  deploy-backstage:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Authenticate to Azure
        uses: azure/login@v2
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Run backstage-deployer Agent
        run: |
          gh copilot /deploy \
            --agent backstage-deployer \
            --cluster-name ${{ github.event.inputs.cluster_name }} \
            --region ${{ github.event.inputs.region }} \
            --environment ${{ github.event.inputs.environment }}
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Verify Backstage Health
        run: |
          kubectl wait --for=condition=ready pod \
            -l app=backstage \
            -n backstage \
            --timeout=600s
          kubectl port-forward -n backstage svc/backstage 7007:7007 &
          sleep 10
          curl -f http://localhost:7007/health || exit 1

      - name: Post Status to GitHub
        if: always()
        run: |
          gh api repos/${{ github.repository }}/issues/comments \
            --input -
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Agents Involved:**
- `backstage-deployer`: Main deployment orchestrator
- `azure-infra`: AKS infrastructure provisioning
- `mcp-setup`: MCP server setup
- `backstage-plugins`: Plugin installation

---

### Workflow: test-mcp-endpoint.yml

**File Path:** `.github/workflows/test-mcp-endpoint.yml`

```yaml
name: Test MCP Endpoint Health & Availability

on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:
    inputs:
      mcp_server:
        description: MCP server to test
        type: choice
        options: [azure, kubernetes, github, backstage, foundry, azuredevops, postgres, playwright]
        required: true

jobs:
  test-mcp:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install MCP CLI
        run: pip install mcp-cli

      - name: Run mcp-tester Agent
        run: |
          gh copilot /diagnose \
            --agent mcp-tester \
            --mcp-server ${{ github.event.inputs.mcp_server || 'all' }} \
            --verbose
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Generate Report
        if: always()
        run: |
          gh copilot /report \
            --format json \
            --output mcp-health-report.json
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Upload Report
        uses: actions/upload-artifact@v4
        with:
          name: mcp-health-report
          path: mcp-health-report.json
```

**Agents Involved:**
- `mcp-tester`: Endpoint testing and validation

---

### Workflow: deploy-rdhh-mcp.yml

**File Path:** `.github/workflows/deploy-rdhh-mcp.yml`

```yaml
name: Deploy RDHH with MCP Dynamic Plugins

on:
  workflow_dispatch:
    inputs:
      cluster_name:
        description: K8s cluster name
        required: true
      enable_lightspeed:
        description: Enable Lightspeed
        type: boolean
        default: true
      enable_byom:
        description: Enable BYOM
        type: boolean
        default: false
      model_provider:
        description: Model provider
        type: choice
        options: [azure-openai, ollama, local-llama]
        default: azure-openai

jobs:
  deploy-rdhh:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup kubeconfig
        run: |
          az aks get-credentials \
            --resource-group ${{ secrets.AZURE_RESOURCE_GROUP }} \
            --name ${{ github.event.inputs.cluster_name }}

      - name: Run rdhh-deployer Agent
        run: |
          gh copilot /deploy \
            --agent rdhh-deployer \
            --cluster-name ${{ github.event.inputs.cluster_name }} \
            --enable-lightspeed ${{ github.event.inputs.enable_lightspeed }} \
            --enable-byom ${{ github.event.inputs.enable_byom }} \
            --model-provider ${{ github.event.inputs.model_provider }}
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Configure MCP Dynamic Plugins
        if: success()
        run: |
          gh copilot /configure \
            --agent mcp-enabler \
            --cluster-name ${{ github.event.inputs.cluster_name }}
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Verify RDHH Deployment
        run: |
          kubectl rollout status deployment/rhdh \
            -n rhdh \
            --timeout=600s
          kubectl get svc -n rhdh
```

**Agents Involved:**
- `rdhh-deployer`: RDHH deployment orchestration
- `mcp-enabler`: Dynamic plugin configuration
- `lightspeed-deployer`: Lightspeed deployment
- `byom-config`: BYOM provider setup

---

### Workflow: deploy-lightspeed.yml

**File Path:** `.github/workflows/deploy-lightspeed.yml`

```yaml
name: Deploy Red Hat Developer Lightspeed

on:
  workflow_dispatch:
    inputs:
      rdhh_endpoint:
        description: RDHH endpoint URL
        required: true
      enable_IDE_plugins:
        description: Enable IDE plugins
        type: boolean
        default: true
      llama_stack_mode:
        description: Llama Stack mode
        type: choice
        options: [sidecar, standalone, cloud]
        default: sidecar

jobs:
  deploy-lightspeed:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Deploy Lightspeed with lightspeed-deployer
        run: |
          gh copilot /deploy \
            --agent lightspeed-deployer \
            --rdhh-endpoint ${{ github.event.inputs.rdhh_endpoint }} \
            --enable-ide-plugins ${{ github.event.inputs.enable_IDE_plugins }} \
            --llama-stack-mode ${{ github.event.inputs.llama_stack_mode }}
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Generate IDE Configuration
        run: |
          gh copilot /generate \
            --agent client-config \
            --ide-types "vscode,jetbrains"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Agents Involved:**
- `lightspeed-deployer`: Lightspeed deployment
- `llama-stack-config`: Llama Stack sidecar setup
- `client-config`: IDE client configuration

---

### Workflow: test-lightspeed-chat.yml

**File Path:** `.github/workflows/test-lightspeed-chat.yml`

```yaml
name: Test Lightspeed Chat Functionality

on:
  schedule:
    - cron: '0 */3 * * *'  # Every 3 hours
  workflow_dispatch:

jobs:
  test-lightspeed:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Playwright
        uses: microsoft/playwright-github-action@v1

      - name: Run rdhh-tester Agent
        run: |
          gh copilot /test \
            --agent rdhh-tester \
            --test-suite lightspeed-chat \
            --verbose
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Generate Test Report
        if: always()
        run: |
          gh copilot /report \
            --format html \
            --output lightspeed-test-report.html
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Upload Test Report
        uses: actions/upload-artifact@v4
        with:
          name: lightspeed-test-report
          path: lightspeed-test-report.html
```

**Agents Involved:**
- `rdhh-tester`: Integration and chat functionality testing

---

### Workflow: multi-cloud-deploy.yml

**File Path:** `.github/workflows/multi-cloud-deploy.yml`

```yaml
name: Multi-Cloud Deployment Orchestration

on:
  workflow_dispatch:
    inputs:
      deployment_targets:
        description: Target clouds
        type: choice
        options:
          - azure-only
          - aws-only
          - gcp-only
          - azure-aws
          - azure-gcp
          - all-clouds
        default: azure-only

jobs:
  deploy-multi-cloud:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Authenticate to Multiple Cloud Providers
        run: |
          az login --service-principal \
            -u ${{ secrets.AZURE_CLIENT_ID }} \
            -p ${{ secrets.AZURE_CLIENT_SECRET }} \
            --tenant ${{ secrets.AZURE_TENANT_ID }}

      - name: Deploy to Target Clouds
        run: |
          gh copilot /deploy \
            --agent multi-cloud-agent \
            --targets ${{ github.event.inputs.deployment_targets }} \
            --orchestrate true
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Agents Involved:**
- `multi-cloud-agent`: Multi-cloud orchestration
- `azure-infra`: Azure infrastructure
- Custom AWS/GCP agents (as available)

---

## 6. GitHub Copilot CLI Integration

**Release Date:** February 27, 2026 (General Availability)

### CLI Features (GA)

The GitHub Copilot CLI is now available as a generally available product with full support for agent orchestration, MCP server management, and agentic workflow execution.

#### Core Commands

```bash
# List available agents
gh copilot agents list

# Execute deployment with agent
gh copilot /deploy --agent <agent-name> [options]

# Diagnose issues with agent
gh copilot /diagnose --agent <agent-name> [--mcp-server <server>]

# Run tests with agent
gh copilot /test --agent <agent-name> [--test-suite <suite>]

# Generate configurations
gh copilot /generate --agent <agent-name> --output-type <type>

# View agent status
gh copilot agent status <agent-name>

# View agent logs
gh copilot agent logs <agent-name> [--tail 100] [--follow]
```

#### Common Usage Patterns

**Deploy Backstage:**
```bash
gh copilot /deploy \
  --agent backstage-deployer \
  --cluster-name backstage-prod \
  --region eastus \
  --environment production
```

**Test MCP Endpoints:**
```bash
gh copilot /diagnose \
  --agent mcp-tester \
  --mcp-server azure,kubernetes,github \
  --verbose
```

**Configure RDHH:**
```bash
gh copilot /configure \
  --agent mcp-enabler \
  --cluster-name rdhh-prod \
  --enable-lightspeed true
```

### MCP Server Connection via CLI

MCP servers are discovered and registered automatically through the CLI:

```bash
# List available MCP servers
gh copilot mcp list

# Connect to MCP server
gh copilot mcp connect <server-name> \
  --endpoint <endpoint-url> \
  --auth-type <oauth2|service-principal|token>

# Verify MCP connection
gh copilot mcp verify <server-name>

# List available tools from MCP server
gh copilot mcp tools <server-name>
```

### Slash Commands

Slash commands are available for quick access to common operations:

| Command | Agent | Purpose |
|---|---|---|
| `/deploy` | Matched agent | Execute deployment workflow |
| `/diagnose` | mcp-tester, rdhh-tester | Diagnose and troubleshoot issues |
| `/test` | rdhh-tester, mcp-tester | Run integration tests |
| `/generate` | client-config, custom-mcp-builder | Generate configuration files |
| `/configure` | mcp-enabler, rbac-ai-config | Configure components |
| `/validate` | mcp-tester | Validate endpoints and connectivity |
| `/report` | All agents | Generate status reports |

### Environment Setup & Authentication

**Required Environment Variables:**

```bash
# GitHub
export GH_TOKEN=<github-pat-token>

# Azure
export AZURE_SUBSCRIPTION_ID=<subscription-id>
export AZURE_CLIENT_ID=<client-id>
export AZURE_CLIENT_SECRET=<client-secret>
export AZURE_TENANT_ID=<tenant-id>

# Kubernetes
export KUBECONFIG=<path-to-kubeconfig>

# Foundry (if using cloud-based Foundry)
export FOUNDRY_ENDPOINT=https://<project>.services.ai.azure.com
export FOUNDRY_KEY=<foundry-api-key>
```

**GitHub Copilot CLI Authentication:**

```bash
# First-time setup
gh auth login --web

# Verify authentication
gh auth status

# Add MCP server scopes
gh auth token --scopes admin:repo_hook,repo,workflow
```

---

## 7. Azure AI Foundry Agents (Python SDK)

Azure AI Foundry provides a Python SDK for creating, deploying, and managing agents with MCP integration.

### Foundry Agent Architecture

Foundry agents support:
- **Models:** GPT-4o, GPT-4-turbo, custom fine-tuned models
- **Tools:** MCP servers, Azure Functions, REST APIs, custom tools
- **Memory:** Agent Memory (Public Preview) for persistent context
- **A2A Communication:** Agent-to-Agent protocol for multi-agent workflows

### Python SDK Installation

```bash
pip install azure-ai-projects
```

### Basic Foundry Agent Pattern

```python
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

# Initialize Foundry project client
project = AIProjectClient(
    credential=DefaultAzureCredential(),
    endpoint="https://<project>.services.ai.azure.com"
)

# Create agent with MCP integration
agent = project.agents.create_agent(
    model="gpt-4o",
    name="backstage-agent",
    instructions="""
    You are a Backstage deployment specialist. Your role is to:
    1. Validate deployment parameters
    2. Provision AKS infrastructure
    3. Install and configure Backstage plugins
    4. Setup MCP servers
    5. Verify health and provide status reports

    Use the azure and kubernetes MCP servers for infrastructure operations.
    """,
    tools=[
        {
            "type": "mcp",
            "mcp": {
                "server_label": "azure",
                "name": "Azure MCP Server",
                "endpoint": "https://mcp.ai.azure.com/v1/azure"
            }
        },
        {
            "type": "mcp",
            "mcp": {
                "server_label": "kubernetes",
                "name": "Kubernetes MCP Server",
                "endpoint": "https://mcp.ai.azure.com/v1/k8s"
            }
        }
    ]
)

# Execute agent with specific task
response = project.agents.run(
    agent_id=agent.id,
    user_message="""
    Deploy Backstage to AKS:
    - Cluster name: backstage-prod
    - Region: eastus
    - Resource group: rg-backstage
    - Node count: 3
    """
)

print(f"Agent Response: {response}")
```

### Creating Multi-Tool Foundry Agent

```python
# Multi-tool agent with multiple MCP servers
multi_tool_agent = project.agents.create_agent(
    model="gpt-4o",
    name="multi-tool-agent",
    instructions="""
    Orchestrate multi-cloud deployments using available MCP servers.
    Coordinate Azure, Kubernetes, GitHub, and Azure DevOps operations.
    """,
    tools=[
        {"type": "mcp", "mcp": {"server_label": "azure"}},
        {"type": "mcp", "mcp": {"server_label": "kubernetes"}},
        {"type": "mcp", "mcp": {"server_label": "github"}},
        {"type": "mcp", "mcp": {"server_label": "azuredevops"}},
    ]
)
```

### Foundry Agents for This Project

#### 1. backstage-agent

```python
backstage_agent = project.agents.create_agent(
    model="gpt-4o",
    name="backstage-agent",
    instructions="Backstage deployment and plugin management specialist",
    tools=[
        {"type": "mcp", "mcp": {"server_label": "azure"}},
        {"type": "mcp", "mcp": {"server_label": "kubernetes"}},
        {"type": "mcp", "mcp": {"server_label": "backstage"}},
    ]
)
```

#### 2. multi-tool-agent

```python
multi_tool_agent = project.agents.create_agent(
    model="gpt-4o",
    name="multi-tool-agent",
    instructions="Multi-MCP orchestrator for complex deployments",
    tools=[
        {"type": "mcp", "mcp": {"server_label": "azure"}},
        {"type": "mcp", "mcp": {"server_label": "kubernetes"}},
        {"type": "mcp", "mcp": {"server_label": "github"}},
        {"type": "mcp", "mcp": {"server_label": "azuredevops"}},
        {"type": "mcp", "mcp": {"server_label": "foundry"}},
    ]
)
```

#### 3. rdhh-agent

```python
rdhh_agent = project.agents.create_agent(
    model="gpt-4o",
    name="rdhh-agent",
    instructions="Red Hat Developer Hub deployment and configuration specialist",
    tools=[
        {"type": "mcp", "mcp": {"server_label": "kubernetes"}},
        {"type": "mcp", "mcp": {"server_label": "github"}},
        {"type": "mcp", "mcp": {"server_label": "backstage"}},
    ]
)
```

#### 4. lightspeed-monitor-agent

```python
lightspeed_monitor = project.agents.create_agent(
    model="gpt-4o",
    name="lightspeed-monitor-agent",
    instructions="Monitor Lightspeed health, chat quality, and model performance",
    tools=[
        {"type": "mcp", "mcp": {"server_label": "kubernetes"}},
        {"type": "mcp", "mcp": {"server_label": "azure"}},
    ]
)
```

#### 5. aika-rag-agent

```python
aika_rag_agent = project.agents.create_agent(
    model="gpt-4o",
    name="aika-rag-agent",
    instructions="AiKA RAG pipeline orchestration and knowledge base management",
    tools=[
        {"type": "mcp", "mcp": {"server_label": "github"}},
        {"type": "mcp", "mcp": {"server_label": "postgres"}},
    ]
)
```

#### 6. multi-cloud-agent

```python
multi_cloud_agent = project.agents.create_agent(
    model="gpt-4o",
    name="multi-cloud-agent",
    instructions="Orchestrate deployments across Azure, AWS, and GCP",
    tools=[
        {"type": "mcp", "mcp": {"server_label": "azure"}},
        {"type": "mcp", "mcp": {"server_label": "kubernetes"}},
        # AWS/GCP MCP servers as available
    ]
)
```

---

## 8. Agent Memory & A2A Protocol

### Agent Memory (Public Preview)

Agent Memory enables persistent context storage and retrieval across agent invocations, supporting long-running workflows and state management.

**Features:**
- **Persistent Storage:** Store agent conversation history, decisions, and context
- **Retrieval:** Query stored context using semantic similarity
- **TTL Configuration:** Set retention periods for sensitive data
- **Integration:** Works seamlessly with Foundry agents and skills

**Example: Agent Memory Usage**

```python
from azure.ai.projects.agents import AgentMemory

# Create agent with memory enabled
agent = project.agents.create_agent(
    model="gpt-4o",
    name="stateful-deployment-agent",
    instructions="Use memory to track deployment state across sessions",
    tools=[...],
    memory=AgentMemory(
        enabled=True,
        max_tokens=10000,
        ttl_days=30  # Retain for 30 days
    )
)

# Store context
project.agents.memory.store(
    agent_id=agent.id,
    key="deployment_state",
    value={
        "cluster": "backstage-prod",
        "status": "provisioning",
        "nodes_ready": 2,
        "total_nodes": 3
    }
)

# Retrieve context
state = project.agents.memory.retrieve(
    agent_id=agent.id,
    key="deployment_state"
)
```

### Agent-to-Agent (A2A) Protocol

The A2A protocol enables direct communication between agents for hierarchical and collaborative workflows.

**Protocol Features:**
- **Direct Messaging:** Agent A can invoke Agent B with context
- **Result Aggregation:** Collect results from multiple agents
- **State Passing:** Share intermediate results and decisions
- **Error Handling:** Built-in retry and fallback mechanisms

**Example: A2A Workflow**

```python
# Parent agent orchestrates child agents
parent_agent = project.agents.create_agent(
    model="gpt-4o",
    name="deployment-orchestrator",
    instructions="Coordinate azure-infra and mcp-setup agents"
)

# Child agents
azure_infra_agent = project.agents.get("azure-infra-agent-id")
mcp_setup_agent = project.agents.get("mcp-setup-agent-id")

# A2A Communication
response = project.agents.a2a_invoke(
    parent_id=parent_agent.id,
    child_id=azure_infra_agent.id,
    message="Provision AKS cluster with 3 nodes in eastus",
    context={
        "resource_group": "rg-backstage",
        "cluster_name": "backstage-prod"
    }
)

# Process result before invoking next agent
if response.status == "success":
    project.agents.a2a_invoke(
        parent_id=parent_agent.id,
        child_id=mcp_setup_agent.id,
        message="Setup MCP servers on provisioned cluster",
        context=response.context  # Pass context from first agent
    )
```

### Foundry Control Plane Integration

Azure AI Foundry Control Plane provides 1,400+ pre-built connectors for extensibility:

```python
# List available connectors
connectors = project.connectors.list()

# Use connector in agent tool
agent = project.agents.create_agent(
    model="gpt-4o",
    name="extended-agent",
    instructions="Use connectors for extended capabilities",
    tools=[
        {
            "type": "connector",
            "connector_id": "salesforce-connector-id",
            "operations": ["query", "create", "update"]
        }
    ]
)
```

---

## 9. Configuration Quick Reference

### Configuration File Index

| Component | Config File | Location | Format | Purpose |
|---|---|---|---|---|
| **Backstage** | app-config.yaml | `open-horizons-backstage/` | YAML | Main Backstage configuration |
| **Backstage Plugins** | app-config.plugins.yaml | `open-horizons-backstage/` | YAML | Plugin-specific settings |
| **MCP Plugin** | backstage-mcp-config.yaml | `open-horizons-backstage/.github/mcp/` | YAML | MCP server endpoints |
| **RDHH** | values.yaml | `three-horizons-rdhh/helm/` | YAML | RDHH Helm chart values |
| **Dynamic Plugins** | dynamic-plugins.yaml | `three-horizons-rdhh/config/` | YAML | Dynamic plugin configuration |
| **Lightspeed** | lightspeed-config.yaml | `three-horizons-rdhh/config/` | YAML | Lightspeed service settings |
| **Llama Stack** | llama-stack-config.yaml | `three-horizons-rdhh/config/` | YAML | Llama Stack sidecar config |
| **BYOM** | byom-models.yaml | `three-horizons-rdhh/config/` | YAML | Model provider configuration |
| **RBAC Policies** | rbac-policies.yaml | `three-horizons-rdhh/config/` | YAML | AI feature access control |
| **AKS** | aks-cluster.yaml | `multi-cloud/azure/` | YAML | AKS cluster configuration |
| **Multi-Cloud** | multi-cloud-config.yaml | `multi-cloud/` | YAML | Multi-cloud deployment settings |
| **Skills** | SKILL.md | `.github/skills/<skill-name>/` | Markdown + YAML | Skill definitions |
| **Agents** | agent.md | `.github/agents/` | Markdown + YAML | Agent definitions |
| **Workflows** | *.yml | `.github/workflows/` | YAML | GitHub Actions workflows |
| **Secrets** | .github/secrets.json | Encrypted in GitHub | JSON | Sensitive credentials |

### Key Configuration Sections

**Backstage MCP Integration (open-horizons-backstage/):**
```yaml
mcp:
  servers:
    - name: azure
      endpoint: https://mcp.ai.azure.com/v1/azure
      auth: service-principal
    - name: kubernetes
      endpoint: https://mcp.ai.azure.com/v1/k8s
      auth: kubeconfig
    - name: github
      endpoint: https://mcp.api.github.com/v1/github
      auth: github-token
```

**RDHH Dynamic Plugins (three-horizons-rdhh/):**
```yaml
dynamicPlugins:
  plugins:
    - id: backstage-plugin-mcp-actions
      config:
        mcp:
          servers:
            - name: azure
              enabled: true
            - name: kubernetes
              enabled: true
    - id: backstage-plugin-lightspeed
      config:
        lightspeed:
          enabled: true
          endpoint: https://lightspeed-svc:8443
```

**Llama Stack Sidecar (three-horizons-rdhh/):**
```yaml
llamaStack:
  enabled: true
  mode: sidecar
  model:
    provider: azure-openai
    endpoint: https://<resource>.openai.azure.com/
    api-version: "2024-02-15-preview"
  resources:
    requests:
      memory: "4Gi"
      cpu: "2"
    limits:
      memory: "8Gi"
      cpu: "4"
```

---

## 10. References

### Official Microsoft Documentation
- **MCP GitHub Repository:** https://github.com/microsoft/mcp
- **MCP Registry & Servers:** https://mcp.ai.azure.com
- **Microsoft Skills Repository:** https://github.com/microsoft/skills
- **Azure AI Foundry Documentation:** https://learn.microsoft.com/azure/ai-services/agents/
- **GitHub Copilot CLI Documentation:** https://docs.github.com/copilot/using-github-copilot/using-github-copilot-in-the-command-line

### Kubernetes & Infrastructure
- **Azure Kubernetes Service (AKS):** https://learn.microsoft.com/azure/aks/
- **Azure MCP Kubernetes Server:** https://github.com/Azure/mcp-kubernetes
- **Kubernetes Official Documentation:** https://kubernetes.io/docs/

### Developer Tools & Platforms
- **Backstage Plugin Catalog:** https://plugins.backstage.io/catalog
- **Backstage Documentation:** https://backstage.io/docs/overview/what-is-backstage
- **Red Hat Developer Hub Documentation:** https://docs.redhat.com/en/documentation/red_hat_developer_hub
- **Red Hat Developer Lightspeed:** https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.2/html-single/configuring_a_plug-in/index#configuring-the-lightspeed-plugin-in-developer-hub_developer-hub

### Azure Services
- **Azure Cognitive Services:** https://learn.microsoft.com/azure/cognitive-services/
- **Azure Container Registry (ACR):** https://learn.microsoft.com/azure/container-registry/
- **Azure Key Vault:** https://learn.microsoft.com/azure/key-vault/
- **Azure DevOps Documentation:** https://learn.microsoft.com/azure/devops/

### AI & LLM Platforms
- **Azure OpenAI Service:** https://learn.microsoft.com/azure/ai-services/openai/
- **Llama Stack Documentation:** https://llama-stack.io/docs
- **Model Context Protocol (MCP) Specification:** https://mcp.ai.azure.com/spec

### Development & CI/CD
- **GitHub Actions Documentation:** https://docs.github.com/actions
- **GitHub CLI Documentation:** https://cli.github.com/
- **Helm Documentation:** https://helm.sh/docs/

### Community & Additional Resources
- **OpenAI Models API:** https://platform.openai.com/docs/models
- **Ansible Documentation:** https://docs.ansible.com/
- **Terraform Documentation:** https://www.terraform.io/docs

---

## Document Notes

This reference document provides comprehensive coverage of the GitHub + Azure AI Foundry Agent Ecosystem as of February 27, 2026 (GA release date). It serves as the authoritative reference for:

- **Task 11 deliverable:** Complete agent ecosystem documentation
- **Paula Silva (paulasilva@microsoft.com):** Microsoft Latam GBB contact
- **Project Context:** Backstage & RHDH with AI Agent Stack deployment (12-task project)

### Versioning & Updates

| Version | Date | Changes |
|---|---|---|
| 1.0 | Feb 27, 2026 | Initial release with GA GitHub Copilot CLI integration |

### Document Maintenance

This document should be updated when:
- New MCP servers are released
- Official skills are added to microsoft/skills
- GitHub Copilot CLI receives feature updates
- Azure AI Foundry introduces new capabilities
- New custom agents or workflows are created

---

**End of Document**
