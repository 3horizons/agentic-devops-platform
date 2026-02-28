# Three Horizons RHDH — Deployment & Customization Guide

**Platform:** Red Hat Developer Hub (RHDH)
**Target:** `devhub.135.18.141.224.nip.io`
**Auth:** GitHub OAuth | **Branding:** Microsoft 4-Color Palette + White Background
**Version:** 1.0 | **Author:** Paula Silva — Microsoft Latam GBB

---

## 1. Architecture Overview

Red Hat Developer Hub (RHDH) is Red Hat's enterprise distribution of Backstage. It provides a supported, pre-packaged version with additional features like dynamic plugin loading, built-in RBAC, and Developer Lightspeed AI. The key advantage of RHDH is that **all customization — including branding, homepage, plugins, and authentication — is done entirely through YAML configuration**. No code changes are required.

The Three Horizons deployment on Azure uses Helm charts with ConfigMaps to inject all customization. This makes updates as simple as editing a YAML file and running `helm upgrade` or updating a ConfigMap.

### Key Differences from Backstage

| Aspect | Backstage (OSS) | RHDH (Red Hat) |
|--------|-----------------|----------------|
| Customization | React/TypeScript code | YAML-only configuration |
| Plugin Loading | Build-time (compiled) | Dynamic (runtime YAML) |
| RBAC | Plugin required | Built-in with policies |
| AI Assistant | Manual integration | Developer Lightspeed built-in |
| Support | Community | Red Hat enterprise support |
| Deploy Method | Docker build + kubectl | Helm upgrade + ConfigMaps |
| Branding | Custom theme.ts | `branding:` section in YAML |

---

## 2. Configuration Files

All RHDH configuration files are in `three-horizons-rhdh/deploy/`. These files are applied via Kubernetes ConfigMaps and Helm values — no container rebuild needed.

| File | Purpose | K8s Resource |
|------|---------|-------------|
| `app-config-rhdh.yaml` | Complete app config (branding, auth, catalog, plugins) | ConfigMap: `rhdh-app-config` |
| `dynamic-plugins.yaml` | Plugin enablement list (20+ plugins) | ConfigMap: `rhdh-dynamic-plugins` |
| `helm-values.yaml` | Helm chart values for deployment | Helm release values |
| `configmaps.yaml` | Homepage data + RBAC policy ConfigMaps | ConfigMaps: `rhdh-homepage-data`, `rhdh-rbac-policy` |
| `secrets.yaml` | Credential template (GitHub, PostgreSQL, AI) | Secret: `rhdh-secrets` |

### Branding Configuration

The `branding` section in `app-config-rhdh.yaml` controls all visual aspects of the RHDH portal. Colors, fonts, favicon, and sidebar styling are all defined in YAML:

```yaml
branding:
  title: Three Horizons
  favicon: data:image/svg+xml,...  # MS 4-color squares
  theme:
    light:
      primaryColor: '#00A4EF'
      headerColor1: '#00A4EF'
      headerColor2: '#0078D4'
      backgroundColor: '#FFFFFF'
      fontFamily: "'Segoe UI', system-ui, sans-serif"
      sidebarBackgroundColor: '#1B1B1F'
      sidebarSelectedItemIndicatorColor: '#00A4EF'
```

### Dynamic Plugins

RHDH loads plugins dynamically at runtime via YAML. The `dynamic-plugins.yaml` file enables 20+ plugins:

| Plugin Category | Plugins | Count |
|----------------|---------|-------|
| Core | Home, Search, Catalog, Scaffolder, TechDocs, API Docs | 6 |
| GitHub | GitHub Actions, GitHub Issues, Catalog Backend | 3 |
| AI | Developer Lightspeed (frontend + backend) | 2 |
| Security | RBAC (Janus IDP) | 1 |
| Infrastructure | Kubernetes, Kubernetes Backend, Topology | 3 |

### Homepage Data

The homepage content is stored in a ConfigMap (`rhdh-homepage-data`) as JSON. It defines Quick Access sections, Featured Templates, and Three Horizons cards.

| Section | Content |
|---------|---------|
| Quick Access: Getting Started | Platform Overview, Onboarding Guide, Create First Service, Connect GitHub |
| Quick Access: Development | Software Catalog, API Explorer, Tech Docs, GitHub Actions |
| Quick Access: AI & Automation | Developer Lightspeed, GitHub Copilot Setup, MCP Registry, Azure AI Foundry |
| Quick Access: Operations | Kubernetes Topology, CI/CD Pipelines, Service Health, RBAC Administration |
| Featured Templates | Node.js, Python FastAPI, React, .NET Web API, Spring Boot, Go |
| Three Horizons | H1: Foundation (Blue), H2: Intelligence (Green), H3: Autonomy (Yellow) |

---

## 3. Prerequisites

| Requirement | Version | Purpose |
|-------------|---------|---------|
| kubectl | 1.28+ | Kubernetes cluster management |
| Helm | v3+ | RHDH Helm chart deployment |
| GitHub OAuth App | N/A | Authentication credentials |
| PostgreSQL | 15+ (auto-provisioned) | Catalog and auth storage |
| Azure AI Foundry | N/A | Developer Lightspeed AI backend |
| RHDH Helm Chart | `redhat-developer/backstage` | Official Red Hat Helm chart |

### GitHub OAuth App Setup

1. Go to **GitHub > Settings > Developer Settings > OAuth Apps > New OAuth App**
2. Application name: `Three Horizons RHDH`
3. Homepage URL: `https://devhub.135.18.141.224.nip.io`
4. Authorization callback URL: `https://devhub.135.18.141.224.nip.io/api/auth/github/handler/frame`
5. Click **Register application** and copy Client ID and Client Secret
6. Add credentials to `secrets.yaml` under `GITHUB_APP_CLIENT_ID` and `GITHUB_APP_CLIENT_SECRET`

> **⚠️ Important:** The callback URL must match exactly — including the `/api/auth/github/handler/frame` path.

---

## 4. Step-by-Step Deployment

### Step 1 — Prepare secrets

Edit `secrets.yaml` and replace all placeholder values with real credentials. Generate random secrets using:

```bash
node -e "console.log(require('crypto').randomBytes(24).toString('base64'))"
```

Required secrets:

- `GITHUB_APP_CLIENT_ID` — From GitHub OAuth App
- `GITHUB_APP_CLIENT_SECRET` — From GitHub OAuth App
- `GITHUB_ORG` — Your GitHub organization name
- `BACKEND_AUTH_SECRET` — Random generated secret
- `AUTH_SESSION_SECRET` — Random generated secret
- `POSTGRES_PASSWORD` — Database password
- `AZURE_AI_FOUNDRY_ENDPOINT` — Azure AI Foundry URL (for Lightspeed)
- `AZURE_AI_FOUNDRY_API_KEY` — Azure AI Foundry API key
- `RHDH_ADMIN_USER` — Your GitHub username (admin access)

### Step 2 — Create namespace and apply secrets

```bash
# Create namespace
kubectl create namespace rhdh --dry-run=client -o yaml | kubectl apply -f -

# Apply secrets
kubectl apply -f three-horizons-rhdh/deploy/secrets.yaml
```

### Step 3 — Create ConfigMaps

```bash
# App configuration
kubectl create configmap rhdh-app-config \
  --from-file=app-config-rhdh.yaml=three-horizons-rhdh/deploy/app-config-rhdh.yaml \
  -n rhdh --dry-run=client -o yaml | kubectl apply -f -

# Homepage data + RBAC policy
kubectl apply -f three-horizons-rhdh/deploy/configmaps.yaml

# Dynamic plugins
kubectl create configmap rhdh-dynamic-plugins \
  --from-file=dynamic-plugins.yaml=three-horizons-rhdh/deploy/dynamic-plugins.yaml \
  -n rhdh --dry-run=client -o yaml | kubectl apply -f -
```

### Step 4 — Deploy with Helm

```bash
# Add Helm repo
helm repo add redhat-developer https://redhat-developer.github.io/rhdh-chart
helm repo update

# Install or upgrade
helm upgrade --install rhdh redhat-developer/backstage \
  -f three-horizons-rhdh/deploy/helm-values.yaml \
  -n rhdh \
  --wait --timeout 10m
```

### Step 5 — Verify deployment

```bash
# Check rollout status
kubectl rollout status deployment/rhdh-backstage -n rhdh

# Check health endpoint
curl -s -o /dev/null -w '%{http_code}' \
  https://devhub.135.18.141.224.nip.io/healthcheck

# Check pod logs
kubectl logs -f deployment/rhdh-backstage -n rhdh
```

---

## 5. Sidebar Navigation Reference

| Item | Route | Plugin/Feature |
|------|-------|---------------|
| Home | `/` | `backstage.plugin-home` |
| My Group | `/catalog?filters[kind]=Group` | `backstage.plugin-catalog` |
| Catalog | `/catalog` | `backstage.plugin-catalog` |
| APIs | `/api-docs` | `backstage.plugin-api-docs` |
| Learning Paths | `/learning` | Custom documentation |
| Create | `/create` | `backstage.plugin-scaffolder` |
| Docs | `/docs` | `backstage.plugin-techdocs` |
| Notifications | `/notifications` | Notification center |
| Administration | `/rbac` | `janus-idp.backstage-plugin-rbac` |
| Settings | `/settings` | User settings |

---

## 6. RBAC Policies

RHDH includes built-in Role-Based Access Control. The RBAC policy is stored in a ConfigMap and defines three roles:

| Role | Permissions | Assignment |
|------|------------|------------|
| Admin | Full access: read, create, update, delete catalog + policies + K8s proxy | `group:default/admins` |
| Developer | Read catalog, create entities, run templates, K8s proxy | `group:default/developers` |
| Viewer | Read-only: catalog and policies | `group:default/viewers` |

> **💡 Tip:** Map GitHub teams to RHDH groups via the `githubOrg` catalog provider for automatic role assignment.

---

## 7. Updating Content (Without Rebuild)

### Updating Homepage Content

To update Quick Access links, Templates, or Three Horizons cards:

1. Edit the `homepage-data.json` section in `configmaps.yaml`
2. Apply the updated ConfigMap: `kubectl apply -f configmaps.yaml -n rhdh`
3. Restart the pod: `kubectl rollout restart deployment/rhdh-backstage -n rhdh`
4. Verify the changes at `https://devhub.135.18.141.224.nip.io`

### Updating Branding

To change colors, fonts, or favicon:

1. Edit the `branding` section in `app-config-rhdh.yaml`
2. Update the ConfigMap: `kubectl create configmap rhdh-app-config --from-file=... | kubectl apply -f -`
3. Restart the pod: `kubectl rollout restart deployment/rhdh-backstage -n rhdh`

### Adding New Plugins

To enable additional dynamic plugins:

1. Add the plugin entry in `dynamic-plugins.yaml` with `disabled: false`
2. If the plugin needs configuration, add it to `app-config-rhdh.yaml`
3. Update both ConfigMaps and restart the pod

---

## 8. Verification & Troubleshooting

### Post-Deploy Verification

1. Access `https://devhub.135.18.141.224.nip.io` — should see Microsoft-branded login page
2. Click "Sign in with GitHub" — should redirect to GitHub OAuth
3. After login, verify homepage shows Quick Access, Templates, and Three Horizons
4. Check the sidebar has all 10 navigation items
5. Test Developer Lightspeed at `/lightspeed`
6. Verify RBAC at `/rbac` (admin users only)

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| GitHub login fails | Wrong callback URL | Verify OAuth App callback matches exactly |
| Homepage blank | ConfigMap not mounted | Check volumes in `helm-values.yaml` |
| Branding not applied | Pod cache | Restart: `kubectl rollout restart deployment/rhdh-backstage` |
| Lightspeed not working | Missing AI credentials | Check `AZURE_AI_FOUNDRY_ENDPOINT` and `API_KEY` in secrets |
| Plugins not loading | Wrong plugin path | Verify `dynamic-plugins.yaml` paths match RHDH version |
| RBAC denied | Missing role mapping | Check GitHub org/team mapping in catalog provider |
| Pod CrashLoop | Config syntax error | Check logs: `kubectl logs -f deployment/rhdh-backstage` |

### Rollback

```bash
# Rollback Helm release to previous revision:
helm rollback rhdh -n rhdh

# Or rollback to a specific revision:
helm rollback rhdh 2 -n rhdh

# Check revision history:
helm history rhdh -n rhdh
```

---

## 9. Branding Reference

| Element | Value |
|---------|-------|
| Background | `#FFFFFF` (White) |
| Microsoft Blue | `#00A4EF` |
| Microsoft Green | `#7FBA00` |
| Microsoft Yellow | `#FFB900` |
| Microsoft Red | `#F25022` |
| Font Family | Segoe UI, system-ui, sans-serif |
| Auth Provider | GitHub OAuth only |
| Favicon | Microsoft 4-color squares (SVG inline) |
| Sidebar Background | `#1B1B1F` (Dark) |
| Logo | Microsoft logo via `img.icons8.com/color/96/microsoft.png` |

---

## Sources

- [RHDH Documentation](https://docs.redhat.com/en/documentation/red_hat_developer_hub/)
- [RHDH Helm Chart](https://github.com/redhat-developer/rhdh-chart)
- [Developer Hub Landing Page](https://docs.developerhub.io/support-center/custom-landing-page)
- [RHDH Dynamic Plugins](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.4/html/configuring_plugins_in_red_hat_developer_hub/)
