# Three Horizons Accelerator - Enterprise Review & Best Practices

## 📋 Análise de Cada Ponto Levantado

---

## 1. 🗂️ Estrutura de Repositórios - Best Practice Recomendada

### Recomendação: **Modelo Multi-Repo com Template Repository**

```
┌─────────────────────────────────────────────────────────────────────┐
│                    REPOSITÓRIO TEMPLATE (Fork Source)               │
│                                                                     │
│  three-horizons-accelerator/                                        │
│  ├── README.md                                                      │
│  ├── GETTING_STARTED.md                                             │
│  ├── accelerator-agents/        ← Agent specifications              │
│  ├── terraform/                 ← IaC modules                       │
│  ├── helm-charts/               ← Helm charts                       │
│  └── .github/                                                       │
│      ├── workflows/             ← Bootstrap workflows               │
│      └── ISSUE_TEMPLATE/        ← Agent triggers                    │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ Fork + Bootstrap Workflow
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    CLIENTE FAZ FORK                                 │
│                                                                     │
│  cliente/three-horizons-platform/                                   │
│  ├── .github/workflows/bootstrap.yml  ← Cria repos automaticamente  │
│  └── config/                                                        │
│      └── platform-config.yaml         ← Configuração do cliente     │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              │ Bootstrap cria automaticamente:
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  REPOSITÓRIOS GERADOS (GitOps Pattern)                              │
│                                                                     │
│  cliente/platform-infrastructure/    ← Terraform state              │
│  cliente/platform-gitops/            ← ArgoCD apps & manifests      │
│  cliente/platform-templates/         ← Golden Path templates        │
│  cliente/platform-observability/     ← Dashboards, alerts           │
│                                                                     │
│  (Opcional - por ambiente)                                          │
│  cliente/apps-dev/                   ← Dev environment apps         │
│  cliente/apps-staging/               ← Staging environment apps     │
│  cliente/apps-prod/                  ← Production environment apps  │
└─────────────────────────────────────────────────────────────────────┘
```

### Justificativa:
- **Separation of Concerns**: Infraestrutura separada de aplicações
- **RBAC Granular**: Times diferentes podem ter acesso a repos diferentes
- **GitOps Native**: Cada repo é uma source of truth
- **Auditoria**: Histórico claro de mudanças por domínio
- **Escalabilidade**: Múltiplos clusters/regiões com repos dedicados

---

## 2. 📐 T-Shirt Sizing para Infraestrutura

### Recomendação: **Adicionar Sizing Profiles aos Agents**

```yaml
# sizing-profiles.yaml
sizing:
  profiles:
    # ──────────────────────────────────────────────────────────────
    # SMALL (Dev/POC) - ~$500-1,000/month
    # ──────────────────────────────────────────────────────────────
    small:
      description: "Development, POC, Small Teams (< 10 devs)"
      aks:
        node_count: 3
        node_size: "Standard_D2s_v5"
        max_pods: 30
        auto_scaling:
          enabled: false
      acr:
        sku: "Basic"
        geo_replication: false
      postgresql:
        sku: "Standard_B1ms"
        storage_gb: 32
        ha_enabled: false
      redis:
        sku: "Basic"
        family: "C"
        capacity: 0
      ai_foundry:
        gpt4o_capacity: 10  # TPM in thousands
        embedding_capacity: 30
      estimated_cost:
        monthly_usd: 800
        
    # ──────────────────────────────────────────────────────────────
    # MEDIUM (Standard) - ~$2,000-5,000/month
    # ──────────────────────────────────────────────────────────────
    medium:
      description: "Standard Production (10-50 devs)"
      aks:
        node_count: 5
        node_size: "Standard_D4s_v5"
        max_pods: 50
        auto_scaling:
          enabled: true
          min_nodes: 3
          max_nodes: 10
      acr:
        sku: "Standard"
        geo_replication: false
      postgresql:
        sku: "Standard_D2ds_v5"
        storage_gb: 128
        ha_enabled: false
      redis:
        sku: "Standard"
        family: "C"
        capacity: 1
      ai_foundry:
        gpt4o_capacity: 50
        embedding_capacity: 100
      estimated_cost:
        monthly_usd: 3500
        
    # ──────────────────────────────────────────────────────────────
    # LARGE (Enterprise) - ~$8,000-15,000/month
    # ──────────────────────────────────────────────────────────────
    large:
      description: "Enterprise Production (50-200 devs)"
      aks:
        node_count: 10
        node_size: "Standard_D8s_v5"
        max_pods: 100
        auto_scaling:
          enabled: true
          min_nodes: 5
          max_nodes: 20
        node_pools:
          - name: "system"
            size: "Standard_D4s_v5"
            count: 3
          - name: "workloads"
            size: "Standard_D8s_v5"
            count: 5
            auto_scale: true
          - name: "ai"
            size: "Standard_NC6s_v3"  # GPU
            count: 2
      acr:
        sku: "Premium"
        geo_replication: true
        replications:
          - "eastus"
      postgresql:
        sku: "Standard_D4ds_v5"
        storage_gb: 256
        ha_enabled: true
        ha_mode: "ZoneRedundant"
      redis:
        sku: "Premium"
        family: "P"
        capacity: 1
      ai_foundry:
        gpt4o_capacity: 150
        embedding_capacity: 300
      estimated_cost:
        monthly_usd: 12000
        
    # ──────────────────────────────────────────────────────────────
    # XLARGE (Enterprise Critical) - ~$25,000-50,000/month
    # ──────────────────────────────────────────────────────────────
    xlarge:
      description: "Mission Critical (200+ devs, multi-region)"
      multi_region: true
      regions:
        primary: "brazilsouth"
        secondary: "eastus"
      aks:
        primary:
          node_count: 20
          node_size: "Standard_D16s_v5"
          auto_scaling:
            enabled: true
            min_nodes: 10
            max_nodes: 50
        secondary:
          node_count: 10
          node_size: "Standard_D8s_v5"
          auto_scaling:
            enabled: true
            min_nodes: 5
            max_nodes: 25
      acr:
        sku: "Premium"
        geo_replication: true
        replications:
          - "eastus"
          - "westeurope"
      postgresql:
        sku: "Standard_D8ds_v5"
        storage_gb: 512
        ha_enabled: true
        ha_mode: "ZoneRedundant"
        read_replicas: 2
      redis:
        sku: "Premium"
        family: "P"
        capacity: 3
        geo_replication: true
      ai_foundry:
        gpt4o_capacity: 500
        embedding_capacity: 1000
        multi_region: true
      estimated_cost:
        monthly_usd: 35000
```

### Como Usar nos Agents:

```yaml
# Issue Template com T-Shirt Sizing
---
title: "[H1] Infrastructure Setup - {PROJECT_NAME}"
labels: agent:infrastructure, horizon:h1
---

## T-Shirt Size

- [ ] 🟢 Small (Dev/POC) - ~$800/month
- [x] 🟡 Medium (Standard Prod) - ~$3,500/month
- [ ] 🔴 Large (Enterprise) - ~$12,000/month
- [ ] ⚫ XLarge (Mission Critical) - ~$35,000/month

## Configuration

sizing: medium  # ← Agent usa profile predefinido

# Ou customização
overrides:
  aks:
    node_count: 7  # Override específico
```

---

## 3. 🤖 GitHub Agent HQ + Claude Code + Copilot

### Descobertas do GitHub Universe 2025:

O **GitHub Agent HQ** é a nova plataforma de orquestração de agentes que:

1. **Multi-Agent Support**: Suporta agentes de Anthropic (Claude), OpenAI (Codex), Google, Cognition, xAI
2. **Mission Control**: Interface unificada para gerenciar múltiplos agentes
3. **AGENTS.md**: Arquivo de configuração para customizar comportamento dos agentes
4. **MCP Registry**: Registro de MCP servers direto no VS Code

### Recomendação: Suportar Múltiplos Runtimes

```yaml
# accelerator-config.yaml
agent_runtime:
  supported:
    - github-copilot-agent     # GitHub Copilot Coding Agent
    - claude-code              # Claude Code com MCP
    - openai-codex             # OpenAI Codex
    
  default: github-copilot-agent
  
  # Configuração por runtime
  configurations:
    github-copilot-agent:
      instruction_file: "AGENTS.md"
      prompts_dir: ".github/prompts/"
      agents_dir: ".github/agents/"
      
    claude-code:
      instruction_file: "CLAUDE.md"
      skills_dir: ".claude/skills/"
      commands_dir: ".claude/commands/"
      
    openai-codex:
      instruction_file: "AGENTS.md"
      # Usa mesmo formato do Copilot
```

### APM (Agent Package Manager) Integration:

O **APM** é uma ferramenta que permite empacotar e distribuir prompts/agents:

```bash
# Install APM
curl -sSL https://raw.githubusercontent.com/danielmeppiel/apm/main/install.sh | sh

# Estrutura do Accelerator como APM Package
apm.yml:
  name: three-horizons-accelerator
  dependencies:
    apm:
      - microsoft/azure-best-practices     # Azure guardrails
      - github/enterprise-security         # Security rules
      - danielmeppiel/compliance-rules     # Compliance
```

---

## 4. 🔧 MCP Servers & Pre-requisitos Enterprise

### MCP Servers Completos:

```json
{
  "mcpServers": {
    "azure": {
      "command": "azure-mcp",
      "env": {
        "AZURE_SUBSCRIPTION_ID": "${AZURE_SUBSCRIPTION_ID}",
        "AZURE_TENANT_ID": "${AZURE_TENANT_ID}"
      },
      "capabilities": [
        "az account", "az group", "az aks", "az acr", "az keyvault",
        "az network", "az identity", "az cognitiveservices", "az search",
        "az monitor", "az security", "az consumption", "az advisor",
        "az postgres", "az redis", "az cosmosdb", "az ml"
      ]
    },
    "terraform": {
      "command": "terraform-mcp",
      "capabilities": ["init", "plan", "apply", "destroy", "state", "output"]
    },
    "kubernetes": {
      "command": "kubernetes-mcp",
      "env": { "KUBECONFIG": "${KUBECONFIG}" },
      "capabilities": ["kubectl", "helm"]
    },
    "argocd": {
      "command": "argocd-mcp",
      "env": {
        "ARGOCD_SERVER": "${ARGOCD_SERVER}",
        "ARGOCD_AUTH_TOKEN": "${ARGOCD_AUTH_TOKEN}"
      }
    },
    "github": {
      "command": "github-mcp",
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" },
      "capabilities": ["gh repo", "gh issue", "gh pr", "gh workflow", "gh secret"]
    },
    "azure-devops": {
      "command": "azure-devops-mcp",
      "env": {
        "ADO_PAT": "${ADO_PAT}",
        "ADO_ORG": "${ADO_ORG}"
      }
    },
    "azure-ai": {
      "command": "azure-ai-mcp",
      "env": {
        "AI_PROJECT_ENDPOINT": "${AI_PROJECT_ENDPOINT}"
      }
    }
  }
}
```

### Enterprise Pre-requisitos:

```yaml
prerequisites:
  azure:
    subscription:
      - "Owner or Contributor role"
      - "User Access Administrator for RBAC"
    providers:
      - "Microsoft.ContainerService"
      - "Microsoft.ContainerRegistry"
      - "Microsoft.KeyVault"
      - "Microsoft.Network"
      - "Microsoft.ManagedIdentity"
      - "Microsoft.CognitiveServices"
      - "Microsoft.Search"
      - "Microsoft.DBforPostgreSQL"
      - "Microsoft.Cache"
      - "Microsoft.OperationalInsights"
    quotas:
      - "vCPUs sufficient for AKS nodes"
      - "Azure OpenAI quota (if H3)"
      
  github:
    organization:
      - "GitHub Enterprise Cloud recommended"
      - "GitHub Advanced Security (GHAS)"
      - "GitHub Copilot Enterprise"
    permissions:
      - "Organization owner or admin"
      - "Repository admin for target repos"
    features:
      - "GitHub Actions enabled"
      - "GitHub Packages (optional)"
      
  tools:
    required:
      - "Azure CLI >= 2.50"
      - "kubectl >= 1.28"
      - "helm >= 3.12"
      - "terraform >= 1.5 (optional)"
      - "argocd CLI >= 2.9"
    optional:
      - "APM CLI (for agent packages)"
      - "gh CLI >= 2.40"
```

---

## 5. 🏗️ Developer Hub - Dual Platform Support (AKS + ARO)

### Opção 1: AKS (Azure Kubernetes Service)

Baseado na documentação oficial Red Hat Developer Hub 1.8:

```yaml
# rhdh-aks-deployment.yaml
rhdh_platform:
  type: "aks"
  
  # Diferenças do AKS vs OpenShift
  differences:
    - "OLM framework não built-in - precisa instalar"
    - "Red Hat Ecosystem pull-secret não gerenciado globalmente"
    - "Ingresses substituem OpenShift Routes"
    
  prerequisites:
    - "OLM (Operator Lifecycle Manager) instalado"
    - "Red Hat Ecosystem Catalog configurado"
    - "Pull secret para registry.redhat.io"
    
  installation:
    method: "helm"  # ou "operator"
    
    # Helm installation
    helm:
      repo: "https://charts.backstage.io"
      chart: "backstage"
      values: |
        backstage:
          appConfig:
            app:
              baseUrl: https://developer.${DOMAIN}
            backend:
              baseUrl: https://developer.${DOMAIN}
              
    # Ingress (required for AKS)
    ingress:
      enabled: true
      className: "webapprouting.kubernetes.azure.com"  # ou nginx
      host: "developer.${DOMAIN}"
      tls:
        enabled: true
        secretName: "rhdh-tls"
```

### Opção 2: ARO (Azure Red Hat OpenShift)

```yaml
# rhdh-aro-deployment.yaml
rhdh_platform:
  type: "aro"
  
  # Vantagens do ARO
  advantages:
    - "OLM built-in"
    - "OpenShift Routes (não precisa Ingress)"
    - "OperatorHub integrado"
    - "Red Hat support incluído"
    
  installation:
    method: "operator"  # Recomendado para ARO
    
    operator:
      source: "Red Hat Developer Hub Operator"
      channel: "fast"  # ou "fast-1.x" para z-stream only
      
    # Route automático (não precisa Ingress)
    route:
      host: "developer-hub-${NAMESPACE}.apps.${CLUSTER_DOMAIN}"
      tls:
        termination: "edge"
```

### Comparação:

| Feature | AKS | ARO |
|---------|-----|-----|
| OLM | Instalar manualmente | Built-in |
| Ingress/Route | Kubernetes Ingress | OpenShift Route |
| Pull Secrets | Configurar manualmente | Gerenciado |
| Operator | Helm ou Operator | Operator (recomendado) |
| Support | Microsoft + community | Microsoft + Red Hat |
| Custo | AKS pricing | ARO pricing (~2x) |

---

## 6. 🔐 IDP Authentication - Dual Option

### Opção 1: Microsoft Entra ID (EMU)

Para clientes com GitHub Enterprise Cloud EMU:

```yaml
# rhdh-auth-entra.yaml
authentication:
  provider: "microsoft-entra-id"
  
  # Configuração Azure AD / Entra ID
  entra_id:
    tenant_id: "${AZURE_TENANT_ID}"
    client_id: "${ENTRA_CLIENT_ID}"
    client_secret: "${ENTRA_CLIENT_SECRET}"
    
  # Integração com GitHub EMU
  github_emu:
    enterprise_slug: "${GITHUB_EMU_SLUG}"
    # Users provisioned via SCIM from Entra ID
    
  # app-config-rhdh.yaml
  app_config: |
    auth:
      environment: production
      providers:
        microsoft:
          production:
            clientId: ${ENTRA_CLIENT_ID}
            clientSecret: ${ENTRA_CLIENT_SECRET}
            tenantId: ${AZURE_TENANT_ID}
            
    signInPage: microsoft
    
    # Catalog sync from Entra ID
    catalog:
      providers:
        microsoftGraphOrg:
          default:
            tenantId: ${AZURE_TENANT_ID}
            clientId: ${ENTRA_CLIENT_ID}
            clientSecret: ${ENTRA_CLIENT_SECRET}
            userSelect: ['id', 'displayName', 'mail']
            groupSelect: ['id', 'displayName']
```

### Opção 2: GitHub OAuth (Enterprise Cloud)

Para clientes com GitHub Enterprise Cloud (não-EMU):

```yaml
# rhdh-auth-github.yaml
authentication:
  provider: "github"
  
  # GitHub App (recomendado sobre OAuth App)
  github_app:
    app_id: "${GITHUB_APP_ID}"
    client_id: "${GITHUB_APP_CLIENT_ID}"
    client_secret: "${GITHUB_APP_CLIENT_SECRET}"
    private_key: "${GITHUB_APP_PRIVATE_KEY}"
    webhook_secret: "${GITHUB_WEBHOOK_SECRET}"
    
  # Para GitHub Enterprise Server
  enterprise:
    enabled: false
    instance_url: "https://ghe.company.com"
    
  # app-config-rhdh.yaml
  app_config: |
    auth:
      environment: production
      providers:
        github:
          production:
            clientId: ${GITHUB_APP_CLIENT_ID}
            clientSecret: ${GITHUB_APP_CLIENT_SECRET}
            # Para GHE:
            # enterpriseInstanceUrl: ${GITHUB_ENTERPRISE_URL}
            
    signInPage: github
    
    # Catalog sync from GitHub orgs
    catalog:
      providers:
        github:
          providerId:
            organization: ${GITHUB_ORG}
            catalogPath: /catalog-info.yaml
            filters:
              branch: main
              repository: '.*'
```

### Seleção no Issue Template:

```yaml
# .github/ISSUE_TEMPLATE/rhdh-deployment.yml
---
name: Deploy Red Hat Developer Hub
labels: agent:rhdh, horizon:h2
---

## Platform Selection

- [ ] AKS (Azure Kubernetes Service)
- [ ] ARO (Azure Red Hat OpenShift)

## Authentication Provider

- [ ] Microsoft Entra ID (Recomendado para EMU)
  - Tenant ID: ___
  - GitHub EMU Enterprise: ___
  
- [ ] GitHub OAuth (GitHub Enterprise Cloud)
  - GitHub Organization: ___
  - Enterprise Server URL (se aplicável): ___
```

---

## 7. 🎛️ Agent Management com GitHub Agent HQ + APM

### Integração com GitHub Agent HQ:

```yaml
# .github/agents/accelerator-orchestrator.agent.yaml
name: accelerator-orchestrator
description: |
  Orchestrates Three Horizons Accelerator deployment.
  Manages infrastructure, GitOps, and AI platform agents.
  
instructions: |
  You are the Three Horizons Accelerator orchestrator.
  
  When a user creates an issue with agent:* labels:
  1. Identify the agent from the label
  2. Load the agent specification from accelerator-agents/
  3. Execute the workflow defined in the spec
  4. Update the issue with progress
  5. Create dependent issues for multi-stage workflows
  
tools:
  - azure-cli
  - kubectl
  - helm
  - argocd
  - github-api
  
trigger:
  - label: "agent:*"
  - label: "workflow:*"
```

### APM Package Structure:

```yaml
# apm.yml
name: three-horizons-accelerator
version: 1.0.0
description: |
  Enterprise Platform Engineering accelerator with
  AI-native deployment agents.

# Dependencies from APM ecosystem
dependencies:
  apm:
    - danielmeppiel/compliance-rules     # Compliance guardrails
    - microsoft/azure-best-practices     # Azure patterns
    - github/enterprise-security         # Security rules

# Primitives
primitives:
  instructions:
    - .apm/instructions/azure-infrastructure.instructions.md
    - .apm/instructions/kubernetes-security.instructions.md
    - .apm/instructions/ai-foundry-deployment.instructions.md
    
  prompts:
    - .apm/prompts/deploy-infrastructure.prompt.md
    - .apm/prompts/setup-gitops.prompt.md
    - .apm/prompts/configure-ai-foundry.prompt.md
    
  agents:
    - .apm/agents/infrastructure-agent.agent.md
    - .apm/agents/gitops-agent.agent.md
    - .apm/agents/ai-foundry-agent.agent.md
```

### Workflow com APM:

```bash
# Instalação
curl -sSL https://raw.githubusercontent.com/danielmeppiel/apm/main/install.sh | sh

# No repositório do cliente
cd my-platform
apm init

# Instalar accelerator
apm install microsoft-latam/three-horizons-accelerator

# Compilar para GitHub Copilot + Claude
apm compile --target all

# Resultado:
# ├── AGENTS.md           → Copilot/Codex instructions
# ├── CLAUDE.md           → Claude Code instructions
# ├── .github/
# │   ├── prompts/        → GitHub Copilot prompts
# │   └── agents/         → GitHub agents
# └── .claude/
#     ├── skills/         → Claude skills
#     └── commands/       → Claude commands
```

---

## 📋 Resumo das Decisões de Arquitetura

| Aspecto | Decisão | Justificativa |
|---------|---------|---------------|
| **Estrutura Repos** | Multi-repo com bootstrap | GitOps, RBAC granular, auditoria |
| **T-Shirt Sizing** | 4 profiles (S/M/L/XL) | Custos previsíveis, scaling claro |
| **Agent Runtime** | GitHub Agent HQ + Claude Code | Suporte multi-vendor, flexibilidade |
| **Package Manager** | APM integration | Prompts/agents reutilizáveis |
| **Developer Hub** | AKS + ARO dual option | Atender diferentes arquiteturas |
| **Authentication** | Entra ID + GitHub OAuth | EMU e não-EMU enterprise |
| **MCP Servers** | 12 servers configurados | Cobertura completa de tools |
| **Security** | Defender for Cloud + Purview | Segurança e governança enterprise |
| **Regiões** | Brazil South + East US 2 | LATAM + Full AI support |

---

## 🛡️ Security & Governance Components

### Microsoft Defender for Cloud

**Included Plans by T-Shirt Size:**

| Plan | Small | Medium | Large | XLarge |
|------|-------|--------|-------|--------|
| CSPM (Free) | ✅ | - | - | - |
| CSPM (Standard) | - | ✅ | ✅ | ✅ |
| Defender for Containers | ✅ | ✅ | ✅ | ✅ |
| Defender for Servers | - | P1 | P2 | P2 |
| Defender for Databases | - | ✅ | ✅ | ✅ |
| Defender for Key Vault | ✅ | ✅ | ✅ | ✅ |
| Defender for Storage | - | ✅ | ✅ | ✅ |
| Defender for AI | - | - | ⚠️ | ✅ |
| Regulatory Compliance | - | - | ✅ | ✅ |
| JIT VM Access | - | - | - | ✅ |

**Estimated Monthly Cost:**
- Small: ~$100
- Medium: ~$500
- Large: ~$2,000
- XLarge: ~$5,000

### Microsoft Purview Data Governance

**Included Features by T-Shirt Size:**

| Feature | Small | Medium | Large | XLarge |
|---------|-------|--------|-------|--------|
| Data Catalog | Free | ✅ | ✅ | ✅ |
| Capacity Units | 0 | 1 | 4 | 16 |
| Automated Scans | Weekly | Daily | Daily | Continuous |
| Business Glossary | - | ✅ | ✅ | ✅ |
| Data Quality | - | - | ✅ | ✅ |
| Data Lineage | - | ✅ | ✅ | ✅ |
| LATAM Classifications | - | ✅ | ✅ | ✅ |
| Private Endpoints | - | Optional | ✅ | ✅ |

**LATAM-Specific Classifications:**
- 🇧🇷 CPF (Brazil Individual Taxpayer)
- 🇧🇷 CNPJ (Brazil Company Registry)
- 🇨🇱 RUT (Chile Tax ID)
- 🇲🇽 RFC (Mexico Tax ID)
- 🇨🇴 NIT (Colombia Tax ID)

---

## 🌎 Azure Region Availability for LATAM

### Recommended Regions

| Region | AKS | AI Foundry | Defender | Purview | Best For |
|--------|-----|------------|----------|---------|----------|
| **Brazil South** | ✅ | ⚠️ Limited | ✅ | ✅ | LGPD, Brazil data residency |
| **East US 2** | ✅ | ✅ Full | ✅ | ✅ | Full AI, DR for Brazil |
| **South Central US** | ✅ | ✅ | ✅ | ✅ | Mexico, Central America |
| **West US 2** | ✅ | ⚠️ | ✅ | ✅ | US West Coast clients |

### AI Model Availability

| Model | Brazil South | East US 2 | South Central US |
|-------|--------------|-----------|------------------|
| GPT-4o | ❌ | ✅ | ✅ |
| GPT-4o-mini | ❌ | ✅ | ✅ |
| GPT-4 | ⚠️ Limited | ✅ | ✅ |
| o3-mini | ❌ | ✅ | ⚠️ |
| text-embedding-3-large | ⚠️ | ✅ | ✅ |

### Deployment Patterns

**Pattern 1: Brazil-Centric (LGPD Compliant)**
```
Primary: Brazil South (data residency)
AI Workloads: East US 2 (via Private Link)
DR: South Central US
```

**Pattern 2: Multi-LATAM**
```
Primary: East US 2 (full capabilities)
Regional: Brazil South (Brazil clients)
Regional: South Central US (Mexico/Central America)
Routing: Azure Front Door
```

**Pattern 3: US-Based with LATAM Access**
```
Primary: East US 2
DR: South Central US
CDN: Azure Front Door for latency
```

---

## 📊 Complete Agent Inventory (v2.1.0)

### H1 - Foundation (7 Agents)

| Agent | Purpose | Issue Template |
|-------|---------|----------------|
| infrastructure-agent | AKS, resource groups | ✅ infrastructure.yml |
| networking-agent | VNet, subnets, DNS | ✅ networking.yml |
| security-agent | Key Vault, identities | ✅ security.yml |
| container-registry-agent | ACR, scanning | ✅ container-registry.yml |
| database-agent | PostgreSQL, Redis | ✅ database.yml |
| **defender-cloud-agent** | Defender for Cloud | ✅ defender-cloud.yml |
| **purview-governance-agent** | Data governance | ✅ purview-governance.yml |

### H2 - Enhancement (5 Agents)

| Agent | Purpose | Issue Template |
|-------|---------|----------------|
| gitops-agent | ArgoCD | ✅ gitops.yml |
| golden-paths-agent | Software templates | ✅ golden-paths.yml |
| observability-agent | Monitoring | ✅ observability.yml |
| rhdh-portal-agent | Developer Hub | ✅ rhdh-portal.yml |
| github-runners-agent | Actions runners | ✅ github-runners.yml |

### H3 - Innovation (4 Agents)

| Agent | Purpose | Issue Template |
|-------|---------|----------------|
| ai-foundry-agent | Azure AI | ✅ ai-foundry.yml |
| sre-agent-setup | SRE automation | ✅ sre-agent.yml |
| mlops-pipeline-agent | ML pipelines | ✅ mlops-pipeline.yml |
| multi-agent-setup | Agent orchestration | ✅ multi-agent.yml |

### Cross-Cutting (4 Agents)

| Agent | Purpose | Issue Template |
|-------|---------|----------------|
| migration-agent | Platform migration | ✅ migration.yml |
| validation-agent | Deployment validation | ✅ validation.yml |
| rollback-agent | State recovery | ✅ rollback.yml |
| cost-optimization-agent | Cost analysis | ✅ cost-optimization.yml |

**Total: 20 Agents with 21 Issue Templates** (includes full-deployment.yml)

---

## 🔧 MCP Servers Configuration (v2.1.0)

| Server | Purpose | Used By |
|--------|---------|---------|
| azure | Azure CLI | 9 agents |
| terraform | IaC | 4 agents |
| kubernetes | K8s operations | 7 agents |
| helm | Helm charts | 3 agents |
| argocd | GitOps | 4 agents |
| github | Repository ops | All agents |
| azure-devops | Migration source | 1 agent |
| git | Version control | 2 agents |
| azure-ai | AI SDK | 2 agents |
| prometheus | Metrics | 3 agents |
| **defender** | Security posture | 3 agents |
| **purview** | Data governance | 2 agents |
| filesystem | File operations | All agents |

---

## ✅ Enterprise Checklist

### Pre-Deployment
- [ ] Azure subscription with required quotas
- [ ] GitHub Enterprise or Organization
- [ ] Region selected based on requirements
- [ ] T-shirt size selected
- [ ] Authentication method chosen (Entra ID or GitHub)

### Security & Governance
- [ ] Defender for Cloud plans enabled
- [ ] Purview account configured
- [ ] Sensitivity labels defined
- [ ] Data classifications deployed
- [ ] Regulatory compliance frameworks selected

### Platform
- [ ] Bootstrap workflow executed
- [ ] Infrastructure agents completed
- [ ] Network connectivity validated
- [ ] GitOps pipeline operational
- [ ] Developer portal accessible

### Operational Readiness
- [ ] Monitoring dashboards configured
- [ ] Alerting rules active
- [ ] Runbooks documented
- [ ] DR tested
- [ ] Cost baseline established

---

## 🚀 Próximos Passos

1. ~~Criar Defender Cloud Agent~~ ✅
2. ~~Criar Purview Governance Agent~~ ✅
3. ~~Adicionar Region Availability Matrix~~ ✅
4. ~~Completar Issue Templates (17 faltando)~~ ✅
5. **Testar com GitHub Agent HQ** (preview)
6. **Validar em cliente piloto LATAM**

---

**Documento de Revisão Version:** 2.1.0
**Data:** Dezembro 2024
**Agents:** 20 (7 H1 + 5 H2 + 4 H3 + 4 Cross-cutting)
**Issue Templates:** 21
