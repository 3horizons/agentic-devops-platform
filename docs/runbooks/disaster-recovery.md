# Disaster Recovery Runbook

## Overview

This runbook provides procedures for disaster recovery of the Three Horizons Platform. Use these procedures when recovering from major incidents that require restoration of the platform.

> 🤖 **Copilot Agents can help!**
> - Ask `@sre` to assess the damage: "Help me determine which components need recovery"
> - Ask `@terraform` to rebuild infrastructure: "Recreate the AKS cluster from Terraform state"
> - Ask `@devops` to restore ArgoCD apps: "Re-bootstrap the app-of-apps after cluster recovery"

## Recovery Objectives

| Metric | Target | Notes |
|--------|--------|-------|
| **RTO** (Recovery Time Objective) | 4 hours | Time to restore service |
| **RPO** (Recovery Point Objective) | 1 hour | Maximum data loss acceptable |

## Backup Inventory

### Automated Backups

| Component | Backup Type | Frequency | Retention |
|-----------|-------------|-----------|-----------|
| Terraform State | Azure Blob versioning | On change | 90 days |
| PostgreSQL | Azure automated backup | Daily + PITR | 35 days |
| Redis | RDB snapshots | Hourly | 7 days |
| Key Vault | Soft delete + purge protection | N/A | 90 days |
| AKS etcd | Azure managed | Continuous | 30 days |
| Git repositories | GitHub | Continuous | Unlimited |

### Manual Backups (Pre-Maintenance)

```bash
# Export Kubernetes resources
kubectl get all -A -o yaml > k8s-backup-$(date +%Y%m%d).yaml

# Export ArgoCD applications
kubectl get applications -n argocd -o yaml > argocd-apps-backup.yaml

# Export secrets (encrypted)
kubectl get secrets -A -o yaml | kubeseal --format yaml > sealed-secrets-backup.yaml
```

## Disaster Scenarios

### Scenario 1: AKS Cluster Loss

**Symptoms**: Cluster unreachable, all workloads down

**Recovery Procedure**:

```bash
# 1. Verify cluster status
az aks show -g <resource-group> -n <cluster-name>

# 2. If cluster is gone, recreate with Terraform
cd terraform
terraform plan -target=module.aks_cluster
terraform apply -target=module.aks_cluster

# 3. Get new credentials
az aks get-credentials -g <resource-group> -n <cluster-name> --overwrite-existing

# 4. Wait for nodes
kubectl wait --for=condition=Ready nodes --all --timeout=600s

# 5. Restore ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 6. Restore applications via GitOps
kubectl apply -f argocd/app-of-apps/root-application.yaml

# 7. Wait for sync
argocd app sync --all
argocd app wait --all --health

# 8. Validate
./scripts/validate-deployment.sh --environment prod
```

**Estimated Recovery Time**: 2-3 hours

### Scenario 2: Database Corruption/Loss

**Symptoms**: Application errors, data inconsistency

**Recovery Procedure for PostgreSQL**:

```bash
# 1. Stop application writes
kubectl scale deployment <app> -n <namespace> --replicas=0

# 2. List available restore points
az postgres flexible-server backup list \
  -g <resource-group> -n <server-name> -o table

# 3. Create restored server
az postgres flexible-server restore \
  -g <resource-group> \
  --source-server <source-server> \
  --name <server-name>-restored \
  --restore-time "2024-01-15T10:00:00Z"

# 4. Verify data on restored server
psql -h <restored-server>.postgres.database.azure.com -U <admin> -d <database> \
  -c "SELECT COUNT(*) FROM important_table;"

# 5. Update connection string in Key Vault
az keyvault secret set --vault-name <vault> \
  --name postgresql-host \
  --value "<restored-server>.postgres.database.azure.com"

# 6. Force secret sync
kubectl delete externalsecret -n <namespace> postgresql-credentials
kubectl apply -f externalsecrets/postgresql-credentials.yaml

# 7. Restart application
kubectl scale deployment <app> -n <namespace> --replicas=<original>
kubectl rollout restart deployment <app> -n <namespace>

# 8. Verify application
curl https://<app-url>/health
```

**Estimated Recovery Time**: 1-2 hours

### Scenario 3: Region Failure

**Symptoms**: All Azure services in region unavailable

**Recovery Procedure**:

```bash
# 1. Assess damage
az resource list -g <resource-group> -o table

# 2. If using geo-redundant storage, data is safe
# Update Terraform to use secondary region
# Edit terraform.tfvars:
# location = "brazilsoutheast"  # Secondary region

# 3. Deploy to secondary region
terraform plan -var="location=brazilsoutheast"
terraform apply -var="location=brazilsoutheast"

# 4. Update DNS to point to new region
az network dns record-set a update \
  -g <dns-rg> -z <domain> -n <record> \
  --set aRecords[0].ipv4Address=<new-ip>

# 5. Restore databases from geo-replicated backups
az postgres flexible-server geo-restore \
  -g <resource-group> \
  --source-server <source-server-in-failed-region> \
  --name <new-server-name> \
  --location <secondary-region>

# 6. Sync applications
argocd app sync --all

# 7. Validate
./scripts/validate-deployment.sh --environment prod
```

**Estimated Recovery Time**: 3-4 hours

### Scenario 4: Ransomware/Security Breach

**Symptoms**: Unauthorized changes, encrypted files, suspicious activity

**Recovery Procedure**:

```bash
# 1. ISOLATE - Prevent further damage
az aks stop -g <resource-group> -n <cluster-name>
az network nsg rule create -g <rg> --nsg-name <nsg> -n DenyAllInbound \
  --priority 100 --access Deny --direction Inbound --source-address-prefixes '*'

# 2. PRESERVE - Capture evidence
az storage account create -g <evidence-rg> -n <evidence-storage>
# Snapshot affected disks
az snapshot create -g <rg> -n evidence-snapshot --source <disk-id>

# 3. CONTAIN - Revoke all credentials
# Rotate all secrets in Key Vault
./scripts/rotate-all-secrets.sh

# Revoke Azure AD tokens
az ad app credential reset --id <app-id>

# 4. COMMUNICATE - Notify security team, management, legal
# Follow security incident process

# 5. RESTORE - From known clean backup
# Choose restore point BEFORE breach was detected
az postgres flexible-server restore \
  --restore-time "2024-01-10T00:00:00Z"  # Before breach

# 6. REBUILD - Fresh cluster from clean state
terraform destroy  # Remove compromised infrastructure
terraform apply    # Recreate from scratch

# 7. VALIDATE - Security scan before going live
./scripts/security-scan.sh

# 8. MONITOR - Enhanced monitoring post-recovery
# Enable additional logging
az monitor diagnostic-settings create ...
```

**Estimated Recovery Time**: 4-8 hours (plus security investigation)

## Recovery Validation Checklist

### Infrastructure Validation

- [ ] All nodes Ready
- [ ] All system pods Running
- [ ] Storage classes available
- [ ] Network connectivity verified
- [ ] DNS resolving correctly

### Application Validation

- [ ] ArgoCD synced and healthy
- [ ] All applications deployed
- [ ] Health endpoints responding
- [ ] Database connections working
- [ ] External integrations verified

### Data Validation

- [ ] Database queries returning expected data
- [ ] No data corruption detected
- [ ] Audit logs intact
- [ ] Backups resuming

### Security Validation

- [ ] Secrets rotated (if security incident)
- [ ] Access logs reviewed
- [ ] No unauthorized resources
- [ ] Security scanning clean

## DR Testing Schedule

| Test Type | Frequency | Duration | Last Tested |
|-----------|-----------|----------|-------------|
| Backup restore | Monthly | 2 hours | YYYY-MM-DD |
| Failover drill | Quarterly | 4 hours | YYYY-MM-DD |
| Full DR test | Annually | 1 day | YYYY-MM-DD |

## DR Contacts

| Role | Contact | Responsibility |
|------|---------|----------------|
| DR Lead | TBD | Coordinates recovery |
| Platform Team | TBD | Technical execution |
| Database Admin | TBD | Data recovery |
| Security | TBD | Security validation |
| Communications | TBD | Stakeholder updates |

## References

- [Emergency Procedures](emergency-procedures.md)
- [Incident Response](incident-response.md)
- [Azure DR Documentation](https://docs.microsoft.com/azure/site-recovery/)
- [AKS BCDR Best Practices](https://docs.microsoft.com/azure/aks/operator-best-practices-multi-region)
