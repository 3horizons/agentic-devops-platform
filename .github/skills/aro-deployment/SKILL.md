---
name: aro-deployment
description: "ARO (Azure Red Hat OpenShift) deployment reference — covers ARO provisioning, RHDH deployment on OpenShift, Operator-based install, and ARO vs AKS differences. ALWAYS consult these docs before deploying to ARO."
---

# ARO (Azure Red Hat OpenShift) Deployment Skill

This skill provides guidance for deploying the Three Horizons platform on **ARO (Azure Red Hat OpenShift)** as an alternative to AKS. **Always consult this skill and the official RHDH OpenShift documentation before performing any ARO deployment.**

## When to Use This Skill

- Provisioning an ARO cluster on Azure
- Deploying RHDH on ARO (Operator-based or Helm)
- Understanding differences between AKS and ARO deployments
- Troubleshooting ARO-specific issues (Routes, Operators, SecurityContextConstraints)
- Managing Red Hat pull secrets for container registry access
- Configuring OAuth on ARO (built-in OAuth vs external providers)

## Mandatory Rule

> **ALWAYS** read the official RHDH OpenShift installation documentation **BEFORE** deploying on ARO. ARO and AKS have significant differences in networking (Routes vs Ingress), security (SCC vs PSP), operator management (OLM), and authentication (built-in OAuth).

## Official Documentation References

| Document | Path | Covers |
|----------|------|--------|
| **Install on OpenShift** | [installing_red_hat_developer_hub_on_openshift_container_platform.md](../../../docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md) | Operator-based install, Helm on OCP, routes, OAuth proxy |
| **About RHDH** | [about_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/about_red_hat_developer_hub.md) | Architecture overview, supported platforms including OpenShift |

## ARO vs AKS: Key Differences

| Aspect | AKS | ARO (OpenShift) |
|--------|-----|-----------------|
| **CLI** | `kubectl` | `oc` (superset of kubectl) |
| **Ingress** | Ingress Controller (nginx/AppGW) | Routes (built-in) |
| **Security** | Pod Security Standards | SecurityContextConstraints (SCC) |
| **Package Mgmt** | Helm only | Helm + Operators (OLM) |
| **RHDH Install** | Helm chart | Operator (preferred) or Helm |
| **Auth** | External (Microsoft Entra ID, GitHub) | Built-in OAuth + External |
| **Container Registry** | ACR pull secret | Red Hat Registry + ACR |
| **Namespaces** | Namespaces | Projects (= namespaces with isolation) |
| **Monitoring** | Azure Monitor + Prometheus | Built-in Prometheus + Grafana |
| **MCP Server** | `kubernetes` | `openshift` (+ `kubernetes` subset) |

## Quick Reference: ARO Provisioning

### Prerequisites
```bash
# Register Azure providers
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.Compute
az provider register -n Microsoft.Storage
az provider register -n Microsoft.Authorization

# Get Red Hat pull secret
# Download from: https://console.redhat.com/openshift/install/pull-secret
# Save to: pull-secret-ARO.txt (already in repo root)
```

### Create ARO Cluster
```bash
# Create resource group
az group create --name rg-3horizons-dev --location centralus

# Create VNet and subnets
az network vnet create \
  --resource-group rg-3horizons-dev \
  --name vnet-aro \
  --address-prefixes 10.0.0.0/22

az network vnet subnet create \
  --resource-group rg-3horizons-dev \
  --vnet-name vnet-aro \
  --name master-subnet \
  --address-prefixes 10.0.0.0/23

az network vnet subnet create \
  --resource-group rg-3horizons-dev \
  --vnet-name vnet-aro \
  --name worker-subnet \
  --address-prefixes 10.0.2.0/23

# Create ARO cluster
az aro create \
  --resource-group rg-3horizons-dev \
  --name aro-3horizons-dev \
  --vnet vnet-aro \
  --master-subnet master-subnet \
  --worker-subnet worker-subnet \
  --pull-secret @pull-secret-ARO.txt \
  --worker-count 3 \
  --worker-vm-size Standard_D4s_v5
```

### Connect to ARO
```bash
# Get credentials
az aro list-credentials --name aro-3horizons-dev --resource-group rg-3horizons-dev

# Get API server URL
API_SERVER=$(az aro show --name aro-3horizons-dev --resource-group rg-3horizons-dev \
  --query apiserverProfile.url -o tsv)

# Login with oc
oc login "$API_SERVER" -u kubeadmin -p <password>

# Or get kubeconfig for kubectl
az aro get-admin-kubeconfig --name aro-3horizons-dev \
  --resource-group rg-3horizons-dev --file ~/.kube/aro-config
export KUBECONFIG=~/.kube/aro-config
```

## RHDH Deployment on ARO

### Option A: Operator (Recommended for ARO)
```bash
# 1. Create project
oc new-project rhdh

# 2. Create pull secret for Red Hat registry
oc create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  -n rhdh

# 3. Install RHDH Operator via OLM
# Navigate to OperatorHub in OpenShift Console
# Search for "Red Hat Developer Hub"
# Install with default settings

# 4. Create Backstage CR
cat <<EOF | oc apply -f -
apiVersion: rhdh.redhat.com/v1alpha3
kind: Backstage
metadata:
  name: developer-hub
  namespace: rhdh
spec:
  application:
    replicas: 2
    route:
      enabled: true
  database:
    enableLocalDb: true
EOF
```

### Option B: Helm (Same chart as AKS)
```bash
helm repo add redhat-developer https://redhat-developer.github.io/rhdh-chart
helm install rhdh redhat-developer/backstage \
  --namespace rhdh \
  --create-namespace \
  -f values-aro.yaml
```

## MCP Servers for ARO

| MCP Server | Use | Agent |
|------------|-----|-------|
| `openshift` | `oc` CLI (routes, operators, projects, SCC) | @deploy, @sre, @devops |
| `azure` | `az aro` (create, credentials, kubeconfig) | @azure-portal-deploy, @deploy |
| `kubernetes` | `kubectl` (subset available via `oc`) | @devops, @sre |
| `helm` | Helm chart operations | @devops, @deploy |
| `argocd` | GitOps sync and deployment | @devops, @deploy |
| `backstage` | RHDH catalog and TechDocs queries | @platform, @template-engineer |

## Azure CLI: ARO Commands

| Command | Purpose |
|---------|---------|
| `az aro create` | Provision ARO cluster |
| `az aro delete` | Remove ARO cluster |
| `az aro list` | List ARO clusters in subscription |
| `az aro show` | Show ARO cluster details |
| `az aro update` | Update ARO cluster configuration |
| `az aro list-credentials` | Get kubeadmin credentials |
| `az aro get-admin-kubeconfig` | Download kubeconfig file |

## Troubleshooting Checklist

- [ ] ARO cluster provisioning: `az aro show --name aro-3horizons-dev -g rg-3horizons-dev --query provisioningState`
- [ ] oc login: `oc whoami` returns current user
- [ ] Pull secret configured: `oc get secret rhdh-pull-secret -n rhdh`
- [ ] RHDH Operator installed: `oc get csv -n rhdh | grep developer-hub`
- [ ] RHDH pods running: `oc get pods -n rhdh`
- [ ] Route accessible: `oc get routes -n rhdh`
- [ ] SCC not blocking pods: `oc get events -n rhdh | grep -i scc`
- [ ] Operator logs: `oc logs deployment/rhdh-operator -n rhdh-operator`
