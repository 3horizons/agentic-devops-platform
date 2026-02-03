---
name: "GitHub Runners Agent"
version: "1.0.0"
horizon: "H2"
status: "stable"
last_updated: "2025-12-15"
mcp_servers:
  - azure
  - kubernetes
  - github
dependencies:
  - github-runners
  - aks-cluster
---

# GitHub Runners Agent

## 🤖 Agent Identity

```yaml
name: github-runners-agent
version: 1.0.0
horizon: H2 - Enhancement
description: |
  Deploys and manages GitHub Actions self-hosted runners on AKS.
  Uses Actions Runner Controller (ARC) for auto-scaling
  runners with enterprise features.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 📁 Terraform Module
**Primary Module:** `terraform/modules/github-runners/main.tf`

## 📋 Related Resources
| Resource Type | Path |
|--------------|------|
| Terraform Module | `terraform/modules/github-runners/main.tf` |
| Issue Template | `.github/ISSUE_TEMPLATE/github-runners.yml` |
| Sizing Config | `config/sizing-profiles.yaml` |
| Workflow Router | `.github/workflows/agent-router.yml` |

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Install ARC** | Actions Runner Controller | Medium |
| **Create Runner Scale Set** | Auto-scaling runners | Medium |
| **Configure Runner Groups** | Org/repo runner groups | Low |
| **Setup Docker-in-Docker** | DinD for builds | Medium |
| **Configure Cache** | Actions cache on Azure | Low |
| **Setup Larger Runners** | Custom runner specs | Low |
| **Enable Metrics** | Prometheus metrics | Low |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "kubernetes": {
      "required": true,
      "capabilities": ["kubectl", "helm"]
    },
    "helm": {
      "required": true
    },
    "github": {
      "required": true,
      "capabilities": ["gh api"]
    }
  }
}
```

---

## 🏷️ Trigger Labels

```yaml
primary_label: "agent:github-runners"
required_labels:
  - horizon:h2
```

---

## 📋 Issue Template

```markdown
---
title: "[H2] Setup GitHub Runners - {PROJECT_NAME}"
labels: agent:github-runners, horizon:h2, env:dev
---

## Prerequisites
- [ ] AKS cluster running
- [ ] GitHub App or PAT configured
- [ ] ACR available for runner images

## Configuration

```yaml
github_runners:
  namespace: "github-runners"
  
  # Authentication (GitHub App recommended)
  auth:
    type: "github-app"  # or "pat"
    app_id: ""
    installation_id: ""
    private_key_secret: "github-app-private-key"
    
  # Controller
  controller:
    replicas: 1
    image: "ghcr.io/actions/actions-runner-controller:latest"
    
  # Runner Scale Sets
  scale_sets:
    - name: "default-runners"
      github_config_url: "https://github.com/${ORG}"
      min_runners: 1
      max_runners: 10
      runner_group: "default"
      
      # Runner spec
      spec:
        image: "${ACR_NAME}.azurecr.io/actions-runner:latest"
        resources:
          requests:
            cpu: "500m"
            memory: "1Gi"
          limits:
            cpu: "2"
            memory: "4Gi"
            
      # Docker-in-Docker
      dind:
        enabled: true
        
    - name: "large-runners"
      github_config_url: "https://github.com/${ORG}"
      min_runners: 0
      max_runners: 5
      runner_group: "large"
      labels:
        - "large"
        - "8-core"
        
      spec:
        image: "${ACR_NAME}.azurecr.io/actions-runner:latest"
        resources:
          requests:
            cpu: "4"
            memory: "8Gi"
          limits:
            cpu: "8"
            memory: "16Gi"
            
  # Cache configuration
  cache:
    enabled: true
    storage_account: "${PROJECT}cache"
    container: "actions-cache"
```

## Acceptance Criteria
- [ ] ARC controller running
- [ ] Default runner scale set active
- [ ] Large runner scale set active
- [ ] Runners visible in GitHub UI
- [ ] Test workflow succeeded
- [ ] Auto-scaling working
```

---

## 🛠️ Tools & Commands

### Install Actions Runner Controller

```bash
# Create namespace
kubectl create namespace github-runners

# Create GitHub App secret
kubectl create secret generic github-app-secret \
  --namespace github-runners \
  --from-literal=github_app_id=${APP_ID} \
  --from-literal=github_app_installation_id=${INSTALLATION_ID} \
  --from-file=github_app_private_key=private-key.pem

# Add Helm repo
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update

# Install controller
helm install arc \
  --namespace github-runners \
  actions-runner-controller/gha-runner-scale-set-controller \
  --set githubConfigSecret=github-app-secret
```

### Create Runner Scale Set

```bash
# Install default runners
helm install default-runners \
  --namespace github-runners \
  actions-runner-controller/gha-runner-scale-set \
  --set githubConfigUrl="https://github.com/${ORG}" \
  --set githubConfigSecret=github-app-secret \
  --set minRunners=1 \
  --set maxRunners=10 \
  --set containerMode.type="dind"

# Install large runners
helm install large-runners \
  --namespace github-runners \
  actions-runner-controller/gha-runner-scale-set \
  --set githubConfigUrl="https://github.com/${ORG}" \
  --set githubConfigSecret=github-app-secret \
  --set minRunners=0 \
  --set maxRunners=5 \
  --set runnerGroup="large" \
  --set template.spec.containers[0].resources.requests.cpu="4" \
  --set template.spec.containers[0].resources.requests.memory="8Gi" \
  --set template.spec.containers[0].resources.limits.cpu="8" \
  --set template.spec.containers[0].resources.limits.memory="16Gi"
```

### Custom Runner Image

```dockerfile
# Dockerfile for custom runner
FROM ghcr.io/actions/actions-runner:latest

# Install additional tools
RUN apt-get update && apt-get install -y \
    azure-cli \
    kubectl \
    helm \
    terraform \
    && rm -rf /var/lib/apt/lists/*

# Install .NET SDK
RUN curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --channel 8.0

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs
```

```bash
# Build and push custom image
az acr build \
  --registry ${ACR_NAME} \
  --image actions-runner:latest \
  --file Dockerfile .
```

### Configure Actions Cache

```bash
# Create storage account for cache
az storage account create \
  --name ${PROJECT}cache \
  --resource-group ${RG_NAME} \
  --location ${LOCATION} \
  --sku Standard_LRS

# Create container
az storage container create \
  --name actions-cache \
  --account-name ${PROJECT}cache

# Get connection string
CACHE_CONN=$(az storage account show-connection-string \
  --name ${PROJECT}cache \
  --resource-group ${RG_NAME} \
  --query connectionString -o tsv)

# Create secret for cache
kubectl create secret generic actions-cache-secret \
  --namespace github-runners \
  --from-literal=ACTIONS_CACHE_URL="https://${PROJECT}cache.blob.core.windows.net/actions-cache" \
  --from-literal=ACTIONS_RUNTIME_TOKEN="${CACHE_CONN}"
```

### Test Workflow

```yaml
# .github/workflows/test-runner.yml
name: Test Self-Hosted Runner

on:
  workflow_dispatch:

jobs:
  test-default:
    runs-on: [self-hosted, default-runners]
    steps:
      - name: Test runner
        run: |
          echo "Running on self-hosted runner"
          echo "Runner: ${{ runner.name }}"
          echo "OS: ${{ runner.os }}"
          
  test-large:
    runs-on: [self-hosted, large]
    steps:
      - name: Test large runner
        run: |
          echo "Running on large runner"
          nproc
          free -h
```

---

## ✅ Validation Criteria

```yaml
validation:
  controller:
    - pods_running: ">= 1"
    - status: "Running"
    
  scale_sets:
    - default_runners:
        min_runners: 1
        registered: true
    - large_runners:
        registered: true
        
  github:
    - runners_visible: true
    - runner_group_exists: "large"
    
  test:
    - workflow_success: true
    - auto_scale_triggered: true
```

---

## 💬 Agent Communication

### On Success
```markdown
✅ **GitHub Runners Configured**

**Controller:** ✅ Running

**Runner Scale Sets:**
| Name | Min | Max | Status |
|------|-----|-----|--------|
| default-runners | 1 | 10 | ✅ Active |
| large-runners | 0 | 5 | ✅ Active |

**Runners in GitHub:**
- Organization: ${org}
- Visible: ✅ Yes
- Groups: default, large

**Features:**
- Docker-in-Docker: ✅ Enabled
- Custom Image: ✅ ${acr_name}.azurecr.io/actions-runner:latest
- Actions Cache: ✅ Configured

**Test Workflow:** ✅ Passed

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `infrastructure-agent` | **Prerequisite** |
| `container-registry-agent` | **Prerequisite** |
| `gitops-agent` | **Parallel** |

---

**Spec Version:** 1.0.0
