# Red Hat Developer Hub 1.8 — Official Documentation Guide

> **Comprehensive reference compiled from 31 official Red Hat documents.**
> Use this guide to configure, install, operate, and extend RHDH in any environment.

---

## Table of Contents

1. [What is RHDH](#1-what-is-rhdh)
2. [Architecture & Sizing](#2-architecture--sizing)
3. [Installation](#3-installation)
   - 3.1 [OpenShift (Operator)](#31-openshift-via-operator)
   - 3.2 [OpenShift (Helm)](#32-openshift-via-helm-chart)
   - 3.3 [Azure AKS](#33-azure-aks)
   - 3.4 [Amazon EKS](#34-amazon-eks)
   - 3.5 [Google GKE](#35-google-gke)
4. [First Instance Setup](#4-first-instance-setup)
5. [Configuration](#5-configuration)
   - 5.1 [App Config](#51-app-config)
   - 5.2 [Custom ConfigMaps & Secrets](#52-custom-configmaps--secrets)
   - 5.3 [Environment Variables](#53-environment-variables)
   - 5.4 [Database (PostgreSQL)](#54-database-postgresql)
   - 5.5 [Redis Cache](#55-redis-cache)
6. [Authentication](#6-authentication)
7. [Authorization (RBAC)](#7-authorization-rbac)
8. [Software Catalog](#8-software-catalog)
9. [Software Templates](#9-software-templates)
10. [TechDocs](#10-techdocs)
11. [Dynamic Plugins](#11-dynamic-plugins)
    - 11.1 [Plugin Architecture](#111-plugin-architecture)
    - 11.2 [Enabling Preloaded Plugins](#112-enabling-preloaded-plugins)
    - 11.3 [Installing External Plugins](#113-installing-external-plugins)
    - 11.4 [Dynamic Plugin Factory](#114-dynamic-plugin-factory)
    - 11.5 [Extensions Page (Tech Preview)](#115-extensions-page-technology-preview)
    - 11.6 [Front-End Plugin Wiring](#116-front-end-plugin-wiring)
    - 11.7 [Plugin Reference List](#117-plugin-reference-list)
12. [Using Specific Plugins](#12-using-specific-plugins)
    - 12.1 [Argo CD](#121-argo-cd)
    - 12.2 [Tekton](#122-tekton)
    - 12.3 [Topology](#123-topology)
    - 12.4 [Keycloak](#124-keycloak)
    - 12.5 [Ansible](#125-ansible)
    - 12.6 [JFrog Artifactory](#126-jfrog-artifactory)
    - 12.7 [Nexus Repository Manager](#127-nexus-repository-manager)
13. [Bulk Import](#13-bulk-import)
14. [Customization](#14-customization)
    - 14.1 [Theming & Branding](#141-theming--branding)
    - 14.2 [Home Page](#142-home-page)
    - 14.3 [Learning Paths & Tech Radar](#143-learning-paths--tech-radar)
    - 14.4 [Localization (i18n)](#144-localization-i18n)
    - 14.5 [Quick Start Experience](#145-quick-start-experience)
    - 14.6 [Global Header & FABs](#146-global-header--floating-action-buttons)
15. [GitHub Integration](#15-github-integration)
16. [Orchestrator (Serverless Workflows)](#16-orchestrator-serverless-workflows)
17. [OpenShift AI Connector](#17-openshift-ai-connector)
18. [MCP Tools (AI Integration)](#18-mcp-tools-ai-integration)
19. [Scorecards (Project Health)](#19-scorecards-project-health)
20. [Adoption Insights](#20-adoption-insights)
21. [Monitoring & Logging](#21-monitoring--logging)
22. [Telemetry](#22-telemetry)
23. [Audit Logs](#23-audit-logs)
24. [GitOps Best Practices](#24-gitops-best-practices)
25. [RHDH 1.8 Release Notes](#25-rhdh-18-release-notes)
26. [Troubleshooting Quick Reference](#26-troubleshooting-quick-reference)

---

## 1. What is RHDH

Red Hat Developer Hub (RHDH) is an enterprise-grade **Internal Developer Portal (IDP)** built on Spotify's open-source **Backstage** framework (v1.42.5), extended via **Project Janus**.

**Core capabilities:**

- **Software Catalog** — Centralized inventory of all services, APIs, resources, and teams
- **Software Templates (Golden Paths)** — Standardized scaffolding for new projects
- **TechDocs** — Docs-like-code technical documentation
- **Dynamic Plugins** — Runtime-loadable plugin system (84+ available)
- **RBAC** — Role-based access control for all features
- **Orchestrator** — Serverless workflow engine for automation
- **MCP Tools** — AI model integration (Developer Preview)

**Key differentiators from upstream Backstage:** Enterprise support, dynamic plugin system (no rebuilds), built-in RBAC, Operator/Helm deployment, Red Hat-curated plugin catalog, production-grade security patches.

---

## 2. Architecture & Sizing

### System Architecture

```
┌──────────────────────────────────────────────────┐
│                  Browser (SPA)                    │
│         React + Material UI Frontend              │
└──────────────┬───────────────────────────────────┘
               │ REST API
┌──────────────▼───────────────────────────────────┐
│            RHDH Backend (Node.js)                 │
│  ┌──────────┐ ┌──────────┐ ┌──────────────────┐  │
│  │ Catalog  │ │ Scaffolder│ │ Dynamic Plugins  │  │
│  │ Backend  │ │ Backend   │ │ (runtime loaded) │  │
│  └────┬─────┘ └────┬─────┘ └────────┬─────────┘  │
│       │             │                │             │
│  ┌────▼─────────────▼────────────────▼──────────┐ │
│  │              PostgreSQL Database              │ │
│  └──────────────────────────────────────────────┘ │
│  ┌──────────────────────────────────────────────┐ │
│  │         Optional: Redis Cache                │ │
│  └──────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────┘
```

- **Frontend:** Browser-based SPA (React + Material UI)
- **Backend:** Stateless Node.js server
- **Database:** PostgreSQL (required)
- **Cache:** Redis (optional, recommended for HA)
- **HA Support:** Horizontal scaling with multiple replicas

### Sizing Requirements

| Scale | Catalog Entities | Users | CPU (request/limit) | Memory (request/limit) | DB CPU | DB Memory |
|-------|-----------------|-------|---------------------|----------------------|--------|-----------|
| **Small** | Up to 5,000 | Up to 50 | 1 / 2 cores | 1 GiB / 2 GiB | 0.5 / 1 core | 512 MiB / 1 GiB |
| **Medium** | Up to 25,000 | Up to 200 | 2 / 4 cores | 2 GiB / 4 GiB | 1 / 2 cores | 1 GiB / 2 GiB |
| **Large** | Up to 50,000 | Up to 500 | 4 / 8 cores | 4 GiB / 8 GiB | 2 / 4 cores | 2 GiB / 4 GiB |
| **Enterprise** | Up to 150,000 | Up to 800 | 8 / 16 cores | 8 GiB / 16 GiB | 4 / 8 cores | 4 GiB / 8 GiB |

---

## 3. Installation

RHDH can be installed via **Operator** (OLM-based, recommended) or **Helm chart**.

### Supported Platforms

| Platform | Operator | Helm | HA Support |
|----------|----------|------|------------|
| OpenShift | ✅ | ✅ | ✅ |
| Azure AKS | ✅ | ✅ | ✅ |
| Amazon EKS | ✅ | ✅ | ✅ |
| Google GKE | ✅ | ✅ | ✅ (new in 1.8) |

### 3.1 OpenShift via Operator

1. Go to **OperatorHub** in the OpenShift Console
2. Search for **Red Hat Developer Hub**
3. Install the Operator (select update channel, namespace)
4. Create a `Backstage` CR (Custom Resource):

```yaml
apiVersion: rhdh.redhat.com/v1alpha3
kind: Backstage
metadata:
  name: my-rhdh
  namespace: rhdh
spec:
  application:
    replicas: 1
    route:
      enabled: true
  database:
    enableLocalDb: true  # Uses built-in PostgreSQL
```

> **⚠️ Important (1.8):** Use `v1alpha3` CRs. `v1alpha1`/`v1alpha2` are deprecated and will be removed in 1.9.

### 3.2 OpenShift via Helm Chart

```bash
# Add the Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# Install
helm install my-rhdh openshift-helm-charts/redhat-developer-hub \
  --namespace rhdh --create-namespace
```

### 3.3 Azure AKS

Both Operator and Helm are supported on AKS. Key considerations:

- Use an Azure-managed PostgreSQL or enable the local DB
- Configure Ingress or use Azure Application Gateway
- Set up Azure AD / Entra ID for authentication
- For monitoring, use Azure Monitor (see Section 21)

### 3.4 Amazon EKS

- Use Amazon RDS for PostgreSQL in production
- Configure AWS ALB Ingress Controller
- For monitoring, use Amazon CloudWatch (see Section 21)
- Prometheus metrics via pod annotations

### 3.5 Google GKE

- **New in 1.8:** Full HA support on GKE
- Use Cloud SQL for PostgreSQL
- Configure GKE Ingress

---

## 4. First Instance Setup

After installation, configure these essentials:

1. **Authentication provider** (Section 6)
2. **Application configuration** — custom `app-config.yaml`
3. **Software Catalog** — seed with initial components (Section 8)
4. **RBAC policies** — define roles and permissions (Section 7)
5. **Dynamic plugins** — enable the plugins you need (Section 11)
6. **TechDocs storage** — configure S3 or ODF (Section 10)

### Minimal app-config.yaml

```yaml
app:
  title: My Developer Hub
  baseUrl: https://my-rhdh.example.com

backend:
  baseUrl: https://my-rhdh.example.com
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}

auth:
  providers:
    github:
      development:
        clientId: ${GITHUB_CLIENT_ID}
        clientSecret: ${GITHUB_CLIENT_SECRET}

catalog:
  locations:
    - type: url
      target: https://github.com/my-org/catalog/blob/main/all.yaml
```

---

## 5. Configuration

### 5.1 App Config

RHDH uses `app-config.yaml` files for configuration. Multiple configs can be layered:

- `app-config.yaml` — base config
- `app-config.production.yaml` — production overrides
- Custom ConfigMaps mounted into the pod

### 5.2 Custom ConfigMaps & Secrets

**Operator method:**

```yaml
apiVersion: rhdh.redhat.com/v1alpha3
kind: Backstage
metadata:
  name: my-rhdh
spec:
  application:
    extraFiles:
      configMaps:
        - name: my-app-config
      secrets:
        - name: my-secrets
```

**Helm method:** Use `upstream.backstage.extraAppConfig` and `upstream.backstage.extraEnvVarsSecrets` in `values.yaml`.

### 5.3 Environment Variables

Secrets and sensitive values are injected via environment variables referenced in `app-config.yaml` using `${VAR_NAME}` syntax.

Common environment variables:

| Variable | Purpose |
|----------|---------|
| `POSTGRES_HOST` | Database hostname |
| `POSTGRES_PORT` | Database port |
| `POSTGRES_USER` | Database username |
| `POSTGRES_PASSWORD` | Database password |
| `GITHUB_TOKEN` | GitHub API access |
| `AUTH_GITHUB_CLIENT_ID` | GitHub OAuth App ID |
| `AUTH_GITHUB_CLIENT_SECRET` | GitHub OAuth Secret |
| `LOG_LEVEL` | Logging verbosity (debug/info/warn/error) |
| `SEGMENT_WRITE_KEY` | Custom Segment source key |

### 5.4 Database (PostgreSQL)

- Required for all deployments
- `enableLocalDb: true` creates a built-in PostgreSQL instance (development only)
- For production, use managed PostgreSQL (RDS, Cloud SQL, Azure DB)

### 5.5 Redis Cache

- Optional but recommended for HA deployments
- Improves catalog and TechDocs performance
- Configured in `app-config.yaml` under `backend.cache`

---

## 6. Authentication

RHDH supports multiple authentication providers configured in `app-config.yaml` under `auth.providers`:

| Provider | Config Key | Notes |
|----------|-----------|-------|
| **GitHub** | `github` | OAuth App or GitHub App |
| **GitLab** | `gitlab` | OAuth Application |
| **Microsoft Entra ID** | `microsoft` | Azure AD / Entra ID |
| **Keycloak / OIDC** | `oidc` | Generic OpenID Connect |
| **SAML** | `saml` | Enterprise SSO |
| **Google** | `google` | Google Workspace |
| **Okta** | `okta` | Okta SSO |
| **Guest** | `guest` | Development/testing only |

### GitHub Authentication Example

```yaml
auth:
  environment: production
  providers:
    github:
      production:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
  session:
    secret: ${SESSION_SECRET}

signInPage: github
```

### Keycloak / OIDC Example

```yaml
auth:
  providers:
    oidc:
      production:
        metadataUrl: https://keycloak.example.com/realms/my-realm/.well-known/openid-configuration
        clientId: ${KEYCLOAK_CLIENT_ID}
        clientSecret: ${KEYCLOAK_CLIENT_SECRET}
        prompt: auto
```

---

## 7. Authorization (RBAC)

RHDH uses **Role-Based Access Control** for fine-grained permissions.

### Enabling RBAC

```yaml
permission:
  enabled: true
  rbac:
    admin:
      users:
        - name: user:default/admin-user
    policies-csv-file: /path/to/rbac-policy.csv
```

### Policy Format (CSV)

```csv
# Role assignment
g, user:default/john, role:default/developer

# Permission policies
p, role:default/developer, catalog-entity, read, allow
p, role:default/developer, catalog.entity.create, create, allow
p, role:default/admin, catalog-entity, delete, allow
```

### Key Permission Resources

| Resource | Actions | Description |
|----------|---------|-------------|
| `catalog-entity` | read, create, delete | Software Catalog entities |
| `catalog.entity.refresh` | update | Force catalog refresh |
| `scaffolder-template` | read | View templates |
| `scaffolder-action` | use | Execute scaffolder actions |
| `kubernetes.clusters` | read | View K8s clusters |
| `kubernetes.resources` | read | View K8s resources |
| `kubernetes.proxy` | use | Access pod logs |
| `bulk.import` | read, create, delete | Bulk import operations |
| `scorecard.metric` | read | View Scorecard metrics |
| `policy-entity` | read, create, update, delete | RBAC policy management |
| `ocm.entity.read` | read | Open Cluster Management |
| `ocm.cluster.read` | read | OCM cluster data |

### RBAC via Web UI

Navigate to **Administration → RBAC** in the RHDH sidebar to create roles and assign permissions visually.

---

## 8. Software Catalog

The catalog is the central registry of all software components, APIs, resources, systems, domains, users, and groups.

### Entity Kinds

| Kind | Description |
|------|-------------|
| `Component` | A software component (service, website, library) |
| `API` | An API definition (OpenAPI, gRPC, AsyncAPI) |
| `Resource` | Infrastructure resource (database, S3 bucket) |
| `System` | A collection of related components and APIs |
| `Domain` | A business domain grouping systems |
| `User` | An individual user |
| `Group` | A team or organizational unit |
| `Location` | A pointer to other entity definition files |
| `Template` | A software template |

### catalog-info.yaml Example

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-backend-service
  description: Backend REST API for the application
  tags:
    - java
    - spring-boot
  annotations:
    github.com/project-slug: my-org/my-backend
    backstage.io/techdocs-ref: dir:.
    backstage.io/source-location: url:https://github.com/my-org/my-backend
    jira/project-key: MYPROJ
    argocd/app-name: my-backend-prod
spec:
  type: service
  lifecycle: production
  owner: team-backend
  system: my-application
  providesApis:
    - my-backend-api
  dependsOn:
    - resource:my-database
```

### Adding Entities to Catalog

1. **Manual registration:** Catalog → Register Existing Component → enter URL to `catalog-info.yaml`
2. **Static locations in app-config:**
   ```yaml
   catalog:
     locations:
       - type: url
         target: https://github.com/my-org/my-repo/blob/main/catalog-info.yaml
   ```
3. **Bulk Import:** See Section 13
4. **Discovery providers:** Automatic scanning of GitHub/GitLab organizations

### Catalog Operations

- **Star/Unstar** components for quick access
- **Filter** by kind, type, lifecycle, owner, tags
- **Refresh** individual entities via the sync icon
- **Inspect** entity YAML via the "Inspect" option

---

## 9. Software Templates

Templates (Golden Paths) automate the creation of new projects with best practices baked in.

### Template Structure

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: nestjs-backend-template
  title: NestJS Backend Service
  description: Create a new NestJS backend with OpenShift deployment
  tags:
    - nestjs
    - typescript
    - recommended
spec:
  owner: platform-team
  type: service
  parameters:
    - title: Project Information
      required:
        - name
        - owner
      properties:
        name:
          title: Name
          type: string
          description: Unique name for the component
        owner:
          title: Owner
          type: string
          description: Owner team
          ui:field: OwnerPicker
    - title: Repository
      required:
        - repoUrl
      properties:
        repoUrl:
          title: Repository Location
          type: string
          ui:field: RepoUrlPicker
  steps:
    - id: fetch
      name: Fetch Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          owner: ${{ parameters.owner }}
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        repoUrl: ${{ parameters.repoUrl }}
        description: ${{ parameters.name }} service
    - id: register
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: /catalog-info.yaml
  output:
    links:
      - title: Repository
        url: ${{ steps.publish.output.remoteUrl }}
      - title: Open in Catalog
        icon: catalog
        entityRef: ${{ steps.register.output.entityRef }}
```

### Template Provenance (New in 1.8)

RHDH 1.8 tracks which template created each component, visible in the entity's metadata.

### Key Scaffolder Actions

| Action | Description |
|--------|-------------|
| `fetch:template` | Fetch and render a template |
| `fetch:plain` | Fetch without rendering |
| `publish:github` | Publish to GitHub repository |
| `publish:gitlab` | Publish to GitLab repository |
| `catalog:register` | Register component in catalog |
| `catalog:write` | Write catalog-info.yaml |
| `debug:log` | Log a message for debugging |

---

## 10. TechDocs

TechDocs provides **docs-like-code** technical documentation using MkDocs.

### How It Works

1. Documentation lives alongside code in `docs/` directory
2. `mkdocs.yml` defines the documentation structure
3. RHDH builds and renders documentation on-the-fly or via CI/CD

### Entity Annotation

```yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

### mkdocs.yml Example

```yaml
site_name: My Service Documentation
nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - API Reference: api-reference.md
plugins:
  - techdocs-core
```

### Storage Configuration

**AWS S3:**

```yaml
techdocs:
  builder: external
  publisher:
    type: awsS3
    awsS3:
      bucketName: my-techdocs-bucket
      region: us-east-1
      credentials:
        accessKeyId: ${AWS_ACCESS_KEY_ID}
        secretAccessKey: ${AWS_SECRET_ACCESS_KEY}
```

**OpenShift Data Foundation (ObjectBucketClaim):**

```yaml
techdocs:
  builder: external
  publisher:
    type: awsS3
    awsS3:
      bucketName: ${BUCKET_NAME}
      region: ''
      endpoint: ${BUCKET_HOST}
      s3ForcePathStyle: true
      credentials:
        accessKeyId: ${AWS_ACCESS_KEY_ID}
        secretAccessKey: ${AWS_SECRET_ACCESS_KEY}
```

### CI/CD Pipeline (GitHub Actions)

```yaml
name: Publish TechDocs
on:
  push:
    branches: [main]
    paths: ['docs/**', 'mkdocs.yml']
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - uses: actions/setup-node@v4
      - run: pip install mkdocs-techdocs-core
      - run: npx @techdocs/cli generate --no-docker
      - run: npx @techdocs/cli publish --publisher-type awsS3 \
               --storage-name $BUCKET --entity default/Component/my-service
```

### TechDocs Add-ons

| Add-on | Status | Description |
|--------|--------|-------------|
| **ReportIssue** | Pre-installed | Report issues from docs |
| **TextSize** | External (install) | Adjust text size |
| **LightBox** | External (install) | Image zoom overlay |

---

## 11. Dynamic Plugins

### 11.1 Plugin Architecture

RHDH uses a **dynamic plugin** system that loads plugins at **runtime** — no need to rebuild the application.

- Plugins are packaged as **OCI artifacts** (new standard from 1.8+)
- Legacy wrapper-based plugins are deprecated and will be removed in 1.9
- Plugins can be frontend, backend, or both

### 11.2 Enabling Preloaded Plugins

Many plugins ship preloaded but disabled. Enable in `dynamic-plugins-config.yaml`:

```yaml
plugins:
  - package: ./dynamic-plugins/dist/backstage-plugin-techdocs
    disabled: false
  - package: ./dynamic-plugins/dist/backstage-plugin-techdocs-backend
    disabled: false
```

### 11.3 Installing External Plugins

External plugins are pulled from OCI registries:

```yaml
plugins:
  - package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/plugin-name:tag
    disabled: false
    integrity: sha512-XXXXX
```

### 11.4 Dynamic Plugin Factory

The **Dynamic Plugin Factory** (Developer Preview) is an open-source tool to automate conversion of standard Backstage plugins into RHDH-compatible dynamic plugins.

### 11.5 Extensions Page (Technology Preview)

New in RHDH 1.8: The **Extensions** page provides a centralized UI to browse, enable, and manage plugins directly from the RHDH interface.

- Accessible via **Administration → Extensions**
- Supports RBAC for controlling who can manage plugins
- Dev-only installation mode available

### 11.6 Front-End Plugin Wiring

Dynamic front-end plugins are wired using these mechanisms:

| Mechanism | Purpose |
|-----------|---------|
| `dynamicRoutes` | Register URL routes for plugin pages |
| `mountPoints` | Embed plugin UI into specific page locations |
| `appIcons` | Register custom icons |
| `menuItems` | Add sidebar navigation entries |
| `routeBindings` | Bind plugin routes to external routes |
| `entityTabs` | Add tabs to entity detail pages |
| `apiFactories` | Register API client implementations |
| `translationResources` | Add i18n translation bundles |

### Mount Point Example

```yaml
mountPoints:
  - mountPoint: entity.page.ci/cards
    importName: EntityTektonContent
    config:
      layout:
        gridColumn: 1 / -1
      if:
        allOf:
          - isTektonCIAvailable
```

### Common Mount Points

| Mount Point | Location |
|-------------|----------|
| `entity.page.overview/cards` | Entity Overview tab cards |
| `entity.page.ci/cards` | CI tab content |
| `entity.page.cd/cards` | CD tab content |
| `entity.page.kubernetes/cards` | Kubernetes tab content |
| `entity.page.image-registry/cards` | Image Registry tab |
| `entity.page.topology/cards` | Topology view |
| `entity.page.api/cards` | API tab content |
| `entity.page.docs/cards` | Docs tab content |
| `search.page.types` | Search result types |
| `admin.page.rbac/cards` | RBAC admin cards |

### 11.7 Plugin Reference List

**RHDH 1.8 ships with 84+ dynamic plugins:**

| Category | Count | Support Level |
|----------|-------|---------------|
| Red Hat Supported | 28 | Full SLA |
| Technology Preview | 56 | Limited |
| External Installable | 3 (Ansible) | Separate |
| Deprecated | 2 (OCM) | Being removed |

**Key supported plugins:** Argo CD, GitHub Actions, GitHub Issues, GitLab, Jira, Keycloak, Kubernetes, Tekton, Topology, TechDocs, Scaffolder, Catalog, RBAC, Bulk Import, Orchestrator, Notifications.

**Key Technology Preview plugins:** JFrog Artifactory, Nexus Repository Manager, SonarQube, Azure DevOps, Datadog, Dynatrace, PagerDuty, Jenkins, Lighthouse, 3scale, Quay, ACR, Confluence, Adoption Insights, Scorecards, MCP Tools, Lightspeed.

---

## 12. Using Specific Plugins

### 12.1 Argo CD

Visualize GitOps CD workflows from OpenShift GitOps.

**Required plugins (RHDH 1.8 breaking change):**
- `backstage-plugin-argocd` (frontend)
- `backstage-plugin-kubernetes-backend` (backend) ← **New requirement in 1.8**
- `backstage-plugin-kubernetes` (frontend) ← **New requirement in 1.8**

**Entity annotation:**
```yaml
annotations:
  argocd/app-name: my-app-prod
```

**Usage:** Catalog → Select Component → **CD** tab → View deployments, commit info, history.

### 12.2 Tekton

Visualize CI/CD pipeline runs on Kubernetes/OpenShift.

**Required plugins (RHDH 1.8 breaking change):**
- Tekton frontend + Kubernetes frontend + Kubernetes backend

**Usage:** Catalog → Select Component → **CI** tab → View PipelineRuns, task status, vulnerabilities.

### 12.3 Topology

View workloads as nodes on Kubernetes clusters.

**RBAC permissions required:**
```csv
p, role:default/topology-viewer, kubernetes.clusters.read, read, allow
p, role:default/topology-viewer, kubernetes.resources.read, read, allow
p, role:default/topology-viewer, kubernetes.proxy, use, allow
p, role:default/topology-viewer, catalog-entity, read, allow
```

**Required plugins (RHDH 1.8 breaking change):**
- Topology frontend + Kubernetes frontend + Kubernetes backend

**Usage:** Catalog → Select Component → **TOPOLOGY** tab → View deployments, pods, services.

### 12.4 Keycloak

Synchronizes Keycloak users and groups into the RHDH Software Catalog.

**Capabilities:**
- Import users from a Keycloak realm
- Import groups and group memberships
- Scheduled synchronization

### 12.5 Ansible

Technology Preview. Provides Ansible-specific portal experience with curated learning paths and content creation tools.

### 12.6 JFrog Artifactory

Technology Preview. Displays container image information from JFrog Artifactory registries.

**Usage:** Catalog → Select Component → **Image Registry** tab.

### 12.7 Nexus Repository Manager

Technology Preview. Displays build artifact information from Nexus Repository Manager.

**Usage:** Catalog → Select Component → **BUILD ARTIFACTS** tab.

---

## 13. Bulk Import

Automates onboarding of GitHub/GitLab repositories into the Software Catalog.

### Enabling Bulk Import

```yaml
plugins:
  - package: ./dynamic-plugins/dist/backstage-plugin-bulk-import
    disabled: false
  - package: ./dynamic-plugins/dist/backstage-plugin-bulk-import-backend
    disabled: false
```

### RBAC for Bulk Import

```csv
p, role:default/bulk-import-admin, bulk.import, read, allow
p, role:default/bulk-import-admin, bulk.import, create, allow
p, role:default/bulk-import-admin, bulk.import, delete, allow
```

### Using Bulk Import

1. Navigate to **Bulk Import** in the sidebar
2. Select repositories from GitHub/GitLab
3. Review and approve the auto-generated `catalog-info.yaml` files
4. Confirm import

**New in 1.8:** Bulk Import can now use **scaffolder templates** to generate `catalog-info.yaml` files, providing richer metadata. GitLab Bulk Import is in Technology Preview.

---

## 14. Customization

### 14.1 Theming & Branding

```yaml
app:
  branding:
    fullLogo: ${BASE64_ENCODED_LOGO}
    iconLogo: ${BASE64_ENCODED_ICON}
    theme:
      light:
        primaryColor: '#0066CC'
        headerColor1: '#003366'
        headerColor2: '#0066CC'
        navigationIndicatorColor: '#FF6600'
      dark:
        primaryColor: '#4da6ff'
        headerColor1: '#001a33'
        headerColor2: '#003366'
```

### 14.2 Home Page

The Home Page is customizable with cards and widgets:

```yaml
dynamicPlugins:
  frontend:
    red-hat-developer-hub.backstage-plugin-dynamic-home-page:
      mountPoints:
        - mountPoint: home.page/cards
          importName: SearchBar
          config:
            layouts:
              xl: { w: 10, h: 1, x: 1 }
              lg: { w: 10, h: 1, x: 1 }
        - mountPoint: home.page/cards
          importName: QuickStartGrid
```

### 14.3 Learning Paths & Tech Radar

- **Learning Paths:** Curated educational content accessible from the sidebar
- **Tech Radar:** Technology adoption visualization (Assess → Trial → Adopt → Hold)

### 14.4 Localization (i18n)

New in RHDH 1.8. French localization is built-in. Additional languages can be added via the `translationResources` extension point in dynamic plugins.

### 14.5 Quick Start Experience

New in RHDH 1.8. Guided onboarding experience for new users, configurable on the home page.

### 14.6 Global Header & Floating Action Buttons

- **Global Header:** Custom banner with support links, notifications, user profile
- **FABs:** Floating action buttons for quick actions (e.g., create component, register entity)

---

## 15. GitHub Integration

### GitHub App (Recommended for Organizations)

1. Create a GitHub App with permissions: Contents (Read), Pull Requests (Read/Write), Webhooks
2. Install on your organization
3. Configure in `app-config.yaml`:

```yaml
integrations:
  github:
    - host: github.com
      apps:
        - appId: ${GITHUB_APP_ID}
          clientId: ${GITHUB_APP_CLIENT_ID}
          clientSecret: ${GITHUB_APP_CLIENT_SECRET}
          webhookSecret: ${GITHUB_WEBHOOK_SECRET}
          privateKey: |
            ${GITHUB_APP_PRIVATE_KEY}
```

### GitHub Token (Simpler Setup)

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

---

## 16. Orchestrator (Serverless Workflows)

The Orchestrator plugin enables automated workflows using **SonataFlow** (OpenShift Serverless Logic).

### Use Cases

- **Cloud migration workflows** — guided migration with approval gates
- **Developer onboarding** — automated account/repo/access provisioning
- **Custom workflows** — any multi-step automated process

### Architecture

```
RHDH → Orchestrator Plugin → SonataFlow → Workflow Steps
                                  ↓
                         OpenShift Serverless Logic
                                  ↓
                    External Systems (GitHub, Jira, K8s, etc.)
```

### Enabling Orchestrator

```yaml
plugins:
  - package: ./dynamic-plugins/dist/backstage-plugin-orchestrator
    disabled: false
  - package: ./dynamic-plugins/dist/backstage-plugin-orchestrator-backend
    disabled: false
```

---

## 17. OpenShift AI Connector

Developer Preview. Bridges RHDH with OpenShift AI for AI/ML model management.

### Entity Mapping

| OpenShift AI Resource | RHDH Entity Kind |
|----------------------|------------------|
| InferenceService | Component |
| Model Registry | Resource |
| Model Server API | API |

### Configuration

```yaml
catalog:
  providers:
    openshiftAI:
      default:
        baseUrl: https://openshift-ai.example.com
        serviceAccountToken: ${OPENSHIFT_AI_TOKEN}
```

---

## 18. MCP Tools (AI Integration)

Developer Preview. Provides **Model Context Protocol** integration for connecting AI tools to RHDH.

### Supported MCP Clients

- **Cursor** IDE
- **Continue** IDE extension
- **Developer Lightspeed** (LCS)

### Available MCP Tools

| Tool | Description |
|------|-------------|
| `catalog-search` | Search the Software Catalog (kind, type, name, owner, lifecycle, tags) |
| `fetch-techdocs` | Retrieve TechDocs content |
| `analyze-techdocs-coverage` | Analyze documentation coverage |
| `retrieve-techdocs-content` | Get specific TechDocs pages |

### Enabling MCP

```yaml
plugins:
  - package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/backstage-plugin-mcp-backend
    disabled: false
    pluginConfig:
      mcp:
        server:
          auth:
            type: static
            token: ${MCP_AUTH_TOKEN}
          pluginSources:
            - type: config
              plugins:
                - id: software-catalog
                - id: techdocs
```

### Client Configuration (Cursor Example)

```json
{
  "mcpServers": {
    "rhdh": {
      "url": "https://my-rhdh.example.com/api/mcp/sse",
      "headers": {
        "Authorization": "Bearer ${MCP_AUTH_TOKEN}"
      }
    }
  }
}
```

---

## 19. Scorecards (Project Health)

Developer Preview. KPI visualization for component health using GitHub and Jira data.

### Metrics

| Provider | Metric | Description |
|----------|--------|-------------|
| GitHub | `github.open_prs` | Number of open pull requests |
| Jira | `jira.open_issues` | Number of open issues |

### Enabling Scorecards

```yaml
plugins:
  - package: oci://...red-hat-developer-hub-backstage-plugin-scorecard:...
    disabled: false
  - package: oci://...red-hat-developer-hub-backstage-plugin-scorecard-backend:...
    disabled: false
```

### Configuring Thresholds

```yaml
scorecard:
  plugins:
    github:
      open_prs:
        thresholds:
          rules:
            - key: success
              expression: '<10'
            - key: warning
              expression: '10-50'
            - key: error
              expression: '>50'
```

### Entity-Level Overrides

```yaml
annotations:
  scorecard.io/jira.open_issues.thresholds.rules.warning: '10-15'
  scorecard.io/jira.open_issues.thresholds.rules.error: '>15'
```

### Threshold Precedence

1. **Entity Annotations** (highest) — per-component overrides
2. **App Configuration** — global rules
3. **Provider Defaults** (lowest) — built-in defaults

---

## 20. Adoption Insights

Analytics dashboard tracking RHDH usage across the organization.

### Metrics Tracked

- Active users (daily, weekly, monthly)
- Catalog entity counts by kind
- Template usage frequency
- TechDocs page views
- Plugin usage statistics

### Enabling

```yaml
plugins:
  - package: ./dynamic-plugins/dist/backstage-plugin-adoption-insights
    disabled: false
  - package: ./dynamic-plugins/dist/backstage-plugin-adoption-insights-backend
    disabled: false
```

### RBAC

```csv
p, role:default/insights-viewer, adoption-insights, read, allow
```

---

## 21. Monitoring & Logging

### Log Levels

Set via `LOG_LEVEL` environment variable: `debug`, `info` (default), `warn`, `error`, `critical`.

### Prometheus Metrics (OpenShift)

**Via Operator (built-in in 1.8):**

```yaml
apiVersion: rhdh.redhat.com/v1alpha3
kind: Backstage
spec:
  monitoring:
    enabled: true
```

**Via Helm:**

```yaml
metrics:
  serviceMonitor:
    enabled: true
```

Metrics are exposed at the `/metrics` endpoint.

### AWS Monitoring

**Prometheus:** Add pod annotations:

```yaml
annotations:
  prometheus.io/scrape: 'true'
  prometheus.io/port: '7007'
  prometheus.io/path: '/metrics'
```

**CloudWatch:** Use the CloudWatch agent DaemonSet or Fluent Bit for log forwarding.

### Azure Monitor (AKS)

Use Azure Monitor managed Prometheus and Container Insights:

```bash
az aks update --resource-group myRG --name myAKS \
  --enable-azure-monitor-metrics
```

---

## 22. Telemetry

RHDH collects two types of telemetry:

### Web Analytics (Segment)

- Page visits, button clicks, search terms
- Anonymized IPs and usernames
- Enabled by default via `analytics-provider-segment` plugin

**Disable:**

```yaml
plugins:
  - package: ./dynamic-plugins/dist/janus-idp-backstage-plugin-analytics-provider-segment
    disabled: true  # Set to true to disable
```

**Custom Segment source:**

```yaml
app:
  analytics:
    segment:
      writeKey: ${SEGMENT_WRITE_KEY}
      maskIP: true
      testMode: false
```

### System Observability (OpenTelemetry)

- CPU, memory, traces, spans
- Exportable to any OTLP-compatible backend
- Configurable via OpenTelemetry SDK environment variables

---

## 23. Audit Logs

Chronological records of user actions in RHDH.

### Enabling on OpenShift

Audit logs are sent to stdout by default and can be captured via OpenShift logging.

### Forwarding to Splunk

Use `ClusterLogForwarder`:

```yaml
apiVersion: logging.openshift.io/v1
kind: ClusterLogForwarder
metadata:
  name: rhdh-audit-to-splunk
spec:
  outputs:
    - name: splunk-output
      type: splunk
      splunk:
        indexName: rhdh-audit
      url: https://splunk-hec.example.com:8088
      secret:
        name: splunk-hec-token
  pipelines:
    - name: rhdh-audit-pipeline
      inputRefs:
        - application
      outputRefs:
        - splunk-output
      filterRefs:
        - rhdh-namespace-filter
```

---

## 24. GitOps Best Practices

### Repository Strategy

- **Separate repos** for application code vs. deployment configuration
- **Directories over branches** for environment management (`/environments/dev/`, `/environments/prod/`)
- **Trunk-based development** — short-lived feature branches, frequent merges to main

### Recommended Structure

```
app-repo/              # Application source code
├── src/
├── catalog-info.yaml
├── docs/
│   ├── index.md
│   └── mkdocs.yml
└── Dockerfile

config-repo/           # Deployment configuration
├── environments/
│   ├── dev/
│   │   └── kustomization.yaml
│   ├── staging/
│   │   └── kustomization.yaml
│   └── prod/
│       └── kustomization.yaml
└── base/
    ├── deployment.yaml
    ├── service.yaml
    └── kustomization.yaml
```

---

## 25. RHDH 1.8 Release Notes

### New Features

| Feature | Description |
|---------|-------------|
| **Built-in Operator Monitoring** | ServiceMonitor auto-configured via `spec.monitoring.enabled` |
| **Extensions Page** | Centralized UI to browse/manage plugins (Tech Preview) |
| **French Localization** | Built-in French language support |
| **Enhanced Bulk Import** | Scaffolder template support for catalog-info generation |
| **Template Provenance** | Track which template created each component |
| **Customizable Home Page** | Widget-based home page configuration |
| **Quick Start** | Guided onboarding experience |
| **Plugin Support Indicators** | Transparent display of plugin support levels |
| **GKE HA Support** | High availability on Google GKE |
| **Customizable Container Deployment** | Additional container configuration options |

### Breaking Changes (1.8)

| Change | Impact |
|--------|--------|
| **Argo CD requires K8s plugins** | Must enable `kubernetes` and `kubernetes-backend` plugins |
| **Tekton requires K8s plugins** | Must enable `kubernetes` and `kubernetes-backend` plugins |
| **Topology requires K8s plugins** | Must enable `kubernetes` and `kubernetes-backend` plugins |

### Deprecations

| Item | Timeline |
|------|----------|
| `v1alpha1` / `v1alpha2` CRs | Removed in 1.9 — migrate to `v1alpha3` |
| Bundled plugin wrappers | Transitioning to OCI artifacts in 1.9 |
| OCM plugins | Deprecated |

### Developer Preview Features

Dynamic Plugin Factory, Events module, RHDH Local, Scorecards, OpenShift AI Connector, MCP Tools, Lightspeed Core.

### Known Issues (1.8)

- Orchestrator migration from 1.7 may require manual steps
- `{{firstName}}` in templates may cause errors
- MUI v5 styling conflicts with some custom themes
- OOM errors possible with very large catalogs (>100K entities)

---

## 26. Troubleshooting Quick Reference

| Symptom | Solution |
|---------|----------|
| **Plugin not loading** | Check `dynamic-plugins-config.yaml`, ensure `disabled: false`, verify OCI image reference |
| **Authentication failing** | Verify provider config, check callback URLs, ensure secrets are mounted |
| **Catalog entity not appearing** | Check `catalog-info.yaml` syntax, verify location is registered, check refresh interval |
| **TechDocs not rendering** | Verify `backstage.io/techdocs-ref` annotation, check storage config, rebuild with `techdocs-cli` |
| **RBAC permission denied** | Verify role assignment and permission policies in CSV or UI |
| **Argo CD/Tekton/Topology not working (1.8)** | Enable `kubernetes` + `kubernetes-backend` plugins (new 1.8 requirement) |
| **OOM errors** | Increase memory limits, check catalog entity count vs. sizing table |
| **Bulk Import not finding repos** | Verify GitHub integration credentials and org access |
| **Scorecards not showing metrics** | Check provider config (GitHub/Jira), verify annotations, check RBAC permissions |
| **MCP connection failing** | Verify auth token, check server URL includes `/api/mcp/sse`, verify plugin is enabled |

---

> **Guide Version:** 1.0 — Compiled from RHDH 1.8 official documentation (31 PDF documents)
> **Last Updated:** March 2026
