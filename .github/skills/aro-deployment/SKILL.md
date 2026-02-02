---
name: aro-deployment
description: 'Azure Red Hat OpenShift (ARO) deployment and configuration for Three Horizons Accelerator. Use when deploying new ARO clusters, configuring OAuth, installing operators, deploying RHDH on OpenShift. Covers full platform setup from scratch to production-ready.'
license: Complete terms in LICENSE.txt
---

# ARO Deployment Skill

Comprehensive skill for deploying and configuring Azure Red Hat OpenShift (ARO) as the enterprise Kubernetes platform.

**Version:** 1.0.0

---

## USE FOR

- Deploy new Azure Red Hat OpenShift clusters
- Configure ARO cluster OAuth and authentication
- Install required OpenShift operators (GitOps, External Secrets)
- Deploy RHDH on OpenShift platform
- Configure ARO networking and private clusters
- Set up ARO integration with Azure services
- run deploy-aro.sh script

## DO NOT USE FOR

- Day-to-day OpenShift operations (use openshift-operations skill)
- Vanilla AKS deployment (use azure-infrastructure skill)
- General Kubernetes workloads (use kubectl-cli skill)
- Non-OpenShift Helm deployments (use helm-cli skill)

---

## Overview

This skill covers the complete ARO deployment lifecycle:
- **MCP Servers**: azure, openshift, kubernetes, helm
- **Scripts**: deploy-aro.sh, setup-github-app.sh
- **Agents**: aro-platform-agent
- **Components**: ARO Cluster, RHDH, OpenShift GitOps, External Secrets

---

## MCP Server Configuration

### ARO MCP Server (Azure)

```json
{
  "aro": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-azure"],
    "capabilities": [
      "az aro create",
      "az aro delete",
      "az aro list",
      "az aro show",
      "az aro update",
      "az aro list-credentials"
    ]
  }
}
```

### OpenShift MCP Server

```json
{
  "openshift": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-openshift"],
    "env": {
      "KUBECONFIG": "${KUBECONFIG}"
    },
    "capabilities": [
      "oc login",
      "oc new-project",
      "oc apply",
      "oc adm",
      "oc create",
      "oc get"
    ]
  }
}
```

---

## Prerequisites

### Required Tools

```bash
# Azure CLI
az version  # >= 2.50.0

# OpenShift CLI (oc)
oc version  # >= 4.14

# Helm (for non-operator deployments)
helm version

# jq for JSON processing
jq --version
```

### Azure Requirements

```bash
# Login to Azure
az login

# Check subscription
az account show

# Register required providers
az provider register -n Microsoft.RedHatOpenShift --wait
az provider register -n Microsoft.Compute --wait
az provider register -n Microsoft.Storage --wait
az provider register -n Microsoft.Authorization --wait
az provider register -n Microsoft.Network --wait
```

### Red Hat Pull Secret

```bash
# Download from: https://console.redhat.com/openshift/install/pull-secret
# Save to: pull-secret.txt

# Validate JSON format
cat pull-secret.txt | jq .
```

---

## Deployment Script

### Quick Deploy

**Path:** `scripts/deploy-aro.sh`

```bash
# Basic ARO deployment
./scripts/deploy-aro.sh \
  --cluster-name aro-prod \
  --resource-group rg-aro-prod \
  --location brazilsouth \
  --pull-secret ./pull-secret.txt

# Full platform deployment
./scripts/deploy-aro.sh \
  --cluster-name aro-prod \
  --resource-group rg-aro-prod \
  --location brazilsouth \
  --pull-secret ./pull-secret.txt \
  --sizing-profile large \
  --enable-gitops \
  --enable-rhdh

# Dry-run mode
./scripts/deploy-aro.sh \
  --cluster-name aro-prod \
  --resource-group rg-aro-prod \
  --location brazilsouth \
  --pull-secret ./pull-secret.txt \
  --dry-run
```

### Sizing Profiles

| Profile | Workers | Worker Size | Master Size |
|---------|---------|-------------|-------------|
| small | 3 | Standard_D4s_v3 | Standard_D8s_v3 |
| medium | 5 | Standard_D8s_v3 | Standard_D8s_v3 |
| large | 10 | Standard_D16s_v3 | Standard_D16s_v3 |
| xlarge | 20 | Standard_D32s_v3 | Standard_D16s_v3 |

---

## Step-by-Step Manual Deployment

### 1. Create Resource Group

```bash
export CLUSTER_NAME="aro-prod"
export RESOURCE_GROUP="rg-aro-prod"
export LOCATION="brazilsouth"

az group create \
  --name ${RESOURCE_GROUP} \
  --location ${LOCATION}
```

### 2. Create Virtual Network

```bash
export VNET_NAME="${CLUSTER_NAME}-vnet"

# Create VNet
az network vnet create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${VNET_NAME} \
  --address-prefixes 10.0.0.0/16

# Create master subnet
az network vnet subnet create \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name master-subnet \
  --address-prefixes 10.0.0.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

# Create worker subnet
az network vnet subnet create \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name worker-subnet \
  --address-prefixes 10.0.2.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

# Disable private link policies (required for ARO)
az network vnet subnet update \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name master-subnet \
  --disable-private-link-service-network-policies true
```

### 3. Create Service Principal

```bash
# Get subscription ID
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

# Create SP
SP_INFO=$(az ad sp create-for-rbac \
  --name "${CLUSTER_NAME}-sp" \
  --role Contributor \
  --scopes /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP})

SP_CLIENT_ID=$(echo $SP_INFO | jq -r '.appId')
SP_CLIENT_SECRET=$(echo $SP_INFO | jq -r '.password')

echo "SP Client ID: ${SP_CLIENT_ID}"
```

### 4. Create ARO Cluster

```bash
# Create cluster (30-45 minutes)
az aro create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${CLUSTER_NAME} \
  --vnet ${VNET_NAME} \
  --master-subnet master-subnet \
  --worker-subnet worker-subnet \
  --worker-count 3 \
  --worker-vm-size Standard_D4s_v3 \
  --master-vm-size Standard_D8s_v3 \
  --client-id ${SP_CLIENT_ID} \
  --client-secret ${SP_CLIENT_SECRET} \
  --pull-secret @pull-secret.txt \
  --domain ${CLUSTER_NAME}

echo "Cluster creation started... this takes 30-45 minutes"
```

### 5. Get Credentials and Login

```bash
# Get API server URL
API_SERVER=$(az aro show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${CLUSTER_NAME} \
  --query apiserverProfile.url -o tsv)

# Get kubeadmin password
KUBEADMIN_PASSWORD=$(az aro list-credentials \
  --resource-group ${RESOURCE_GROUP} \
  --name ${CLUSTER_NAME} \
  --query kubeadminPassword -o tsv)

# Get console URL
CONSOLE_URL=$(az aro show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${CLUSTER_NAME} \
  --query consoleProfile.url -o tsv)

echo "Console: ${CONSOLE_URL}"
echo "API: ${API_SERVER}"

# Login with oc
oc login ${API_SERVER} \
  --username kubeadmin \
  --password ${KUBEADMIN_PASSWORD} \
  --insecure-skip-tls-verify=true
```

---

## Configure Entra ID OAuth

### 1. Create Entra ID Application

```bash
# Create Entra app for OAuth
ENTRA_APP=$(az ad app create \
  --display-name "${CLUSTER_NAME}-oauth" \
  --web-redirect-uris "https://oauth-openshift.apps.${CLUSTER_NAME}.${LOCATION}.aroapp.io/oauth2callback/EntraID" \
  --sign-in-audience AzureADMyOrg)

ENTRA_APP_ID=$(echo $ENTRA_APP | jq -r '.appId')

# Create secret
ENTRA_SECRET=$(az ad app credential reset \
  --id ${ENTRA_APP_ID} \
  --display-name "oauth-secret")

ENTRA_CLIENT_SECRET=$(echo $ENTRA_SECRET | jq -r '.password')

# Get tenant ID
TENANT_ID=$(az account show --query tenantId -o tsv)
```

### 2. Configure OpenShift OAuth

```bash
# Create secret for client credentials
oc create secret generic entra-client-secret \
  --namespace openshift-config \
  --from-literal=clientSecret=${ENTRA_CLIENT_SECRET}

# Apply OAuth configuration
cat << EOF | oc apply -f -
apiVersion: config.openshift.io/v1
kind: OAuth
metadata:
  name: cluster
spec:
  identityProviders:
  - name: EntraID
    mappingMethod: claim
    type: OpenID
    openID:
      clientID: ${ENTRA_APP_ID}
      clientSecret:
        name: entra-client-secret
      claims:
        preferredUsername:
        - preferred_username
        name:
        - name
        email:
        - email
        groups:
        - groups
      issuer: https://login.microsoftonline.com/${TENANT_ID}/v2.0
      extraScopes:
      - email
      - profile
EOF

echo "OAuth configured - users can now login with Entra ID"
```

### 3. Configure RBAC for Entra Groups

```bash
# Get Entra group IDs
ADMIN_GROUP_ID="<your-admin-group-id>"
DEVELOPER_GROUP_ID="<your-developer-group-id>"

# Cluster admin binding
cat << EOF | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: entra-cluster-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: ${ADMIN_GROUP_ID}
EOF

# Developer binding
cat << EOF | oc apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: entra-developers
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: edit
subjects:
- apiGroup: rbac.authorization.k8s.io
  kind: Group
  name: ${DEVELOPER_GROUP_ID}
EOF
```

---

## Install OpenShift GitOps (ArgoCD)

### Deploy Operator

```bash
# Install GitOps operator
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-operators
spec:
  channel: latest
  installPlanApproval: Automatic
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

# Wait for operator
oc wait --for=condition=Ready pod \
  -l app.kubernetes.io/name=openshift-gitops-operator \
  -n openshift-operators \
  --timeout=300s

# Get ArgoCD route
ARGOCD_ROUTE=$(oc get route openshift-gitops-server \
  -n openshift-gitops \
  -o jsonpath='{.spec.host}')

echo "ArgoCD URL: https://${ARGOCD_ROUTE}"

# Get ArgoCD admin password
ARGOCD_PASSWORD=$(oc get secret openshift-gitops-cluster \
  -n openshift-gitops \
  -o jsonpath='{.data.admin\.password}' | base64 -d)

echo "ArgoCD Admin Password: ${ARGOCD_PASSWORD}"
```

### Configure ArgoCD for GitHub

```bash
# Create repository secret
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: repo-platform
  namespace: openshift-gitops
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/org/platform-repo.git
  password: ${GITHUB_TOKEN}
  username: git
EOF
```

---

## Deploy Red Hat Developer Hub (RHDH)

### 1. Install RHDH Operator

```bash
# Create namespace
oc new-project rhdh

# Install RHDH operator
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: rhdh
  namespace: openshift-operators
spec:
  channel: fast
  installPlanApproval: Automatic
  name: rhdh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

# Wait for CRD
oc wait --for=condition=Established \
  crd/backstages.rhdh.redhat.com \
  --timeout=300s
```

### 2. Create PostgreSQL for RHDH

```bash
# Deploy PostgreSQL
cat << EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgresql
  namespace: rhdh
spec:
  replicas: 1
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
    spec:
      containers:
      - name: postgresql
        image: registry.redhat.io/rhel9/postgresql-15:latest
        env:
        - name: POSTGRESQL_USER
          value: rhdh
        - name: POSTGRESQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: postgresql-credentials
              key: password
        - name: POSTGRESQL_DATABASE
          value: backstage
        ports:
        - containerPort: 5432
        volumeMounts:
        - name: data
          mountPath: /var/lib/pgsql/data
      volumes:
      - name: data
        persistentVolumeClaim:
          claimName: postgresql-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: postgresql
  namespace: rhdh
spec:
  selector:
    app: postgresql
  ports:
  - port: 5432
---
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-credentials
  namespace: rhdh
stringData:
  password: "${RHDH_DB_PASSWORD}"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgresql-pvc
  namespace: rhdh
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF
```

### 3. Create RHDH Secrets

```bash
# Create GitHub App credentials
cat << EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: rhdh-secrets
  namespace: rhdh
stringData:
  GITHUB_APP_ID: "${GITHUB_APP_ID}"
  GITHUB_APP_CLIENT_ID: "${GITHUB_APP_CLIENT_ID}"
  GITHUB_APP_CLIENT_SECRET: "${GITHUB_APP_CLIENT_SECRET}"
  GITHUB_APP_PRIVATE_KEY: |
    ${GITHUB_APP_PRIVATE_KEY}
  AUTH_GITHUB_CLIENT_ID: "${GITHUB_OAUTH_CLIENT_ID}"
  AUTH_GITHUB_CLIENT_SECRET: "${GITHUB_OAUTH_CLIENT_SECRET}"
EOF
```

### 4. Create RHDH Configuration

```bash
# App config
cat << EOF | oc apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-rhdh
  namespace: rhdh
data:
  app-config-rhdh.yaml: |
    app:
      title: Three Horizons Developer Hub
      baseUrl: https://developer-hub-rhdh.apps.${CLUSTER_NAME}.${LOCATION}.aroapp.io
    
    organization:
      name: Three Horizons Platform
    
    backend:
      baseUrl: https://developer-hub-rhdh.apps.${CLUSTER_NAME}.${LOCATION}.aroapp.io
      database:
        client: pg
        connection:
          host: postgresql.rhdh.svc.cluster.local
          port: 5432
          user: rhdh
          password: \${POSTGRESQL_PASSWORD}
          database: backstage
    
    auth:
      environment: production
      providers:
        github:
          production:
            clientId: \${AUTH_GITHUB_CLIENT_ID}
            clientSecret: \${AUTH_GITHUB_CLIENT_SECRET}
    
    integrations:
      github:
        - host: github.com
          apps:
            - appId: \${GITHUB_APP_ID}
              clientId: \${GITHUB_APP_CLIENT_ID}
              clientSecret: \${GITHUB_APP_CLIENT_SECRET}
              privateKey: \${GITHUB_APP_PRIVATE_KEY}
    
    catalog:
      locations:
        - type: url
          target: https://github.com/org/platform/blob/main/catalog/all.yaml
    
    kubernetes:
      serviceLocatorMethod:
        type: 'multiTenant'
      clusterLocatorMethods:
        - type: 'config'
          clusters:
            - url: ${API_SERVER}
              name: aro-production
              authProvider: 'serviceAccount'
EOF
```

### 5. Deploy RHDH Instance

```bash
# Create Backstage instance
cat << EOF | oc apply -f -
apiVersion: rhdh.redhat.com/v1alpha1
kind: Backstage
metadata:
  name: developer-hub
  namespace: rhdh
spec:
  application:
    appConfig:
      mountPath: /opt/app-root/src
      configMaps:
        - name: app-config-rhdh
    extraFiles:
      mountPath: /opt/app-root/src
      secrets:
        - name: rhdh-secrets
    extraEnvs:
      secrets:
        - name: rhdh-secrets
        - name: postgresql-credentials
    replicas: 2
    route:
      enabled: true
      tls:
        termination: edge
  database:
    enableLocalDb: false
    externalDb:
      host: postgresql.rhdh.svc.cluster.local
      port: 5432
      database: backstage
      user: rhdh
      passwordSecret:
        name: postgresql-credentials
        key: password
EOF

# Wait for deployment
oc wait --for=condition=Ready pod \
  -l app.kubernetes.io/component=backstage \
  -n rhdh \
  --timeout=300s

# Get RHDH route
RHDH_ROUTE=$(oc get route developer-hub -n rhdh -o jsonpath='{.spec.host}')
echo "RHDH URL: https://${RHDH_ROUTE}"
```

---

## Install External Secrets Operator

```bash
# Install External Secrets
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: external-secrets-operator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: external-secrets-operator
  source: community-operators
  sourceNamespace: openshift-marketplace
EOF

# Create ClusterSecretStore for Key Vault
cat << EOF | oc apply -f -
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: azure-keyvault
spec:
  provider:
    azurekv:
      authType: WorkloadIdentity
      vaultUrl: https://${KEY_VAULT_NAME}.vault.azure.net
      serviceAccountRef:
        name: external-secrets-sa
        namespace: external-secrets
EOF
```

---

## Configure ACR Integration

```bash
# Get ACR credentials
ACR_NAME="your-acr-name"
ACR_USERNAME=$(az acr credential show --name ${ACR_NAME} --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name ${ACR_NAME} --query "passwords[0].value" -o tsv)

# Create pull secret
oc create secret docker-registry acr-pull-secret \
  --docker-server=${ACR_NAME}.azurecr.io \
  --docker-username=${ACR_USERNAME} \
  --docker-password=${ACR_PASSWORD} \
  -n openshift-config

# Link globally
oc secrets link default acr-pull-secret --for=pull -n openshift-config

# Allow from all projects
oc patch image.config.openshift.io/cluster \
  --type merge \
  --patch '{"spec":{"registrySources":{"allowedRegistries":["'${ACR_NAME}'.azurecr.io","registry.redhat.io","quay.io"]}}}'
```

---

## Validation Checklist

```bash
#!/bin/bash
# validate-aro-deployment.sh

echo "=== ARO Deployment Validation ==="

# 1. ARO Cluster
echo -n "1. ARO Cluster: "
az aro show --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} \
  --query "provisioningState" -o tsv 2>/dev/null | grep -q "Succeeded" && echo "✅" || echo "❌"

# 2. OC Login
echo -n "2. OC Login: "
oc whoami &>/dev/null && echo "✅ ($(oc whoami))" || echo "❌"

# 3. OAuth Config
echo -n "3. OAuth (Entra): "
oc get oauth cluster -o jsonpath='{.spec.identityProviders[0].name}' 2>/dev/null | grep -q "Entra" && echo "✅" || echo "⚠️ Not configured"

# 4. GitOps Operator
echo -n "4. OpenShift GitOps: "
oc get csv -n openshift-operators 2>/dev/null | grep -q "openshift-gitops" && echo "✅" || echo "❌"

# 5. ArgoCD Route
echo -n "5. ArgoCD Route: "
ARGOCD=$(oc get route openshift-gitops-server -n openshift-gitops -o jsonpath='{.spec.host}' 2>/dev/null)
[[ -n "${ARGOCD}" ]] && echo "✅ https://${ARGOCD}" || echo "❌"

# 6. RHDH Operator
echo -n "6. RHDH Operator: "
oc get csv -n openshift-operators 2>/dev/null | grep -q "rhdh" && echo "✅" || echo "❌"

# 7. RHDH Instance
echo -n "7. RHDH Instance: "
oc get backstage developer-hub -n rhdh &>/dev/null && echo "✅" || echo "❌"

# 8. RHDH Route
echo -n "8. RHDH Route: "
RHDH=$(oc get route developer-hub -n rhdh -o jsonpath='{.spec.host}' 2>/dev/null)
[[ -n "${RHDH}" ]] && echo "✅ https://${RHDH}" || echo "❌"

# 9. External Secrets
echo -n "9. External Secrets: "
oc get csv -n openshift-operators 2>/dev/null | grep -q "external-secrets" && echo "✅" || echo "⚠️ Optional"

# 10. ACR Pull Secret
echo -n "10. ACR Integration: "
oc get secret acr-pull-secret -n openshift-config &>/dev/null && echo "✅" || echo "⚠️ Not configured"

echo ""
echo "=== Cluster Info ==="
az aro show --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} \
  --query "{Console:consoleProfile.url, API:apiserverProfile.url, Version:version}" -o table 2>/dev/null
```

---

## Error Handling

### Common Errors and Solutions

#### Insufficient Quota

```bash
# Error: QuotaExceeded for DCSv3 Family
# Solution: Request quota increase

az vm list-usage --location ${LOCATION} --output table | grep -i "DCS"

# Request via Azure Portal: Subscriptions > Usage + quotas
```

#### Pull Secret Invalid

```bash
# Error: InvalidPullSecret
# Solution: Re-download from Red Hat

cat pull-secret.txt | jq .  # Validate JSON

# Download fresh from: https://console.redhat.com/openshift/install/pull-secret
```

#### VNet Peering Issues

```bash
# Error: Network connectivity issues
# Solution: Check subnet configuration

az network vnet subnet show \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name master-subnet \
  --query "privateLinkServiceNetworkPolicies" -o tsv
# Should be "Disabled"
```

#### RHDH OAuth Redirect Error

```bash
# Error: Invalid redirect_uri
# Solution: Update Entra App redirect URI

az ad app update \
  --id ${ENTRA_APP_ID} \
  --web-redirect-uris "https://developer-hub-rhdh.apps.${CLUSTER_NAME}.${LOCATION}.aroapp.io/api/auth/github/handler/frame"
```

---

## Related Skills

- [openshift-operations](../openshift-operations/) - Ongoing OpenShift operations
- [rhdh-portal](../rhdh-portal/) - RHDH catalog and templates
- [argocd-cli](../argocd-cli/) - GitOps operations
- [azure-infrastructure](../azure-infrastructure/) - Azure resource management

---

## References

- [Azure Red Hat OpenShift Documentation](https://learn.microsoft.com/en-us/azure/openshift/)
- [ARO Quick Start](https://learn.microsoft.com/en-us/azure/openshift/tutorial-create-cluster)
- [RHDH Documentation](https://developers.redhat.com/rhdh)
- [OpenShift GitOps](https://docs.openshift.com/gitops/latest/understanding_openshift_gitops/about-redhat-openshift-gitops.html)

````
