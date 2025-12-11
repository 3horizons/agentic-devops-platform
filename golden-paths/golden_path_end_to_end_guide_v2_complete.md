# Golden Path End-to-End Execution Guide v2.0

## Red Hat Developer Hub + GitOps + Terraform + Ansible + AI Integration + Observability

**Version:** 2.0  
**Author:** paulasilva@microsoft.com  
**Team:** Latam Software GBB  
**Last Updated:** December 2025

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Strategic Framework: Three Horizons Model](#2-strategic-framework-three-horizons-model)
3. [Golden Path Fundamentals](#3-golden-path-fundamentals)
4. [Architecture Overview](#4-architecture-overview)
5. [Software Templates Catalog](#5-software-templates-catalog)
6. [Infrastructure as Code (Terraform)](#6-infrastructure-as-code-terraform)
7. [Configuration Management (Ansible)](#7-configuration-management-ansible)
8. [GitOps Deployment (ArgoCD)](#8-gitops-deployment-argocd)
9. [Complete Observability Stack](#9-complete-observability-stack)
10. [AI-Native Modernization (Without MTA)](#10-ai-native-modernization-without-mta)
11. [Database Schema Automation](#11-database-schema-automation)
12. [Blue-Green Deployment Validation](#12-blue-green-deployment-validation)
13. [Intelligent Self-Healing Pipelines](#13-intelligent-self-healing-pipelines)
14. [Post-Migration Testing Strategies](#14-post-migration-testing-strategies)
15. [Complete End-to-End Flow](#15-complete-end-to-end-flow)
16. [The 6 Rs Modernization Framework](#16-the-6-rs-modernization-framework)
17. [TechDocs Integration](#17-techdocs-integration)
18. [Implementation Example](#18-implementation-example)
19. [Value Proposition](#19-value-proposition)
20. [Implementation Roadmap](#20-implementation-roadmap)

---

## 1. Executive Summary

This guide provides a comprehensive technical reference for implementing Golden Path templates in Red Hat Developer Hub (RHDH), covering the complete execution flow from developer self-service to production deployment with Day 2 Operations readiness.

### Key Differentiators in v2.0

| Feature | Traditional Approach | Golden Path v2.0 |
|---------|---------------------|------------------|
| **Code Analysis** | MTA static rules | AI-Native (Azure AI + Copilot) |
| **Observability** | Manual configuration | Integrated (Prometheus + Grafana in RHDH) |
| **Database Migration** | Manual scripts | Automated (Skeema + gh-ost) |
| **Deployment Validation** | Manual checks | 4-Phase Blue-Green (T1-T4) |
| **Pipeline Intelligence** | Deterministic | Self-healing with AIOps |
| **Time to Production** | 2-4 weeks | 48 minutes |

### Technology Stack

| Layer | Components | Purpose |
|-------|------------|---------|
| **Developer Portal** | Red Hat Developer Hub (RHDH) | Self-service, catalog, TechDocs |
| **Source Control** | GitHub Enterprise | Repos, Actions, GHAS, Copilot |
| **Infrastructure** | Terraform + Ansible | IaC + Configuration Management |
| **Runtime** | AKS + ArgoCD | Kubernetes + GitOps |
| **Observability** | Azure Monitor + Prometheus + Grafana + SRE Agent | Metrics, logs, dashboards, AIOps |
| **AI Agents** | Azure AI Foundry + GitHub Copilot | Analysis, transformation, operations |

---

## 2. Strategic Framework: Three Horizons Model

The Three Horizons model provides a strategic framework for phasing platform transformation, ensuring immediate business needs are met while building capabilities for future innovation.

### Horizon Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        THREE HORIZONS MODEL                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  H1 (Present)          H2 (Near Future)         H3 (Future)                │
│  ───────────────       ─────────────────        ──────────────              │
│                                                                             │
│  • GitHub Enterprise   • Internal Developer     • AI-Powered DevEx         │
│  • GitHub Copilot        Platform (IDP)         • Agentic Systems          │
│  • Basic CI/CD         • Golden Paths           • Autonomous Ops           │
│  • Standardization     • Self-Service Infra     • Multi-Agent Workflows    │
│                                                                             │
│  Timeline: 0-6 months  Timeline: 6-18 months   Timeline: 18-36 months     │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ VALUE                                                               │   │
│  │   │                                              ┌──────────────┐   │   │
│  │   │                              ┌───────────────│     H3       │   │   │
│  │   │              ┌───────────────│     H2       │    Agentic   │   │   │
│  │   │  ┌──────────│     H1        │   Platform   │    DevOps    │   │   │
│  │   │  │ Foundation│  Engineering │  Engineering │              │   │   │
│  │   └──┴──────────┴───────────────┴──────────────┴──────────────┴───│   │
│  │                            TIME →                                  │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Horizon Details

#### H1: Foundation (0-6 months)
**Focus:** Standardization and developer productivity

| Component | Implementation | Outcome |
|-----------|----------------|---------|
| GitHub Enterprise | GHEC deployment, SSO | Unified source control |
| GitHub Copilot | Enterprise-wide rollout | 40% faster coding |
| GHAS | Security scanning enabled | Shift-left security |
| CI/CD | GitHub Actions standardized | Consistent pipelines |
| RHDH | Basic deployment | Service catalog |

**Key Metrics:**
- 80%+ GitHub adoption
- 50%+ Copilot activation
- GHAS on all production repos

#### H2: Platform Engineering (6-18 months)
**Focus:** Self-service infrastructure and golden paths

| Component | Implementation | Outcome |
|-----------|----------------|---------|
| RHDH Templates | 6 Rs Golden Paths | Self-service provisioning |
| Terraform Modules | Standardized IaC | Consistent infrastructure |
| Ansible Roles | Configuration automation | Day 2 readiness |
| ArgoCD | GitOps deployment | Declarative delivery |
| Observability | Prometheus + Grafana | Unified monitoring |

**Key Metrics:**
- < 1 hour time to production
- 90%+ template adoption
- Zero manual infrastructure provisioning

#### H3: Agentic DevOps (18-36 months)
**Focus:** AI-powered autonomous operations

| Component | Implementation | Outcome |
|-----------|----------------|---------|
| Azure SRE Agent | Autonomous incident response | 70-80% MTTR reduction |
| Copilot Coding Agent | Autonomous code changes | Self-maintaining code |
| AI Discovery | Semantic code analysis | Intelligent modernization |
| Self-Healing Pipelines | Predictive failure handling | Zero-touch deployments |
| Multi-Agent Orchestration | Agent HQ integration | Autonomous workflows |

**Key Metrics:**
- 90%+ automated incident resolution
- < 10 minute MTTR
- Zero customer-impacting deployments

---

## 3. Golden Path Fundamentals

### What is a Golden Path?

A **Golden Path** is a pre-built, opinionated, and fully automated template that enables developers to create production-ready services without deep infrastructure knowledge. It embodies organizational best practices while maintaining flexibility for customization.

```
┌─────────────────────────────────────────────────────────────────┐
│                    GOLDEN PATH CONCEPT                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Developer                    Golden Path                       │
│  ──────────                   ───────────                       │
│                                                                 │
│  ┌─────────┐    Parameters    ┌─────────────────────────────┐  │
│  │  Fill   │ ───────────────► │  • Repository scaffolding   │  │
│  │  Form   │                  │  • CI/CD pipelines          │  │
│  │  in     │                  │  • Infrastructure (Terraform)│  │
│  │  RHDH   │                  │  • Configuration (Ansible)   │  │
│  └─────────┘                  │  • GitOps (ArgoCD)          │  │
│                               │  • Observability            │  │
│                               │  • Security scanning        │  │
│                               │  • Documentation            │  │
│                               └─────────────────────────────┘  │
│                                           │                     │
│                                           ▼                     │
│                               ┌─────────────────────────────┐  │
│                               │  PRODUCTION-READY SERVICE   │  │
│                               │  in < 1 hour                │  │
│                               └─────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### Golden Path Principles

1. **Opinionated by Default, Flexible by Design**
   - Sensible defaults that work for 80% of cases
   - Override mechanisms for special requirements

2. **Complete End-to-End**
   - From code to production in one template
   - All supporting infrastructure included

3. **Day 2 Ready**
   - Observability built-in
   - Runbooks generated
   - Alerting configured

4. **Security First**
   - GHAS scanning enabled
   - Network policies applied
   - Secrets managed securely

5. **Self-Documenting**
   - TechDocs generated automatically
   - Architecture diagrams included
   - API documentation created

---

## 4. Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           GOLDEN PATH ARCHITECTURE                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  ┌─────────────────┐                                                            │
│  │   DEVELOPER     │                                                            │
│  │                 │                                                            │
│  │  • VS Code      │                                                            │
│  │  • Copilot      │                                                            │
│  │  • Browser      │                                                            │
│  └────────┬────────┘                                                            │
│           │                                                                     │
│           ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    RED HAT DEVELOPER HUB (RHDH)                          │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │   │
│  │  │  Software    │ │   Service    │ │   TechDocs   │ │   Plugins    │    │   │
│  │  │  Templates   │ │   Catalog    │ │   Portal     │ │  (Grafana,   │    │   │
│  │  │  (6 Rs)      │ │              │ │              │ │  Prometheus, │    │   │
│  │  │              │ │              │ │              │ │  ArgoCD)     │    │   │
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│           │                                                                     │
│           ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                         GITHUB ENTERPRISE                                │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │   │
│  │  │   GitHub     │ │   GitHub     │ │   GitHub     │ │   GitHub     │    │   │
│  │  │   Actions    │ │   Copilot    │ │    GHAS      │ │   Models     │    │   │
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│           │                                                                     │
│           ├──────────────────────┬──────────────────────┐                       │
│           ▼                      ▼                      ▼                       │
│  ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐             │
│  │   TERRAFORM     │    │    ANSIBLE      │    │    ARGOCD       │             │
│  │                 │    │                 │    │                 │             │
│  │  • AKS          │    │  • Configure    │    │  • GitOps       │             │
│  │  • ACR          │    │  • Harden       │    │  • Blue-Green   │             │
│  │  • PostgreSQL   │    │  • Monitor      │    │  • Canary       │             │
│  │  • Networking   │    │                 │    │                 │             │
│  └────────┬────────┘    └────────┬────────┘    └────────┬────────┘             │
│           │                      │                      │                       │
│           └──────────────────────┼──────────────────────┘                       │
│                                  ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                    AZURE KUBERNETES SERVICE (AKS)                        │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │   │
│  │  │ Application  │ │  Ingress     │ │  Prometheus  │ │  External    │    │   │
│  │  │  Workloads   │ │  Controller  │ │  (Managed)   │ │  Secrets     │    │   │
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│           │                                                                     │
│           ▼                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                       OBSERVABILITY STACK                                │   │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐    │   │
│  │  │    Azure     │ │   Managed    │ │   Managed    │ │  Azure SRE   │    │   │
│  │  │   Monitor    │ │  Prometheus  │ │   Grafana    │ │    Agent     │    │   │
│  │  └──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘    │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        TEMPLATE EXECUTION FLOW                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. DEVELOPER INPUT                                                         │
│     ────────────────                                                        │
│     Developer fills template form in RHDH                                   │
│           │                                                                 │
│           ▼                                                                 │
│  2. SCAFFOLDING                                                             │
│     ────────────                                                            │
│     RHDH generates repository structure with all files                      │
│           │                                                                 │
│           ▼                                                                 │
│  3. PUBLISH TO GITHUB                                                       │
│     ─────────────────                                                       │
│     Repository created, CI/CD triggered                                     │
│           │                                                                 │
│           ├─────────────────────────────────────────┐                       │
│           ▼                                         ▼                       │
│  4. INFRASTRUCTURE                          5. BUILD & TEST                 │
│     ──────────────                             ─────────────                │
│     Terraform provisions                       GitHub Actions               │
│     • AKS cluster                              • Build container            │
│     • Database                                 • Run tests                  │
│     • Networking                               • Security scan              │
│           │                                         │                       │
│           ▼                                         ▼                       │
│  6. CONFIGURATION                           7. PUSH TO ACR                  │
│     ─────────────                              ───────────                  │
│     Ansible configures                         Container image              │
│     • Monitoring                               pushed to registry           │
│     • Security policies                             │                       │
│     • Resource quotas                               │                       │
│           │                                         │                       │
│           └─────────────────────────────────────────┘                       │
│                               │                                             │
│                               ▼                                             │
│  8. GITOPS DEPLOYMENT                                                       │
│     ─────────────────                                                       │
│     ArgoCD syncs from Git → AKS                                             │
│           │                                                                 │
│           ▼                                                                 │
│  9. BLUE-GREEN VALIDATION (T1-T4)                                           │
│     ─────────────────────────────                                           │
│     • T1: Deploy green                                                      │
│     • T2: Integration tests                                                 │
│     • T3: Traffic switch                                                    │
│     • T4: AI-powered monitoring                                             │
│           │                                                                 │
│           ▼                                                                 │
│  10. PRODUCTION READY                                                       │
│      ────────────────                                                       │
│      Service live with full observability                                   │
│                                                                             │
│      TOTAL TIME: ~48 minutes                                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 5. Software Templates Catalog

### Template Categories

RHDH Software Templates are organized into categories aligned with the 6 Rs modernization framework plus supporting templates:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       SOFTWARE TEMPLATES CATALOG                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                     6 Rs MODERNIZATION TEMPLATES                     │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │                                                                     │   │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐                         │   │
│  │  │  REHOST   │ │ REPLATFORM│ │  REFACTOR │                         │   │
│  │  │           │ │           │ │           │                         │   │
│  │  │ VM → K8s  │ │ Managed   │ │ Cloud-    │                         │   │
│  │  │ Lift &    │ │ Services  │ │ Native    │                         │   │
│  │  │ Shift     │ │ Adoption  │ │ Re-arch   │                         │   │
│  │  └───────────┘ └───────────┘ └───────────┘                         │   │
│  │                                                                     │   │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐                         │   │
│  │  │REPURCHASE │ │  RETIRE   │ │  RETAIN   │                         │   │
│  │  │           │ │           │ │           │                         │   │
│  │  │ Replace   │ │ Decommis- │ │ Hybrid    │                         │   │
│  │  │ with SaaS │ │ sion      │ │ Connect   │                         │   │
│  │  └───────────┘ └───────────┘ └───────────┘                         │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                      SUPPORTING TEMPLATES                            │   │
│  ├─────────────────────────────────────────────────────────────────────┤   │
│  │                                                                     │   │
│  │  ┌───────────┐ ┌───────────┐ ┌───────────┐ ┌───────────┐          │   │
│  │  │  New      │ │   API     │ │   AI      │ │ Database  │          │   │
│  │  │ Service   │ │ Gateway   │ │  Agent    │ │ Migration │          │   │
│  │  └───────────┘ └───────────┘ └───────────┘ └───────────┘          │   │
│  │                                                                     │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Base Template Structure

All Golden Path templates follow a consistent structure:

```yaml
# template.yaml - Base structure for all Golden Path templates
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: golden-path-base
  title: Golden Path Base Template
  description: Base structure showing common template patterns
  tags:
    - golden-path
    - recommended
  annotations:
    backstage.io/techdocs-ref: dir:.
spec:
  owner: platform-team
  type: service
  
  # ============================================
  # PARAMETERS - User Input
  # ============================================
  parameters:
    # Step 1: Basic Information
    - title: Service Information
      required:
        - serviceName
        - owner
        - description
      properties:
        serviceName:
          title: Service Name
          type: string
          pattern: '^[a-z0-9-]+$'
          maxLength: 63
          description: Lowercase alphanumeric with hyphens
        owner:
          title: Owner Team
          type: string
          ui:field: OwnerPicker
          ui:options:
            catalogFilter:
              kind: Group
        description:
          title: Description
          type: string
          maxLength: 200
        
    # Step 2: Technical Options
    - title: Technical Configuration
      required:
        - runtime
        - targetEnvironment
      properties:
        runtime:
          title: Runtime
          type: string
          enum:
            - java-17
            - dotnet-8
            - nodejs-20
            - python-3.11
          enumNames:
            - Java 17 (Spring Boot 3)
            - .NET 8 (ASP.NET Core)
            - Node.js 20 (NestJS/Express)
            - Python 3.11 (FastAPI)
        targetEnvironment:
          title: Target Environment
          type: string
          enum:
            - dev
            - staging
            - production
          default: dev
        
    # Step 3: Infrastructure Options
    - title: Infrastructure
      properties:
        enableDatabase:
          title: Enable PostgreSQL Database
          type: boolean
          default: true
        enableRedis:
          title: Enable Redis Cache
          type: boolean
          default: false
        enableServiceMesh:
          title: Enable Istio Service Mesh
          type: boolean
          default: false
          
    # Step 4: Repository
    - title: Repository Configuration
      required:
        - repoUrl
      properties:
        repoUrl:
          title: Repository Location
          type: string
          ui:field: RepoUrlPicker
          ui:options:
            allowedHosts:
              - github.com
              
  # ============================================
  # STEPS - Template Execution
  # ============================================
  steps:
    # Step 1: Fetch and render template files
    - id: fetch-base
      name: Fetch Base Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          serviceName: ${{ parameters.serviceName }}
          owner: ${{ parameters.owner }}
          runtime: ${{ parameters.runtime }}
          # ... other parameters
          
    # Step 2: Render Terraform files
    - id: fetch-terraform
      name: Generate Terraform
      action: fetch:template
      input:
        url: ./terraform
        targetPath: ./terraform
        values:
          serviceName: ${{ parameters.serviceName }}
          enableDatabase: ${{ parameters.enableDatabase }}
          
    # Step 3: Render Ansible files
    - id: fetch-ansible
      name: Generate Ansible
      action: fetch:template
      input:
        url: ./ansible
        targetPath: ./ansible
        values:
          serviceName: ${{ parameters.serviceName }}
          
    # Step 4: Publish to GitHub
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: ${{ parameters.repoUrl }}
        description: ${{ parameters.description }}
        defaultBranch: main
        protectDefaultBranch: true
        requireCodeOwnerReviews: true
        
    # Step 5: Register in RHDH Catalog
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
        
    # Step 6: Trigger Infrastructure Provisioning
    - id: trigger-terraform
      name: Trigger Terraform
      action: github:actions:dispatch
      input:
        workflowId: terraform-apply.yml
        repoUrl: ${{ parameters.repoUrl }}
        branchOrTagName: main
        workflowInputs:
          environment: ${{ parameters.targetEnvironment }}
          action: apply

  # ============================================
  # OUTPUT - Links and References
  # ============================================
  output:
    links:
      - title: Repository
        url: ${{ steps['publish'].output.remoteUrl }}
      - title: Service Catalog
        icon: catalog
        entityRef: ${{ steps['register'].output.entityRef }}
      - title: GitHub Actions
        url: ${{ steps['publish'].output.remoteUrl }}/actions
```

---

## 16. The 6 Rs Modernization Framework

The 6 Rs framework provides a systematic approach to application modernization, with each strategy implemented as a dedicated RHDH Golden Path template.

### 6 Rs Decision Matrix

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      6 Rs DECISION FLOWCHART                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                        ┌──────────────────┐                                 │
│                        │  Is application  │                                 │
│                        │  still needed?   │                                 │
│                        └────────┬─────────┘                                 │
│                                 │                                           │
│                    ┌────────────┴────────────┐                              │
│                    │ NO                  YES │                              │
│                    ▼                         ▼                              │
│           ┌────────────────┐     ┌──────────────────┐                       │
│           │    RETIRE      │     │ Can replace with │                       │
│           │ Decommission   │     │    SaaS/COTS?    │                       │
│           └────────────────┘     └────────┬─────────┘                       │
│                                           │                                 │
│                              ┌────────────┴────────────┐                    │
│                              │ YES                 NO  │                    │
│                              ▼                         ▼                    │
│                    ┌────────────────┐     ┌──────────────────┐              │
│                    │  REPURCHASE    │     │ Must stay        │              │
│                    │ Replace w/SaaS │     │ on-premises?     │              │
│                    └────────────────┘     └────────┬─────────┘              │
│                                                    │                        │
│                                       ┌────────────┴────────────┐           │
│                                       │ YES                 NO  │           │
│                                       ▼                         ▼           │
│                             ┌────────────────┐     ┌──────────────────┐     │
│                             │    RETAIN      │     │ Needs significant│     │
│                             │ Hybrid Connect │     │ modernization?   │     │
│                             └────────────────┘     └────────┬─────────┘     │
│                                                             │               │
│                                                ┌────────────┴────────────┐  │
│                                                │ YES                 NO  │  │
│                                                ▼                         ▼  │
│                                      ┌────────────────┐     ┌────────────┐  │
│                                      │   REFACTOR     │     │ Need       │  │
│                                      │ Cloud-Native   │     │ managed    │  │
│                                      │ Re-architect   │     │ services?  │  │
│                                      └────────────────┘     └─────┬──────┘  │
│                                                                   │         │
│                                                      ┌────────────┴───────┐ │
│                                                      │ YES            NO  │ │
│                                                      ▼                    ▼ │
│                                            ┌────────────────┐   ┌─────────┐ │
│                                            │  REPLATFORM    │   │ REHOST  │ │
│                                            │ Managed Svcs   │   │ Lift &  │ │
│                                            │                │   │ Shift   │ │
│                                            └────────────────┘   └─────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6 Rs Summary Table

| Strategy | Description | Timeline | Risk | Effort | Best For |
|----------|-------------|----------|------|--------|----------|
| **REHOST** | Lift-and-shift to containers | 1-4 weeks | Low | Low | Quick wins, stable apps |
| **REPLATFORM** | Adopt managed services | 2-8 weeks | Low-Med | Medium | Database/cache modernization |
| **REFACTOR** | Cloud-native re-architecture | 2-6 months | Medium | High | Strategic apps, tech debt |
| **REPURCHASE** | Replace with SaaS | 1-3 months | Low | Low-Med | Commodity functions |
| **RETIRE** | Decommission | 2-4 weeks | Low | Low | Unused/redundant apps |
| **RETAIN** | Keep on-prem with hybrid | Ongoing | Low | Low | Compliance/latency needs |

---

### 16.1 REHOST Template

**Purpose:** Containerize VM-based applications with minimal code changes

```yaml
# templates/rehost-vm-to-aks/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: rehost-vm-to-aks
  title: "6R: Rehost - VM to AKS Migration"
  description: |
    Containerize a VM-based application and deploy to AKS with minimal changes.
    Best for: Applications that are stable and don't require significant modernization.
  tags:
    - 6rs
    - rehost
    - migration
    - lift-and-shift
    - golden-path
spec:
  owner: platform-team
  type: migration
  
  parameters:
    - title: Source Application
      required:
        - sourceVmName
        - applicationPort
        - runtimeType
      properties:
        sourceVmName:
          title: Source VM Name
          type: string
          description: Name of the VM hosting the application
        applicationPort:
          title: Application Port
          type: integer
          default: 8080
          description: Port the application listens on
        runtimeType:
          title: Runtime Type
          type: string
          enum:
            - java
            - dotnet
            - nodejs
            - python
          enumNames:
            - Java (JAR/WAR)
            - .NET (DLL)
            - Node.js
            - Python
        applicationPath:
          title: Application Path on VM
          type: string
          default: /opt/app
          description: Path where application files are located
          
    - title: Target Environment
      required:
        - targetEnvironment
        - aksNodeSize
      properties:
        targetEnvironment:
          title: Target Environment
          type: string
          enum: [dev, staging, production]
          default: dev
        aksNodeSize:
          title: AKS Node Size
          type: string
          enum:
            - Standard_D2s_v3
            - Standard_D4s_v3
            - Standard_D8s_v3
          default: Standard_D2s_v3
        replicas:
          title: Number of Replicas
          type: integer
          default: 2
          minimum: 1
          maximum: 10
          
    - title: AI Options
      properties:
        useAiDiscovery:
          title: Use AI for Application Discovery
          type: boolean
          default: true
          description: AI analyzes the source application for dependencies and configuration
          
    - title: Repository
      required:
        - repoUrl
        - owner
      properties:
        repoUrl:
          title: Repository Location
          type: string
          ui:field: RepoUrlPicker
          ui:options:
            allowedHosts:
              - github.com
        owner:
          title: Owner
          type: string
          ui:field: OwnerPicker
          
  steps:
    # Step 1: AI Discovery (optional)
    - id: ai-discovery
      name: AI Application Discovery
      if: ${{ parameters.useAiDiscovery }}
      action: http:backstage:request
      input:
        method: POST
        path: /api/proxy/ai-discovery
        body:
          vmName: ${{ parameters.sourceVmName }}
          applicationPath: ${{ parameters.applicationPath }}
          runtimeType: ${{ parameters.runtimeType }}
          
    # Step 2: Generate Dockerfile based on runtime
    - id: generate-dockerfile
      name: Generate Dockerfile
      action: fetch:template
      input:
        url: ./dockerfiles/${{ parameters.runtimeType }}
        targetPath: ./
        values:
          applicationPort: ${{ parameters.applicationPort }}
          runtimeType: ${{ parameters.runtimeType }}
          
    # Step 3: Fetch base template
    - id: fetch-base
      name: Fetch Base Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          serviceName: ${{ parameters.sourceVmName | replace(' ', '-') | lower }}
          applicationPort: ${{ parameters.applicationPort }}
          runtimeType: ${{ parameters.runtimeType }}
          replicas: ${{ parameters.replicas }}
          targetEnvironment: ${{ parameters.targetEnvironment }}
          
    # Step 4: Generate Terraform for AKS
    - id: fetch-terraform
      name: Generate Terraform
      action: fetch:template
      input:
        url: ./terraform
        targetPath: ./terraform
        values:
          serviceName: ${{ parameters.sourceVmName | replace(' ', '-') | lower }}
          aksNodeSize: ${{ parameters.aksNodeSize }}
          targetEnvironment: ${{ parameters.targetEnvironment }}
          
    # Step 5: Publish to GitHub
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: ${{ parameters.repoUrl }}
        description: "Rehosted from VM: ${{ parameters.sourceVmName }}"
        defaultBranch: main
        
    # Step 6: Register in Catalog
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
        
  output:
    links:
      - title: Repository
        url: ${{ steps['publish'].output.remoteUrl }}
      - title: Service Catalog
        icon: catalog
        entityRef: ${{ steps['register'].output.entityRef }}
      - title: Migration Guide
        icon: docs
        url: ${{ steps['publish'].output.remoteUrl }}/blob/main/docs/migration-guide.md
```

**Generated Dockerfile (Java Example):**

```dockerfile
# dockerfiles/java/Dockerfile
FROM eclipse-temurin:17-jre-alpine

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy application
COPY target/*.jar app.jar

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD wget -qO- http://localhost:${{ values.applicationPort }}/actuator/health || exit 1

# Switch to non-root user
USER appuser

EXPOSE ${{ values.applicationPort }}

ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
```

---

### 16.2 REPLATFORM Template

**Purpose:** Migrate applications while adopting Azure managed services

```yaml
# templates/replatform-managed-services/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: replatform-managed-services
  title: "6R: Replatform - Adopt Managed Services"
  description: |
    Migrate application to use Azure managed services (databases, caches, messaging).
    Best for: Applications that can benefit from managed services without major code changes.
  tags:
    - 6rs
    - replatform
    - managed-services
    - golden-path
spec:
  owner: platform-team
  type: migration
  
  parameters:
    - title: Application Information
      required:
        - serviceName
        - sourceRepoUrl
      properties:
        serviceName:
          title: Service Name
          type: string
          pattern: '^[a-z0-9-]+$'
        sourceRepoUrl:
          title: Source Repository URL
          type: string
          description: Existing repository to migrate
          
    - title: Database Migration
      properties:
        databaseMigration:
          title: Database Migration
          type: string
          enum:
            - none
            - sqlserver-to-postgresql-flexible
            - mysql-to-postgresql-flexible
            - oracle-to-postgresql-flexible
            - mongodb-to-cosmosdb
          enumNames:
            - No Database Migration
            - SQL Server → PostgreSQL Flexible
            - MySQL → PostgreSQL Flexible
            - Oracle → PostgreSQL Flexible
            - MongoDB → Cosmos DB
          default: none
        databaseSize:
          title: Database Size
          type: string
          enum:
            - Burstable_B1ms
            - GeneralPurpose_D2s_v3
            - GeneralPurpose_D4s_v3
            - MemoryOptimized_E2s_v3
          default: GeneralPurpose_D2s_v3
          ui:options:
            dependencies:
              databaseMigration:
                oneOf:
                  - const: sqlserver-to-postgresql-flexible
                  - const: mysql-to-postgresql-flexible
                  - const: oracle-to-postgresql-flexible
                  
    - title: Cache Migration
      properties:
        cacheMigration:
          title: Cache Migration
          type: string
          enum:
            - none
            - redis-vm-to-azure-cache
            - memcached-to-azure-cache
          enumNames:
            - No Cache Migration
            - Redis VM → Azure Cache for Redis
            - Memcached → Azure Cache for Redis
          default: none
        cacheSize:
          title: Cache Size
          type: string
          enum:
            - Basic_C0
            - Standard_C1
            - Premium_P1
          default: Standard_C1
          
    - title: Storage Migration
      properties:
        storageMigration:
          title: Storage Migration
          type: string
          enum:
            - none
            - nfs-to-blob
            - smb-to-files
            - local-to-data-lake
          enumNames:
            - No Storage Migration
            - NFS → Azure Blob Storage
            - SMB → Azure Files
            - Local Storage → Azure Data Lake
          default: none
          
    - title: Messaging Migration
      properties:
        messagingMigration:
          title: Messaging Migration
          type: string
          enum:
            - none
            - rabbitmq-to-servicebus
            - kafka-to-eventhubs
            - activemq-to-servicebus
          enumNames:
            - No Messaging Migration
            - RabbitMQ → Azure Service Bus
            - Kafka → Azure Event Hubs
            - ActiveMQ → Azure Service Bus
          default: none
          
    - title: Repository & Owner
      required:
        - repoUrl
        - owner
      properties:
        repoUrl:
          title: Target Repository Location
          type: string
          ui:field: RepoUrlPicker
          ui:options:
            allowedHosts:
              - github.com
        owner:
          title: Owner Team
          type: string
          ui:field: OwnerPicker
          
  steps:
    # Step 1: Clone source repository
    - id: fetch-source
      name: Fetch Source Repository
      action: fetch:plain
      input:
        url: ${{ parameters.sourceRepoUrl }}
        
    # Step 2: AI analysis of connection strings and config
    - id: ai-analysis
      name: AI Configuration Analysis
      action: http:backstage:request
      input:
        method: POST
        path: /api/proxy/ai-analysis
        body:
          analysisType: connection-strings
          migrations:
            database: ${{ parameters.databaseMigration }}
            cache: ${{ parameters.cacheMigration }}
            storage: ${{ parameters.storageMigration }}
            messaging: ${{ parameters.messagingMigration }}
            
    # Step 3: Generate Terraform for managed services
    - id: fetch-terraform
      name: Generate Terraform for Managed Services
      action: fetch:template
      input:
        url: ./terraform
        targetPath: ./terraform
        values:
          serviceName: ${{ parameters.serviceName }}
          databaseMigration: ${{ parameters.databaseMigration }}
          databaseSize: ${{ parameters.databaseSize }}
          cacheMigration: ${{ parameters.cacheMigration }}
          cacheSize: ${{ parameters.cacheSize }}
          storageMigration: ${{ parameters.storageMigration }}
          messagingMigration: ${{ parameters.messagingMigration }}
          
    # Step 4: Generate migration scripts
    - id: generate-migration-scripts
      name: Generate Migration Scripts
      action: fetch:template
      input:
        url: ./migration-scripts
        targetPath: ./migrations
        values:
          databaseMigration: ${{ parameters.databaseMigration }}
          cacheMigration: ${{ parameters.cacheMigration }}
          storageMigration: ${{ parameters.storageMigration }}
          messagingMigration: ${{ parameters.messagingMigration }}
          
    # Step 5: Generate updated application configuration
    - id: update-config
      name: Update Application Configuration
      action: github:copilot:modify
      input:
        task: |
          Update connection strings and configuration files for Azure managed services:
          - Database: ${{ parameters.databaseMigration }}
          - Cache: ${{ parameters.cacheMigration }}
          - Storage: ${{ parameters.storageMigration }}
          - Messaging: ${{ parameters.messagingMigration }}
          Use Azure Key Vault references for secrets.
          
    # Step 6: Generate data migration pipeline
    - id: generate-migration-pipeline
      name: Generate Data Migration Pipeline
      action: fetch:template
      input:
        url: ./pipelines
        targetPath: ./.github/workflows
        values:
          databaseMigration: ${{ parameters.databaseMigration }}
          
    # Step 7: Publish to GitHub
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: ${{ parameters.repoUrl }}
        description: "Replatformed: ${{ parameters.serviceName }} with Azure managed services"
        
    # Step 8: Register in Catalog
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
        
  output:
    links:
      - title: Repository
        url: ${{ steps['publish'].output.remoteUrl }}
      - title: Service Catalog
        entityRef: ${{ steps['register'].output.entityRef }}
      - title: Migration Runbook
        url: ${{ steps['publish'].output.remoteUrl }}/blob/main/docs/migration-runbook.md
```

**Service Migration Mapping:**

| Source Service | Target Azure Service | Complexity | Migration Tool |
|----------------|---------------------|------------|----------------|
| SQL Server | PostgreSQL Flexible | Medium | Azure DMS |
| MySQL | PostgreSQL Flexible | Low | pg_loader |
| Oracle | PostgreSQL Flexible | High | ora2pg |
| MongoDB | Cosmos DB (MongoDB API) | Low | Native tools |
| Redis (VM) | Azure Cache for Redis | Low | redis-cli |
| Memcached | Azure Cache for Redis | Medium | Custom script |
| RabbitMQ | Azure Service Bus | Medium | Custom adapter |
| Kafka | Azure Event Hubs | Low | Kafka protocol |
| NFS | Azure Blob Storage | Low | AzCopy |
| SMB | Azure Files | Low | robocopy |

---

### 16.3 REFACTOR Template

**Purpose:** Full cloud-native re-architecture with microservices decomposition

```yaml
# templates/refactor-cloud-native/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: refactor-cloud-native
  title: "6R: Refactor - Cloud-Native Re-architecture"
  description: |
    Decompose monolithic applications into cloud-native microservices.
    Best for: Strategic applications requiring significant modernization.
  tags:
    - 6rs
    - refactor
    - cloud-native
    - microservices
    - golden-path
spec:
  owner: platform-team
  type: migration
  
  parameters:
    - title: Legacy Application
      required:
        - legacyRepoUrl
        - applicationName
        - legacyLanguage
      properties:
        legacyRepoUrl:
          title: Legacy Repository URL
          type: string
          description: URL of the monolithic application repository
        applicationName:
          title: Application Name
          type: string
          pattern: '^[a-z0-9-]+$'
        legacyLanguage:
          title: Legacy Language/Framework
          type: string
          enum:
            - java-spring
            - java-ee
            - dotnet-framework
            - dotnet-core
            - nodejs
            - python-django
            - python-flask
            - php-laravel
          enumNames:
            - Java (Spring)
            - Java EE (WebSphere/JBoss)
            - .NET Framework
            - .NET Core
            - Node.js
            - Python (Django)
            - Python (Flask)
            - PHP (Laravel)
            
    - title: Target Architecture
      required:
        - targetFramework
        - decompositionStrategy
      properties:
        targetFramework:
          title: Target Framework
          type: string
          enum:
            - quarkus
            - spring-boot-3
            - dotnet-8
            - fastapi
            - nestjs
          enumNames:
            - Quarkus (Cloud-Native Java)
            - Spring Boot 3 (Java)
            - .NET 8 (ASP.NET Core)
            - FastAPI (Python)
            - NestJS (Node.js)
        decompositionStrategy:
          title: Decomposition Strategy
          type: string
          enum:
            - domain-driven-design
            - strangler-fig
            - branch-by-abstraction
          enumNames:
            - Domain-Driven Design (Bounded Contexts)
            - Strangler Fig (Incremental Extraction)
            - Branch by Abstraction
          default: domain-driven-design
        eventArchitecture:
          title: Event-Driven Architecture
          type: string
          enum:
            - choreography
            - orchestration
            - hybrid
          enumNames:
            - Choreography (Event-based, loose coupling)
            - Orchestration (Saga pattern, central coordinator)
            - Hybrid (Mix based on use case)
          default: choreography
          
    - title: AI Options
      properties:
        useAiDiscovery:
          title: Use AI for Code Discovery
          type: boolean
          default: true
          description: AI analyzes the codebase for bounded contexts and dependencies
        useAiRefactoring:
          title: Use AI for Code Refactoring
          type: boolean
          default: true
          description: AI generates refactored code using GitHub Copilot
        generateTests:
          title: Generate Test Suite
          type: boolean
          default: true
          description: AI generates comprehensive test suite
          
    - title: Repository Configuration
      required:
        - repoUrl
        - owner
      properties:
        repoUrl:
          title: Target Repository (Mono-repo or first service)
          type: string
          ui:field: RepoUrlPicker
          ui:options:
            allowedHosts:
              - github.com
        owner:
          title: Owner Team
          type: string
          ui:field: OwnerPicker
          
  steps:
    # Step 1: Clone legacy repository
    - id: fetch-legacy
      name: Fetch Legacy Repository
      action: fetch:plain
      input:
        url: ${{ parameters.legacyRepoUrl }}
        targetPath: ./legacy
        
    # Step 2: AI Code Discovery - Identify bounded contexts
    - id: ai-discovery
      name: AI Code Discovery
      if: ${{ parameters.useAiDiscovery }}
      action: http:backstage:request
      input:
        method: POST
        path: /api/proxy/ai-discovery
        body:
          analysisType: bounded-contexts
          legacyPath: ./legacy
          legacyLanguage: ${{ parameters.legacyLanguage }}
          decompositionStrategy: ${{ parameters.decompositionStrategy }}
          
    # Step 3: Generate microservices scaffolding
    - id: generate-services
      name: Generate Microservices Scaffolding
      action: fetch:template
      input:
        url: ./templates/${{ parameters.targetFramework }}
        values:
          applicationName: ${{ parameters.applicationName }}
          targetFramework: ${{ parameters.targetFramework }}
          eventArchitecture: ${{ parameters.eventArchitecture }}
          # Bounded contexts from AI discovery
          boundedContexts: ${{ steps['ai-discovery'].output.body.boundedContexts }}
          
    # Step 4: Generate event-driven infrastructure
    - id: generate-events
      name: Generate Event Infrastructure
      action: fetch:template
      input:
        url: ./event-infrastructure
        targetPath: ./infrastructure/events
        values:
          eventArchitecture: ${{ parameters.eventArchitecture }}
          services: ${{ steps['ai-discovery'].output.body.boundedContexts }}
          
    # Step 5: Create Copilot Issues for refactoring tasks
    - id: create-refactoring-issues
      name: Create Refactoring Issues
      if: ${{ parameters.useAiRefactoring }}
      action: github:issues:create
      input:
        repoUrl: ${{ parameters.repoUrl }}
        issues: ${{ steps['ai-discovery'].output.body.refactoringTasks }}
        labels:
          - copilot-agent
          - refactoring
          - automated
          
    # Step 6: Generate Strangler Fig proxy (if applicable)
    - id: generate-strangler-proxy
      name: Generate Strangler Fig Proxy
      if: ${{ parameters.decompositionStrategy == 'strangler-fig' }}
      action: fetch:template
      input:
        url: ./strangler-proxy
        targetPath: ./proxy
        values:
          legacyEndpoint: ${{ parameters.legacyRepoUrl }}
          newServices: ${{ steps['ai-discovery'].output.body.boundedContexts }}
          
    # Step 7: Generate comprehensive Terraform
    - id: generate-terraform
      name: Generate Terraform
      action: fetch:template
      input:
        url: ./terraform
        targetPath: ./terraform
        values:
          applicationName: ${{ parameters.applicationName }}
          services: ${{ steps['ai-discovery'].output.body.boundedContexts }}
          eventArchitecture: ${{ parameters.eventArchitecture }}
          
    # Step 8: Generate test suite
    - id: generate-tests
      name: Generate Test Suite
      if: ${{ parameters.generateTests }}
      action: github:copilot:generate
      input:
        task: |
          Generate comprehensive test suite for microservices:
          - Unit tests for each service
          - Integration tests for API contracts
          - Contract tests (Pact)
          - E2E tests for critical flows
        targetPath: ./tests
        
    # Step 9: Publish to GitHub
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: ${{ parameters.repoUrl }}
        description: "Refactored cloud-native: ${{ parameters.applicationName }}"
        
    # Step 10: Register in Catalog
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
        
  output:
    links:
      - title: Repository
        url: ${{ steps['publish'].output.remoteUrl }}
      - title: Service Catalog
        entityRef: ${{ steps['register'].output.entityRef }}
      - title: Architecture Diagram
        url: ${{ steps['publish'].output.remoteUrl }}/blob/main/docs/architecture.md
      - title: Refactoring Issues
        url: ${{ steps['publish'].output.remoteUrl }}/issues?q=label:copilot-agent
```

**Decomposition Strategies:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DECOMPOSITION STRATEGIES                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  1. DOMAIN-DRIVEN DESIGN (DDD)                                              │
│     ─────────────────────────                                               │
│                                                                             │
│     ┌─────────────────────────────────────────────────────┐                │
│     │              MONOLITH                               │                │
│     │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐   │                │
│     │  │ Orders  │ │Inventory│ │ Users   │ │ Payment │   │                │
│     │  │ Module  │ │ Module  │ │ Module  │ │ Module  │   │                │
│     │  └────┬────┘ └────┬────┘ └────┬────┘ └────┬────┘   │                │
│     │       └───────────┴───────────┴───────────┘        │                │
│     │              Shared Database                        │                │
│     └─────────────────────────────────────────────────────┘                │
│                           │                                                 │
│                           │ AI identifies bounded contexts                  │
│                           ▼                                                 │
│     ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                   │
│     │  Order   │ │ Inventory│ │  User    │ │ Payment  │                   │
│     │ Service  │ │ Service  │ │ Service  │ │ Service  │                   │
│     │    │     │ │    │     │ │    │     │ │    │     │                   │
│     │   DB     │ │   DB     │ │   DB     │ │   DB     │                   │
│     └──────────┘ └──────────┘ └──────────┘ └──────────┘                   │
│           │            │            │            │                         │
│           └────────────┴────────────┴────────────┘                         │
│                        Event Bus                                            │
│                                                                             │
│  2. STRANGLER FIG PATTERN                                                   │
│     ─────────────────────                                                   │
│                                                                             │
│     ┌─────────────────────────────────────────────────────┐                │
│     │                    PROXY                            │                │
│     │     Routes traffic based on feature flags           │                │
│     └───────────────────────┬─────────────────────────────┘                │
│                             │                                               │
│           ┌─────────────────┼─────────────────┐                            │
│           ▼                 ▼                 ▼                            │
│     ┌──────────┐      ┌──────────┐      ┌──────────┐                      │
│     │  Legacy  │      │   New    │      │   New    │                      │
│     │ Monolith │      │ Service  │      │ Service  │                      │
│     │ (70%)    │      │ A (20%)  │      │ B (10%)  │                      │
│     └──────────┘      └──────────┘      └──────────┘                      │
│                                                                             │
│     Over time, traffic shifts from Legacy to New Services                  │
│                                                                             │
│  3. BRANCH BY ABSTRACTION                                                   │
│     ─────────────────────────                                               │
│                                                                             │
│     Step 1: Create abstraction layer                                       │
│     ┌─────────────────────────────────────────────────────┐                │
│     │  ┌─────────────────────────────────────────────┐   │                │
│     │  │           ABSTRACTION LAYER                  │   │                │
│     │  │  interface PaymentProcessor { ... }          │   │                │
│     │  └─────────────────────────────────────────────┘   │                │
│     │                      │                              │                │
│     │         ┌────────────┴────────────┐                │                │
│     │         ▼                         ▼                │                │
│     │  ┌─────────────┐          ┌─────────────┐         │                │
│     │  │   Legacy    │          │    New      │         │                │
│     │  │   Impl      │          │    Impl     │         │                │
│     │  └─────────────┘          └─────────────┘         │                │
│     └─────────────────────────────────────────────────────┘                │
│                                                                             │
│     Step 2: Switch implementations via feature flag                        │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 16.4 REPURCHASE Template

**Purpose:** Replace custom applications with SaaS solutions

```yaml
# templates/repurchase-saas-migration/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: repurchase-saas-migration
  title: "6R: Repurchase - SaaS Migration"
  description: |
    Replace custom-built applications with SaaS solutions.
    Best for: Commodity functions better served by commercial products.
  tags:
    - 6rs
    - repurchase
    - saas
    - golden-path
spec:
  owner: platform-team
  type: migration
  
  parameters:
    - title: Legacy Application
      required:
        - legacyAppName
        - legacyAppType
      properties:
        legacyAppName:
          title: Legacy Application Name
          type: string
        legacyAppType:
          title: Application Type
          type: string
          enum:
            - crm
            - erp
            - hrms
            - cms
            - analytics
            - helpdesk
            - project-management
          enumNames:
            - CRM (Customer Relationship)
            - ERP (Enterprise Resource Planning)
            - HRMS (Human Resources)
            - CMS (Content Management)
            - Analytics/BI
            - Helpdesk/ITSM
            - Project Management
        dataVolume:
          title: Data Volume
          type: string
          enum:
            - small-gb
            - medium-100gb
            - large-1tb
            - xlarge-10tb
          default: medium-100gb
          
    - title: Target SaaS
      required:
        - targetSaas
      properties:
        targetSaas:
          title: Target SaaS Platform
          type: string
          enum:
            - dynamics365-sales
            - dynamics365-finance
            - salesforce
            - servicenow
            - workday
            - power-platform
            - sharepoint-online
            - github-issues
            - azure-devops
          enumNames:
            - Dynamics 365 Sales (CRM)
            - Dynamics 365 Finance & Operations (ERP)
            - Salesforce (CRM)
            - ServiceNow (ITSM)
            - Workday (HCM)
            - Power Platform (Low-Code Apps)
            - SharePoint Online (CMS/Collab)
            - GitHub Issues (Project Mgmt)
            - Azure DevOps (Project Mgmt)
        dataMigrationStrategy:
          title: Data Migration Strategy
          type: string
          enum:
            - full-historical
            - incremental-cutover
            - fresh-start
          enumNames:
            - Full Historical Migration
            - Incremental with Cutover Date
            - Fresh Start (No Historical Data)
          default: incremental-cutover
          
    - title: Integration Requirements
      properties:
        integrationRequired:
          title: Required Integrations
          type: array
          items:
            type: string
            enum:
              - active-directory
              - api-gateway
              - data-warehouse
              - reporting
              - email
              - erp-sync
          uniqueItems: true
          ui:widget: checkboxes
          
    - title: Repository & Owner
      required:
        - repoUrl
        - owner
      properties:
        repoUrl:
          title: Repository for Migration Scripts
          type: string
          ui:field: RepoUrlPicker
        owner:
          title: Owner Team
          type: string
          ui:field: OwnerPicker
          
  steps:
    # Step 1: Generate data export pipeline
    - id: generate-export
      name: Generate Data Export Pipeline
      action: fetch:template
      input:
        url: ./data-export
        targetPath: ./export
        values:
          legacyAppName: ${{ parameters.legacyAppName }}
          dataVolume: ${{ parameters.dataVolume }}
          
    # Step 2: Generate data transformation scripts
    - id: generate-transform
      name: Generate Data Transformation
      action: fetch:template
      input:
        url: ./data-transform/${{ parameters.targetSaas }}
        targetPath: ./transform
        values:
          legacyAppType: ${{ parameters.legacyAppType }}
          targetSaas: ${{ parameters.targetSaas }}
          
    # Step 3: Generate integration setup
    - id: generate-integrations
      name: Setup Integrations
      action: fetch:template
      input:
        url: ./integrations
        targetPath: ./integrations
        values:
          targetSaas: ${{ parameters.targetSaas }}
          integrations: ${{ parameters.integrationRequired }}
          
    # Step 4: Generate user migration plan
    - id: generate-user-migration
      name: Generate User Migration Plan
      action: fetch:template
      input:
        url: ./user-migration
        targetPath: ./docs
        values:
          targetSaas: ${{ parameters.targetSaas }}
          
    # Step 5: Generate decommission checklist
    - id: generate-decommission
      name: Generate Decommission Checklist
      action: fetch:template
      input:
        url: ./decommission
        targetPath: ./docs
        values:
          legacyAppName: ${{ parameters.legacyAppName }}
          
    # Step 6: Publish to GitHub
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: ${{ parameters.repoUrl }}
        description: "Repurchase migration: ${{ parameters.legacyAppName }} → ${{ parameters.targetSaas }}"
        
    # Step 7: Register in Catalog
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
        
  output:
    links:
      - title: Migration Repository
        url: ${{ steps['publish'].output.remoteUrl }}
      - title: Migration Guide
        url: ${{ steps['publish'].output.remoteUrl }}/blob/main/docs/migration-guide.md
      - title: User Training Plan
        url: ${{ steps['publish'].output.remoteUrl }}/blob/main/docs/user-training.md
```

---

### 16.5 RETIRE Template

**Purpose:** Safely decommission obsolete applications

```yaml
# templates/retire-decommission/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: retire-decommission
  title: "6R: Retire - Application Decommission"
  description: |
    Safely decommission applications that are no longer needed.
    Includes data archival, user notification, and infrastructure teardown.
  tags:
    - 6rs
    - retire
    - decommission
    - golden-path
spec:
  owner: platform-team
  type: decommission
  
  parameters:
    - title: Application to Retire
      required:
        - applicationName
        - applicationRepo
      properties:
        applicationName:
          title: Application Name
          type: string
        applicationRepo:
          title: Application Repository
          type: string
          description: GitHub repository URL
        infrastructureType:
          title: Infrastructure Type
          type: string
          enum:
            - kubernetes
            - vms
            - paas
            - hybrid
          default: kubernetes
          
    - title: Data Retention
      required:
        - dataRetentionPolicy
      properties:
        dataRetentionPolicy:
          title: Data Retention Policy
          type: string
          enum:
            - archive-1year
            - archive-3years
            - archive-7years
            - archive-permanent
            - delete-immediate
          enumNames:
            - Archive for 1 Year
            - Archive for 3 Years
            - Archive for 7 Years (Regulatory)
            - Archive Permanently
            - Delete Immediately (No Archive)
          default: archive-3years
        archiveLocation:
          title: Archive Location
          type: string
          enum:
            - azure-archive-storage
            - aws-glacier
            - on-premises-tape
          default: azure-archive-storage
          
    - title: Timeline
      properties:
        notificationPeriod:
          title: User Notification Period (days)
          type: integer
          default: 30
          minimum: 7
          maximum: 90
          description: Days before shutdown to notify users
        readOnlyPeriod:
          title: Read-Only Period (days)
          type: integer
          default: 14
          minimum: 0
          maximum: 30
          description: Days in read-only mode before full shutdown
        gracePeriod:
          title: Grace Period (days)
          type: integer
          default: 7
          minimum: 0
          maximum: 30
          description: Days after shutdown before infrastructure teardown
          
    - title: Repository for Decommission Plan
      required:
        - repoUrl
        - owner
      properties:
        repoUrl:
          title: Repository Location
          type: string
          ui:field: RepoUrlPicker
        owner:
          title: Owner Team
          type: string
          ui:field: OwnerPicker
          
  steps:
    # Step 1: Analyze dependencies
    - id: analyze-dependencies
      name: Analyze Dependencies
      action: http:backstage:request
      input:
        method: POST
        path: /api/proxy/dependency-analysis
        body:
          applicationRepo: ${{ parameters.applicationRepo }}
          
    # Step 2: Generate user notification plan
    - id: generate-notification
      name: Generate Notification Plan
      action: fetch:template
      input:
        url: ./notification-templates
        targetPath: ./docs/notifications
        values:
          applicationName: ${{ parameters.applicationName }}
          notificationPeriod: ${{ parameters.notificationPeriod }}
          
    # Step 3: Generate data archival pipeline
    - id: generate-archival
      name: Generate Data Archival Pipeline
      action: fetch:template
      input:
        url: ./archival-pipeline
        targetPath: ./archival
        values:
          applicationName: ${{ parameters.applicationName }}
          dataRetentionPolicy: ${{ parameters.dataRetentionPolicy }}
          archiveLocation: ${{ parameters.archiveLocation }}
          
    # Step 4: Generate access removal runbook
    - id: generate-access-removal
      name: Generate Access Removal Runbook
      action: fetch:template
      input:
        url: ./access-removal
        targetPath: ./docs
        values:
          applicationName: ${{ parameters.applicationName }}
          
    # Step 5: Generate infrastructure teardown plan
    - id: generate-teardown
      name: Generate Infrastructure Teardown
      action: fetch:template
      input:
        url: ./teardown/${{ parameters.infrastructureType }}
        targetPath: ./teardown
        values:
          applicationName: ${{ parameters.applicationName }}
          gracePeriod: ${{ parameters.gracePeriod }}
          
    # Step 6: Generate compliance documentation
    - id: generate-compliance
      name: Generate Compliance Documentation
      action: fetch:template
      input:
        url: ./compliance
        targetPath: ./docs/compliance
        values:
          applicationName: ${{ parameters.applicationName }}
          dataRetentionPolicy: ${{ parameters.dataRetentionPolicy }}
          
    # Step 7: Publish to GitHub
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: ${{ parameters.repoUrl }}
        description: "Decommission plan: ${{ parameters.applicationName }}"
        
    # Step 8: Register in Catalog
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
        
  output:
    links:
      - title: Decommission Repository
        url: ${{ steps['publish'].output.remoteUrl }}
      - title: Notification Templates
        url: ${{ steps['publish'].output.remoteUrl }}/tree/main/docs/notifications
      - title: Compliance Documentation
        url: ${{ steps['publish'].output.remoteUrl }}/tree/main/docs/compliance
```

**Decommission Timeline:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      DECOMMISSION TIMELINE                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  Week -4        Week -2        Week 0         Week +1        Week +2        │
│     │              │              │              │              │           │
│     ▼              ▼              ▼              ▼              ▼           │
│  ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐      ┌──────┐         │
│  │Notify│      │Read- │      │ Full │      │Grace │      │Infra │         │
│  │Users │ ───► │Only  │ ───► │Shut  │ ───► │Period│ ───► │Tear  │         │
│  │      │      │Mode  │      │down  │      │      │      │down  │         │
│  └──────┘      └──────┘      └──────┘      └──────┘      └──────┘         │
│                                                                             │
│  Activities:                                                                │
│  ──────────                                                                 │
│  Week -4 to -2:                                                             │
│    • Send user notifications                                                │
│    • Identify data to archive                                               │
│    • Verify no active dependencies                                          │
│    • Confirm alternative solutions ready                                    │
│                                                                             │
│  Week -2 to 0:                                                              │
│    • Set application to read-only                                           │
│    • Redirect write operations                                              │
│    • Complete data archival                                                 │
│    • Monitor for unexpected usage                                           │
│                                                                             │
│  Week 0:                                                                    │
│    • Stop application services                                              │
│    • Remove DNS entries                                                     │
│    • Revoke all credentials                                                 │
│    • Final backup verification                                              │
│                                                                             │
│  Week 0 to +1:                                                              │
│    • Keep infrastructure in dormant state                                   │
│    • Monitor for restore requests                                           │
│    • Document any issues encountered                                        │
│                                                                             │
│  Week +1 to +2:                                                             │
│    • Delete compute resources                                               │
│    • Remove storage (except archives)                                       │
│    • Archive repository to read-only                                        │
│    • Update service catalog                                                 │
│                                                                             │
│  Post-Decommission:                                                         │
│    • Remove from RHDH catalog                                               │
│    • Update dependency maps                                                 │
│    • Final compliance sign-off                                              │
│    • Cost verification (resources deleted)                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

### 16.6 RETAIN Template

**Purpose:** Keep applications on-premises with cloud integration

```yaml
# templates/retain-hybrid-connect/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: retain-hybrid-connect
  title: "6R: Retain - Hybrid Cloud Integration"
  description: |
    Keep applications on-premises while enabling cloud integration and management.
    Best for: Applications with data sovereignty, latency, or compliance requirements.
  tags:
    - 6rs
    - retain
    - hybrid
    - azure-arc
    - golden-path
spec:
  owner: platform-team
  type: integration
  
  parameters:
    - title: On-Premises Application
      required:
        - applicationName
        - applicationUrl
      properties:
        applicationName:
          title: Application Name
          type: string
        applicationUrl:
          title: Internal Application URL
          type: string
          description: Internal URL where application is accessible
        infrastructureType:
          title: Infrastructure Type
          type: string
          enum:
            - vms-windows
            - vms-linux
            - kubernetes
            - vmware
            - physical-servers
          enumNames:
            - Virtual Machines (Windows)
            - Virtual Machines (Linux)
            - On-Premises Kubernetes
            - VMware vSphere
            - Physical Servers
            
    - title: Retain Reason
      required:
        - retainReason
      properties:
        retainReason:
          title: Primary Reason for Retaining On-Premises
          type: string
          enum:
            - data-sovereignty
            - regulatory-compliance
            - latency-requirements
            - legacy-dependencies
            - cost-optimization
            - security-requirements
          enumNames:
            - Data Sovereignty Requirements
            - Regulatory Compliance
            - Latency-Sensitive Workload
            - Legacy System Dependencies
            - Cost Optimization (existing investment)
            - Security/Air-Gap Requirements
            
    - title: Cloud Integration Options
      properties:
        enableAzureArc:
          title: Enable Azure Arc Management
          type: boolean
          default: true
          description: Manage on-premises resources from Azure portal
        enableHybridIdentity:
          title: Enable Microsoft Entra ID Integration
          type: boolean
          default: true
          description: Single sign-on with cloud identity
        enableCloudMonitoring:
          title: Enable Azure Monitor
          type: boolean
          default: true
          description: Centralized monitoring in Azure
        enablePrivateLink:
          title: Enable Private Connectivity
          type: boolean
          default: false
          description: ExpressRoute or VPN for private cloud access
        exposeViaAppProxy:
          title: Expose via Application Proxy
          type: boolean
          default: false
          description: Secure external access without VPN
          
    - title: Repository Configuration
      required:
        - repoUrl
        - owner
      properties:
        repoUrl:
          title: Repository for Integration Scripts
          type: string
          ui:field: RepoUrlPicker
        owner:
          title: Owner Team
          type: string
          ui:field: OwnerPicker
          
  steps:
    # Step 1: Generate Azure Arc enrollment
    - id: generate-arc
      name: Generate Azure Arc Enrollment
      if: ${{ parameters.enableAzureArc }}
      action: fetch:template
      input:
        url: ./azure-arc/${{ parameters.infrastructureType }}
        targetPath: ./arc-enrollment
        values:
          applicationName: ${{ parameters.applicationName }}
          infrastructureType: ${{ parameters.infrastructureType }}
          
    # Step 2: Generate hybrid identity setup
    - id: generate-identity
      name: Generate Hybrid Identity Setup
      if: ${{ parameters.enableHybridIdentity }}
      action: fetch:template
      input:
        url: ./hybrid-identity
        targetPath: ./identity
        values:
          applicationName: ${{ parameters.applicationName }}
          applicationUrl: ${{ parameters.applicationUrl }}
          
    # Step 3: Generate monitoring integration
    - id: generate-monitoring
      name: Generate Azure Monitor Integration
      if: ${{ parameters.enableCloudMonitoring }}
      action: fetch:template
      input:
        url: ./monitoring
        targetPath: ./monitoring
        values:
          applicationName: ${{ parameters.applicationName }}
          infrastructureType: ${{ parameters.infrastructureType }}
          
    # Step 4: Generate network connectivity
    - id: generate-network
      name: Generate Network Configuration
      action: fetch:template
      input:
        url: ./networking
        targetPath: ./networking
        values:
          enablePrivateLink: ${{ parameters.enablePrivateLink }}
          exposeViaAppProxy: ${{ parameters.exposeViaAppProxy }}
          applicationUrl: ${{ parameters.applicationUrl }}
          
    # Step 5: Generate documentation
    - id: generate-docs
      name: Generate Hybrid Architecture Documentation
      action: fetch:template
      input:
        url: ./docs
        targetPath: ./docs
        values:
          applicationName: ${{ parameters.applicationName }}
          retainReason: ${{ parameters.retainReason }}
          integrations:
            arc: ${{ parameters.enableAzureArc }}
            identity: ${{ parameters.enableHybridIdentity }}
            monitoring: ${{ parameters.enableCloudMonitoring }}
            privateLink: ${{ parameters.enablePrivateLink }}
            appProxy: ${{ parameters.exposeViaAppProxy }}
            
    # Step 6: Publish to GitHub
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: ${{ parameters.repoUrl }}
        description: "Hybrid integration: ${{ parameters.applicationName }}"
        
    # Step 7: Register in Catalog
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
        
  output:
    links:
      - title: Integration Repository
        url: ${{ steps['publish'].output.remoteUrl }}
      - title: Arc Enrollment Guide
        url: ${{ steps['publish'].output.remoteUrl }}/blob/main/docs/arc-enrollment.md
      - title: Hybrid Architecture
        url: ${{ steps['publish'].output.remoteUrl }}/blob/main/docs/architecture.md
```

**Hybrid Architecture:**

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      HYBRID ARCHITECTURE                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         AZURE CLOUD                                  │   │
│  │                                                                      │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐            │   │
│  │  │  Azure   │  │  Azure   │  │  Azure   │  │Microsoft │            │   │
│  │  │  Portal  │  │   Arc    │  │ Monitor  │  │ Entra ID │            │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘            │   │
│  │                                                                      │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                          │   │
│  │  │  App     │  │  Key     │  │ Private  │                          │   │
│  │  │  Proxy   │  │  Vault   │  │  Link    │                          │   │
│  │  └──────────┘  └──────────┘  └──────────┘                          │   │
│  │                                                                      │   │
│  └─────────────────────────────────┬────────────────────────────────────┘   │
│                                    │                                        │
│                          ┌─────────┴─────────┐                              │
│                          │ ExpressRoute/VPN  │                              │
│                          │  Private Connect  │                              │
│                          └─────────┬─────────┘                              │
│                                    │                                        │
│  ┌─────────────────────────────────┴────────────────────────────────────┐   │
│  │                      ON-PREMISES DATA CENTER                          │   │
│  │                                                                       │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐             │   │
│  │  │  Azure   │  │  Azure   │  │  Entra   │  │  Your    │             │   │
│  │  │   Arc    │  │ Monitor  │  │ Connect  │  │ App      │             │   │
│  │  │  Agent   │  │  Agent   │  │  Sync    │  │          │             │   │
│  │  └────┬─────┘  └────┬─────┘  └────┬─────┘  └────┬─────┘             │   │
│  │       │             │             │             │                    │   │
│  │       └─────────────┴─────────────┴─────────────┘                    │   │
│  │                           │                                          │   │
│  │                    ┌──────┴──────┐                                   │   │
│  │                    │   Server    │                                   │   │
│  │                    │   (App +    │                                   │   │
│  │                    │    DB +     │                                   │   │
│  │                    │  Storage)   │                                   │   │
│  │                    └─────────────┘                                   │   │
│  │                                                                       │   │
│  └───────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
│  BENEFITS:                                                                  │
│  ─────────                                                                  │
│  • Unified management in Azure Portal                                       │
│  • Centralized monitoring and alerting                                      │
│  • Single identity (SSO with Entra ID)                                      │
│  • Secure access without VPN (via App Proxy)                                │
│  • Compliance with data sovereignty requirements                            │
│  • Cost optimization (use existing infrastructure)                          │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Infrastructure as Code (Terraform)

### Terraform Module Structure

```
terraform/
├── modules/
│   ├── aks/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── prometheus.tf       # Managed Prometheus config
│   ├── acr/
│   ├── postgresql/
│   ├── keyvault/
│   ├── networking/
│   └── monitoring/
│       ├── prometheus.tf
│       └── grafana.tf
└── environments/
    ├── dev/
    ├── staging/
    └── prod/
```

### AKS Module with Observability

```hcl
# terraform/modules/aks/main.tf

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                = "system"
    node_count          = var.system_node_count
    vm_size             = var.system_vm_size
    enable_auto_scaling = true
    min_count           = var.system_min_count
    max_count           = var.system_max_count
    os_disk_size_gb     = 100
    type                = "VirtualMachineScaleSets"
    zones               = ["1", "2", "3"]
    
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }
  }

  identity {
    type = "SystemAssigned"
  }

  # Azure Monitor integration
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }

  # Enable Managed Prometheus
  monitor_metrics {
    annotations_allowed = "*"
    labels_allowed      = "*"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_ids
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

  tags = var.tags
}

# Application Node Pool
resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                  = "app"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.app_vm_size
  enable_auto_scaling   = true
  min_count             = var.app_min_count
  max_count             = var.app_max_count
  zones                 = ["1", "2", "3"]
  
  node_labels = {
    "nodepool-type" = "application"
    "environment"   = var.environment
  }

  node_taints = []

  tags = var.tags
}
```

### Prometheus & Grafana Module

```hcl
# terraform/modules/monitoring/main.tf

# Azure Monitor Workspace (for Prometheus)
resource "azurerm_monitor_workspace" "prometheus" {
  name                = "${var.prefix}-prometheus"
  resource_group_name = var.resource_group_name
  location            = var.location
  
  tags = var.tags
}

# Data Collection Rule for Prometheus
resource "azurerm_monitor_data_collection_rule" "prometheus" {
  name                = "${var.prefix}-prometheus-dcr"
  resource_group_name = var.resource_group_name
  location            = var.location

  destinations {
    monitor_account {
      monitor_account_id = azurerm_monitor_workspace.prometheus.id
      name               = "MonitoringAccount"
    }
  }

  data_flow {
    streams      = ["Microsoft-PrometheusMetrics"]
    destinations = ["MonitoringAccount"]
  }

  data_sources {
    prometheus_forwarder {
      name    = "PrometheusDataSource"
      streams = ["Microsoft-PrometheusMetrics"]
    }
  }
}

# Associate DCR with AKS
resource "azurerm_monitor_data_collection_rule_association" "aks_prometheus" {
  name                    = "${var.prefix}-aks-prometheus-dcra"
  target_resource_id      = var.aks_cluster_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.prometheus.id
}

# Azure Managed Grafana
resource "azurerm_dashboard_grafana" "grafana" {
  name                              = "${var.prefix}-grafana"
  resource_group_name               = var.resource_group_name
  location                          = var.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.prometheus.id
  }

  tags = var.tags
}

# Grafana permissions to read Prometheus data
resource "azurerm_role_assignment" "grafana_monitoring_reader" {
  scope                = azurerm_monitor_workspace.prometheus.id
  role_definition_name = "Monitoring Data Reader"
  principal_id         = azurerm_dashboard_grafana.grafana.identity[0].principal_id
}

# Grafana permissions to read AKS metrics
resource "azurerm_role_assignment" "grafana_aks_reader" {
  scope                = var.aks_cluster_id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.grafana.identity[0].principal_id
}
```

---

## 9. Complete Observability Stack

### Observability Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    OBSERVABILITY ARCHITECTURE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  LAYER 1: COLLECTION                                                        │
│  ────────────────────                                                       │
│                                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                      │
│  │ Azure Monitor│  │  Container   │  │  Application │                      │
│  │    Agent     │  │  Insights    │  │  Insights    │                      │
│  │   (AMA)      │  │              │  │    SDK       │                      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘                      │
│         │                 │                 │                               │
│         └─────────────────┼─────────────────┘                               │
│                           │                                                 │
│  LAYER 2: DATA STORE                                                        │
│  ───────────────────                                                        │
│                           │                                                 │
│         ┌─────────────────┴─────────────────┐                              │
│         ▼                                   ▼                              │
│  ┌─────────────────────┐      ┌─────────────────────┐                      │
│  │   Azure Managed     │      │   Azure Monitor     │                      │
│  │    Prometheus       │      │     Workspace       │                      │
│  │                     │      │   (Log Analytics)   │                      │
│  │  • Metrics (18 mo)  │      │  • Logs             │                      │
│  │  • PromQL queries   │      │  • KQL queries      │                      │
│  │  • Recording rules  │      │  • Alerts           │                      │
│  └──────────┬──────────┘      └──────────┬──────────┘                      │
│             │                            │                                  │
│  LAYER 3: VISUALIZATION                  │                                  │
│  ──────────────────────                  │                                  │
│             │                            │                                  │
│             └────────────┬───────────────┘                                  │
│                          ▼                                                  │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │                    AZURE MANAGED GRAFANA                           │     │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐               │     │
│  │  │   Service    │ │    Golden    │ │    SRE       │               │     │
│  │  │  Dashboard   │ │    Signals   │ │  Dashboard   │               │     │
│  │  └──────────────┘ └──────────────┘ └──────────────┘               │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                          │                                                  │
│  LAYER 4: AI/AUTOMATION  │                                                  │
│  ──────────────────────  │                                                  │
│                          ▼                                                  │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │                      AZURE SRE AGENT                               │     │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐               │     │
│  │  │   Anomaly    │ │  Root Cause  │ │  Automated   │               │     │
│  │  │  Detection   │ │   Analysis   │ │ Remediation  │               │     │
│  │  └──────────────┘ └──────────────┘ └──────────────┘               │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                                                                             │
│  RHDH INTEGRATION                                                           │
│  ────────────────                                                           │
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │              RED HAT DEVELOPER HUB PLUGINS                         │     │
│  │  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐               │     │
│  │  │  Prometheus  │ │   Grafana    │ │    Azure     │               │     │
│  │  │   Plugin     │ │   Plugin     │ │  Resources   │               │     │
│  │  └──────────────┘ └──────────────┘ └──────────────┘               │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### RHDH Plugin Configuration

```yaml
# app-config.yaml - RHDH Observability Plugins

app:
  title: Developer Hub
  baseUrl: https://rhdh.example.com

proxy:
  endpoints:
    # Prometheus proxy
    '/prometheus/api':
      target: https://${PROMETHEUS_WORKSPACE}.${AZURE_REGION}.prometheus.monitor.azure.com
      headers:
        Authorization: Bearer ${PROMETHEUS_TOKEN}
      changeOrigin: true
      
    # Grafana proxy  
    '/grafana/api':
      target: https://${GRAFANA_INSTANCE}.grafana.azure.com
      headers:
        Authorization: Bearer ${GRAFANA_TOKEN}
      changeOrigin: true

kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - name: aks-dev
          url: ${AKS_DEV_URL}
          authProvider: 'azure'
          dashboardUrl: https://portal.azure.com/#resource${AKS_DEV_RESOURCE_ID}
        - name: aks-staging
          url: ${AKS_STAGING_URL}
          authProvider: 'azure'
        - name: aks-prod
          url: ${AKS_PROD_URL}
          authProvider: 'azure'

azureResources:
  enabled: true
  subscriptions:
    - subscriptionId: ${AZURE_SUBSCRIPTION_ID}
      resourceGroups:
        - ${RESOURCE_GROUP}

prometheus:
  proxyPath: /prometheus/api

grafana:
  domain: https://${GRAFANA_INSTANCE}.grafana.azure.com
  unifiedAlerting: true
```

### Azure SRE Agent Configuration

```yaml
# sre-agent-config.yaml
apiVersion: sre.azure.com/v1
kind: SREAgentConfiguration
metadata:
  name: production-sre-agent
spec:
  # Monitored resources
  resources:
    - type: AzureKubernetesService
      resourceGroup: ${RESOURCE_GROUP}
      clusterName: ${AKS_CLUSTER_NAME}
    - type: AzurePostgreSQLFlexible
      resourceGroup: ${RESOURCE_GROUP}
      serverName: ${POSTGRES_SERVER_NAME}
  
  # Incident response configuration
  incidentResponse:
    plans:
      - name: high-error-rate
        trigger:
          metric: error_rate
          threshold: 5
          duration: 5m
        mode: Review  # or Autonomous
        actions:
          - type: Investigate
            parameters:
              depth: detailed
          - type: Remediate
            action: RestartPods
            conditions:
              - podRestartCount < 3
          - type: Notify
            channel: slack
            webhook: ${SLACK_WEBHOOK}
            
      - name: high-latency
        trigger:
          metric: p99_latency
          threshold: 2000  # ms
          duration: 5m
        mode: Review
        actions:
          - type: Investigate
          - type: ScaleUp
            parameters:
              maxReplicas: 10
              
      - name: memory-pressure
        trigger:
          metric: memory_usage_percent
          threshold: 85
          duration: 3m
        mode: Autonomous
        actions:
          - type: ClearCache
          - type: ScaleUp
            parameters:
              increment: 2
              
  # Subagents
  subagents:
    - name: security-agent
      type: Security
      schedule: "0 */6 * * *"  # Every 6 hours
      actions:
        - ScanVulnerabilities
        - ReviewNetworkPolicies
        - AuditRBAC
        
    - name: performance-agent
      type: Performance
      enabled: true
      baselineWindow: 7d
      anomalyThreshold: 2.5  # Standard deviations
      
    - name: cost-agent
      type: Cost
      enabled: true
      budgetAlerts:
        - threshold: 80
          action: Notify
        - threshold: 100
          action: ScaleDown
          
  # MCP Integration for queries
  mcp:
    enabled: true
    tools:
      - name: prometheus-query
        description: Query Prometheus metrics
        endpoint: ${PROMETHEUS_ENDPOINT}
      - name: log-analytics-query
        description: Query Log Analytics
        workspaceId: ${LOG_ANALYTICS_WORKSPACE_ID}
      - name: github-issue-create
        description: Create GitHub issues
        repo: ${GITHUB_REPO}
```

---

## 12. Blue-Green Deployment Validation

### Four-Phase Model (T1-T4)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                  BLUE-GREEN DEPLOYMENT PHASES                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  T1: DEPLOY GREEN (5-10 min)                                                │
│  ───────────────────────────                                                │
│                                                                             │
│     ┌─────────────┐                          ┌─────────────┐               │
│     │    BLUE     │ ◄──── 100% Traffic ────► │   SERVICE   │               │
│     │  (Current)  │                          │             │               │
│     └─────────────┘                          └─────────────┘               │
│                                                                             │
│     ┌─────────────┐                                                         │
│     │   GREEN     │ ◄──── 0% Traffic (Deploy only)                         │
│     │   (New)     │                                                         │
│     └─────────────┘                                                         │
│                                                                             │
│     Actions:                                                                │
│     • Deploy new version to Green environment                               │
│     • Azure Monitor validates pod health                                    │
│     • No traffic routing yet                                                │
│                                                                             │
│  T2: SYNC & TEST (10-20 min)                                                │
│  ──────────────────────────                                                 │
│                                                                             │
│     ┌─────────────┐                          ┌─────────────┐               │
│     │    BLUE     │ ◄──── 100% Traffic ────► │   SERVICE   │               │
│     │  (Current)  │                          │             │               │
│     └─────────────┘                          └─────────────┘               │
│                                                                             │
│     ┌─────────────┐                                                         │
│     │   GREEN     │ ◄──── Test Traffic Only                                │
│     │   (New)     │       • Integration tests                              │
│     │             │       • Performance tests (k6)                         │
│     └─────────────┘       • Prometheus metrics                             │
│                                                                             │
│     Actions:                                                                │
│     • Run integration tests against Green                                   │
│     • Execute load tests to establish baseline                              │
│     • Prometheus collects performance metrics                               │
│     • RHDH displays SLO compliance dashboard                                │
│                                                                             │
│  T3: TRAFFIC SWITCH (1-2 min)                                               │
│  ───────────────────────────                                                │
│                                                                             │
│     ┌─────────────┐                                                         │
│     │    BLUE     │ ◄──── 0% Traffic (Standby)                             │
│     │  (Standby)  │                                                         │
│     └─────────────┘                                                         │
│                                                                             │
│     ┌─────────────┐                          ┌─────────────┐               │
│     │   GREEN     │ ◄──── 100% Traffic ────► │   SERVICE   │               │
│     │  (Active)   │                          │             │               │
│     └─────────────┘                          └─────────────┘               │
│                                                                             │
│     Actions:                                                                │
│     • Update Service selector to point to Green                             │
│     • Verify live traffic flowing to Green                                  │
│     • Keep Blue running for immediate rollback                              │
│                                                                             │
│  T4: POST-MIGRATION VALIDATION (5-15 min)                                   │
│  ──────────────────────────────────────────                                 │
│                                                                             │
│     ┌─────────────┐                                                         │
│     │   GREEN     │ ◄──── 100% Traffic                                     │
│     │  (Active)   │       • SRE Agent monitoring                           │
│     │             │       • AI anomaly detection                           │
│     └─────────────┘       • Auto-rollback if issues                        │
│                                                                             │
│     ┌─────────────┐                                                         │
│     │    BLUE     │ ◄──── Scheduled for decommission                       │
│     │ (Retiring)  │       after stability confirmed                        │
│     └─────────────┘                                                         │
│                                                                             │
│     Actions:                                                                │
│     • SRE Agent monitors for 5+ minutes                                     │
│     • AI analyzes metrics for anomalies                                     │
│     • Auto-rollback if degradation detected                                 │
│     • Decommission Blue after stability confirmed                           │
│                                                                             │
│  TOTAL TIMELINE: 21-47 minutes                                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Blue-Green Validation Playbook

```yaml
# ansible/playbooks/blue-green-validation.yml
---
- name: Blue-Green Deployment Validation
  hosts: localhost
  vars:
    service_name: "{{ lookup('env', 'SERVICE_NAME') }}"
    namespace: "{{ lookup('env', 'NAMESPACE') }}"
    green_image: "{{ lookup('env', 'GREEN_IMAGE') }}"
    prometheus_url: "{{ lookup('env', 'PROMETHEUS_URL') }}"
    slo_error_rate: 0.01  # 1% max error rate
    slo_p99_latency: 2.0  # 2 seconds max
    
  tasks:
    # ========================================
    # T1: DEPLOY GREEN
    # ========================================
    - name: "T1: Deploy Green Environment"
      block:
        - name: Deploy green deployment
          kubernetes.core.k8s:
            state: present
            definition:
              apiVersion: apps/v1
              kind: Deployment
              metadata:
                name: "{{ service_name }}-green"
                namespace: "{{ namespace }}"
              spec:
                replicas: 3
                selector:
                  matchLabels:
                    app: "{{ service_name }}"
                    version: green
                template:
                  metadata:
                    labels:
                      app: "{{ service_name }}"
                      version: green
                  spec:
                    containers:
                      - name: app
                        image: "{{ green_image }}"
                        ports:
                          - containerPort: 8080
                        readinessProbe:
                          httpGet:
                            path: /health/ready
                            port: 8080
                          initialDelaySeconds: 10
                          periodSeconds: 5
                        livenessProbe:
                          httpGet:
                            path: /health/live
                            port: 8080
                          initialDelaySeconds: 30
                          periodSeconds: 10
                          
        - name: Wait for green pods to be ready
          kubernetes.core.k8s_info:
            kind: Deployment
            name: "{{ service_name }}-green"
            namespace: "{{ namespace }}"
          register: green_deployment
          until: green_deployment.resources[0].status.readyReplicas == 3
          retries: 30
          delay: 10
          
        - name: Validate green health endpoint
          uri:
            url: "http://{{ service_name }}-green.{{ namespace }}.svc.cluster.local:8080/health"
            method: GET
          register: health_check
          failed_when: health_check.status != 200
          
      rescue:
        - name: T1 Failed - Cleanup green
          kubernetes.core.k8s:
            state: absent
            kind: Deployment
            name: "{{ service_name }}-green"
            namespace: "{{ namespace }}"
        - fail:
            msg: "T1 Failed: Could not deploy green environment"
            
    # ========================================
    # T2: SYNC & TEST
    # ========================================
    - name: "T2: Integration and Performance Tests"
      block:
        - name: Run integration tests
          shell: |
            cd /workspace/tests
            pytest integration/ --target-url="http://{{ service_name }}-green.{{ namespace }}.svc.cluster.local:8080"
          register: integration_tests
          
        - name: Run k6 performance baseline
          shell: |
            k6 run --out json=/tmp/k6-results.json \
              -e TARGET_URL="http://{{ service_name }}-green.{{ namespace }}.svc.cluster.local:8080" \
              /workspace/tests/performance/baseline.js
          register: k6_results
          
        - name: Query Prometheus for error rate
          uri:
            url: "{{ prometheus_url }}/api/v1/query"
            method: POST
            body_format: form-urlencoded
            body:
              query: |
                sum(rate(http_requests_total{service="{{ service_name }}-green", code=~"5.."}[5m])) /
                sum(rate(http_requests_total{service="{{ service_name }}-green"}[5m]))
          register: error_rate_query
          
        - name: Query Prometheus for P99 latency
          uri:
            url: "{{ prometheus_url }}/api/v1/query"
            method: POST
            body_format: form-urlencoded
            body:
              query: |
                histogram_quantile(0.99, 
                  sum(rate(http_request_duration_seconds_bucket{service="{{ service_name }}-green"}[5m])) by (le)
                )
          register: p99_latency_query
          
        - name: Validate SLOs
          assert:
            that:
              - error_rate_query.json.data.result[0].value[1] | float < slo_error_rate
              - p99_latency_query.json.data.result[0].value[1] | float < slo_p99_latency
            fail_msg: "SLO validation failed"
            
      rescue:
        - name: T2 Failed - Cleanup green
          kubernetes.core.k8s:
            state: absent
            kind: Deployment
            name: "{{ service_name }}-green"
            namespace: "{{ namespace }}"
        - fail:
            msg: "T2 Failed: Tests or SLO validation failed"
            
    # ========================================
    # T3: TRAFFIC SWITCH
    # ========================================
    - name: "T3: Switch Traffic to Green"
      block:
        - name: Update service selector to green
          kubernetes.core.k8s:
            state: present
            definition:
              apiVersion: v1
              kind: Service
              metadata:
                name: "{{ service_name }}"
                namespace: "{{ namespace }}"
              spec:
                selector:
                  app: "{{ service_name }}"
                  version: green
                ports:
                  - port: 80
                    targetPort: 8080
                    
        - name: Verify traffic reaching green
          uri:
            url: "http://{{ service_name }}.{{ namespace }}.svc.cluster.local/version"
            method: GET
          register: version_check
          until: version_check.json.version == "green"
          retries: 10
          delay: 5
          
    # ========================================
    # T4: POST-MIGRATION VALIDATION
    # ========================================
    - name: "T4: Post-Migration Monitoring"
      block:
        - name: Monitor for 5 minutes
          pause:
            minutes: 5
            
        - name: Check error rate post-switch
          uri:
            url: "{{ prometheus_url }}/api/v1/query"
            method: POST
            body_format: form-urlencoded
            body:
              query: |
                sum(rate(http_requests_total{service="{{ service_name }}", code=~"5.."}[5m])) /
                sum(rate(http_requests_total{service="{{ service_name }}"}[5m]))
          register: post_error_rate
          
        - name: Check SRE Agent health assessment
          uri:
            url: "{{ sre_agent_url }}/api/v1/health/{{ service_name }}"
            method: GET
          register: sre_health
          
        - name: Validate post-migration health
          assert:
            that:
              - post_error_rate.json.data.result[0].value[1] | float < slo_error_rate
              - sre_health.json.status == "healthy"
            fail_msg: "Post-migration validation failed"
            
        - name: Decommission blue deployment
          kubernetes.core.k8s:
            state: absent
            kind: Deployment
            name: "{{ service_name }}-blue"
            namespace: "{{ namespace }}"
            
        - name: Rename green to current
          kubernetes.core.k8s:
            state: present
            definition:
              apiVersion: apps/v1
              kind: Deployment
              metadata:
                name: "{{ service_name }}"
                namespace: "{{ namespace }}"
                labels:
                  app: "{{ service_name }}"
                  version: current
              spec:
                replicas: 3
                selector:
                  matchLabels:
                    app: "{{ service_name }}"
                template:
                  metadata:
                    labels:
                      app: "{{ service_name }}"
                  spec:
                    containers:
                      - name: app
                        image: "{{ green_image }}"
                        
      rescue:
        - name: T4 Failed - Rollback to blue
          kubernetes.core.k8s:
            state: present
            definition:
              apiVersion: v1
              kind: Service
              metadata:
                name: "{{ service_name }}"
                namespace: "{{ namespace }}"
              spec:
                selector:
                  app: "{{ service_name }}"
                  version: blue
                  
        - name: Delete green deployment
          kubernetes.core.k8s:
            state: absent
            kind: Deployment
            name: "{{ service_name }}-green"
            namespace: "{{ namespace }}"
            
        - name: Notify rollback via Slack
          uri:
            url: "{{ slack_webhook }}"
            method: POST
            body_format: json
            body:
              text: "🔴 ROLLBACK: {{ service_name }} deployment rolled back to blue version"
              
        - fail:
            msg: "T4 Failed: Post-migration validation failed, rolled back to blue"
```

---

## 19. Value Proposition

### Time to Production Comparison

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    TIME TO PRODUCTION COMPARISON                             │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TRADITIONAL APPROACH (2-4 weeks)                                           │
│  ────────────────────────────────                                           │
│                                                                             │
│  Day 1-3     Day 4-7      Day 8-10     Day 11-14    Day 15-20              │
│     │           │            │            │             │                   │
│     ▼           ▼            ▼            ▼             ▼                   │
│  ┌──────┐   ┌──────┐     ┌──────┐     ┌──────┐     ┌──────┐               │
│  │Submit│   │Infra │     │Config│     │Deploy│     │ Test │               │
│  │Ticket│──►│Provi-│────►│ure   │────►│ Code │────►│  &   │               │
│  │      │   │sion  │     │      │     │      │     │Verify│               │
│  └──────┘   └──────┘     └──────┘     └──────┘     └──────┘               │
│                                                                             │
│  Bottlenecks:                                                               │
│  • Manual ticket processing                                                 │
│  • Infrastructure team backlog                                              │
│  • Security review delays                                                   │
│  • Manual configuration                                                     │
│  • Manual testing cycles                                                    │
│                                                                             │
│  ═══════════════════════════════════════════════════════════════════════   │
│                                                                             │
│  GOLDEN PATH v2.0 (48 minutes)                                              │
│  ─────────────────────────────                                              │
│                                                                             │
│  T+0    T+5m     T+10m    T+25m    T+35m    T+43m    T+48m                 │
│    │       │        │        │        │        │        │                   │
│    ▼       ▼        ▼        ▼        ▼        ▼        ▼                   │
│  ┌────┐ ┌────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐               │
│  │Fill│ │Scaf│  │Pub- │  │Infra│  │Ansi-│  │Build│  │Blue-│               │
│  │Form│►│fold│─►│lish │─►│(TF) │─►│ble  │─►│Test │─►│Green│               │
│  └────┘ └────┘  └─────┘  └─────┘  └─────┘  └─────┘  └─────┘               │
│                                                                             │
│  Enablers:                                                                  │
│  • Self-service templates                                                   │
│  • Automated infrastructure                                                 │
│  • Pre-approved security patterns                                           │
│  • GitOps deployment                                                        │
│  • AI-powered validation                                                    │
│                                                                             │
│  IMPROVEMENT: 50-100x faster                                                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Business Outcomes

| Metric | Before Golden Path | After Golden Path | Improvement |
|--------|-------------------|-------------------|-------------|
| Time to Production | 2-4 weeks | 48 minutes | 50-100x |
| Infrastructure Provisioning | Days | Minutes | 95%+ reduction |
| Security Compliance | Manual reviews | Automated | 100% consistent |
| Developer Wait Time | 78% of cycle time | Near zero | 78% reduction |
| Deployment Confidence | Low (manual) | High (validated) | Significant |
| MTTR | Hours to days | Minutes | 70-80% reduction |
| Customer-Impacting Incidents | Common | Rare | 90% reduction |
| Developer Productivity | Baseline | +40% | GitHub Copilot |
| Code Quality Issues | Reactive | Proactive | Shift-left |

### ROI Calculation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ROI CALCULATION                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ASSUMPTIONS:                                                               │
│  • 50 developers                                                            │
│  • Average developer salary: $150,000/year                                  │
│  • 10 new services/quarter                                                  │
│  • 20% time spent on infrastructure/deployment tasks                        │
│                                                                             │
│  CURRENT STATE COSTS (Annual):                                              │
│  ────────────────────────────                                               │
│  Developer time on infra: 50 devs × $150k × 20% = $1,500,000               │
│  Delayed releases (opportunity cost):              $500,000                 │
│  Incident response (extended MTTR):                $300,000                 │
│  Security remediation:                             $200,000                 │
│  ──────────────────────────────────────────────────────────                 │
│  TOTAL CURRENT STATE:                            $2,500,000                 │
│                                                                             │
│  GOLDEN PATH INVESTMENT (Year 1):                                           │
│  ─────────────────────────────────                                          │
│  Platform team (4 FTEs):                           $600,000                 │
│  Tooling licenses:                                 $100,000                 │
│  Infrastructure (observability, etc):              $150,000                 │
│  Training:                                          $50,000                 │
│  ──────────────────────────────────────────────────────────                 │
│  TOTAL INVESTMENT:                                 $900,000                 │
│                                                                             │
│  SAVINGS WITH GOLDEN PATH (Annual):                                         │
│  ──────────────────────────────────                                         │
│  Developer time reduction (80%): $1,500k × 80% =  $1,200,000               │
│  Faster releases (50% more):                       $250,000                 │
│  Reduced MTTR (70%):             $300k × 70% =     $210,000                 │
│  Proactive security:             $200k × 50% =     $100,000                 │
│  ──────────────────────────────────────────────────────────                 │
│  TOTAL SAVINGS:                                  $1,760,000                 │
│                                                                             │
│  YEAR 1 ROI:                                                                │
│  ───────────                                                                │
│  Net Benefit: $1,760,000 - $900,000 =              $860,000                 │
│  ROI: ($1,760,000 / $900,000) - 1 =                   96%                   │
│  Payback Period:                                   ~6 months                │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 20. Implementation Roadmap

### Phased Implementation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    IMPLEMENTATION ROADMAP                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  PHASE 1: FOUNDATION (Weeks 1-6)                                            │
│  ─────────────────────────────────                                          │
│                                                                             │
│  Week 1-2: Infrastructure Setup                                             │
│  • Deploy RHDH on AKS                                                       │
│  • Configure GitHub Enterprise integration                                  │
│  • Setup Azure Monitor + Managed Prometheus                                 │
│  • Deploy Azure Managed Grafana                                             │
│                                                                             │
│  Week 3-4: Core Templates                                                   │
│  • Create REHOST template (simplest)                                        │
│  • Create new service template                                              │
│  • Configure Terraform modules (AKS, ACR, PostgreSQL)                       │
│  • Setup ArgoCD for GitOps                                                  │
│                                                                             │
│  Week 5-6: Validation                                                       │
│  • Pilot with 2-3 teams                                                     │
│  • Gather feedback                                                          │
│  • Iterate on templates                                                     │
│                                                                             │
│  Deliverables:                                                              │
│  ✓ RHDH running with basic templates                                        │
│  ✓ End-to-end deployment working                                            │
│  ✓ Observability stack operational                                          │
│                                                                             │
│  ═══════════════════════════════════════════════════════════════════════   │
│                                                                             │
│  PHASE 2: EXPANSION (Weeks 7-12)                                            │
│  ───────────────────────────────                                            │
│                                                                             │
│  Week 7-8: 6 Rs Templates                                                   │
│  • Create REPLATFORM template                                               │
│  • Create REPURCHASE template                                               │
│  • Create RETIRE template                                                   │
│  • Create RETAIN template                                                   │
│                                                                             │
│  Week 9-10: REFACTOR Template                                               │
│  • Implement AI discovery integration                                       │
│  • Configure GitHub Copilot for refactoring                                 │
│  • Setup decomposition strategies                                           │
│                                                                             │
│  Week 11-12: Blue-Green Validation                                          │
│  • Implement T1-T4 phases                                                   │
│  • Configure Ansible playbooks                                              │
│  • Setup SLO validation                                                     │
│                                                                             │
│  Deliverables:                                                              │
│  ✓ All 6 Rs templates operational                                           │
│  ✓ Blue-green deployment validated                                          │
│  ✓ 10+ teams onboarded                                                      │
│                                                                             │
│  ═══════════════════════════════════════════════════════════════════════   │
│                                                                             │
│  PHASE 3: INTELLIGENCE (Weeks 13-18)                                        │
│  ──────────────────────────────────                                         │
│                                                                             │
│  Week 13-14: AI Integration                                                 │
│  • Deploy AI Discovery Agent                                                │
│  • Configure Azure AI Foundry                                               │
│  • Setup Copilot Coding Agent workflows                                     │
│                                                                             │
│  Week 15-16: SRE Agent                                                      │
│  • Deploy Azure SRE Agent                                                   │
│  • Configure incident response plans                                        │
│  • Setup autonomous remediation                                             │
│                                                                             │
│  Week 17-18: Self-Healing Pipelines                                         │
│  • Implement predictive test selection                                      │
│  • Configure canary analysis                                                │
│  • Setup auto-remediation workflows                                         │
│                                                                             │
│  Deliverables:                                                              │
│  ✓ AI-powered discovery operational                                         │
│  ✓ SRE Agent monitoring production                                          │
│  ✓ Self-healing pipelines active                                            │
│                                                                             │
│  ═══════════════════════════════════════════════════════════════════════   │
│                                                                             │
│  PHASE 4: OPTIMIZATION (Weeks 19-24)                                        │
│  ──────────────────────────────────                                         │
│                                                                             │
│  Week 19-20: Database Automation                                            │
│  • Implement Skeema + gh-ost                                                │
│  • Configure zero-downtime migrations                                       │
│  • Setup schema-as-code workflows                                           │
│                                                                             │
│  Week 21-22: Advanced Templates                                             │
│  • API Gateway template                                                     │
│  • Event-driven architecture template                                       │
│  • Multi-region deployment template                                         │
│                                                                             │
│  Week 23-24: Governance & Metrics                                           │
│  • Implement template usage analytics                                       │
│  • Setup cost optimization dashboards                                       │
│  • Create compliance reporting                                              │
│                                                                             │
│  Deliverables:                                                              │
│  ✓ Database automation complete                                             │
│  ✓ Advanced templates available                                             │
│  ✓ Full governance in place                                                 │
│  ✓ 50%+ organization adoption                                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Success Criteria

| Phase | Criteria | Target |
|-------|----------|--------|
| **Phase 1** | RHDH operational | 100% |
| | Basic template working | End-to-end |
| | Pilot teams satisfied | NPS > 50 |
| **Phase 2** | 6 Rs templates available | 6/6 |
| | Blue-green validation | < 1% failure |
| | Teams onboarded | 10+ |
| **Phase 3** | AI discovery accuracy | > 90% |
| | SRE Agent MTTR | < 15 min |
| | Self-healing success | > 80% |
| **Phase 4** | Database migrations | Zero-downtime |
| | Organization adoption | > 50% |
| | Developer satisfaction | NPS > 70 |

---

## Document Information

**Version:** 2.0  
**Status:** Complete  
**Author:** Paula Silva (paulasilva@microsoft.com)  
**Team:** Microsoft Latam Software GBB  
**Last Updated:** December 2025

### Change Log

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Nov 2025 | Initial release |
| 2.0 | Dec 2025 | Added 6 Rs framework, AI-native approach, complete observability stack, self-healing pipelines, Blue-Green T1-T4 phases |

### Related Documents

- `project_instructions_ai_maturity_agentic_devops_v3_0.md` - AI Maturity Framework
- `three_horizons_discovery_guide.docx` - Three Horizons Platform Guide
- `t_shirt_models.md` - T-Shirt Sizing Reference
- `AI_MATURITY_PIPELINE_INSIGHTS_PLAN.md` - Pipeline Implementation Plan    