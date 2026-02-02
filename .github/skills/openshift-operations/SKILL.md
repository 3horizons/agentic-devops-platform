````skill
---
name: openshift-operations
description: 'Azure Red Hat OpenShift (ARO) operations for Three Horizons Accelerator. Use when deploying ARO clusters, managing OpenShift projects, configuring operators, setting up routes. Covers oc CLI, OpenShift operators, RHDH on OpenShift, GitOps with OpenShift.'
license: Complete terms in LICENSE.txt
---

# OpenShift Operations Skill

Comprehensive skill for Azure Red Hat OpenShift (ARO) operations in the Three Horizons Accelerator platform.

**Version:** 1.0.0

---

## Overview

This skill encapsulates all tools required for ARO/OpenShift operations:
- **MCP Servers**: azure, openshift, kubernetes, helm
- **Scripts**: deploy-aro.sh, onboard-team.sh
- **Terraform Modules**: (ARO via azurerm)
- **Golden Paths**: OpenShift application templates

---

## MCP Server Configuration

### OpenShift MCP Server

```json
{
  "openshift": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-openshift"],
    "description": "OpenShift CLI for ARO clusters",
    "env": {
      "KUBECONFIG": "${KUBECONFIG}"
    },
    "capabilities": [
      "oc login",
      "oc project",
      "oc new-app",
      "oc expose",
      "oc get",
      "oc apply",
      "oc adm",
      "oc policy",
      "oc create route"
    ]
  }
}
```

### ARO MCP Server (Azure Operations)

```json
{
  "aro": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-azure"],
    "description": "Azure Red Hat OpenShift operations",
    "capabilities": [
      "az aro create",
      "az aro delete",
      "az aro list",
      "az aro show",
      "az aro update"
    ]
  }
}
```

---

## Core Commands

### ARO Cluster Management (Azure CLI)

```bash
# Create ARO cluster
az aro create \
  --resource-group ${RESOURCE_GROUP} \
  --name aro-${PROJECT}-${ENV}-${LOCATION_SHORT} \
  --vnet ${VNET_NAME} \
  --master-subnet snet-aro-master \
  --worker-subnet snet-aro-worker \
  --pull-secret @pull-secret.txt \
  --domain ${CLUSTER_DOMAIN} \
  --location ${LOCATION}

# List ARO clusters
az aro list --output table

# Show ARO cluster
az aro show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${ARO_CLUSTER_NAME}

# Get ARO credentials
az aro list-credentials \
  --resource-group ${RESOURCE_GROUP} \
  --name ${ARO_CLUSTER_NAME}

# Get ARO console URL
az aro show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${ARO_CLUSTER_NAME} \
  --query "consoleProfile.url" -o tsv

# Get API server URL
az aro show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${ARO_CLUSTER_NAME} \
  --query "apiserverProfile.url" -o tsv

# Update ARO cluster
az aro update \
  --resource-group ${RESOURCE_GROUP} \
  --name ${ARO_CLUSTER_NAME}

# Delete ARO cluster
az aro delete \
  --resource-group ${RESOURCE_GROUP} \
  --name ${ARO_CLUSTER_NAME} \
  --yes
```

### OpenShift CLI (oc) Commands

```bash
# Login to ARO cluster
oc login ${API_SERVER_URL} -u kubeadmin -p ${KUBEADMIN_PASSWORD}

# Login with token
oc login --token=${TOKEN} --server=${API_SERVER_URL}

# Get current user
oc whoami

# Get cluster info
oc cluster-info
```

### Project Management

```bash
# Create new project (namespace)
oc new-project ${PROJECT_NAME} \
  --display-name="My Project" \
  --description="Project description"

# Switch project
oc project ${PROJECT_NAME}

# List projects
oc projects

# Delete project
oc delete project ${PROJECT_NAME}

# Add user to project
oc adm policy add-role-to-user admin ${USER} -n ${PROJECT_NAME}
oc adm policy add-role-to-user edit ${USER} -n ${PROJECT_NAME}
oc adm policy add-role-to-user view ${USER} -n ${PROJECT_NAME}
```

### Application Deployment

```bash
# Deploy from image
oc new-app nginx:latest --name=my-nginx

# Deploy from Git
oc new-app https://github.com/org/repo.git --name=my-app

# Deploy from template
oc new-app --template=postgresql-persistent

# Expose service as route
oc expose svc/my-nginx

# Create secure route (HTTPS)
oc create route edge my-nginx \
  --service=my-nginx \
  --port=8080 \
  --hostname=my-nginx.apps.${CLUSTER_DOMAIN}

# Get routes
oc get routes
```

### Operators

```bash
# List installed operators
oc get csv -A

# List operator subscriptions
oc get subscriptions -A

# Install operator via CLI
cat <<EOF | oc apply -f -
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

# Check operator status
oc get csv -n openshift-operators
```

### Security Context Constraints (SCC)

```bash
# List SCCs
oc get scc

# Add SCC to service account
oc adm policy add-scc-to-user anyuid -z my-sa -n ${NAMESPACE}
oc adm policy add-scc-to-user privileged -z my-sa -n ${NAMESPACE}

# Remove SCC from service account
oc adm policy remove-scc-from-user anyuid -z my-sa -n ${NAMESPACE}

# Check SCC for pod
oc get pod my-pod -o yaml | grep -i scc
```

### Image Streams

```bash
# List image streams
oc get imagestreams -n openshift

# Create image stream
oc create imagestream my-app

# Import image
oc import-image my-app:v1.0.0 \
  --from=docker.io/myorg/my-app:v1.0.0 \
  --confirm

# Tag image
oc tag my-app:v1.0.0 my-app:latest
```

---

## Scripts Reference

### Deploy ARO Script

**Path:** `scripts/deploy-aro.sh`

```bash
#!/bin/bash
# Deploy Azure Red Hat OpenShift cluster

./scripts/deploy-aro.sh \
  --environment ${ENV} \
  --location ${LOCATION} \
  --project ${PROJECT} \
  --pull-secret-path ./pull-secret.txt
```

### Onboard Team Script

**Path:** `scripts/onboard-team.sh`

```bash
#!/bin/bash
# Onboard team to ARO/AKS platform

./scripts/onboard-team.sh \
  --team-name ${TEAM_NAME} \
  --platform aro \
  --namespace ${NAMESPACE}
```

---

## Operator Installation

### OpenShift GitOps (ArgoCD)

```yaml
# ArgoCD Operator Subscription
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
---
# Wait for operator
oc wait --for=condition=InstallSucceeded csv \
  -l operators.coreos.com/openshift-gitops-operator.openshift-operators \
  -n openshift-operators \
  --timeout=300s
```

### External Secrets Operator

```yaml
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
```

### Red Hat Developer Hub (RHDH)

```yaml
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
```

---

## ARO Networking

### VNet Requirements

```bash
# Create master subnet
az network vnet subnet create \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name snet-aro-master \
  --address-prefixes 10.0.10.0/24 \
  --service-endpoints Microsoft.ContainerRegistry

# Create worker subnet
az network vnet subnet create \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name snet-aro-worker \
  --address-prefixes 10.0.11.0/24 \
  --service-endpoints Microsoft.ContainerRegistry

# Disable subnet private endpoint policies
az network vnet subnet update \
  --resource-group ${RESOURCE_GROUP} \
  --vnet-name ${VNET_NAME} \
  --name snet-aro-master \
  --disable-private-link-service-network-policies true
```

### Service Principal for ARO

```bash
# Create service principal
az ad sp create-for-rbac \
  --name sp-aro-${PROJECT}-${ENV} \
  --role Contributor \
  --scopes /subscriptions/${SUBSCRIPTION_ID}/resourceGroups/${RESOURCE_GROUP}

# Assign Network Contributor to VNet
az role assignment create \
  --assignee ${SP_APP_ID} \
  --role "Network Contributor" \
  --scope ${VNET_ID}
```

---

## Comparison: AKS vs ARO

| Feature | AKS | ARO |
|---------|-----|-----|
| **Platform** | Azure Native | Red Hat OpenShift |
| **CLI** | az aks, kubectl | az aro, oc |
| **Operators** | Helm, Operator Lifecycle | OLM (Operator Lifecycle Manager) |
| **Registry** | ACR | Internal Registry + ACR |
| **Routes** | Ingress Controller | OpenShift Routes |
| **Security** | Pod Security Standards | Security Context Constraints |
| **Developer Portal** | Backstage | RHDH (Red Hat Developer Hub) |
| **GitOps** | ArgoCD (Helm) | OpenShift GitOps Operator |
| **Support** | Microsoft | Red Hat + Microsoft |

---

## Error Handling

### Common Errors and Solutions

#### Pull Secret Invalid

```bash
# Error: InvalidPullSecret
# Solution: Validate pull secret format

cat pull-secret.txt | jq .

# Download fresh pull secret from Red Hat
# https://console.redhat.com/openshift/install/pull-secret
```

#### Insufficient Quotas

```bash
# Error: QuotaExceeded for DCSv3
# Solution: Check and request quota increase

az vm list-usage --location ${LOCATION} --output table | grep DCSv3
```

#### SCC Denied

```bash
# Error: pods "my-pod" is forbidden: unable to validate against any security context constraint
# Solution: Add SCC to service account

oc adm policy add-scc-to-user anyuid -z ${SERVICE_ACCOUNT} -n ${NAMESPACE}
```

#### Route Not Accessible

```bash
# Error: 503 Service Unavailable
# Solution: Check service and endpoints

oc get svc ${SERVICE_NAME}
oc get endpoints ${SERVICE_NAME}
oc describe route ${ROUTE_NAME}
```

---

## Pre-Deployment Checklist

- [ ] Red Hat pull secret obtained from console.redhat.com
- [ ] Azure subscription has ARO resource provider registered
- [ ] Sufficient quota for DCSv3 VMs (master) and D4s_v3 (workers)
- [ ] VNet with required subnets created
- [ ] Service principal created with proper permissions
- [ ] Domain configured for cluster ingress

## Post-Deployment Validation

```bash
# Validate ARO cluster
./scripts/validate-deployment.sh --platform aro

# Check cluster operators
oc get clusteroperators

# Check nodes
oc get nodes

# Check console access
xdg-open $(az aro show -g ${RG} -n ${ARO} --query consoleProfile.url -o tsv)
```

---

## Related Skills

- [azure-cli](../azure-cli/) - Azure CLI command reference
- [kubectl-cli](../kubectl-cli/) - Kubernetes CLI reference
- [argocd-cli](../argocd-cli/) - ArgoCD CLI reference
- [rhdh-portal](../rhdh-portal/) - RHDH operations

---

## References

- [Azure Red Hat OpenShift Documentation](https://learn.microsoft.com/en-us/azure/openshift/)
- [OpenShift CLI Reference](https://docs.openshift.com/container-platform/latest/cli_reference/openshift_cli/getting-started-cli.html)
- [Red Hat Operators](https://catalog.redhat.com/software/operators)
- [ARO Architecture](https://learn.microsoft.com/en-us/azure/openshift/concepts-networking)

````
