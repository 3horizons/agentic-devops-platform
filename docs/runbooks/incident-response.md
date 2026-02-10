# Incident Response Runbook

## Overview

This runbook provides procedures for responding to production incidents on the Three Horizons Platform.

> 🤖 **Copilot Agents can help!**
> - Ask `@sre` to run diagnostics: "Analyze the failing pods in namespace X"
> - Ask `@security` if you suspect a security breach: "Check for unauthorized access patterns"
> - Ask `@devops` to deploy a hotfix: "Help me push an emergency fix via ArgoCD"

## Severity Classification

| Severity | Impact | Response Time | Examples |
|----------|--------|---------------|----------|
| **SEV1** | Platform-wide outage | 15 min | All services down, data corruption |
| **SEV2** | Major feature unavailable | 30 min | ArgoCD down, no deployments possible |
| **SEV3** | Minor degradation | 4 hours | Single service degraded |
| **SEV4** | Minimal impact | 24 hours | Non-critical bug |

## Initial Response

### 1. Acknowledge the Incident

```bash
# Check current alerts
kubectl get events -A --field-selector type=Warning

# Quick health check
./scripts/validate-deployment.sh --quick
```

### 2. Assess Impact

- [ ] Which services are affected?
- [ ] How many users/teams impacted?
- [ ] Is data integrity at risk?
- [ ] Is there a security component?

### 3. Create Incident Ticket

Include:
- Severity level
- Affected services
- Initial symptoms
- Time of detection
- Current status

## Diagnostic Procedures

### Check Cluster Health

```bash
# Node status
kubectl get nodes -o wide
kubectl describe nodes | grep -A5 "Conditions:"

# Resource usage
kubectl top nodes
kubectl top pods -A --sort-by=memory | head -20

# Recent events
kubectl get events -A --sort-by='.lastTimestamp' | tail -50
```

### Check Pod Status

```bash
# Find unhealthy pods
kubectl get pods -A | grep -v "Running\|Completed"

# Check specific pod
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --tail=100

# Check previous container logs
kubectl logs <pod-name> -n <namespace> --previous
```

### Check Services

```bash
# Service endpoints
kubectl get endpoints -A

# Test service connectivity
kubectl run curl-test --image=curlimages/curl --rm -it -- \
  curl -v http://<service>.<namespace>.svc.cluster.local
```

### Check Storage

```bash
# PV/PVC status
kubectl get pv,pvc -A

# Check for storage issues
kubectl get events -A | grep -i "volume\|pvc\|storage"
```

## Common Issues and Resolutions

### Node Not Ready

```bash
# Check node conditions
kubectl describe node <node-name>

# Check kubelet logs (via Azure Portal or SSH)
journalctl -u kubelet -n 100

# Cordon and drain if needed
kubectl cordon <node-name>
kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
```

### Pod CrashLoopBackOff

```bash
# Get pod events
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace> --previous

# Common fixes:
# 1. Check resource limits
# 2. Check image pull secrets
# 3. Check ConfigMaps/Secrets
# 4. Check liveness/readiness probes
```

### OOMKilled

```bash
# Check memory usage
kubectl top pod <pod-name> -n <namespace>

# Check events
kubectl get events -n <namespace> | grep OOM

# Increase memory limits in deployment
kubectl patch deployment <name> -n <namespace> --type=json \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/limits/memory", "value": "2Gi"}]'
```

### ArgoCD Out of Sync

```bash
# Check application status
kubectl get applications -n argocd

# Force sync
argocd app sync <app-name> --force

# Check sync errors
argocd app get <app-name>
```

### External Secrets Not Syncing

```bash
# Check ExternalSecret status
kubectl get externalsecrets -A

# Check ClusterSecretStore
kubectl get clustersecretstore
kubectl describe clustersecretstore <name>

# Check ESO logs
kubectl logs -n external-secrets -l app.kubernetes.io/name=external-secrets
```

## Escalation Matrix

| Severity | First Contact | Escalation (15 min) | Escalation (30 min) |
|----------|---------------|---------------------|---------------------|
| SEV1 | Platform On-Call | Platform Lead | Engineering Director |
| SEV2 | Platform On-Call | Platform Lead | - |
| SEV3 | Create Ticket | Platform Team | - |
| SEV4 | Create Ticket | - | - |

## Communication Templates

### Initial Notification

```
INCIDENT: [SEV#] - [Brief Description]
Time Detected: [HH:MM UTC]
Impact: [Description of user impact]
Status: Investigating
Next Update: [Time]
```

### Status Update

```
UPDATE: [SEV#] - [Brief Description]
Current Status: [Investigating/Mitigating/Monitoring]
Actions Taken: [List actions]
Next Steps: [Planned actions]
Next Update: [Time]
```

### Resolution

```
RESOLVED: [SEV#] - [Brief Description]
Duration: [Total time]
Root Cause: [Brief description]
Resolution: [What fixed it]
Follow-up: [Any required actions]
```

## Post-Incident

### Required for SEV1/SEV2

1. [ ] Schedule post-incident review within 48 hours
2. [ ] Document timeline of events
3. [ ] Identify root cause
4. [ ] Create action items to prevent recurrence
5. [ ] Update runbooks if needed

### Post-Incident Review Template

1. **Summary**: What happened?
2. **Impact**: Who was affected and how?
3. **Timeline**: Chronological events
4. **Root Cause**: Why did it happen?
5. **Resolution**: How was it fixed?
6. **Lessons Learned**: What can we improve?
7. **Action Items**: Preventive measures

## References

- [Troubleshooting Guide](../guides/TROUBLESHOOTING_GUIDE.md)
- [Emergency Procedures](emergency-procedures.md)
- [Rollback Runbook](rollback-runbook.md)
