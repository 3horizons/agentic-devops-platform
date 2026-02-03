---
name: "ARO Platform Agent"
version: "1.0.0"
horizon: "H1"
status: "stable"
last_updated: "2025-12-15"
mcp_servers:
  - azure
  - openshift
  - helm
dependencies:
  - networking
  - security
---

# ARO Platform Agent

## 🤖 Agent Identity

```yaml
name: aro-platform-agent
version: 1.0.0
horizon: H1 - Foundation
description: |
  Deploys and configures Azure Red Hat OpenShift (ARO) clusters.
  Uses both Azure CLI (az aro) and OpenShift CLI (oc) for complete
  platform setup including RHDH, GitOps, and enterprise integrations.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 📋 Related Resources

| Resource Type | Path |
|--------------|------|
| Issue Template | `.github/ISSUE_TEMPLATE/infrastructure.yml` |
| RHDH Values | `platform/rhdh/values.yaml` |
| MCP Servers | `mcp-servers/mcp-config.json` (aro, openshift) |
| Bootstrap Script | `scripts/bootstrap.sh` |
| Sizing Config | `config/sizing-profiles.yaml` |

---

## 🎯 Capabilities

| Capability | Description | Complexity | CLI |
|------------|-------------|------------|-----|
| **Create ARO Cluster** | Full cluster provisioning | Very High | `az aro` |
| **Configure OAuth** | Entra ID / GitHub SSO | High | `oc` |
| **Install Operators** | OLM-based operators | Medium | `oc` |
| **Deploy RHDH** | Developer Hub on OpenShift | High | `oc`, `helm` |
| **Configure Routes** | OpenShift Routes + TLS | Medium | `oc` |
| **Setup GitOps** | OpenShift GitOps Operator | High | `oc` |
| **Configure RBAC** | OpenShift RBAC policies | Medium | `oc` |
| **Integrate ACR** | Pull secrets for ACR | Low | `oc`, `az` |

---

## 🔧 MCP Servers Required

```json
{
  "aro": {
    "capabilities": ["az aro create", "az aro list", "az aro show", "az aro update"]
  },
  "openshift": {
    "capabilities": ["oc login", "oc project", "oc apply", "oc adm", "oc get", "oc create"]
  },
  "azure": {
    "capabilities": ["az network", "az ad", "az keyvault"]
  },
  "helm": {
    "capabilities": ["helm install", "helm upgrade"]
  }
}
```

---

## 🛠️ Implementation

### 1. Prerequisites - Network Setup

```bash
# Create VNet for ARO
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

# Disable subnet private endpoint policies (required for ARO)
az network vnet subnet update \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name master-subnet \
  --disable-private-link-service-network-policies true
```

### 2. Create ARO Cluster

```bash
# Register resource providers
az provider register -n Microsoft.RedHatOpenShift --wait
az provider register -n Microsoft.Compute --wait
az provider register -n Microsoft.Storage --wait
az provider register -n Microsoft.Authorization --wait

# Create Service Principal for ARO (or use existing)
SP_INFO=$(az ad sp create-for-rbac --name "${CLUSTER_NAME}-sp" --role Contributor \
  --scopes /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP})

SP_CLIENT_ID=$(echo $SP_INFO | jq -r '.appId')
SP_CLIENT_SECRET=$(echo $SP_INFO | jq -r '.password')

# Get Red Hat pull secret (download from cloud.redhat.com)
PULL_SECRET=$(cat pull-secret.txt)

# Create ARO cluster
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
  --domain ${CLUSTER_NAME} \
  --cluster-resource-group ${CLUSTER_NAME}-resources

# Wait for cluster creation (30-45 minutes)
echo "Cluster creation in progress... This takes 30-45 minutes"
```

### 3. Get Cluster Credentials

```bash
# Get API server URL
ARO_API_SERVER=$(az aro show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${CLUSTER_NAME} \
  --query apiserverProfile.url -o tsv)

# Get kubeadmin credentials
ARO_KUBEADMIN_PASSWORD=$(az aro list-credentials \
  --resource-group ${RESOURCE_GROUP} \
  --name ${CLUSTER_NAME} \
  --query kubeadminPassword -o tsv)

# Get console URL
ARO_CONSOLE_URL=$(az aro show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${CLUSTER_NAME} \
  --query consoleProfile.url -o tsv)

echo "Console: ${ARO_CONSOLE_URL}"
echo "API Server: ${ARO_API_SERVER}"

# Login with oc CLI
oc login ${ARO_API_SERVER} \
  --username kubeadmin \
  --password ${ARO_KUBEADMIN_PASSWORD}
```

### 4. Configure OAuth (Entra ID)

```bash
# Create OAuth configuration for Entra ID
cat > oauth-entra.yaml << EOF
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

# Create secret for client credentials
oc create secret generic entra-client-secret \
  --namespace openshift-config \
  --from-literal=clientSecret=${ENTRA_CLIENT_SECRET}

# Apply OAuth config
oc apply -f oauth-entra.yaml
```

### 5. Install OpenShift GitOps Operator

```bash
# Create subscription for GitOps Operator
cat > gitops-operator.yaml << EOF
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

oc apply -f gitops-operator.yaml

# Wait for operator to be ready
oc wait --for=condition=Ready pod -l app.kubernetes.io/name=openshift-gitops-operator \
  -n openshift-operators --timeout=300s

# Get ArgoCD route
ARGOCD_ROUTE=$(oc get route openshift-gitops-server \
  -n openshift-gitops \
  -o jsonpath='{.spec.host}')

echo "ArgoCD URL: https://${ARGOCD_ROUTE}"
```

### 6. Install Red Hat Developer Hub (RHDH)

```bash
# Create namespace for RHDH
oc new-project rhdh

# Create subscription for RHDH Operator
cat > rhdh-operator.yaml << EOF
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

oc apply -f rhdh-operator.yaml

# Wait for CRD to be available
oc wait --for=condition=Established crd/backstages.rhdh.redhat.com --timeout=300s

# Create RHDH instance
cat > rhdh-instance.yaml << EOF
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
    replicas: 2
    route:
      enabled: true
      tls:
        termination: edge
  database:
    enableLocalDb: false
    externalDb:
      host: ${POSTGRESQL_HOST}
      port: 5432
      database: rhdh
      user: rhdh
      passwordSecret:
        name: postgresql-credentials
        key: password
EOF

oc apply -f rhdh-instance.yaml

# Get RHDH route
RHDH_ROUTE=$(oc get route developer-hub -n rhdh -o jsonpath='{.spec.host}')
echo "RHDH URL: https://${RHDH_ROUTE}"
```

### 7. Configure ACR Pull Secret

```bash
# Get ACR credentials
ACR_USERNAME=$(az acr credential show --name ${ACR_NAME} --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name ${ACR_NAME} --query "passwords[0].value" -o tsv)

# Create pull secret for all namespaces
oc create secret docker-registry acr-pull-secret \
  --docker-server=${ACR_NAME}.azurecr.io \
  --docker-username=${ACR_USERNAME} \
  --docker-password=${ACR_PASSWORD} \
  -n openshift-config

# Link to default service account globally
oc patch configs.imageregistry.operator.openshift.io/cluster \
  --type merge \
  --patch '{"spec":{"allowedRegistriesForImport":[{"domainName":"'${ACR_NAME}'.azurecr.io"}]}}'

# Or use Workload Identity (recommended)
# Configure ARO to use Azure AD for ACR
az aro update \
  --resource-group ${RESOURCE_GROUP} \
  --name ${CLUSTER_NAME} \
  --pull-secret @pull-secret-with-acr.txt
```

### 8. Configure Cluster RBAC

```bash
# Create cluster admin group binding for Entra ID group
cat > cluster-admins.yaml << EOF
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
  name: ${ENTRA_ADMIN_GROUP_ID}
EOF

oc apply -f cluster-admins.yaml

# Create developer group with edit permissions
cat > developers-binding.yaml << EOF
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
  name: ${ENTRA_DEVELOPERS_GROUP_ID}
EOF

oc apply -f developers-binding.yaml
```

---

## 📊 ARO vs AKS Comparison

| Feature | ARO | AKS |
|---------|-----|-----|
| **CLI** | `az aro` + `oc` | `az aks` + `kubectl` |
| **Developer Portal** | RHDH (Operator) | RHDH (Helm) |
| **GitOps** | OpenShift GitOps | ArgoCD |
| **Ingress** | OpenShift Routes | NGINX/AGIC |
| **Registry** | Internal + ACR | ACR |
| **OAuth** | OpenShift OAuth | Entra ID direct |
| **Operators** | OLM (built-in) | OLM (addon) |
| **Service Mesh** | OpenShift Service Mesh | Istio/OSM |

---

## 📊 Validation Checklist

```bash
#!/bin/bash
# validate-aro-platform.sh

echo "=== ARO Platform Validation ==="

# Check ARO cluster
echo -n "ARO Cluster: "
az aro show --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} &>/dev/null && echo "✅" || echo "❌"

# Check oc login
echo -n "OC Login: "
oc whoami &>/dev/null && echo "✅ ($(oc whoami))" || echo "❌"

# Check OAuth
echo -n "OAuth (Entra): "
oc get oauth cluster -o jsonpath='{.spec.identityProviders[0].name}' 2>/dev/null | grep -q "Entra" && echo "✅" || echo "❌"

# Check GitOps Operator
echo -n "GitOps Operator: "
oc get subscription openshift-gitops-operator -n openshift-operators &>/dev/null && echo "✅" || echo "❌"

# Check RHDH
echo -n "RHDH: "
oc get backstage developer-hub -n rhdh &>/dev/null && echo "✅" || echo "❌"

# Check RHDH Route
echo -n "RHDH Route: "
RHDH_ROUTE=$(oc get route developer-hub -n rhdh -o jsonpath='{.spec.host}' 2>/dev/null)
[[ -n "${RHDH_ROUTE}" ]] && echo "✅ (https://${RHDH_ROUTE})" || echo "❌"

# Check ACR integration
echo -n "ACR Pull Secret: "
oc get secret acr-pull-secret -n openshift-config &>/dev/null && echo "✅" || echo "❌"

# Check console access
echo -n "Console Access: "
ARO_CONSOLE=$(az aro show --resource-group ${RESOURCE_GROUP} --name ${CLUSTER_NAME} --query consoleProfile.url -o tsv 2>/dev/null)
[[ -n "${ARO_CONSOLE}" ]] && echo "✅ (${ARO_CONSOLE})" || echo "❌"
```

---

## 🔗 Dependencies

| Agent | Purpose |
|-------|---------|
| `identity-federation-agent` | Entra ID → OpenShift OAuth |
| `github-app-agent` | GitHub App for RHDH |
| `networking-agent` | VNet for ARO |
| `security-agent` | Key Vault for secrets |
| `gitops-agent` | OpenShift GitOps config |
| `rhdh-portal-agent` | RHDH application config |
