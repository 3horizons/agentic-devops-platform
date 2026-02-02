# Platform Choices

> Decision matrix and configuration differences between AKS and ARO for Three Horizons implementation.

## Overview

The Three Horizons Accelerator supports two Kubernetes platforms. Clients choose ONE platform at project initialization based on their requirements.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        PLATFORM CHOICES                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│    ┌───────────────────────┐       ┌───────────────────────┐           │
│    │         AKS           │       │         ARO           │           │
│    │  Azure Kubernetes     │  OR   │  Azure Red Hat        │           │
│    │      Service          │       │     OpenShift         │           │
│    └───────────────────────┘       └───────────────────────┘           │
│                                                                          │
│    ► Azure-native                  ► Enterprise-grade                   │
│    ► Simpler operations            ► Red Hat support                    │
│    ► Lower cost                    ► OpenShift ecosystem                │
│    ► Faster deployment             ► Built-in operators                 │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Decision Matrix

### When to Choose AKS

| Criteria | Weight | AKS Advantage |
|----------|--------|---------------|
| Cloud-native approach | High | Native Azure integration |
| Cost sensitivity | High | 40-50% lower compute costs |
| Team experience | Medium | Standard Kubernetes |
| Deployment speed | Medium | 25-30 min deployment |
| Flexibility | Medium | Full control over components |

**Ideal for:**
- Teams already using Azure services
- Cost-conscious deployments
- Standard Kubernetes workflows
- Startups and smaller organizations
- Proof of concept projects

### When to Choose ARO

| Criteria | Weight | ARO Advantage |
|----------|--------|---------------|
| Enterprise support | High | Red Hat + Microsoft support |
| Regulatory compliance | High | Certified for regulated industries |
| Operator ecosystem | High | 200+ certified operators |
| Team experience | Medium | OpenShift expertise |
| Integrated tooling | Medium | Built-in CI/CD, registry, monitoring |

**Ideal for:**
- Large enterprises with Red Hat agreements
- Regulated industries (finance, healthcare)
- Teams with OpenShift experience
- Need for 24/7 enterprise support
- Hybrid cloud strategies

---

## Detailed Comparison

### Infrastructure

| Feature | AKS | ARO |
|---------|-----|-----|
| Kubernetes Version | 1.29+ | 4.14+ (OKD 4.x) |
| Control Plane | Azure managed | Red Hat + Azure managed |
| Worker Nodes | Azure VMs | Azure VMs |
| Min Nodes | 1 | 3 (minimum for HA) |
| Max Nodes | 5000 | 250 per cluster |
| SLA | 99.95% (paid) | 99.95% included |

### Networking

| Feature | AKS | ARO |
|---------|-----|-----|
| CNI | Azure CNI / Kubenet / Overlay | OVN-Kubernetes |
| Network Policies | Calico / Azure NPM | Built-in OVN |
| Ingress | Many options (NGINX, AGIC) | HAProxy (built-in) |
| Service Mesh | Istio / Linkerd (add-on) | OpenShift Service Mesh |
| Private Cluster | Supported | Supported |

### Security

| Feature | AKS | ARO |
|---------|-----|-----|
| Identity | Azure AD + Workload ID | Azure AD + Red Hat SSO |
| RBAC | Kubernetes RBAC | OpenShift RBAC |
| Pod Security | Pod Security Admission | Security Context Constraints |
| Registry | ACR | ACR or OpenShift Registry |
| Secrets | Key Vault + ESO | Key Vault + ESO |
| Compliance | SOC, ISO, PCI | SOC, ISO, PCI + FIPS |

### Operations

| Feature | AKS | ARO |
|---------|-----|-----|
| GitOps | ArgoCD (installed) | OpenShift GitOps (operator) |
| Monitoring | Prometheus + Grafana | OpenShift Monitoring |
| Logging | Loki | OpenShift Logging |
| CI/CD | GitHub Actions | OpenShift Pipelines + Actions |
| Developer Portal | RHDH | RHDH (native integration) |

### Cost (USD/month - 3 nodes)

| Environment | AKS | ARO |
|-------------|-----|-----|
| Dev | ~$300 | ~$600 |
| Staging | ~$600 | ~$1,100 |
| Production | ~$1,500 | ~$2,500 |

*Note: ARO includes Red Hat support and additional features*

---

## Configuration Differences

### Terraform Variables

```hcl
# For AKS
platform_choice = "aks"

# For ARO
platform_choice = "aro"
```

### Module Selection

The accelerator automatically selects the appropriate modules based on `platform_choice`:

```hcl
# main.tf (simplified)
module "aks_cluster" {
  count  = var.platform_choice == "aks" ? 1 : 0
  source = "./modules/aks-cluster"
  # ...
}

module "aro_cluster" {
  count  = var.platform_choice == "aro" ? 1 : 0
  source = "./modules/aro-cluster"
  # ...
}
```

### Agents Configuration

Agents adapt behavior based on platform:

```yaml
# infrastructure-agent.md
platform_specific:
  aks:
    commands:
      - az aks create
      - az aks nodepool add
    tools:
      - azure-cli
      - kubectl-cli
  aro:
    commands:
      - az aro create
      - oc adm
    tools:
      - azure-cli
      - kubectl-cli
      - openshift-cli
```

---

## Deployment Differences

### AKS Deployment

```bash
# 1. Initialize
cd terraform
terraform init

# 2. Configure (AKS)
cat > terraform.tfvars << EOF
platform_choice = "aks"
environment     = "dev"
location        = "eastus2"
EOF

# 3. Deploy
terraform apply -var-file=terraform.tfvars

# 4. Get credentials
az aks get-credentials --resource-group $RG --name $AKS_NAME

# 5. Verify
kubectl get nodes
```

### ARO Deployment

```bash
# 1. Prerequisites
# Download Red Hat pull secret from cloud.redhat.com

# 2. Initialize
cd terraform
terraform init

# 3. Configure (ARO)
cat > terraform.tfvars << EOF
platform_choice      = "aro"
environment          = "dev"
location             = "eastus2"
pull_secret_file     = "pull-secret.json"
EOF

# 4. Deploy
terraform apply -var-file=terraform.tfvars

# 5. Get credentials
az aro get-admin-kubeconfig --resource-group $RG --name $ARO_NAME \
  --file kubeconfig

export KUBECONFIG=./kubeconfig

# 6. Verify
oc get nodes
```

---

## GitOps Differences

### AKS with ArgoCD

```yaml
# argocd/applications/app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: my-app
  source:
    repoURL: https://github.com/org/gitops-repo.git
    path: apps/my-app
```

### ARO with OpenShift GitOps

```yaml
# Same structure, but uses OpenShift GitOps operator
# Installed via OperatorHub subscription
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-gitops-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-gitops-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
```

---

## Developer Portal (RHDH)

### Integration Pattern

RHDH works with both platforms but has deeper integration with ARO:

| Feature | AKS + RHDH | ARO + RHDH |
|---------|------------|------------|
| Installation | Helm chart | Operator |
| Authentication | Azure AD | Azure AD + Red Hat SSO |
| Plugins | Standard | OpenShift-specific available |
| Catalog | Same | Same |
| Templates | Same | OpenShift-specific templates |

---

## Migration Between Platforms

### AKS to ARO

Not recommended for production. If needed:

1. Export application manifests
2. Deploy ARO cluster
3. Migrate workloads using Velero or MTC
4. Update DNS/Ingress

### ARO to AKS

Not recommended for production. If needed:

1. Export application manifests
2. Convert OpenShift-specific resources (SCCs → PSA, Routes → Ingress)
3. Deploy AKS cluster
4. Migrate workloads

---

## Platform-Specific Features

### AKS-Only Features

| Feature | Description |
|---------|-------------|
| Azure CNI Overlay | Efficient IP address usage |
| KEDA | Event-driven autoscaling |
| Azure AD Pod Identity | Native Azure identity |
| Virtual Nodes | Serverless containers (ACI) |
| Draft | Application scaffolding |

### ARO-Only Features

| Feature | Description |
|---------|-------------|
| OpenShift Routes | Advanced traffic management |
| SCCs | Granular pod security |
| ImageStreams | Image lifecycle management |
| BuildConfigs | Built-in CI |
| Operator Framework | Native operator support |
| Developer Console | Built-in web console |

---

## Support Matrix

### Microsoft Support

| Platform | Support Level |
|----------|---------------|
| AKS | Direct Microsoft support |
| ARO | Microsoft + Red Hat joint support |

### Red Hat Support

| Platform | Support Level |
|----------|---------------|
| AKS | N/A (community operators only) |
| ARO | Full Red Hat enterprise support |

### SLA Comparison

| Metric | AKS | ARO |
|--------|-----|-----|
| Control Plane SLA | 99.95% (paid tier) | 99.95% included |
| Support Response | Based on Azure plan | 24/7 critical |
| Patch Frequency | Monthly | Bi-weekly |

---

## Recommendation Framework

### Score Your Requirements

Rate each criterion 1-5 (5 = most important):

| Criterion | Your Score | AKS Points | ARO Points |
|-----------|------------|------------|------------|
| Cost efficiency | ___ | 5 | 2 |
| Enterprise support | ___ | 3 | 5 |
| Regulatory compliance | ___ | 3 | 5 |
| Standard Kubernetes | ___ | 5 | 3 |
| Red Hat ecosystem | ___ | 1 | 5 |
| Deployment speed | ___ | 5 | 3 |
| Integrated tooling | ___ | 3 | 5 |
| Hybrid cloud | ___ | 3 | 5 |

### Calculate Score

```
AKS Score = Sum(Your Score × AKS Points)
ARO Score = Sum(Your Score × ARO Points)
```

Choose the platform with the higher score.

---

## Quick Reference

### Setting Platform Choice

```bash
# In terraform.tfvars
platform_choice = "aks"  # or "aro"

# Via CLI
terraform apply -var="platform_choice=aks"

# Via environment variable
export TF_VAR_platform_choice="aro"
```

### Validating Platform Deployment

```bash
# AKS
az aks show --resource-group $RG --name $AKS_NAME --query "provisioningState"

# ARO
az aro show --resource-group $RG --name $ARO_NAME --query "provisioningState"
```

---

**Document Owner:** Platform Engineering Team  
**Last Updated:** February 2026  
**Review Cycle:** Quarterly
