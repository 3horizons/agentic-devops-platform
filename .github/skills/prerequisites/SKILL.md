---
name: prerequisites
description: "CLI tool prerequisites validation and setup — covers all tools needed for platform deployment, development, testing, security scanning, and RHDH plugin development."
---

## When to Use
- Before any deployment workflow
- Environment setup validation
- CI/CD pipeline prerequisite checks
- New developer onboarding
- Plugin development setup

## Prerequisites
- Bash shell (macOS/Linux)
- Access to download tools if missing
- Python 3.11+ (for pip-based tools)
- Recommended: version manager (`asdf` or `mise`) for multi-tool version control

---

## 1. Core Platform (Always Required)

| Tool | Min Version | Purpose | Install (macOS) |
|------|-------------|---------|-----------------|
| az | 2.50.0 | Azure CLI | `brew install azure-cli` |
| terraform | 1.5.0 | Infrastructure as Code | `brew install terraform` |
| kubectl | 1.28.0 | Kubernetes CLI | `brew install kubectl` |
| helm | 3.12.0 | Kubernetes package manager | `brew install helm` |
| gh | 2.30.0 | GitHub CLI | `brew install gh` |
| argocd | 2.8.0 | ArgoCD CLI (GitOps) | `brew install argocd` |
| jq | 1.6 | JSON processor | `brew install jq` |
| yq | 4.0.0 | YAML processor | `brew install yq` |

```bash
# macOS — Install all core tools
brew install azure-cli terraform kubectl helm gh argocd jq yq
```

## 2. Container & Runtime (Always Required)

| Tool | Min Version | Purpose | Install (macOS) |
|------|-------------|---------|-----------------|
| docker | 24.0 | Container runtime (builds, MCP server) | `brew install --cask docker` |
| node | 18.0 | Node.js runtime (npx for MCP servers, plugin dev) | `brew install node@20` |
| npm | 9.0 | Node.js package manager (bundled with node) | (bundled) |
| git | 2.40.0 | Version control | `brew install git` |

```bash
# macOS — Container & runtime
brew install --cask docker
brew install node@20 git
```

## 3. GitHub Copilot CLI (Always Required)

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| gh copilot | latest | GitHub Copilot CLI extension | `gh extension install github/gh-copilot` |

```bash
# Install GitHub Copilot CLI extension
gh auth login
gh extension install github/gh-copilot

# Verify
gh copilot --version
```

## 4. Deployment Target: ARO (Conditional)

Required when `DEPLOY_TARGET=aro` (Azure Red Hat OpenShift).

| Tool | Min Version | Purpose | Install (macOS) |
|------|-------------|---------|-----------------|
| oc | 4.14.0 | OpenShift CLI (ARO) | `brew install openshift-cli` |
| oras | 1.1.0 | OCI Registry (custom plugin push) | `brew install oras` |
| ansible | 2.16.0 | Ansible Automation (RHDH Tech Preview) | `pip install ansible` |

```bash
# macOS — ARO tools (conditional)
brew install openshift-cli oras
pip install ansible
```

## 5. Code Quality & Linting (Dev Environment)

Required for local development. Auto-installed via `pre-commit install`.

| Tool | Min Version | Purpose | Install |
|------|-------------|---------|---------|
| pre-commit | 3.6.0 | Git hooks framework | `brew install pre-commit` |
| tflint | 0.50.0 | Terraform linter | `brew install tflint` |
| shellcheck | 0.9.0 | Shell script linter | `brew install shellcheck` |
| shfmt | 3.8.0 | Shell script formatter | `brew install shfmt` |
| yamllint | 1.33.0 | YAML linter | `pip install yamllint` |
| markdownlint | 0.38.0 | Markdown linter | `npm install -g markdownlint-cli` |
| commitizen | 3.13.0 | Conventional commit validator | `pip install commitizen` |
| terraform-docs | 0.17.0 | Terraform doc generator | `brew install terraform-docs` |
| kubelogin | latest | Azure AKS auth helper | `brew install Azure/kubelogin/kubelogin` |

```bash
# macOS — Code quality tools
brew install pre-commit tflint shellcheck shfmt terraform-docs
brew install Azure/kubelogin/kubelogin
pip install yamllint commitizen
npm install -g markdownlint-cli

# Setup pre-commit hooks
pre-commit install
```

## 6. Security Scanning (Dev + CI)

| Tool | Min Version | Purpose | Install |
|------|-------------|---------|---------|
| tfsec | latest | Terraform security scanner | via pre-commit hook |
| checkov | 3.1.0 | IaC security scanner (multi-framework) | `pip install checkov` |
| gitleaks | 8.18.0 | Git secret scanner | `brew install gitleaks` |
| detect-secrets | 1.4.0 | Secret detector | `pip install detect-secrets` |

```bash
# macOS — Security scanning
brew install gitleaks
pip install checkov detect-secrets
```

## 7. K8s Validation (Dev + CI)

| Tool | Min Version | Purpose | Install |
|------|-------------|---------|---------|
| kubeconform | 0.6.4 | Kubernetes manifest validator | `brew install kubeconform` |
| conftest | 0.46.0 | OPA policy testing for Terraform | `brew install conftest` |

```bash
brew install kubeconform conftest
```

## 8. Testing (For Development)

| Tool | Min Version | Purpose | Install |
|------|-------------|---------|---------|
| go | 1.21.0 | Go runtime (Terratest) | `brew install go` |
| pytest | latest | Python test framework | `pip install pytest` |

```bash
brew install go
pip install pytest
```

## 9. RHDH Plugin Development (For Custom Plugins)

| Tool | Version | Purpose | Install |
|------|---------|---------|---------|
| @janus-idp/cli | latest | Dynamic plugin export CLI | `npm install -g @janus-idp/cli` |
| @backstage/create-app | latest | Backstage plugin scaffold | `npx @backstage/create-app` (npx-only) |

```bash
npm install -g @janus-idp/cli
# @backstage/create-app is used via npx, no global install needed
```

## 10. Python Ecosystem (For Python Development)

Recommended: use `python3 -m venv .venv` for isolation.

| Tool | Min Version | Purpose | Install |
|------|-------------|---------|---------|
| python | 3.11.0 | Python runtime | `brew install python@3.11` |
| black | 24.1.0 | Python formatter | `pip install black` |
| isort | 5.13.0 | Python import sorter | `pip install isort` |
| ruff | latest | Python linter (replaces flake8) | `pip install ruff` |

```bash
brew install python@3.11
python3 -m venv .venv && source .venv/bin/activate
pip install black isort ruff
```

---

## Validation Script

```bash
#!/bin/bash
set -euo pipefail

MODE="${1:---core}"

check_tool() {
  local tool="$1"
  local required="$2"
  if command -v "$tool" &> /dev/null; then
    echo "  ✅ $tool: $(command -v "$tool")"
  elif [ "$required" = "required" ]; then
    echo "  ❌ $tool: MISSING (required)"
    MISSING+=("$tool")
  else
    echo "  ⚠️  $tool: not found (optional)"
  fi
}

MISSING=()

echo "=== Core Platform ==="
for tool in az terraform kubectl helm gh argocd jq yq; do
  check_tool "$tool" "required"
done

echo "=== Container & Runtime ==="
for tool in docker node npm git; do
  check_tool "$tool" "required"
done

echo "=== GitHub Copilot ==="
if gh extension list 2>/dev/null | grep -q copilot; then
  echo "  ✅ gh copilot: installed"
else
  echo "  ⚠️  gh copilot: not installed (run: gh extension install github/gh-copilot)"
fi

if [[ "$MODE" == "--dev" || "$MODE" == "--full" ]]; then
  echo "=== Code Quality ==="
  for tool in pre-commit tflint shellcheck shfmt yamllint markdownlint terraform-docs kubelogin; do
    check_tool "$tool" "required"
  done
  echo "=== Security Scanning ==="
  for tool in checkov gitleaks detect-secrets; do
    check_tool "$tool" "required"
  done
  echo "=== K8s Validation ==="
  for tool in kubeconform conftest; do
    check_tool "$tool" "required"
  done
fi

if [[ "$MODE" == "--full" ]]; then
  echo "=== ARO Tools ==="
  for tool in oc oras ansible; do
    check_tool "$tool" "optional"
  done
  echo "=== Testing ==="
  for tool in go pytest; do
    check_tool "$tool" "optional"
  done
  echo "=== Python Ecosystem ==="
  for tool in python3 black isort ruff; do
    check_tool "$tool" "optional"
  done
  echo "=== Plugin Development ==="
  if npm list -g @janus-idp/cli &>/dev/null; then
    echo "  ✅ @janus-idp/cli: installed"
  else
    echo "  ⚠️  @janus-idp/cli: not found (run: npm install -g @janus-idp/cli)"
  fi
fi

echo ""
if [ ${#MISSING[@]} -ne 0 ]; then
  echo "❌ Missing required tools: ${MISSING[*]}"
  exit 1
fi
echo "✅ All prerequisites satisfied (mode: $MODE)"
```

**Usage:**
```bash
./scripts/validate-prerequisites.sh           # Core only (11 tools)
./scripts/validate-prerequisites.sh --dev     # Core + Quality + Security (25 tools)
./scripts/validate-prerequisites.sh --full    # Everything (33+ tools)
```

---

## Quick Setup (All-in-One)

### macOS
```bash
# Core + Container + Runtime
brew install azure-cli terraform kubectl helm gh argocd jq yq git
brew install --cask docker
brew install node@20

# GitHub Copilot
gh extension install github/gh-copilot

# Code Quality
brew install pre-commit tflint shellcheck shfmt terraform-docs gitleaks
brew install kubeconform conftest
brew install Azure/kubelogin/kubelogin

# Python tools
brew install python@3.11
pip install yamllint commitizen checkov detect-secrets black isort ruff pytest

# Markdown
npm install -g markdownlint-cli

# Pre-commit hooks
pre-commit install
```

### ARO (Additional)
```bash
brew install openshift-cli oras
pip install ansible
```

### Plugin Development (Additional)
```bash
npm install -g @janus-idp/cli
brew install go
```

## Version Manager (Recommended)

Use `asdf` or `mise` to manage multiple tool versions:

```bash
# Install mise
brew install mise

# Add tools
mise use terraform@1.5.0
mise use kubectl@1.28.0
mise use node@20
mise use go@1.21
mise use python@3.11
```

## Integration with Agents

| Agent | Needs | Categories |
|-------|-------|-----------|
| All agents | Core Platform (#1) | az, terraform, kubectl, helm, gh, argocd, jq, yq |
| @deploy, @devops, @sre | Container (#2) | docker, node |
| @deploy, @azure-portal-deploy | ARO (#4) | oc, oras (conditional) |
| @security | Security (#6) | tfsec, checkov, gitleaks, detect-secrets |
| @devops | Quality + K8s (#5,#7) | pre-commit, conftest, kubeconform |
| @test | Testing (#8) | go, pytest, conftest |
| @template-engineer, @rhdh-architect | Plugin Dev (#9) | node, npm, @janus-idp/cli |
| @reviewer | Quality (#5) | tflint, shellcheck, yamllint |
