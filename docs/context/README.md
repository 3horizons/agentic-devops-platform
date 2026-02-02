# Three Horizons Accelerator - Context Documentation

> Project context and reference documentation for complete validation, deployment, integration, and configuration.

## Purpose

This folder contains essential context documentation that provides:

1. **Project Understanding** - Goals, scope, and business value
2. **Technology Reference** - Complete tech stack with versions and integrations
3. **Architecture Decisions** - Agent architecture, platform choices, and design patterns
4. **Deployment Guidance** - Integration requirements and configuration steps
5. **Validation Criteria** - How to validate successful implementation

## Documents

| Document | Purpose |
|----------|---------|
| [Project Goals](./project-goals.md) | Business objectives, success criteria, and scope definition |
| [Tech Stack](./tech-stack.md) | Complete technology inventory with versions and integrations |
| [Agent Architecture](./agent-architecture.md) | AI agent design, execution modes, and orchestration patterns |
| [Platform Choices](./platform-choices.md) | AKS vs ARO decision matrix and configuration differences |
| [Deployment Integration](./deployment-integration.md) | Step-by-step integration with Red Hat, Microsoft, and GitHub |
| [Validation Checklist](./validation-checklist.md) | Complete validation criteria for each horizon |

## Usage

### For Implementation Teams

1. Start with [Project Goals](./project-goals.md) to understand the business context
2. Review [Tech Stack](./tech-stack.md) for required tools and versions
3. Use [Platform Choices](./platform-choices.md) to decide between AKS and ARO
4. Follow [Deployment Integration](./deployment-integration.md) for step-by-step setup
5. Validate using [Validation Checklist](./validation-checklist.md)

### For AI Agents

These documents provide context for intelligent deployment orchestration:

- Agents reference these files for configuration decisions
- MCP servers use this context for command execution
- Validation agents verify against success criteria defined here

## Partners

This accelerator is a joint initiative between:

| Partner | Role |
|---------|------|
| **Microsoft** | Azure infrastructure, AI Foundry, GitHub integration |
| **Red Hat** | OpenShift (ARO), Developer Hub (RHDH), enterprise support |
| **GitHub** | Actions, Copilot, repository management, issue tracking |

## Related Documentation

- [Main README](../../README.md) - Quick start and overview
- [Architecture Guide](../guides/ARCHITECTURE_GUIDE.md) - Detailed architecture
- [Deployment Guide](../guides/DEPLOYMENT_GUIDE.md) - Step-by-step deployment
- [Agent README](../../agents/README.md) - AI agent specifications

---

**Last Updated:** February 2026  
**Version:** 4.0.0
