# Rollback Runbook

> **Version:** 2.0.0
> **Last Updated:** December 2025
> **Audience:** Platform Engineers, DevOps Engineers

## Overview

This runbook provides procedures for rolling back deployments on the Three Horizons Platform. Use these procedures when a deployment causes issues that require reverting to a previous state.

> 🤖 **Copilot Agents can help!**
> - Ask `@devops` for ArgoCD rollback: "Help me rollback app-name to its previous version"
> - Ask `@terraform` for infrastructure rollback: "Show me how to revert the last Terraform state change"
> - Ask `@sre` to verify health after rollback: "Check if all services are healthy after the rollback"

## Rollback Decision Matrix

| Issue Type | Rollback Method | Time to Rollback |
|------------|-----------------|------------------|
| Application bug | ArgoCD sync to previous commit | 5-10 minutes |
| Configuration error | GitOps revert + sync | 5-10 minutes |
| Infrastructure change | Terraform state rollback | 15-30 minutes |
| Failed Helm upgrade | Helm rollback | 5 minutes |
| Complete deployment failure | Full restore from backup | 30-60 minutes |

## Pre-Rollback Checklist

- [ ] Confirm rollback is necessary (not a transient issue)
- [ ] Identify the last known good state
- [ ] Document current state before rollback
- [ ] Notify stakeholders
- [ ] Prepare rollback plan verification steps

## Application Rollback (ArgoCD)

### Rollback Single Application

```bash
# 1. List application history
argocd app history <app-name>

# 2. Identify target revision
# Note the ID of the last good deployment

# 3. Rollback to specific revision
argocd app rollback <app-name> <revision-id>

# 4. Verify rollback
argocd app get <app-name>
kubectl get pods -n <namespace> -w
```

### Rollback via Git Revert

```bash
# 1. Find the commit to revert
git log --oneline -20

# 2. Revert the problematic commit
git revert <commit-hash>

# 3. Push the revert
git push origin main

# 4. Sync ArgoCD
argocd app sync <app-name>

# 5. Verify
argocd app get <app-name>
```

### Rollback All Applications

```bash
# 1. Identify target revision in app-of-apps
argocd app history root-application

# 2. Rollback root application
argocd app rollback root-application <revision-id>

# 3. Sync all child applications
argocd app sync --all

# 4. Verify all applications
argocd app list
```

## Helm Release Rollback

### Rollback Single Release

```bash
# 1. List release history
helm history <release-name> -n <namespace>

# 2. Rollback to previous revision
helm rollback <release-name> <revision> -n <namespace>

# 3. Verify rollback
helm status <release-name> -n <namespace>
kubectl get pods -n <namespace> -w
```

### Rollback with Values Override

```bash
# If you need to modify values during rollback
helm rollback <release-name> <revision> -n <namespace> \
  --set key=value
```

## Kubernetes Deployment Rollback

### Rollback Deployment

```bash
# 1. Check rollout history
kubectl rollout history deployment/<name> -n <namespace>

# 2. Rollback to previous revision
kubectl rollout undo deployment/<name> -n <namespace>

# 3. Or rollback to specific revision
kubectl rollout undo deployment/<name> -n <namespace> --to-revision=<revision>

# 4. Monitor rollback
kubectl rollout status deployment/<name> -n <namespace>
```

### Rollback DaemonSet

```bash
kubectl rollout undo daemonset/<name> -n <namespace>
```

### Rollback StatefulSet

```bash
# Note: StatefulSet rollback may require manual intervention for PVCs
kubectl rollout undo statefulset/<name> -n <namespace>
```

## Terraform Rollback

### Rollback to Previous State

```bash
# 1. List state history (if using remote backend with versioning)
# Azure Storage:
az storage blob list --account-name <account> --container-name <container> \
  --prefix terraform.tfstate --include snapshots --query "[].snapshot"

# 2. Download previous state
az storage blob download --account-name <account> --container-name <container> \
  --name terraform.tfstate --snapshot <snapshot-id> \
  --file terraform.tfstate.backup

# 3. Review changes that will be made
terraform plan

# 4. Apply the previous state
terraform apply
```

### Rollback Specific Resource

```bash
# 1. Get current state
terraform state show <resource-address>

# 2. Import previous configuration
# Modify .tf file to previous configuration
terraform plan -target=<resource-address>

# 3. Apply targeted change
terraform apply -target=<resource-address>
```

### Emergency: Recreate from Scratch

```bash
# If state is corrupted, recreate with import
terraform import <resource-address> <resource-id>
```

## Database Rollback

### PostgreSQL Point-in-Time Recovery

```bash
# 1. Get available restore points
az postgres flexible-server backup list \
  -g <resource-group> -n <server-name>

# 2. Restore to new server
az postgres flexible-server restore \
  -g <resource-group> \
  --source-server <source-server> \
  --name <new-server-name> \
  --restore-time "2024-01-15T10:00:00Z"

# 3. Update application connection strings
# Via External Secrets or Terraform
```

### Redis Cache Recovery

```bash
# Export current data (if accessible)
redis-cli -h <host> -a <password> --rdb dump.rdb

# For Azure Redis, use import/export feature
az redis export -g <rg> -n <name> --prefix <blob-prefix> --container <container>
```

## Secrets Rollback

### Rollback Key Vault Secret

```bash
# 1. List secret versions
az keyvault secret list-versions --vault-name <vault> --name <secret>

# 2. Get previous version value
az keyvault secret show --vault-name <vault> --name <secret> --version <version>

# 3. Set current to previous value
az keyvault secret set --vault-name <vault> --name <secret> --value "<previous-value>"

# 4. Force External Secret sync
kubectl delete externalsecret <name> -n <namespace>
kubectl apply -f <externalsecret-yaml>

# 5. Restart affected pods
kubectl rollout restart deployment/<name> -n <namespace>
```

## Network Configuration Rollback

### Rollback NSG Rules

```bash
# Via Terraform (preferred)
git revert <commit-with-nsg-changes>
terraform apply

# Or manually via Azure CLI
az network nsg rule delete -g <rg> --nsg-name <nsg> -n <rule-name>
```

## Post-Rollback Verification

### Verification Checklist

```bash
# 1. Run deployment validation
./scripts/validate-deployment.sh --environment <env>

# 2. Check application health
argocd app list
kubectl get pods -A | grep -v Running

# 3. Verify critical endpoints
curl -s -o /dev/null -w "%{http_code}" https://<app-url>/health

# 4. Check logs for errors
kubectl logs -n <namespace> -l app=<app> --tail=100

# 5. Verify metrics are flowing
# Check Grafana dashboards
```

### Notify Stakeholders

Send rollback completion notification:
- What was rolled back
- Why rollback was necessary
- Current state
- Any data implications
- Next steps

## Rollback Failure Procedures

If rollback fails:

1. **Don't panic** - Document the current state
2. **Escalate** - Get additional help
3. **Consider alternatives**:
   - Partial rollback
   - Forward fix
   - Fresh deployment
4. **Communicate** - Keep stakeholders informed

## References

- [Incident Response](incident-response.md)
- [Emergency Procedures](emergency-procedures.md)
- [Deployment Runbook](deployment-runbook.md)
- [Disaster Recovery](disaster-recovery.md)

---

**Document Version:** 2.0.0
**Last Updated:** December 2025
**Maintainer:** Platform Engineering Team
