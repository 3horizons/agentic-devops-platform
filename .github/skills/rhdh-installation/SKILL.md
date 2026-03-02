---
name: rhdh-installation
description: "RHDH installation and initial setup reference — covers Azure AKS, OpenShift, first instance configuration, sizing, and prerequisites. ALWAYS consult these docs before installing, upgrading, or troubleshooting RHDH deployment issues."
---

# RHDH Installation & Setup Skill

This skill provides the official Red Hat documentation for installing, setting up, and configuring your first RHDH instance. **Always consult these references before performing any installation, upgrade, or initial setup of the RHDH portal.**

## When to Use This Skill

- Installing RHDH on Azure AKS or OpenShift Container Platform
- Setting up and configuring a first RHDH instance
- Troubleshooting installation failures (pods, Helm chart, networking)
- Upgrading RHDH to a new version
- Understanding RHDH architecture and sizing requirements
- Onboarding new teams to the portal

## Mandatory Rule

> **ALWAYS** read the relevant official documentation below **BEFORE** recommending installation steps, troubleshooting deployment issues, or guiding first-time setup. Never rely solely on memorized knowledge — the official docs contain version-specific details, prerequisites, and known issues that change with each RHDH release.

## Official Documentation References

### Core Installation

| Document | Path | Covers |
|----------|------|--------|
| **About RHDH** | [about_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/about_red_hat_developer_hub.md) | Architecture overview, Backstage version, key features, supported platforms |
| **Install on AKS** | [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](../../../docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) | Azure AKS prerequisites, Helm chart, PostgreSQL, Redis, ingress, TLS |
| **Install on OpenShift** | [installing_red_hat_developer_hub_on_openshift_container_platform.md](../../../docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md) | Operator-based install, Helm on OCP, routes, OAuth proxy |
| **First Instance Setup** | [setting_up_and_configuring_your_first_red_hat_developer_hub_instance.md](../../../docs/official-docs/rhdh/markdown/setting_up_and_configuring_your_first_red_hat_developer_hub_instance.md) | Step-by-step first setup, app-config.yaml basics, database, initial catalog |

### Supplementary

| Document | Path | Covers |
|----------|------|--------|
| **Developer Guide** | [a-developers-guide-to-red-hat-developer-hub-and-janus-_-red-hat-developer.md](../../../docs/official-docs/rhdh/markdown/a-developers-guide-to-red-hat-developer-hub-and-janus-_-red-hat-developer.md) | Janus IDP, development workflow, plugin ecosystem overview |

### ARO (Azure Red Hat OpenShift) Deployment

For ARO-specific deployment instructions (Operator install, Routes, SCC, pull-secret management), see the dedicated skill:

> **Reference:** [ARO Deployment Skill](../aro-deployment/SKILL.md)

## Quick Reference: AKS Installation

### Prerequisites
- Azure CLI >= 2.50, kubectl >= 1.28, Helm >= 3.12
- AKS cluster with Workload Identity enabled
- Azure Key Vault for secrets management
- Azure Container Registry for plugin OCI artifacts
- PostgreSQL Flexible Server for catalog database

### Helm Chart
```bash
helm repo add redhat-developer https://redhat-developer.github.io/rhdh-chart
helm repo update
helm install rhdh redhat-developer/backstage \
  --namespace rhdh --create-namespace \
  -f values.yaml
```

### Key Configuration Files
- `values.yaml` — Helm values (image, replicas, resources, ingress)
- `app-config.yaml` — App configuration (via ConfigMap or Secret)
- `dynamic-plugins-config.yaml` — Plugin enablement and wiring

## Troubleshooting Checklist

Before troubleshooting, **read the installation doc for your platform** (AKS or OCP). Common issues:

- [ ] Pod stuck in CrashLoopBackOff → Check `app-config.yaml` syntax and database connectivity
- [ ] Helm install fails → Verify chart version compatibility with RHDH version
- [ ] Ingress not working → Check TLS cert, DNS, and ingress controller config
- [ ] Database connection errors → Verify PostgreSQL endpoint, credentials, and network policies
- [ ] Plugin loading failures → Check `dynamic-plugins-config.yaml` syntax and OCI artifact availability
