# Security Agent

## 🤖 Agent Identity

```yaml
name: security-agent
version: 1.0.0
horizon: H1 - Foundation
description: |
  Configures security foundations for the platform.
  Workload Identity, RBAC, Network Policies, Azure Policies,
  Key Vault integration, and Defender for Cloud.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 📁 Terraform Module
**Primary Module:** `terraform/modules/security/main.tf`

## 📋 Related Resources
| Resource Type | Path |
|--------------|------|
| Terraform Module | `terraform/modules/security/main.tf` |
| Defender Module | `terraform/modules/defender/main.tf` |
| Issue Template | `.github/ISSUE_TEMPLATE/security.yml` |
| Golden Path | `golden-paths/h1-foundation/security-baseline/template.yaml` |
| Validation Script | `scripts/validate-config.sh` |

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Configure Workload Identity** | AKS ↔ Azure AD federation | Medium |
| **Setup RBAC** | Kubernetes and Azure RBAC | Medium |
| **Create Network Policies** | Pod-to-pod traffic rules | Medium |
| **Apply Azure Policies** | Governance policies | Low |
| **Configure Key Vault CSI** | Secrets in pods | Medium |
| **Enable Defender** | Defender for Cloud/Containers | Low |
| **Configure Pod Security** | Pod Security Standards | Low |
| **Setup External Secrets** | External Secrets Operator | Medium |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "azure": {
      "required": true,
      "capabilities": [
        "az identity",
        "az aks",
        "az keyvault",
        "az policy",
        "az security"
      ]
    },
    "kubernetes": {
      "required": true,
      "capabilities": [
        "kubectl apply",
        "kubectl auth"
      ]
    },
    "terraform": {
      "required": false
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
primary_label: "agent:security"
required_labels:
  - horizon:h1
action_labels:
  - action:configure-identity   # Workload Identity
  - action:setup-rbac          # RBAC configuration
  - action:network-policies    # Network policies
  - action:enable-defender     # Defender for Cloud
  - action:setup-secrets       # External Secrets
```

---

## 📋 Issue Template

```markdown
---
title: "[H1] Security Configuration - {PROJECT_NAME}"
labels: agent:security, horizon:h1, env:dev
---

## Prerequisites
- [ ] AKS cluster running (Issue #{infra_issue})

## Configuration

```yaml
security:
  # Workload Identity
  workload_identity:
    enabled: true
    namespaces:
      - name: "argocd"
        service_accounts:
          - name: "argocd-server"
            roles: ["Key Vault Secrets User"]
      - name: "ai-apps"
        service_accounts:
          - name: "ai-workload"
            roles: ["Key Vault Secrets User", "Cognitive Services User"]
            
  # RBAC Configuration
  rbac:
    cluster_roles:
      - name: "platform-admin"
        groups: ["platform-team@company.com"]
        permissions: "cluster-admin"
      - name: "developer"
        groups: ["developers@company.com"]
        permissions: "edit"
        namespaces: ["dev-*"]
        
  # Network Policies
  network_policies:
    default_deny: true
    allow_rules:
      - from: "monitoring"
        to: "*"
        ports: [9090, 8080]
      - from: "ingress-nginx"
        to: "*"
        ports: [80, 443]
        
  # Azure Policies
  azure_policies:
    - "Kubernetes cluster should not allow privileged containers"
    - "Kubernetes clusters should use internal load balancers"
    - "Kubernetes cluster containers should only use allowed images"
    
  # Defender
  defender:
    enabled: true
    plans:
      - "Containers"
      - "KeyVault"
      - "Arm"
      
  # Key Vault Integration
  keyvault:
    csi_driver: true
    secret_store_class: "azure-keyvault"
    
  # External Secrets
  external_secrets:
    enabled: true
    provider: "azure-keyvault"
```

## Acceptance Criteria
- [ ] Workload Identity configured for specified namespaces
- [ ] RBAC roles and bindings created
- [ ] Network policies applied
- [ ] Azure Policies assigned
- [ ] Defender enabled
- [ ] Key Vault CSI driver installed
- [ ] External Secrets Operator running
```

---

## 🛠️ Tools & Commands

### Workload Identity Setup

```bash
# Get AKS OIDC issuer
OIDC_ISSUER=$(az aks show -n ${AKS_NAME} -g ${RG_NAME} \
  --query "oidcIssuerProfile.issuerUrl" -o tsv)

# Create managed identity
az identity create -n ${APP_NAME}-identity -g ${RG_NAME}

IDENTITY_CLIENT_ID=$(az identity show -n ${APP_NAME}-identity -g ${RG_NAME} \
  --query "clientId" -o tsv)

# Create federated credential
az identity federated-credential create \
  --name ${APP_NAME}-fed \
  --identity-name ${APP_NAME}-identity \
  --resource-group ${RG_NAME} \
  --issuer ${OIDC_ISSUER} \
  --subject "system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
  --audiences "api://AzureADTokenExchange"

# Grant Key Vault access
az keyvault set-policy -n ${KV_NAME} \
  --secret-permissions get list \
  --object-id $(az identity show -n ${APP_NAME}-identity -g ${RG_NAME} --query "principalId" -o tsv)
```

### RBAC Configuration

```bash
# Create ClusterRoleBinding
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: platform-admins
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: Group
    name: "platform-team@company.com"
    apiGroup: rbac.authorization.k8s.io
EOF
```

### Network Policies

```bash
# Default deny all
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: ${NAMESPACE}
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
EOF

# Allow from monitoring
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
  namespace: ${NAMESPACE}
spec:
  podSelector: {}
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: monitoring
      ports:
        - port: 9090
        - port: 8080
EOF
```

### External Secrets Operator

```bash
# Install ESO
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace

# Create ClusterSecretStore
kubectl apply -f - <<EOF
apiVersion: external-secrets.io/v1beta1
kind: ClusterSecretStore
metadata:
  name: azure-keyvault
spec:
  provider:
    azurekv:
      authType: WorkloadIdentity
      vaultUrl: "https://${KV_NAME}.vault.azure.net"
      serviceAccountRef:
        name: external-secrets
        namespace: external-secrets
EOF
```

---

## ✅ Validation Criteria

```yaml
validation:
  workload_identity:
    - federated_credentials_created: true
    - service_accounts_annotated: true
    - token_exchange_working: true
    
  rbac:
    - cluster_roles_exist: true
    - role_bindings_exist: true
    - access_test_pass: true
    
  network_policies:
    - policies_applied: true
    - default_deny_active: true
    - allowed_traffic_flows: true
    
  defender:
    - plans_enabled: ["Containers", "KeyVault"]
    - no_critical_findings: true
    
  secrets:
    - csi_driver_running: true
    - external_secrets_running: true
    - test_secret_sync: true
```

---

## 💬 Agent Communication

### On Success
```markdown
✅ **Security Configuration Complete**

**Workload Identity:**
| Namespace | Service Account | Identity |
|-----------|-----------------|----------|
| argocd | argocd-server | argocd-identity |
| ai-apps | ai-workload | ai-apps-identity |

**RBAC:**
- ✅ platform-admins: cluster-admin
- ✅ developers: edit (dev-* namespaces)

**Network Policies:** 3 policies applied

**Defender:** ✅ Enabled (Containers, KeyVault)

**External Secrets:** ✅ Running, syncing from ${KV_NAME}

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `infrastructure-agent` | **Prerequisite** |
| `gitops-agent` | **Post** |
| `observability-agent` | **Parallel** |

---

**Spec Version:** 1.0.0
