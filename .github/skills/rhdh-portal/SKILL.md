---
name: rhdh-portal
description: 'Red Hat Developer Hub (RHDH) operations for Three Horizons Accelerator. Use when deploying developer portal, configuring software catalogs, creating golden paths. Covers RHDH installation, Backstage configuration, software templates, catalog entities, TechDocs.'
license: Complete terms in LICENSE.txt
---

# RHDH Portal Skill

Comprehensive skill for Red Hat Developer Hub operations in the Three Horizons Accelerator platform.

**Version:** 1.0.0

---

## USE FOR

- Deploy Red Hat Developer Hub on OpenShift or AKS
- Configure software catalog and entities
- Create and manage golden path templates
- Set up TechDocs documentation
- Configure RHDH plugins and integrations
- Manage team and user onboarding
- Configure GitHub/GitLab integration
- Set up authentication providers (OAuth, OIDC)

## DO NOT USE FOR

- OpenShift cluster operations (use openshift-operations skill)
- ARO deployment (use aro-deployment skill)
- General Kubernetes deployments (use kubectl-cli skill)
- Helm chart management (use helm-cli skill)

---

## Overview

This skill encapsulates all tools required for RHDH operations:
- **MCP Servers**: kubernetes, helm, github
- **Scripts**: onboard-team.sh
- **Terraform Modules**: rhdh
- **Golden Paths**: All templates in golden-paths/
- **Platform Configuration**: platform/rhdh/

---

## MCP Server Configuration

### Kubernetes MCP Server

```json
{
  "kubernetes": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-kubernetes"],
    "capabilities": [
      "kubectl get",
      "kubectl apply",
      "kubectl logs"
    ]
  }
}
```

### GitHub MCP Server

```json
{
  "github": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-github"],
    "capabilities": [
      "gh repo",
      "gh api"
    ]
  }
}
```

---

## RHDH Installation

### Deploy via Helm

```bash
# Add Helm repository
helm repo add backstage https://backstage.github.io/charts
helm repo update

# Create namespace
kubectl create namespace rhdh

# Install RHDH
helm upgrade --install rhdh backstage/backstage \
  --namespace rhdh \
  -f platform/rhdh/values.yaml
```

### Deploy via OpenShift Operator

```yaml
# RHDH Operator Subscription
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh-operator
  namespace: openshift-operators
spec:
  channel: fast
  installPlanApproval: Automatic
  name: rhdh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
---
# RHDH Instance
apiVersion: rhdh.redhat.com/v1alpha1
kind: Backstage
metadata:
  name: developer-hub
  namespace: rhdh
spec:
  application:
    appConfig:
      configMaps:
        - name: app-config
    extraEnvs:
      secrets:
        - name: rhdh-secrets
  database:
    enableLocalDb: false
    externalDb:
      secretName: rhdh-postgresql-credentials
```

---

## Configuration

### App Config

**Path:** `platform/rhdh/app-config.yaml`

```yaml
app:
  title: Three Horizons Developer Hub
  baseUrl: https://developer.${DOMAIN}

organization:
  name: Three Horizons Platform

backend:
  baseUrl: https://developer.${DOMAIN}
  listen:
    port: 7007
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: 5432
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: backstage

auth:
  environment: production
  providers:
    github:
      production:
        clientId: ${GITHUB_CLIENT_ID}
        clientSecret: ${GITHUB_CLIENT_SECRET}

integrations:
  github:
    - host: github.com
      apps:
        - appId: ${GITHUB_APP_ID}
          clientId: ${GITHUB_APP_CLIENT_ID}
          clientSecret: ${GITHUB_APP_CLIENT_SECRET}
          privateKey: ${GITHUB_APP_PRIVATE_KEY}

catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow: [Component, API, Resource, System, Domain, Group, User, Template, Location]
  locations:
    - type: url
      target: https://github.com/org/platform/blob/main/catalog/all.yaml
    - type: url
      target: https://github.com/org/platform/blob/main/golden-paths/all-templates.yaml

techdocs:
  builder: 'external'
  generator:
    runIn: 'local'
  publisher:
    type: 'azureBlobStorage'
    azureBlobStorage:
      containerName: techdocs
      accountName: ${STORAGE_ACCOUNT}

kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - url: ${AKS_API_URL}
          name: production
          authProvider: 'serviceAccount'
          serviceAccountToken: ${K8S_TOKEN}
          skipTLSVerify: true

argocd:
  baseUrl: https://argocd.${DOMAIN}
  instances:
    - name: main
      url: https://argocd.${DOMAIN}
      token: ${ARGOCD_TOKEN}
```

---

## Software Catalog

### Catalog Entity Structure

```yaml
# catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  description: My microservice
  annotations:
    backstage.io/techdocs-ref: dir:.
    github.com/project-slug: org/my-service
    argocd/app-name: my-service-prod
    prometheus.io/scrape: 'true'
  labels:
    tier: backend
    horizon: h2
  tags:
    - python
    - fastapi
    - kubernetes
spec:
  type: service
  lifecycle: production
  owner: team-platform
  system: platform-services
  dependsOn:
    - resource:default/postgresql
    - component:default/auth-service
  providesApis:
    - my-service-api
---
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: my-service-api
  description: My Service REST API
spec:
  type: openapi
  lifecycle: production
  owner: team-platform
  definition:
    $text: https://github.com/org/my-service/blob/main/openapi.yaml
```

### System Definition

```yaml
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: platform-services
  description: Core platform services
spec:
  owner: team-platform
  domain: platform
---
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: platform
  description: Platform Engineering Domain
spec:
  owner: team-platform
```

### Group and User

```yaml
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: team-platform
  description: Platform Engineering Team
spec:
  type: team
  profile:
    displayName: Platform Team
    email: platform@company.com
  children: []
  members:
    - user:john.doe
    - user:jane.smith
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: john.doe
spec:
  profile:
    displayName: John Doe
    email: john.doe@company.com
  memberOf:
    - team-platform
```

---

## Software Templates (Golden Paths)

### Template Structure

**Path:** `golden-paths/h1-foundation/microservice-template/`

```yaml
# template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: microservice-template
  title: Python Microservice
  description: Create a new Python FastAPI microservice
  tags:
    - python
    - fastapi
    - recommended
spec:
  owner: team-platform
  type: service
  
  parameters:
    - title: Service Information
      required:
        - name
        - description
        - owner
      properties:
        name:
          title: Service Name
          type: string
          description: Unique name for the service
          pattern: '^[a-z][a-z0-9-]*$'
          ui:autofocus: true
        description:
          title: Description
          type: string
          description: Brief description of the service
        owner:
          title: Owner
          type: string
          description: Team that owns this service
          ui:field: OwnerPicker
          ui:options:
            catalogFilter:
              kind: Group
              
    - title: Repository Settings
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
            allowedOrganizations:
              - my-org
              
    - title: Deployment Configuration
      properties:
        environment:
          title: Target Environment
          type: string
          default: dev
          enum:
            - dev
            - staging
            - prod
        platform:
          title: Platform
          type: string
          default: aks
          enum:
            - aks
            - aro
          
  steps:
    - id: fetch-template
      name: Fetch Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
          environment: ${{ parameters.environment }}
          platform: ${{ parameters.platform }}
          
    - id: publish-github
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: ${{ parameters.repoUrl }}
        description: ${{ parameters.description }}
        defaultBranch: main
        protectDefaultBranch: true
        
    - id: register-catalog
      name: Register in Catalog
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps['publish-github'].output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
        
    - id: create-argocd-app
      name: Create ArgoCD Application
      action: argocd:create-resources
      input:
        appName: ${{ parameters.name }}-${{ parameters.environment }}
        projectName: default
        repoUrl: ${{ steps['publish-github'].output.remoteUrl }}
        path: deploy/kubernetes
        namespace: ${{ parameters.name }}
        
  output:
    links:
      - title: Repository
        url: ${{ steps['publish-github'].output.remoteUrl }}
      - title: Open in Catalog
        icon: catalog
        entityRef: ${{ steps['register-catalog'].output.entityRef }}
      - title: ArgoCD Application
        url: https://argocd.${DOMAIN}/applications/${{ parameters.name }}
```

### Template Skeleton

```
skeleton/
├── catalog-info.yaml
├── README.md
├── Dockerfile
├── pyproject.toml
├── src/
│   ├── __init__.py
│   ├── main.py
│   └── api/
│       ├── __init__.py
│       └── routes.py
├── tests/
│   └── test_api.py
├── deploy/
│   └── kubernetes/
│       ├── kustomization.yaml
│       ├── deployment.yaml
│       ├── service.yaml
│       └── ingress.yaml
└── .github/
    └── workflows/
        └── ci.yaml
```

---

## Terraform Module Reference

**Path:** `terraform/modules/rhdh/`

```hcl
module "rhdh" {
  source = "./modules/rhdh"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  
  cluster_name       = module.aks.cluster_name
  cluster_endpoint   = module.aks.cluster_endpoint
  
  postgresql = {
    host     = module.databases.postgresql_host
    port     = 5432
    database = "backstage"
    user     = var.rhdh_db_user
    password = var.rhdh_db_password
  }
  
  github = {
    app_id         = var.github_app_id
    client_id      = var.github_client_id
    client_secret  = var.github_client_secret
    private_key    = var.github_private_key
  }
  
  domain = var.domain
  
  storage_account_name = azurerm_storage_account.techdocs.name
  
  tags = local.tags
}
```

---

## Scripts Reference

### Onboard Team Script

**Path:** `scripts/onboard-team.sh`

```bash
#!/bin/bash
# Onboard new team to RHDH

./scripts/onboard-team.sh \
  --team-name "team-payments" \
  --team-email "payments@company.com" \
  --members "john.doe,jane.smith" \
  --github-team "payments-team" \
  --namespace "payments" \
  --argocd-project "payments"
```

---

## Common Operations

### Access RHDH

```bash
# Port forward
kubectl port-forward svc/rhdh-backstage -n rhdh 7007:7007

# Get ingress URL
kubectl get ingress -n rhdh -o jsonpath='{.items[0].spec.rules[0].host}'
```

### Refresh Catalog

```bash
# Trigger catalog refresh via API
curl -X POST "https://developer.${DOMAIN}/api/catalog/refresh" \
  -H "Authorization: Bearer ${RHDH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"entityRef": "location:default/all-templates"}'
```

### Register New Component

```bash
# Via RHDH API
curl -X POST "https://developer.${DOMAIN}/api/catalog/locations" \
  -H "Authorization: Bearer ${RHDH_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "type": "url",
    "target": "https://github.com/org/my-service/blob/main/catalog-info.yaml"
  }'
```

---

## Error Handling

### Common Errors and Solutions

#### Entity Not Found

```bash
# Error: Entity 'component:default/my-service' not found
# Solution: Check catalog-info.yaml and refresh catalog

kubectl logs -n rhdh -l app.kubernetes.io/name=backstage | grep "my-service"
```

#### GitHub Integration Failed

```bash
# Error: Failed to fetch from GitHub
# Solution: Verify GitHub App permissions and credentials

# Check GitHub App settings
gh api /app/installations --jq '.[0].permissions'
```

#### Template Error

```bash
# Error: Failed to execute template step
# Solution: Check template logs and validate YAML

kubectl logs -n rhdh -l app.kubernetes.io/name=backstage -f | grep scaffolder
```

---

## Pre-Deployment Checklist

- [ ] PostgreSQL database provisioned
- [ ] GitHub App created with required permissions
- [ ] OAuth application for authentication
- [ ] Azure Blob Storage for TechDocs
- [ ] Kubernetes cluster accessible
- [ ] ArgoCD configured
- [ ] DNS configured for RHDH domain

## Post-Deployment Validation

```bash
# Check RHDH pods
kubectl get pods -n rhdh

# Check catalog entities
curl "https://developer.${DOMAIN}/api/catalog/entities" \
  -H "Authorization: Bearer ${TOKEN}" | jq '.length'

# Verify templates
curl "https://developer.${DOMAIN}/api/catalog/entities?filter=kind=template" \
  -H "Authorization: Bearer ${TOKEN}" | jq '.[].metadata.name'
```

---

## Related Skills

- [github-cli](../github-cli/) - GitHub CLI reference
- [argocd-cli](../argocd-cli/) - ArgoCD CLI reference
- [kubernetes-operations](../kubectl-cli/) - Kubernetes operations

---

## References

- [Red Hat Developer Hub](https://developers.redhat.com/rhdh)
- [Backstage Documentation](https://backstage.io/docs)
- [Software Templates](https://backstage.io/docs/features/software-templates/)
- [Catalog Model](https://backstage.io/docs/features/software-catalog/descriptor-format)

````
