# Node Replacement Runbook

## Overview

This runbook describes the procedures for replacing AKS nodes in the Three Horizons platform, including planned replacements and emergency scenarios.

> 🤖 **Copilot Agents can help!**
> - Ask `@sre` to check node health: "Which nodes are NotReady and what are the events?"
> - Ask `@terraform` for nodepool changes: "Help me add a new nodepool to the AKS module"

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Planned Node Replacement](#planned-node-replacement)
3. [Emergency Node Replacement](#emergency-node-replacement)
4. [Node Pool Scaling](#node-pool-scaling)
5. [Troubleshooting](#troubleshooting)
6. [Rollback Procedures](#rollback-procedures)

---

## Prerequisites

### Required Access
- Azure subscription Owner or Contributor role
- AKS cluster admin credentials
- kubectl configured for the cluster
- Azure CLI installed and authenticated

### Required Tools
```bash
# Verify tools
az --version
kubectl version
helm version
```

### Pre-flight Checks
```bash
# Check cluster health
kubectl get nodes
kubectl get pods --all-namespaces | grep -v Running | grep -v Completed

# Check node conditions
kubectl describe nodes | grep -A5 "Conditions:"

# Verify PodDisruptionBudgets
kubectl get pdb --all-namespaces
```

---

## Planned Node Replacement

### Scenario: Kubernetes Version Upgrade

#### Step 1: Review Current State
```bash
# Get current node pool information
az aks nodepool list \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --output table

# Check current Kubernetes version
kubectl version --short
```

#### Step 2: Cordon the Node
```bash
# Prevent new pods from being scheduled
kubectl cordon <node-name>

# Verify node is cordoned
kubectl get nodes
```

#### Step 3: Drain the Node
```bash
# Gracefully evict all pods
kubectl drain <node-name> \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --grace-period=300 \
  --timeout=600s

# For stubborn pods, use force (last resort)
kubectl drain <node-name> \
  --ignore-daemonsets \
  --delete-emptydir-data \
  --force
```

#### Step 4: Verify Workloads Migrated
```bash
# Check pods are running on other nodes
kubectl get pods -o wide --all-namespaces | grep <old-node-name>

# Should return empty
```

#### Step 5: Delete the Node
```bash
# For VMSS-based node pools
az vmss delete-instances \
  --resource-group $NODE_RESOURCE_GROUP \
  --name $VMSS_NAME \
  --instance-ids <instance-id>
```

#### Step 6: Verify New Node Joins
```bash
# Watch for new node
kubectl get nodes -w

# Verify node is Ready
kubectl describe node <new-node-name> | grep -A5 "Conditions:"
```

---

## Emergency Node Replacement

### Scenario: Node Failure

#### Immediate Actions

1. **Identify Failed Node**
```bash
# Check node status
kubectl get nodes
kubectl describe node <problem-node>

# Check Azure VM status
az vm get-instance-view \
  --resource-group $NODE_RESOURCE_GROUP \
  --name <vm-name> \
  --query instanceView.statuses
```

2. **Check Affected Workloads**
```bash
# List pods on failed node
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=<failed-node>
```

3. **Force Remove Node (if unresponsive)**
```bash
# Delete node from cluster
kubectl delete node <failed-node>

# Pods will be rescheduled automatically
```

4. **Scale Node Pool**
```bash
# Increase node count to compensate
az aks nodepool scale \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $NODEPOOL_NAME \
  --node-count $NEW_COUNT
```

5. **Verify Recovery**
```bash
# Check all pods are running
kubectl get pods --all-namespaces | grep -v Running | grep -v Completed

# Check new node is healthy
kubectl get nodes
```

---

## Node Pool Scaling

### Scale Up
```bash
# Increase node count
az aks nodepool scale \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $NODEPOOL_NAME \
  --node-count 5

# Or enable autoscaler
az aks nodepool update \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $NODEPOOL_NAME \
  --enable-cluster-autoscaler \
  --min-count 3 \
  --max-count 10
```

### Scale Down
```bash
# Decrease node count (nodes are cordoned/drained automatically)
az aks nodepool scale \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $NODEPOOL_NAME \
  --node-count 3
```

### Add New Node Pool
```bash
# Create new node pool with updated config
az aks nodepool add \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name newpool \
  --node-count 3 \
  --node-vm-size Standard_D4s_v3 \
  --zones 1 2 3 \
  --mode User
```

---

## Troubleshooting

### Node Not Joining Cluster

1. Check Azure VM status
```bash
az vm get-instance-view \
  --resource-group $NODE_RESOURCE_GROUP \
  --name <vm-name>
```

2. Check VM boot diagnostics in Azure Portal

3. Verify NSG rules allow kubelet communication

4. Check AKS cluster certificate status
```bash
az aks show \
  --resource-group $RESOURCE_GROUP \
  --name $CLUSTER_NAME \
  --query "aadProfile"
```

### Pods Not Rescheduling

1. Check PodDisruptionBudgets
```bash
kubectl get pdb --all-namespaces
kubectl describe pdb <pdb-name> -n <namespace>
```

2. Check resource constraints
```bash
kubectl describe nodes | grep -A10 "Allocated resources"
```

3. Check pod affinity/anti-affinity rules
```bash
kubectl get pod <pod-name> -o yaml | grep -A20 "affinity:"
```

### Drain Command Hanging

1. Identify blocking pods
```bash
kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=<node>
```

2. Check pod termination grace period
```bash
kubectl get pod <pod-name> -o yaml | grep terminationGracePeriodSeconds
```

3. Force delete stuck pods
```bash
kubectl delete pod <pod-name> --grace-period=0 --force
```

---

## Rollback Procedures

### If New Node Has Issues

1. **Cordon New Node**
```bash
kubectl cordon <new-node>
```

2. **Scale Back Original Nodes**
```bash
az aks nodepool scale \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $ORIGINAL_NODEPOOL \
  --node-count $ORIGINAL_COUNT
```

3. **Migrate Workloads Back**
```bash
kubectl drain <new-node> --ignore-daemonsets --delete-emptydir-data
```

4. **Remove Problematic Node Pool**
```bash
az aks nodepool delete \
  --resource-group $RESOURCE_GROUP \
  --cluster-name $CLUSTER_NAME \
  --name $NEW_NODEPOOL
```

---

## Health Verification Checklist

After any node replacement:

- [ ] All nodes show `Ready` status
- [ ] All system pods are running (`kube-system` namespace)
- [ ] All application pods are running
- [ ] No pods in `Pending` state due to resource constraints
- [ ] Metrics and logging are functioning
- [ ] ArgoCD shows all applications healthy
- [ ] No alerts firing in Prometheus/Grafana

```bash
# Quick health check script
echo "=== Node Status ==="
kubectl get nodes

echo "=== System Pods ==="
kubectl get pods -n kube-system | grep -v Running

echo "=== All Namespaces ==="
kubectl get pods --all-namespaces | grep -v Running | grep -v Completed

echo "=== PDB Status ==="
kubectl get pdb --all-namespaces
```

---

## Related Runbooks

- [Disaster Recovery](./disaster-recovery.md)
- [Emergency Procedures](./emergency-procedures.md)
- [Incident Response](./incident-response.md)
