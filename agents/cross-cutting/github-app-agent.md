# GitHub App Agent

## 🤖 Agent Identity

```yaml
name: github-app-agent
version: 1.0.0
horizon: Cross-Cutting
description: |
  Creates and manages GitHub Apps, OAuth Apps, and webhooks.
  Configures authentication for RHDH/Backstage, ArgoCD, and 
  enterprise integrations with proper permissions and secrets.
  
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
| RHDH Integration | `platform/rhdh/values.yaml` |
| ArgoCD Integration | `argocd/repo-credentials.yaml` |
| Bootstrap Script | `scripts/bootstrap.sh` |
| MCP Servers | `mcp-servers/mcp-config.json` (github) |

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Create GitHub App** | Full GitHub App with permissions | High |
| **Create OAuth App** | OAuth App for web authentication | Medium |
| **Configure Webhooks** | Repository and org webhooks | Medium |
| **Generate Private Key** | App authentication key | Low |
| **Install App** | Install on org/repos | Medium |
| **Configure Permissions** | Set required scopes | Medium |
| **Setup Callbacks** | OAuth callback URLs | Low |

---

## 🔧 MCP Servers Required

```json
{
  "github": {
    "capabilities": ["gh api", "gh app", "gh auth", "gh secret"]
  },
  "bash": {
    "capabilities": ["curl", "jq", "openssl"]
  }
}
```

---

## 🛠️ Implementation

### 1. Create GitHub App for RHDH/Backstage

```bash
# GitHub App Manifest for RHDH
cat > github-app-manifest.json << 'EOF'
{
  "name": "${ORG_NAME}-developer-hub",
  "url": "https://developer-hub.${DOMAIN}",
  "hook_attributes": {
    "url": "https://developer-hub.${DOMAIN}/api/github/webhook",
    "active": true
  },
  "redirect_url": "https://developer-hub.${DOMAIN}/api/auth/github/handler/frame",
  "callback_urls": [
    "https://developer-hub.${DOMAIN}/api/auth/github/handler/frame"
  ],
  "setup_url": "https://developer-hub.${DOMAIN}/api/github/setup",
  "public": false,
  "default_permissions": {
    "contents": "read",
    "metadata": "read",
    "pull_requests": "write",
    "issues": "write",
    "workflows": "write",
    "actions": "read",
    "members": "read",
    "organization_administration": "read"
  },
  "default_events": [
    "push",
    "pull_request",
    "repository",
    "workflow_run"
  ]
}
EOF

# Create via GitHub API (manual step - requires org admin)
echo "To create GitHub App:"
echo "1. Go to: https://github.com/organizations/${GITHUB_ORG}/settings/apps/new"
echo "2. Use manifest: github-app-manifest.json"
echo "3. Save App ID and generate Private Key"
```

### 2. Create GitHub App via CLI (Enterprise)

```bash
# For GitHub Enterprise Server with API access
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /orgs/${GITHUB_ORG}/apps \
  -f name="${ORG_NAME}-developer-hub" \
  -f url="https://developer-hub.${DOMAIN}" \
  -f callback_url="https://developer-hub.${DOMAIN}/api/auth/github/handler/frame" \
  --jq '.id'
```

### 3. Create OAuth App for ArgoCD

```bash
# OAuth App for ArgoCD SSO
# Navigate to: https://github.com/organizations/${GITHUB_ORG}/settings/applications/new

ARGOCD_OAUTH_CONFIG=$(cat << EOF
{
  "application_name": "${ORG_NAME}-argocd",
  "homepage_url": "https://argocd.${DOMAIN}",
  "authorization_callback_url": "https://argocd.${DOMAIN}/api/dex/callback",
  "description": "ArgoCD GitOps - Single Sign-On"
}
EOF
)

echo "Create OAuth App with:"
echo "${ARGOCD_OAUTH_CONFIG}"

# After creation, store credentials
gh secret set ARGOCD_GITHUB_CLIENT_ID --body "${CLIENT_ID}" --repo ${GITHUB_ORG}/platform-gitops
gh secret set ARGOCD_GITHUB_CLIENT_SECRET --body "${CLIENT_SECRET}" --repo ${GITHUB_ORG}/platform-gitops
```

### 4. Generate and Store Private Key

```bash
# After GitHub App is created, generate private key
# Download from: https://github.com/organizations/${GITHUB_ORG}/settings/apps/${APP_SLUG}

# Convert PEM to base64 for Kubernetes secret
GITHUB_APP_PRIVATE_KEY_B64=$(cat github-app-private-key.pem | base64 -w 0)

# Store in Azure Key Vault
az keyvault secret set \
  --vault-name ${KV_NAME} \
  --name "github-app-private-key" \
  --value "${GITHUB_APP_PRIVATE_KEY_B64}"

# Store App ID
az keyvault secret set \
  --vault-name ${KV_NAME} \
  --name "github-app-id" \
  --value "${GITHUB_APP_ID}"

# Create Kubernetes secret for RHDH
kubectl create secret generic github-app-credentials \
  --namespace rhdh \
  --from-literal=GITHUB_APP_ID=${GITHUB_APP_ID} \
  --from-file=GITHUB_APP_PRIVATE_KEY=github-app-private-key.pem \
  --from-literal=GITHUB_APP_WEBHOOK_SECRET=${WEBHOOK_SECRET}
```

### 5. Configure Webhooks

```bash
# Create organization webhook for events
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /orgs/${GITHUB_ORG}/hooks \
  -f name='web' \
  -f config[url]="https://developer-hub.${DOMAIN}/api/github/webhook" \
  -f config[content_type]='json' \
  -f config[secret]="${WEBHOOK_SECRET}" \
  -F active=true \
  -f events[]='push' \
  -f events[]='pull_request' \
  -f events[]='repository' \
  -f events[]='workflow_run' \
  -f events[]='create' \
  -f events[]='delete'

# Create ArgoCD webhook
gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  /orgs/${GITHUB_ORG}/hooks \
  -f name='web' \
  -f config[url]="https://argocd.${DOMAIN}/api/webhook" \
  -f config[content_type]='json' \
  -f config[secret]="${ARGOCD_WEBHOOK_SECRET}" \
  -F active=true \
  -f events[]='push'
```

### 6. Install GitHub App on Organization

```bash
# Get installation URL
INSTALL_URL="https://github.com/apps/${APP_SLUG}/installations/new"
echo "Install app at: ${INSTALL_URL}"

# After installation, get installation ID
INSTALLATION_ID=$(gh api \
  -H "Accept: application/vnd.github+json" \
  /orgs/${GITHUB_ORG}/installations \
  --jq ".installations[] | select(.app_slug==\"${APP_SLUG}\") | .id")

# Store installation ID
az keyvault secret set \
  --vault-name ${KV_NAME} \
  --name "github-app-installation-id" \
  --value "${INSTALLATION_ID}"
```

---

## 📝 RHDH Configuration

```yaml
# platform/rhdh/values.yaml - GitHub App integration
integrations:
  github:
    - host: github.com
      apps:
        - appId: ${GITHUB_APP_ID}
          clientId: ${GITHUB_CLIENT_ID}
          clientSecret: ${GITHUB_CLIENT_SECRET}
          webhookSecret: ${GITHUB_WEBHOOK_SECRET}
          privateKey: |
            ${GITHUB_APP_PRIVATE_KEY}

auth:
  providers:
    github:
      development:
        clientId: ${GITHUB_OAUTH_CLIENT_ID}
        clientSecret: ${GITHUB_OAUTH_CLIENT_SECRET}
      production:
        clientId: ${GITHUB_OAUTH_CLIENT_ID}
        clientSecret: ${GITHUB_OAUTH_CLIENT_SECRET}

catalog:
  providers:
    github:
      providerId:
        organization: '${GITHUB_ORG}'
        catalogPath: '/catalog-info.yaml'
        filters:
          branch: 'main'
          repository: '.*'
        schedule:
          frequency: { minutes: 30 }
          timeout: { minutes: 3 }
```

---

## 📝 ArgoCD Configuration

```yaml
# argocd/argocd-cm.yaml - GitHub OAuth
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  url: https://argocd.${DOMAIN}
  dex.config: |
    connectors:
      - type: github
        id: github
        name: GitHub
        config:
          clientID: $GITHUB_OAUTH_CLIENT_ID
          clientSecret: $GITHUB_OAUTH_CLIENT_SECRET
          orgs:
            - name: ${GITHUB_ORG}
          loadAllGroups: true
          teamNameField: slug
          useLoginAsID: true
```

---

## 📊 Validation Checklist

```bash
#!/bin/bash
# validate-github-apps.sh

echo "=== GitHub Apps Validation ==="

# Check GitHub App exists
echo -n "GitHub App (RHDH): "
gh api /apps/${APP_SLUG} &>/dev/null && echo "✅" || echo "❌"

# Check OAuth App
echo -n "OAuth App (ArgoCD): "
# OAuth apps are listed differently
echo "⏳ (check manually)"

# Check webhooks
echo -n "Org Webhooks: "
WEBHOOK_COUNT=$(gh api /orgs/${GITHUB_ORG}/hooks --jq 'length')
[[ $WEBHOOK_COUNT -gt 0 ]] && echo "✅ (${WEBHOOK_COUNT} hooks)" || echo "❌"

# Check installation
echo -n "App Installation: "
gh api /orgs/${GITHUB_ORG}/installations --jq ".installations[] | select(.app_slug==\"${APP_SLUG}\") | .id" &>/dev/null && echo "✅" || echo "❌"

# Check Key Vault secrets
echo -n "Key Vault Secrets: "
az keyvault secret show --vault-name ${KV_NAME} --name "github-app-id" &>/dev/null && echo "✅" || echo "❌"

# Check Kubernetes secret
echo -n "K8s Secret (RHDH): "
kubectl get secret github-app-credentials -n rhdh &>/dev/null && echo "✅" || echo "❌"
```

---

## 🔒 Security Best Practices

1. **Private Keys**: Store only in Key Vault, never in git
2. **Webhook Secrets**: Use strong random values
3. **Minimum Permissions**: Request only needed scopes
4. **IP Allowlisting**: Restrict webhook sources (Enterprise)
5. **Token Rotation**: Rotate OAuth secrets periodically
6. **Audit Logging**: Enable GitHub audit log streaming

---

## 🔗 Dependencies

| Agent | Purpose |
|-------|---------|
| `identity-federation-agent` | Azure ↔ GitHub OIDC |
| `rhdh-portal-agent` | Consumes GitHub App |
| `gitops-agent` | Consumes OAuth App |
| `security-agent` | Key Vault storage |
