# Red Hat Developer Hub Accelerator — Agent Ecosystem

| Field | Value |
|-------|-------|
| **Repository** | `three-horizons-rhdh` |
| **Portal Technology** | Red Hat Developer Hub (RHDH) |
| **Cluster** | Azure AKS or Azure Red Hat OpenShift (ARO) |
| **Date** | February 26, 2026 |
| **Version** | 1.0 |
| **Author** | paulasilva@microsoft.com |
| **Total Agents** | 15 |

---

## 1. Repository Scope

This repository contains the **Red Hat Developer Hub (RHDH)** accelerator. Everything here is specific to:

- **Dynamic plugins** — enabled via YAML config (`disabled: false`), no code changes
- **Red Hat pre-built image** — `registry.redhat.io/rhdh` (requires Red Hat subscription)
- **Declarative EntityPage** — mount points and dynamic routes in YAML
- **Helm values + ConfigMaps** — configuration mounted at runtime, never baked into image
- **RBAC built-in** — CSV permission policies, no community plugin needed
- **Dual cluster support** — AKS (Helm) or ARO (Operator)
- **Operator lifecycle** — `rhdh.redhat.com/v1alpha3` Custom Resource on ARO

**What is NOT in this repository:**
- Backstage upstream — see `three-horizons-backstage` repository
- Static plugins, `yarn add`, EntityPage.tsx, custom Docker images, ACR

---

## 2. Agent Inventory (15 Agents)

### Group 1: Foundation (7 agents — technology-agnostic)

| Agent | Responsibility | Completes Task Solo |
|-------|---------------|---------------------|
| `architect` | Solution design, WAF, ADRs, Mermaid diagrams | ✅ |
| `terraform` | Azure IaC — write, validate, plan .tf files | ✅ |
| `security` | Compliance, vulnerabilities, Zero Trust, OWASP | ✅ |
| `reviewer` | Code quality, SOLID, Clean Code, PR review | ✅ |
| `test` | TDD, unit/integration/e2e, coverage analysis | ✅ |
| `docs` | Technical writing, READMEs, ADRs, Mermaid | ✅ |
| `sre` | Observability, SLOs, incident response | ✅ |

### Group 2: Delivery (3 agents)

| Agent | Responsibility | Completes Task Solo |
|-------|---------------|---------------------|
| `devops` | GitHub Actions, ArgoCD, K8s, Helm | ✅ |
| `deploy` | Deployment orchestrator (12-step sequence) | ✅ (via handoffs) |
| `onboarding` | New user guidance, prerequisites, first deploy | ✅ |

### Group 3: Azure Infrastructure (1 agent)

| Agent | Responsibility | Completes Task Solo |
|-------|---------------|---------------------|
| `azure-portal-deploy` | Provision AKS or ARO, Key Vault, PostgreSQL | ✅ |

### Group 4: Portal Expert (1 agent)

| Agent | Responsibility | Completes Task Solo |
|-------|---------------|---------------------|
| `rhdh-expert` | Deploy RHDH, dynamic plugins, RBAC, Helm/Operator, ConfigMaps | ✅ |

### Group 5: Portal Services (3 agents)

| Agent | Responsibility | Completes Task Solo |
|-------|---------------|---------------------|
| `template-engineer` | Software Templates v1beta3, Codespaces, devcontainer | ✅ |
| `github-integration` | GitHub App, OAuth, org discovery, GHAS, Actions | ✅ |
| `ado-integration` | ADO PAT, pipelines, boards, Copilot | ✅ |

---

## 3. RHDH-Specific Technical Stack

### Plugin Lifecycle (Dynamic)
```
1. Edit dynamic-plugins.yaml (or Helm values):
     plugins:
       - package: ./dynamic-plugins/dist/backstage-plugin-kubernetes
         disabled: false
2. Add pluginConfig if needed (same file or app-config-rhdh ConfigMap)
3. Pod restarts → init container (install-dynamic-plugins) installs the plugin
4. Plugin loaded at runtime by backend plugin manager
```

**For third-party plugins not pre-loaded in RHDH:**
```
1. Clone community plugin source
2. npx @red-hat-developer-hub/cli@latest plugin package --tag quay.io/org/plugin:v1.0
3. Push OCI image to registry
4. Reference in dynamic-plugins.yaml:
     - package: oci://quay.io/org/plugin:v1.0!plugin-name
       disabled: false
```

### Configuration Files

| Resource | Type | Purpose | Update Method |
|----------|------|---------|--------------|
| `values.yaml` | Helm values | Primary config for AKS deploy | `helm upgrade` |
| `app-config-rhdh` | ConfigMap | App config (auth, catalog, integrations) | `kubectl apply` |
| `dynamic-plugins-rhdh` | ConfigMap | Plugin enable/disable + pluginConfig | `kubectl apply` |
| `permission-policies` | ConfigMap | RBAC CSV policies | `kubectl apply` |
| `rhdh-secrets` | Secret | Env vars (tokens, passwords) | Key Vault CSI |
| Operator CR (`v1alpha3`) | Custom Resource | RHDH lifecycle on ARO | `oc apply` |

### Auth Configuration
```yaml
# app-config-rhdh ConfigMap — CONFIG ONLY, no code
auth:
  providers:
    github:
      production:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        signIn:
          resolvers:
            - resolver: usernameMatchingUserEntityName
```
```yaml
# dynamic-plugins.yaml — enable auth module
plugins:
  - package: ./dynamic-plugins/dist/backstage-plugin-auth-backend-module-github-provider-dynamic
    disabled: false
```

### RBAC Configuration (Built-in)
```csv
# permission-policies.csv ConfigMap
p, role:default/platform-admin, catalog.entity.read, read, allow
p, role:default/platform-admin, catalog.entity.create, create, allow
p, role:default/platform-admin, scaffolder.template.instantiate, use, allow
p, role:default/developer, catalog.entity.read, read, allow
p, role:default/developer, scaffolder.template.instantiate, use, allow
g, group:default/platform-engineers, role:default/platform-admin
g, group:default/engineering, role:default/developer
```

### Template Registration
```yaml
# Option A: Helm values
upstream:
  backstage:
    appConfig:
      catalog:
        locations:
          - type: url
            target: https://github.com/my-org/templates/blob/main/template.yaml
            rules:
              - allow: [Template]

# Option B: app-config-rhdh ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config-rhdh
data:
  app-config-rhdh.yaml: |
    catalog:
      locations:
        - type: url
          target: https://github.com/my-org/templates/blob/main/template.yaml

# Option C: RHDH Self-service UI
# Self-service > Manage Templates > Register Existing Template
```

### EntityPage Composition (Declarative)
```yaml
# dynamic-plugins.yaml — mount points, no React code
plugins:
  - package: ./dynamic-plugins/dist/backstage-plugin-kubernetes
    disabled: false
    pluginConfig:
      dynamicPlugins:
        frontend:
          backstage-plugin-kubernetes:
            mountPoints:
              - mountPoint: entity.page.kubernetes/cards
                importName: EntityKubernetesContent
                config:
                  layout:
                    gridColumnEnd: "span 12"
            dynamicRoutes:
              - path: /kubernetes
                importName: EntityKubernetesContent
```

### Deployment Architecture — AKS
```
Azure AKS Cluster
├── Namespace: rhdh
│   ├── Deployment: developer-hub
│   │   ├── Init Container: install-dynamic-plugins
│   │   │   └── Reads dynamic-plugins ConfigMap
│   │   └── Main Container: registry.redhat.io/rhdh
│   │       └── Mounts: app-config-rhdh + rhdh-secrets
│   ├── Service: developer-hub
│   ├── Ingress + cert-manager TLS
│   ├── ConfigMap: app-config-rhdh
│   ├── ConfigMap: dynamic-plugins-rhdh
│   ├── ConfigMap: permission-policies
│   ├── Secret: rhdh-secrets (via Key Vault CSI)
│   └── PVC: dynamic-plugins-root (plugin cache)
├── Azure Key Vault — secrets
└── Azure PostgreSQL Flexible Server — database
```

### Deployment Architecture — ARO
```
Azure Red Hat OpenShift (ARO)
├── Namespace: rhdh
│   ├── RHDH Operator (from OLM OperatorHub)
│   │   └── Manages Backstage CR (v1alpha3)
│   ├── Backstage CR: developer-hub
│   │   └── spec.application:
│   │       ├── appConfig.configMaps: [app-config-rhdh]
│   │       ├── dynamicPluginsConfigMapName: dynamic-plugins-rhdh
│   │       ├── extraEnvs.secrets: [rhdh-secrets]
│   │       ├── replicas: 2
│   │       └── route.enabled: true
│   ├── OpenShift Route (auto-TLS)
│   ├── ConfigMap: app-config-rhdh
│   ├── ConfigMap: dynamic-plugins-rhdh
│   ├── ConfigMap: permission-policies
│   ├── Secret: rhdh-secrets
│   └── PVC: dynamic-plugins-root
├── Azure Key Vault — secrets
└── Azure PostgreSQL Flexible Server — database
```

---

## 4. Handoff Matrix

| Source Agent | Hands Off To |
|-------------|-------------|
| `architect` | `terraform`, `security` |
| `terraform` | `security`, `devops` |
| `security` | `devops` |
| `reviewer` | `security` |
| `test` | `reviewer` |
| `docs` | `architect` |
| `sre` | `devops`, `security` |
| `devops` | `security`, `platform` |
| `deploy` | `security`, `terraform`, `sre`, `rhdh-expert`, `azure-portal-deploy`, `github-integration`, `ado-integration` |
| `onboarding` | `architect`, `terraform`, `deploy` |
| `azure-portal-deploy` | `rhdh-expert`, `terraform`, `security` |
| `rhdh-expert` | `azure-portal-deploy`, `github-integration`, `ado-integration`, `deploy`, `security` |
| `github-integration` | `rhdh-expert`, `security` |
| `ado-integration` | `rhdh-expert` |
| `template-engineer` | `rhdh-expert`, `github-integration`, `ado-integration`, `security`, `devops` |

---

## 5. Task Ownership — "Who Do I Call?"

| User Request | Call This Agent |
|-------------|----------------|
| "Design a new architecture" | `architect` |
| "Write Terraform for AKS/ARO" | `terraform` |
| "Review my code" | `reviewer` |
| "Write tests for this module" | `test` |
| "Set up CI/CD pipeline" | `devops` |
| "Deploy the platform" | `deploy` |
| "I am new, help me start" | `onboarding` |
| "Check why pods are crashing" | `sre` |
| "Scan for vulnerabilities" | `security` |
| "Update the README" | `docs` |
| "Create a Golden Path template" | `template-engineer` |
| "Set up RHDH on AKS" | `rhdh-expert` |
| "Set up RHDH on ARO" | `rhdh-expert` |
| "Provision AKS or ARO cluster" | `azure-portal-deploy` |
| "Configure GitHub App for RHDH" | `github-integration` |
| "Connect ADO to RHDH" | `ado-integration` |
| "Enable Kubernetes plugin" | `rhdh-expert` |
| "Configure RBAC policies" | `rhdh-expert` |
| "Enable a dynamic plugin" | `rhdh-expert` |
| "Package a third-party plugin" | `rhdh-expert` |
| "Add a tab to the entity page" | `rhdh-expert` |
| "Configure GitHub OAuth" | `rhdh-expert` + `github-integration` |

---

## 6. Deployment Sequence

### Path A: RHDH on AKS (Helm)
```
Step 1:  onboarding      → Prerequisites + .tfvars + Red Hat pull secret
Step 2:  deploy           → Choose AKS deployment
Step 3:  azure-portal-deploy → Provision AKS + Key Vault + PostgreSQL
Step 4:  terraform        → terraform plan + apply
Step 5:  security         → Review deployment config
Step 6:  rhdh-expert      → Create ConfigMaps (app-config + dynamic-plugins + RBAC)
Step 7:  rhdh-expert      → helm install redhat-developer-hub
Step 8:  github-integration → Create GitHub App + configure OAuth
Step 9:  rhdh-expert      → Update ConfigMap with auth + catalog config
Step 10: template-engineer → Create Golden Path templates
Step 11: rhdh-expert      → Register templates via ConfigMap or UI
Step 12: sre              → Verify platform health
Step 13: deploy           → Summary: Portal URL + credentials + template count
```

### Path B: RHDH on ARO (Operator)
```
Step 1:  onboarding      → Prerequisites + .tfvars + Red Hat pull secret
Step 2:  deploy           → Choose ARO deployment
Step 3:  azure-portal-deploy → Provision ARO + Key Vault + PostgreSQL
Step 4:  terraform        → terraform plan + apply
Step 5:  security         → Review deployment config
Step 6:  rhdh-expert      → Install RHDH Operator from OperatorHub
Step 7:  rhdh-expert      → Create ConfigMaps (app-config + dynamic-plugins + RBAC)
Step 8:  rhdh-expert      → Apply Backstage CR (v1alpha3)
Step 9:  github-integration → Create GitHub App + configure OAuth
Step 10: rhdh-expert      → Update ConfigMap with auth + catalog config
Step 11: template-engineer → Create Golden Path templates
Step 12: rhdh-expert      → Register templates via ConfigMap or UI
Step 13: sre              → Verify platform health
Step 14: deploy           → Summary: Portal URL (OpenShift Route) + credentials
```

---

## 7. Boundary Summary

### Destructive Actions — NEVER Allowed
- `terraform destroy`
- Delete K8s/OCP production resources
- Delete catalog entities
- Delete repos
- Grant IAM access
- Disable security controls
- Merge code / auto-approve PRs
- Expose secrets
- Deploy outside Central US / East US
- Use without Red Hat subscription
- Disable auth in production
- Store secrets in ConfigMaps (always Key Vault)
- Use SQLite in production (always PostgreSQL)

### Ask First Actions
- `terraform plan` / `terraform apply`
- Create GitHub App
- Create ADO PAT
- Configure RBAC policies (may restrict access)
- Restart pods
- Register entities in catalog
- Install RHDH Operator
