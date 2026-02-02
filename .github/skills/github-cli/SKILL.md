---
name: github-cli
description: 'GitHub CLI (gh) reference for repository and workflow management. Use when asked to create repos, configure Actions workflows, manage PRs, issues, secrets, GitHub Apps.'
license: Complete terms in LICENSE.txt
---

# GitHub CLI Skill

> **Domain:** GitHub Operations & Automation  
> **Category:** CLI Operations  
> **Version:** 2.30+

## Overview

This skill provides comprehensive GitHub CLI (`gh`) reference for managing repositories, issues, pull requests, workflows, and GitHub Apps. Use this for automating GitHub operations in the Three Horizons platform.

---

## USE FOR

- When user asks to run `gh` commands
- Create or configure GitHub repositories
- Manage GitHub Actions workflows
- Create or update GitHub Apps
- Set up branch protection rules
- Configure repository secrets and variables
- Manage GitHub Issues and Pull Requests
- Automate repository settings
- Set up OIDC federation for Azure

## DO NOT USE FOR

- Git operations (use git commands directly)
- Azure resource provisioning (use azure-cli skill)
- Kubernetes deployments (use kubectl-cli skill)
- ArgoCD GitOps sync (use argocd-cli skill)
- Direct API calls without gh CLI (use MCP servers)

---

## Installation & Authentication

```bash
# Install GitHub CLI
brew install gh      # macOS
apt install gh       # Ubuntu/Debian
winget install gh    # Windows

# Authenticate
gh auth login

# Check authentication status
gh auth status

# Set default Git protocol
gh config set git_protocol ssh
```

---

## Repository Management

### Create & Configure Repositories

```bash
# Create new repository
gh repo create my-org/my-repo \
  --public \
  --description "Platform infrastructure" \
  --gitignore Terraform \
  --license MIT

# Create from template
gh repo create my-org/my-repo \
  --template my-org/template-repo \
  --private

# Clone repository
gh repo clone my-org/my-repo

# Fork repository
gh repo fork upstream-org/repo --clone

# View repository info
gh repo view my-org/my-repo

# List organization repositories
gh repo list my-org --limit 100
```

### Repository Settings

```bash
# Enable/disable features
gh repo edit my-org/my-repo \
  --enable-issues=true \
  --enable-wiki=false \
  --enable-projects=true

# Set default branch
gh repo edit my-org/my-repo --default-branch main

# Update visibility
gh repo edit my-org/my-repo --visibility private

# Add topics
gh repo edit my-org/my-repo \
  --add-topic terraform \
  --add-topic kubernetes \
  --add-topic azure
```

### Branch Protection

```bash
# Protect main branch with required reviews
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["ci/terraform-validate","ci/security-scan"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":2,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}' \
  --field restrictions=null

# Simpler protection (basic)
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --input branch-protection.json

# Example branch-protection.json
cat <<EOF > branch-protection.json
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["ci/terraform-validate"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 2,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "restrictions": null,
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false
}
EOF
```

---

## Secrets & Variables

### Repository Secrets

```bash
# Set repository secret
gh secret set AZURE_CLIENT_ID \
  --repo my-org/my-repo \
  --body "00000000-0000-0000-0000-000000000000"

# Set from file
cat azure-credentials.json | gh secret set AZURE_CREDENTIALS \
  --repo my-org/my-repo

# List secrets
gh secret list --repo my-org/my-repo

# Delete secret
gh secret delete SECRET_NAME --repo my-org/my-repo
```

### Organization Secrets

```bash
# Set organization secret (all repos)
gh secret set AZURE_TENANT_ID \
  --org my-org \
  --visibility all \
  --body "00000000-0000-0000-0000-000000000000"

# Set for selected repositories
gh secret set AZURE_SUBSCRIPTION_ID \
  --org my-org \
  --visibility selected \
  --repos my-org/repo1,my-org/repo2 \
  --body "00000000-0000-0000-0000-000000000000"

# List organization secrets
gh secret list --org my-org
```

### Variables (Non-Sensitive Config)

```bash
# Set repository variable
gh variable set ENVIRONMENT --repo my-org/my-repo --body "production"
gh variable set AZURE_REGION --repo my-org/my-repo --body "eastus"

# List variables
gh variable list --repo my-org/my-repo

# Delete variable
gh variable delete VARIABLE_NAME --repo my-org/my-repo
```

---

## GitHub Actions Workflows

### Workflow Management

```bash
# List workflows
gh workflow list --repo my-org/my-repo

# View workflow runs
gh run list --repo my-org/my-repo --limit 10

# View specific run
gh run view 123456789 --repo my-org/my-repo

# Watch run (live logs)
gh run watch 123456789 --repo my-org/my-repo

# Download artifacts
gh run download 123456789 --repo my-org/my-repo

# Re-run failed jobs
gh run rerun 123456789 --repo my-org/my-repo --failed

# Cancel run
gh run cancel 123456789 --repo my-org/my-repo
```

### Trigger Workflows

```bash
# Trigger workflow_dispatch event
gh workflow run deploy.yml \
  --repo my-org/my-repo \
  --ref main \
  -f environment=production \
  -f dry_run=false

# List workflow runs for specific workflow
gh run list --workflow deploy.yml --repo my-org/my-repo
```

---

## GitHub Apps

### Create & Configure GitHub App

```bash
# Create GitHub App (interactive)
gh api /orgs/:org/apps \
  --method POST \
  --input github-app-config.json

# Example github-app-config.json
cat <<EOF > github-app-config.json
{
  "name": "Three Horizons Platform",
  "url": "https://github.com/my-org/platform",
  "hook_attributes": {
    "url": "https://platform.example.com/webhooks",
    "active": true
  },
  "public": false,
  "default_permissions": {
    "contents": "read",
    "metadata": "read",
    "pull_requests": "write",
    "issues": "write"
  },
  "default_events": [
    "push",
    "pull_request",
    "issues"
  ]
}
EOF

# List organization GitHub Apps
gh api /orgs/:org/installations

# Get App details
gh api /app
```

### GitHub App Permissions

**Common Permission Scopes:**

```json
{
  "contents": "write",           // Read/write repository contents
  "metadata": "read",            // Read repository metadata (always required)
  "pull_requests": "write",      // Create/update PRs
  "issues": "write",             // Create/update issues
  "statuses": "write",           // Set commit statuses
  "checks": "write",             // Create check runs
  "actions": "write",            // Manage GitHub Actions
  "secrets": "write",            // Manage secrets
  "workflows": "write",          // Edit workflows
  "administration": "write",     // Repo admin (branch protection, etc.)
  "members": "read",             // Read org members
  "organization_administration": "write"  // Org settings
}
```

---

## Issues & Pull Requests

### Issues

```bash
# Create issue
gh issue create \
  --repo my-org/my-repo \
  --title "Deploy H1 Foundation" \
  --body "Infrastructure deployment for AKS cluster" \
  --label deployment \
  --assignee @me

# List issues
gh issue list --repo my-org/my-repo --state open

# View issue
gh issue view 123 --repo my-org/my-repo

# Close issue
gh issue close 123 --repo my-org/my-repo --comment "Deployment completed"

# Add comment
gh issue comment 123 --repo my-org/my-repo --body "Terraform apply successful"
```

### Pull Requests

```bash
# Create PR
gh pr create \
  --repo my-org/my-repo \
  --base main \
  --head feature-branch \
  --title "Add AKS cluster module" \
  --body "Implements AKS cluster with Workload Identity"

# List PRs
gh pr list --repo my-org/my-repo

# Review PR
gh pr review 456 --repo my-org/my-repo --approve
gh pr review 456 --repo my-org/my-repo --request-changes --body "Missing tests"

# Merge PR
gh pr merge 456 --repo my-org/my-repo --squash --delete-branch

# Check PR status
gh pr status --repo my-org/my-repo

# View PR diff
gh pr diff 456 --repo my-org/my-repo
```

---

## OIDC Federation for Azure

### Set up Federated Credentials

```bash
# Add OIDC subject claim for GitHub Actions
# (This creates federated credential in Azure Entra ID)

# 1. Get GitHub OIDC issuer
echo "https://token.actions.githubusercontent.com"

# 2. Set subject claim for main branch
SUBJECT="repo:my-org/my-repo:ref:refs/heads/main"

# 3. Configure in Azure (via Azure CLI)
az ad app federated-credential create \
  --id $(az ad app show --id $APP_ID --query id -o tsv) \
  --parameters '{
    "name": "github-actions-main",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:my-org/my-repo:ref:refs/heads/main",
    "description": "GitHub Actions - main branch",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# 4. Set GitHub repository secrets
gh secret set AZURE_CLIENT_ID --repo my-org/my-repo --body "$APP_ID"
gh secret set AZURE_TENANT_ID --repo my-org/my-repo --body "$TENANT_ID"
gh secret set AZURE_SUBSCRIPTION_ID --repo my-org/my-repo --body "$SUBSCRIPTION_ID"
```

### Subject Claim Patterns

```bash
# Main branch
repo:my-org/my-repo:ref:refs/heads/main

# Pull requests
repo:my-org/my-repo:pull_request

# Specific environment
repo:my-org/my-repo:environment:production

# Any branch
repo:my-org/my-repo:ref:refs/heads/*

# Tags
repo:my-org/my-repo:ref:refs/tags/v*
```

---

## Advanced Operations

### Repository Rulesets (New Branch Protection)

```bash
# Create ruleset
gh api repos/:owner/:repo/rulesets \
  --method POST \
  --input ruleset.json

# Example ruleset.json
cat <<EOF > ruleset.json
{
  "name": "Main branch protection",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "include": ["refs/heads/main"],
      "exclude": []
    }
  },
  "rules": [
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 2,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": true,
        "require_last_push_approval": false
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "required_status_checks": [
          {"context": "ci/terraform-validate"},
          {"context": "ci/security-scan"}
        ],
        "strict_required_status_checks_policy": true
      }
    }
  ]
}
EOF

# List rulesets
gh api repos/:owner/:repo/rulesets
```

### Webhooks

```bash
# Create webhook
gh api repos/:owner/:repo/hooks \
  --method POST \
  --field name=web \
  --field config[url]='https://platform.example.com/webhooks' \
  --field config[content_type]=json \
  --field config[secret]='your-webhook-secret' \
  --field events[]='push' \
  --field events[]='pull_request' \
  --field active=true

# List webhooks
gh api repos/:owner/:repo/hooks

# Test webhook
gh api repos/:owner/:repo/hooks/:hook_id/tests --method POST
```

### Deploy Keys (Read-Only Access)

```bash
# Add deploy key
gh api repos/:owner/:repo/keys \
  --method POST \
  --field title="ArgoCD Deploy Key" \
  --field key="$(cat ~/.ssh/argocd_deploy.pub)" \
  --field read_only=true

# List deploy keys
gh api repos/:owner/:repo/keys
```

---

## Best Practices

### 1. Use GitHub Apps Instead of PATs

```bash
# ✅ Good - GitHub App with scoped permissions
# Create GitHub App with minimal permissions

# ❌ Bad - Personal Access Token with full access
# PATs have broader scope and security risks
```

### 2. OIDC Over Static Credentials

```bash
# ✅ Good - OIDC federation (no stored secrets)
# Configure federated credentials in Azure

# ❌ Bad - Service Principal credentials in secrets
gh secret set AZURE_CREDENTIALS --repo my-org/my-repo
```

### 3. Organization-Level Secrets

```bash
# ✅ Good - Single source for shared secrets
gh secret set AZURE_TENANT_ID --org my-org --visibility all

# ❌ Bad - Duplicate secrets across repos
gh secret set AZURE_TENANT_ID --repo my-org/repo1
gh secret set AZURE_TENANT_ID --repo my-org/repo2
```

### 4. Use Variables for Non-Sensitive Data

```bash
# ✅ Good - Variables for configuration
gh variable set ENVIRONMENT --repo my-org/my-repo --body "production"

# ❌ Bad - Secrets for non-sensitive data
gh secret set ENVIRONMENT --repo my-org/my-repo
```

---

## Integration with Three Horizons Platform

### Initial Repository Setup

```bash
#!/bin/bash
# Script: setup-platform-repo.sh

ORG="my-org"
REPO="three-horizons-platform"

# 1. Create repository
gh repo create $ORG/$REPO \
  --private \
  --description "Three Horizons Accelerator Platform" \
  --gitignore Terraform \
  --license Apache-2.0

# 2. Set repository variables
gh variable set AZURE_REGION --repo $ORG/$REPO --body "eastus"
gh variable set ENVIRONMENT --repo $ORG/$REPO --body "production"

# 3. Set organization secrets (OIDC)
gh secret set AZURE_CLIENT_ID --org $ORG --visibility all --body "$AZURE_CLIENT_ID"
gh secret set AZURE_TENANT_ID --org $ORG --visibility all --body "$AZURE_TENANT_ID"
gh secret set AZURE_SUBSCRIPTION_ID --org $ORG --visibility all --body "$AZURE_SUBSCRIPTION_ID"

# 4. Enable features
gh repo edit $ORG/$REPO \
  --enable-issues=true \
  --enable-projects=true \
  --enable-wiki=false

# 5. Add topics
gh repo edit $ORG/$REPO \
  --add-topic terraform \
  --add-topic kubernetes \
  --add-topic azure \
  --add-topic platform-engineering

echo "✅ Repository setup complete"
```

### Deploy Key for ArgoCD

```bash
# Generate SSH key for ArgoCD
ssh-keygen -t ed25519 -C "argocd@three-horizons" -f ~/.ssh/argocd_deploy -N ""

# Add deploy key to repository
gh api repos/$ORG/$REPO/keys \
  --method POST \
  --field title="ArgoCD Deploy Key" \
  --field key="$(cat ~/.ssh/argocd_deploy.pub)" \
  --field read_only=true

# Store private key as Kubernetes secret
kubectl create secret generic argocd-repo-creds \
  -n argocd \
  --from-file=sshPrivateKey=$HOME/.ssh/argocd_deploy
```

---

## Troubleshooting

### Authentication Issues

```bash
# Re-authenticate
gh auth login --web

# Check token scopes
gh auth status

# Use token directly
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
```

### API Rate Limits

```bash
# Check rate limit
gh api rate_limit

# Use authenticated requests (higher limits)
gh auth login
```

### Permission Denied

```bash
# Check repository access
gh api repos/:owner/:repo

# Verify organization membership
gh api orgs/:org/members/:username

# Check GitHub App permissions
gh api /app
```

---

## References

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub REST API](https://docs.github.com/en/rest)
- [GitHub Actions OIDC](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [GitHub Apps Documentation](https://docs.github.com/en/apps)

---

**Skill Version:** 1.0.0  
**Last Updated:** 2026-02-02
