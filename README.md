# 🚀 Three Horizons Accelerator v4.0.0

> **Enterprise Platform Engineering with Agentic DevOps**

[![Version](https://img.shields.io/badge/version-4.0.0-blue.svg)](./CHANGELOG.md)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](./LICENSE)
[![Azure](https://img.shields.io/badge/Azure-Ready-0078D4.svg)](https://azure.microsoft.com)
[![GitHub](https://img.shields.io/badge/GitHub-Actions-181717.svg)](https://github.com/features/actions)

## 🎯 What is This?

The Three Horizons Accelerator is a **complete enterprise platform** that combines:

1. **Production-Ready Infrastructure** - 12 Terraform modules, GitOps, observability
2. **AI-Powered Orchestration** - 20 intelligent agents for automated deployments
3. **Developer Experience** - 21 Golden Path templates for self-service

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| 🤖 **20 AI Agents** | Intelligent deployment orchestration via GitHub Issues |
| 🏗️ **12 Terraform Modules** | AKS, networking, security, databases, AI Foundry, Defender, Purview |
| 📐 **T-Shirt Sizing** | S/M/L/XL profiles with automatic cost estimation |
| 🌎 **LATAM Optimized** | Brazil South, East US 2, South Central US regions |
| 🛡️ **Enterprise Security** | Defender for Cloud, Purview, RBAC, Private Endpoints |
| 📊 **Full Observability** | Azure Managed Prometheus + Grafana |
| 🔄 **GitOps Ready** | ArgoCD with ApplicationSets |
| 🎨 **21 Golden Paths** | Backstage/RHDH templates for all horizons |

## 🚀 Quick Start

### Option 1: GitHub Issues + AI Agent

1. Fork this repository
2. Open an issue using any template (e.g., `Full Platform Deployment`)
3. GitHub Copilot / AI agent executes the deployment

### Option 2: Bootstrap Script

```bash
# Clone
git clone https://github.com/YOUR_ORG/three-horizons-accelerator.git
cd three-horizons-accelerator

# Configure
cp customer-config/customer.tfvars.example customer-config/customer.tfvars
vim customer-config/customer.tfvars

# Deploy
./scripts/bootstrap.sh standard
```

## 📐 Sizing Profiles

| Profile | AKS Nodes | Database | AI Models | Est. Cost/mo |
|---------|-----------|----------|-----------|--------------|
| **Small** | 3x D4s | Basic PostgreSQL | GPT-4o-mini | $2,000-3,000 |
| **Medium** | 6x D4s | Standard PostgreSQL | GPT-4o | $5,000-8,000 |
| **Large** | 9x D8s | Premium HA | Full AI Suite | $15,000-25,000 |
| **XLarge** | 12x D16s | Geo-Replicated | Enterprise AI | $40,000-60,000 |

## 🌎 LATAM Regions

| Region | Use Case | AI Support | Data Residency |
|--------|----------|------------|----------------|
| **Brazil South** | Brazilian clients | Limited (GPT-4, 3.5) | LGPD ✅ |
| **East US 2** | Full AI capabilities | Full (GPT-4o, o3-mini) | - |
| **South Central US** | Mexico/Central America | Full | - |

**Recommended Pattern:** Brazil South (data) + East US 2 (AI via Private Link)

## 📁 Repository Structure

```
├── agents/           # 20 AI agent specifications
├── terraform/        # 12 infrastructure modules
├── argocd/          # GitOps configuration
├── golden-paths/    # 21 developer templates
├── config/          # Sizing & region configs
├── scripts/         # Automation scripts
├── .github/         # 21 issue templates
└── mcp-servers/     # 13 MCP configurations
```

## 🛡️ Security Components

- **Defender for Cloud** - CSPM, container scanning, regulatory compliance
- **Microsoft Purview** - Data catalog, LATAM classifications (CPF, CNPJ, RUT, RFC)
- **Azure Key Vault** - Secrets with workload identity
- **Private Endpoints** - All services behind private network
- **RBAC** - Azure AD integration

## 📚 Documentation

- [Enterprise Review](./ENTERPRISE_REVIEW.md) - Architecture decisions
- [Inventory](./INVENTORY_v4.md) - Complete component list
- [Agent Catalog](./AGENT_CATALOG.md) - AI agent documentation
- [Sizing Profiles](./config/sizing-profiles.yaml) - Cost estimation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

MIT License - see [LICENSE](./LICENSE)

---

**Built with ❤️ for LATAM Enterprise Platform Engineering**
