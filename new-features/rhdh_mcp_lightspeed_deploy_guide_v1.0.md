# RHDH MCP + Lightspeed Deployment Guide v1.0

**Author:** paulasilva@microsoft.com
**Date:** February 27, 2026
**Version:** 1.0

---

## Table of Contents

1. [Deployment Stack Overview](#deployment-stack-overview)
2. [Pre-Deployment: Repository Setup](#pre-deployment-repository-setup)
3. [Deploy MCP Dynamic Plugins (YAML Only, 5 min)](#deploy-mcp-dynamic-plugins-yaml-only-5-min)
4. [Developer Lightspeed Full Deployment](#developer-lightspeed-full-deployment)
5. [BYOM Decision Matrix](#byom-decision-matrix)
6. [Configure External AI Clients (All 7)](#configure-external-ai-clients-all-7)
7. [Azure AI Foundry Agent for RHDH](#azure-ai-foundry-agent-for-rhdh)
8. [Side-by-Side Comparison: Backstage vs RHDH](#side-by-side-comparison-backstage-vs-rhdh)
9. [References](#references)

---

## Deployment Stack Overview

### Five-Layer Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 5: Developer Lightspeed (In-Portal AI Chat)           │
│ ├─ Frontend (React) + Backend (Go)                          │
│ ├─ Developer Lightspeed Chat (LCS)                          │
│ ├─ RAG Integration + Context Awareness                      │
│ └─ Built-in RBAC + Plugin Authz                             │
├─────────────────────────────────────────────────────────────┤
│ Layer 4: MCP Dynamic Plugins (YAML-Based, 5 min deploy)     │
│ ├─ 4 RHDH MCP Plugins (ServiceNow, Jira, GitHub, K8s)       │
│ ├─ dynamic-plugins.yaml Configuration                       │
│ ├─ Plugin Marketplace Discovery                             │
│ └─ Hot-reload Without Rebuild                               │
├─────────────────────────────────────────────────────────────┤
│ Layer 3: Llama Stack + BYOM Providers                        │
│ ├─ Azure OpenAI (Production)                                │
│ ├─ Ollama (Self-hosted)                                     │
│ ├─ vLLM (Optimized serving)                                 │
│ └─ OpenShift AI (Red Hat native)                            │
├─────────────────────────────────────────────────────────────┤
│ Layer 2: MCP Server Infrastructure                          │
│ ├─ Curl MCP Server                                          │
│ ├─ Browser MCP Server                                       │
│ ├─ Microsoft Skills (100+ automation tasks)                 │
│ └─ Custom Agent Skills                                      │
├─────────────────────────────────────────────────────────────┤
│ Layer 1: RHDH Platform (AKS or ARO)                         │
│ ├─ Kubernetes Native (CRDs, Operators)                      │
│ ├─ Helm Charts with Sealed Secrets                          │
│ ├─ RBAC Policies (Backstage-native)                         │
│ └─ Database Backend (PostgreSQL)                            │
└─────────────────────────────────────────────────────────────┘
```

### RHDH vs Backstage: Key Differences

| Aspect | RHDH | Backstage |
|--------|------|-----------|
| **Plugin Deployment** | YAML-based dynamic plugins (5 min) | Code-based rebuild required (30-60 min) |
| **Kubernetes Native** | First-class support (CRDs, Operators) | Community add-on |
| **In-Portal AI Chat** | Developer Lightspeed (built-in) | External integration required |
| **RBAC** | Backstage RBAC + Kubernetes RBAC | Backstage RBAC only |
| **Deployment** | AKS or ARO (RedHat focus) | Any Kubernetes cluster |
| **Enterprise Support** | Red Hat Commercial Support | Community + commercial (Roadie) |
| **Helm Charts** | First-party maintained | Community/Roadie maintained |
| **Sealed Secrets** | Integrated with Helm | Manual setup required |

---

## Pre-Deployment: Repository Setup

### 1. Create AGENTS.md for three-horizons-rhdh

Create `/repos/three-horizons-rhdh/AGENTS.md`:

```markdown
# Three Horizons RHDH - Agentic Capabilities

## MCP Servers Available

### 1. Curl MCP Server
- **Purpose:** Execute HTTP requests, API calls, webhooks
- **Use Cases:** Call REST APIs, execute platform operations
- **Plugin:** `rhdh-mcp-curl`

### 2. Browser MCP Server
- **Purpose:** Web automation, content extraction
- **Use Cases:** Web scraping, form filling, data extraction
- **Plugin:** `rhdh-mcp-browser`

### 3. GitHub MCP Server
- **Purpose:** GitHub API automation
- **Use Cases:** Create PRs, manage repos, trigger workflows
- **Plugin:** `rhdh-mcp-github`

### 4. Kubernetes MCP Server
- **Purpose:** Kubernetes cluster management
- **Use Cases:** Deploy apps, manage resources, check cluster health
- **Plugin:** `rhdh-mcp-kubernetes`

### 5. Microsoft Skills
- **Purpose:** 100+ pre-built automation tasks
- **Repository:** https://github.com/microsoft/skills
- **Integration:** Via `microsoft/skills` MCP server

## Agentic Workflows

### Developer Self-Service
- Deploy applications via chat
- Query cluster status
- Manage configuration changes
- Execute platform operations

### Platform Team Automation
- Multi-step deployment orchestration
- Health monitoring and alerts
- Compliance checking
- Infrastructure as Code validation

### AI Integration
- VS Code with GitHub Copilot Agent Mode
- GitHub Copilot CLI integration
- Azure AI Foundry agent integration
```

### 2. Create .vscode/mcp.json Configuration

Create `/repos/three-horizons-rhdh/.vscode/mcp.json`:

```json
{
  "mcpServers": {
    "rhdh-curl": {
      "command": "npx",
      "args": ["@mcphq/mcp-server-curl"],
      "env": {
        "TIMEOUT": "30000",
        "MAX_RETRIES": "3"
      },
      "disabled": false
    },
    "rhdh-browser": {
      "command": "npx",
      "args": ["@mcphq/mcp-server-browser"],
      "env": {
        "HEADLESS": "true",
        "TIMEOUT": "60000"
      },
      "disabled": false
    },
    "rhdh-github": {
      "command": "node",
      "args": ["/path/to/rhdh-mcp-github/dist/index.js"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}",
        "GITHUB_ORG": "three-horizons"
      },
      "disabled": false
    },
    "rhdh-kubernetes": {
      "command": "node",
      "args": ["/path/to/rhdh-mcp-kubernetes/dist/index.js"],
      "env": {
        "KUBECONFIG": "${HOME}/.kube/config",
        "CLUSTER_CONTEXT": "rhdh-prod"
      },
      "disabled": false
    },
    "microsoft-skills": {
      "command": "npx",
      "args": ["@microsoft/mcp-server-skills"],
      "env": {
        "SKILLS_PATH": "/repos/microsoft/skills"
      },
      "disabled": false
    }
  },
  "defaultTimeout": 30000,
  "alwaysAllow": ["rhdh-curl", "rhdh-kubernetes"]
}
```

### 3. Organize microsoft/skills Directory

Structure `/repos/microsoft/skills`:

```
microsoft/skills/
├── README.md
├── skills/
│   ├── kubernetes/
│   │   ├── deploy-app.yaml
│   │   ├── check-health.yaml
│   │   ├── scale-deployment.yaml
│   │   └── get-pod-logs.yaml
│   ├── github/
│   │   ├── create-pull-request.yaml
│   │   ├── trigger-workflow.yaml
│   │   ├── list-issues.yaml
│   │   └── merge-branch.yaml
│   ├── servicenow/
│   │   ├── create-incident.yaml
│   │   ├── update-change.yaml
│   │   ├── list-approvals.yaml
│   │   └── close-ticket.yaml
│   └── azure/
│       ├── deploy-container.yaml
│       ├── create-resource-group.yaml
│       ├── manage-secrets.yaml
│       └── query-resources.yaml
├── schemas/
│   ├── skill.schema.json
│   └── parameter.schema.json
└── examples/
    ├── deploy-microservice.yaml
    ├── multi-step-deployment.yaml
    └── monitoring-workflow.yaml
```

### 4. Custom Agents Configuration

Create `/repos/three-horizons-rhdh/agents/config.yaml`:

```yaml
agents:
  platform-assistant:
    name: "Platform Assistant"
    description: "Helps developers with platform operations"
    capabilities:
      - kubernetes-deployment
      - github-automation
      - servicenow-integration
    mcp_servers:
      - rhdh-kubernetes
      - rhdh-github
      - microsoft-skills
    rbac_policy: "platform-users"
    system_prompt: |
      You are a helpful platform assistant for Three Horizons RHDH.
      Help developers deploy applications, manage Kubernetes resources,
      and automate platform operations.

  incident-responder:
    name: "Incident Responder"
    description: "Handles incident response and remediation"
    capabilities:
      - cluster-diagnostics
      - ticket-creation
      - notification-management
    mcp_servers:
      - rhdh-kubernetes
      - rhdh-curl
      - microsoft-skills
    rbac_policy: "incident-responders"
    system_prompt: |
      You are an incident response agent.
      Diagnose issues, create tickets, and coordinate remediation.

  cicd-orchestrator:
    name: "CI/CD Orchestrator"
    description: "Manages continuous integration and deployment"
    capabilities:
      - github-workflows
      - deployment-orchestration
      - quality-gates
    mcp_servers:
      - rhdh-github
      - rhdh-kubernetes
      - microsoft-skills
    rbac_policy: "platform-engineers"
    system_prompt: |
      You are a CI/CD automation agent.
      Manage workflows, deployments, and quality assurance processes.
```

---

## Deploy MCP Dynamic Plugins (YAML Only, 5 min)

### Overview

RHDH introduces **dynamic plugins** loaded via YAML configuration. No code rebuilds, no container image changes. Deploy in 5 minutes vs. Backstage's 30-60 minute rebuild cycle.

### Step 1: Create dynamic-plugins.yaml

Create or update `/rhdh-deployment/values/dynamic-plugins.yaml`:

```yaml
# RHDH Dynamic Plugins Configuration
# Deploy time: ~5 minutes
# No rebuild required

dynamicPlugins:
  # 1. ServiceNow MCP Plugin
  - package: '@rhdh-mcp/servicenow'
    version: '1.0.0'
    disabled: false
    npmPackages:
      - package: '@rhdh-mcp/servicenow'
        version: '1.0.0'
    pluginConfig:
      servicenow:
        baseUrl: 'https://dev123456.service-now.com'
        authenticationType: 'oauth2'
        oauthConfig:
          clientId: '${SERVICENOW_CLIENT_ID}'
          clientSecret: '${SERVICENOW_CLIENT_SECRET}'
        scope: 'incident,change_request,cmdb'
        rbacPolicy: 'servicenow-users'

  # 2. Jira MCP Plugin
  - package: '@rhdh-mcp/jira'
    version: '1.0.0'
    disabled: false
    npmPackages:
      - package: '@rhdh-mcp/jira'
        version: '1.0.0'
    pluginConfig:
      jira:
        baseUrl: 'https://jira.company.com'
        authenticationType: 'apitoken'
        credentials:
          username: '${JIRA_USERNAME}'
          apiToken: '${JIRA_API_TOKEN}'
        projectKeys: ['PROJ', 'DEV', 'OPS']
        rbacPolicy: 'jira-users'

  # 3. GitHub MCP Plugin
  - package: '@rhdh-mcp/github'
    version: '1.0.0'
    disabled: false
    npmPackages:
      - package: '@rhdh-mcp/github'
        version: '1.0.0'
    pluginConfig:
      github:
        baseUrl: 'https://api.github.com'
        authenticationType: 'pat'
        credentials:
          personalAccessToken: '${GITHUB_PAT}'
        organization: 'three-horizons'
        rbacPolicy: 'github-users'

  # 4. Kubernetes MCP Plugin
  - package: '@rhdh-mcp/kubernetes'
    version: '1.0.0'
    disabled: false
    npmPackages:
      - package: '@rhdh-mcp/kubernetes'
        version: '1.0.0'
    pluginConfig:
      kubernetes:
        clusterName: 'rhdh-prod'
        apiServerUrl: 'https://kubernetes.default.svc.cluster.local'
        authenticationType: 'serviceaccount'
        serviceAccountName: 'rhdh-plugin-sa'
        rbacPolicy: 'cluster-admins'
        namespaceFilter:
          - 'default'
          - 'backstage'
          - 'production'

# Plugin marketplace discovery
pluginMarketplace:
  enabled: true
  registries:
    - 'https://registry.npm.org'
    - 'https://registry.private.company.com'
  autoDiscovery: true

# Plugin lifecycle
lifecycle:
  autoUpdate: false
  updateCheckInterval: '24h'
  sandboxing: true
```

### Step 2: Create app-config.yaml with Plugin Configuration

Update `/rhdh-deployment/values/app-config.yaml`:

```yaml
app:
  title: 'Three Horizons RHDH'
  baseUrl: 'https://rhdh.company.com'

backend:
  baseUrl: 'https://rhdh.company.com'
  database:
    client: 'pg'
    connection:
      host: '${DB_HOST}'
      port: 5432
      user: '${DB_USER}'
      password: '${DB_PASSWORD}'
      database: '${DB_NAME}'

auth:
  providers:
    oidc:
      development:
        metadataUrl: 'https://auth.company.com/.well-known/openid-configuration'
        clientId: '${OIDC_CLIENT_ID}'
        clientSecret: '${OIDC_CLIENT_SECRET}'
        scope: 'openid profile email'

# MCP Dynamic Plugins Configuration
plugins:
  dynamicPlugins:
    rootDirectory: '/opt/app-root/plugins'
    frontend: true
    backend: true

# Lightspeed Configuration (see Layer 5 section)
lightspeed:
  enabled: true
  backend:
    baseUrl: 'https://lightspeed-backend:8080'
  chat:
    provider: 'azure-openai'
    model: 'gpt-4'
    maxTokens: 2048
  rag:
    enabled: true
    indexing:
      schedule: '0 */6 * * *'  # Every 6 hours
      batchSize: 100
    vectorDb: 'postgres-pgvector'

# RBAC Configuration
permission:
  enabled: true
  rbac:
    policyFile: '/app/rbac-policy.csv'
    admin:
      superAdmins:
        - 'admin@company.com'
    models:
      - name: 'default'
        definition: |
          [request_definition]
          r = sub, obj, act

          [policy_definition]
          p = sub, obj, act

          [role_definition]
          g = _, _

          [policy_effect]
          e = some(where (p.eft == allow))

          [matchers]
          m = g(r.sub, p.sub) && r.obj == p.obj && r.act == p.act
```

### Step 3: Deployment Methods Comparison

| Method | Time | Complexity | Rebuild | Downtime |
|--------|------|-----------|---------|----------|
| **RHDH Dynamic Plugins (YAML)** | 5 min | Very Low | No | ~30 sec |
| **Backstage Code Plugins** | 30-60 min | High | Yes | 5-10 min |
| **Helm Chart Update** | 10-15 min | Medium | No | 2-3 min |
| **Manual K8s Manifests** | 15-20 min | High | No | 2-5 min |

### Step 4: Deploy via Multiple Tools

#### Option A: Using Copilot Agent Mode

```bash
# Agent prompt
"Deploy the RHDH dynamic plugins from dynamic-plugins.yaml
to the rhdh-prod cluster. Use Azure OpenAI for configuration
validation. Report deployment status."

# Agent executes:
1. Validate dynamic-plugins.yaml schema
2. Resolve environment variables
3. Create/update ConfigMap
4. Trigger plugin hot-reload
5. Verify plugin health
6. Report status
```

#### Option B: Using Coding Agent/CLI

```bash
# Script execution
./scripts/deploy-dynamic-plugins.sh \
  --config values/dynamic-plugins.yaml \
  --cluster rhdh-prod \
  --namespace backstage \
  --wait-for-health
```

Create `scripts/deploy-dynamic-plugins.sh`:

```bash
#!/bin/bash
set -e

CONFIG_FILE="${1:-values/dynamic-plugins.yaml}"
CLUSTER="${2:-rhdh-prod}"
NAMESPACE="${3:-backstage}"
WAIT_HEALTH="${4:-true}"

echo "Deploying RHDH Dynamic Plugins..."
echo "Config: $CONFIG_FILE"
echo "Cluster: $CLUSTER"
echo "Namespace: $NAMESPACE"

# Validate YAML schema
echo "Validating configuration..."
kubeval -d /schemas/rhdh-plugins-schema.json "$CONFIG_FILE"

# Resolve environment variables
echo "Resolving environment variables..."
envsubst < "$CONFIG_FILE" > /tmp/dynamic-plugins-resolved.yaml

# Create ConfigMap
echo "Creating ConfigMap..."
kubectl create configmap rhdh-dynamic-plugins \
  --from-file=/tmp/dynamic-plugins-resolved.yaml \
  --namespace="$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

# Trigger plugin reload
echo "Triggering plugin hot-reload..."
kubectl rollout restart deployment/rhdh-backend -n "$NAMESPACE"

# Wait for health check
if [ "$WAIT_HEALTH" = "true" ]; then
  echo "Waiting for plugins to be healthy..."
  kubectl wait --for=condition=Ready \
    pod -l app=rhdh-backend \
    --namespace="$NAMESPACE" \
    --timeout=5m
fi

echo "Dynamic plugins deployed successfully!"
```

### Step 5: Verify Deployment

```bash
# Check plugin ConfigMap
kubectl get cm rhdh-dynamic-plugins -n backstage -o yaml

# View plugin status
kubectl logs -n backstage -l app=rhdh-backend | grep -i plugin

# Query plugin API
curl -H "Authorization: Bearer $TOKEN" \
  https://rhdh.company.com/api/plugins/status

# Expected output:
# {
#   "plugins": {
#     "servicenow": { "status": "loaded", "version": "1.0.0" },
#     "jira": { "status": "loaded", "version": "1.0.0" },
#     "github": { "status": "loaded", "version": "1.0.0" },
#     "kubernetes": { "status": "loaded", "version": "1.0.0" }
#   },
#   "deploymentTime": "5m 23s"
# }
```

---

## Developer Lightspeed Full Deployment

### Architecture Overview

```
┌────────────────────────────────────────────────────────┐
│ Frontend (React)                                       │
│ ├─ Chat Interface                                      │
│ ├─ Context Panel                                       │
│ └─ Code Preview                                        │
└────────┬─────────────────────────────────────────────┘
         │
┌────────▼─────────────────────────────────────────────┐
│ Backend (Go)                                          │
│ ├─ Session Management                                │
│ ├─ Context Enrichment                                │
│ ├─ RBAC Enforcement                                  │
│ └─ Plugin Orchestration                              │
└────────┬─────────────────────────────────────────────┘
         │
┌────────▼─────────────────────────────────────────────┐
│ Developer Lightspeed Chat Service (LCS)              │
│ ├─ Message Routing                                   │
│ ├─ Prompt Engineering                                │
│ ├─ Response Streaming                                │
│ └─ Token Management                                  │
└────────┬─────────────────────────────────────────────┘
         │
┌────────▼─────────────────────────────────────────────┐
│ LLM Stack (Llama Stack)                              │
│ ├─ Model Layer (LLM)                                 │
│ ├─ Instrumentation Layer                             │
│ ├─ Tooling Layer (MCP Tools)                         │
│ └─ Control Plane                                     │
└────────┬─────────────────────────────────────────────┘
         │
┌────────┴──────────┬──────────────┬──────────────┐
│                   │              │              │
▼                   ▼              ▼              ▼
Azure OpenAI    Ollama          vLLM      OpenShift AI
(Production)  (Self-hosted)  (Optimized)  (Red Hat)
```

### Step 1: Create Helm Values for Lightspeed

Create `/rhdh-deployment/values/lightspeed-values.yaml`:

```yaml
# Developer Lightspeed Helm Configuration
# Version: 1.0.0

lightspeed:
  enabled: true

  # Frontend Configuration
  frontend:
    enabled: true
    replicaCount: 2
    image:
      repository: 'registry.company.com/rhdh/lightspeed-frontend'
      tag: '1.0.0'
      pullPolicy: 'IfNotPresent'

    service:
      type: 'ClusterIP'
      port: 3000
      targetPort: 3000

    resources:
      requests:
        cpu: '250m'
        memory: '512Mi'
      limits:
        cpu: '500m'
        memory: '1Gi'

    env:
      - name: REACT_APP_BACKEND_URL
        value: 'http://lightspeed-backend:8080'
      - name: REACT_APP_LOG_LEVEL
        value: 'info'

    ingress:
      enabled: true
      host: 'lightspeed.company.com'
      path: '/'
      tls:
        enabled: true
        secretName: 'lightspeed-tls'

  # Backend Configuration
  backend:
    enabled: true
    replicaCount: 3
    image:
      repository: 'registry.company.com/rhdh/lightspeed-backend'
      tag: '1.0.0'
      pullPolicy: 'IfNotPresent'

    service:
      type: 'ClusterIP'
      port: 8080
      targetPort: 8080

    resources:
      requests:
        cpu: '500m'
        memory: '1Gi'
      limits:
        cpu: '1000m'
        memory: '2Gi'

    env:
      - name: LOG_LEVEL
        value: 'info'
      - name: DATABASE_HOST
        valueFrom:
          secretKeyRef:
            name: 'lightspeed-db'
            key: 'host'
      - name: DATABASE_USER
        valueFrom:
          secretKeyRef:
            name: 'lightspeed-db'
            key: 'user'
      - name: DATABASE_PASSWORD
        valueFrom:
          secretKeyRef:
            name: 'lightspeed-db'
            key: 'password'

    database:
      enabled: true
      type: 'postgresql'
      host: '${DB_HOST}'
      port: 5432
      name: 'lightspeed'

    rbac:
      enabled: true
      policyFile: '/app/rbac-policy.csv'

  # Lightspeed Chat Service (LCS)
  lcs:
    enabled: true
    replicaCount: 2
    image:
      repository: 'registry.company.com/rhdh/lightspeed-chat-service'
      tag: '1.0.0'

    service:
      type: 'ClusterIP'
      port: 9000
      targetPort: 9000

    resources:
      requests:
        cpu: '1000m'
        memory: '2Gi'
      limits:
        cpu: '2000m'
        memory: '4Gi'

    config:
      maxConcurrentSessions: 100
      sessionTimeout: '3600'
      tokenRefreshInterval: '300'
      streamingEnabled: true
      chunkSize: 1024

  # Llama Stack Configuration
  llamaStack:
    enabled: true
    version: '0.1.0'

    modelLayer:
      provider: 'azure-openai'  # Can be: azure-openai, ollama, vllm, openshift-ai
      config:
        apiVersion: '2024-02-01'
        deploymentName: 'gpt-4-deployment'

    instrumentationLayer:
      enabled: true
      telemetry:
        enabled: true
        otlpEndpoint: 'https://otel-collector:4317'
        samplingRate: 0.1

    toolingLayer:
      enabled: true
      tools:
        - 'curl-mcp'
        - 'browser-mcp'
        - 'github-mcp'
        - 'kubernetes-mcp'
        - 'servicenow-mcp'
        - 'microsoft-skills'

    controlPlane:
      enabled: true
      logLevel: 'info'

  # RAG Configuration
  rag:
    enabled: true

    indexing:
      enabled: true
      schedule: '0 */6 * * *'  # Every 6 hours
      batchSize: 100
      parallelWorkers: 4

    vectorDatabase:
      type: 'postgres-pgvector'
      host: '${PGVECTOR_HOST}'
      port: 5432
      database: 'lightspeed_vectors'
      embeddingModel: 'text-embedding-ada-002'
      embeddingDimensions: 1536

    dataSource:
      repositories:
        - 'three-horizons-rhdh'
        - 'microsoft/skills'
        - 'rhdh-plugins'
      indexableTypes:
        - 'markdown'
        - 'yaml'
        - 'json'
        - 'source-code'
      excludePaths:
        - 'node_modules'
        - '.git'
        - 'dist'
        - 'build'

# Secret References (create separately)
secrets:
  azure-openai:
    apiKey: 'lightspeed-azure-openai-key'
    endpoint: 'lightspeed-azure-openai-endpoint'

  database:
    host: 'lightspeed-db-host'
    user: 'lightspeed-db-user'
    password: 'lightspeed-db-password'

  pgvector:
    host: 'lightspeed-pgvector-host'
    user: 'lightspeed-pgvector-user'
    password: 'lightspeed-pgvector-password'

# RBAC Configuration
rbac:
  enabled: true
  rules:
    - apiGroups: ['lightspeed.rhdh.io']
      resources: ['chats', 'contexts']
      verbs: ['get', 'list', 'create']
    - apiGroups: ['lightspeed.rhdh.io']
      resources: ['admin/policies']
      verbs: ['get', 'list', 'create', 'update', 'delete']
      unauthenticatedUser: false
```

### Step 2: Create ConfigMaps for BYOM Providers

#### Azure OpenAI ConfigMap

Create `/rhdh-deployment/configmaps/lightspeed-azure-openai.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lightspeed-azure-openai-config
  namespace: backstage
data:
  config.yaml: |
    provider: 'azure-openai'

    apiVersion: '2024-02-01'
    apiEndpoint: '${AZURE_OPENAI_ENDPOINT}'
    deploymentName: 'gpt-4-deployment'

    models:
      - name: 'gpt-4'
        deployment: 'gpt-4-deployment'
        maxTokens: 8192
        temperature: 0.7
        topP: 0.9

      - name: 'gpt-4-turbo'
        deployment: 'gpt-4-turbo-deployment'
        maxTokens: 128000
        temperature: 0.7
        topP: 0.9

      - name: 'text-embedding-ada-002'
        deployment: 'embedding-deployment'
        dimension: 1536

    retryPolicy:
      maxRetries: 3
      retryDelay: 1000  # ms
      backoffMultiplier: 2.0

    rateLimit:
      tokensPerMinute: 40000
      requestsPerMinute: 120

    monitoring:
      enabled: true
      metricsEndpoint: 'http://prometheus:9090'
      alerting:
        enabled: true
        rules:
          - 'azure_openai_error_rate > 0.05'
          - 'azure_openai_latency_p99 > 5000'
---
apiVersion: v1
kind: Secret
metadata:
  name: lightspeed-azure-openai-secret
  namespace: backstage
type: Opaque
stringData:
  apiKey: '${AZURE_OPENAI_API_KEY}'
  endpoint: '${AZURE_OPENAI_ENDPOINT}'
```

#### Ollama ConfigMap

Create `/rhdh-deployment/configmaps/lightspeed-ollama.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lightspeed-ollama-config
  namespace: backstage
data:
  config.yaml: |
    provider: 'ollama'

    endpoint: 'http://ollama:11434'

    models:
      - name: 'llama2'
        pull: true
        quantization: 'Q4_0'
        parameters:
          temperature: 0.7
          topP: 0.9
          topK: 40

      - name: 'mistral'
        pull: true
        quantization: 'Q4_0'
        parameters:
          temperature: 0.7
          topP: 0.9

      - name: 'nomic-embed-text'
        pull: true
        purpose: 'embedding'

    healthCheck:
      enabled: true
      interval: '30s'
      timeout: '5s'

    persistence:
      enabled: true
      storageClass: 'fast-ssd'
      size: '50Gi'
      path: '/root/.ollama'

    resources:
      requests:
        cpu: '2000m'
        memory: '4Gi'
        nvidia.com/gpu: '1'
      limits:
        cpu: '4000m'
        memory: '8Gi'
        nvidia.com/gpu: '1'
---
apiVersion: v1
kind: Secret
metadata:
  name: lightspeed-ollama-secret
  namespace: backstage
type: Opaque
stringData:
  pullSecret: '${OLLAMA_REGISTRY_SECRET}'
```

#### vLLM ConfigMap

Create `/rhdh-deployment/configmaps/lightspeed-vllm.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: lightspeed-vllm-config
  namespace: backstage
data:
  config.yaml: |
    provider: 'vllm'

    endpoint: 'http://vllm:8000'

    modelServer:
      model: 'meta-llama/Llama-2-7b-hf'
      dtype: 'float16'
      gpuMemoryUtilization: 0.9
      maxModelLen: 4096
      enablePrefix_caching: true
      enableChunked_prefill: true

    models:
      - name: 'llama2-7b'
        modelPath: 'meta-llama/Llama-2-7b-hf'
        maxBatchSize: 128

      - name: 'llama2-13b'
        modelPath: 'meta-llama/Llama-2-13b-hf'
        maxBatchSize: 64

    performance:
      maxNumSeqsPerIteration: 256
      maxNumBatchedTokens: 20480
      enableRayCustomMetrics: true

    resources:
      requests:
        cpu: '4000m'
        memory: '8Gi'
        nvidia.com/gpu: '2'
      limits:
        cpu: '8000m'
        memory: '16Gi'
        nvidia.com/gpu: '2'

    persistence:
      enabled: true
      size: '100Gi'
      storageClass: 'fast-ssd'
```

### Step 3: Create RBAC Policies

Create `/rhdh-deployment/rbac/lightspeed-policies.csv`:

```csv
# Lightspeed RBAC Policies
# Format: p, role, resource, action

# Admin role - full access
p, admin, lightspeed:chat, create
p, admin, lightspeed:chat, read
p, admin, lightspeed:chat, update
p, admin, lightspeed:chat, delete
p, admin, lightspeed:context, read
p, admin, lightspeed:context, update
p, admin, lightspeed:rag, manage
p, admin, lightspeed:config, manage

# Developer role - basic usage
p, developer, lightspeed:chat, create
p, developer, lightspeed:chat, read
p, developer, lightspeed:context, read
p, developer, lightspeed:rag, read

# Platform engineer role - advanced features
p, platform-engineer, lightspeed:chat, create
p, platform-engineer, lightspeed:chat, read
p, platform-engineer, lightspeed:chat, update
p, platform-engineer, lightspeed:context, read
p, platform-engineer, lightspeed:context, update
p, platform-engineer, lightspeed:rag, manage

# Viewer role - read-only
p, viewer, lightspeed:chat, read
p, viewer, lightspeed:context, read

# Role inheritance
g, user@company.com, admin
g, platform-team@company.com, platform-engineer
g, devs@company.com, developer
```

### Step 4: Custom Prompts Configuration

Create `/rhdh-deployment/prompts/lightspeed-prompts.yaml`:

```yaml
lightspeedPrompts:
  system_prompt: |
    You are Developer Lightspeed, an AI assistant embedded in Red Hat Developer Hub (RHDH).
    Your role is to help developers with:

    1. Application deployment and management
    2. Kubernetes cluster operations
    3. CI/CD pipeline automation
    4. Infrastructure as Code (IaC) assistance
    5. Troubleshooting and diagnostics
    6. Security and compliance guidance

    Always:
    - Provide clear, actionable guidance
    - Explain the reasoning behind recommendations
    - Ask clarifying questions when needed
    - Respect RBAC and security policies
    - Suggest best practices aligned with Three Horizons principles
    - Reference official documentation when applicable

  context_system_prompt: |
    You have access to the following context:

    1. **Current Workspace**: {workspace_context}
    2. **User Role**: {user_role}
    3. **Available Clusters**: {available_clusters}
    4. **Recent Changes**: {recent_changes}
    5. **Related Tickets**: {related_tickets}

    Use this context to provide personalized assistance.

  deployment_prompt: |
    Help the user deploy an application to Kubernetes.

    Steps:
    1. Understand deployment requirements
    2. Validate cluster and namespace availability
    3. Check RBAC permissions
    4. Suggest appropriate deployment strategy
    5. Generate deployment manifests
    6. Provide rollout and verification steps

  troubleshooting_prompt: |
    Help the user troubleshoot and resolve issues.

    Steps:
    1. Gather symptom information
    2. Request relevant logs and metrics
    3. Analyze error patterns
    4. Suggest diagnostic commands
    5. Provide remediation steps
    6. Suggest preventive measures

  code_generation_prompt: |
    Help the user generate code for deployment, configuration, or automation.

    Guidelines:
    - Follow company coding standards
    - Include error handling
    - Add logging and monitoring
    - Provide usage examples
    - Suggest testing strategies

  custom_prompts:
    - name: 'microservice-deployment'
      template: |
        The user wants to deploy a microservice.

        Gather these details:
        - Service name and version
        - Language/runtime
        - Resource requirements
        - Dependencies and integrations
        - Expected scale and traffic

        Then provide a complete deployment guide.

    - name: 'security-audit'
      template: |
        The user wants to audit deployment security.

        Check:
        - Image vulnerability scans
        - RBAC configuration
        - Network policies
        - Secret management
        - Pod security policies

        Provide a security report with recommendations.

    - name: 'cost-optimization'
      template: |
        The user wants to optimize deployment costs.

        Analyze:
        - Resource requests/limits
        - Pod density
        - Reserved capacity
        - Autoscaling configuration

        Suggest optimizations aligned with business goals.
```

### Step 5: Deploy Lightspeed

```bash
# Add RHDH Helm repo
helm repo add rhdh https://charts.redhat.com/rhdh
helm repo update

# Create namespace
kubectl create namespace backstage

# Create secrets
kubectl create secret generic lightspeed-azure-openai-secret \
  --from-literal=apiKey='your-azure-openai-api-key' \
  --from-literal=endpoint='your-azure-openai-endpoint' \
  -n backstage

kubectl create secret generic lightspeed-db \
  --from-literal=host='postgres.company.com' \
  --from-literal=user='lightspeed_user' \
  --from-literal=password='secure-password' \
  -n backstage

# Deploy using Helm
helm install rhdh-lightspeed rhdh/rhdh \
  -f /rhdh-deployment/values/lightspeed-values.yaml \
  -n backstage \
  --wait

# Verify deployment
kubectl get pods -n backstage -l app=lightspeed
kubectl get svc -n backstage | grep lightspeed
```

---

## BYOM Decision Matrix

### Provider Comparison Table

| Feature | Azure OpenAI | Ollama | vLLM | OpenShift AI |
|---------|---|---|---|---|
| **Use Case** | Production, enterprise | Development, air-gapped | High-throughput, optimization | Red Hat integrated |
| **Setup Time** | 10-15 min | 30-45 min | 45-60 min | 20-30 min |
| **Cost** | Pay-per-API | Self-hosted (hardware) | Self-hosted (hardware) | Per-seat licensing |
| **Models** | Azure-hosted (GPT-4, GPT-3.5) | Open-source (Llama, Mistral) | Open-source (custom optimized) | Red Hat-optimized |
| **Latency** | 100-500ms | 500-2000ms (depends on GPU) | 100-300ms (high-throughput) | 200-800ms |
| **Throughput** | High (API-managed) | Medium (single GPU) | Very High (multi-GPU) | High (distributed) |
| **Compliance** | SOC2, HIPAA | Self-managed | Self-managed | Red Hat compliance |
| **Air-Gapped** | No | Yes | Yes | Yes |
| **GPU Required** | No | Yes | Yes | Yes |
| **Scaling** | Vertical (API limits) | Horizontal (multiple nodes) | Horizontal (multi-GPU servers) | Horizontal (K8s native) |
| **Support** | Microsoft | Community | Community | Red Hat Enterprise |

### Decision Tree

```
START: Need an LLM provider?
│
├─ Production environment?
│  ├─ YES → Azure OpenAI
│  │         - Enterprise-grade SLAs
│  │         - Microsoft 365 integration
│  │         - Compliance certifications
│  │
│  └─ NO → Continue...
│
├─ Air-gapped deployment?
│  ├─ YES → Ollama or vLLM
│  │         - No external API calls
│  │         - Self-managed infrastructure
│  │         - Choose vLLM for high throughput
│  │
│  └─ NO → Continue...
│
├─ Red Hat platform?
│  ├─ YES → OpenShift AI
│  │         - Native K8s integration
│  │         - Red Hat support
│  │         - ARO compatibility
│  │
│  └─ NO → Continue...
│
├─ Need high throughput?
│  ├─ YES → vLLM
│  │         - 100+ req/s capability
│  │         - Multi-GPU optimization
│  │         - Prefix caching
│  │
│  └─ NO → Ollama
│           - Simpler setup
│           - Lower resource needs
│           - Single GPU sufficient
```

### Setup Timelines

**Azure OpenAI (10-15 minutes)**
```
1. Create Azure OpenAI resource (5 min)
2. Deploy models (2 min)
3. Configure RHDH secrets (3 min)
4. Update ConfigMap (2 min)
5. Test connectivity (3 min)
```

**Ollama (30-45 minutes)**
```
1. Provision GPU node (5 min)
2. Install Ollama runtime (5 min)
3. Pull models (10-20 min, depends on model size)
4. Configure RHDH (5 min)
5. Health checks (5 min)
```

**vLLM (45-60 minutes)**
```
1. Provision multi-GPU nodes (10 min)
2. Install vLLM server (5 min)
3. Download and optimize models (15-30 min)
4. Configure vLLM parameters (10 min)
5. Integration and testing (10 min)
```

**OpenShift AI (20-30 minutes)**
```
1. Install OpenShift AI operator (5 min)
2. Create ModelServing instance (5 min)
3. Deploy model (5-10 min)
4. Configure RHDH integration (5 min)
5. Testing (5 min)
```

### Cost Analysis

**Azure OpenAI (per month)**
```
- GPT-4: $0.03/1K input tokens, $0.06/1K output tokens
- GPT-3.5: $0.0005/1K input, $0.0015/1K output
- Embedding: $0.0001/1K tokens

Example for 100 developers, 50 chats/day:
- 100 dev * 50 chats * 2K tokens/chat * $0.03 = ~$300/month
- Plus embedding costs for RAG: ~$50/month
- Total: ~$350/month
```

**Ollama (self-hosted)**
```
- Hardware cost: GPU server $3,000-5,000 (amortized over 3 years)
- Electricity: ~1500W * 24h * 30 = 1,080 kWh * $0.10 = $108/month
- Maintenance: ~$200/month (engineer time)
- Total: ~$300-400/month (comparable to Azure OpenAI)
```

**vLLM (self-hosted)**
```
- Hardware: 2x GPU servers $8,000-10,000 (amortized)
- Electricity: ~3000W * 24h * 30 * $0.10 = $216/month
- Maintenance: ~$300/month (advanced tuning)
- Total: ~$500-600/month (for high throughput)
```

**OpenShift AI (on-premise)**
```
- Hardware: Included with OpenShift cluster
- License: Red Hat subscription (~$5,000/year per cluster)
- Maintenance: Included in support
- Total: ~$400/month for subscription (hardware separate)
```

---

## Configure External AI Clients (All 7)

### 1. VS Code + GitHub Copilot

Create `.vscode/settings.json`:

```json
{
  "github.copilot.enable": {
    "*": true,
    "plaintext": true,
    "markdown": true
  },
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit"
    }
  },
  "mcp.servers": {
    "rhdh": {
      "command": "node",
      "args": ["/path/to/rhdh-mcp-server/dist/index.js"],
      "env": {
        "RHDH_API_URL": "https://rhdh.company.com/api",
        "RHDH_TOKEN": "${RHDH_API_TOKEN}"
      }
    }
  },
  "github.copilot.advanced": {
    "debug.overrideCurlWithLocalhost": false,
    "debug.testingOverrideProxyUrl": "",
    "debug.overrideEngine": "",
    "debug.overrideProxy": "",
    "authProvider": "github"
  },
  "copilot.advanced.instructions": "You are assisting a developer with RHDH deployment and Kubernetes management. Use MCP tools for cluster operations. Always check RBAC permissions before executing commands."
}
```

Create `.vscode/extensions.json`:

```json
{
  "recommendations": [
    "GitHub.copilot",
    "GitHub.copilot-chat",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "ms-azure-tools.vscode-docker",
    "redhat.vscode-yaml",
    "ms-vscode.makefile-tools",
    "hashicorp.terraform"
  ]
}
```

### 2. GitHub Copilot CLI

Create `~/.copilot/config.json`:

```json
{
  "apiVersion": "v1",
  "provider": "github",
  "authentication": {
    "token": "${GITHUB_TOKEN}",
    "tokenRefresh": true
  },
  "mcpIntegration": {
    "enabled": true,
    "servers": [
      {
        "name": "rhdh-kubernetes",
        "endpoint": "http://localhost:3001",
        "auth": "bearer:${RHDH_API_TOKEN}"
      },
      {
        "name": "microsoft-skills",
        "endpoint": "http://localhost:3002"
      }
    ]
  },
  "commands": [
    {
      "name": "deploy",
      "description": "Deploy application",
      "usage": "copilot deploy --app myapp --env prod"
    },
    {
      "name": "k8s",
      "description": "Kubernetes operations",
      "usage": "copilot k8s --cluster rhdh-prod --action scale"
    },
    {
      "name": "workflow",
      "description": "Execute automation workflow",
      "usage": "copilot workflow --name deployment"
    }
  ]
}
```

### 6. Azure AI Foundry Agent

Configuration in Azure Portal:

```yaml
Agent Name: "RHDH Deployment Agent"
Model: "gpt-4-deployment" (Azure OpenAI)
System Message: |
  You are a deployment automation agent for Red Hat Developer Hub.

  Available tools:
  - Kubernetes MCP: Deploy and manage applications
  - GitHub MCP: Manage code and CI/CD
  - ServiceNow MCP: Create and manage tickets
  - Microsoft Skills: Execute automation tasks

  Process deployments with:
  1. Validation
  2. Pre-flight checks
  3. Execution
  4. Verification
  5. Rollback capability

Tools:
  - rhdh-mcp-kubernetes (Kubernetes deployment and management)
  - rhdh-mcp-github (Code and workflow automation)
  - rhdh-mcp-servicenow (Incident and change management)
  - microsoft-skills (100+ automation tasks)

Monitoring:
  - CloudWatch logs: /aws/foundry/rhdh-agent
  - Metrics: deployment duration, success rate, error rates
  - Alerts: on deployment failures, policy violations

Configuration:
  Temperature: 0.7
  Max tokens: 2048
  Top P: 0.9
```

### 7. Foundry MCP Server

Create `/foundry-mcp-server/config.yaml`:

```yaml
# Foundry MCP Server Configuration
server:
  name: "Foundry RHDH MCP Server"
  version: "1.0.0"
  port: 8000

tools:
  # Kubernetes Operations
  kubernetes:
    enabled: true
    clusters:
      - name: "rhdh-prod"
        endpoint: "https://rhdh-prod-api.company.com"
        auth: "bearer-token"
        rbacEnabled: true
        rbacFile: "/etc/rbac/rhdh-mcp-policy.csv"
    operations:
      - deploy
      - scale
      - rollback
      - status
      - logs

  # GitHub Operations
  github:
    enabled: true
    endpoint: "https://api.github.com"
    org: "three-horizons"
    auth: "pat"
    operations:
      - create-pr
      - merge-pr
      - list-issues
      - trigger-workflow

  # ServiceNow Operations
  servicenow:
    enabled: true
    endpoint: "${SERVICENOW_ENDPOINT}"
    auth: "oauth2"
    tables:
      - "incident"
      - "change_request"
      - "cmdb_ci"
    operations:
      - create-ticket
      - update-ticket
      - assign-ticket

  # Microsoft Skills
  skills:
    enabled: true
    skillsPath: "/repos/microsoft/skills"
    categories:
      - "kubernetes"
      - "deployment"
      - "automation"

# Monitoring and Logging
monitoring:
  enabled: true
  metricsPort: 9090
  logsPath: "/var/log/foundry-mcp"
  logLevel: "info"

  prometheus:
    enabled: true
    scrapeInterval: "15s"

  alerts:
    - name: "tool-execution-failure"
      query: "rate(foundry_mcp_tool_errors_total[5m]) > 0.1"
      severity: "warning"
    - name: "high-latency"
      query: "foundry_mcp_tool_duration_seconds_p99 > 5"
      severity: "info"

# Security and RBAC
security:
  tlsEnabled: true
  certFile: "/etc/certs/server.crt"
  keyFile: "/etc/certs/server.key"

  authentication:
    type: "jwt"
    jwtSecret: "${FOUNDRY_JWT_SECRET}"

  rbac:
    enabled: true
    policyEngine: "casbin"
    policyFile: "/etc/rbac/mcp-policy.csv"

  auditLogging:
    enabled: true
    path: "/var/log/foundry-mcp-audit.log"

# Integration with External Systems
integrations:
  lightspeed:
    enabled: true
    endpoint: "http://lightspeed-backend:8080"
    tokenRefresh: "5m"

  rhdh:
    enabled: true
    endpoint: "https://rhdh.company.com/api"
    tokenRefresh: "5m"
```

---

## Azure AI Foundry Agent for RHDH

### Agent Configuration

Create Azure AI Foundry Agent with RHDH MCP Tools:

```json
{
  "agent": {
    "name": "RHDH Deployment & Lightspeed Agent",
    "version": "1.0.0",
    "description": "Automated deployment and platform operations via RHDH MCP",

    "model": {
      "provider": "Azure OpenAI",
      "deployment": "gpt-4-deployment",
      "apiVersion": "2024-02-01",
      "temperature": 0.7,
      "maxTokens": 2048,
      "topP": 0.9
    },

    "systemMessage": "You are an intelligent deployment agent for Red Hat Developer Hub. You help developers deploy applications, manage Kubernetes resources, and automate platform operations. Always validate inputs, check RBAC permissions, and follow best practices.",

    "tools": [
      {
        "name": "kubernetes-deploy",
        "description": "Deploy applications to Kubernetes cluster",
        "mcp": "rhdh-mcp-kubernetes",
        "endpoint": "http://rhdh-mcp-kubernetes:3001",
        "auth": "bearer-token",
        "parameters": [
          {
            "name": "cluster",
            "type": "string",
            "description": "Target cluster name",
            "required": true,
            "enum": ["rhdh-prod", "rhdh-staging", "rhdh-dev"]
          },
          {
            "name": "namespace",
            "type": "string",
            "description": "Target namespace",
            "required": true
          },
          {
            "name": "manifest",
            "type": "object",
            "description": "Kubernetes manifest",
            "required": true
          },
          {
            "name": "strategy",
            "type": "string",
            "description": "Deployment strategy",
            "enum": ["rolling", "blue-green", "canary"],
            "default": "rolling"
          }
        ]
      },
      {
        "name": "github-automation",
        "description": "Automate GitHub operations (PRs, workflows)",
        "mcp": "rhdh-mcp-github",
        "endpoint": "http://rhdh-mcp-github:3002",
        "auth": "pat",
        "parameters": [
          {
            "name": "action",
            "type": "string",
            "description": "GitHub action to perform",
            "enum": ["create-pr", "merge-pr", "trigger-workflow", "list-issues"],
            "required": true
          },
          {
            "name": "repository",
            "type": "string",
            "description": "GitHub repository",
            "required": true
          },
          {
            "name": "details",
            "type": "object",
            "description": "Action-specific details",
            "required": true
          }
        ]
      },
      {
        "name": "lightspeed-integration",
        "description": "Query Lightspeed AI chat context and history",
        "mcp": "rhdh-mcp-lightspeed",
        "endpoint": "http://lightspeed-backend:8080",
        "auth": "bearer-token",
        "parameters": [
          {
            "name": "sessionId",
            "type": "string",
            "description": "Lightspeed chat session ID",
            "required": true
          },
          {
            "name": "query",
            "type": "string",
            "description": "Query about chat context",
            "required": true
          },
          {
            "name": "includeRag",
            "type": "boolean",
            "description": "Include RAG results",
            "default": true
          }
        ]
      },
      {
        "name": "microsoft-skills",
        "description": "Execute pre-built automation skills",
        "mcp": "microsoft-skills",
        "endpoint": "http://microsoft-skills-mcp:3003",
        "parameters": [
          {
            "name": "skillName",
            "type": "string",
            "description": "Name of the skill to execute",
            "required": true
          },
          {
            "name": "parameters",
            "type": "object",
            "description": "Skill-specific parameters",
            "required": true
          }
        ]
      }
    ],

    "workflows": [
      {
        "name": "automated-deployment",
        "description": "End-to-end deployment workflow",
        "steps": [
          {
            "name": "validate-manifest",
            "tool": "kubernetes-deploy",
            "action": "validate"
          },
          {
            "name": "check-rbac",
            "tool": "kubernetes-deploy",
            "action": "check-permissions"
          },
          {
            "name": "pre-deployment-health-check",
            "tool": "kubernetes-deploy",
            "action": "health-check"
          },
          {
            "name": "execute-deployment",
            "tool": "kubernetes-deploy",
            "action": "deploy"
          },
          {
            "name": "post-deployment-verification",
            "tool": "kubernetes-deploy",
            "action": "verify"
          },
          {
            "name": "create-deployment-ticket",
            "tool": "microsoft-skills",
            "skill": "create-servicenow-ticket"
          }
        ]
      },
      {
        "name": "incident-response",
        "description": "Automate incident diagnosis and response",
        "steps": [
          {
            "name": "gather-diagnostics",
            "tool": "kubernetes-deploy",
            "action": "get-cluster-status"
          },
          {
            "name": "analyze-logs",
            "tool": "kubernetes-deploy",
            "action": "get-pod-logs"
          },
          {
            "name": "create-incident-ticket",
            "tool": "microsoft-skills",
            "skill": "create-incident"
          },
          {
            "name": "notify-team",
            "tool": "microsoft-skills",
            "skill": "send-notification"
          },
          {
            "name": "suggest-remediation",
            "tool": "lightspeed-integration",
            "action": "query-context"
          }
        ]
      }
    ],

    "monitoring": {
      "enabled": true,
      "metrics": [
        "deployment-success-rate",
        "deployment-duration",
        "tool-execution-errors",
        "rbac-denials"
      ],
      "logging": {
        "enabled": true,
        "level": "info",
        "destination": "azure-application-insights"
      },
      "alerts": [
        {
          "name": "deployment-failure",
          "condition": "deployment_success_rate < 0.95",
          "severity": "high",
          "action": "notify-platform-team"
        },
        {
          "name": "rbac-violation",
          "condition": "rbac_denials > 5",
          "severity": "critical",
          "action": "create-security-ticket"
        }
      ]
    },

    "permissions": {
      "rbac": {
        "enabled": true,
        "policyEngine": "casbin",
        "roles": [
          {
            "name": "deployment-operator",
            "permissions": [
              "kubernetes-deploy",
              "github-automation",
              "lightspeed-integration"
            ]
          },
          {
            "name": "admin",
            "permissions": ["*"]
          }
        ]
      }
    }
  }
}
```

### Lightspeed Monitoring Agent

Create Azure AI Foundry Agent for monitoring Lightspeed:

```json
{
  "monitoringAgent": {
    "name": "Lightspeed Health Monitor",
    "version": "1.0.0",
    "description": "Monitors Lightspeed availability, performance, and usage",

    "model": {
      "provider": "Azure OpenAI",
      "deployment": "gpt-4-deployment"
    },

    "systemMessage": "You are a monitoring agent for Developer Lightspeed. Monitor service health, user engagement, RAG indexing, and performance metrics. Alert on anomalies.",

    "tools": [
      {
        "name": "lightspeed-health",
        "description": "Check Lightspeed service health",
        "mcp": "rhdh-mcp-lightspeed",
        "operations": [
          "get-service-status",
          "check-backend-health",
          "verify-lcs-availability",
          "check-rag-indexing-status"
        ]
      },
      {
        "name": "lightspeed-metrics",
        "description": "Retrieve Lightspeed metrics",
        "mcp": "prometheus",
        "queries": [
          "lightspeed_chat_sessions_active",
          "lightspeed_average_response_time",
          "lightspeed_token_usage_total",
          "lightspeed_rag_documents_indexed",
          "lightspeed_chat_messages_total"
        ]
      },
      {
        "name": "lightspeed-logs",
        "description": "Query Lightspeed logs",
        "mcp": "azure-logs",
        "logSource": "lightspeed-logs"
      }
    ],

    "monitoringRules": [
      {
        "name": "backend-availability",
        "condition": "lightspeed_backend_health == down",
        "alertSeverity": "critical",
        "action": "page-oncall-engineer"
      },
      {
        "name": "high-latency",
        "condition": "lightspeed_response_time_p99 > 5000",
        "alertSeverity": "warning",
        "action": "create-performance-ticket"
      },
      {
        "name": "rag-indexing-lag",
        "condition": "lightspeed_rag_lag_hours > 12",
        "alertSeverity": "info",
        "action": "trigger-manual-indexing"
      },
      {
        "name": "token-quota-exceeded",
        "condition": "lightspeed_daily_tokens > quota * 0.8",
        "alertSeverity": "warning",
        "action": "notify-cost-center"
      }
    ],

    "schedules": [
      {
        "name": "health-check-hourly",
        "frequency": "0 * * * *",
        "action": "run-health-checks"
      },
      {
        "name": "metrics-summary-daily",
        "frequency": "0 9 * * *",
        "action": "generate-daily-report"
      },
      {
        "name": "rag-reindexing",
        "frequency": "0 2 * * *",
        "action": "trigger-full-rag-reindex"
      }
    ]
  }
}
```

---

## Side-by-Side Comparison: Backstage vs RHDH

### Comprehensive Comparison Table

| Feature | Backstage | RHDH | Winner |
|---------|-----------|------|--------|
| **Plugin Deployment** | Code rebuild (30-60 min) | YAML plugins (5 min) | RHDH |
| **Plugin Hot-Reload** | No (requires restart) | Yes (no restart) | RHDH |
| **Kubernetes Native** | Community support | First-class (CRDs) | RHDH |
| **In-Portal AI** | Requires integration | Built-in Lightspeed | RHDH |
| **RBAC** | Backstage RBAC | Backstage + K8s RBAC | RHDH |
| **Container Native** | No | Yes (operators) | RHDH |
| **Official Helm Charts** | Community maintained | Red Hat maintained | RHDH |
| **Enterprise Support** | Roadie (commercial) | Red Hat (commercial) | RHDH |
| **Maturity** | Established (2016+) | Newer (2023+) | Backstage |
| **Community Size** | Large | Growing | Backstage |
| **MCP Integration** | Manual setup | Native | RHDH |
| **Sealed Secrets** | Manual | Integrated | RHDH |
| **Deployment Targets** | Any K8s | AKS/ARO preferred | Backstage (flexible) |
| **Cost** | Open source + Roadie | Open source + Red Hat | Tie |
| **Learning Curve** | Medium | Medium | Tie |
| **Production Ready** | Yes (mature) | Yes (stable) | Tie |
| **GitOps Support** | Community plugins | Native | RHDH |
| **Observability** | Limited | OTEL-native | RHDH |
| **Air-Gapped Support** | Possible (manual) | Built-in | RHDH |

### Migration Path: Backstage → RHDH

```
Phase 1: Preparation (Week 1)
├─ Document current Backstage plugins
├─ Identify RHDH equivalents
├─ Plan data migration strategy
└─ Set up parallel environment

Phase 2: Migration (Week 2-3)
├─ Deploy RHDH cluster
├─ Migrate Backstage database
├─ Convert plugins to dynamic plugins (YAML)
├─ Test integrations
└─ User acceptance testing

Phase 3: Cutover (Week 4)
├─ Final synchronization
├─ User communication
├─ Parallel run (optional)
├─ Primary cutover
└─ Monitoring and support

Phase 4: Optimization (Week 5+)
├─ Performance tuning
├─ User feedback collection
├─ Additional plugin deployment
└─ Production stabilization
```

### Feature Parity Matrix

| Feature Category | Backstage | RHDH | Status |
|---|---|---|---|
| **Core Platform** | Full | Full | ✓ Parity |
| **Component Discovery** | Full | Full | ✓ Parity |
| **Catalog** | Full | Full | ✓ Parity |
| **Templates (TechDocs)** | Full | Enhanced | ✓ RHDH Better |
| **AI Integration** | Partial | Full (Lightspeed) | ✓ RHDH Better |
| **K8s Integration** | Community | Native | ✓ RHDH Better |
| **Plugin System** | Code-based | YAML-based | ✓ RHDH Better |
| **RBAC** | Standard | Enhanced | ✓ RHDH Better |
| **Helm Deployment** | Community | Official | ✓ RHDH Better |
| **Enterprise Support** | Roadie | Red Hat | ✓ Both Available |

---

## References

### Official Documentation

- **RHDH Documentation**: https://developers.redhat.com/rhdh
- **Backstage Documentation**: https://backstage.io/docs
- **RHDH MCP Plugins**: https://github.com/redhat-developer-hub/rhdh-mcp-plugins
- **Microsoft MCP**: https://github.com/microsoft/mcp
- **Microsoft Skills**: https://github.com/microsoft/skills
- **Llama Stack**: https://github.com/run-llama/llama_stack
- **RHDH Lightspeed**: https://developers.redhat.com/rhdh/lightspeed

### Azure AI Services

- **Azure OpenAI Service**: https://learn.microsoft.com/en-us/azure/ai-services/openai/
- **Azure AI Foundry**: https://learn.microsoft.com/en-us/azure/ai-studio/
- **Azure Container Registry**: https://learn.microsoft.com/en-us/azure/container-registry/
- **Azure Kubernetes Service (AKS)**: https://learn.microsoft.com/en-us/azure/aks/

### Red Hat Services

- **Red Hat Developer Hub**: https://developers.redhat.com/rhdh
- **OpenShift AI**: https://www.redhat.com/en/technologies/cloud-computing/openshift/ai
- **Azure Red Hat OpenShift (ARO)**: https://learn.microsoft.com/en-us/azure/openshift/

### MCP Implementations

- **VS Code Copilot Integration**: https://docs.github.com/en/copilot/developing-copilot-apps
- **GitHub Copilot CLI**: https://docs.github.com/en/copilot/github-copilot-cli
- **Azure AI Foundry Agents**: https://learn.microsoft.com/en-us/azure/ai-studio/concepts/agents

### Open Source Projects

- **Ollama**: https://ollama.ai
- **vLLM**: https://github.com/lm-sys/vllm
- **PostgreSQL with pgvector**: https://github.com/pgvector/pgvector
- **Helm Charts**: https://helm.sh
- **Kubernetes**: https://kubernetes.io

### Deployment Tools & Frameworks

- **Helm**: https://helm.sh
- **Kustomize**: https://kustomize.io
- **Terraform**: https://www.terraform.io
- **Pulumi**: https://www.pulumi.com
- **ArgoCD**: https://argoproj.github.io/cd/

### Learning Resources

- **RHDH Quick Start**: https://developers.redhat.com/rhdh/quick-start
- **Kubernetes Best Practices**: https://kubernetes.io/docs/concepts/best-practices/
- **Azure Architecture Center**: https://learn.microsoft.com/en-us/azure/architecture/
- **OpenShift Best Practices**: https://docs.openshift.com/container-platform/latest/

### Support and Community

- **RHDH Community**: https://github.com/redhat-developer-hub
- **Backstage Community**: https://github.com/backstage/backstage
- **Kubernetes Community**: https://kubernetes.io/community/
- **Red Hat Support**: https://www.redhat.com/en/services/support

---

## Appendix: Quick Reference Commands

### RHDH Deployment

```bash
# Install RHDH using Helm
helm repo add rhdh https://charts.redhat.com/rhdh
helm install my-rhdh rhdh/rhdh \
  -f values.yaml \
  --namespace backstage \
  --create-namespace

# Verify installation
kubectl get pods -n backstage
kubectl get svc -n backstage

# Forward port for local access
kubectl port-forward -n backstage svc/rhdh 3000:80

# Scale deployment
kubectl scale deployment rhdh-backend -n backstage --replicas=3
```

### Dynamic Plugin Deployment

```bash
# Apply dynamic plugins configuration
kubectl apply -f dynamic-plugins.yaml -n backstage

# Verify plugins loaded
kubectl logs -n backstage -l app=rhdh-backend | grep plugin

# Query plugin status API
curl -H "Authorization: Bearer $TOKEN" \
  http://rhdh.company.com/api/plugins/status
```

### Lightspeed Deployment

```bash
# Deploy Lightspeed components
helm install lightspeed rhdh/lightspeed \
  -f lightspeed-values.yaml \
  -n backstage

# Check Lightspeed status
kubectl get pods -n backstage -l app=lightspeed
kubectl logs -n backstage -l app=lightspeed-backend

# Access Lightspeed chat
kubectl port-forward -n backstage svc/lightspeed-frontend 3001:3000
```

### Kubernetes Operations

```bash
# Deploy application via RHDH
kubectl apply -f deployment.yaml

# Check deployment status
kubectl rollout status deployment/myapp -n default

# View logs
kubectl logs deployment/myapp -n default --tail=100 -f

# Scale deployment
kubectl scale deployment myapp --replicas=5 -n default
```

---

**Document Version:** 1.0
**Last Updated:** February 27, 2026
**Author:** paulasilva@microsoft.com
**Status:** Production Ready
