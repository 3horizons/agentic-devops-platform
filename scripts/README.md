# Automation Scripts

> **A solution created in partnership with Microsoft, GitHub, and Red Hat**

This directory contains automation scripts for the Three Horizons Platform.

## Script Inventory

### Deployment Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `platform-bootstrap.sh` | Full platform deployment | `./platform-bootstrap.sh --environment dev` |
| `bootstrap.sh` | H1 infrastructure setup | `./bootstrap.sh` |
| `deploy-aro.sh` | Azure Red Hat OpenShift deployment | `./deploy-aro.sh` |

### Validation Scripts

> **Note:** Validation scripts are located in `.github/skills/validation-scripts/scripts/`, not in this directory.
> They are part of the agent skills system. See [AGENTS.md](../AGENTS.md) for details.

| Script | Description | Usage |
|--------|-------------|-------|
| `validate-config.sh` | Configuration validation | `.github/skills/validation-scripts/scripts/validate-config.sh --config terraform.tfvars` |
| `validate-cli-prerequisites.sh` | CLI tools verification | `.github/skills/validation-scripts/scripts/validate-cli-prerequisites.sh` |
| `validate-naming.sh` | Naming conventions check | `.github/skills/validation-scripts/scripts/validate-naming.sh` |
| `validate-agents.sh` | Agent specifications validation | `.github/skills/validation-scripts/scripts/validate-agents.sh` |
| `validate-deployment.sh` | Post-deployment health check | `.github/skills/validation-scripts/scripts/validate-deployment.sh --environment prod` |

### Setup Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `setup-github-app.sh` | GitHub App configuration | `./setup-github-app.sh` |
| `setup-identity-federation.sh` | OIDC workload identity | `./setup-identity-federation.sh` |
| `setup-pre-commit.sh` | Pre-commit hooks | `./setup-pre-commit.sh` |
| `setup-branch-protection.sh` | GitHub branch rules | `./setup-branch-protection.sh` |

### Operations Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `onboard-team.sh` | Team onboarding | `./onboard-team.sh --team-name myteam` |

### Migration Scripts

| Script | Description | Usage |
|--------|-------------|-------|
| `migration/ado-to-github-migration.sh` | Azure DevOps migration | `./migration/ado-to-github-migration.sh` |

## Quick Reference

### First-Time Setup

```bash
# 1. Check prerequisites
./validate-cli-prerequisites.sh

# 2. Configure GitHub App
./setup-github-app.sh

# 3. Set up identity federation
./setup-identity-federation.sh

# 4. Validate configuration
./validate-config.sh --config ../terraform/terraform.tfvars
```

### Deploy Platform

```bash
# Full deployment (all horizons)
./platform-bootstrap.sh --environment dev --horizon all

# Deploy specific horizon
./platform-bootstrap.sh --environment dev --horizon h1

# Dry run (preview only)
./platform-bootstrap.sh --environment dev --dry-run
```

### Validate Deployment

```bash
# Quick health check
./validate-deployment.sh --environment prod --quick

# Full validation
./validate-deployment.sh --environment prod --verbose
```

## Script Development

### Standards

- All scripts use `#!/bin/bash`
- Use `set -euo pipefail` for safety
- Include help documentation
- Follow ShellCheck recommendations
- Include exit codes documentation

### Testing

```bash
# Run ShellCheck on all scripts
shellcheck *.sh

# Test script in dry-run mode (where available)
./script.sh --dry-run
```

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Prerequisites not met |
| 3 | Configuration error |
| 4 | Network error |
| 5 | Authentication error |

## Related Documentation

- [Deployment Guide](../docs/guides/DEPLOYMENT_GUIDE.md)
- [Deployment Runbook](../docs/runbooks/deployment-runbook.md)
