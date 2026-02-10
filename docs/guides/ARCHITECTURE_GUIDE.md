# Three Horizons Accelerator - Architecture Guide

> **Version:** 4.0.0
> **Last Updated:** December 2025
> **Audience:** Architects, Tech Leads, Senior Engineers

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Understanding the Three Horizons Model](#2-understanding-the-three-horizons-model)
3. [High-Level Platform Architecture](#3-high-level-platform-architecture)
4. [Infrastructure Architecture](#4-infrastructure-architecture)
5. [Network Architecture](#5-network-architecture)
6. [Security Architecture](#6-security-architecture)
7. [GitOps Architecture](#7-gitops-architecture)
8. [Observability Architecture](#8-observability-architecture)
9. [AI/ML Architecture](#9-aiml-architecture)
10. [Agent Architecture](#10-agent-architecture)
11. [Data Flow Diagrams](#11-data-flow-diagrams)
12. [Architecture Decision Records](#12-architecture-decision-records)

---

## 1. Introduction

### What is This Guide?

This Architecture Guide explains **how** the Three Horizons Accelerator is designed and **why** specific technology choices were made. It's intended for architects and engineers who need to understand the platform's internal workings.

> 💡 **Different from the Deployment Guide**
>
> - **Deployment Guide:** Step-by-step instructions to deploy the platform
> - **Architecture Guide (this):** Explains the design decisions and component interactions

### Who Should Read This?

| Role | What You'll Learn |
|------|-------------------|
| **Cloud Architects** | Overall platform design and Azure service integration |
| **Security Architects** | Zero-trust implementation and security controls |
| **Platform Engineers** | Component interactions and customization points |
| **DevOps Engineers** | GitOps workflow and CI/CD architecture |
| **Tech Leads** | Technology choices and trade-offs |

### Key Concepts You'll Understand

After reading this guide, you'll understand:

1. Why we use the "Three Horizons" organizational model
2. How Azure services are integrated together
3. How network isolation and security work
4. How GitOps enables declarative infrastructure
5. How observability components interact
6. How AI capabilities are integrated

---

## 2. Understanding the Three Horizons Model

### 2.1 What is the Three Horizons Framework?

> 💡 **Origin of the Model**
>
> The Three Horizons Accelerator is a solution created in partnership with **Microsoft**,
> **GitHub**, and **Red Hat**. It helps organizations balance maintaining current operations
> (H1) while developing improvements (H2) and exploring future opportunities (H3).

The Three Horizons model organizes the platform into three layers with different purposes:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                        H3: INNOVATION                                  │ │
│  │                                                                        │ │
│  │  PURPOSE: Enable next-generation capabilities                          │ │
│  │                                                                        │ │
│  │  • AI/ML models and intelligent automation                             │ │
│  │  • Experimental features and proof-of-concepts                         │ │
│  │  • Future platform evolution                                           │ │
│  │                                                                        │ │
│  │  CHARACTERISTICS:                                                      │ │
│  │  ✓ Optional - not required for basic operation                         │ │
│  │  ✓ Experimental - features may change                                  │ │
│  │  ✓ High value - enables competitive advantages                         │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
│                                    ▲                                        │
│                                    │ Builds upon                            │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                        H2: ENHANCEMENT                                 │ │
│  │                                                                        │ │
│  │  PURPOSE: Improve developer productivity and operations                │ │
│  │                                                                        │ │
│  │  • GitOps continuous deployment (ArgoCD)                               │ │
│  │  • Developer self-service portal (RHDH)                                │ │
│  │  • Observability stack (Prometheus, Grafana)                           │ │
│  │  • Secret synchronization (External Secrets)                           │ │
│  │  • Policy enforcement (Gatekeeper)                                     │ │
│  │                                                                        │ │
│  │  CHARACTERISTICS:                                                      │ │
│  │  ✓ Recommended - significantly improves operations                     │ │
│  │  ✓ Stable - production-ready components                                │ │
│  │  ✓ Integrated - components work together seamlessly                    │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
│                                    ▲                                        │
│                                    │ Builds upon                            │
│  ┌───────────────────────────────────────────────────────────────────────┐ │
│  │                        H1: FOUNDATION                                  │ │
│  │                                                                        │ │
│  │  PURPOSE: Provide core infrastructure that everything runs on          │ │
│  │                                                                        │ │
│  │  • Compute: AKS (Kubernetes cluster)                                   │ │
│  │  • Container Registry: ACR (image storage)                             │ │
│  │  • Secrets: Key Vault (secure storage)                                 │ │
│  │  • Networking: VNet, Subnets, NSGs                                     │ │
│  │  • Security: Defender, Purview, Managed Identities                     │ │
│  │  • Data: PostgreSQL, Redis                                             │ │
│  │                                                                        │ │
│  │  CHARACTERISTICS:                                                      │ │
│  │  ✓ Required - platform cannot function without it                      │ │
│  │  ✓ Stable - changes are rare and carefully managed                     │ │
│  │  ✓ Foundational - all other horizons depend on it                      │ │
│  └───────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Why Use Three Horizons?

| Benefit | Explanation |
|---------|-------------|
| **Clear Dependencies** | Each horizon has well-defined dependencies on lower horizons |
| **Independent Scaling** | Horizons can evolve at different speeds |
| **Risk Isolation** | Experimental H3 features don't affect stable H1 infrastructure |
| **Incremental Adoption** | Organizations can start with H1, add H2/H3 when ready |
| **Budget Control** | Each horizon can have separate cost allocation |

### 2.3 Component Mapping by Horizon

#### H1: Foundation Components

| Component | Azure Service | Purpose | Required? |
|-----------|---------------|---------|-----------|
| **AKS** | Azure Kubernetes Service | Container orchestration | Yes |
| **ACR** | Azure Container Registry | Container image storage | Yes |
| **Key Vault** | Azure Key Vault | Secrets and certificates | Yes |
| **VNet** | Azure Virtual Network | Network isolation | Yes |
| **NSG** | Network Security Groups | Firewall rules | Yes |
| **Managed Identity** | Azure AD Managed Identity | Passwordless auth | Yes |
| **Defender** | Defender for Cloud | Threat protection | Recommended |
| **Purview** | Microsoft Purview | Data governance | Optional |
| **PostgreSQL** | Azure Database for PostgreSQL | Relational database | Optional |
| **Redis** | Azure Cache for Redis | Caching | Optional |

#### H2: Enhancement Components

| Component | Technology | Purpose | Required? |
|-----------|------------|---------|-----------|
| **ArgoCD** | CNCF ArgoCD | GitOps deployment | Recommended |
| **External Secrets** | External Secrets Operator | Secret synchronization | Recommended |
| **Prometheus** | CNCF Prometheus | Metrics collection | Recommended |
| **Grafana** | Grafana | Dashboards | Recommended |
| **Alertmanager** | CNCF Alertmanager | Alert routing | Recommended |
| **Gatekeeper** | OPA Gatekeeper | Policy enforcement | Recommended |
| **RHDH** | Red Hat Developer Hub | Developer portal | Optional |
| **GitHub Runners** | Self-hosted runners | CI/CD execution | Optional |

#### H3: Innovation Components

| Component | Technology | Purpose | Required? |
|-----------|------------|---------|-----------|
| **AI Foundry** | Azure OpenAI | LLM capabilities | Optional |
| **GPT-4o** | OpenAI GPT-4o | Text generation | Optional |
| **Embeddings** | text-embedding-3 | Vector embeddings | Optional |
| **Agents** | Custom implementations | Intelligent automation | Optional |

---

## 3. High-Level Platform Architecture

### 3.1 Layered Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           EXTERNAL LAYER                                     │
│                                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐        │
│  │  Developers │  │   GitHub    │  │   Azure     │  │  External   │        │
│  │             │  │  (Source)   │  │   Portal    │  │    APIs     │        │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘        │
└─────────┼────────────────┼────────────────┼────────────────┼────────────────┘
          │                │                │                │
          ▼                ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           INGRESS LAYER                                      │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    Azure Application Gateway                         │    │
│  │                                                                      │    │
│  │    FUNCTIONS:                                                        │    │
│  │    • SSL/TLS termination (offloads encryption from pods)            │    │
│  │    • Web Application Firewall (WAF) - protects against attacks      │    │
│  │    • Load balancing (distributes traffic across pods)               │    │
│  │    • URL-based routing (routes to different services)               │    │
│  │                                                                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         KUBERNETES CLUSTER (AKS)                             │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         SYSTEM NAMESPACE                             │    │
│  │                                                                      │    │
│  │  These are Kubernetes system components that run automatically:      │    │
│  │                                                                      │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐               │    │
│  │  │ CoreDNS  │ │ Metrics  │ │Gatekeeper│ │  CSI     │               │    │
│  │  │          │ │ Server   │ │          │ │ Drivers  │               │    │
│  │  │ DNS for  │ │ Resource │ │ Policy   │ │ Storage  │               │    │
│  │  │ services │ │ metrics  │ │ enforce  │ │ drivers  │               │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                      PLATFORM NAMESPACES                             │    │
│  │                                                                      │    │
│  │  These are the H2 Enhancement components:                            │    │
│  │                                                                      │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐               │    │
│  │  │  ArgoCD  │ │   RHDH   │ │ External │ │Observa-  │               │    │
│  │  │          │ │          │ │ Secrets  │ │bility    │               │    │
│  │  │ GitOps   │ │ Developer│ │ Secret   │ │ Metrics  │               │    │
│  │  │ deploy   │ │ portal   │ │ sync     │ │ & alerts │               │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                    APPLICATION NAMESPACES                            │    │
│  │                                                                      │    │
│  │  Your applications run here, isolated by namespace:                  │    │
│  │                                                                      │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐               │    │
│  │  │  app-a   │ │  app-b   │ │  app-c   │ │  app-n   │               │    │
│  │  │  (dev)   │ │(staging) │ │  (prod)  │ │   ...    │               │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
          │
          │ Private Endpoints (secure connection)
          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          AZURE PaaS SERVICES                                 │
│                                                                              │
│  These services are managed by Azure (you don't manage the servers):        │
│                                                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐         │
│  │   ACR    │ │Key Vault │ │PostgreSQL│ │  Redis   │ │AI Foundry│         │
│  │          │ │          │ │ Flexible │ │  Cache   │ │ (OpenAI) │         │
│  │ Container│ │ Secrets  │ │ Database │ │  Fast    │ │ AI/ML    │         │
│  │ images   │ │ storage  │ │ storage  │ │  cache   │ │ models   │         │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘         │
│                                                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐                       │
│  │ Defender │ │ Purview  │ │ Monitor  │ │ Storage  │                       │
│  │for Cloud │ │          │ │          │ │ Account  │                       │
│  │ Security │ │ Data     │ │ Logs &   │ │ Blob     │                       │
│  │ scanning │ │ catalog  │ │ metrics  │ │ storage  │                       │
│  └──────────┘ └──────────┘ └──────────┘ └──────────┘                       │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Design Principles

> 💡 **What are Design Principles?**
>
> Design principles are the rules we follow when making architecture decisions.
> They ensure consistency and help avoid common mistakes.

| Principle | What It Means | How We Implement It |
|-----------|---------------|---------------------|
| **Infrastructure as Code** | All infrastructure is defined in code, not created manually | Terraform for Azure resources, Kubernetes manifests for apps |
| **GitOps** | Git is the single source of truth for deployments | ArgoCD watches Git repos and syncs changes automatically |
| **Zero Trust** | Never trust, always verify | Private endpoints, workload identity, network policies |
| **Immutable Infrastructure** | Don't modify running systems; replace them | Rolling updates, blue-green deployments |
| **Observable** | Everything can be measured and monitored | Prometheus metrics, Grafana dashboards, alerts |
| **Self-Service** | Developers can deploy without ops intervention | Golden Path templates, RHDH portal |
| **Policy as Code** | Security policies are defined in code | Gatekeeper/OPA constraints |
| **Cost Awareness** | Monitor and optimize costs continuously | Azure Cost Management, budgets, alerts |

---

## 4. Infrastructure Architecture

### 4.1 AKS Cluster Architecture

> 💡 **What is AKS?**
>
> Azure Kubernetes Service (AKS) is a managed Kubernetes service. Azure manages
> the control plane (API server, etcd, scheduler), and you only manage the
> worker nodes where your applications run.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                               AKS CLUSTER                                    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                  CONTROL PLANE (Azure Managed)                       │    │
│  │                                                                      │    │
│  │  You don't see or manage these - Azure handles them:                 │    │
│  │                                                                      │    │
│  │  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐               │    │
│  │  │ API      │ │ etcd     │ │Controller│ │Scheduler │               │    │
│  │  │ Server   │ │          │ │ Manager  │ │          │               │    │
│  │  │          │ │ Stores   │ │ Manages  │ │ Places   │               │    │
│  │  │ Receives │ │ cluster  │ │ desired  │ │ pods on  │               │    │
│  │  │ commands │ │ state    │ │ state    │ │ nodes    │               │    │
│  │  └──────────┘ └──────────┘ └──────────┘ └──────────┘               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │                         NODE POOLS                                   │    │
│  │                                                                      │    │
│  │  These are the VMs where your workloads run:                         │    │
│  │                                                                      │    │
│  │  ┌────────────────────────────────────────────────────────────┐     │    │
│  │  │  SYSTEM NODE POOL                                          │     │    │
│  │  │                                                            │     │    │
│  │  │  Purpose: Run Kubernetes system components                 │     │    │
│  │  │  Configuration:                                            │     │    │
│  │  │  • 3 nodes (across availability zones 1, 2, 3)            │     │    │
│  │  │  • VM Size: Standard_D4s_v5 (4 vCPU, 16 GB RAM)           │     │    │
│  │  │  • OS: Ubuntu 22.04 LTS                                    │     │    │
│  │  │  • Taint: CriticalAddonsOnly (only system pods run here)  │     │    │
│  │  │                                                            │     │    │
│  │  │  ┌────────┐ ┌────────┐ ┌────────┐                         │     │    │
│  │  │  │ Node 1 │ │ Node 2 │ │ Node 3 │                         │     │    │
│  │  │  │ Zone 1 │ │ Zone 2 │ │ Zone 3 │                         │     │    │
│  │  │  └────────┘ └────────┘ └────────┘                         │     │    │
│  │  └────────────────────────────────────────────────────────────┘     │    │
│  │                                                                      │    │
│  │  ┌────────────────────────────────────────────────────────────┐     │    │
│  │  │  WORKLOAD NODE POOL                                        │     │    │
│  │  │                                                            │     │    │
│  │  │  Purpose: Run your applications                            │     │    │
│  │  │  Configuration:                                            │     │    │
│  │  │  • 3-10 nodes (auto-scales based on demand)               │     │    │
│  │  │  • VM Size: Standard_D8s_v5 (8 vCPU, 32 GB RAM)           │     │    │
│  │  │  • OS: Ubuntu 22.04 LTS                                    │     │    │
│  │  │  • No taints (any pod can run here)                       │     │    │
│  │  │                                                            │     │    │
│  │  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐  ┌─────────┐│     │    │
│  │  │  │ Node 1 │ │ Node 2 │ │ Node 3 │ │ Node 4 │  │ ...     ││     │    │
│  │  │  │ Zone 1 │ │ Zone 2 │ │ Zone 3 │ │ Zone 1 │  │ (auto)  ││     │    │
│  │  │  └────────┘ └────────┘ └────────┘ └────────┘  └─────────┘│     │    │
│  │  └────────────────────────────────────────────────────────────┘     │    │
│  │                                                                      │    │
│  │  ┌────────────────────────────────────────────────────────────┐     │    │
│  │  │  AI NODE POOL (Optional - H3 only)                         │     │    │
│  │  │                                                            │     │    │
│  │  │  Purpose: Run AI/ML workloads with GPU                     │     │    │
│  │  │  Configuration:                                            │     │    │
│  │  │  • 0-3 nodes (scales to 0 when not in use)                │     │    │
│  │  │  • VM Size: Standard_NC8as_T4_v3 (GPU)                    │     │    │
│  │  │  • Taint: nvidia.com/gpu (only GPU pods run here)         │     │    │
│  │  └────────────────────────────────────────────────────────────┘     │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Why Multiple Node Pools?

| Node Pool | Purpose | Why Separate? |
|-----------|---------|---------------|
| **System** | Kubernetes system components | Isolates system pods from application disruptions |
| **Workload** | Application pods | Can scale independently based on app demand |
| **AI** | GPU-accelerated workloads | Expensive GPUs only used when needed (scales to 0) |

### 4.3 Cluster Add-ons

These are additional capabilities we enable on the AKS cluster:

| Add-on | What It Does | Why We Enable It |
|--------|--------------|------------------|
| **Azure CNI** | Network plugin | Assigns Azure VNet IPs to pods for better network integration |
| **Azure Policy** | Policy enforcement | Integrates with Azure Policy for compliance |
| **Workload Identity** | Pod authentication | Allows pods to authenticate to Azure without secrets |
| **Key Vault CSI** | Secret injection | Mounts Key Vault secrets as files in pods |
| **Blob CSI** | Blob storage | Allows pods to use Azure Blob storage as volumes |

---

## 5. Network Architecture

### 5.1 Network Topology

> 💡 **Why Network Architecture Matters**
>
> Proper network design is critical for:
> - **Security:** Isolating sensitive workloads
> - **Performance:** Reducing latency between components
> - **Compliance:** Meeting regulatory requirements for data isolation

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           AZURE VIRTUAL NETWORK                              │
│                           CIDR: 10.0.0.0/16 (65,536 IPs)                    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  AKS NODES SUBNET                                                    │    │
│  │  CIDR: 10.0.0.0/22 (1,024 IPs)                                      │    │
│  │                                                                      │    │
│  │  PURPOSE: Where AKS worker node VMs get their IP addresses          │    │
│  │                                                                      │    │
│  │  NSG RULES:                                                          │    │
│  │  ✓ Allow: HTTPS (443) from Application Gateway                      │    │
│  │  ✓ Allow: Kube API (6443) from control plane                        │    │
│  │  ✓ Allow: Internal cluster communication                            │    │
│  │  ✗ Deny: Direct internet access                                     │    │
│  │                                                                      │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐                    │    │
│  │  │10.0.0.4 │ │10.0.0.5 │ │10.0.0.6 │ │10.0.0.7 │ ...               │    │
│  │  │ Node 1  │ │ Node 2  │ │ Node 3  │ │ Node 4  │                    │    │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘                    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  AKS PODS SUBNET (Azure CNI)                                         │    │
│  │  CIDR: 10.0.16.0/20 (4,096 IPs)                                     │    │
│  │                                                                      │    │
│  │  PURPOSE: Where Kubernetes pods get their IP addresses               │    │
│  │                                                                      │    │
│  │  WHY SEPARATE: Azure CNI assigns VNet IPs directly to pods,         │    │
│  │  allowing them to communicate with Azure services without NAT        │    │
│  │                                                                      │    │
│  │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐                    │    │
│  │  │10.0.16.1│ │10.0.16.2│ │10.0.16.3│ │10.0.16.4│ ...               │    │
│  │  │ Pod A   │ │ Pod B   │ │ Pod C   │ │ Pod D   │                    │    │
│  │  └─────────┘ └─────────┘ └─────────┘ └─────────┘                    │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  PRIVATE ENDPOINTS SUBNET                                            │    │
│  │  CIDR: 10.0.4.0/24 (256 IPs)                                        │    │
│  │                                                                      │    │
│  │  PURPOSE: Secure connections to Azure PaaS services                  │    │
│  │                                                                      │    │
│  │  Private endpoints give Azure services a private IP in your VNet,   │    │
│  │  so traffic never goes over the public internet:                    │    │
│  │                                                                      │    │
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐   │    │
│  │  │ 10.0.4.4    │ │ 10.0.4.5    │ │ 10.0.4.6    │ │ 10.0.4.7    │   │    │
│  │  │ ACR PE      │ │ Key Vault PE│ │ PostgreSQL  │ │ AI Foundry  │   │    │
│  │  │             │ │             │ │ PE          │ │ PE          │   │    │
│  │  └──────┬──────┘ └──────┬──────┘ └──────┬──────┘ └──────┬──────┘   │    │
│  │         │               │               │               │           │    │
│  │         ▼               ▼               ▼               ▼           │    │
│  │  ┌─────────────────────────────────────────────────────────────┐   │    │
│  │  │        Azure PaaS Services (accessed via private IPs)       │   │    │
│  │  └─────────────────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  APPLICATION GATEWAY SUBNET                                          │    │
│  │  CIDR: 10.0.6.0/24 (256 IPs)                                        │    │
│  │                                                                      │    │
│  │  PURPOSE: Azure Application Gateway (Layer 7 load balancer)         │    │
│  │                                                                      │    │
│  │  Application Gateway needs its own dedicated subnet.                 │    │
│  │  It handles:                                                         │    │
│  │  • SSL termination                                                   │    │
│  │  • WAF (Web Application Firewall)                                    │    │
│  │  • Path-based routing                                                │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  AZURE BASTION SUBNET                                                │    │
│  │  Name: AzureBastionSubnet (required exact name)                      │    │
│  │  CIDR: 10.0.5.0/26 (64 IPs)                                         │    │
│  │                                                                      │    │
│  │  PURPOSE: Secure RDP/SSH access to VMs without public IPs           │    │
│  │                                                                      │    │
│  │  Azure Bastion provides browser-based secure shell access.          │    │
│  │  No need to expose SSH ports to the internet.                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 5.2 Private DNS Zones

> 💡 **What are Private DNS Zones?**
>
> When you create a private endpoint for an Azure service (like Key Vault),
> it gets a private IP (e.g., 10.0.4.5). Private DNS zones automatically
> resolve the service's public DNS name to this private IP when queried
> from within the VNet.

| Service | Private DNS Zone | Example Resolution |
|---------|------------------|-------------------|
| Key Vault | `privatelink.vaultcore.azure.net` | kv-myapp.vault.azure.net → 10.0.4.5 |
| ACR | `privatelink.azurecr.io` | myacr.azurecr.io → 10.0.4.4 |
| PostgreSQL | `privatelink.postgres.database.azure.com` | mydb.postgres.database.azure.com → 10.0.4.6 |
| OpenAI | `privatelink.openai.azure.com` | myoai.openai.azure.com → 10.0.4.7 |

### 5.3 Network Security Groups (NSGs)

NSGs act as firewalls at the subnet level:

```
┌────────────────────────────────────────────────────────────────────────────┐
│                        NSG: nsg-aks-nodes                                   │
├────────────────────────────────────────────────────────────────────────────┤
│  INBOUND RULES (what traffic is allowed IN):                               │
│                                                                             │
│  Priority │ Name              │ Source          │ Port  │ Action          │
│  ─────────┼───────────────────┼─────────────────┼───────┼─────────────────│
│  100      │ AllowAppGateway   │ AppGw Subnet    │ 443   │ Allow           │
│  110      │ AllowKubeAPI      │ AzureCloud      │ 443   │ Allow           │
│  120      │ AllowLoadBalancer │ AzureLoadBal    │ *     │ Allow           │
│  4096     │ DenyAllInbound    │ *               │ *     │ Deny            │
│                                                                             │
│  OUTBOUND RULES (what traffic is allowed OUT):                             │
│                                                                             │
│  Priority │ Name              │ Destination     │ Port  │ Action          │
│  ─────────┼───────────────────┼─────────────────┼───────┼─────────────────│
│  100      │ AllowAzureServices│ AzureCloud      │ 443   │ Allow           │
│  110      │ AllowPrivateEndpt │ VirtualNetwork  │ *     │ Allow           │
│  4096     │ DenyAllOutbound   │ Internet        │ *     │ Deny            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## 6. Security Architecture

### 6.1 Zero Trust Model

> 💡 **What is Zero Trust?**
>
> Zero Trust is a security model where you never trust anything by default,
> even if it's inside your network. Every request must be verified.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        ZERO TRUST IMPLEMENTATION                             │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  1. IDENTITY VERIFICATION                                            │    │
│  │                                                                      │    │
│  │  Every request must prove who is making it:                          │    │
│  │                                                                      │    │
│  │  • Users: Azure AD authentication with MFA                           │    │
│  │  • Services: Managed Identity (no passwords!)                        │    │
│  │  • Pods: Workload Identity (Azure AD tokens for pods)               │    │
│  │  • CI/CD: Federated credentials (GitHub OIDC)                       │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  2. LEAST PRIVILEGE ACCESS                                           │    │
│  │                                                                      │    │
│  │  Grant minimum permissions needed:                                    │    │
│  │                                                                      │    │
│  │  • RBAC roles: Specific roles instead of Owner/Contributor          │    │
│  │  • Key Vault: Access policies per secret                            │    │
│  │  • K8s RBAC: Namespace-scoped permissions                           │    │
│  │  • Network policies: Only allowed pod-to-pod traffic               │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  3. NETWORK SEGMENTATION                                             │    │
│  │                                                                      │    │
│  │  Isolate traffic at multiple levels:                                 │    │
│  │                                                                      │    │
│  │  • Subnets: Separate subnets for different workloads                │    │
│  │  • NSGs: Firewall rules per subnet                                   │    │
│  │  • Private endpoints: No public internet exposure                    │    │
│  │  • Network policies: Pod-level traffic control                      │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐    │
│  │  4. CONTINUOUS VERIFICATION                                          │    │
│  │                                                                      │    │
│  │  Always monitor and verify:                                          │    │
│  │                                                                      │    │
│  │  • Defender for Cloud: Continuous security scanning                 │    │
│  │  • Azure Monitor: Audit logs for all operations                     │    │
│  │  • Gatekeeper: Policy enforcement on every deployment               │    │
│  │  • TFSec: Infrastructure code scanning in CI                        │    │
│  └─────────────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.2 Workload Identity

> 💡 **What is Workload Identity?**
>
> Workload Identity allows Kubernetes pods to authenticate to Azure services
> using Azure AD tokens, without needing secrets or passwords.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    HOW WORKLOAD IDENTITY WORKS                               │
│                                                                              │
│  TRADITIONAL (BAD):                                                         │
│  ┌──────────┐     Store password     ┌──────────┐    Password      ┌─────┐  │
│  │   Pod    │ ──────────────────────►│  Secret  │ ─────────────────►│Azure│  │
│  └──────────┘    in K8s Secret       └──────────┘   in request     └─────┘  │
│                                                                              │
│  Problems:                                                                   │
│  ✗ Secrets can leak                                                         │
│  ✗ Secrets need rotation                                                    │
│  ✗ Secrets stored in multiple places                                        │
│                                                                              │
│  ────────────────────────────────────────────────────────────────────────   │
│                                                                              │
│  WORKLOAD IDENTITY (GOOD):                                                  │
│                                                                              │
│  ┌──────────┐   1. Request token    ┌──────────┐   2. Get token  ┌────────┐ │
│  │   Pod    │ ─────────────────────►│ Azure AD │ ───────────────►│Managed │ │
│  │ (Service │                       │ (OIDC)   │                 │Identity│ │
│  │ Account) │◄───────────────────── └──────────┘ ◄───────────────└────────┘ │
│  └──────────┘   3. JWT token                      4. Verified               │
│       │                                                                      │
│       │ 5. Use token                                                        │
│       ▼                                                                      │
│  ┌──────────┐                                                               │
│  │Key Vault │  No secrets needed!                                           │
│  │PostgreSQL│  Just a short-lived token                                     │
│  │   ACR    │                                                               │
│  └──────────┘                                                               │
│                                                                              │
│  Benefits:                                                                   │
│  ✓ No secrets to manage                                                     │
│  ✓ Tokens auto-rotate                                                       │
│  ✓ Azure AD handles authentication                                          │
│  ✓ Audit trail in Azure AD                                                  │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 6.3 Secret Management Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SECRET MANAGEMENT ARCHITECTURE                            │
│                                                                              │
│   ┌─────────────┐                                                           │
│   │  Developer  │                                                           │
│   │  creates    │                                                           │
│   │  secret in  │                                                           │
│   │  Key Vault  │                                                           │
│   └──────┬──────┘                                                           │
│          │                                                                   │
│          ▼                                                                   │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │                    AZURE KEY VAULT                               │       │
│   │                                                                  │       │
│   │  Single source of truth for all secrets:                        │       │
│   │                                                                  │       │
│   │  • database-password                                             │       │
│   │  • api-keys                                                      │       │
│   │  • certificates                                                  │       │
│   │  • connection-strings                                            │       │
│   │                                                                  │       │
│   │  Access controlled by:                                           │       │
│   │  • Azure RBAC roles                                              │       │
│   │  • Access policies                                               │       │
│   │  • Private endpoint (network isolation)                         │       │
│   └─────────────────────┬───────────────────────────────────────────┘       │
│                         │                                                    │
│                         │ Sync via Workload Identity                        │
│                         ▼                                                    │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │              EXTERNAL SECRETS OPERATOR                           │       │
│   │                                                                  │       │
│   │  Runs in Kubernetes, watches for ExternalSecret resources:      │       │
│   │                                                                  │       │
│   │  1. Reads ExternalSecret custom resource                        │       │
│   │  2. Uses Workload Identity to authenticate to Key Vault         │       │
│   │  3. Fetches secret value                                         │       │
│   │  4. Creates Kubernetes Secret                                    │       │
│   │  5. Periodically refreshes (every 1h by default)                │       │
│   └─────────────────────┬───────────────────────────────────────────┘       │
│                         │                                                    │
│                         │ Creates K8s Secret                                │
│                         ▼                                                    │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │                  KUBERNETES SECRET                               │       │
│   │                                                                  │       │
│   │  kind: Secret                                                    │       │
│   │  metadata:                                                       │       │
│   │    name: my-app-secrets                                         │       │
│   │  data:                                                           │       │
│   │    database-password: <base64>                                  │       │
│   └─────────────────────┬───────────────────────────────────────────┘       │
│                         │                                                    │
│                         │ Mounted as volume or env var                      │
│                         ▼                                                    │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │                    APPLICATION POD                               │       │
│   │                                                                  │       │
│   │  Pod can access secrets as:                                      │       │
│   │  • Environment variables: $DATABASE_PASSWORD                    │       │
│   │  • Volume mount: /secrets/database-password                     │       │
│   └─────────────────────────────────────────────────────────────────┘       │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 7. GitOps Architecture

### 7.1 What is GitOps?

> 💡 **GitOps Explained Simply**
>
> GitOps means **Git is the source of truth** for your infrastructure.
> Instead of running commands to deploy, you commit changes to Git,
> and a tool (ArgoCD) automatically applies them to your cluster.

### 7.2 GitOps Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         GITOPS WORKFLOW                                      │
│                                                                              │
│   ┌─────────────┐                                                           │
│   │  Developer  │                                                           │
│   │  makes      │                                                           │
│   │  change     │                                                           │
│   └──────┬──────┘                                                           │
│          │                                                                   │
│          │ 1. Push code change                                              │
│          ▼                                                                   │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │                       GITHUB REPOSITORY                          │       │
│   │                                                                  │       │
│   │  Contains:                                                       │       │
│   │  • Application code (src/)                                       │       │
│   │  • Kubernetes manifests (k8s/)                                  │       │
│   │  • ArgoCD application definitions (argocd/)                     │       │
│   │                                                                  │       │
│   │  Example structure:                                              │       │
│   │  ├── src/                    # Application source code          │       │
│   │  ├── k8s/                                                        │       │
│   │  │   ├── base/               # Base Kubernetes manifests        │       │
│   │  │   └── overlays/                                              │       │
│   │  │       ├── dev/            # Dev environment patches          │       │
│   │  │       ├── staging/        # Staging patches                  │       │
│   │  │       └── prod/           # Production patches               │       │
│   │  └── argocd/                                                     │       │
│   │      └── application.yaml    # ArgoCD app definition            │       │
│   └─────────────────────────┬───────────────────────────────────────┘       │
│                             │                                                │
│          ┌──────────────────┼──────────────────────┐                        │
│          │                  │                      │                        │
│          │ 2. CI runs       │ 3. ArgoCD polls     │                        │
│          ▼                  ▼                      │                        │
│   ┌─────────────┐    ┌─────────────┐              │                        │
│   │   GitHub    │    │   ARGOCD    │              │                        │
│   │   Actions   │    │             │              │                        │
│   │             │    │  Watches    │              │                        │
│   │  • Tests    │    │  Git repos  │              │                        │
│   │  • Build    │    │  every 3min │              │                        │
│   │  • Scan     │    │             │              │                        │
│   └──────┬──────┘    └──────┬──────┘              │                        │
│          │                  │                      │                        │
│          │ 4. Push image    │ 5. Detect diff      │                        │
│          ▼                  ▼                      │                        │
│   ┌─────────────┐    ┌─────────────┐              │                        │
│   │     ACR     │    │ Kubernetes  │◄─────────────┘                        │
│   │             │    │   Cluster   │                                        │
│   │  Container  │    │             │                                        │
│   │  images     │    │ 6. Apply    │                                        │
│   │             │    │ manifests   │                                        │
│   └─────────────┘    └─────────────┘                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.3 ArgoCD Application Model

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    ARGOCD APPLICATION HIERARCHY                              │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────┐       │
│   │                    APP-OF-APPS (Root)                            │       │
│   │                                                                  │       │
│   │  This is the "master" application that manages all others.      │       │
│   │  When you deploy this, it creates all child applications.       │       │
│   │                                                                  │       │
│   │  Source: argocd/apps/app-of-apps.yaml                           │       │
│   └─────────────────────────┬───────────────────────────────────────┘       │
│                             │                                                │
│          ┌──────────────────┼──────────────────┐                            │
│          │                  │                  │                            │
│          ▼                  ▼                  ▼                            │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                     │
│   │   Wave 0    │    │   Wave 1    │    │   Wave 2    │                     │
│   │             │    │             │    │             │                     │
│   │ External    │    │ Gatekeeper  │    │Observability│                     │
│   │ Secrets     │    │ (policies)  │    │(Prometheus) │                     │
│   │             │    │             │    │             │                     │
│   │ Must deploy │    │ Depends on  │    │ Depends on  │                     │
│   │ first!      │    │ Wave 0      │    │ Wave 0,1    │                     │
│   └─────────────┘    └─────────────┘    └─────────────┘                     │
│                                                                              │
│   WHY WAVES?                                                                 │
│   ──────────                                                                 │
│   Some applications depend on others. For example:                          │
│   • Gatekeeper can't enforce policies until External Secrets               │
│     provides the secrets it needs                                           │
│   • Prometheus can't scrape metrics until other apps are running           │
│                                                                              │
│   ArgoCD sync waves ensure apps deploy in the correct order.               │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 7.4 Sync Strategies

| Strategy | When to Use | How It Works |
|----------|-------------|--------------|
| **Auto-Sync** | Development environments | ArgoCD automatically applies changes when Git changes |
| **Manual Sync** | Production | Human must click "Sync" to apply changes |
| **Self-Heal** | Always-on environments | ArgoCD reverts manual changes made directly to cluster |
| **Prune** | Cleanup needed | Deletes resources removed from Git |

---

## 8. Observability Architecture

### 8.1 Observability Stack

> 💡 **What is Observability?**
>
> Observability is the ability to understand what's happening inside your system
> by looking at its external outputs: **metrics**, **logs**, and **traces**.

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      OBSERVABILITY ARCHITECTURE                              │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                         DATA SOURCES                                 │   │
│   │                                                                      │   │
│   │   ┌───────────┐  ┌───────────┐  ┌───────────┐  ┌───────────┐       │   │
│   │   │    AKS    │  │   Pods    │  │  Azure    │  │ External  │       │   │
│   │   │   Nodes   │  │           │  │ Services  │  │  Probes   │       │   │
│   │   └─────┬─────┘  └─────┬─────┘  └─────┬─────┘  └─────┬─────┘       │   │
│   │         │              │              │              │              │   │
│   │         │ Node metrics │ Pod metrics  │ Azure diag   │ Black-box   │   │
│   │         │              │              │ metrics      │ metrics     │   │
│   │         └──────────────┴──────────────┴──────────────┘              │   │
│   │                                │                                     │   │
│   └────────────────────────────────┼────────────────────────────────────┘   │
│                                    │                                         │
│                                    ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                         PROMETHEUS                                   │   │
│   │                                                                      │   │
│   │   TIME-SERIES DATABASE FOR METRICS                                  │   │
│   │                                                                      │   │
│   │   • Scrapes metrics from targets every 15-30 seconds               │   │
│   │   • Stores time-series data (who, what, when, how much)            │   │
│   │   • Provides query language (PromQL) for analysis                   │   │
│   │   • Evaluates alerting rules continuously                          │   │
│   │                                                                      │   │
│   │   Example metric:                                                    │   │
│   │   container_cpu_usage_seconds_total{pod="my-app",namespace="prod"}  │   │
│   │                                                                      │   │
│   └─────────────────────────┬───────────────────────────────────────────┘   │
│                             │                                                │
│             ┌───────────────┼───────────────┐                               │
│             │               │               │                               │
│             ▼               ▼               ▼                               │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                    │
│   │   GRAFANA   │    │ALERTMANAGER │    │   AZURE     │                    │
│   │             │    │             │    │  MONITOR    │                    │
│   │ DASHBOARDS  │    │   ALERTS    │    │  (Logs)     │                    │
│   │             │    │             │    │             │                    │
│   │ Visualize   │    │ Route       │    │ Store logs  │                    │
│   │ metrics in  │    │ alerts to   │    │ for long    │                    │
│   │ graphs      │    │ Slack/PD    │    │ retention   │                    │
│   └─────────────┘    └─────────────┘    └─────────────┘                    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.2 Metrics Collection

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    HOW METRICS ARE COLLECTED                                 │
│                                                                              │
│   SCRAPE TARGETS (what Prometheus collects from):                           │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐    │
│   │  1. NODE EXPORTER (runs on every node)                              │    │
│   │                                                                     │    │
│   │  Collects: CPU, memory, disk, network stats for the VM             │    │
│   │  Endpoint: http://node:9100/metrics                                │    │
│   │                                                                     │    │
│   │  Example metrics:                                                   │    │
│   │  • node_cpu_seconds_total                                          │    │
│   │  • node_memory_MemAvailable_bytes                                  │    │
│   │  • node_disk_read_bytes_total                                      │    │
│   └────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐    │
│   │  2. KUBE-STATE-METRICS                                              │    │
│   │                                                                     │    │
│   │  Collects: Kubernetes object states (pods, deployments, etc.)      │    │
│   │  Endpoint: http://kube-state-metrics:8080/metrics                  │    │
│   │                                                                     │    │
│   │  Example metrics:                                                   │    │
│   │  • kube_pod_status_phase                                           │    │
│   │  • kube_deployment_status_replicas_ready                           │    │
│   │  • kube_node_status_condition                                      │    │
│   └────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐    │
│   │  3. APPLICATION METRICS (your apps expose these)                    │    │
│   │                                                                     │    │
│   │  Collects: Business and application-specific metrics               │    │
│   │  Endpoint: http://your-app:8080/metrics                            │    │
│   │                                                                     │    │
│   │  Example metrics:                                                   │    │
│   │  • http_requests_total{method="GET",status="200"}                  │    │
│   │  • order_processing_duration_seconds                               │    │
│   │  • active_users_gauge                                              │    │
│   └────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 8.3 Alert Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ALERT FLOW                                           │
│                                                                              │
│   ┌────────────┐     ┌────────────┐     ┌────────────┐     ┌────────────┐   │
│   │ Prometheus │ ──► │Alertmanager│ ──► │  Routing   │ ──► │   Action   │   │
│   │  (detects) │     │ (receives) │     │  (decides) │     │  (notifies)│   │
│   └────────────┘     └────────────┘     └────────────┘     └────────────┘   │
│                                                                              │
│   EXAMPLE ALERT FLOW:                                                        │
│   ─────────────────────                                                      │
│                                                                              │
│   1. Prometheus detects: CPU > 85% for 10 minutes                           │
│      │                                                                       │
│      ▼                                                                       │
│   2. Fires alert: HighNodeCPU (severity: warning)                           │
│      │                                                                       │
│      ▼                                                                       │
│   3. Alertmanager receives, groups similar alerts                           │
│      │                                                                       │
│      ▼                                                                       │
│   4. Routes based on severity:                                              │
│      │                                                                       │
│      ├── critical ──► PagerDuty (wake someone up!)                          │
│      ├── warning ───► Slack #platform-alerts                                │
│      └── info ──────► Log only                                               │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 9. AI/ML Architecture

### 9.1 AI Foundry Integration

> 💡 **What is Azure AI Foundry?**
>
> Azure AI Foundry is a comprehensive enterprise AI platform that goes far beyond just Azure OpenAI.
> It provides a unified hub for building, deploying, and managing AI solutions at scale, including:
>
> - **Multiple AI Model Providers:** Azure OpenAI (GPT-4, GPT-4o), Anthropic Claude, Meta Llama, Mistral, and more
> - **AI Agent Development:** Tools for building autonomous agents for enterprise workflows
> - **RAG & Knowledge Management:** Vector search, document intelligence, and knowledge bases
> - **Responsible AI:** Built-in content safety, prompt shields, and governance controls
> - **MLOps Integration:** Model versioning, deployment pipelines, and monitoring
> - **Enterprise Security:** Private endpoints, managed identities, and compliance certifications

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AI FOUNDRY ARCHITECTURE                                 │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                     AZURE OPENAI SERVICE                             │   │
│   │                                                                      │   │
│   │  Model Deployments:                                                  │   │
│   │                                                                      │   │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                  │   │
│   │  │   GPT-4o    │  │ GPT-4o-mini │  │ text-embed  │                  │   │
│   │  │             │  │             │  │ -3-large    │                  │   │
│   │  │ Complex     │  │ Simple      │  │             │                  │   │
│   │  │ reasoning   │  │ tasks       │  │ Vector      │                  │   │
│   │  │ $$$        │  │ $           │  │ embeddings  │                  │   │
│   │  │             │  │             │  │ $$          │                  │   │
│   │  │ Capacity:   │  │ Capacity:   │  │ Capacity:   │                  │   │
│   │  │ 10 TPM     │  │ 20 TPM     │  │ 50 TPM     │                  │   │
│   │  └─────────────┘  └─────────────┘  └─────────────┘                  │   │
│   │                                                                      │   │
│   │  Access: Private Endpoint (10.0.4.7)                                │   │
│   │  Auth: Managed Identity (no API keys in code!)                      │   │
│   └─────────────────────────┬───────────────────────────────────────────┘   │
│                             │                                                │
│                             │ Private endpoint                              │
│                             ▼                                                │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    KUBERNETES PODS                                   │   │
│   │                                                                      │   │
│   │   Applications access AI via:                                        │   │
│   │                                                                      │   │
│   │   1. Azure SDK with Managed Identity                                │   │
│   │   2. OpenAI Python client                                           │   │
│   │   3. REST API calls                                                 │   │
│   │                                                                      │   │
│   │   Example usage:                                                     │   │
│   │   ┌──────────────────────────────────────────────────────────────┐  │   │
│   │   │  from azure.identity import DefaultAzureCredential           │  │   │
│   │   │  from openai import AzureOpenAI                              │  │   │
│   │   │                                                               │  │   │
│   │   │  client = AzureOpenAI(                                       │  │   │
│   │   │      azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],     │  │   │
│   │   │      azure_ad_token_provider=get_bearer_token_provider(      │  │   │
│   │   │          DefaultAzureCredential(), "https://cognitiveservic..│  │   │
│   │   │      ),                                                       │  │   │
│   │   │      api_version="2024-02-15-preview"                        │  │   │
│   │   │  )                                                            │  │   │
│   │   └──────────────────────────────────────────────────────────────┘  │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 9.2 Model Selection Guide

| Model | Best For | Cost | Speed | Example Use Cases |
|-------|----------|------|-------|-------------------|
| **GPT-4o** | Complex reasoning, analysis | $$$ | Medium | Code review, complex Q&A, analysis |
| **GPT-4o-mini** | Simple tasks, high volume | $ | Fast | Chatbots, classification, summarization |
| **text-embedding-3-large** | Semantic search | $$ | Fast | RAG, similarity search, recommendations |

---

## 10. Agent Architecture

### 10.1 Agent Categories

The platform includes 23 pre-defined agents organized by horizon:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AGENT ARCHITECTURE                                   │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  H1 FOUNDATION AGENTS (Infrastructure)                               │   │
│   │                                                                      │   │
│   │  • infrastructure-analyzer    - Analyzes Terraform code             │   │
│   │  • security-scanner          - Scans for vulnerabilities            │   │
│   │  • cost-optimizer            - Recommends cost savings              │   │
│   │  • compliance-checker        - Validates against policies           │   │
│   │  • network-diagnostics       - Troubleshoots network issues         │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  H2 ENHANCEMENT AGENTS (Operations)                                  │   │
│   │                                                                      │   │
│   │  • deployment-assistant      - Helps with deployments               │   │
│   │  • incident-responder        - Assists during incidents             │   │
│   │  • performance-tuner         - Optimizes application performance    │   │
│   │  • log-analyzer              - Analyzes logs for patterns           │   │
│   │  • documentation-generator   - Creates documentation                │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  H3 INNOVATION AGENTS (AI/ML)                                        │   │
│   │                                                                      │   │
│   │  • code-reviewer             - Reviews PRs automatically            │   │
│   │  • test-generator            - Generates test cases                 │   │
│   │  • api-designer              - Helps design APIs                    │   │
│   │  • data-analyst              - Analyzes data patterns               │   │
│   │  • ml-model-optimizer        - Tunes ML models                      │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │  CROSS-CUTTING AGENTS (Platform-wide)                                │   │
│   │                                                                      │   │
│   │  • platform-orchestrator     - Coordinates other agents             │   │
│   │  • knowledge-base            - Answers platform questions           │   │
│   │  • onboarding-assistant      - Helps new team members               │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 11. Data Flow Diagrams

### 11.1 Application Deployment Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    APPLICATION DEPLOYMENT DATA FLOW                          │
│                                                                              │
│   Developer                                                                  │
│      │                                                                       │
│      │ 1. git push                                                          │
│      ▼                                                                       │
│   ┌──────────┐                                                              │
│   │  GitHub  │                                                              │
│   └────┬─────┘                                                              │
│        │                                                                     │
│        │ 2. Trigger CI                                                      │
│        ▼                                                                     │
│   ┌──────────────────────────────────────────────────────────────────┐      │
│   │                    GITHUB ACTIONS CI                              │      │
│   │                                                                   │      │
│   │  Jobs:                                                            │      │
│   │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐         │      │
│   │  │  Test    │─►│  Build   │─►│  Scan    │─►│  Push    │         │      │
│   │  │          │  │  Image   │  │  Image   │  │  to ACR  │         │      │
│   │  └──────────┘  └──────────┘  └──────────┘  └────┬─────┘         │      │
│   └──────────────────────────────────────────────────┼───────────────┘      │
│                                                      │                       │
│                                                      │ 3. Push image        │
│                                                      ▼                       │
│                                                 ┌──────────┐                │
│                                                 │   ACR    │                │
│                                                 └────┬─────┘                │
│                                                      │                       │
│   ┌──────────────────────────────────────────────────┼───────────────┐      │
│   │                       ARGOCD                      │               │      │
│   │                                                   │               │      │
│   │  4. Detect Git change                            │               │      │
│   │  5. Compare desired vs actual state              │               │      │
│   │  6. Sync manifests to cluster                    │               │      │
│   │                                                   │               │      │
│   └───────────────────────────┬──────────────────────┘               │      │
│                               │                                       │      │
│                               │ 7. Apply manifests                   │      │
│                               ▼                                       │      │
│   ┌──────────────────────────────────────────────────────────────────┐      │
│   │                    KUBERNETES CLUSTER                             │      │
│   │                                                                   │      │
│   │  8. Create/Update deployment                                     │      │
│   │  9. Pull image from ACR ◄────────────────────────────────────────┘      │
│   │  10. Start new pods                                                     │
│   │  11. Route traffic to new pods                                          │
│   │                                                                          │
│   └──────────────────────────────────────────────────────────────────────────┘
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 11.2 Secret Access Flow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SECRET ACCESS DATA FLOW                              │
│                                                                              │
│   ┌──────────┐  1. Creates ExternalSecret CR  ┌──────────────────────┐      │
│   │ Developer│ ─────────────────────────────► │    Kubernetes API    │      │
│   └──────────┘                                └──────────┬───────────┘      │
│                                                          │                   │
│                                                          │ 2. Notify        │
│                                                          ▼                   │
│   ┌──────────────────────────────────────────────────────────────────┐      │
│   │            EXTERNAL SECRETS OPERATOR (Controller)                 │      │
│   │                                                                   │      │
│   │  3. Read ExternalSecret resource                                 │      │
│   │  4. Determine target: ClusterSecretStore "azure-key-vault"      │      │
│   └───────────────────────────┬──────────────────────────────────────┘      │
│                               │                                              │
│                               │ 5. Request secret via Workload Identity     │
│                               ▼                                              │
│   ┌──────────────────────────────────────────────────────────────────┐      │
│   │                      AZURE KEY VAULT                              │      │
│   │                                                                   │      │
│   │  6. Verify identity (Workload Identity token)                    │      │
│   │  7. Check access policy                                          │      │
│   │  8. Return secret value                                          │      │
│   └───────────────────────────┬──────────────────────────────────────┘      │
│                               │                                              │
│                               │ 9. Secret value                             │
│                               ▼                                              │
│   ┌──────────────────────────────────────────────────────────────────┐      │
│   │            EXTERNAL SECRETS OPERATOR                              │      │
│   │                                                                   │      │
│   │  10. Create Kubernetes Secret with value                         │      │
│   │  11. Set ownership reference to ExternalSecret                   │      │
│   │  12. Schedule refresh (every 1h)                                 │      │
│   └───────────────────────────┬──────────────────────────────────────┘      │
│                               │                                              │
│                               │ 13. K8s Secret created                      │
│                               ▼                                              │
│   ┌──────────────────────────────────────────────────────────────────┐      │
│   │                    APPLICATION POD                                │      │
│   │                                                                   │      │
│   │  14. Mount secret as volume or environment variable              │      │
│   │  15. Use secret in application                                   │      │
│   └──────────────────────────────────────────────────────────────────┘      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 12. Architecture Decision Records

### ADR-001: Use AKS Instead of Self-Managed Kubernetes

**Status:** Accepted

**Context:** We need a Kubernetes platform for container orchestration.

**Decision:** Use Azure Kubernetes Service (AKS) instead of self-managed Kubernetes.

**Rationale:**
- Azure manages the control plane (99.95% SLA)
- Automatic security patches
- Deep Azure integration (identity, networking, storage)
- Lower operational overhead
- Cost: Only pay for worker nodes

**Trade-offs:**
- Less control over control plane configuration
- Tied to Azure's upgrade schedule

---

### ADR-002: Use ArgoCD for GitOps

**Status:** Accepted

**Context:** We need a mechanism to deploy applications declaratively.

**Decision:** Use ArgoCD for GitOps-based deployments.

**Rationale:**
- CNCF graduated project (mature, well-maintained)
- Excellent UI for visibility
- Supports Helm, Kustomize, plain YAML
- Application-centric model fits our needs
- Strong community support

**Alternatives Considered:**
- Flux: Good but less intuitive UI
- Jenkins X: More complex, heavier
- Spinnaker: Enterprise-focused, complex

---

### ADR-003: Use Azure CNI Networking

**Status:** Accepted

**Context:** Need to choose Kubernetes network plugin.

**Decision:** Use Azure CNI instead of kubenet.

**Rationale:**
- Pods get VNet IP addresses directly
- Better integration with Azure services
- Required for some features (Windows nodes, network policies)
- Better performance for large clusters

**Trade-offs:**
- Requires more IP addresses (need larger subnets)
- More complex IP planning

---

### ADR-004: Use External Secrets Operator

**Status:** Accepted

**Context:** Applications need access to secrets stored in Key Vault.

**Decision:** Use External Secrets Operator instead of Key Vault CSI driver.

**Rationale:**
- Works with standard Kubernetes Secrets (no application changes)
- Supports multiple secret stores (flexibility)
- Automatic refresh of secrets
- Better GitOps compatibility

**Trade-offs:**
- Additional component to maintain
- Secrets exist in-cluster (encrypted at rest)

---

## Summary

This Architecture Guide covered:

1. **Three Horizons Model:** How the platform is organized into Foundation, Enhancement, and Innovation layers
2. **Platform Architecture:** High-level view of all components
3. **Infrastructure:** AKS cluster design and node pools
4. **Networking:** VNet topology, subnets, and private endpoints
5. **Security:** Zero trust implementation and secret management
6. **GitOps:** ArgoCD workflow and application model
7. **Observability:** Prometheus, Grafana, and alerting
8. **AI/ML:** Azure AI Foundry - enterprise AI hub with multiple model providers and agent capabilities
9. **Agents:** 10 Copilot Chat Agents for development assistance
10. **Data Flows:** How deployments and secret access work
11. **ADRs:** Key architecture decisions and rationale

For implementation details, see the [Deployment Guide](./DEPLOYMENT_GUIDE.md).

---

## 🤖 Using Copilot Agents for Architecture

| Task | Agent | Example Prompt |
|------|-------|---------------|
| System design | `@architect` | "Design a microservice architecture for order processing" |
| WAF review | `@architect` | "Evaluate this design against the Reliability WAF pillar" |
| Module structure | `@terraform` | "Help me decompose this into reusable Terraform modules" |
| Security review | `@security` | "Review this architecture for Zero Trust compliance" |
| ADR creation | `@docs` | "Create an ADR for choosing Cosmos DB over PostgreSQL" |

> **Tip:** `@architect` will create Mermaid diagrams, evaluate trade-offs, and write ADRs. It automatically hands off to `@terraform` for implementation and `@security` for review.

---

**Document Version:** 2.0.0
**Last Updated:** December 2025
**Maintainer:** Platform Engineering Team
