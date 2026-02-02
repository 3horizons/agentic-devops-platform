---
name: identity-federation-agent
version: 1.0.0
horizon: Cross-Cutting
task: Configure workload identity federation
skills:
  - azure-infrastructure
  - github-cli
  - terraform-cli
  - validation-scripts
triggers:
  - "setup identity federation"
  - "configure workload identity"
  - "setup oidc"
---

# Identity Federation Agent

## Task
Configure workload identity federation for secure CI/CD.

## Skills Reference
- **[azure-infrastructure](../../skills/azure-infrastructure/)** - Identity management
- **[github-cli](../../skills/github-cli/)** - GitHub OIDC config
- **[terraform-cli](../../skills/terraform-cli/)** - Infrastructure as code
- **[validation-scripts](../../skills/validation-scripts/)** - Federation validation

## Workflow

```mermaid
graph LR
    A[Start] --> B[Create App Registration]
    B --> C[Add Federated Credential]
    C --> D[Assign RBAC Roles]
    D --> E[Configure GitHub]
    E --> F[Validate Federation]
```

## Commands

### Setup Script
```bash
./scripts/setup-identity-federation.sh \
  --app-name "github-actions-${REPO}" \
  --github-org ${ORG} \
  --github-repo ${REPO} \
  --subscription-id ${SUB_ID}
```

### Manual Setup
```bash
# Create app registration
az ad app create --display-name "github-actions-${REPO}"
APP_ID=$(az ad app list --display-name "github-actions-${REPO}" --query [0].appId -o tsv)

# Create federated credential
az ad app federated-credential create \
  --id ${APP_ID} \
  --parameters @federated-credential.json
```

### GitHub Workflow Usage
```yaml
jobs:
  deploy:
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| app_name | Yes | - | App registration name |
| github_org | Yes | - | GitHub organization |
| github_repo | Yes | - | GitHub repository |
| environments | No | [main] | Branch/environment list |

## Dependencies
- Azure AD permissions to create app registrations

## Triggers Next
- CI/CD pipelines use federated credentials
