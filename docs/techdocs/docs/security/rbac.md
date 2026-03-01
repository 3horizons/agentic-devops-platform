# RBAC Policies

Role-Based Access Control is enforced at multiple layers of the Three Horizons platform: RHDH portal, Kubernetes clusters, Azure resources, ArgoCD, and CI/CD pipelines. This document covers the configuration and management of RBAC across all layers.

---

## RBAC Architecture Overview

```
Azure AD Groups (source of truth)
        |
        +--> RHDH Portal (Admin, Developer, Viewer)
        |
        +--> Kubernetes (namespace-scoped Roles + ClusterRoles)
        |
        +--> ArgoCD (project-level permissions)
        |
        +--> Azure RBAC (resource group-scoped role assignments)
        |
        +--> GitHub (org teams, repo permissions)
```

Azure AD groups serve as the identity source. Group memberships propagate to all platform layers through OIDC federation, GitHub OAuth, and Kubernetes RBAC bindings.

---

## RHDH Portal Roles

RHDH provides built-in RBAC with three predefined roles managed via CSV-based policy files. The RBAC plugin (`janus-idp.backstage-plugin-rbac`) is enabled as a dynamic plugin and accessible from the Administration menu.

### Admin

Full platform management capabilities:

- Create, update, and delete catalog entities
- Manage Golden Path templates
- Configure dynamic plugins
- Manage RBAC policies and user roles
- Access all TechDocs and API definitions
- View Engineering Intelligence dashboards
- Access the RBAC administration page
- Manage Lightspeed AI configuration

### Developer

Standard development capabilities:

- Browse the Software Catalog
- Create components from Golden Path templates
- View and update owned catalog entities
- Access TechDocs and API definitions
- Use Developer Lightspeed AI chat
- View owned component metrics and logs
- Trigger scaffolder actions for owned templates
- View CI/CD pipeline status for owned components

### Viewer

Read-only access:

- Browse the Software Catalog (read-only)
- View TechDocs and API definitions
- View public dashboards
- No create or modify permissions
- No access to Lightspeed AI chat
- No access to scaffolder actions

---

## CSV-Based RBAC Policy Management

RBAC policies are defined in CSV format and loaded into RHDH at startup. The policy file is stored in `new-features/configs/` and mounted into the RHDH container.

### Policy Format

RHDH uses a Casbin-based policy engine with two types of rules:

**Permission rules** (`p` prefix) define what a role can do:

```csv
p, role:default/<role>, <resource>, <action>, <effect>
```

**Group rules** (`g` prefix) assign users and groups to roles:

```csv
g, user:default/<username>, role:default/<role>
g, group:default/<group-name>, role:default/<role>
```

### Complete Policy Example

```csv
# ---- Permission Rules ----

# Admin: full access to all resources
p, role:default/admin, catalog-entity, create, allow
p, role:default/admin, catalog-entity, read, allow
p, role:default/admin, catalog-entity, update, allow
p, role:default/admin, catalog-entity, delete, allow
p, role:default/admin, catalog.entity.create, use, allow
p, role:default/admin, scaffolder-template, read, allow
p, role:default/admin, scaffolder-action, use, allow
p, role:default/admin, policy-entity, read, allow
p, role:default/admin, policy-entity, create, allow
p, role:default/admin, policy-entity, update, allow
p, role:default/admin, policy-entity, delete, allow

# Developer: create and manage owned entities
p, role:default/developer, catalog-entity, create, allow
p, role:default/developer, catalog-entity, read, allow
p, role:default/developer, catalog-entity, update, allow
p, role:default/developer, scaffolder-template, read, allow
p, role:default/developer, scaffolder-action, use, allow

# Viewer: read-only access
p, role:default/viewer, catalog-entity, read, allow
p, role:default/viewer, scaffolder-template, read, allow

# ---- Group Assignments ----

# Admins
g, user:default/admin-user, role:default/admin
g, group:default/platform-team, role:default/admin

# Developers
g, group:default/dev-team, role:default/developer
g, group:default/backend-team, role:default/developer
g, group:default/frontend-team, role:default/developer

# Viewers
g, group:default/stakeholders, role:default/viewer
g, group:default/management, role:default/viewer
```

### RHDH Configuration

The RBAC system is enabled in `app-config-rhdh.yaml`:

```yaml
permission:
  enabled: true
  rbac:
    admin:
      users:
        - name: ${RHDH_ADMIN_USER:admin}
    policies-csv-file: /opt/app-root/src/rbac-policy.csv
```

### Updating RBAC Policies

1. Edit the RBAC CSV file in the `new-features/configs/` directory
2. Commit the change to the repository
3. ArgoCD syncs the updated ConfigMap to the RHDH deployment
4. Changes take effect on the next RHDH pod restart or configuration reload

```bash
# Verify RBAC policies are loaded
kubectl exec -n rhdh deploy/rhdh-developer-hub -- \
  cat /opt/app-root/src/rbac-policy.csv
```

---

## Kubernetes RBAC

Kubernetes RBAC is configured per namespace with standard roles. The AKS cluster uses Azure AD integration for authentication, and RBAC is always enabled.

### Standard Namespace Roles

| Role | Permissions | Typical Binding |
|------|-------------|-----------------|
| `namespace-admin` | Full access within the namespace | Team leads, platform admins |
| `namespace-developer` | Create/update deployments, pods, services; read secrets | Developers |
| `namespace-viewer` | Read-only access to all resources | Stakeholders, on-call engineers |

### Role Definitions

```yaml
# namespace-admin: full access within the team namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-admin
  namespace: team-alpha
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]

---
# namespace-developer: standard developer access
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-developer
  namespace: team-alpha
rules:
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets", "statefulsets"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["pods", "services", "configmaps"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["pods/log", "pods/exec"]
    verbs: ["get", "list"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]

---
# namespace-viewer: read-only access
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: namespace-viewer
  namespace: team-alpha
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["get", "list", "watch"]
```

### RoleBindings

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: team-alpha-developers
  namespace: team-alpha
subjects:
  - kind: Group
    name: "<azure-ad-group-object-id>"
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: namespace-developer
  apiGroup: rbac.authorization.k8s.io
```

### Workload Service Accounts

Service accounts used by workloads are granted minimal permissions via RoleBindings scoped to their namespace. Workload Identity links these service accounts to Azure Managed Identities.

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service
  namespace: team-alpha
  annotations:
    azure.workload.identity/client-id: "<managed-identity-client-id>"
  labels:
    azure.workload.identity/use: "true"
```

---

## ArgoCD RBAC

ArgoCD RBAC maps Azure AD groups to project-level permissions. ArgoCD authenticates users via Azure AD SSO (OIDC).

### ArgoCD Roles

| Role | Permissions | Assigned To |
|------|-------------|-------------|
| **Platform Admins** | Full access to all projects and applications | `@platform-team` Azure AD group |
| **Team Leads** | Sync, manage applications within team project | Team lead Azure AD groups |
| **Developers** | View status, logs, events; no production sync | Developer Azure AD groups |
| **Read-Only** | View application status only | Stakeholder groups |

### ArgoCD RBAC Policy

```csv
# Platform admins: full access
p, role:admin, applications, *, */*, allow
p, role:admin, clusters, *, *, allow
p, role:admin, repositories, *, *, allow
p, role:admin, projects, *, *, allow

# Team leads: manage applications in their project
p, role:team-lead, applications, get, team-*/*, allow
p, role:team-lead, applications, sync, team-*/*, allow
p, role:team-lead, applications, action/*, team-*/*, allow
p, role:team-lead, applications, delete, team-*/*, deny

# Developers: view only, no sync in production
p, role:developer, applications, get, */*, allow
p, role:developer, applications, sync, dev-*/*, allow
p, role:developer, applications, sync, staging-*/*, allow
p, role:developer, applications, sync, prod-*/*, deny

# Map Azure AD groups to ArgoCD roles
g, platform-admins, role:admin
g, team-alpha-leads, role:team-lead
g, dev-team, role:developer
```

### ArgoCD SSO Configuration

ArgoCD integrates with Azure AD for single sign-on:

```yaml
server:
  config:
    oidc.config: |
      name: Azure AD
      issuer: https://login.microsoftonline.com/${AZURE_TENANT_ID}/v2.0
      clientID: ${ARGOCD_CLIENT_ID}
      clientSecret: ${ARGOCD_CLIENT_SECRET}
      requestedScopes:
        - openid
        - profile
        - email
```

---

## Azure RBAC

Azure resource access follows the principle of least privilege. Role assignments are scoped to the minimum resource group required.

### Role Assignment Model

| Identity | Role | Scope | Purpose |
|----------|------|-------|---------|
| AKS Cluster Identity | Network Contributor | VNet resource group | Manage VNet and subnets |
| AKS Kubelet Identity | AcrPull | Container Registry | Pull container images |
| ESO Managed Identity | Key Vault Secrets User | Key Vault | Read secrets |
| Terraform SP | Contributor | Subscription | Provision infrastructure |
| GitHub Actions | Contributor | Resource group | Deploy resources |

### Prohibited Assignments

The following role assignments are explicitly forbidden and enforced by policy:

- **Owner role**: Never assigned programmatically; requires manual approval
- **Subscription-scope Contributor**: Only for Terraform; all others are resource group-scoped
- **Key Vault Administrator**: Only for initial setup; use Key Vault Secrets User for runtime
- **Classic Administrator**: Deprecated; never use

### Azure AD Group Management

Azure AD groups serve as the identity source for all platform layers:

```
platform-team     --> RHDH Admin, ArgoCD Admin, K8s ClusterAdmin
infra-team        --> Terraform Contributor, K8s namespace-admin
security-team     --> Defender access, Key Vault admin
devops-team       --> ArgoCD team-lead, CI/CD pipeline access
dev-team          --> RHDH Developer, K8s namespace-developer
stakeholders      --> RHDH Viewer, ArgoCD read-only
```

---

## Policy-as-Code with OPA

OPA/Rego policies enforce RBAC-adjacent controls in both Terraform plans and Kubernetes runtime.

### Terraform Policies

Policies in `policies/terraform/azure.rego` check that:

- Required tags are present on all resources (including `owner` for attribution)
- AKS clusters have RBAC enabled
- No public access is configured on sensitive resources
- Managed Identity is used instead of service principals

### Kubernetes Policies

Gatekeeper constraint templates enforce runtime RBAC controls:

- `K8sRequiredLabels`: Ensures `app.kubernetes.io/name`, `app.kubernetes.io/instance`, and `app.kubernetes.io/version` labels are present
- Namespace isolation prevents cross-namespace access
- Service account tokens are not auto-mounted unless explicitly required

---

## Auditing

All RBAC changes are tracked through multiple audit trails:

| Layer | Audit Source | Retention |
|-------|-------------|-----------|
| RHDH | Git history of CSV policy files | Permanent (in Git) |
| Kubernetes | AKS audit logs (Container Insights) | 90 days |
| ArgoCD | ArgoCD event log and audit trail | 30 days |
| Azure | Azure Activity Log | 90 days (configurable) |
| GitHub | GitHub audit log | 90 days (Enterprise) |

### Viewing Audit Logs

```bash
# Kubernetes RBAC changes
kubectl get events --field-selector reason=Created -A

# Azure role assignments
az role assignment list --resource-group ${RESOURCE_GROUP} --output table

# ArgoCD access events
argocd admin settings rbac validate --policy-file argocd-rbac.csv
```

---

## RBAC Troubleshooting

### Common Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| User cannot access RHDH catalog | Missing group assignment in CSV | Add `g, user:default/<user>, role:default/developer` |
| Pod cannot pull images from ACR | Missing AcrPull role on kubelet identity | Verify Terraform `container-registry` module output |
| ArgoCD sync denied | User not in the correct ArgoCD role group | Add user to the appropriate Azure AD group |
| Cannot access Key Vault secrets | Missing Key Vault role assignment | Verify ESO Managed Identity has `Key Vault Secrets User` role |
| Kubectl access denied | AKS RBAC not bound to Azure AD group | Create RoleBinding for the Azure AD group |

### Useful Commands

```bash
# Check RHDH RBAC policies
kubectl exec -n rhdh deploy/rhdh-developer-hub -- \
  cat /opt/app-root/src/rbac-policy.csv

# Check Kubernetes RBAC for a user
kubectl auth can-i --list --as=<user> -n <namespace>

# Check Azure role assignments
az role assignment list --assignee <identity-id> --output table

# Validate ArgoCD RBAC policy
argocd admin settings rbac can role:developer sync applications 'prod-*/*'
```
