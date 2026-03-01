# Three Horizons Model

The Three Horizons model is the maturity framework that guides the incremental adoption of the Agentic DevOps Platform. Each horizon builds on the previous one, allowing organizations to start with foundational infrastructure and progressively add platform services and AI capabilities.

## H1 -- Foundation

**Goal**: Establish a secure, production-ready Azure infrastructure baseline.

H1 provides the core cloud infrastructure that all subsequent horizons depend on. It is deployed using Terraform with strict security defaults and compliance policies.

**Components**:

- **Azure Kubernetes Service (AKS)** -- Kubernetes 1.29+ with Calico network policy, Workload Identity, and auto-scaling (system + user node pools)
- **Networking** -- VNet with dedicated subnets for AKS nodes, pods, private endpoints, bastion, and Application Gateway; NSGs with deny-by-default rules
- **Azure Key Vault** -- RBAC-based access, soft delete, purge protection, TLS 1.2+ enforcement
- **PostgreSQL Flexible Server** -- Version 16 with geo-redundant backup and private endpoints
- **Redis Cache** -- TLS 1.2+ enforced, private endpoint connectivity
- **Azure Container Registry** -- Integrated with AKS via AcrPull role assignment
- **Microsoft Defender** -- Container and cloud security posture management
- **Disaster Recovery** -- Backup Vault with cross-region replication

**Golden Path Templates** (6): basic-cicd, security-baseline, documentation-site, web-application, new-microservice, infrastructure-provisioning

## H2 -- Enhancement

**Goal**: Layer platform services on top of H1 to deliver a self-service developer experience.

H2 transforms raw infrastructure into a platform with automated deployments, an internal developer portal, and comprehensive observability.

**Components**:

- **Red Hat Developer Hub (RHDH) 1.8** -- Backstage-based IDP with dynamic plugins, built-in RBAC, and TechDocs
- **ArgoCD 5.51.0** -- GitOps with App-of-Apps pattern, sync waves, and environment-specific policies
- **External Secrets Operator 0.9.9** -- Syncs Azure Key Vault secrets to Kubernetes via Workload Identity
- **Prometheus + Grafana + Alertmanager** -- Full observability with 50+ alert rules and 3 dashboards
- **Jaeger** -- Distributed tracing for microservice architectures
- **OPA Gatekeeper** -- 5 constraint templates for Kubernetes policy enforcement
- **GitHub Actions Self-Hosted Runners** -- ARC-based runners on AKS

**Golden Path Templates** (9): microservice, api-microservice, event-driven-microservice, data-pipeline, batch-job, api-gateway, gitops-deployment, ado-to-github-migration, reusable-workflows

## H3 -- Innovation

**Goal**: Integrate AI capabilities to amplify developer productivity and automate platform operations.

H3 adds intelligent agents, AI-assisted development, and machine learning infrastructure to the platform.

**Components**:

- **Azure AI Foundry** -- GPT-4o, GPT-4o-mini, text-embedding-3-large, AI Search, Content Safety
- **18 GitHub Copilot Chat Agents** -- Specialized agents with handoff orchestration (architect, platform, devops, sre, terraform, security, and more)
- **14 MCP Servers** -- Model Context Protocol servers for AI-tool communication
- **Developer Lightspeed** -- AI chat in RHDH using Llama Stack + RAG with Azure OpenAI backend
- **Microsoft Purview** -- Data governance and cataloging
- **Engineering Intelligence** -- DORA metrics, Copilot analytics, GHAS security posture dashboards

**Golden Path Templates** (8): foundry-agent, sre-agent-integration, mlops-pipeline, multi-agent-system, copilot-extension, rag-application, ai-evaluation-pipeline, engineering-intelligence-dashboard

## Adoption Path

Organizations typically progress through the horizons over 3-6 months:

1. **Weeks 1-4**: Deploy H1 Foundation with `express` or `standard` mode
2. **Weeks 5-10**: Enable H2 services (ArgoCD, RHDH, observability) and onboard teams
3. **Weeks 11-16+**: Activate H3 AI features and Engineering Intelligence dashboards
