# Backstage Deployment Skill

Deploys the upstream open-source Backstage developer portal on Azure AKS or locally via Docker Desktop.

---

## Scope

| Aspect | Detail |
|--------|--------|
| **Platform** | Azure AKS (production) or Docker Desktop + kind (local) |
| **Region** | Central US (`centralus`) or East US (`eastus`) only |
| **Image** | Custom-built from `backstage/` directory |
| **Auth** | GitHub OAuth + Guest (dev only) |
| **Catalog** | H1 Foundation + H2 Enhancement Golden Paths pre-loaded |
| **Used by** | `@backstage-expert`, `@deploy`, `@platform` |

---

## 1. Prerequisites

### CLI Tools
```bash
# Required
az --version        # >= 2.55
terraform --version # >= 1.5
kubectl version     # >= 1.28
helm version        # >= 3.13
docker --version    # >= 24.0
node --version      # >= 20.0
yarn --version      # >= 4.0
gh auth status      # GitHub CLI authenticated
```

### Azure
```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.Storage
```

---

## 2. Local Deployment (Docker Desktop)

### Quick Start
```bash
# Set portal type
export PORTAL_TYPE="backstage"

# Deploy full platform on kind
make -C local up

# Access portal
make -C local portal   # http://localhost:7007
```

### Custom Image Build
```bash
cd backstage

# Install dependencies
yarn install

# Build backend
yarn tsc && yarn build:backend

# Build Docker image
docker build -t <portal-name>-portal:local -f packages/backend/Dockerfile .

# Load into kind
kind load docker-image <portal-name>-portal:local --name three-horizons-demo
```

### Configuration Files
| File | Purpose |
|------|---------|
| `backstage/app-config.yaml` | Development config |
| `backstage/app-config.production.yaml` | Production config (baked into image) |
| `local/values/backstage-local.yaml` | Helm values for local deployment |
| `local/config/local.env` | Environment variables |

### Key Helm Values (`local/values/backstage-local.yaml`)
```yaml
backstage:
  image:
    repository: <portal-name>-portal
    tag: local
    pullPolicy: Never
  command: ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
  extraEnvVars:
    - name: POSTGRES_HOST
      value: "postgresql.databases.svc.cluster.local"
    - name: GITHUB_APP_CLIENT_ID
      valueFrom:
        secretKeyRef:
          name: backstage-github-app
          key: client-id
```

---

## 3. Azure AKS Deployment

### Terraform
```bash
cd terraform

# Initialize
terraform init -backend-config=environments/dev-backend.hcl

# Plan
terraform plan \
  -var-file=environments/dev.tfvars \
  -var="portal_name=<client-portal-name>" \
  -var="location=centralus"

# Apply
terraform apply \
  -var-file=environments/dev.tfvars \
  -var="portal_name=<client-portal-name>" \
  -var="location=centralus"
```

### Module: `terraform/modules/backstage/`
Provisions:
- Helm release for `backstage/backstage` chart
- Custom image from ACR
- PostgreSQL Flexible Server integration
- GitHub App secret in Key Vault
- Ingress with TLS (cert-manager)

### Region Validation
```hcl
variable "location" {
  type    = string
  validation {
    condition     = contains(["centralus", "eastus"], var.location)
    error_message = "Only Central US and East US are supported."
  }
}
```

---

## 4. GitHub App Setup

### Create GitHub App
```bash
./scripts/setup-github-app.sh --target rhdh --org <GITHUB_ORG>
```

### Manual Creation
1. Go to `https://github.com/organizations/<ORG>/settings/apps/new`
2. Set:
   - **Homepage URL:** `https://<portal-url>`
   - **Callback URL:** `https://<portal-url>/api/auth/github/handler/frame`
   - **Webhook:** Disable (not needed for auth)
3. Permissions:
   - `contents: read`
   - `metadata: read`
   - `pull_requests: write`
   - `members: read`
4. Generate Private Key (.pem file)
5. Note: App ID, Client ID, Client Secret

### Configure in Backstage
Environment variables:
```
GITHUB_APP_ID=<numeric-app-id>
GITHUB_APP_CLIENT_ID=<client-id>
GITHUB_APP_CLIENT_SECRET=<client-secret>
GITHUB_APP_PRIVATE_KEY=<contents-of-pem-file>
```

---

## 5. Golden Path Templates

### Valid Templates (YAML-compatible with Backstage parser)
| Template | Horizon | Description |
|----------|---------|-------------|
| `api-microservice` | H2 | FastAPI microservice with PostgreSQL |
| `ado-to-github-migration` | H2 | Azure DevOps to GitHub migration |
| `copilot-extension` | H3 | GitHub Copilot Extension |
| `rag-application` | H3 | RAG application with Azure AI |

### Registration
Templates are registered via `catalog.locations` in `app-config.production.yaml`:
```yaml
catalog:
  locations:
    - type: url
      target: https://github.com/<org>/<repo>/blob/main/golden-paths/<horizon>/<template>/template.yaml
      rules:
        - allow: [Template]
```

---

## 6. Codespaces Integration

Each Golden Path template skeleton includes a `.devcontainer/devcontainer.json` that configures:
- Base image with required SDKs
- VS Code extensions for the template type
- Port forwarding for development servers
- Post-create setup scripts

### Example: Python Microservice
```json
{
  "name": "Python Microservice",
  "image": "mcr.microsoft.com/devcontainers/python:3.11",
  "features": {
    "ghcr.io/devcontainers/features/azure-cli:1": {},
    "ghcr.io/devcontainers/features/kubectl-helm-minikube:1": {}
  },
  "customizations": {
    "vscode": {
      "extensions": ["ms-python.python", "ms-python.pylint", "redhat.vscode-yaml"]
    }
  },
  "postCreateCommand": "pip install -r requirements.txt",
  "forwardPorts": [8000]
}
```

---

## 7. Troubleshooting

### Backstage pod not starting
```bash
kubectl logs -n rhdh -l app.kubernetes.io/name=backstage --tail=50
kubectl describe pod -n rhdh -l app.kubernetes.io/name=backstage
```

### Templates not loading
```bash
# Check for YAML parse errors
kubectl logs -n rhdh -l app.kubernetes.io/name=backstage | grep 'YAML error'

# Verify catalog locations
kubectl exec -n rhdh deploy/backstage -- cat /app/app-config.production.yaml | grep -A 2 'locations'
```

### GitHub auth not working
```bash
# Test auth endpoint
kubectl exec -n rhdh deploy/backstage -- \
  node -e "fetch('http://localhost:7007/api/auth/github/start?env=development',{redirect:'manual'}).then(r=>console.log(r.status))"
# Expected: 302
```

### Database connection
```bash
kubectl exec -n rhdh deploy/backstage -- \
  node -e "fetch('http://localhost:7007/.backstage/health/v1/readiness').then(r=>console.log(r.status))"
# Expected: 200
```
