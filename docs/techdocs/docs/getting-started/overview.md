# Platform Overview

The **Three Horizons Agentic DevOps Platform** is an enterprise-grade Internal Developer Platform (IDP) built on Red Hat Developer Hub (RHDH), powered by Azure cloud infrastructure, and enhanced with AI-driven automation through GitHub Copilot and MCP servers.

## The Three Horizons Model

The platform follows a maturity-based delivery model organized into three horizons:

- **H1 -- Foundation**: Core Azure infrastructure including AKS clusters, networking, databases, security, and disaster recovery. This is your production-ready baseline.
- **H2 -- Enhancement**: Platform services such as ArgoCD for GitOps, RHDH for the developer portal, observability with Prometheus and Grafana, Golden Path templates, and self-hosted GitHub runners.
- **H3 -- Innovation**: AI capabilities including Azure AI Foundry, GitHub Copilot agents, MCP servers for AI-tool communication, and Developer Lightspeed for in-portal AI chat.

## What RHDH Provides

Red Hat Developer Hub serves as the central developer portal, offering:

- **Software Catalog** -- Discover and manage all services, APIs, and infrastructure components
- **Golden Path Templates** -- 23 pre-built templates spanning H1, H2, and H3 workloads
- **TechDocs** -- Integrated documentation rendered directly in the portal
- **Dynamic Plugins** -- Enable or disable capabilities via YAML without rebuilding
- **Developer Lightspeed** -- AI-assisted chat powered by Llama Stack and Azure OpenAI
- **RBAC** -- Built-in role-based access control with Admin, Developer, and Viewer roles

## Key Features

| Feature | Description |
|---------|-------------|
| Infrastructure as Code | 15 Terraform modules with three deployment modes (express, standard, enterprise) |
| GitOps | ArgoCD App-of-Apps pattern with sync wave orchestration |
| AI Agents | 18 GitHub Copilot Chat agents with handoff orchestration |
| Observability | 50+ Prometheus alert rules, 3 Grafana dashboards, Jaeger tracing |
| Security | OPA Gatekeeper policies, Workload Identity, private endpoints, TLS 1.2+ |
| CI/CD | 10 GitHub Actions workflows with self-hosted runner support |
| Compliance | LGPD-first (Brazil South region), SOC 2, PCI-DSS, CIS benchmarks |

## Deployment Modes

| Mode | Nodes | Use Case |
|------|-------|----------|
| **Express** | 3 | Development and testing |
| **Standard** | 5 | Production with HA |
| **Enterprise** | 10 | Multi-zone, full HA, all features enabled |

## Next Steps

- Follow the [Quick Start](quick-start.md) to get hands-on with the portal
- Review the [Architecture](../architecture/three-horizons.md) for deeper technical details
- Explore [Golden Path Templates](../development/golden-paths.md) to create your first service
