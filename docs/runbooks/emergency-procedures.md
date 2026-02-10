# Emergency Procedures Runbook

## Overview

This runbook contains critical emergency procedures for the Three Horizons Platform. Use these procedures when immediate action is required to protect the platform, data, or users.

> 🤖 **Copilot Agents can help during emergencies!**
> - Ask `@sre` for rapid diagnostics: "All pods are crashing, help me triage"
> - Ask `@security` for security emergencies: "We may have compromised credentials, guide me through rotation"
> - Ask `@terraform` for infrastructure emergencies: "The AKS cluster is unreachable, help me recover"

## Emergency Contact Chain

1. **Platform On-Call**: PagerDuty rotation
2. **Platform Lead**: Escalation within 15 minutes
3. **Security Team**: For security incidents
4. **Cloud Ops**: For Azure infrastructure issues

## Emergency Scenarios

### 1. Complete Platform Outage

**Symptoms**: All services unreachable, no pods running

**Immediate Actions**:

```bash
# 1. Check AKS cluster status
az aks show -g <resource-group> -n <cluster-name> --query "powerState"

# 2. Check node status
kubectl get nodes

# 3. If cluster is stopped, start it
az aks start -g <resource-group> -n <cluster-name>

# 4. Check control plane
az aks get-credentials -g <resource-group> -n <cluster-name> --overwrite-existing
kubectl cluster-info
```

**If control plane unreachable**:
1. Check Azure status page: https://status.azure.com
2. Open Azure support ticket (Severity A)
3. Notify stakeholders

### 2. Security Breach Detected

**Immediate Actions**:

```bash
# 1. Isolate affected resources
kubectl cordon <affected-node>

# 2. Capture evidence before changes
kubectl get pods -A -o yaml > pods-snapshot.yaml
kubectl get events -A > events-snapshot.txt

# 3. Revoke compromised credentials
az keyvault secret set --vault-name <vault> --name <secret> --value "REVOKED"

# 4. Check for unauthorized access
kubectl get secrets -A
kubectl auth can-i --list --as=system:anonymous
```

**Required Notifications**:
- [ ] Security Team immediately
- [ ] Legal/Compliance within 1 hour
- [ ] Management within 2 hours

### 3. Data Corruption Risk

**Immediate Actions**:

```bash
# 1. Stop writes to affected system
kubectl scale deployment <name> -n <namespace> --replicas=0

# 2. Create backup immediately
# For PostgreSQL
pg_dump -h <host> -U <user> -d <database> > emergency-backup.sql

# 3. Verify backup integrity
pg_restore --list emergency-backup.sql

# 4. Document current state
kubectl get pvc -A -o yaml > pvc-state.yaml
```

### 4. Resource Exhaustion

**Symptoms**: Pods evicted, OOMKilled, disk pressure

**Immediate Actions**:

```bash
# 1. Identify resource pressure
kubectl describe nodes | grep -A5 "Conditions:"

# 2. Find top consumers
kubectl top pods -A --sort-by=memory | head -20
kubectl top pods -A --sort-by=cpu | head -20

# 3. Emergency pod eviction
kubectl delete pod <pod-name> -n <namespace> --grace-period=0 --force

# 4. Scale down non-critical workloads
kubectl scale deployment <non-critical> -n <namespace> --replicas=0

# 5. Add nodes if needed
az aks nodepool scale -g <rg> -n <pool> --cluster-name <cluster> --node-count <new-count>
```

### 5. Certificate Expiration

**Symptoms**: TLS errors, service-to-service failures

**Immediate Actions**:

```bash
# 1. Check certificate expiration
kubectl get certificates -A
kubectl describe certificate <name> -n <namespace>

# 2. Force certificate renewal (cert-manager)
kubectl delete certificate <name> -n <namespace>
# cert-manager will recreate it

# 3. Restart affected pods
kubectl rollout restart deployment <name> -n <namespace>

# 4. Verify new certificate
kubectl get certificates -A
```

### 6. Secrets Leak Detected

**Immediate Actions**:

```bash
# 1. Identify leaked secrets
# Check git history, logs, etc.

# 2. Rotate ALL potentially exposed secrets
# In Azure Key Vault:
az keyvault secret set --vault-name <vault> --name <secret> --value "<new-value>"

# 3. Force secret sync
kubectl delete externalsecret <name> -n <namespace>
# ESO will recreate and sync new value

# 4. Restart all pods using the secret
kubectl rollout restart deployment -n <namespace>

# 5. Audit access logs
az monitor activity-log list --resource-group <rg> --start-time <time>
```

## Emergency Shutdown Procedure

Use only when platform must be completely stopped:

```bash
# 1. Notify all stakeholders
# Use emergency communication channel

# 2. Stop all deployments
kubectl scale deployment --all -n <namespace> --replicas=0

# 3. Cordon all nodes
kubectl cordon --all

# 4. Stop AKS cluster (preserves state)
az aks stop -g <resource-group> -n <cluster-name>

# 5. Document shutdown time and reason
```

## Emergency Startup Procedure

After emergency shutdown:

```bash
# 1. Start AKS cluster
az aks start -g <resource-group> -n <cluster-name>

# 2. Wait for nodes
kubectl wait --for=condition=Ready nodes --all --timeout=600s

# 3. Uncordon nodes
kubectl uncordon --all

# 4. Verify system pods
kubectl get pods -n kube-system

# 5. Sync ArgoCD applications
argocd app sync --all

# 6. Validate deployment
./scripts/validate-deployment.sh --environment prod

# 7. Notify stakeholders of restoration
```

## Emergency Contacts

| Role | Primary | Backup |
|------|---------|--------|
| Platform On-Call | PagerDuty | Slack #platform-oncall |
| Security | security@company.com | Slack #security-urgent |
| Azure Support | Azure Portal | Phone support |
| Management | Escalation list | - |

## Communication Channels

- **Primary**: PagerDuty + Slack #incidents
- **Backup**: Email distribution list
- **Stakeholders**: Status page update

## Checklist: Before Taking Emergency Action

- [ ] Confirm severity justifies emergency action
- [ ] Document current state before changes
- [ ] Notify appropriate stakeholders
- [ ] Have rollback plan ready
- [ ] Two-person verification for destructive actions

## References

- [Incident Response](incident-response.md)
- [Rollback Runbook](rollback-runbook.md)
- [Disaster Recovery](disaster-recovery.md)
