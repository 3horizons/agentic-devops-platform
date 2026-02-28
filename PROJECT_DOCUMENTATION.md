# Three Horizons Implementation Accelerator — Documentação Completa do Projeto

> **Agentic DevOps Platform with Red Hat Developer Hub**
> Versão: 4.0.0 | Licença: MIT | Última atualização: 2025-12-15

---

## Índice

1. [Visão Geral do Projeto](#1-visão-geral-do-projeto)
2. [Arquitetura Three Horizons](#2-arquitetura-three-horizons)
3. [Stack Tecnológica Completa](#3-stack-tecnológica-completa)
4. [Requisitos Funcionais](#4-requisitos-funcionais)
5. [Requisitos Não-Funcionais](#5-requisitos-não-funcionais)
6. [User Stories](#6-user-stories)
7. [Estrutura do Repositório](#7-estrutura-do-repositório)
8. [Módulos Terraform (Infrastructure as Code)](#8-módulos-terraform-infrastructure-as-code)
9. [Golden Paths (Templates RHDH)](#9-golden-paths-templates-rhdh)
10. [Sistema de Agentes AI](#10-sistema-de-agentes-ai)
11. [MCP Servers (Model Context Protocol)](#11-mcp-servers-model-context-protocol)
12. [GitOps com ArgoCD](#12-gitops-com-argocd)
13. [Observabilidade e Monitoramento](#13-observabilidade-e-monitoramento)
14. [Segurança e Compliance](#14-segurança-e-compliance)
15. [Políticas (OPA/Gatekeeper)](#15-políticas-opagatekeeper)
16. [CI/CD e Automação](#16-cicd-e-automação)
17. [Configurações](#17-configurações)
18. [Scripts Operacionais](#18-scripts-operacionais)
19. [Testes](#19-testes)
20. [Deployment Multi-Cloud](#20-deployment-multi-cloud)
21. [RHDH — Red Hat Developer Hub](#21-rhdh--red-hat-developer-hub)
22. [Métricas e KPIs do Projeto](#22-métricas-e-kpis-do-projeto)
23. [Histórico de Versões](#23-histórico-de-versões)
24. [Referências e Links](#24-referências-e-links)

---

## 1. Visão Geral do Projeto

O **Three Horizons Implementation Accelerator** é uma plataforma enterprise-grade de DevOps agnóstica que combina **Infrastructure as Code**, **GitOps**, **AI Agents** e **Internal Developer Platform (IDP)** para acelerar a entrega de software em organizações de grande porte.

### Números do Projeto

| Métrica | Valor |
|---------|-------|
| Arquivos totais | 900+ |
| Linhas de código | ~80.000 |
| Módulos Terraform | 15 |
| Agentes AI (GitHub Copilot) | 17 |
| Golden Path Templates | 22 (9 detalhados no H2) |
| MCP Servers | 13 (11 configurados + 2 custom) |
| GitHub Workflows | 9 |
| Issue Templates | 23 |
| Skills Reutilizáveis | 15 |
| Prometheus Alert Rules | 50+ |
| Recording Rules | 40+ |
| Grafana Dashboards | 3 |
| Testes Go (Terratest) | 16 arquivos |
| Políticas OPA/Rego | 10+ |
| Constraint Templates K8s | 6 |

### Problema que Resolve

Organizações enterprise enfrentam fragmentação de ferramentas, falta de padronização, ciclos de entrega lentos e dificuldade em escalar práticas DevOps. Esta plataforma oferece um acelerador pré-configurado que vai de infraestrutura base até AI-powered development em três horizontes de maturidade.

### Proposta de Valor

- **Redução de 70% no tempo de onboarding** de novos times
- **Padronização via Golden Paths** que guiam desenvolvedores pelo caminho feliz
- **AI-Assisted Operations** com 17 agentes especializados e MCP servers
- **Compliance automático** via Policy as Code (OPA + Gatekeeper)
- **Multi-cloud ready** com Azure como primário, suporte a AWS, GCP e On-Premise

---

## 2. Arquitetura Three Horizons

O projeto segue o modelo de **Three Horizons of Innovation**, dividindo a plataforma em três fases de maturidade:

### H1 — Foundation (Horizonte 1: Base)

Infraestrutura core e serviços fundamentais.

- **AKS Cluster** — Kubernetes gerenciado no Azure
- **Networking** — VNet, Subnets, NSGs, Private Endpoints
- **Container Registry** — ACR (Azure Container Registry)
- **Databases** — PostgreSQL Flexible Server + Redis Cache
- **Security** — Key Vault, Managed Identity, RBAC
- **Naming Convention** — Padrão de nomenclatura para todos os recursos
- **Disaster Recovery** — Backup Vault, replicação geo-redundante

### H2 — Enhancement (Horizonte 2: Evolução)

Plataforma de desenvolvimento e automação.

- **Red Hat Developer Hub (RHDH)** — Portal do desenvolvedor com Backstage
- **ArgoCD** — GitOps engine para deployments
- **Golden Path Templates** — Templates padronizados para criação de serviços
- **Observability Stack** — Prometheus + Grafana + Alertmanager
- **External Secrets** — Integração com Azure Key Vault
- **GitHub Runners** — Self-hosted runners para CI/CD
- **OPA Gatekeeper** — Policy enforcement no cluster
- **API Gateway** — Gerenciamento de APIs com rate limiting

### H3 — Innovation (Horizonte 3: Inovação)

AI, automação inteligente e experiência do desenvolvedor.

- **AI Foundry** — Azure AI com modelos GPT-4o e embeddings
- **Developer Lightspeed** — AI chat integrado ao RHDH (Llama Stack + RAG)
- **GitHub Copilot Agents** — 17 agentes especializados
- **MCP Servers** — 13 servidores de contexto para AI
- **Microsoft Purview** — Data governance e catalogação
- **Cost Management** — Otimização de custos com budgets e alertas
- **Microsoft Defender** — Segurança avançada para containers e cloud

---

## 3. Stack Tecnológica Completa

### Infraestrutura & Cloud

| Tecnologia | Uso | Versão/Detalhes |
|------------|-----|-----------------|
| **Microsoft Azure** | Cloud provider primário | Regiões: brazilsouth, eastus2, southcentralus |
| **Terraform** | Infrastructure as Code | >= 1.5.0 com AzureRM >= 3.75.0 |
| **Azure Kubernetes Service (AKS)** | Orquestração de containers | Kubernetes 1.28+ |
| **Azure Container Registry (ACR)** | Registry de imagens | Premium SKU |
| **Azure Key Vault** | Gerenciamento de secrets | Premium SKU com HSM |
| **Azure PostgreSQL Flexible** | Banco de dados relacional | v14+ com geo-redundância |
| **Azure Redis Cache** | Cache distribuído | Premium com clustering |
| **Azure AI Foundry** | Serviços de AI | GPT-4o, text-embedding-ada-002 |
| **Azure Virtual Network** | Networking | /16 com subnets dedicadas |
| **Azure Backup Vault** | Disaster Recovery | Geo-redundante |
| **Microsoft Purview** | Data Governance | Catalogação e classificação |
| **Microsoft Defender for Cloud** | Segurança | Containers + Cloud posture |

### Plataforma & Orquestração

| Tecnologia | Uso |
|------------|-----|
| **Red Hat Developer Hub (RHDH) 1.8** | Internal Developer Platform (Backstage enterprise) |
| **ArgoCD** | GitOps continuous deployment |
| **Helm** | Package manager para Kubernetes |
| **OPA Gatekeeper** | Policy enforcement engine |
| **External Secrets Operator** | Sincronização de secrets |
| **cert-manager** | Gerenciamento de certificados TLS |
| **ingress-nginx** | Ingress controller |
| **external-dns** | DNS automation |
| **Prometheus** | Monitoramento e métricas |
| **Grafana** | Visualização e dashboards |
| **Alertmanager** | Gestão de alertas |
| **Jaeger** | Distributed tracing |

### AI & Agentes

| Tecnologia | Uso |
|------------|-----|
| **GitHub Copilot** | AI code assistant |
| **GitHub Copilot Agents** | 17 agentes especializados (.agent.md) |
| **Model Context Protocol (MCP)** | Protocolo de comunicação AI-tools |
| **Azure AI Foundry** | Backend de modelos AI |
| **Developer Lightspeed** | AI chat no RHDH (Llama Stack + RAG) |
| **Llama Stack** | LLM inference server |
| **Python AI SDK** | Azure AI Foundry SDK |

### CI/CD & DevOps

| Tecnologia | Uso |
|------------|-----|
| **GitHub Actions** | CI/CD pipelines |
| **GitHub Self-Hosted Runners** | Runners no AKS |
| **Pre-commit hooks** | Code quality gates |
| **Terratest (Go)** | Testes de infraestrutura |
| **tflint** | Linting de Terraform |
| **tfsec** | Security scanning de Terraform |
| **ShellCheck** | Linting de shell scripts |
| **yamllint** | Linting de YAML |
| **markdownlint** | Linting de Markdown |
| **detect-secrets** | Detecção de secrets no código |
| **kubeconform** | Validação de manifests K8s |
| **Conftest** | Policy testing com OPA |
| **Gitleaks** | Secret scanning |
| **Trivy** | Container vulnerability scanning |

### Linguagens & Frameworks

| Linguagem | Uso |
|-----------|-----|
| **HCL (Terraform)** | Definição de infraestrutura |
| **Go** | Testes de infraestrutura (Terratest) |
| **Python** | AI agents, scripts de automação |
| **Bash/Shell** | Scripts operacionais |
| **YAML** | Configurações K8s, Helm, ArgoCD, GitHub Actions |
| **Rego** | Políticas OPA |
| **JSON** | Dashboards Grafana, configurações |
| **Markdown** | Documentação |

---

## 4. Requisitos Funcionais

### RF-001: Provisionamento de Infraestrutura

- **RF-001.1** — O sistema DEVE provisionar um cluster AKS com node pools configuráveis (system + user) via Terraform
- **RF-001.2** — O sistema DEVE criar uma VNet com subnets isoladas para AKS, databases, endpoints privados e serviços
- **RF-001.3** — O sistema DEVE configurar NSGs (Network Security Groups) com regras de segurança para cada subnet
- **RF-001.4** — O sistema DEVE provisionar um Azure Container Registry (ACR) Premium com geo-replicação
- **RF-001.5** — O sistema DEVE criar um Azure Key Vault com soft delete, purge protection e RBAC
- **RF-001.6** — O sistema DEVE provisionar PostgreSQL Flexible Server com high availability e geo-redundant backup
- **RF-001.7** — O sistema DEVE provisionar Redis Cache com clustering e persistência
- **RF-001.8** — O sistema DEVE seguir uma convenção de nomenclatura padronizada para todos os recursos Azure

### RF-002: GitOps e Continuous Deployment

- **RF-002.1** — O sistema DEVE implementar ArgoCD como engine de GitOps com App-of-Apps pattern
- **RF-002.2** — O sistema DEVE suportar sync policies diferenciadas por ambiente (dev: auto-sync, staging: auto-sync, prod: manual)
- **RF-002.3** — O sistema DEVE implementar sync waves para garantir ordem de deployment (cert-manager → ingress → monitoring → RHDH → apps)
- **RF-002.4** — O sistema DEVE integrar External Secrets Operator com Azure Key Vault via Workload Identity
- **RF-002.5** — O sistema DEVE suportar múltiplos repositórios Git (GitHub HTTPS/SSH, Azure DevOps, Helm repos)
- **RF-002.6** — O sistema DEVE configurar RBAC no ArgoCD com integração SSO via Dex

### RF-003: Internal Developer Platform (IDP)

- **RF-003.1** — O sistema DEVE implantar Red Hat Developer Hub (RHDH) como portal do desenvolvedor
- **RF-003.2** — O sistema DEVE disponibilizar Golden Path templates para criação padronizada de serviços
- **RF-003.3** — O sistema DEVE suportar Dynamic Plugins via YAML (sem rebuild necessário)
- **RF-003.4** — O sistema DEVE implementar TechDocs para documentação técnica integrada
- **RF-003.5** — O sistema DEVE configurar homepage customizada com links, ações rápidas e widgets
- **RF-003.6** — O sistema DEVE implementar RBAC no RHDH com roles Admin, Developer e Viewer
- **RF-003.7** — O sistema DEVE suportar autenticação via GitHub OAuth

### RF-004: Golden Path Templates

- **RF-004.1** — O sistema DEVE fornecer template para criação de microserviços completos (API, DB, eventos, observabilidade, CI/CD)
- **RF-004.2** — O sistema DEVE fornecer template para API microservice com OpenAPI, validação e error handling
- **RF-004.3** — O sistema DEVE fornecer template para event-driven microservice com Event Hubs/Service Bus
- **RF-004.4** — O sistema DEVE fornecer template para data pipeline com ETL e quality checks
- **RF-004.5** — O sistema DEVE fornecer template para batch jobs com CronJob e monitoramento
- **RF-004.6** — O sistema DEVE fornecer template para API Gateway com rate limiting e auth
- **RF-004.7** — O sistema DEVE fornecer template para GitOps deployment com ArgoCD
- **RF-004.8** — O sistema DEVE fornecer template para migração ADO → GitHub (6 fases)
- **RF-004.9** — O sistema DEVE fornecer template para reusable GitHub Actions workflows

### RF-005: Observabilidade

- **RF-005.1** — O sistema DEVE implementar Prometheus para coleta de métricas
- **RF-005.2** — O sistema DEVE implementar Grafana com 3 dashboards pré-configurados (Platform Overview, Cost Management, Golden Path Application)
- **RF-005.3** — O sistema DEVE implementar 50+ alert rules cobrindo infraestrutura, aplicações, AI agents, GitOps, segurança e SLA
- **RF-005.4** — O sistema DEVE implementar 40+ recording rules para métricas agregadas
- **RF-005.5** — O sistema DEVE configurar ServiceMonitors para RHDH, ArgoCD, ingress-nginx, cert-manager e external-secrets
- **RF-005.6** — O sistema DEVE implementar Alertmanager com notificações configuráveis
- **RF-005.7** — O sistema DEVE suportar métricas SLO com burn rates em janelas de 5m, 1h, 24h e 30d

### RF-006: AI e Agentes Inteligentes

- **RF-006.1** — O sistema DEVE provisionar Azure AI Foundry com modelos GPT-4o e embeddings
- **RF-006.2** — O sistema DEVE disponibilizar 17 agentes GitHub Copilot especializados
- **RF-006.3** — O sistema DEVE configurar 13 MCP servers para comunicação AI-tools
- **RF-006.4** — O sistema DEVE suportar Developer Lightspeed no RHDH para AI chat
- **RF-006.5** — O sistema DEVE implementar BYOM (Bring Your Own Model) com suporte a Azure OpenAI, Ollama e vLLM
- **RF-006.6** — O sistema DEVE suportar agent-to-agent handoffs com contexto compartilhado
- **RF-006.7** — O sistema DEVE implementar 15 skills reutilizáveis para os agentes

### RF-007: Segurança

- **RF-007.1** — O sistema DEVE implementar Managed Identity / Workload Identity para autenticação sem secrets
- **RF-007.2** — O sistema DEVE aplicar Network Policies isolando namespaces
- **RF-007.3** — O sistema DEVE implementar OPA Gatekeeper com 6 constraint templates
- **RF-007.4** — O sistema DEVE integrar Microsoft Defender for Containers e Cloud
- **RF-007.5** — O sistema DEVE configurar private endpoints para todos os serviços PaaS
- **RF-007.6** — O sistema DEVE implementar secret scanning com detect-secrets e gitleaks
- **RF-007.7** — O sistema DEVE enforcement de TLS 1.2+ em todos os serviços

### RF-008: Automação e Scripts

- **RF-008.1** — O sistema DEVE fornecer script de deploy completo (`deploy-full.sh`)
- **RF-008.2** — O sistema DEVE fornecer scripts de validação (prerequisites, config, deployment, agents, docs)
- **RF-008.3** — O sistema DEVE fornecer scripts de setup (GitHub App, Identity Federation, Pre-commit, Branch Protection, Terraform Backend)
- **RF-008.4** — O sistema DEVE fornecer script de onboarding de times (`onboard-team.sh`)
- **RF-008.5** — O sistema DEVE fornecer script de migração ADO → GitHub

### RF-009: Cost Management

- **RF-009.1** — O sistema DEVE implementar budgets com alertas em 50%, 80%, 90% e 100% do orçamento
- **RF-009.2** — O sistema DEVE fornecer dashboard Grafana de custos
- **RF-009.3** — O sistema DEVE implementar resource tagging obrigatório (environment, project, owner, cost-center)
- **RF-009.4** — O sistema DEVE alertar sobre uso de VM sizes caros

---

## 5. Requisitos Não-Funcionais

### RNF-001: Disponibilidade

- **RNF-001.1** — A plataforma DEVE manter SLA de 99.9% de disponibilidade para serviços core (AKS, RHDH, ArgoCD)
- **RNF-001.2** — SLO burn rate DEVE ser monitorado em janelas de 5m, 1h, 24h e 30d
- **RNF-001.3** — Failover automático DEVE estar configurado para PostgreSQL com geo-redundância

### RNF-002: Performance

- **RNF-002.1** — Latência de API DEVE ser < 500ms no p99 (alertas em > 1s)
- **RNF-002.2** — RHDH DEVE responder em < 5s para operações de catalog
- **RNF-002.3** — Alertas de AI Foundry DEVEM disparar quando latência > 5s
- **RNF-002.4** — Recording rules DEVEM pré-calcular percentis de latência (p50, p90, p99)

### RNF-003: Escalabilidade

- **RNF-003.1** — AKS DEVE suportar auto-scaling de node pools (min 2 → max configurável)
- **RNF-003.2** — O sistema DEVE suportar 4 sizing profiles: Small (≤10 devs), Medium (10-50 devs), Large (50-200 devs), XLarge (200+ devs)
- **RNF-003.3** — ACR DEVE suportar geo-replicação para múltiplas regiões

### RNF-004: Segurança

- **RNF-004.1** — Todos os dados em trânsito DEVEM usar TLS 1.2+
- **RNF-004.2** — Todos os dados em repouso DEVEM ser encriptados (AES-256)
- **RNF-004.3** — Nenhum serviço PaaS DEVE ter acesso público habilitado (private endpoints obrigatórios)
- **RNF-004.4** — Containers DEVEM rodar como non-root sem privilege escalation
- **RNF-004.5** — Imagens DEVEM ser restritas a registries aprovados
- **RNF-004.6** — RBAC DEVE estar habilitado em AKS, RHDH, ArgoCD e Key Vault

### RNF-005: Compliance

- **RNF-005.1** — A plataforma DEVE suportar compliance LGPD (dados no Brazil: brazilsouth)
- **RNF-005.2** — A plataforma DEVE suportar auditorias SOC 2
- **RNF-005.3** — A plataforma DEVE suportar PCI-DSS e CIS Benchmarks
- **RNF-005.4** — Todas as políticas DEVEM ser versionadas e auditáveis via Git

### RNF-006: Observabilidade

- **RNF-006.1** — 100% dos serviços core DEVEM ter ServiceMonitors configurados
- **RNF-006.2** — Alertas DEVEM ter severidade classificada (critical, warning, info)
- **RNF-006.3** — Dashboards DEVEM estar disponíveis para infraestrutura, custos e aplicações
- **RNF-006.4** — Métricas de AI agents DEVEM incluir invocação, latência, tokens e erro rate

### RNF-007: Manutenibilidade

- **RNF-007.1** — Todo código Terraform DEVE passar por tflint, tfsec e Conftest
- **RNF-007.2** — Documentação DEVE ser gerada automaticamente via terraform-docs
- **RNF-007.3** — Pre-commit hooks DEVEM validar Terraform, Shell, YAML, Markdown, Kubernetes e Secrets
- **RNF-007.4** — Agentes DEVEM ter especificações validáveis via `validate-agents.sh`

### RNF-008: Portabilidade

- **RNF-008.1** — A arquitetura DEVE suportar deployment em Azure (primário), AWS, GCP e On-Premise
- **RNF-008.2** — Terraform modules DEVEM ser independentes e reutilizáveis
- **RNF-008.3** — Golden Paths DEVEM ser agnósticos de cloud quando possível

### RNF-009: Disaster Recovery

- **RNF-009.1** — RPO (Recovery Point Objective) DEVE ser ≤ 1 hora para dados críticos
- **RNF-009.2** — RTO (Recovery Time Objective) DEVE ser ≤ 4 horas para restauração completa
- **RNF-009.3** — Backups DEVEM ser geo-redundantes com retenção configurável
- **RNF-009.4** — DR runbooks DEVEM estar documentados e testados

---

## 6. User Stories

### Epic 1: Provisionamento de Infraestrutura

**US-001** — Como **Platform Engineer**, eu quero provisionar toda a infraestrutura Azure com um único `terraform apply`, para que eu possa ter um ambiente completo em menos de 1 hora.

**US-002** — Como **Platform Engineer**, eu quero que todos os recursos sigam uma convenção de nomenclatura padronizada (`{project}-{environment}-{region}-{resource}`), para facilitar identificação e governança.

**US-003** — Como **SRE**, eu quero que o cluster AKS tenha auto-scaling configurado com sizing profiles (S/M/L/XL), para atender diferentes escalas de time sem re-configuração manual.

**US-004** — Como **Security Engineer**, eu quero que todos os serviços PaaS usem private endpoints, para garantir que nenhum dado trafegue pela internet pública.

**US-005** — Como **Platform Engineer**, eu quero que o sistema de naming gere nomes consistentes para todos os recursos, para que eu mantenha padrão organizacional em múltiplos ambientes.

### Epic 2: GitOps e Deployments

**US-006** — Como **DevOps Engineer**, eu quero que todas as aplicações sejam deployadas via ArgoCD com Git como source of truth, para ter auditabilidade e rollback fácil.

**US-007** — Como **DevOps Engineer**, eu quero sync policies diferenciadas por ambiente (dev=auto, prod=manual), para ter velocidade em dev sem comprometer segurança em produção.

**US-008** — Como **DevOps Engineer**, eu quero sync waves para garantir que infraestrutura base (cert-manager, ingress) seja deployada antes das aplicações, para evitar falhas de dependência.

**US-009** — Como **DevOps Engineer**, eu quero que secrets sejam sincronizados automaticamente do Azure Key Vault via External Secrets Operator, para nunca ter secrets em repositórios Git.

### Epic 3: Developer Experience

**US-010** — Como **Desenvolvedor**, eu quero acessar um portal (RHDH) onde posso criar um novo microserviço a partir de um template padronizado, para começar a desenvolver em minutos ao invés de dias.

**US-011** — Como **Desenvolvedor**, eu quero escolher entre diferentes Golden Paths (microservice, API, event-driven, data pipeline, batch job), para usar o padrão arquitetural correto para meu caso de uso.

**US-012** — Como **Desenvolvedor**, eu quero que o template já inclua CI/CD, observabilidade, testes e documentação, para não precisar configurar cada um manualmente.

**US-013** — Como **Desenvolvedor**, eu quero ter um AI assistant (Developer Lightspeed) integrado ao portal, para me ajudar a resolver problemas e gerar código com contexto do meu projeto.

**US-014** — Como **Tech Lead**, eu quero visualizar o catálogo completo de serviços, APIs e documentação no RHDH, para ter visibilidade de todos os componentes da plataforma.

**US-015** — Como **Desenvolvedor**, eu quero usar templates de GitHub Actions reusáveis, para não duplicar pipelines entre projetos.

### Epic 4: Observabilidade

**US-016** — Como **SRE**, eu quero ter dashboards Grafana pré-configurados para infraestrutura, custos e aplicações, para monitorar a saúde da plataforma em tempo real.

**US-017** — Como **SRE**, eu quero receber alertas automáticos quando pods reiniciam mais de 5x em 15min, CPU > 80%, ou disco > 85%, para agir proativamente antes de impacto ao usuário.

**US-018** — Como **SRE**, eu quero monitorar SLOs com burn rates em múltiplas janelas de tempo, para priorizar ações baseado no impacto ao error budget.

**US-019** — Como **SRE**, eu quero métricas específicas de AI agents (invocação, latência, tokens, erro), para garantir que os agentes estão performando adequadamente.

**US-020** — Como **SRE**, eu quero alertas de GitOps que indiquem quando ArgoCD sync falhou ou RHDH está indisponível, para reagir rapidamente a problemas de deployment.

### Epic 5: AI Agents

**US-021** — Como **Desenvolvedor**, eu quero interagir com agentes especializados (@platform, @devops, @sre, @security, etc.) no GitHub Copilot, para receber assistência contextual na minha tarefa.

**US-022** — Como **Platform Engineer**, eu quero que agentes possam delegar tarefas entre si (handoffs), para que um fluxo complexo como deployment passe por validação, segurança e observabilidade automaticamente.

**US-023** — Como **Platform Engineer**, eu quero usar MCP servers para dar aos agentes acesso controlado a Azure, GitHub, Terraform, Kubernetes e Helm, para que eles possam executar ações reais com segurança.

**US-024** — Como **DevOps Engineer**, eu quero usar chat modes (Architect, Reviewer, SRE) para ter personas especializadas, para receber orientação no tom e expertise corretos.

**US-025** — Como **Platform Engineer**, eu quero criar novos agentes seguindo o template padronizado (.agent.md), para expandir a capacidade da plataforma com novos especialistas.

### Epic 6: Segurança e Compliance

**US-026** — Como **Security Engineer**, eu quero que OPA Gatekeeper bloqueie containers privilegiados, sem resource limits, ou de registries não aprovados, para enforce security policies automaticamente.

**US-027** — Como **Security Engineer**, eu quero que políticas Terraform validem tags obrigatórias, TLS, encryption e public access em todo recurso Azure, para garantir compliance antes do deploy.

**US-028** — Como **Compliance Officer**, eu quero que a plataforma suporte LGPD (dados no Brazil), SOC 2 e PCI-DSS, para atender requisitos regulatórios.

**US-029** — Como **Security Engineer**, eu quero que pre-commit hooks detectem secrets no código antes do commit, para prevenir vazamento de credenciais.

**US-030** — Como **Security Engineer**, eu quero alertas de segurança (certificados expirando, login failures, pod security violations), para responder a incidentes rapidamente.

### Epic 7: Migração e Onboarding

**US-031** — Como **Platform Engineer**, eu quero um template de migração ADO → GitHub em 6 fases, para migrar times do Azure DevOps para GitHub de forma estruturada.

**US-032** — Como **Platform Engineer**, eu quero um script de onboarding (`onboard-team.sh`) que configure namespace, RBAC, service account, resource quotas e network policies para um novo time, para onboardar equipes em minutos.

**US-033** — Como **Novo Desenvolvedor**, eu quero um quick start guiado por agente que me configure em 3 passos (prerequisites → deploy → validate), para começar a usar a plataforma no primeiro dia.

### Epic 8: Cost Management

**US-034** — Como **FinOps Engineer**, eu quero budgets Azure com alertas em 50%, 80%, 90% e 100%, para controlar gastos proativamente.

**US-035** — Como **FinOps Engineer**, eu quero um dashboard Grafana de custos, para visualizar tendências e identificar oportunidades de otimização.

**US-036** — Como **FinOps Engineer**, eu quero alertas quando VMs caras (Standard_E, Standard_M) são usadas, para validar se o sizing é adequado.

---

## 7. Estrutura do Repositório

```
agentic-devops-platform/
├── .github/                          # GitHub configuration
│   ├── workflows/                    # 9 GitHub Actions workflows
│   │   ├── ci-cd.yml                 # Combined CI/CD pipeline
│   │   ├── ci.yml                    # Continuous Integration
│   │   ├── cd.yml                    # Continuous Deployment
│   │   ├── terraform-test.yml        # Terraform testing
│   │   ├── validate-agents.yml       # Agent validation
│   │   ├── release.yml               # Release automation
│   │   ├── agent-router.yml          # Route issues to agents
│   │   ├── issue-ops.yml             # Issue operations
│   │   └── branch-protection.yml     # Branch protection rules
│   ├── ISSUE_TEMPLATE/               # 23 issue templates
│   ├── skills/                       # 15 reusable agent skills
│   ├── chatmodes/                    # 3 chat modes (Architect, Reviewer, SRE)
│   ├── prompts/                      # 7 reusable prompts
│   ├── instructions/                 # Path-specific instructions
│   └── copilot-instructions.md       # Global Copilot instructions
│
├── agents-templates/                 # 17 agent specifications
│   ├── AGENT_TEMPLATE.md             # Base template for agents
│   ├── platform.agent.md             # IDP/Golden Paths specialist
│   ├── devops.agent.md               # CI/CD specialist
│   ├── sre.agent.md                  # SRE/Observability specialist
│   ├── architect.agent.md            # System design
│   ├── reviewer.agent.md             # Code review
│   ├── terraform.agent.md            # IaC specialist
│   ├── security.agent.md             # Security compliance
│   ├── deploy.agent.md               # Deployment orchestration
│   ├── test.agent.md                 # Testing/QA
│   ├── docs.agent.md                 # Documentation
│   ├── github-integration.agent.md   # GitHub operations
│   ├── ado-integration.agent.md      # Azure DevOps integration
│   ├── azure-portal-deploy.agent.md  # Azure portal deploy
│   ├── template-engineer.agent.md    # Template creation
│   ├── onboarding.agent.md           # Team onboarding
│   └── hybrid-scenarios.agent.md     # Multi-step scenarios
│
├── terraform/                        # Infrastructure as Code
│   ├── main.tf                       # Root module orchestration
│   ├── variables.tf                  # Input variables
│   ├── outputs.tf                    # Output values
│   ├── terraform.tfvars.example      # Example variable values
│   ├── backend.tf.example            # Remote state backend
│   └── modules/                      # 15 Terraform modules
│       ├── naming/                   # Resource naming convention
│       ├── networking/               # VNet, Subnets, NSGs
│       ├── aks-cluster/              # AKS configuration
│       ├── container-registry/       # ACR
│       ├── databases/                # PostgreSQL + Redis
│       ├── security/                 # Key Vault, RBAC
│       ├── argocd/                   # ArgoCD deployment
│       ├── observability/            # Prometheus, Grafana
│       ├── external-secrets/         # External Secrets Operator
│       ├── github-runners/           # Self-hosted runners
│       ├── ai-foundry/              # Azure AI services
│       ├── purview/                  # Data governance
│       ├── defender/                 # Microsoft Defender
│       ├── cost-management/          # Budgets and alerts
│       └── disaster-recovery/        # Backup and recovery
│
├── golden-paths/                     # RHDH templates
│   └── h2-enhancement/               # Horizon 2 templates
│       ├── microservice/             # Full microservice
│       ├── api-microservice/         # REST API service
│       ├── event-driven-microservice/# Event-based service
│       ├── data-pipeline/            # ETL pipelines
│       ├── batch-job/                # CronJob workloads
│       ├── api-gateway/              # API Management
│       ├── gitops-deployment/        # ArgoCD manifests
│       ├── ado-to-github-migration/  # Migration template
│       └── reusable-workflows/       # GitHub Actions library
│
├── argocd/                           # GitOps configuration
│   ├── app-of-apps/                  # Root application
│   ├── apps/                         # Individual applications
│   ├── secrets/                      # Secret stores
│   ├── sync-policies.yaml            # Sync policy presets
│   └── repo-credentials.yaml         # Repository access
│
├── deploy/                           # Deployment manifests
│   └── helm/                         # Helm values
│       ├── argocd/values.yaml        # ArgoCD config
│       ├── monitoring/values.yaml    # Prometheus stack
│       ├── sre-alerts.yaml           # Alert rules
│       ├── service-monitors.yaml     # Metric scrapers
│       ├── external-secrets-config.yaml
│       ├── ingress-all.yaml          # Ingress resources
│       └── argocd-apps.yaml          # ArgoCD applications
│
├── config/                           # Platform configuration
│   ├── apm.yml                       # Agent Package Manager
│   ├── sizing-profiles.yaml          # T-shirt sizing (S/M/L/XL)
│   └── region-availability.yaml      # Azure regions matrix
│
├── grafana/                          # Grafana dashboards
│   └── dashboards/
│       ├── platform-overview.json    # Infrastructure dashboard
│       ├── cost-management.json      # Cost dashboard
│       └── golden-path-application.json # App dashboard
│
├── prometheus/                       # Monitoring rules
│   ├── alerting-rules.yaml           # 50+ alert rules
│   └── recording-rules.yaml          # 40+ recording rules
│
├── policies/                         # Policy as Code
│   ├── terraform/azure.rego          # OPA policies for Terraform
│   └── kubernetes/                   # Gatekeeper policies
│       ├── constraint-templates/     # 6 ConstraintTemplates
│       └── constraints/              # Applied constraints
│
├── mcp-servers/                      # MCP configuration
│   ├── mcp-config.json               # 11 server definitions
│   └── USAGE.md                      # Usage guide + access matrix
│
├── scripts/                          # Operational scripts
│   ├── deploy-full.sh                # Full deployment
│   ├── platform-bootstrap.sh         # Platform setup
│   ├── bootstrap.sh                  # H1 infrastructure
│   ├── validate-*.sh                 # Validation scripts (5)
│   ├── setup-*.sh                    # Setup scripts (5)
│   ├── onboard-team.sh               # Team onboarding
│   └── migration/                    # ADO→GitHub migration
│
├── new-features/                     # RHDH-specific features
│   ├── AGENTS.md                     # RHDH agent guide
│   ├── configs/                      # Dynamic plugins, RBAC, Helm
│   ├── foundry/                      # Python AI agents
│   └── homepage/                     # RHDH homepage config
│
├── tests/                            # Test suites
│   └── terraform/
│       └── modules/                  # 16 Go test files (Terratest)
│
├── docs/                             # Documentation
│   ├── research/agent-research.md    # Agent research
│   ├── GITHUB_COPILOT_AGENTS_BEST_PRACTICES.md
│   └── official-docs/rhdh/           # Red Hat PDFs and HTML
│
├── images-logos/                      # Brand assets
├── platform/                          # Platform services docs
├── AGENTS.md                          # Agent system overview
├── README.md                          # Project README
├── CONTRIBUTING.md                    # Contribution guide
├── SECURITY.md                        # Security policy
├── CHANGELOG.md                       # Version history
├── CODEOWNERS                         # Code ownership
└── LICENSE                            # MIT License
```

---

## 8. Módulos Terraform (Infrastructure as Code)

### 8.1 Visão Geral dos Módulos

Todos os módulos utilizam AzureRM provider >= 3.75.0 e Terraform >= 1.5.0.

| # | Módulo | Descrição | Recursos Criados |
|---|--------|-----------|------------------|
| 1 | **naming** | Convenção de nomenclatura | Nomes padronizados para todos os recursos |
| 2 | **networking** | Rede virtual | VNet, Subnets (AKS, DB, PE, Services), NSGs, Route Tables |
| 3 | **aks-cluster** | Cluster Kubernetes | AKS com system + user node pools, Managed Identity, RBAC |
| 4 | **container-registry** | Registry de imagens | ACR Premium, geo-replicação, integração AKS |
| 5 | **databases** | Bancos de dados | PostgreSQL Flexible Server, Redis Cache, diagnósticos |
| 6 | **security** | Segurança core | Key Vault, Managed Identity, role assignments |
| 7 | **argocd** | GitOps | ArgoCD via Helm, namespace, RBAC, ingress |
| 8 | **observability** | Monitoramento | Prometheus, Grafana, Alertmanager, Log Analytics |
| 9 | **external-secrets** | Secret sync | External Secrets Operator, ClusterSecretStore, Workload Identity |
| 10 | **github-runners** | CI runners | Self-hosted GitHub Actions runners no AKS |
| 11 | **ai-foundry** | Inteligência artificial | Cognitive Account, AI Search, model deployments |
| 12 | **purview** | Governança de dados | Microsoft Purview Account, scan rules |
| 13 | **defender** | Segurança avançada | Defender for Containers, Cloud, Key Vault |
| 14 | **cost-management** | Custos | Budgets, alertas, tags obrigatórias |
| 15 | **disaster-recovery** | DR | Backup Vault, políticas, geo-replicação |

### 8.2 Variáveis Globais (terraform/variables.tf)

Variáveis-chave que controlam todo o deployment:

- `project_name` — Nome do projeto (usado no naming convention)
- `environment` — Ambiente (dev, staging, prod)
- `location` — Região Azure primária
- `tags` — Tags obrigatórias (environment, project, owner, cost-center)
- `aks_config` — Configuração do cluster (versão K8s, node count, VM size)
- `networking_config` — CIDRs da VNet e subnets
- `database_config` — SKU e versão do PostgreSQL/Redis
- `enable_*` — Feature flags para cada módulo (enable_defender, enable_purview, etc.)

### 8.3 Outputs Globais (terraform/outputs.tf)

Os outputs incluem:

- IDs e endpoints de todos os recursos criados
- Credenciais de acesso (via Key Vault references)
- Comandos `kubectl` para conexão ao cluster
- URLs de acesso para RHDH, ArgoCD, Grafana
- Connection strings para databases

---

## 9. Golden Paths (Templates RHDH)

Golden Paths são templates padronizados registrados no Red Hat Developer Hub que guiam desenvolvedores pelo "caminho feliz" de criação de serviços.

### 9.1 Templates Disponíveis (H2 Enhancement)

#### Microservice Completo
- **Escopo**: API REST + Database + Event Producer/Consumer + Observabilidade + CI/CD
- **Inclui**: Dockerfile, Helm chart, GitHub Actions, Prometheus metrics, health checks
- **Linguagens**: Configurável (Node.js, Python, Java, Go)

#### API Microservice
- **Escopo**: RESTful API com OpenAPI spec, validação, error handling, observabilidade
- **Inclui**: OpenAPI 3.0 spec, request validation, structured error responses, rate limiting

#### Event-Driven Microservice
- **Escopo**: Microservice baseado em eventos com Event Hubs/Service Bus
- **Inclui**: Dead letter queues, retry policies, event schema validation, idempotency

#### Data Pipeline
- **Escopo**: ETL pipeline com Databricks
- **Inclui**: Data quality checks, schema validation, monitoring, alerting

#### Batch Job
- **Escopo**: Kubernetes CronJob com monitoramento
- **Inclui**: Job scheduling, failure handling, resource limits, alerting

#### API Gateway
- **Escopo**: API Management com OpenAPI
- **Inclui**: Rate limiting, authentication (JWT/OAuth), routing, request transformation

#### GitOps Deployment
- **Escopo**: ArgoCD application manifests
- **Inclui**: Sync policies, health checks, rollback configuration, notifications

#### ADO to GitHub Migration
- **Escopo**: Migração em 6 fases do Azure DevOps para GitHub
- **Fases**: Config → Repos → Pipelines → Boards → Artifacts → Validation

#### Reusable Workflows
- **Escopo**: Library de GitHub Actions workflows reutilizáveis
- **Inclui**: CI, CD, security scanning, linting, testing workflows

---

## 10. Sistema de Agentes AI

### 10.1 Agentes GitHub Copilot

O projeto define 17 agentes especializados no formato `.agent.md` (padrão agents.md open standard):

| Agente | Escopo | Tools |
|--------|--------|-------|
| **@platform** | IDP, Golden Paths, Catalog, Onboarding | kubernetes, helm, github |
| **@devops** | CI/CD, K8s, GitOps, Pipelines | kubernetes, helm, github, argocd |
| **@sre** | Observability, SLOs, Incident Response | prometheus, grafana, kubernetes |
| **@architect** | System design, architecture decisions | - |
| **@reviewer** | Code review, security analysis | github |
| **@terraform** | Infrastructure as Code | terraform, azure |
| **@security** | Compliance, vulnerability scanning | defender, gitleaks, trivy |
| **@deploy** | Deployment orchestration | argocd, kubernetes, helm |
| **@test** | Testing and QA automation | - |
| **@docs** | Documentation generation | - |
| **@github-integration** | GitHub operations | github |
| **@ado-integration** | Azure DevOps integration | azure |
| **@azure-portal-deploy** | Azure portal deployment | azure |
| **@template-engineer** | Golden Path template creation | kubernetes, helm |
| **@onboarding** | Team onboarding workflows | kubernetes, github |
| **@hybrid-scenarios** | Multi-step complex scenarios | all |

### 10.2 Estrutura de um Agente (.agent.md)

Cada agente segue um formato padronizado com:

```yaml
---
name: agent-name
description: Agent purpose
tools: [tool1, tool2]
user-invokable: true
handoffs: [other-agent-1, other-agent-2]
---
```

Seguido de seções:
- **Purpose** — O que o agente faz
- **Commands** — Comandos disponíveis
- **Boundaries** — Always do / Ask first / Never do
- **Task Decomposition** — Como quebrar tarefas complexas
- **Handoffs** — Quando e para quem delegar

### 10.3 Fluxos de Handoff

1. **Deployment Flow**: @deploy → @security (scan) → @sre (monitoring) → @deploy (execute)
2. **Security Flow**: @security → @terraform (fix infra) → @reviewer (validate)
3. **Template Flow**: @template-engineer → @platform (register) → @docs (document)
4. **Multi-file Change**: @architect (plan) → @terraform + @devops (implement) → @reviewer (validate)
5. **Hybrid Integration**: @github-integration + @ado-integration → @deploy

### 10.4 Skills Reutilizáveis

15 skills em `.github/skills/`:

| Skill | Descrição |
|-------|-----------|
| azure-infrastructure | Bootstrap de infraestrutura Azure |
| azure-cli | Operações Azure CLI |
| terraform-cli | Operações Terraform (init, plan, apply) |
| kubernetes | Operações kubectl |
| helm-cli | Operações Helm |
| github-cli | Operações GitHub |
| argocd-cli | Operações ArgoCD |
| prerequisites | Validação de pré-requisitos |
| observability-stack | Setup de monitoramento |
| ai-foundry-operations | Gestão de AI Foundry |
| mcp-cli | Configuração MCP |
| deploy-orchestration | Coordenação de deploy |
| database-management | Gestão de databases |
| codespaces-golden-paths | GitHub Codespaces setup |
| validation-scripts | Scripts de validação |

### 10.5 Chat Modes

3 personas especializadas para GitHub Copilot Chat:

- **Architect** — Foco em design de sistemas, trade-offs, ADRs
- **Reviewer** — Foco em code review, segurança, best practices
- **SRE** — Foco em observabilidade, SLOs, incident response

### 10.6 Reusable Prompts

7 prompts padronizados em `.github/prompts/`:

| Prompt | Uso |
|--------|-----|
| review-code | Code review com foco em segurança |
| generate-tests | Geração de testes |
| create-service | Scaffolding de serviço |
| generate-docs | Geração de documentação |
| deploy-platform | Deploy da plataforma |
| troubleshoot-incident | Resposta a incidentes |
| deploy-service | Deploy de serviço |

---

## 11. MCP Servers (Model Context Protocol)

### 11.1 Servidores Configurados

13 MCP servers que dão aos agentes AI acesso controlado a ferramentas:

| Server | Comando | Capabilities |
|--------|---------|-------------|
| **azure** | `az` | Azure CLI — recursos, RBAC, monitoring |
| **github** | `gh` | GitHub CLI — repos, PRs, issues, actions |
| **terraform** | `terraform` | Plan, apply, state, validate |
| **kubernetes** | `kubectl` | Pods, services, deployments, logs |
| **helm** | `helm` | Install, upgrade, rollback, template |
| **docker** | `docker` | Build, push, pull, inspect |
| **git** | `git` | Clone, commit, push, branch, merge |
| **bash** | `bash` | Shell commands (with restrictions) |
| **filesystem** | `fs` | Read, write, list files |
| **defender** | `defender` | Security scanning, compliance |
| **copilot** | `copilot` | GitHub Copilot CLI |

### 11.2 Matriz de Acesso

Cada agente tem acesso específico a determinados MCP servers:

| Agente | azure | github | terraform | kubernetes | helm |
|--------|-------|--------|-----------|------------|------|
| @terraform | ✅ | ✅ | ✅ | ❌ | ❌ |
| @devops | ✅ | ✅ | ❌ | ✅ | ✅ |
| @sre | ✅ | ❌ | ❌ | ✅ | ❌ |
| @security | ✅ | ✅ | ✅ | ✅ | ❌ |
| @deploy | ✅ | ✅ | ❌ | ✅ | ✅ |

### 11.3 Segurança dos MCP Servers

- **Read-only operations**: Permitidas sem confirmação
- **Write operations**: Requerem confirmação do usuário
- **Forbidden operations**: Nunca executadas (delete production resources, force push main)
- **Authentication**: Via variáveis de ambiente (AZURE_SUBSCRIPTION_ID, GITHUB_TOKEN, etc.)

---

## 12. GitOps com ArgoCD

### 12.1 Padrão App-of-Apps

O ArgoCD utiliza o padrão **App-of-Apps** com uma Root Application que gerencia todas as outras:

**Deployment Waves (ordem de instalação):**

| Wave | Componente | Tipo |
|------|-----------|------|
| 1 | cert-manager, external-dns | Infrastructure |
| 2 | ingress-nginx | Networking |
| 3 | prometheus, jaeger | Observability |
| 4 | Red Hat Developer Hub | Platform |
| 5+ | Team namespaces, Golden Paths, Cluster Issuers | Applications |

### 12.2 Sync Policies

| Preset | Prune | Self-Heal | Auto-Sync | Uso |
|--------|-------|-----------|-----------|-----|
| dev-auto-sync | ✅ | ✅ | ✅ | Desenvolvimento |
| staging-auto-sync | ✅ | ✅ | ✅ | Staging |
| prod-manual-sync | ❌ | ❌ | ❌ | Produção |
| infra-careful-sync | ❌ | ✅ | ✅ | Infra crítica |
| preview-aggressive-sync | ✅ | ✅ | ✅ | Ambientes efêmeros |

### 12.3 Repository Credentials

Suporte a múltiplos tipos de repositório:
- GitHub HTTPS com PAT
- GitHub SSH com deploy keys
- Azure DevOps HTTPS
- Helm repositories (Bitnami, Prometheus, Grafana, Jetstack)
- ACR (Azure Container Registry) como Helm OCI

---

## 13. Observabilidade e Monitoramento

### 13.1 Stack de Observabilidade

- **Prometheus** — Coleta de métricas com scrape configurado
- **Grafana** — Dashboards com SSO via Azure AD
- **Alertmanager** — Gestão e roteamento de alertas
- **Jaeger** — Distributed tracing
- **Log Analytics** — Azure-native logging

### 13.2 Alertas por Categoria

#### Infraestrutura (H1)
- Node não pronto por > 5min (critical)
- Pod reiniciando > 5x em 15min (warning)
- PVC > 85% utilizado (warning)
- CPU > 80% por > 15min (warning)
- Memória > 85% por > 15min (warning)

#### Plataforma (H2)
- RHDH indisponível por > 5min (critical)
- ArgoCD sync falhando por > 15min (critical)
- Grafana indisponível por > 5min (warning)

#### AI/Agents (H3)
- AI Foundry latência > 5s (warning)
- Agent failure rate > 10% em 15min (warning)
- Multi-agent orchestration timeout (warning)

#### SRE/SLOs
- SLO burn rate alto (1h window) (critical)
- SLO burn rate moderado (6h window) (warning)
- Availability SLA breach (critical)

#### Segurança
- Certificados expirando em < 30 dias (warning)
- Failed login attempts > 10 em 5min (warning)
- Pod security policy violations (warning)

### 13.3 Grafana Dashboards

| Dashboard | Painéis |
|-----------|---------|
| **Platform Overview** | Cluster health, node status, pod distribution, resource usage |
| **Cost Management** | Budget utilization, cost trends, resource costs by tag |
| **Golden Path Application** | App RED metrics, latency, error rates, deployment frequency |

### 13.4 ServiceMonitors

Métricas coletadas de:
- RHDH (porta 7007, path /metrics)
- ArgoCD (server, repo-server, controller)
- ingress-nginx (porta 10254)
- cert-manager (porta 9402)
- external-secrets (porta 8080)

---

## 14. Segurança e Compliance

### 14.1 Modelo de Segurança

```
┌─────────────────────────────────────────────────┐
│                  Perímetro                        │
│  ┌─────────────────────────────────────────────┐ │
│  │           Network Security                    │ │
│  │  VNet + NSGs + Private Endpoints             │ │
│  │  ┌────────────────────────────────────────┐  │ │
│  │  │         Identity & Access               │  │ │
│  │  │  Managed Identity + Workload Identity   │  │ │
│  │  │  RBAC + Azure AD + Key Vault           │  │ │
│  │  │  ┌──────────────────────────────────┐  │  │ │
│  │  │  │       Runtime Security           │  │  │ │
│  │  │  │  Gatekeeper + Defender           │  │  │ │
│  │  │  │  Non-root + No-privilege         │  │  │ │
│  │  │  │  Approved registries only        │  │  │ │
│  │  │  └──────────────────────────────────┘  │  │ │
│  │  └────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### 14.2 Padrões de Segurança

| Área | Implementação |
|------|---------------|
| **Authentication** | Managed Identity, Workload Identity, OIDC Federation, Azure AD SSO |
| **Network** | Private Endpoints, NSGs, VNet isolation, no public access |
| **Data Protection** | TLS 1.2+, AES-256 encryption at rest, Key Vault for secrets |
| **Container** | Non-root, no privilege escalation, read-only rootfs, approved registries |
| **CI/CD** | Branch protection, signed commits, secret scanning, SAST |

### 14.3 Ferramentas de Segurança Integradas

- **Gitleaks** — Secret scanning em commits
- **detect-secrets** — Baseline de secrets no repositório
- **Trivy** — Vulnerability scanning de containers
- **tfsec** — Security analysis de Terraform
- **OPA/Gatekeeper** — Policy enforcement runtime
- **Microsoft Defender** — Cloud security posture management
- **Conftest** — Policy testing para Terraform plans

### 14.4 Compliance Suportado

- **LGPD** — Dados no brazilsouth, consent management
- **SOC 2** — Audit trails, access controls, monitoring
- **PCI-DSS** — Network segmentation, encryption, access management
- **CIS Benchmarks** — Kubernetes e Azure hardening

### 14.5 Versões Suportadas

| Versão | Suporte |
|--------|---------|
| 4.x | ✅ Suporte ativo com security patches |
| 3.x | ❌ Sem suporte |
| < 3.0 | ❌ Sem suporte |

---

## 15. Políticas (OPA/Gatekeeper)

### 15.1 Políticas Terraform (Rego)

Políticas OPA executadas via Conftest no pipeline CI:

| Política | Severidade | Descrição |
|----------|-----------|-----------|
| Required Tags | Error | environment, project, owner, cost-center obrigatórios |
| TLS Enforcement | Error | Storage accounts e PostgreSQL devem usar TLS 1.2 |
| Encryption | Error | Storage e Key Vault devem ter encryption habilitado |
| No Public Access | Error | Storage, Key Vault, AKS sem acesso público |
| HTTPS Only | Error | Storage accounts HTTPS-only |
| Private Endpoints | Warning | Serviços PaaS devem ter private endpoints |
| AKS RBAC | Error | AKS deve ter RBAC, Managed Identity, Azure Policy, Defender |
| Geo-redundant Backups | Error | PostgreSQL deve ter backup geo-redundante |
| Expensive VMs | Warning | Alerta sobre uso de Standard_E/Standard_M series |

### 15.2 Constraint Templates Kubernetes (Gatekeeper)

| Template | Descrição |
|----------|-----------|
| **K8sRequiredLabels** | Labels obrigatórias com regex validation |
| **K8sContainerResources** | CPU e memory requests/limits obrigatórios |
| **K8sDenyPrivileged** | Bloqueia containers privilegiados |
| **K8sRequireNonRoot** | Exige execução como non-root |
| **K8sAllowedRegistries** | Restringe a registries aprovados |
| **K8sDenyHostNamespace** | Bloqueia acesso ao host namespace |

---

## 16. CI/CD e Automação

### 16.1 GitHub Actions Workflows

| Workflow | Trigger | Descrição |
|----------|---------|-----------|
| **ci-cd.yml** | push/PR to main | Pipeline completo (lint, test, build, deploy) |
| **ci.yml** | push/PR | Continuous Integration (lint, test, validate) |
| **cd.yml** | merge to main | Continuous Deployment (deploy to staging/prod) |
| **terraform-test.yml** | changes in terraform/ | Terratest execution |
| **validate-agents.yml** | changes in agents/ | Validação de specs de agentes |
| **release.yml** | tag creation | Release automation com CHANGELOG |
| **agent-router.yml** | issue creation | Roteia issues para agentes corretos |
| **issue-ops.yml** | issue events | Automação de issue operations |
| **branch-protection.yml** | scheduled | Enforcement de branch rules |

### 16.2 Pre-commit Hooks

Hooks executados antes de cada commit:

| Hook | Escopo | Ação |
|------|--------|------|
| terraform fmt | .tf files | Formatação |
| terraform validate | .tf files | Validação de sintaxe |
| tflint | .tf files | Linting de Terraform |
| tfsec | .tf files | Security scanning |
| shellcheck | .sh files | Linting de shell |
| kubeconform | .yaml K8s files | Validação de manifests |
| yamllint | .yaml files | Linting YAML |
| markdownlint | .md files | Linting Markdown |
| detect-secrets | all files | Detecção de secrets |
| end-of-file-fixer | all files | Newline no final |
| trailing-whitespace | all files | Espaços em branco |
| check-yaml | .yaml files | Sintaxe YAML |
| check-json | .json files | Sintaxe JSON |

### 16.3 Branch Strategy

- `main` — Branch protegida, requer PR com aprovação
- `feature/*` — Features novas
- `bugfix/*` — Bug fixes
- `hotfix/*` — Hotfixes para produção
- `release/*` — Preparação de releases

### 16.4 Commit Convention

```
<type>(<scope>): <description>

Types: feat, fix, docs, style, refactor, perf, test, chore, ci
Scopes: terraform, k8s, argocd, agents, golden-paths, scripts, docs
```

---

## 17. Configurações

### 17.1 APM (Agent Package Manager) — config/apm.yml

Manifesto central que define todas as dependências, instruções, prompts e agentes do projeto. Serve como "package.json" para a configuração de agentes, com targets de compilação para VSCode, Claude e Codex.

### 17.2 Sizing Profiles — config/sizing-profiles.yaml

Perfis T-shirt para dimensionamento de infraestrutura:

| Profile | Devs | AKS Nodes | PostgreSQL | Redis | AI Foundry |
|---------|------|-----------|------------|-------|------------|
| **Small** | ≤10 | 2 (Standard_D4s_v5) | B_Standard_B2s | Basic C1 | S0 |
| **Medium** | 10-50 | 3 (Standard_D8s_v5) | GP_Standard_D4s_v3 | Standard C3 | S1 |
| **Large** | 50-200 | 5 (Standard_D16s_v5) | GP_Standard_D8s_v3 | Premium P2 | S2 |
| **XLarge** | 200+ | 8 (Standard_D32s_v5) | MO_Standard_E4s_v3 | Premium P4 | S3 |

### 17.3 Region Availability — config/region-availability.yaml

| Tier | Regiões | Serviços |
|------|---------|----------|
| **Tier 1** | brazilsouth, eastus2, southcentralus | Todos os serviços (AKS, AI, Purview, etc.) |
| **Tier 2** | westus2 | Maioria dos serviços (sem Purview) |

**Deployment Patterns:**
- **LGPD Compliance**: Primary brazilsouth, DR eastus2
- **Multi-LATAM**: Primary brazilsouth, Secondary southcentralus
- **US-Based**: Primary eastus2, Secondary westus2

### 17.4 Arquivos de Lint e Validação

| Arquivo | Propósito |
|---------|-----------|
| `.tflint.hcl` | Regras para Terraform linting (Azure-specific) |
| `.yamllint.yml` | Regras YAML (200 chars max, allow comments) |
| `.markdownlint.json` | Regras Markdown (proper names: Kubernetes, Azure, RHDH) |
| `.terraform-docs.yml` | Auto-geração de docs Terraform |
| `.secrets.baseline` | Baseline de detect-secrets com 13+ detectors |
| `.pre-commit-config.yaml` | Definição de todos os pre-commit hooks |

---

## 18. Scripts Operacionais

### 18.1 Scripts de Deployment

| Script | Descrição |
|--------|-----------|
| `deploy-full.sh` | Deploy completo end-to-end (infra + platform + apps) |
| `platform-bootstrap.sh` | Bootstrap da plataforma (RHDH, ArgoCD, monitoring) |
| `bootstrap.sh` | Setup da infraestrutura H1 (Terraform apply) |

### 18.2 Scripts de Validação

| Script | Valida |
|--------|--------|
| `validate-prerequisites.sh` | CLIs instaladas (az, terraform, kubectl, helm, gh, etc.) |
| `validate-config.sh` | Arquivos de configuração (tfvars, sizing, regions) |
| `validate-deployment.sh` | Saúde pós-deploy (pods, services, endpoints) |
| `validate-agents.sh` | Specs dos agentes (YAML frontmatter, boundaries, handoffs) |
| `validate-docs.sh` | Documentação (links quebrados, formatação, completeness) |

### 18.3 Scripts de Setup

| Script | Configura |
|--------|-----------|
| `setup-github-app.sh` | GitHub App para autenticação RHDH |
| `setup-identity-federation.sh` | OIDC Workload Identity Federation |
| `setup-pre-commit.sh` | Instala e configura pre-commit hooks |
| `setup-branch-protection.sh` | Rules de branch no GitHub |
| `setup-terraform-backend.sh` | Backend remoto (Azure Storage Account) |

### 18.4 Scripts Operacionais

| Script | Descrição |
|--------|-----------|
| `onboard-team.sh` | Cria namespace, RBAC, service account, quotas, network policies |
| `migration/ado-to-github-migration.sh` | Migração ADO → GitHub em 6 fases |

---

## 19. Testes

### 19.1 Framework de Testes

O projeto utiliza **Terratest** (Go) para testes de infraestrutura. Cada módulo Terraform tem seu próprio arquivo de teste.

### 19.2 Arquivos de Teste

| Teste | Módulo | Validações |
|-------|--------|------------|
| `aks_cluster_test.go` | AKS | Versão K8s, node pools, RBAC, identity |
| `networking_test.go` | Networking | VNet CIDR, subnets, NSGs |
| `container_registry_test.go` | ACR | SKU, geo-replicação, admin disabled |
| `databases_test.go` | Databases | PostgreSQL version, SSL, Redis config |
| `security_test.go` | Security | Key Vault, purge protection, RBAC |
| `argocd_test.go` | ArgoCD | Namespace, Helm values, ingress |
| `ai_foundry_test.go` | AI Foundry | Model deployments, endpoints |
| `observability_test.go` | Observability | Prometheus, Grafana, ServiceMonitors |
| `github_runners_test.go` | GitHub Runners | Runner deployment, labels |
| `purview_test.go` | Purview | Account creation, scan rules |
| `cost_management_test.go` | Costs | Budgets, alert thresholds |
| `disaster_recovery_test.go` | DR | Backup vault, retention |
| `defender_test.go` | Defender | Plans enabled, auto-provisioning |
| `external_secrets_test.go` | Ext Secrets | Operator, SecretStore, sync |
| `naming_test.go` | Naming | Convention compliance |
| `integration_test.go` | All | End-to-end cross-module tests |

### 19.3 Padrão de Testes

Cada teste segue o padrão:

1. `t.Parallel()` — Execução paralela
2. Define variáveis Terraform
3. `terraform.Init()` — Inicializa módulo
4. `terraform.Validate()` — Valida sintaxe
5. `terraform.Plan()` — Gera plan
6. Assertions no plan output (nomes, configurações, properties)

---

## 20. Deployment Multi-Cloud

### 20.1 Azure (Primário)

Deployment completo com todos os 15 módulos Terraform:
- **Compute**: AKS, GitHub Runners
- **Storage**: ACR, PostgreSQL, Redis, Backup Vault
- **Security**: Key Vault, Managed Identity, Defender
- **AI**: AI Foundry (GPT-4o, embeddings)
- **Governance**: Purview, Cost Management
- **Networking**: VNet, NSGs, Private Endpoints

### 20.2 AWS (Secundário)

| Azure | AWS Equivalente |
|-------|-----------------|
| AKS | EKS |
| ACR | ECR |
| Key Vault | Secrets Manager |
| Managed Identity | IRSA (IAM Roles for Service Accounts) |
| PostgreSQL Flexible | RDS PostgreSQL |
| Redis Cache | ElastiCache |

### 20.3 GCP (Secundário)

| Azure | GCP Equivalente |
|-------|-----------------|
| AKS | GKE |
| ACR | Artifact Registry |
| Key Vault | Secret Manager |
| Managed Identity | Workload Identity |
| AI Foundry | Vertex AI |

### 20.4 On-Premise

| Azure | On-Premise Equivalente |
|-------|----------------------|
| AKS | OpenShift / k3s |
| ACR | Harbor |
| Key Vault | HashiCorp Vault |
| AI Foundry | Ollama / vLLM |

---

## 21. RHDH — Red Hat Developer Hub

### 21.1 RHDH vs Backstage

| Aspecto | Backstage OSS | RHDH (Red Hat) |
|---------|---------------|----------------|
| Plugins | Code-based (npm build) | Dynamic Plugins (YAML-only) |
| Deployment | Kustomize + custom image | Helm chart padrão |
| RBAC | Básico (Owner model) | Built-in com CSV policies |
| AI | Requer custom plugin | Developer Lightspeed nativo |
| Support | Comunidade | Red Hat Enterprise Support |
| Auth | Configuração manual | Pré-integrado com OAuth |

### 21.2 Dynamic Plugins

No RHDH, plugins são habilitados via YAML sem rebuild:

```yaml
global:
  dynamic:
    includes:
      - dynamic-plugins.default.yaml
    plugins:
      - package: ./dynamic-plugins/dist/backstage-plugin-github-actions
        disabled: false
      - package: ./dynamic-plugins/dist/backstage-plugin-kubernetes
        disabled: false
```

### 21.3 Developer Lightspeed

AI chat integrado ao RHDH usando:
- **LCS (Lightspeed Conversation Service)** — Backend de conversação
- **Llama Stack** — LLM inference
- **RAG** — Retrieval Augmented Generation com docs do projeto
- **BYOM** — Suporte a Azure OpenAI, Ollama, vLLM como modelos alternativos

### 21.4 RBAC Policies

| Role | Permissões |
|------|-----------|
| **Admin** | Tudo (catalog, scaffolder, AI, plugins) |
| **Developer** | Catalog read/write, scaffolder execute, AI chat |
| **Viewer** | Catalog read-only, documentação |

### 21.5 Homepage Customizada

Homepage do RHDH com:
- Quick actions (criar serviço, visualizar catalog)
- Links importantes (ArgoCD, Grafana, docs)
- Status widgets (deployments recentes, alertas)
- Microsoft branding (4-color logo palette)

---

## 22. Métricas e KPIs do Projeto

### 22.1 Recording Rules (Métricas Pré-calculadas)

| Categoria | Métricas |
|-----------|----------|
| **Cluster** | CPU/memory/storage utilization ratios |
| **Applications** | Request rate, error rate, latency (p50/p90/p99) |
| **SLO** | Availability em janelas 5m, 1h, 24h, 30d |
| **GitOps** | ArgoCD app sync success rate, time to sync |
| **AI Agents** | Invocation rate, LLM latency, token usage, error rate |
| **Golden Paths** | Template creation rate, success rate, time to first deploy |
| **Platform Health** | Aggregated health score |

### 22.2 Deploy Times Estimados

| Fase | Tempo |
|------|-------|
| H1 Foundation (Terraform) | ~45 minutos |
| H2 Enhancement (ArgoCD + RHDH) | ~30 minutos |
| H3 Innovation (AI + Agents) | ~15 minutos |
| **Total** | **~90 minutos** |

---

## 23. Histórico de Versões

### v4.0.0 (2025-12-15) — Current

Adições massivas:
- 15 módulos Terraform completos
- 17 agentes GitHub Copilot com handoffs
- 22 Golden Path templates
- 13 MCP servers
- 3 Grafana dashboards
- 50+ alert rules + 40+ recording rules
- 6 Gatekeeper constraint templates
- 16 Terratest suites
- 23 issue templates
- 9 GitHub Actions workflows
- Scripts de deploy, validação, setup e onboarding

### v3.0.0 (2025-06-01)

- Arquitetura Three Horizons inicial
- 8 módulos Terraform
- ArgoCD com App-of-Apps
- 5 Golden Paths básicos
- Prometheus + Grafana base

### v2.0.0 (2025-01-15)

- Módulos Azure infrastructure
- AKS + Networking + ACR + Databases + Key Vault
- CI pipeline básico

### v1.0.0 (2024-09-01)

- Release inicial
- Terraform base para AKS
- Documentação inicial

---

## 24. Referências e Links

### Documentação Oficial

- [Red Hat Developer Hub 1.8 Documentation](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.8)
- [Backstage.io](https://backstage.io)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io)
- [Terraform AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm)
- [GitHub Copilot Agents](https://docs.github.com/en/copilot)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io)
- [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper)
- [Terratest](https://terratest.gruntwork.io)

### Equipes Responsáveis (CODEOWNERS)

| Área | Time |
|------|------|
| Default | @platform-team |
| Terraform | @platform-team @infra-team |
| Kubernetes/Helm | @platform-team @devops-team |
| Golden Paths | @platform-team + times por horizonte |
| Security | @security-team |
| AI Agents/MCP | @platform-team @ai-team |
| Documentation | @platform-team @docs-team |

### Contatos de Segurança

- **Email**: security@three-horizons.dev
- **Vulnerabilidades**: Reportar via processo descrito em SECURITY.md
- **Severidade**: Critical (< 24h), High (< 48h), Medium (< 1 semana), Low (próximo sprint)

---

> **Documento gerado em**: 2026-02-28
> **Fonte**: Análise completa do repositório `agentic-devops-platform/`
> **Cobertura**: 900+ arquivos, 80.000+ linhas de código, 15 módulos Terraform, 17 agentes AI, 22 Golden Paths, 13 MCP servers
