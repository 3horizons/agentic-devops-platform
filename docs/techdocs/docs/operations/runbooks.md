# Runbooks

This page contains step-by-step operational runbooks for common platform tasks and incident response scenarios. Each runbook follows a consistent format: trigger condition, prerequisites, diagnostic steps, resolution procedure, and verification.

---

## AKS Cluster Operations

### Scaling Node Pools

**Trigger**: Application pods are pending due to insufficient cluster capacity, or cost optimization requires scaling down during low-traffic periods.

**Prerequisites**: `kubectl` and `az` CLI authenticated, Contributor role on the AKS resource group.

**Diagnosis**:

```bash
# Check for pending pods
kubectl get pods -A --field-selector=status.phase=Pending

# Check current node pool status
kubectl get nodes -o wide
az aks nodepool list --resource-group ${RG} --cluster-name ${CLUSTER} -o table

# Check resource utilization
kubectl top nodes
```

**Resolution**:

```bash
# Scale user node pool (adjust count as needed)
az aks nodepool scale \
  --resource-group ${RG} \
  --cluster-name ${CLUSTER} \
  --name userpool \
  --node-count 5

# Wait for nodes to become ready
kubectl get nodes -w
```

**Verification**:

```bash
# All nodes should be in Ready state
kubectl get nodes | grep -c "Ready"

# Pending pods should now be scheduled
kubectl get pods -A --field-selector=status.phase=Pending
```

### AKS Cluster Upgrade

**Trigger**: Kubernetes version upgrade is available and scheduled during a maintenance window.

**Prerequisites**: Coordinate with all teams. Verify no active deployments. Check compatibility of Helm charts and custom controllers.

**Diagnosis**:

```bash
# Check available upgrades
az aks get-upgrades --resource-group ${RG} --cluster-name ${CLUSTER} -o table

# Check current version
az aks show --resource-group ${RG} --cluster-name ${CLUSTER} --query kubernetesVersion
```

**Resolution**:

```bash
# Step 1: Upgrade control plane first
az aks upgrade \
  --resource-group ${RG} \
  --cluster-name ${CLUSTER} \
  --kubernetes-version ${TARGET_VERSION} \
  --control-plane-only

# Step 2: Upgrade system node pool
az aks nodepool upgrade \
  --resource-group ${RG} \
  --cluster-name ${CLUSTER} \
  --name systempool \
  --kubernetes-version ${TARGET_VERSION}

# Step 3: Upgrade user node pool
az aks nodepool upgrade \
  --resource-group ${RG} \
  --cluster-name ${CLUSTER} \
  --name userpool \
  --kubernetes-version ${TARGET_VERSION}
```

**Verification**:

```bash
# Verify cluster version
az aks show --resource-group ${RG} --cluster-name ${CLUSTER} --query kubernetesVersion

# Verify all nodes are on the new version
kubectl get nodes -o custom-columns=NAME:.metadata.name,VERSION:.status.nodeInfo.kubeletVersion

# Verify all pods are healthy
kubectl get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded | head -20
```

### Node Not Ready Recovery

**Trigger**: `NodeNotReady` alert fires when a node is unready for 5+ minutes.

**Diagnosis**:

```bash
# Identify problematic nodes
kubectl get nodes | grep NotReady

# Check node conditions and events
kubectl describe node ${NODE_NAME} | grep -A 10 "Conditions:"
kubectl get events --field-selector involvedObject.name=${NODE_NAME} --sort-by=.lastTimestamp
```

**Resolution**:

```bash
# Option 1: Check if the node is cordoned
kubectl uncordon ${NODE_NAME}

# Option 2: For persistent issues, cordon and drain
kubectl cordon ${NODE_NAME}
kubectl drain ${NODE_NAME} --ignore-daemonsets --delete-emptydir-data --timeout=120s
# AKS auto-repair will provision a replacement node

# Option 3: Scale the node pool to force fresh provisioning
az aks nodepool scale \
  --resource-group ${RG} \
  --cluster-name ${CLUSTER} \
  --name ${POOL_NAME} \
  --node-count $((CURRENT_COUNT + 1))
```

**Verification**: All nodes show `Ready` status and workloads are rescheduled successfully.

---

## ArgoCD Operations

### Sync Failure Recovery

**Trigger**: `ArgoSyncFailed` alert fires when an application cannot sync from the Git repository.

**Diagnosis**:

```bash
# List all applications and their sync status
kubectl get applications -n argocd

# Check the specific application
kubectl describe application ${APP_NAME} -n argocd

# View detailed sync error
argocd app get ${APP_NAME}
```

**Common Causes and Resolutions**:

1. **Manifest validation error** -- Fix YAML syntax or schema issues in the GitOps repository
2. **Resource conflict** -- Another controller owns the resource; check for conflicting Helm releases or manual edits
3. **Namespace not found** -- Ensure the target namespace exists and sync waves are ordered correctly
4. **Git repository connection failure** -- Verify repo credentials in `argocd/repo-credentials.yaml`
5. **Out of sync with pruning disabled** -- Resources were removed from Git but remain in the cluster

**Resolution**:

```bash
# Retry the sync
argocd app sync ${APP_NAME} --retry-limit 3

# If resources are stuck, force sync
argocd app sync ${APP_NAME} --force

# If specific resources are blocking, sync them individually
argocd app sync ${APP_NAME} --resource apps/Deployment/${RESOURCE_NAME}
```

**Verification**: Application shows `Synced` and `Healthy` status.

### Rolling Back an Application

**Trigger**: A deployment caused regressions and needs to be reverted.

**Diagnosis**:

```bash
# List application history with revisions
argocd app history ${APP_NAME}
```

**Resolution**:

```bash
# Option 1: Roll back to a specific ArgoCD revision
argocd app rollback ${APP_NAME} ${REVISION_NUMBER}

# Option 2: Revert the Git commit (preferred for traceability)
git revert ${COMMIT_SHA}
git push origin main
# ArgoCD will auto-sync to the reverted state
```

**Verification**: Application health returns to `Healthy` and error rate drops.

### Sync Wave Troubleshooting

**Trigger**: Applications are not deploying in the correct order after a platform bootstrap.

The platform sync wave order is defined in `argocd/app-of-apps/root-application.yaml`:

| Wave | Components |
| ---- | ---------- |
| 1 | cert-manager, external-dns |
| 2 | ingress-nginx |
| 3 | prometheus, jaeger |
| 4 | Red Hat Developer Hub |
| 5+ | Team namespaces, applications |

**Diagnosis**:

```bash
# Check sync wave annotations on all applications
kubectl get applications -n argocd \
  -o custom-columns=NAME:.metadata.name,WAVE:.metadata.annotations.argocd\.argoproj\.io/sync-wave,STATUS:.status.sync.status

# Identify which wave is stuck
argocd app resources ${APP_NAME} --orphaned
```

**Resolution**: Fix the blocking application in the earlier wave first. Applications in later waves will proceed automatically once dependencies are healthy.

---

## Database Operations

### PostgreSQL Health Check

**Trigger**: Database-related alerts fire or applications report connection errors.

**Diagnosis**:

```bash
# Check server status
az postgres flexible-server show \
  --resource-group ${RG} \
  --name ${PG_SERVER} \
  --query "{state:state, version:version, haState:highAvailability.state}" \
  -o table

# Check connectivity from within the cluster
kubectl run pg-check --rm -it --restart=Never \
  --image=postgres:16-alpine -- \
  pg_isready -h ${PG_HOST} -U ${PG_USER}

# Check active connections
kubectl run pg-check --rm -it --restart=Never \
  --image=postgres:16-alpine -- \
  psql "host=${PG_HOST} dbname=postgres user=${PG_USER} sslmode=require" \
  -c "SELECT count(*) as connections, state FROM pg_stat_activity GROUP BY state;"
```

**Resolution for HA-enabled deployments (standard/enterprise)**:

1. Azure manages automatic failover to the standby replica
2. Monitor failover progress in Azure Portal or CLI
3. If applications do not reconnect, perform a rolling restart:

```bash
kubectl rollout restart deployment/${SERVICE} -n ${NAMESPACE}
```

**Resolution for non-HA deployments (express)**:

```bash
# Attempt server restart
az postgres flexible-server restart \
  --resource-group ${RG} \
  --name ${PG_SERVER}
```

If restart fails, restore from the latest geo-redundant backup.

### Redis Health Check

**Trigger**: Redis connection errors or high latency reported by applications.

**Diagnosis**:

```bash
# Check Redis status
az redis show \
  --resource-group ${RG} \
  --name ${REDIS_NAME} \
  --query "{provisioningState:provisioningState, sslPort:sslPort}" \
  -o table

# Check connectivity from within the cluster
kubectl run redis-check --rm -it --restart=Never \
  --image=redis:7-alpine -- \
  redis-cli -h ${REDIS_HOST} -p 6380 --tls PING
```

**Resolution**: If Redis is unreachable, check the private endpoint and NSG rules. If Redis is overloaded, consider scaling up the SKU tier.

### Database Backup Verification

**Trigger**: Regular scheduled verification or before any major database operation.

**Procedure**:

```bash
# List available backups
az postgres flexible-server backup list \
  --resource-group ${RG} \
  --name ${PG_SERVER} \
  -o table

# Verify geo-redundant backup is enabled
az postgres flexible-server show \
  --resource-group ${RG} \
  --name ${PG_SERVER} \
  --query "backup.geoRedundantBackup"
```

Retention periods: 7 days for dev, 35 days for prod with geo-redundant backup.

---

## Certificate Operations

### TLS Certificate Renewal

**Trigger**: `CertificateExpiring` alert fires when a certificate is within 14 days of expiry.

cert-manager handles automatic renewal for Let's Encrypt certificates. If auto-renewal fails:

**Diagnosis**:

```bash
# Check certificate status
kubectl get certificates -A
kubectl describe certificate ${CERT_NAME} -n ${NAMESPACE}

# Check cert-manager controller logs
kubectl logs -n cert-manager deployment/cert-manager --tail=100

# Check ACME challenges (for Let's Encrypt)
kubectl get challenges -A
kubectl get orders -A
```

**Resolution**:

```bash
# Option 1: Verify the Issuer is healthy
kubectl get issuer -n ${NAMESPACE}
kubectl describe issuer ${ISSUER_NAME} -n ${NAMESPACE}

# Option 2: Delete the Secret to trigger re-issuance
kubectl delete secret ${CERT_SECRET_NAME} -n ${NAMESPACE}
# cert-manager will detect the missing secret and issue a new certificate

# Option 3: If the Issuer itself is broken, recreate it
kubectl delete issuer ${ISSUER_NAME} -n ${NAMESPACE}
kubectl apply -f issuer.yaml
```

**Verification**:

```bash
# Certificate should show Ready=True and a future expiry date
kubectl get certificate ${CERT_NAME} -n ${NAMESPACE} \
  -o jsonpath='{.status.conditions[0].status} - expires: {.status.notAfter}'
```

---

## Disaster Recovery

### Initiating Failover to DR Region

**Trigger**: Primary region (`brazilsouth`) is unavailable and SLO breach is imminent.

**Prerequisites**: `enable_disaster_recovery = true` in Terraform, DR region pre-provisioned.

**Procedure**:

```bash
# 1. Verify primary region is down
az aks show --resource-group ${PRIMARY_RG} --cluster-name ${PRIMARY_CLUSTER} 2>/dev/null \
  || echo "PRIMARY UNREACHABLE"

# 2. Switch DNS to DR region
az network dns record-set a update \
  --resource-group ${DNS_RG} \
  --zone-name ${DNS_ZONE} \
  --name ${RECORD_NAME} \
  --set aRecords[0].ipv4Address=${DR_IP}

# 3. Verify DR cluster health
kubectl --context ${DR_CONTEXT} get nodes
kubectl --context ${DR_CONTEXT} get pods -A --field-selector=status.phase!=Running,status.phase!=Succeeded

# 4. Verify ArgoCD sync in DR cluster
kubectl --context ${DR_CONTEXT} get applications -n argocd

# 5. Verify database replication
az postgres flexible-server show \
  --resource-group ${DR_RG} \
  --name ${DR_PG_SERVER} \
  --query state
```

### Failback to Primary

**Procedure**:

```bash
# 1. Verify primary is restored
az aks show --resource-group ${PRIMARY_RG} --cluster-name ${PRIMARY_CLUSTER}

# 2. Sync primary ArgoCD
argocd --context ${PRIMARY_CONTEXT} app sync --all

# 3. Switch DNS back to primary
az network dns record-set a update \
  --resource-group ${DNS_RG} \
  --zone-name ${DNS_ZONE} \
  --name ${RECORD_NAME} \
  --set aRecords[0].ipv4Address=${PRIMARY_IP}

# 4. Monitor for 30 minutes before declaring complete
```

---

## Common Alert Response Procedures

### Pod Crash Loop Recovery

**Trigger**: `PodCrashLooping` alert fires when a pod restarts more than 5 times in 10 minutes.

**Diagnosis**:

```bash
# Identify the crashing pod
kubectl get pods -A | grep CrashLoopBackOff

# Check container logs (current and previous attempts)
kubectl logs ${POD_NAME} -n ${NAMESPACE}
kubectl logs ${POD_NAME} -n ${NAMESPACE} --previous

# Check pod events
kubectl describe pod ${POD_NAME} -n ${NAMESPACE}
```

**Common Causes**:

| Cause | Indicator | Resolution |
| ----- | --------- | ---------- |
| OOMKilled | `Reason: OOMKilled` in events | Increase `resources.limits.memory` |
| Config error | Error in application logs | Check ConfigMaps and Secrets |
| Dependency unavailable | Connection refused in logs | Verify upstream services |
| Image pull error | `ImagePullBackOff` status | Verify ACR access and image tag |
| Readiness probe failure | `Unhealthy` events | Increase `initialDelaySeconds` |

**Verification**: Pod reaches `Running` state and remains stable for at least 10 minutes.

### High Error Rate

**Trigger**: `HighErrorRate` alert fires when HTTP 5xx rate exceeds 5% for 5 minutes.

**Diagnosis**:

```bash
# Check ingress logs for 5xx errors
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller \
  --tail=100 | grep " 50[0-9] "

# Check application logs
kubectl logs deployment/${SERVICE_NAME} -n ${NAMESPACE} --tail=200

# Check resource pressure
kubectl top pods -n ${NAMESPACE} --sort-by=cpu
```

**Resolution**:

```bash
# If caused by a bad deployment, roll back
argocd app rollback ${APP_NAME}

# If caused by resource pressure, scale up
kubectl scale deployment/${SERVICE_NAME} -n ${NAMESPACE} --replicas=5

# If caused by dependency failure, check upstream
kubectl exec deployment/${SERVICE_NAME} -n ${NAMESPACE} -- \
  curl -sf http://localhost:${HEALTH_PORT}/health
```

### Disk Space Low

**Trigger**: `DiskSpaceLow` alert fires when disk usage exceeds 90%.

**Resolution**:

```bash
# Delete completed and failed pods
kubectl delete pods -A --field-selector=status.phase==Succeeded
kubectl delete pods -A --field-selector=status.phase==Failed

# Force image garbage collection via node image upgrade
az aks nodepool upgrade \
  --resource-group ${RG} \
  --cluster-name ${CLUSTER} \
  --name ${NODEPOOL} \
  --node-image-only
```

---

## Platform Health Check

Run the comprehensive platform health check:

```bash
./scripts/validate-deployment.sh
```

### Quick Manual Health Check

```bash
# AKS cluster
kubectl get nodes && kubectl cluster-info

# Core platform services
kubectl get pods -n rhdh
kubectl get pods -n argocd
kubectl get pods -n monitoring
kubectl get pods -n external-secrets

# ArgoCD applications
kubectl get applications -n argocd -o custom-columns=NAME:.metadata.name,SYNC:.status.sync.status,HEALTH:.status.health.status

# External Secrets
kubectl get clustersecretstore
kubectl get externalsecrets -A --no-headers | grep -v SecretSynced

# Certificates
kubectl get certificates -A -o custom-columns=NAME:.metadata.name,READY:.status.conditions[0].status

# RHDH portal
curl -sf https://devhub.3horizons.ai/health && echo "RHDH OK" || echo "RHDH UNHEALTHY"
```
