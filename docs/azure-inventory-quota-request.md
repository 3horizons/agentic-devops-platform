# Azure Resource Inventory & Quota Increase Request

**Subscription**: Visual Studio Enterprise Subscription
**Subscription ID**: `efc4896f-8b1f-4f4c-ad9f-b323ee647e93`
**Tenant ID**: `2fdc24aa-9deb-40a8-a662-d7f5ad81f447`
**Primary Region**: East US 2
**Date**: 2026-03-01

---

## 1. Resource Inventory

### 1.1 Resource Groups

| Resource Group | Location | Purpose |
|---|---|---|
| `rg-threehorizons-demo` | East US 2 | Three Horizons platform (AKS + monitoring) |
| `rg-backstage-demo` | East US 2 | Backstage/RHDH platform (full stack) |
| `MC_rg-threehorizons-demo_aks-threehorizons-demo_eastus2` | East US 2 | AKS managed infra (cluster 1) |
| `MC_rg-backstage-demo_aks-backstage-demo_eastus2` | East US 2 | AKS managed infra (cluster 2) |
| `MA_prometheus-backstage-demo_eastus2_managed` | East US 2 | Managed Prometheus |
| `DefaultResourceGroup-EUS2` | East US 2 | Default |
| `NetworkWatcherRG` | East US 2 | Network Watcher |

### 1.2 AKS Clusters

| Cluster | Resource Group | Location | K8s Version | VM Size | Current Nodes | Min | Max | Autoscale | SKU |
|---|---|---|---|---|---|---|---|---|---|
| `aks-threehorizons-demo` | `rg-threehorizons-demo` | East US 2 | 1.33.6 | Standard_D2s_v5 (2 vCPUs, 8 GiB) | 5 | 5 | 10 | Yes | Free |
| `aks-backstage-demo` | `rg-backstage-demo` | East US 2 | 1.33.6 | Standard_B2s (2 vCPUs, 4 GiB) | 5 | 5 | 8 | Yes | Free |

### 1.3 Databases

| Resource | Type | Location | SKU | Version | State |
|---|---|---|---|---|---|
| `pg-threehorizons-demo` | PostgreSQL Flexible Server | Central US | Standard_B1ms (Burstable) | 16 | Ready |
| `pgbackstagedemo` | PostgreSQL Flexible Server | Central US | Standard_B1ms (Burstable) | 16 | Ready |
| `redis-backstage-demo` | Redis Enterprise | East US 2 | Balanced_B0 | - | Running |

### 1.4 Container Registry

| Resource | Location | SKU | Login Server |
|---|---|---|---|
| `acrbackstagedemo` | East US 2 | Basic | `acrbackstagedemo.azurecr.io` |

### 1.5 Security

| Resource | Location | SKU |
|---|---|---|
| `kv-backstage-demo` (Key Vault) | East US 2 | Standard |

### 1.6 AI Services

| Resource | Location | Kind | SKU |
|---|---|---|---|
| `ai-backstage-demo` | East US 2 | AIServices | S0 |

### 1.7 Observability

| Resource | Type | Location | SKU |
|---|---|---|---|
| `grafana-backstage-demo` | Managed Grafana | East US 2 | Standard |
| `prometheus-backstage-demo` | Azure Monitor (Prometheus) | East US 2 | - |
| `law-backstage-demo` | Log Analytics Workspace | East US 2 | PerGB2018 (30-day retention) |
| `appi-backstage-demo` | Application Insights | East US 2 | - |

### 1.8 Monitoring & Alerts

| Resource | Type |
|---|---|
| `ag-backstage-sre` | Action Group |
| `AKS Node CPU High` | Metric Alert |
| `AKS Node Memory High` | Metric Alert |
| `Failure Anomalies - appi-backstage-demo` | Smart Detector Alert |
| 6x Prometheus Recording Rule Groups | per cluster |
| 2x Data Collection Rules | per cluster |
| 2x Data Collection Endpoints | per cluster |

---

## 2. Registered Resource Providers (25 Required)

All providers are **Registered**:

| Provider | Purpose |
|---|---|
| `Microsoft.ContainerService` | AKS clusters |
| `Microsoft.ContainerRegistry` | ACR |
| `Microsoft.Compute` | VMs, VMSS (AKS node pools) |
| `Microsoft.Network` | VNets, NSGs, Load Balancers, Public IPs |
| `Microsoft.Storage` | Storage accounts |
| `Microsoft.KeyVault` | Key Vault |
| `Microsoft.DBforPostgreSQL` | PostgreSQL Flexible Server |
| `Microsoft.Cache` | Redis Enterprise |
| `Microsoft.CognitiveServices` | Azure AI Services |
| `Microsoft.OperationalInsights` | Log Analytics |
| `Microsoft.Monitor` | Azure Monitor (Prometheus) |
| `Microsoft.Dashboard` | Managed Grafana |
| `Microsoft.ManagedIdentity` | Managed Identities |
| `Microsoft.AlertsManagement` | Prometheus rule groups |
| `microsoft.insights` | Metrics, diagnostics, Application Insights |
| `Microsoft.Security` | Microsoft Defender |
| `Microsoft.Purview` | Data governance |
| `Microsoft.DataProtection` | Backup Vault |
| `Microsoft.Authorization` | RBAC, policies |
| `Microsoft.Resources` | Resource management |
| `Microsoft.PolicyInsights` | Azure Policy compliance |
| `Microsoft.GuestConfiguration` | Guest Configuration |
| `Microsoft.CostManagement` | Cost management |
| `Microsoft.Cdn` | CDN / Front Door |
| `Microsoft.App` | Container Apps |

---

## 3. Current Quota (East US 2)

| Quota | Current Usage | Current Limit | Status |
|---|---|---|---|
| **Total Regional vCPUs** | **20** | **20** | **AT LIMIT** |
| Standard DSv5 Family vCPUs | 10 | 20 | 50% used |
| Standard BS Family vCPUs | 10 | 20 | 50% used |

### Usage Breakdown

- **aks-threehorizons-demo**: 5 nodes x Standard_D2s_v5 (2 vCPUs) = **10 vCPUs** (DSv5 family)
- **aks-backstage-demo**: 5 nodes x Standard_B2s (2 vCPUs) = **10 vCPUs** (BS family)
- **Total**: 20 vCPUs used / 20 limit = **100% utilized**

---

## 4. Quota Increase Request

### Justification

The Three Horizons Agentic DevOps Platform requires additional compute capacity to:
1. Run RHDH (Red Hat Developer Hub) with 5 custom dynamic plugins
2. Support ArgoCD GitOps, Prometheus, Grafana observability stack
3. Handle autoscaling for development workloads and CI/CD runners
4. Ensure high availability with proper node distribution

### Requested Increases

| Quota | Current Limit | Requested Limit | Increase |
|---|---|---|---|
| **Total Regional vCPUs** | 20 | **80** | +60 |
| **Standard DSv5 Family vCPUs** | 20 | **40** | +20 |
| **Standard BS Family vCPUs** | 20 | **40** | +20 |

### New Node Pool Configuration (after quota approval)

| Cluster | VM Size | Min Nodes | Max Nodes | Min vCPUs | Max vCPUs |
|---|---|---|---|---|---|
| `aks-threehorizons-demo` | Standard_D2s_v5 | **10** | **20** | 20 | 40 |
| `aks-backstage-demo` | Standard_B2s | **10** | **20** | 20 | 40 |

---

## 5. How to Request Quota Increase

### Option A: Azure Portal (Recommended)

1. Go to **Azure Portal** > **Subscriptions** > `Visual Studio Enterprise Subscription`
2. Click **Usage + quotas** in the left menu
3. Filter by **Location: East US 2** and **Provider: Microsoft.Compute**
4. Find each quota and click the pencil icon to request an increase:
   - **Total Regional vCPUs**: Request **80**
   - **Standard DSv5 Family vCPUs**: Request **40**
   - **Standard BS Family vCPUs**: Request **40**
5. Fill in the justification and submit

**Direct link**: https://portal.azure.com/#view/Microsoft_Azure_Capacity/QuotaMenuBlade/~/myQuotas

### Option B: Azure Support Request

1. Go to **Azure Portal** > **Help + Support** > **New support request**
2. Select:
   - Issue type: **Service and subscription limits (quotas)**
   - Subscription: `Visual Studio Enterprise Subscription`
   - Quota type: **Compute-VM (cores-vCPUs) subscription limit increases**
3. Enter the 3 quota increases listed above
4. Submit

---

## 6. Post-Quota Commands

After the quota increase is approved, run these commands to update AKS node pools:

```bash
# Update aks-threehorizons-demo: min 10, max 20
az aks nodepool update \
  --resource-group rg-threehorizons-demo \
  --cluster-name aks-threehorizons-demo \
  --name nodepool1 \
  --min-count 10 \
  --max-count 20 \
  --enable-cluster-autoscaler

# Update aks-backstage-demo: min 10, max 20
az aks nodepool update \
  --resource-group rg-backstage-demo \
  --cluster-name aks-backstage-demo \
  --name nodepool1 \
  --min-count 10 \
  --max-count 20 \
  --enable-cluster-autoscaler
```

### Verify After Update

```bash
# Check node pool configs
az aks nodepool show --resource-group rg-threehorizons-demo --cluster-name aks-threehorizons-demo --name nodepool1 --query "{minCount:minCount, maxCount:maxCount, count:count}" -o table
az aks nodepool show --resource-group rg-backstage-demo --cluster-name aks-backstage-demo --name nodepool1 --query "{minCount:minCount, maxCount:maxCount, count:count}" -o table

# Check current quota usage
az vm list-usage --location eastus2 -o table | grep -E "Total Regional|DSv5|BS Family"
```
