# Acelerador de Implementação Three Horizons

🌐 **Idioma / Language:** [English](README.md) | [Português](#) | [Español](README.es.md)

---

## 🎯 Visão Geral

O **Acelerador de Implementação Three Horizons** é um kit completo de Infrastructure as Code (IaC), GitOps e templates para desenvolvedores, projetado para implementar a plataforma Three Horizons em clientes LATAM.

### O que está incluído

| Componente | Quantidade | Descrição |
|------------|------------|-----------|
| **Módulos Terraform** | 14 | Infraestrutura Azure completa |
| **Agentes AI** | 23 | Orquestração inteligente de deploys |
| **Templates Golden Path** | 21 | Templates self-service para RHDH |
| **Issue Templates** | 25 | Templates para GitHub Issues |
| **Scripts de Automação** | 10 | Bootstrap e operações |
| **MCP Servers** | 15 | Configurações de servidores MCP |
| **Observabilidade** | 4 | Dashboards e alertas |

**Total: 100+ arquivos | ~18.000 linhas de código pronto para produção**

---

## 🏗️ Arquitetura Three Horizons

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        H3: INOVAÇÃO                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ AI Foundry  │  │ SRE Agent   │  │ Multi-Agent │  │   MLOps     │    │
│  │   Agentes   │  │ Integração  │  │  Sistemas   │  │  Pipeline   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────────────┤
│                        H2: APRIMORAMENTO                                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   ArgoCD    │  │    RHDH     │  │Observabilidade│ │   GitOps   │    │
│  │   GitOps    │  │   Portal    │  │    Stack    │  │  Workflows  │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────────────┤
│                        H1: FUNDAÇÃO                                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │     AKS     │  │    Rede     │  │  Segurança  │  │     ACR     │    │
│  │   Cluster   │  │  VNet/NSG   │  │  KeyVault   │  │  Registry   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Início Rápido (5 minutos)

### Pré-requisitos

```bash
# Ferramentas necessárias
az version        # >= 2.50.0
terraform version # >= 1.5.0
kubectl version   # >= 1.28
helm version      # >= 3.12
gh --version      # >= 2.30

# Autenticação
az login
gh auth login
```

### Deploy Rápido

```bash
# 1. Clonar o acelerador
git clone https://github.com/YOUR_ORG/three-horizons-accelerator-v4.git
cd three-horizons-accelerator-v4

# 2. Tornar scripts executáveis
chmod +x scripts/*.sh

# 3. Validar pré-requisitos e configurar variáveis
./scripts/validate-cli-prerequisites.sh
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edite terraform.tfvars com seus valores

# 4. Deploy completo (Dev)
./scripts/platform-bootstrap.sh --environment dev

# Ou deploy por horizonte
./scripts/platform-bootstrap.sh --horizon h1 --environment dev
./scripts/platform-bootstrap.sh --horizon h2 --environment staging
./scripts/platform-bootstrap.sh --horizon h3 --environment prod
```

---

## 📁 Estrutura de Diretórios

```
three-horizons-accelerator-v4/
│
├── agents/                         # 23 especificações de agentes AI
│   ├── h1-foundation/              # 8 agentes (infra, rede, segurança, ACR, DB, defender, purview, ARO)
│   ├── h2-enhancement/             # 5 agentes (gitops, golden-paths, observability, rhdh, runners)
│   ├── h3-innovation/              # 4 agentes (ai-foundry, sre, mlops, multi-agent)
│   └── cross-cutting/              # 6 agentes (migration, validation, rollback, cost, github-app, identity)
│
├── terraform/                      # 14 módulos Infrastructure as Code
│   ├── main.tf                     # Módulo raiz
│   └── modules/
│       ├── aks-cluster/            # Azure Kubernetes Service
│       ├── argocd/                 # ArgoCD GitOps
│       ├── networking/             # VNet, Subnets, NSGs
│       ├── observability/          # Prometheus, Grafana, Loki
│       ├── databases/              # PostgreSQL, Redis, Cosmos
│       ├── security/               # Key Vault, Identidades
│       ├── ai-foundry/             # Azure AI Foundry
│       ├── container-registry/     # ACR
│       ├── github-runners/         # Runners auto-hospedados
│       ├── rhdh/                   # Red Hat Developer Hub
│       ├── defender/               # Defender for Cloud
│       ├── purview/                # Microsoft Purview
│       └── naming/                 # Convenções de nomenclatura
│
├── golden-paths/                   # 21 templates RHDH (Backstage)
│   ├── h1-foundation/              # 6 templates básicos
│   ├── h2-enhancement/             # 8 templates avançados
│   └── h3-innovation/              # 7 templates AI/Agentes
│
├── .github/ISSUE_TEMPLATE/         # 25 templates de issues
├── argocd/                         # Configurações GitOps
├── config/                         # Sizing profiles e regiões
├── mcp-servers/                    # 15 configurações MCP
├── scripts/                        # 10 scripts de automação
├── grafana/dashboards/             # Dashboards
├── prometheus/                     # Alertas
└── docs/                           # Documentação
```

---

## 🔧 Guia de Uso Detalhado

### Passo 1: Deploy da Infraestrutura Base (H1)

```bash
cd terraform

# Inicializar Terraform
terraform init

# Criar plano
terraform plan -var-file=environments/dev.tfvars -out=tfplan

# Aplicar (H1 Fundação)
terraform apply tfplan
```

**Recursos criados no H1:**
- Cluster AKS (3 nós)
- VNet com 3 subnets
- Azure Container Registry
- Key Vault
- Managed Identities
- NSGs e Private Endpoints

### Passo 2: Deploy do ArgoCD e RHDH (H2)

```bash
# Após H1 completo, aplicar H2
terraform apply -var-file=environments/dev.tfvars -var="enable_h2=true"

# Ou via script
./scripts/platform-bootstrap.sh --horizon h2 --environment dev
```

**Recursos criados no H2:**
- ArgoCD com ApplicationSets
- Red Hat Developer Hub
- Prometheus + Grafana + Loki
- GitHub Actions Runners

### Passo 3: Deploy do AI Foundry (H3)

```bash
# Requer H1 e H2
terraform apply -var-file=environments/dev.tfvars -var="enable_h3=true"
```

**Recursos criados no H3:**
- Azure AI Foundry
- Azure OpenAI (GPT-4o, o1)
- AI Search (Vetorial)
- Cosmos DB (Vector Store)

---

## 📋 Golden Paths - Como Usar

### Registrar Templates no RHDH

```bash
# Registrar todos os templates
./scripts/bootstrap.sh --register-templates

# Ou registrar individualmente
kubectl apply -f golden-paths/h1-foundation/basic-cicd/template.yaml
```

### Criar Aplicação via RHDH

1. Acesse o portal: `https://rhdh.seu-dominio.com`
2. Navegue até **Criar** → **Escolher Template**
3. Selecione o template (ex: "H2: Criar Microsserviço")
4. Preencha os parâmetros:
   - Nome do componente
   - Descrição
   - Proprietário (time)
   - Linguagem/Framework
   - Tipo de deploy
5. Clique em **Criar**
6. Monitore no ArgoCD

### Templates Disponíveis por Horizonte

#### H1 Fundação (Início)
| Template | Caso de Uso |
|----------|-------------|
| `basic-cicd` | Pipeline CI/CD simples |
| `security-baseline` | Configuração de segurança |
| `documentation-site` | Sites de documentação |
| `web-application` | Aplicações web full-stack |
| `new-microservice` | Microsserviço básico |
| `infrastructure-provisioning` | Módulos Terraform |

#### H2 Aprimoramento (Produção)
| Template | Caso de Uso |
|----------|-------------|
| `gitops-deployment` | Aplicações ArgoCD |
| `microservice` | Microsserviço completo |
| `api-gateway` | API Management |
| `event-driven-microservice` | Event Hubs/Service Bus |
| `data-pipeline` | ETL com Databricks |
| `batch-job` | Jobs agendados |
| `reusable-workflows` | Workflows GitHub |

#### H3 Inovação (AI/Agentes)
| Template | Caso de Uso |
|----------|-------------|
| `foundry-agent` | Agentes AI Foundry |
| `sre-agent-integration` | Automação SRE |
| `mlops-pipeline` | Pipeline ML completo |
| `multi-agent-system` | Orquestração multi-agente |
| `copilot-extension` | Extensões GitHub Copilot |
| `rag-application` | Aplicações RAG |
| `ai-evaluation-pipeline` | Avaliação de modelos |

---

## ⚙️ Configuração do ArgoCD

### ApplicationSets

O acelerador usa ApplicationSets para geração dinâmica de aplicações:

```yaml
# Monorepo - apps/* vira uma Application
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: monorepo-apps
spec:
  generators:
    - git:
        repoURL: https://github.com/org/platform-gitops.git
        directories:
          - path: apps/*
```

### Projetos por Ambiente

- **Dev** - auto-sync habilitado
- **Staging** - auto-sync com aprovação
- **Prod** - sync manual, janelas de manutenção

### RBAC e Papéis

| Papel | Permissões |
|-------|------------|
| `admin` | Acesso total |
| `platform-engineer` | Acesso total + exec |
| `sre` | Sync + actions, sem delete |
| `developer` | Total dev, sync staging, view prod |
| `qa` | Total staging, view outros |
| `release-manager` | Pode fazer sync prod |
| `ci-bot` | Deploy dev/staging/previews |

### Notificações

Configurado para enviar para:
- **Microsoft Teams** - Cards formatados
- **Slack** - Attachments coloridos
- **Email** - Templates HTML
- **PagerDuty** - Incidentes críticos

---

## 📊 Observabilidade

### Dashboards Grafana

1. **Platform Overview** - Saúde da infraestrutura
2. **Golden Path Application** - Métricas RED/USE
3. **AI Agent Metrics** - Observabilidade de agentes

### Alertas Prometheus

| Categoria | Alertas | Exemplos |
|-----------|---------|----------|
| Infraestrutura | 8 | CPU, Memória, Disco, Nó |
| Aplicações | 10 | Taxa de erro, Latência, Disponibilidade |
| AI & Agentes | 8 | Uso de tokens, Latência, Erros |
| GitOps | 5 | Falhas de sync, Saúde da app |
| Segurança | 4 | Expiração de certificados, Secrets |

---

## 🔐 Segurança

### Gerenciamento de Secrets

O acelerador usa **External Secrets Operator** com **Azure Key Vault**:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
spec:
  secretStoreRef:
    name: azure-keyvault
  target:
    name: app-secrets
  data:
    - secretKey: database-password
      remoteRef:
        key: prod-database-password
```

### Workload Identity

Todas as aplicações usam **Azure Workload Identity** (sem secrets estáticos):

```yaml
serviceAccountName: my-app
metadata:
  annotations:
    azure.workload.identity/client-id: "<managed-identity-client-id>"
```

---

## 🔄 Migração ADO → GitHub

### Script de Migração

```bash
# Migrar repositórios do Azure DevOps para GitHub
./scripts/migration/ado-to-github-migration.sh \
  --ado-org "contoso" \
  --ado-project "MeuProjeto" \
  --github-org "contoso-github" \
  --repos "repo1,repo2,repo3"
```

### O que é Migrado:
- ✅ Código fonte e histórico Git
- ✅ Branches e tags
- ✅ Pull requests (como issues)
- ✅ Wiki (como repositório separado)
- ⚠️ Pipelines (requerem conversão manual)
- ⚠️ Work items (via integração Azure Boards)

---

## 💰 Custos Estimados (USD/mês)

| Recurso | Dev | Staging | Produção |
|---------|-----|---------|----------|
| AKS (3-5 nós) | $300 | $600 | $1.500 |
| PostgreSQL | $50 | $100 | $300 |
| Redis | $30 | $60 | $150 |
| ACR | $20 | $40 | $100 |
| AI Foundry | $100 | $300 | $1.000+ |
| Monitoramento | $50 | $100 | $250 |
| **Total** | **~$550** | **~$1.200** | **~$3.300+** |

*Nota: Custos do AI Foundry variam com uso de tokens*

---

## ⏱️ Tempos de Deploy

| Fase | Dev | Staging | Produção |
|------|-----|---------|----------|
| H1 Fundação | 25-35 min | 35-45 min | 45-60 min |
| H2 Aprimoramento | 30-40 min | 40-50 min | 50-70 min |
| H3 Inovação | 20-30 min | 25-35 min | 35-45 min |
| **Total** | **75-105 min** | **100-130 min** | **130-175 min** |

---

## 🆘 Solução de Problemas

### Erros de Terraform

```bash
# Limpar estado corrompido
terraform state list
terraform state rm <recurso>

# Atualizar estado
terraform refresh

# Importar recurso existente
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/...
```

### Problemas com ArgoCD

```bash
# Ver status de sync
argocd app list
argocd app get <nome-app>

# Forçar sync
argocd app sync <nome-app> --force

# Ver logs
argocd app logs <nome-app>

# Hard refresh
argocd app get <nome-app> --hard-refresh
```

### Problemas com AKS

```bash
# Verificar nós
kubectl get nodes
kubectl describe node <nome-no>

# Ver pods problemáticos
kubectl get pods --all-namespaces | grep -v Running

# Logs do pod
kubectl logs <nome-pod> -n <namespace> --previous
```

---

## 📞 Suporte

| Canal | Contato |
|-------|---------|
| Time de Plataforma | #platform-engineering (Slack/Teams) |
| Time de AI/ML | #ai-agents (Slack/Teams) |
| Time de Segurança | #security (Slack/Teams) |
| Emergência | platform-oncall@microsoft.com |

---

## 📚 Referências

### Documentação Oficial
- [Azure AKS](https://docs.microsoft.com/azure/aks/)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Red Hat Developer Hub](https://developers.redhat.com/rhdh)
- [Azure AI Foundry](https://azure.microsoft.com/products/ai-foundry/)
- [GitHub Actions](https://docs.github.com/actions)
- [External Secrets Operator](https://external-secrets.io/)

---

## 📝 Histórico de Versões

### v4.0.0 (Dezembro 2025) - Unified Agentic DevOps
- ✅ 14 módulos Terraform (incluindo Defender, Purview, Naming)
- ✅ 23 agentes AI para orquestração inteligente
- ✅ 25 templates de GitHub Issues
- ✅ 21 templates Golden Path
- ✅ 10 scripts de automação
- ✅ 15 configurações MCP Server
- ✅ Stack de observabilidade completo
- ✅ Documentação multi-idioma

### v3.0.0 (Dezembro 2024)
- 11 módulos Terraform
- 21 templates Golden Path
- 6 scripts de automação

---

**Versão:** 4.0.0 Unified
**Última Atualização:** Dezembro 2025
**Mantido por:** Microsoft LATAM Platform Engineering
**Licença:** MIT
