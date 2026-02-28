# Three Horizons — Red Hat Developer Hub Custom Homepage Deployment

This directory contains the deployment configuration and data files for the Three Horizons RHDH custom homepage with GitHub-only authentication and AI capabilities.

## Overview

The Three Horizons homepage provides an enterprise-grade landing page for RHDH with:
- **GitHub OAuth authentication** (only auth provider)
- **Lightspeed AI Assistant** integration for developer support
- **MCP (Model Context Protocol) servers** for enhanced AI capabilities
- **Quick access links** to catalog and templates
- **AI & Developer Tools** section
- **Featured templates** for rapid service creation
- **Catalog statistics** and insights
- **RBAC (Role-Based Access Control)** policies
- **Dynamic plugin** configuration system

## Files Included

| File | Purpose |
|------|---------|
| `app-config.homepage.yaml` | Main RHDH configuration with auth, catalog, plugins, and AI settings |
| `homepage-data.json` | Dynamic homepage content via ConfigMap |
| `README.md` | This file |

## Prerequisites

- Red Hat Developer Hub 1.0+ (or Backstage 1.15+)
- Kubernetes cluster for RHDH deployment
- Helm 3+
- GitHub OAuth application credentials
- Optional: Lightspeed AI service for developer assistance

## GitHub OAuth Setup

### Step 1: Create GitHub OAuth Application

1. Navigate to https://github.com/settings/developers
2. Click **New OAuth App**
3. Configure the application:
   - **Application Name:** `Three Horizons`
   - **Homepage URL:** `https://your-rhdh-domain.com`
   - **Authorization callback URL:** `https://your-rhdh-domain.com/auth/github/handler/frame`
4. Click **Register application**
5. Copy the **Client ID** and generate a **Client Secret**

### Step 2: GitHub Organization Setup

Ensure your GitHub organization is properly configured:

```bash
# Set organization name
export GITHUB_ORG="your-organization"
export ALLOWED_GITHUB_ORGS="your-organization,partner-org"
```

## Installation

### 1. Prepare Kubernetes Namespace

```bash
# Create the RHDH namespace
kubectl create namespace rhdh

# Create the namespace if using different name
kubectl create namespace ${RHDH_NAMESPACE:-rhdh}
```

### 2. Create Secrets

Create a Kubernetes secret with GitHub OAuth credentials:

```bash
kubectl create secret generic rhdh-github-secrets \
  --from-literal=clientId="${GITHUB_CLIENT_ID}" \
  --from-literal=clientSecret="${GITHUB_CLIENT_SECRET}" \
  --from-literal=backendSecret="$(openssl rand -base64 32)" \
  -n rhdh

# Optional: Lightspeed AI credentials
kubectl create secret generic rhdh-lightspeed-secrets \
  --from-literal=authToken="${LIGHTSPEED_AUTH_TOKEN}" \
  -n rhdh
```

### 3. Create ConfigMap with Homepage Data

```bash
kubectl create configmap rhdh-homepage-data \
  --from-file=homepage-data.json=homepage-data.json \
  -n rhdh
```

### 4. Create ConfigMap with App Configuration

```bash
kubectl create configmap rhdh-app-config \
  --from-file=app-config.yaml=app-config.homepage.yaml \
  -n rhdh
```

## Helm Deployment

### 1. Add RHDH Helm Repository

```bash
helm repo add rhdh https://redhat-developer.github.io/rhdh-helm-chart
helm repo update
```

### 2. Create Helm Values File

Create `values.yaml`:

```yaml
# values.yaml
# RHDH Helm Values for Three Horizons Homepage Deployment

namespace: rhdh
replicaCount: 2

image:
  repository: quay.io/rhdh/rhdh
  tag: latest
  pullPolicy: IfNotPresent

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: your-rhdh-domain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: rhdh-tls
      hosts:
        - your-rhdh-domain.com

postgresql:
  enabled: true
  auth:
    username: rhdh
    password: ${DB_PASSWORD}
    database: rhdh

environment:
  BACKSTAGE_BASE_URL: "https://your-rhdh-domain.com"
  RHDH_BASE_URL: "https://your-rhdh-domain.com"
  GITHUB_ORG: "${GITHUB_ORG}"
  GITHUB_URL: "https://github.com"
  GITHUB_HOST: "github.com"
  ALLOWED_GITHUB_ORGS: "${ALLOWED_GITHUB_ORGS}"
  RHDH_NAMESPACE: "rhdh"
  ADMIN_USER: "admin@your-org.com"
  LOG_LEVEL: "info"

secrets:
  github:
    clientId: rhdh-github-secrets
    clientSecret: rhdh-github-secrets
    backendSecret: rhdh-github-secrets
  lightspeed:
    authToken: rhdh-lightspeed-secrets
    baseUrl: "https://lightspeed.ai.redhat.com"

configMaps:
  appConfig: rhdh-app-config
  homepageData: rhdh-homepage-data

rbac:
  enabled: true
  adminUsers:
    - admin@your-org.com
  rules:
    - role: default
      permission: policy/read
      action: read
      effect: allow

resources:
  requests:
    memory: "512Mi"
    cpu: "250m"
  limits:
    memory: "1Gi"
    cpu: "500m"

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
```

### 3. Deploy RHDH with Helm

```bash
# Install the Helm chart
helm install rhdh rhdh/rhdh \
  --namespace rhdh \
  --values values.yaml \
  --set secrets.github.clientId="$(kubectl get secret rhdh-github-secrets -n rhdh -o jsonpath='{.data.clientId}' | base64 -d)" \
  --set secrets.github.clientSecret="$(kubectl get secret rhdh-github-secrets -n rhdh -o jsonpath='{.data.clientSecret}' | base64 -d)"

# Verify deployment
kubectl get deployments -n rhdh
kubectl get pods -n rhdh
kubectl logs -n rhdh -l app=rhdh --tail=50 -f
```

### 4. Configure Ingress (TLS Certificate)

If using cert-manager:

```bash
# Install cert-manager (if not already installed)
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Create ClusterIssuer for Let's Encrypt
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: admin@your-org.com
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF
```

## Configuration Details

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `GITHUB_CLIENT_ID` | Yes | - | GitHub OAuth app Client ID |
| `GITHUB_CLIENT_SECRET` | Yes | - | GitHub OAuth app Client Secret |
| `GITHUB_ORG` | Yes | - | Primary GitHub organization |
| `ALLOWED_GITHUB_ORGS` | No | `${GITHUB_ORG}` | Comma-separated list of allowed orgs |
| `RHDH_BASE_URL` | Yes | - | Base URL of RHDH instance |
| `RHDH_NAMESPACE` | No | `rhdh` | Kubernetes namespace |
| `LIGHTSPEED_BASE_URL` | No | - | URL for Lightspeed AI service |
| `LIGHTSPEED_AUTH_TOKEN` | No | - | Authentication token for Lightspeed |
| `ADMIN_USER` | No | `admin` | Administrator user email |

### Homepage Data Configuration

The `homepage-data.json` file defines the homepage structure:

```json
{
  "hero": { ... },
  "sections": [
    {
      "id": "quick-access",
      "links": [ ... ]
    },
    {
      "id": "ai-tools",
      "links": [ ... ]
    },
    {
      "id": "featured-templates",
      "templates": [ ... ]
    }
  ]
}
```

To update homepage content:

```bash
# Edit the JSON file
nano homepage-data.json

# Update the ConfigMap
kubectl create configmap rhdh-homepage-data \
  --from-file=homepage-data.json=homepage-data.json \
  -n rhdh \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart pods to pick up changes
kubectl rollout restart deployment/rhdh -n rhdh
```

### Lightspeed AI Integration

To enable Lightspeed AI Assistant:

1. Create a Lightspeed service account or obtain credentials
2. Create the secret:
   ```bash
   kubectl create secret generic rhdh-lightspeed-secrets \
     --from-literal=authToken="${LIGHTSPEED_AUTH_TOKEN}" \
     -n rhdh
   ```
3. Set environment variables in Helm values
4. Lightspeed will appear in the AI & Developer Tools section

### RBAC Configuration

Default RBAC rules are configured in `app-config.homepage.yaml`:

```yaml
permission:
  enabled: true
  rbac:
    admin:
      users:
        - name: admin@your-org.com
    rules:
      - entityRef: role:default/guest
        permission: policy/read
        action: read
        effect: allow
```

Add additional rules as needed for your organization.

## Verification

### Check Deployment Status

```bash
# Check pod status
kubectl get pods -n rhdh

# Check services
kubectl get svc -n rhdh

# Check ingress
kubectl get ingress -n rhdh

# Check logs
kubectl logs -n rhdh -l app=rhdh --tail=100
```

### Access the Homepage

1. Navigate to `https://your-rhdh-domain.com`
2. Click "Sign in with GitHub"
3. Authorize the OAuth application
4. You should see the Three Horizons homepage

### Verify GitHub Integration

1. Go to the Software Catalog
2. Verify components from GitHub are listed
3. Check that recent components appear on homepage

### Test Lightspeed AI (if enabled)

1. Navigate to the Lightspeed section
2. Test code generation and analysis features
3. Check that MCP servers are available

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status and events
kubectl describe pod <pod-name> -n rhdh

# Check logs
kubectl logs <pod-name> -n rhdh
```

### GitHub Authentication Failing

- Verify `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` are correct
- Check callback URL in GitHub OAuth settings matches exactly
- Ensure GitHub user is in the organization

### Homepage Data Not Updating

```bash
# Verify ConfigMap exists
kubectl get configmap rhdh-homepage-data -n rhdh

# Check ConfigMap content
kubectl get configmap rhdh-homepage-data -n rhdh -o yaml

# Restart deployment to pick up changes
kubectl rollout restart deployment/rhdh -n rhdh
```

### Database Connection Issues

```bash
# Check PostgreSQL pod
kubectl get pods -n rhdh -l app=postgresql

# Check database logs
kubectl logs -n rhdh -l app=postgresql --tail=50
```

## Scaling & Performance

### Horizontal Pod Autoscaling

The Helm values include autoscaling configuration:

```yaml
autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 5
  targetCPUUtilizationPercentage: 80
```

Monitor scaling:

```bash
kubectl get hpa -n rhdh -w
```

### Resource Limits

Adjust resource requests/limits in `values.yaml` based on workload:

```yaml
resources:
  requests:
    memory: "1Gi"
    cpu: "500m"
  limits:
    memory: "2Gi"
    cpu: "1000m"
```

## Security Best Practices

- Use strong backend secrets
- Enable HTTPS with valid certificates
- Restrict GitHub organizations
- Configure RBAC policies
- Regularly update RHDH and dependencies
- Monitor logs for suspicious activity
- Use separate credentials for dev/staging/prod

## Maintenance

### Backup Configuration

```bash
# Backup Secrets
kubectl get secret rhdh-github-secrets -n rhdh -o yaml > backup-secrets.yaml

# Backup ConfigMaps
kubectl get configmap rhdh-app-config rhdh-homepage-data -n rhdh -o yaml > backup-configmaps.yaml

# Backup Database
kubectl exec -n rhdh <postgresql-pod> -- pg_dump -U rhdh rhdh > backup-db.sql
```

### Update RHDH

```bash
# Update Helm repository
helm repo update rhdh

# Update deployment
helm upgrade rhdh rhdh/rhdh \
  --namespace rhdh \
  --values values.yaml
```

## Support & Documentation

- [Red Hat Developer Hub Documentation](https://access.redhat.com/documentation/en-us/red_hat_developer_hub)
- [Backstage Documentation](https://backstage.io/docs)
- [GitHub OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [Kubernetes Documentation](https://kubernetes.io/docs)

## License

Three Horizons is licensed under the Apache License 2.0. See LICENSE file for details.
