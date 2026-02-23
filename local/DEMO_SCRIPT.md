# Three Horizons Accelerator — Demo Script

> **Duração total:** 45–60 minutos
> **Público-alvo:** Enterprise architects, CTOs, engineering leads, platform teams
> **Requisitos:** Cluster kind rodando (`make -C local up`), VS Code com GitHub Copilot Chat

---

## Números da Plataforma

Abra com esses números para estabelecer credibilidade:

| Asset | Quantidade |
|-------|-----------|
| Copilot Chat Agents | **11** |
| Golden Path Templates | **22** (6 H1 + 9 H2 + 7 H3) |
| Operational Skills | **18** |
| Terraform Modules | **16** |
| Reusable Prompts | **7** |
| Chat Modes | **3** |
| Issue Templates | **28** |
| Code-Gen Instructions | **3** |
| Total de arquivos | **120+** |
| Linhas de código | **~20.000** |

---

## Ato 1 — Abertura + Visão Geral (5 min)

### Objetivo
Contextualizar a plataforma e sua arquitetura de 3 horizontes.

### Talking Points

> "O Three Horizons Accelerator é um kit de aceleração enterprise-grade criado em parceria com Microsoft, GitHub e Red Hat. Ele implementa o conceito de 3 Horizontes de Inovação aplicado a uma plataforma de engenharia moderna."

> "O diferencial: **13 AI agents** especializados que operam dentro do VS Code via GitHub Copilot Chat. Cada agent tem um papel definido — deploy, arquitetura, segurança, SRE, DevOps — com boundaries claros sobre o que podem e não podem fazer."

### O que mostrar

1. **Estrutura do repositório** — Abrir VS Code, mostrar `.github/agents/` com os 13 agents
2. **Golden Paths** — Navegar `golden-paths/` mostrando as 3 pastas (h1, h2, h3)
3. **README.md** — Scroll rápido pela documentação principal

### Comandos

```bash
# Mostrar estrutura no terminal
tree -L 2 .github/agents/
tree -L 1 golden-paths/
```

---

## Ato 2 — Deploy com @deploy Agent (10 min)

### Objetivo
Demonstrar que um AI agent orquestra o deployment completo de infraestrutura.

### Setup Prévio
- Cluster kind rodando: `kind get clusters` → `three-horizons-demo`
- Todos os componentes instalados: `make -C local status`
- Se preciso recomeçar do zero: `make -C local reset`

### Sequência

#### Passo 1: Chamar o agent

No **Copilot Chat** do VS Code, digitar:

```
@deploy Show me the deployment status of the local demo
```

**O que acontece:** O agent verifica o cluster, lista pods, mostra saúde dos componentes.

**Talking Point:**
> "O @deploy agent é um orquestrador de deployment. Ele valida prerequisites, executa cada fase em ordem, e verifica a saúde entre cada etapa. Se algo falha, ele faz handoff para o @terraform ou @sre agent."

#### Passo 2: Validação com o agent

```
@deploy Validate the local deployment — check all components are healthy
```

**O que acontece:** O agent roda `kubectl get pods -A`, verifica serviços, mostra status ✅/❌.

#### Passo 3: Mostrar as 3 opções de deploy

```
@deploy How can I deploy the Three Horizons platform?
```

**O que acontece:** O agent apresenta as 4 opções:
- **Option A:** Agent-guided (interativo)
- **Option B:** Script automatizado (`deploy-full.sh`)
- **Option C:** Manual (step-by-step)
- **Option D:** Local Demo (`deploy-local.sh`)

**Talking Point:**
> "4 formas de deployment. O mesmo accelerator cobre desde demo local até produção enterprise multi-região. A Option D é o que estamos usando agora — zero dependência de Azure."

#### Fallback
Se o agent não reconhecer "local demo", usar diretamente:
```bash
make -C local validate
```

---

## Ato 3 — Portal RHDH + Developer Experience (10 min)

### Objetivo
Mostrar o portal self-service com catálogo de serviços e 22 templates.

### Setup Prévio
- RHDH rodando: `make -C local rhdh` (ou se não estiver instalado, mostrar screenshots/mockup)
- Browser aberto em `http://localhost:7007`

### Sequência (se RHDH estiver rodando)

#### Passo 1: Catálogo de Software
1. Abrir `http://localhost:7007` no browser
2. Mostrar a página inicial — catálogo de componentes
3. Clicar em um componente — mostrar metadata, owner, dependências

#### Passo 2: Templates (Software Templates)
1. Navegar para **Create** → **Templates**
2. Mostrar os templates organizados por horizonte:
   - **H1 Foundation**: Web Application, Basic CI/CD, Security Baseline
   - **H2 Enhancement**: API Microservice, Data Pipeline, ADO Migration, Event-Driven
   - **H3 Innovation**: Foundry Agent, RAG Application, MLOps, Multi-Agent System

**Talking Point:**
> "22 templates prontos. Um developer escolhe, preenche um formulário, e em 2 minutos tem: repositório GitHub, CI/CD, manifests Kubernetes, ArgoCD Application, e registro no catálogo. Zero configuração manual."

#### Passo 3: Scaffold de um serviço (live demo)
1. Clicar em **"H2: Create API Microservice"**
2. Preencher: nome (`demo-api`), owner (`platform-team`), language (`Python`)
3. Mostrar o preview do que será criado

### Sequência alternativa (sem RHDH)

Se RHDH não estiver instalado, usar o **@platform agent**:

```
@platform Show me all available Golden Path templates and what each one scaffolds
```

E mostrar os template.yaml diretamente:
```
@platform Explain the API Microservice Golden Path template
```

**Talking Point:**
> "Mesmo sem o portal visual, os agents dão acesso completo aos templates. O @platform agent conhece cada um dos 22 Golden Paths."

---

## Ato 4 — Multi-Agent Workflow Chain (10 min)

### Objetivo
**O grande diferencial.** Mostrar 5 agents trabalhando em cadeia numa tarefa real.

### Cenário
> "Um developer precisa adicionar suporte a Cosmos DB na plataforma."

### Sequência

#### Passo 1: @architect — Design

```
@architect Design a Cosmos DB integration for the Three Horizons platform. Consider multi-region, consistency levels, and partition strategy for a high-throughput order processing system.
```

**O que acontece:** O agent produz:
- Diagrama Mermaid da arquitetura
- Decisões de design (consistency level, partition key)
- Trade-offs documentados
- Cita o Azure Well-Architected Framework

**Talking Point:**
> "O @architect não é um chatbot genérico — ele segue o Azure WAF, produz diagramas Mermaid, e estrutura a resposta em Context → Options → Recommendation → Trade-offs."

#### Passo 2: @terraform — Implementação

```
@terraform Create a Terraform module for Cosmos DB following the architect's design above. Use the project's module conventions.
```

**O que acontece:** O agent gera:
- `main.tf` com `azurerm_cosmosdb_account`
- `variables.tf` com validações
- `outputs.tf`
- Segue naming conventions do projeto

#### Passo 3: @security — Security Review

```
@security Review the Cosmos DB Terraform module for security best practices
```

**O que acontece:** O agent identifica:
- Network rules e private endpoints
- Encryption at rest e in transit
- RBAC vs Access Keys
- Diagnostic settings
- Feedback com severidade: 🔴 Critical / 🟡 Major / 🟢 Minor

**Talking Point:**
> "O @security tem boundaries NEVER — ele nunca permite bypass de security review. Se encontra um Critical, bloqueia o fluxo e exige correção."

#### Passo 4: @test — Testes

```
@test Generate tests for the Cosmos DB Terraform module
```

**O que acontece:** O agent gera:
- `terraform validate` test
- `terraform plan` test
- Input validation tests
- Naming convention tests

#### Passo 5: @reviewer — Code Review

```
@reviewer Review all the Cosmos DB code we just created for quality and best practices
```

**O que acontece:** O agent faz review completo:
- Severity-tagged (🔴🟡🟢)
- Checklists de qualidade
- Sugestões de melhoria

**Talking Point:**
> "5 agents. 5 perspectivas diferentes. Design → Implementação → Segurança → Testes → Review. Cada um com expertise específica, e todos operando dentro do VS Code. Essa cadeia de handoffs é o que diferencia o Three Horizons de um simples copilot."

---

## Ato 5 — Observabilidade + SRE Agent (10 min)

### Objetivo
Mostrar dashboards ao vivo e demonstrar incident response com AI.

### Setup Prévio
- Grafana: `make -C local grafana` → abrir `http://localhost:3000`
- Prometheus: `make -C local prometheus` → abrir `http://localhost:9090`

### Sequência

#### Passo 1: Grafana Dashboards

No browser (`http://localhost:3000`, login `admin`/`admin`):

1. **Dashboard de cluster** — mostrar nodes, CPU, RAM, pods
2. **Dashboard Three Horizons** (se importado) — mostrar dashboards customizados
3. Mostrar que sidecar auto-descobre dashboards via labels

**Talking Point:**
> "Dashboards prontos para produção. O accelerator inclui dashboards para cluster health, application RED/USE metrics, ArgoCD sync status, e AI agent metrics. O Grafana sidecar descobre novos dashboards automaticamente via labels."

#### Passo 2: Prometheus

No browser (`http://localhost:9090`):

1. Mostrar **Targets** — todos UP (kube-state-metrics, node-exporter, etc.)
2. Mostrar **Alerts** — regras ThreeHorizonsHighErrorRate, ThreeHorizonsSlowResponse
3. Executar uma query PromQL: `up{job="kubelet"}`

#### Passo 3: @sre Agent — Incident Response

```
@sre We're seeing high latency on the ArgoCD server. Investigate and provide a root cause analysis.
```

**O que acontece:** O agent faz:
1. Classificação SEV (SEV3 neste caso)
2. Verifica pods ArgoCD: `kubectl get pods -n argocd`
3. Analisa métricas: sugere queries PromQL específicas
4. Hipóteses: resource constraints, repo sync issues, etc.
5. Ações recomendadas
6. Template de post-mortem

**Talking Point:**
> "O @sre agent não dá respostas genéricas. Ele classifica por severidade (SEV1-4), gera PromQL queries específicas para o diagnóstico, e produz um template de post-mortem com timeline, root cause, e action items."

#### Passo 4: SRE Chat Mode

Mudar para o **Chat Mode SRE** (se disponível):

```
Define SLOs for ArgoCD: sync latency P99 < 30s, availability 99.9%
```

**O que acontece:** Produz tabela de SLO framework com budget calculations.

---

## Ato 6 — Golden Path Scaffolding Live (5–10 min)

### Objetivo
Demonstrar o loop completo: template → código → deploy → observável.

### Sequência

#### Passo 1: @platform — Explorar templates

```
@platform List all H3 Innovation Golden Path templates with a brief description of each
```

**O que acontece:** Lista os 7 templates H3:
- Foundry Agent (RAG + safety + human-in-the-loop)
- RAG Application
- MLOps Pipeline
- Multi-Agent System
- AI Evaluation Pipeline
- Copilot Extension
- SRE Agent Integration

**Talking Point:**
> "Do H1 básico ao H3 inovação com AI. Um developer pode criar um AI Agent com RAG, content safety, e human-in-the-loop preenchendo um formulário. Todo o scaffolding — incluindo segurança, CI/CD, e observação — é gerado automaticamente."

#### Passo 2: @devops — GitOps

```
@devops Explain how a new service from a Golden Path template gets deployed via ArgoCD in this platform
```

**O que acontece:** O agent explica o fluxo GitOps completo:
1. Template scaffold → GitHub repo
2. ArgoCD ApplicationSet detecta novo repo
3. Auto-sync para environment dev
4. Prometheus scraping automático via annotations

#### Passo 3: Mostrar ArgoCD

Abrir ArgoCD (`https://localhost:8443`):
- Mostrar Applications list
- Mostrar sync status
- Explicar o pattern App-of-Apps

---

## Encerramento (5 min)

### Talking Points Finais

> "O que vocês viram hoje:"

1. **13 AI agents** cobrindo todo o lifecycle: architect → terraform → security → devops → test → reviewer → sre → deploy → platform → docs → onboarding

2. **22 Golden Path templates** de H1 Foundation a H3 AI Innovation — incluindo ADO para GitHub migration, Foundry Agents, RAG apps

3. **Cadeia multi-agent** — o verdadeiro diferencial. Não é um chatbot. São 11 especialistas com roles, boundaries, skills, e handoffs definidos

4. **Zero a plataforma completa** em um comando: `make -C local up`

5. **O mesmo accelerator** escala: demo local ($0) → dev ($50/mês) → enterprise multi-region ($3000+/mês)

### Call to Action

> "Tudo está no repositório. 120+ arquivos, 20.000+ linhas de código production-ready. A demo que vocês viram roda em qualquer Mac ou Linux com Docker."

---

## Apêndice: Comandos Rápidos por Ato

| Ato | Comandos |
|-----|----------|
| 1 | `tree -L 2 .github/agents/` |
| 2 | `@deploy Show deployment status` |
| 3 | `http://localhost:7007` ou `@platform Show Golden Paths` |
| 4 | `@architect` → `@terraform` → `@security` → `@test` → `@reviewer` |
| 5 | `http://localhost:3000`, `@sre Investigate latency` |
| 6 | `@platform List H3 templates`, `https://localhost:8443` |

## Apêndice: Fallbacks

| Se isso falhar... | Faça isso |
|--------------------|-----------|
| Agent não responde | Use o comando bash diretamente |
| RHDH não carrega | Mostre os template.yaml no VS Code |
| Grafana sem dados | Espere 2 min para scraping, use `kubectl top nodes` |
| ArgoCD timeout | `make argocd` (port-forward manual) |
| Pods Pending | `kubectl describe pod -n <ns>` — provavelmente falta RAM |
| Cluster não sobe | Aumentar RAM Docker Desktop para 16GB+ |
