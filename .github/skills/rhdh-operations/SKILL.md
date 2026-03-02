---
name: rhdh-operations
description: "RHDH day-2 operations reference — covers release notes, GitOps best practices, developer experience patterns, and portal operations. ALWAYS consult these docs for troubleshooting, upgrades, and operational best practices."
---

# RHDH Operations & Best Practices Skill

This skill provides the official Red Hat documentation for RHDH day-2 operations — release notes, GitOps deployment patterns, developer experience best practices, and portal management. **Always consult these references for troubleshooting, upgrade planning, GitOps workflows, and operational guidance.**

## When to Use This Skill

- Planning RHDH version upgrades (release notes, breaking changes, new features)
- Implementing GitOps deployment patterns for RHDH
- Improving developer experience (DX) through portal optimization
- Troubleshooting operational issues (performance, scaling, availability)
- Understanding internal developer portal best practices
- Writing runbooks for RHDH operations
- Creating incident response procedures for portal outages

## Mandatory Rule

> **ALWAYS** read the Release Notes before performing any RHDH upgrade. Check for breaking changes, deprecated features, and new plugin versions. For GitOps deployments, consult the GitOps best practices document to ensure proper sync policies and deployment strategies.

## Official Documentation References

| Document | Path | Covers |
|----------|------|--------|
| **Release Notes** | [red_hat_developer_hub_release_notes.md](../../../docs/official-docs/rhdh/markdown/red_hat_developer_hub_release_notes.md) | RHDH 1.8 changes, new features, bug fixes, known issues, breaking changes, plugin version matrix |
| **GitOps Best Practices** | [git-best-practices_-workflows-for-gitops-deployments-_-red-hat-developer.md](../../../docs/official-docs/rhdh/markdown/git-best-practices_-workflows-for-gitops-deployments-_-red-hat-developer.md) | GitOps workflows, ArgoCD patterns, branching strategies, config-as-code, environment promotion |
| **Frontend DX** | [improving-front-end-developer-experience-_-red-hat-developer.md](../../../docs/official-docs/rhdh/markdown/improving-front-end-developer-experience-_-red-hat-developer.md) | Developer experience patterns, portal UX optimization, frontend best practices |
| **Developer Portals eBook** | [developer-portals-summit-developer-ebook.md](../../../docs/official-docs/rhdh/markdown/developer-portals-summit-developer-ebook.md) | IDP strategy, platform engineering, developer productivity, organizational patterns |

## Quick Reference: Upgrade Process

### Pre-Upgrade Checklist
1. **Read Release Notes** — Check for breaking changes and deprecated features
2. **Backup Database** — PostgreSQL backup before upgrade
3. **Backup ConfigMaps** — Export current `app-config.yaml` and `dynamic-plugins-config.yaml`
4. **Test in Staging** — Deploy new version to staging environment first
5. **Verify Plugin Compatibility** — Check plugin version matrix in release notes

### Upgrade via Helm
```bash
# Check available versions
helm search repo redhat-developer/backstage --versions

# Upgrade
helm upgrade rhdh redhat-developer/backstage \
  --namespace rhdh \
  -f values.yaml \
  --version <new-version>
```

### Post-Upgrade Validation
- [ ] RHDH pods are running and healthy
- [ ] All dynamic plugins loaded successfully
- [ ] Catalog entities are accessible
- [ ] Authentication is working
- [ ] TechDocs are rendering
- [ ] Templates are executable

## Quick Reference: GitOps Deployment

### ArgoCD App-of-Apps Pattern for RHDH
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rhdh
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "4"   # After ingress, cert-manager, monitoring
spec:
  project: default
  source:
    repoURL: https://github.com/org/platform-config
    targetRevision: main
    path: deploy/helm/rhdh
  destination:
    server: https://kubernetes.default.svc
    namespace: rhdh
  syncPolicy:
    automated:
      selfHeal: true
      prune: false        # Never prune RHDH resources automatically
```

### Environment Promotion Strategy
```
dev (auto-sync) → staging (auto-sync) → prod (manual approval)
```

## Operational Runbook Topics

When creating runbooks for RHDH operations, reference these docs:

| Runbook | Primary Doc | Key Metrics |
|---------|------------|-------------|
| **Portal Health Check** | Monitoring & Logging | Pod readiness, `/healthcheck` endpoint, memory/CPU |
| **Plugin Loading Failures** | Dynamic Plugins Reference | Plugin init logs, OCI artifact availability |
| **Auth Outage** | Authentication | Provider connectivity, token expiry, session state |
| **Catalog Sync Delays** | Software Catalog | GitHub App webhook delivery, processor queue |
| **TechDocs Build Failures** | TechDocs | MkDocs logs, storage backend connectivity |
| **Version Upgrade** | Release Notes | Pre/post upgrade checklist |
