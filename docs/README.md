# Three Horizons Accelerator - Documentation

> **A solution created in partnership with Microsoft, GitHub, and Red Hat**
>
> **Version:** 4.0.0 | **Last Updated:** December 2025

---

## Quick Navigation

| I want to... | Go to... |
| :--- | :--- |
| **Deploy the platform from scratch** | [Deployment Guide](guides/DEPLOYMENT_GUIDE.md) |
| **Understand the architecture** | [Architecture Guide](guides/ARCHITECTURE_GUIDE.md) |
| **Manage the platform day-to-day** | [Administrator Guide](guides/ADMINISTRATOR_GUIDE.md) |
| **Fix a problem** | [Troubleshooting Guide](guides/TROUBLESHOOTING_GUIDE.md) |
| **Learn about Terraform modules** | [Module Reference](guides/MODULE_REFERENCE.md) |

---

## Documentation Index

### Getting Started

| Document | Description | Audience |
| :--- | :--- | :--- |
| [README](../README.md) | Project overview and quick start | Everyone |
| [CONTRIBUTING](../CONTRIBUTING.md) | How to contribute | Contributors |

### Comprehensive Guides

| Guide | Description | Pages |
| :--- | :--- | :--- |
| [Deployment Guide](guides/DEPLOYMENT_GUIDE.md) | Complete step-by-step deployment from Step 1 to production | ~50 |
| [Architecture Guide](guides/ARCHITECTURE_GUIDE.md) | System architecture, diagrams, and design decisions | ~40 |
| [Administrator Guide](guides/ADMINISTRATOR_GUIDE.md) | Day-2 operations, scaling, backup, monitoring | ~40 |
| [Troubleshooting Guide](guides/TROUBLESHOOTING_GUIDE.md) | Common issues and solutions | ~35 |
| [Module Reference](guides/MODULE_REFERENCE.md) | Terraform module documentation | ~30 |

### Reference Documentation

| Document | Description |
|----------|-------------|
| [Branching Strategy](BRANCHING_STRATEGY.md) | Git workflow and branch protection |
| [Copilot Agents Playbook](../AGENTS.md) | **Interactive Chat Agents** (VS Code) |
| [Deployment Agents Index](../agents/README.md) | **Automation Agents** (IssueOps) |

### Agent Documentation

Located in `/agents/`:

| Horizon | Agents |
|---------|--------|
| H1 Foundation | infrastructure, networking, database, security, defender, purview, container-registry, aro-platform |
| H2 Enhancement | gitops, RHDH-portal, golden-paths, observability, GitHub-runners |
| H3 Innovation | ai-foundry, mlops-pipeline, sre-agent, multi-agent-setup |
| Cross-Cutting | GitHub-app, identity-federation, validation, migration, rollback, cost-optimization |

---

## Guide Overview

### 1. Deployment Guide

**File:** [guides/DEPLOYMENT_GUIDE.md](guides/DEPLOYMENT_GUIDE.md)

Complete step-by-step instructions for deploying the Three Horizons platform:

```
Step 1:  Azure Environment Setup (30 min)
Step 2:  GitHub Organization Setup (15 min)
Step 3:  Clone and Initial Configuration (15 min)
Step 4:  Deploy H1 Foundation (30 min)
Step 5:  Verify H1 Foundation (15 min)
Step 6:  Deploy H2 Enhancement (30 min)
Step 7:  Verify H2 Enhancement (15 min)
Step 8:  Deploy H3 Innovation (30 min) - Optional
Step 9:  Final Platform Verification (30 min)
Step 10: Post-Deployment Configuration (30 min)
```

**Includes:**

- Prerequisites checklist
- Command examples with expected outputs
- Verification procedures
- File and directory references
- Rollback procedures

---

### 2. Architecture Guide

**File:** [guides/ARCHITECTURE_GUIDE.md](guides/ARCHITECTURE_GUIDE.md)

Comprehensive architecture documentation:

- Three Horizons Model (H1/H2/H3)
- Infrastructure Architecture (AKS, networking)
- Network Topology (VNets, subnets, NSGs)
- Security Architecture (Zero Trust, Workload Identity)
- GitOps Architecture (ArgoCD, sync waves)
- Observability Architecture (Prometheus, Grafana)
- AI/ML Architecture (Azure OpenAI, LATAM strategy)
- Agent Orchestration Model
- Data Flow Diagrams

---

### 3. Administrator Guide

**File:** [guides/ADMINISTRATOR_GUIDE.md](guides/ADMINISTRATOR_GUIDE.md)

Day-2 operations manual:

- Daily health checks
- Monitoring and alerting
- Scaling operations (manual and auto)
- Backup and recovery (Velero)
- Secret management
- User management (RBAC)
- Certificate management
- Cost management
- Security operations
- Maintenance windows
- Incident response
- Common runbook procedures

---

### 4. Troubleshooting Guide

**File:** [guides/TROUBLESHOOTING_GUIDE.md](guides/TROUBLESHOOTING_GUIDE.md)

Problem-solving reference:

- Quick diagnostics script
- Terraform issues
- AKS cluster issues (nodes, pods)
- ArgoCD issues (sync, health)
- Networking issues
- External Secrets issues
- Observability issues
- AI Foundry issues
- Authentication issues
- Performance issues
- Common error messages reference
- Support escalation procedures

---

### 5. Module Reference

**File:** [guides/MODULE_REFERENCE.md](guides/MODULE_REFERENCE.md)

Terraform module documentation:

- Standard module structure
- All input variables with types and defaults
- All outputs with descriptions
- Usage examples
- Module dependencies graph
- Minimal and full deployment examples

**Modules covered:**

- naming
- networking
- aks-cluster
- container-registry
- databases
- security
- defender
- purview
- observability
- ArgoCD
- external-secrets
- GitHub-runners
- cost-management
- disaster-recovery
- ai-foundry

---

## Document Structure

```
docs/
├── README.md                    # This index file
├── BRANCHING_STRATEGY.md        # Git workflow
│
└── guides/
    ├── DEPLOYMENT_GUIDE.md      # Step-by-step deployment
    ├── ARCHITECTURE_GUIDE.md    # System architecture
    ├── ADMINISTRATOR_GUIDE.md   # Operations manual
    ├── TROUBLESHOOTING_GUIDE.md # Problem solving
    └── MODULE_REFERENCE.md      # Terraform modules
```

---

## How to Use This Documentation

### New to the Project

1. Read the [README](../README.md) for an overview
2. Study the [Architecture Guide](guides/ARCHITECTURE_GUIDE.md) to understand the system

### Deploying for Production

1. Complete the [Deployment Guide](guides/DEPLOYMENT_GUIDE.md) step by step
2. Reference the [Module Reference](guides/MODULE_REFERENCE.md) for customization
3. Set up operations using the [Administrator Guide](guides/ADMINISTRATOR_GUIDE.md)

### Operating the Platform

1. Use the [Administrator Guide](guides/ADMINISTRATOR_GUIDE.md) daily
2. Reference the [Troubleshooting Guide](guides/TROUBLESHOOTING_GUIDE.md) for issues
3. Check [Agent Documentation](../agents/README.md) for automation

### Contributing

1. Read [CONTRIBUTING](../CONTRIBUTING.md)
2. Follow [Branching Strategy](BRANCHING_STRATEGY.md)
3. Check the [Architecture Guide](guides/ARCHITECTURE_GUIDE.md)

---

## Documentation Standards

### Writing Guidelines

- Use clear, concise language
- Include command examples with expected outputs
- Provide file paths for all referenced files
- Include diagrams for complex concepts
- Keep all content in English
- Update version and date on changes

### Code Blocks

```bash
# Commands should be copy-pasteable
kubectl get pods -n my-namespace
```

### File References

When referencing files, use the format:

- **Absolute:** `/terraform/modules/aks-cluster/main.tf`
- **Relative:** `../terraform/modules/aks-cluster/main.tf`

### Version Updates

When updating documentation:

1. Update the "Last Updated" date
2. Update the document version if significant changes
3. Add to CHANGELOG if applicable

---

## Feedback

Found an issue or want to improve the documentation?

- Open an issue: [GitHub Issues](https://github.com/paulanunes85/three-horizons-accelerator-v4/issues)
- Submit a PR: Follow [CONTRIBUTING](../CONTRIBUTING.md)

---

**Maintained by:** Platform Engineering Team
**License:** MIT
