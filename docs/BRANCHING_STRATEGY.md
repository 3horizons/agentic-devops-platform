# Branching Strategy

This document describes the Git branching strategy used in the Three Horizons Accelerator project.

## Branch Overview

| Branch | Purpose | Protected | Direct Push |
|--------|---------|-----------|-------------|
| `main` | Production-ready code | Yes | No |
| `develop` | Integration branch for development | Yes | No |
| `feature/*` | New features | No | Yes |
| `fix/*` | Bug fixes | No | Yes |
| `hotfix/*` | Urgent production fixes | No | Yes |

## Branch Flow

![Branch Flow](docs/assets/branching-strategy.svg)

## Workflow

### 1. Feature Development

```bash
# Start from develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/my-new-feature

# Make changes, commit
git add .
git commit -m "feat: add new feature description"

# Push feature branch
git push origin feature/my-new-feature

# Create PR to develop
```

### 2. Bug Fixes

```bash
# Start from develop
git checkout develop
git pull origin develop

# Create fix branch
git checkout -b fix/bug-description

# Fix the bug, commit
git add .
git commit -m "fix: resolve bug description"

# Push and create PR to develop
git push origin fix/bug-description
```

### 3. Releasing to Production

```bash
# Ensure develop is up to date
git checkout develop
git pull origin develop

# Create PR from develop to main via GitHub
# PR will be validated by CI pipeline
# Requires approval before merge
```

### 4. Hotfixes (Urgent Production Fixes)

```bash
# Start from main
git checkout main
git pull origin main

# Create hotfix branch
git checkout -b hotfix/critical-fix

# Apply fix, commit
git add .
git commit -m "fix: critical production issue"

# Push and create PR to main
git push origin hotfix/critical-fix

# After merge to main, also merge to develop
git checkout develop
git merge main
git push origin develop
```

## Branch Protection Rules

### Main Branch

- **Required reviews:** 1 approval minimum
- **Required status checks:**
  - CI pipeline must pass
  - Branch protection validation
  - Security scans (TFSec, Checkov, Gitleaks)
- **Restrictions:**
  - No direct pushes
  - PRs must come from `develop` branch only
  - No force pushes
  - No branch deletion

### Develop Branch

- **Required reviews:** 1 approval minimum
- **Required status checks:**
  - CI pipeline must pass
  - Pre-commit checks
- **Restrictions:**
  - No force pushes

## Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation changes |
| `style` | Code style changes (formatting, etc.) |
| `refactor` | Code refactoring |
| `perf` | Performance improvements |
| `test` | Adding or updating tests |
| `build` | Build system changes |
| `ci` | CI/CD changes |
| `chore` | Other changes (dependencies, etc.) |
| `revert` | Reverting previous changes |

### Examples

```bash
feat(terraform): add cost management module
fix(ci): resolve YAML parsing error in workflow
docs: update branching strategy documentation
refactor(aks): simplify node pool configuration
ci: add branch protection workflow
```

## Pull Request Guidelines

### PR Title

Follow the same conventional commit format:

```
feat(module): add new capability
fix(workflow): resolve issue with validation
```

### PR Description

Use the PR template and include:

1. **Description** - What changed and why
2. **Type of Change** - Feature, fix, docs, etc.
3. **Related Issues** - Link to issues
4. **Testing** - How it was tested
5. **Checklist** - Verify all items

### PR Checklist

Before requesting review:

- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] Pre-commit hooks pass
- [ ] CI pipeline passes

## GitHub Configuration

### Setting Up Branch Protection (GitHub UI)

1. Go to **Settings** > **Branches**
2. Add rule for `main`:
   - Require pull request reviews (1 approval)
   - Require status checks to pass
   - Require branches to be up to date
   - Include administrators
3. Add rule for `develop`:
   - Require pull request reviews (1 approval)
   - Require status checks to pass

### Required Status Checks

For `main` branch:
- `validate-pr-source`
- `CI / terraform-validate`
- `CI / terraform-security`
- `CI / ci-summary`

For `develop` branch:
- `CI / terraform-validate`
- `CI / ci-summary`

## Quick Reference

### Daily Development

```bash
# Update develop
git checkout develop && git pull

# Create feature
git checkout -b feature/xyz

# Work and commit
git add . && git commit -m "feat: description"

# Push and create PR
git push origin feature/xyz
```

### Release to Production

```bash
# On GitHub:
# 1. Go to develop branch
# 2. Create PR to main
# 3. Fill PR template
# 4. Request review
# 5. Merge after approval
```

### After Merge

```bash
# Clean up feature branch
git checkout develop
git pull origin develop
git branch -d feature/xyz
git push origin --delete feature/xyz
```

## Troubleshooting

### PR Blocked: Wrong Source Branch

PRs to `main` must come from `develop`. If you need to merge a feature directly:

1. First merge to `develop`
2. Then create PR from `develop` to `main`

### CI Failing on PR

1. Check the CI logs
2. Run pre-commit locally: `pre-commit run --all-files`
3. Run Terraform validation: `terraform validate`
4. Fix issues and push

### Merge Conflicts

```bash
# Update your branch with latest develop
git checkout your-branch
git fetch origin
git merge origin/develop
# Resolve conflicts
git add .
git commit -m "chore: resolve merge conflicts"
git push
```

---

**Last Updated:** December 2025
