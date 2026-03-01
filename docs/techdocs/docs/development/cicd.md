# CI/CD Pipelines

All CI/CD pipelines on the Three Horizons platform are powered by **GitHub Actions** for continuous integration and **ArgoCD** for continuous deployment via GitOps. Self-hosted runners on AKS are available for workloads that require private network access.

---

## GitHub Actions Workflows

The platform provides 10 reusable workflows in `.github/workflows/`:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci-cd.yml` | Push/PR to main | Full pipeline: lint, test, build, deploy |
| `ci.yml` | Push/PR | Lint, test, validate |
| `cd.yml` | Merge to main | Deploy to staging, then production |
| `terraform-test.yml` | Changes in `terraform/` | Terratest validation |
| `validate-agents.yml` | Changes in `agents/` | Agent specification validation |
| `release.yml` | Tag creation | Release automation with changelog |
| `agent-router.yml` | Issue creation | Route issues to Copilot agents |
| `issue-ops.yml` | Issue events | Issue lifecycle automation |
| `branch-protection.yml` | Scheduled | Enforce branch protection rules |
| `engineering-intelligence.yml` | Scheduled (6h) + manual | Collect DORA and Copilot metrics |

### Workflow Structure

Each workflow follows a consistent structure with reusable job definitions:

```yaml
name: CI Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

permissions:
  id-token: write        # OIDC for Azure Workload Identity
  contents: read
  security-events: write # GHAS code scanning upload

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run linters
        run: |
          pre-commit run --all-files

  test:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          go test -v ./...

  security-scan:
    needs: lint
    runs-on: ubuntu-latest
    steps:
      - uses: github/codeql-action/init@v3
      - uses: github/codeql-action/analyze@v3

  build:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    steps:
      - name: Build and push image
        run: |
          az acr build --registry $ACR_NAME --image $IMAGE:$TAG .
```

---

## Branch Strategy

The repository follows a trunk-based development model with short-lived feature branches:

- **`main`** -- Protected branch, requires PR with at least one approval
- **`feature/*`** -- New features and enhancements
- **`bugfix/*`** -- Bug fixes
- **`hotfix/*`** -- Urgent production fixes (expedited review)
- **`release/*`** -- Release preparation branches

### Branch Protection Rules

The `main` branch enforces:

- At least 1 approving review
- All status checks must pass (lint, test, security scan)
- No direct pushes (all changes via PR)
- Conversation resolution required
- Linear history enforced (squash merge)

Branch protection is verified by the `branch-protection.yml` scheduled workflow and can be set up using the `scripts/setup-branch-protection.sh` script.

---

## Pipeline Stages

A typical CI/CD pipeline for a Golden Path component follows these stages:

### Continuous Integration (CI)

```
Code Push --> Lint --> Test --> Security Scan --> Build --> Validate
```

**1. Lint**

Code formatting and style checks using language-specific linters:

- **Terraform**: `terraform fmt`, `terraform validate`, TFLint with Azure rules
- **Python**: Black, isort, Flake8
- **YAML**: yamllint (200 char max, comments allowed)
- **Markdown**: markdownlint (enforced proper names: Kubernetes, Azure, RHDH)
- **Shell**: shellcheck for Bash scripts
- **Kubernetes**: `kubectl` manifest validation, Helm chart linting
- **Secrets**: detect-secrets, gitleaks

All linters are configured in `.pre-commit-config.yaml` with 14 hooks and can be run locally:

```bash
pre-commit run --all-files            # All hooks
pre-commit run terraform_fmt --all-files  # Specific hook
```

**2. Test**

Unit and integration tests with coverage reporting:

- **Terraform**: Terratest (Go) runs `init`, `validate`, `plan` and asserts outputs
- **Python**: pytest with coverage thresholds
- **Golden Paths**: Template rendering validation

```bash
# Run Terraform tests
cd tests/terraform && go test -v -parallel 4 ./modules/...
```

**3. Security Scan**

Multiple layers of security analysis:

- **GHAS Code Scanning**: CodeQL analysis for known vulnerability patterns
- **Secret Detection**: GitHub secret scanning plus pre-commit hooks
- **Dependency Review**: Dependabot alerts and PR checks
- **Container Scan**: Trivy vulnerability scanner on built images
- **Policy Validation**: OPA Conftest checks Terraform plans against `policies/terraform/azure.rego`

```bash
# Run policy checks locally
conftest test terraform/tfplan.json -p policies/terraform/
```

**4. Build**

Container image build and push to Azure Container Registry:

```bash
# Build and push via ACR Tasks (no local Docker daemon needed)
az acr build \
  --registry ${ACR_NAME} \
  --image ${SERVICE_NAME}:${GIT_SHA} \
  --image ${SERVICE_NAME}:latest \
  .
```

Images are tagged with both the Git SHA (for traceability) and `latest` (for development convenience). Production deployments always reference the SHA tag.

**5. Validate**

Post-build validation before deployment:

- Kubernetes manifest validation with `kubectl --dry-run=server`
- Helm chart linting with `helm lint`
- OPA Gatekeeper constraint dry-run

### Continuous Deployment (CD)

```
Manifest Update --> ArgoCD Detect --> Sync --> Health Check --> Smoke Test
```

**1. Update Manifests**

The CD pipeline updates the image tag in the GitOps repository:

```yaml
# Update the image tag in the Helm values file
image:
  repository: ${ACR_NAME}.azurecr.io/${SERVICE_NAME}
  tag: ${GIT_SHA}
```

**2. ArgoCD Sync**

ArgoCD watches the GitOps repository and detects manifest changes. Depending on the environment sync policy, it either auto-syncs or waits for manual approval.

**3. Health Check**

ArgoCD verifies pod readiness and liveness probes pass before marking the sync as healthy.

**4. Smoke Test**

Post-deployment validation tests confirm the service is responding correctly:

```bash
# Verify the deployed service is healthy
curl -sf https://${SERVICE_URL}/health || exit 1
```

**5. Notification**

Deployment status is sent to Slack (`#platform-deployments`) and posted as a GitHub deployment status.

---

## Deployment Flow

```
Developer Push --> GitHub Actions CI --> Build Image --> Push to ACR
                                                          |
                                                          v
                                          Update GitOps Manifests
                                                          |
                                                          v
                                          ArgoCD Sync --> AKS Cluster
                                                          |
                                                          v
                                          Health Check --> Notification
```

---

## Environment Promotion

| Environment | Trigger | ArgoCD Sync Policy | Approval |
|-------------|---------|-------------------|----------|
| Development | Push to `feature/*` | `dev-auto-sync`: auto-sync, self-heal, prune | None |
| Staging | Merge to `main` | `staging-auto-sync`: auto-sync, self-heal, prune | None |
| Production | Manual trigger or tag | `prod-manual-sync`: manual sync only | Required |

### ArgoCD Sync Policy Details

Five sync policy presets are defined in `argocd/sync-policies.yaml`:

| Preset | Auto-Sync | Self-Heal | Prune | Use Case |
|--------|-----------|-----------|-------|----------|
| `dev-auto-sync` | Yes | Yes | Yes | Dev environments |
| `staging-auto-sync` | Yes | Yes | Yes | Staging |
| `prod-manual-sync` | No | No | No | Production (manual approval) |
| `infra-careful-sync` | Yes | Yes | No | Critical infrastructure |
| `preview-aggressive-sync` | Yes | Yes | Yes | Ephemeral preview environments |

### Promotion Workflow

1. Developer creates a `feature/*` branch and opens a PR
2. CI pipeline runs: lint, test, scan, build
3. PR review and approval
4. Merge to `main` triggers CD pipeline
5. Image is built and pushed to ACR
6. GitOps manifests are updated for staging
7. ArgoCD auto-syncs to staging
8. After staging validation, a manual sync deploys to production

---

## Self-Hosted Runners

For workloads requiring access to private endpoints (databases, Key Vault, internal APIs), self-hosted runners are deployed on AKS via the Actions Runner Controller (ARC).

### Enabling Runners

```hcl
# In terraform.tfvars
enable_github_runners = true
```

### Runner Architecture

```
GitHub Actions
      |
      v
Actions Runner Controller (ARC) on AKS
      |
      +--> Runner Pod (ephemeral, auto-scaled)
      |        |
      |        +--> Access to VNet private endpoints
      |        +--> Access to Key Vault via Workload Identity
      |        +--> Access to ACR for image builds
      |
      +--> Runner Pod (scales to zero when idle)
```

### Runner Configuration

- Runners are ephemeral (new pod per job, no persistent state)
- Auto-scaling based on pending workflow demand (scale-to-zero when idle)
- Runners run in a dedicated namespace with constrained RBAC
- Network access follows the same private endpoint model as other AKS workloads

### When to Use Self-Hosted Runners

| Scenario | Use Self-Hosted | Reason |
|----------|----------------|--------|
| Terraform apply to Azure | Yes | Needs VNet access to private endpoints |
| Container builds with ACR | Yes | Faster push to ACR via VNet |
| Unit tests (no infra deps) | No | GitHub-hosted runners are sufficient |
| Documentation builds | No | No private access needed |

---

## Secrets Handling in CI/CD

CI/CD pipelines never use static credentials. All Azure authentication uses OIDC Workload Identity Federation.

### OIDC Configuration

```yaml
permissions:
  id-token: write  # Required for OIDC token request

steps:
  - name: Azure Login
    uses: azure/login@v2
    with:
      client-id: ${{ secrets.AZURE_CLIENT_ID }}
      tenant-id: ${{ secrets.AZURE_TENANT_ID }}
      subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
```

### Secret Sources

| Secret Type | Source | Access Method |
|-------------|--------|---------------|
| Azure credentials | OIDC Federation | `azure/login` action |
| GitHub token | Automatic | `${{ github.token }}` |
| Application secrets | Azure Key Vault | ESO sync or `az keyvault secret show` |
| Container registry | ACR + AKS integration | AcrPull role assignment |

Setup the federation with:

```bash
./scripts/setup-identity-federation.sh
```

---

## Code Coverage and Quality Gates

### Coverage Requirements

All Golden Path templates include coverage configuration:

| Language | Tool | Minimum Threshold |
|----------|------|-------------------|
| Go | `go test -cover` | 80% |
| Python | pytest-cov | 80% |
| TypeScript | Jest | 75% |

### Quality Gates

PRs are blocked from merging if any of the following fail:

- All CI status checks (lint, test, scan)
- Code coverage below the configured threshold
- GHAS code scanning finds high/critical severity issues
- Secret scanning detects exposed credentials
- OPA policy validation fails

---

## Commit Message Convention

All commits must follow the conventional commits format:

```
<type>(<scope>): <description>

Types: feat, fix, docs, refactor, test, chore, ci, infra
Scopes: terraform, k8s, argocd, agents, golden-paths, scripts, docs
```

Examples:

```
feat(golden-paths): add Node.js microservice template
fix(terraform): correct AKS node pool scaling configuration
ci(workflows): add container image scanning step
docs(techdocs): update monitoring runbook
```

---

## Troubleshooting

### Common CI Failures

| Issue | Cause | Resolution |
|-------|-------|------------|
| Pre-commit hook failure | Formatting or lint error | Run `pre-commit run --all-files` locally |
| Terraform validate fails | Invalid HCL syntax | Run `terraform validate` in the module directory |
| Secret detection alert | Potential secret in code | Review the finding, add to `.secrets.baseline` if false positive |
| OPA policy failure | Non-compliant Terraform plan | Review the policy in `policies/terraform/azure.rego` |
| ACR build timeout | Large image or slow network | Optimize Dockerfile layers, use multi-stage builds |

### Useful Commands

```bash
# Validate all prerequisites are installed
./scripts/validate-prerequisites.sh

# Run pre-commit hooks locally
pre-commit run --all-files

# Test Terraform modules
cd tests/terraform && go test -v ./modules/...

# Validate Terraform config
./scripts/validate-config.sh

# Check post-deployment health
./scripts/validate-deployment.sh
```
