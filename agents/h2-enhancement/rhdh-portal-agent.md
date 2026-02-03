---
name: "RHDH Portal Agent"
version: "2.0.0"
horizon: "H2"
status: "stable"
last_updated: "2025-12-15"
mcp_servers:
  - azure
  - kubernetes
  - helm
  - github
dependencies:
  - rhdh
  - databases
  - security
---

# RHDH Portal Agent (Dual Platform)

## 🤖 Agent Identity

```yaml
name: rhdh-portal-agent
version: 2.0.0
horizon: H2 - Enhancement
description: |
  Deploys and configures Red Hat Developer Hub (Backstage) 
  with support for:
  - AKS (Azure Kubernetes Service)
  - ARO (Azure Red Hat OpenShift)
  
  Authentication options:
  - Microsoft Entra ID (recommended for GitHub EMU)
  - GitHub OAuth (GitHub Enterprise Cloud)
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

## 📁 Terraform Module
**Primary Module:** `terraform/modules/rhdh/main.tf`

## 📋 Related Resources
| Resource Type | Path |
|--------------|------|
| Terraform Module | `terraform/modules/rhdh/main.tf` |
| Issue Template | `.github/ISSUE_TEMPLATE/rhdh-portal.yml` |
| Helm Values | `platform/rhdh/values.yaml` |
| Golden Paths Integration | `golden-paths/` (all templates register here) |
| ArgoCD Integration | `argocd/applicationsets.yaml` |

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Install on AKS** | Deploy via Helm + OLM | High |
| **Install on ARO** | Deploy via Operator | Medium |
| **Configure Entra ID Auth** | Microsoft SSO + SCIM | Medium |
| **Configure GitHub Auth** | GitHub App OAuth | Medium |
| **Setup Catalog** | Import service catalog | Medium |
| **Enable TechDocs** | Documentation site | Low |
| **Configure Plugins** | ArgoCD, GitHub, Azure | Medium |
| **Create Templates** | Golden Path templates | Medium |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "kubernetes": {
      "required": true,
      "capabilities": ["kubectl", "helm"]
    },
    "azure": {
      "required": true,
      "capabilities": ["az aro", "az aks", "az ad"]
    },
    "github": {
      "required": true
    }
  }
}
```

---

## 🏷️ Trigger Labels

```yaml
primary_label: "agent:rhdh"
required_labels:
  - horizon:h2
platform_labels:
  - platform:aks
  - platform:aro
auth_labels:
  - auth:entra-id
  - auth:github
```

---

## 📋 Issue Template

```markdown
---
title: "[H2] Deploy RHDH Portal - {PROJECT_NAME}"
labels: agent:rhdh, horizon:h2, env:dev
---

## Prerequisites
- [ ] Kubernetes cluster running (AKS or ARO)
- [ ] PostgreSQL database available
- [ ] DNS configured for portal domain

## Platform Selection

- [ ] **AKS** (Azure Kubernetes Service)
  - Requires OLM installation
  - Uses Kubernetes Ingress
  
- [ ] **ARO** (Azure Red Hat OpenShift)
  - OLM built-in
  - Uses OpenShift Routes

## Authentication Provider

- [ ] **Microsoft Entra ID** (Recommended for EMU)
  - Tenant ID: ___
  - Enterprise App configured: [ ]
  - GitHub EMU slug (if applicable): ___
  
- [ ] **GitHub OAuth** (GitHub Enterprise Cloud)
  - Organization: ___
  - GitHub App created: [ ]
  - Enterprise Server URL (optional): ___

## Configuration

```yaml
rhdh:
  version: "1.8"
  namespace: "rhdh"
  
  # Platform Selection
  platform: "aks"  # or "aro"
  
  # Domain
  domain: "developer.${DOMAIN}"
  
  # Authentication
  auth:
    provider: "entra-id"  # or "github"
    
    # If Entra ID
    entra_id:
      tenant_id: "${AZURE_TENANT_ID}"
      client_id: "${ENTRA_CLIENT_ID}"
      
    # If GitHub
    github:
      organization: "${GITHUB_ORG}"
      enterprise_url: ""  # For GHE only
      
  # Database
  database:
    type: "postgresql"
    host: "${PROJECT}-postgres.postgres.database.azure.com"
    
  # Catalog
  catalog:
    locations:
      - type: "url"
        target: "https://github.com/${ORG}/platform-catalog/blob/main/all.yaml"
        
  # Plugins
  plugins:
    argocd:
      enabled: true
      url: "https://argocd.${DOMAIN}"
    github:
      enabled: true
    azure:
      enabled: true
    kubernetes:
      enabled: true
      
  # TechDocs
  techdocs:
    builder: "external"
    storage: "azureBlobStorage"
```

## Acceptance Criteria
- [ ] RHDH pods running
- [ ] Portal accessible via domain
- [ ] SSO authentication working
- [ ] Catalog populated
- [ ] Plugins configured
- [ ] Templates visible
```

---

## 🛠️ Installation - AKS Platform

### Step 1: Install OLM (Operator Lifecycle Manager)

```bash
# OLM is NOT built-in on AKS
curl -sL https://github.com/operator-framework/operator-lifecycle-manager/releases/download/v0.28.0/install.sh | bash -s v0.28.0

# Verify OLM
kubectl get pods -n olm
```

### Step 2: Install Red Hat Ecosystem Catalog

```bash
# Create pull secret for Red Hat registry
kubectl create secret docker-registry rh-pull-secret \
  --namespace rhdh \
  --docker-server=registry.redhat.io \
  --docker-username="${RH_USERNAME}" \
  --docker-password="${RH_PASSWORD}"

# Install catalog source
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: redhat-operators
  namespace: olm
spec:
  sourceType: grpc
  image: registry.redhat.io/redhat/redhat-operator-index:v4.15
  displayName: Red Hat Operators
  publisher: Red Hat
  secrets:
    - rh-pull-secret
EOF
```

### Step 3: Install RHDH Operator

```bash
# Create subscription
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh
  namespace: rhdh
spec:
  channel: fast-1.8
  name: rhdh
  source: redhat-operators
  sourceNamespace: olm
EOF

# Wait for operator
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=rhdh-operator -n rhdh --timeout=300s
```

### Step 4: Create Ingress (AKS Only)

```yaml
# rhdh-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rhdh-ingress
  namespace: rhdh
  annotations:
    kubernetes.io/ingress.class: "webapprouting.kubernetes.azure.com"
    # For nginx:
    # kubernetes.io/ingress.class: "nginx"
spec:
  ingressClassName: webapprouting.kubernetes.azure.com
  tls:
    - hosts:
        - developer.${DOMAIN}
      secretName: rhdh-tls
  rules:
    - host: developer.${DOMAIN}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: backstage-developer-hub
                port:
                  name: http-backend
```

---

## 🛠️ Installation - ARO Platform

### Step 1: Install via OperatorHub (Built-in)

```bash
# On ARO, use the web console:
# 1. Go to Operators → OperatorHub
# 2. Search for "Red Hat Developer Hub"
# 3. Click Install
# 4. Select channel: fast-1.8
# 5. Install in rhdh namespace

# Or via CLI:
kubectl apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh
  namespace: rhdh
spec:
  channel: fast-1.8
  name: rhdh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

### Step 2: Route is Automatic (ARO)

```yaml
# OpenShift creates Route automatically
# Access: https://backstage-developer-hub-rhdh.apps.${CLUSTER_DOMAIN}
```

---

## 🔐 Authentication - Microsoft Entra ID

### Step 1: Register Azure AD Application

```bash
# Create app registration
az ad app create \
  --display-name "Red Hat Developer Hub" \
  --sign-in-audience AzureADMyOrg \
  --web-redirect-uris "https://developer.${DOMAIN}/api/auth/microsoft/handler/frame"

# Get app ID
APP_ID=$(az ad app list --display-name "Red Hat Developer Hub" --query "[0].appId" -o tsv)

# Create service principal
az ad sp create --id ${APP_ID}

# Create client secret
CLIENT_SECRET=$(az ad app credential reset --id ${APP_ID} --query password -o tsv)

# Grant API permissions
az ad app permission add --id ${APP_ID} \
  --api 00000003-0000-0000-c000-000000000000 \
  --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope  # User.Read
```

### Step 2: Configure RHDH for Entra ID

```yaml
# app-config-rhdh.yaml
auth:
  environment: production
  providers:
    microsoft:
      production:
        clientId: ${ENTRA_CLIENT_ID}
        clientSecret: ${ENTRA_CLIENT_SECRET}
        tenantId: ${AZURE_TENANT_ID}
        
signInPage: microsoft

# Sync users from Entra ID
catalog:
  providers:
    microsoftGraphOrg:
      default:
        tenantId: ${AZURE_TENANT_ID}
        clientId: ${ENTRA_CLIENT_ID}
        clientSecret: ${ENTRA_CLIENT_SECRET}
        userSelect: ['id', 'displayName', 'mail', 'jobTitle']
        groupSelect: ['id', 'displayName', 'description']
        schedule:
          frequency: { hours: 1 }
          timeout: { minutes: 50 }
```

---

## 🔐 Authentication - GitHub OAuth

### Step 1: Create GitHub App

```bash
# Create via GitHub UI or API:
# 1. Go to Organization Settings → Developer Settings → GitHub Apps
# 2. New GitHub App:
#    - Name: "Developer Hub - ${ORG}"
#    - Homepage URL: https://developer.${DOMAIN}
#    - Callback URL: https://developer.${DOMAIN}/api/auth/github/handler/frame
#    - Webhook URL: https://developer.${DOMAIN}
#    - Permissions:
#      - Repository: Read (Contents, Metadata)
#      - Organization: Read (Members)
#    - Generate Private Key
#    - Note Client ID and Client Secret
```

### Step 2: Configure RHDH for GitHub

```yaml
# app-config-rhdh.yaml
auth:
  environment: production
  providers:
    github:
      production:
        clientId: ${GITHUB_APP_CLIENT_ID}
        clientSecret: ${GITHUB_APP_CLIENT_SECRET}
        # For GitHub Enterprise Server:
        # enterpriseInstanceUrl: https://ghe.company.com
        
signInPage: github

# Sync users from GitHub org
catalog:
  providers:
    github:
      providerId:
        organization: ${GITHUB_ORG}
        catalogPath: /catalog-info.yaml
        filters:
          branch: main
          repository: '.*'
        schedule:
          frequency: { minutes: 30 }
          timeout: { minutes: 3 }
          
# GitHub integration
integrations:
  github:
    - host: github.com
      apps:
        - appId: ${GITHUB_APP_ID}
          clientId: ${GITHUB_APP_CLIENT_ID}
          clientSecret: ${GITHUB_APP_CLIENT_SECRET}
          privateKey: |
            ${GITHUB_APP_PRIVATE_KEY}
```

---

## 📦 Full RHDH Custom Resource

```yaml
# rhdh-instance.yaml
apiVersion: rhdh.redhat.com/v1alpha1
kind: Backstage
metadata:
  name: developer-hub
  namespace: rhdh
spec:
  application:
    replicas: 2
    
    appConfig:
      configMaps:
        - name: app-config-rhdh
        
    extraEnvs:
      secrets:
        - name: rhdh-secrets
        
  database:
    enableLocalDb: false
    
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-rhdh
  namespace: rhdh
data:
  app-config.yaml: |
    app:
      title: "Developer Hub"
      baseUrl: https://developer.${DOMAIN}
      
    backend:
      baseUrl: https://developer.${DOMAIN}
      database:
        client: pg
        connection:
          host: ${POSTGRES_HOST}
          port: 5432
          user: rhdh
          password: ${POSTGRES_PASSWORD}
          
    # Auth config (Entra ID or GitHub - choose one)
    auth:
      environment: production
      providers:
        # Option 1: Microsoft Entra ID
        microsoft:
          production:
            clientId: ${ENTRA_CLIENT_ID}
            clientSecret: ${ENTRA_CLIENT_SECRET}
            tenantId: ${AZURE_TENANT_ID}
            
        # Option 2: GitHub
        # github:
        #   production:
        #     clientId: ${GITHUB_APP_CLIENT_ID}
        #     clientSecret: ${GITHUB_APP_CLIENT_SECRET}
            
    signInPage: microsoft  # or github
    
    # Plugins
    argocd:
      baseUrl: https://argocd.${DOMAIN}
      
    kubernetes:
      serviceLocatorMethod:
        type: multiTenant
      clusterLocatorMethods:
        - type: config
          clusters:
            - name: ${AKS_NAME}
              url: ${AKS_URL}
              authProvider: serviceAccount
              serviceAccountToken: ${K8S_TOKEN}
              
    techdocs:
      builder: external
      generator:
        runIn: docker
      publisher:
        type: azureBlobStorage
        azureBlobStorage:
          accountName: ${STORAGE_ACCOUNT}
          containerName: techdocs
```

---

## ✅ Validation Criteria

```yaml
validation:
  deployment:
    aks:
      - olm_running: true
      - operator_installed: true
      - pods_running: ">= 2"
      - ingress_configured: true
      
    aro:
      - operator_installed: true
      - pods_running: ">= 2"
      - route_created: true
      
  authentication:
    entra_id:
      - app_registration: true
      - sso_login_test: "successful"
      - user_sync: "working"
      
    github:
      - github_app_created: true
      - oauth_flow: "working"
      - org_sync: "working"
      
  plugins:
    - argocd_connected: true
    - github_connected: true
    - kubernetes_connected: true
    
  catalog:
    - entities_discovered: "> 0"
    - templates_visible: true
```

---

## 💬 Agent Communication

### On Success (AKS)
```markdown
✅ **RHDH Portal Deployed on AKS**

**Platform:** Azure Kubernetes Service
**Access:** https://developer.${DOMAIN}

**Authentication:**
- Provider: ${auth_provider}
- SSO: ✅ Working
- User Sync: ✅ Enabled

**Infrastructure:**
- OLM: ✅ Installed
- Operator: ✅ Running
- Ingress: ✅ Configured

**Catalog:**
- Components: 12 discovered
- Templates: 8 registered

**Plugins:**
| Plugin | Status |
|--------|--------|
| ArgoCD | ✅ Connected |
| GitHub | ✅ Connected |
| Kubernetes | ✅ Connected |

🎉 Closing this issue.
```

### On Success (ARO)
```markdown
✅ **RHDH Portal Deployed on ARO**

**Platform:** Azure Red Hat OpenShift
**Access:** https://developer-hub-rhdh.apps.${CLUSTER_DOMAIN}

**Authentication:**
- Provider: ${auth_provider}
- SSO: ✅ Working

**Infrastructure:**
- Operator: ✅ Running (via OperatorHub)
- Route: ✅ Auto-configured

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `infrastructure-agent` | **Prerequisite** |
| `database-agent` | **Prerequisite** |
| `gitops-agent` | **Prerequisite** |
| `golden-paths-agent` | **Post** |

---

## 📚 Official Documentation

- [RHDH on AKS](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.8/html-single/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks/)
- [RHDH on OpenShift](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.8/html/installing_red_hat_developer_hub_on_openshift_container_platform/)
- [RHDH Authentication](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.8/html/authentication/)
- [GitHub EMU Setup](https://resources.github.com/github-enterprise/emu-getting-started-guide/)

---

**Spec Version:** 2.0.0
