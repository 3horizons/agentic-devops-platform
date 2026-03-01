# Three Horizons — Portal Customization Deployment Guide

Complete guide for deploying Microsoft-branded homepage customizations to the live Backstage and RHDH portals on Azure.

## Architecture Overview

| Aspect | Backstage (Open Source) | RHDH (Red Hat) |
|--------|------------------------|----------------|
| **URL** | backstage.20.62.35.83.sslip.io | devhub.3horizons.ai |
| **Customization** | React/TypeScript code | YAML-only (ConfigMaps) |
| **Deploy Method** | Build new Docker image | Helm upgrade + ConfigMaps |
| **Auth** | GitHub OAuth | GitHub OAuth |
| **Branding** | Custom Backstage theme | RHDH branding section |

## Prerequisites

- `kubectl` configured for both clusters
- `helm` v3+ installed
- Node.js 18+ and `yarn` (Backstage only)
- Docker CLI (Backstage only)
- Container registry access (ACR, GHCR, or Docker Hub)
- GitHub OAuth App with callbacks configured for both URLs

---

## Part 1 — Backstage Customizations

Backstage is customized via React/TypeScript source code that gets compiled into the Docker image.

### Files Created

```
open-horizons-backstage/packages/app/src/
  theme.ts              → Microsoft theme (Segoe UI, 4-color palette, white bg)
  SignInPage.tsx         → GitHub OAuth login page with MS branding
  HomePage.tsx           → Custom homepage (Three Horizons, Quick Access, Templates)
  App.tsx                → Main app wiring (theme + auth + routes)
  Root.tsx               → Sidebar navigation (all menu items)
  app-config.local.yaml  → GitHub auth config + catalog settings
```

### Step-by-Step Deployment

**1. Copy files into your Backstage project:**

```bash
# From the root of your Backstage repo:
cp <workspace>/open-horizons-backstage/packages/app/src/theme.ts \
   packages/app/src/theme.ts

cp <workspace>/open-horizons-backstage/packages/app/src/SignInPage.tsx \
   packages/app/src/components/SignInPage.tsx

cp <workspace>/open-horizons-backstage/packages/app/src/HomePage.tsx \
   packages/app/src/components/HomePage.tsx
```

**2. Merge App.tsx changes** into your existing `packages/app/src/App.tsx`:

```typescript
// Add these imports:
import { microsoftTheme } from './theme';
import { SignInPage } from './components/SignInPage';
import { HomePage } from './components/HomePage';

// In createApp():
const app = createApp({
  // ... existing config
  themes: [{
    id: 'microsoft',
    title: 'Microsoft',
    variant: 'light',
    Provider: ({ children }) => (
      <UnifiedThemeProvider theme={microsoftTheme} children={children} />
    ),
  }],
  components: {
    SignInPage: props => <SignInPage {...props} />,
  },
});

// In routes, add:
<Route path="/" element={<HomePage />} />
```

**3. Merge Root.tsx** for sidebar navigation.

**4. Apply app-config:**

```bash
cp <workspace>/open-horizons-backstage/packages/app/src/app-config.local.yaml \
   app-config.local.yaml

# Edit with your real GitHub OAuth credentials:
# - GITHUB_CLIENT_ID
# - GITHUB_CLIENT_SECRET
# - GITHUB_ORG
```

**5. Build and deploy:**

```bash
yarn install
yarn tsc
yarn build:backend --config ../../app-config.yaml --config ../../app-config.local.yaml

# Docker build
docker build -t backstage-three-horizons:latest .
docker push <registry>/backstage-three-horizons:latest

# Update K8s
kubectl set image deployment/backstage \
  backstage=<registry>/backstage-three-horizons:latest \
  -n backstage
```

---

## Part 2 — RHDH Customizations

RHDH is customized entirely through YAML configuration — no code changes needed. Branding, plugins, and homepage data are applied via ConfigMaps and Helm values.

### Files Created

```
three-horizons-rhdh/deploy/
  app-config-rhdh.yaml   → Complete app config (branding, auth, catalog, plugins)
  dynamic-plugins.yaml   → Plugin enablement list
  helm-values.yaml       → Helm chart values for deployment
  configmaps.yaml        → K8s ConfigMaps (homepage data, RBAC policy)
  secrets.yaml           → K8s Secret template (credentials)
```

### Step-by-Step Deployment

**1. Edit secrets with real credentials:**

```bash
# Edit secrets.yaml and replace ALL placeholder values:
vi three-horizons-rhdh/deploy/secrets.yaml

# Required values:
# - GITHUB_APP_CLIENT_ID
# - GITHUB_APP_CLIENT_SECRET
# - GITHUB_ORG
# - BACKEND_AUTH_SECRET (generate random)
# - AUTH_SESSION_SECRET (generate random)
# - POSTGRES_PASSWORD
# - AZURE_AI_FOUNDRY_ENDPOINT (for Lightspeed)
# - AZURE_AI_FOUNDRY_API_KEY
# - RHDH_ADMIN_USER
```

**2. Create namespace and apply secrets:**

```bash
kubectl create namespace rhdh --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f three-horizons-rhdh/deploy/secrets.yaml
```

**3. Create ConfigMaps:**

```bash
# App config
kubectl create configmap rhdh-app-config \
  --from-file=app-config-rhdh.yaml=three-horizons-rhdh/deploy/app-config-rhdh.yaml \
  -n rhdh --dry-run=client -o yaml | kubectl apply -f -

# ConfigMaps (homepage data + RBAC)
kubectl apply -f three-horizons-rhdh/deploy/configmaps.yaml

# Dynamic plugins
kubectl create configmap rhdh-dynamic-plugins \
  --from-file=dynamic-plugins.yaml=three-horizons-rhdh/deploy/dynamic-plugins.yaml \
  -n rhdh --dry-run=client -o yaml | kubectl apply -f -
```

**4. Deploy with Helm:**

```bash
helm repo add redhat-developer https://redhat-developer.github.io/rhdh-chart
helm repo update

helm upgrade --install rhdh redhat-developer/backstage \
  -f three-horizons-rhdh/deploy/helm-values.yaml \
  -n rhdh \
  --wait --timeout 10m
```

**5. Verify:**

```bash
kubectl rollout status deployment/rhdh-backstage -n rhdh
curl -s -o /dev/null -w "%{http_code}" https://devhub.3horizons.ai/healthcheck
```

---

## Part 3 — GitHub OAuth Setup

Both portals need a GitHub OAuth App configured.

### Create GitHub OAuth App

1. Go to GitHub > Settings > Developer Settings > OAuth Apps > New OAuth App
2. For **Backstage**:
   - Homepage URL: `https://backstage.20.62.35.83.sslip.io`
   - Callback URL: `https://backstage.20.62.35.83.sslip.io/api/auth/github/handler/frame`
3. For **RHDH**:
   - Homepage URL: `https://devhub.3horizons.ai`
   - Callback URL: `https://devhub.3horizons.ai/api/auth/github/handler/frame`
4. Copy Client ID and Client Secret into the respective configs.

---

## Part 4 — Copilot Agent for Automation

A GitHub Copilot agent is available at:

```
.github/agents/deploy-portal-customizations.agent.md
```

This agent provides step-by-step commands that GitHub Copilot Chat (in VS Code) can execute to automate the entire deployment process.

### Usage in VS Code:

```
@workspace /deploy-portal-customizations Deploy RHDH customizations
```

---

## Branding Reference

| Element | Value |
|---------|-------|
| Background | White (#FFFFFF) |
| Microsoft Blue | #00A4EF |
| Microsoft Green | #7FBA00 |
| Microsoft Yellow | #FFB900 |
| Microsoft Red | #F25022 |
| Font Family | Segoe UI, system-ui, sans-serif |
| Auth Provider | GitHub OAuth only |
| Favicon | Microsoft 4-color squares (SVG) |

---

## Rollback Procedures

### Backstage
```bash
kubectl rollout undo deployment/backstage -n backstage
```

### RHDH
```bash
helm rollback rhdh -n rhdh
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| GitHub login redirect fails | Verify OAuth callback URL matches exactly |
| Homepage not showing | Check ConfigMap is mounted correctly in pod |
| Branding not applied | Restart pod after ConfigMap update |
| Lightspeed not working | Verify Azure AI Foundry endpoint and API key |
| Plugins not loading | Check dynamic-plugins.yaml paths match RHDH version |
| RBAC permission denied | Verify user is in correct GitHub org/team mapped to RBAC role |
