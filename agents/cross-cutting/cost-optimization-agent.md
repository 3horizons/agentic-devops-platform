---
name: "Cost Optimization Agent"
version: "1.0.0"
horizon: "cross-cutting"
status: "stable"
last_updated: "2025-12-15"
mcp_servers:
  - azure
dependencies:
  - cost-management
---

# Cost Optimization Agent

## 🤖 Agent Identity

```yaml
name: cost-optimization-agent
version: 1.0.0
horizon: Cross-Cutting
description: |
  Analyzes Azure spending, identifies optimization opportunities,
  recommends and implements cost-saving measures. Integrates
  with Azure Cost Management and Advisor.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Analyze Costs** | Current spending analysis | Low |
| **Identify Waste** | Unused/idle resources | Low |
| **Right-size VMs** | VM SKU optimization | Medium |
| **Reserved Instances** | RI recommendations | Medium |
| **AKS Optimization** | Node pool optimization | Medium |
| **Storage Tiering** | Blob/disk optimization | Low |
| **Implement Savings** | Apply recommendations | Medium |
| **Budget Alerts** | Setup cost alerts | Low |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "azure": {
      "required": true,
      "capabilities": [
        "az consumption",
        "az advisor",
        "az cost",
        "az vm",
        "az aks",
        "az storage"
      ]
    },
    "kubernetes": {
      "required": true,
      "capabilities": ["kubectl top"]
    },
    "github": {
      "required": true
    }
  }
}
```

---

## 🏷️ Trigger Labels

```yaml
primary_label: "agent:cost-optimization"

trigger_labels:
  - trigger:scheduled      # Weekly/monthly analysis
  - trigger:budget-alert   # Budget threshold triggered
  - trigger:manual        # On-demand analysis
```

---

## 📋 Issue Template

```markdown
---
title: "[FinOps] Cost Optimization Analysis - {PROJECT_NAME}"
labels: agent:cost-optimization, priority:normal
---

## Scope

```yaml
cost_analysis:
  subscription_id: "${SUBSCRIPTION_ID}"
  resource_groups:
    - "${PROJECT}-dev-rg"
    - "${PROJECT}-staging-rg"
    - "${PROJECT}-prod-rg"
    
  # Analysis period
  period:
    start: "2024-01-01"
    end: "2024-12-31"
    
  # Focus areas
  analyze:
    - compute           # VMs, AKS nodes
    - storage           # Disks, blobs
    - networking        # Bandwidth, IPs
    - databases         # SQL, PostgreSQL, Cosmos
    - ai_services       # OpenAI, Foundry
    
  # Thresholds
  thresholds:
    cpu_utilization_min: 20     # Flag if below
    memory_utilization_min: 30  # Flag if below
    disk_utilization_min: 40    # Flag if below
    idle_days: 7                # Flag if idle > days
    
  # Actions
  actions:
    auto_implement:
      - "delete_orphaned_disks"
      - "release_unused_ips"
    require_approval:
      - "resize_vms"
      - "resize_aks_nodes"
      - "purchase_reserved_instances"
      
  # Budget
  budget:
    monthly_limit: 50000
    alert_thresholds: [50, 75, 90, 100]
```

## Deliverables
- [ ] Cost breakdown by service
- [ ] Optimization recommendations
- [ ] Savings estimate
- [ ] Implementation plan
- [ ] Budget alerts configured
```

---

## 🛠️ Analysis Commands

### Cost Breakdown

```bash
# Get current month costs
az consumption usage list \
  --subscription ${SUBSCRIPTION_ID} \
  --start-date $(date -d "$(date +%Y-%m-01)" +%Y-%m-%d) \
  --end-date $(date +%Y-%m-%d) \
  --query "[].{Service:consumedService, Cost:pretaxCost, Currency:currency}" \
  -o table

# Cost by resource group
az cost management query \
  --type "ActualCost" \
  --timeframe "MonthToDate" \
  --dataset-aggregation '{"totalCost":{"name":"Cost","function":"Sum"}}' \
  --dataset-grouping name="ResourceGroup" type="Dimension"

# Top 10 costly resources
az consumption usage list \
  --subscription ${SUBSCRIPTION_ID} \
  --start-date $(date -d "-30 days" +%Y-%m-%d) \
  --end-date $(date +%Y-%m-%d) \
  --query "sort_by([].{Resource:instanceName, Cost:pretaxCost}, &Cost)[-10:]" \
  -o table
```

### Azure Advisor Recommendations

```bash
# Get cost recommendations
az advisor recommendation list \
  --category Cost \
  --query "[].{Impact:impact, Problem:shortDescription.problem, Solution:shortDescription.solution, Savings:extendedProperties.annualSavingsAmount}" \
  -o table

# Get all recommendations
az advisor recommendation list \
  --query "[?category=='Cost'].{Resource:resourceMetadata.resourceId, Savings:extendedProperties.annualSavingsAmount, Action:shortDescription.solution}"
```

### Compute Analysis

```bash
# List underutilized VMs
az monitor metrics list \
  --resource $(az vm show -n ${VM_NAME} -g ${RG_NAME} --query id -o tsv) \
  --metric "Percentage CPU" \
  --interval PT1H \
  --start-time $(date -d "-7 days" -u +%Y-%m-%dT%H:%M:%SZ) \
  --aggregation Average \
  --query "value[0].timeseries[0].data[].average"

# AKS node utilization
kubectl top nodes --no-headers | awk '{print $1, $3, $5}'

# Identify idle AKS nodes
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.allocatable.cpu,PODS:.status.capacity.pods
```

### Storage Analysis

```bash
# Find orphaned disks
az disk list \
  --query "[?diskState=='Unattached'].{Name:name, Size:diskSizeGb, SKU:sku.name, RG:resourceGroup}" \
  -o table

# Find unattached public IPs
az network public-ip list \
  --query "[?ipConfiguration==null].{Name:name, RG:resourceGroup}" \
  -o table

# Storage account analysis
az storage account list \
  --query "[].{Name:name, SKU:sku.name, Kind:kind, AccessTier:accessTier}" \
  -o table
```

### Database Analysis

```bash
# PostgreSQL DTU/vCore usage
az postgres flexible-server show \
  --name ${POSTGRES_NAME} \
  --resource-group ${RG_NAME} \
  --query "{SKU:sku.name, Storage:storage.storageSizeGb}"

# Cosmos DB RU analysis
az cosmosdb show \
  --name ${COSMOS_NAME} \
  --resource-group ${RG_NAME} \
  --query "{Throughput:capabilities}"
```

---

## 💰 Optimization Actions

### Delete Orphaned Resources

```bash
# Delete unattached disks (with approval)
ORPHANED_DISKS=$(az disk list --query "[?diskState=='Unattached'].id" -o tsv)
for disk in $ORPHANED_DISKS; do
  echo "Deleting orphaned disk: $disk"
  az disk delete --ids $disk --yes
done

# Release unused public IPs
UNUSED_IPS=$(az network public-ip list --query "[?ipConfiguration==null].id" -o tsv)
for ip in $UNUSED_IPS; do
  echo "Deleting unused IP: $ip"
  az network public-ip delete --ids $ip
done
```

### Right-size VMs

```bash
# Resize VM (requires approval)
az vm resize \
  --resource-group ${RG_NAME} \
  --name ${VM_NAME} \
  --size Standard_D2s_v5  # Smaller SKU

# Update AKS node pool
az aks nodepool update \
  --resource-group ${RG_NAME} \
  --cluster-name ${AKS_NAME} \
  --name ${NODEPOOL_NAME} \
  --node-count 2  # Reduce count
```

### Configure Budgets

```bash
# Create budget
az consumption budget create \
  --budget-name "${PROJECT}-monthly-budget" \
  --amount 50000 \
  --time-grain Monthly \
  --start-date $(date +%Y-%m-01) \
  --end-date $(date -d "+1 year" +%Y-%m-01) \
  --resource-group ${RG_NAME}

# Add budget alerts
az consumption budget create \
  --budget-name "${PROJECT}-monthly-budget" \
  --amount 50000 \
  --time-grain Monthly \
  --notifications '{
    "Actual_GreaterThan_50_Percent": {
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": 50,
      "contactEmails": ["platform-team@company.com"],
      "thresholdType": "Actual"
    },
    "Actual_GreaterThan_90_Percent": {
      "enabled": true,
      "operator": "GreaterThan",
      "threshold": 90,
      "contactEmails": ["platform-leads@company.com"],
      "thresholdType": "Actual"
    }
  }'
```

---

## 📊 Cost Report Template

```yaml
cost_report:
  metadata:
    generated: "2024-12-10T10:00:00Z"
    period: "2024-11-01 to 2024-11-30"
    subscription: "${SUBSCRIPTION_ID}"
    
  summary:
    total_cost: 45000
    budget: 50000
    utilization: "90%"
    trend: "+5% MoM"
    
  breakdown_by_service:
    - service: "Virtual Machines"
      cost: 15000
      percentage: 33%
    - service: "Azure Kubernetes Service"
      cost: 12000
      percentage: 27%
    - service: "Storage"
      cost: 5000
      percentage: 11%
    - service: "Azure OpenAI"
      cost: 8000
      percentage: 18%
    - service: "Other"
      cost: 5000
      percentage: 11%
      
  recommendations:
    - category: "Compute"
      finding: "3 VMs underutilized (<20% CPU)"
      action: "Right-size to smaller SKU"
      savings: 2500
      effort: "Low"
      
    - category: "Storage"
      finding: "5 orphaned disks"
      action: "Delete unused disks"
      savings: 500
      effort: "Low"
      
    - category: "Reserved Instances"
      finding: "Stable AKS workload"
      action: "Purchase 1-year RI"
      savings: 4000
      effort: "Medium"
      
  total_potential_savings: 7000
  savings_percentage: "15.5%"
```

---

## ✅ Validation Criteria

```yaml
validation:
  analysis:
    - cost_data_retrieved: true
    - advisor_queried: true
    - utilization_metrics: true
    
  recommendations:
    - generated: true
    - savings_calculated: true
    
  actions:
    - orphaned_resources_cleaned: true
    - budgets_configured: true
    - alerts_active: true
    
  report:
    - generated: true
    - stakeholders_notified: true
```

---

## 💬 Agent Communication

### On Analysis Complete
```markdown
✅ **Cost Optimization Analysis Complete**

**Period:** November 2024
**Total Spend:** $45,000 / $50,000 budget (90%)

**Top Cost Drivers:**
| Service | Cost | % |
|---------|------|---|
| Virtual Machines | $15,000 | 33% |
| AKS | $12,000 | 27% |
| Azure OpenAI | $8,000 | 18% |
| Storage | $5,000 | 11% |

**Optimization Opportunities:**

| Finding | Action | Savings | Status |
|---------|--------|---------|--------|
| 3 underutilized VMs | Right-size | $2,500/mo | ⏳ Approval required |
| 5 orphaned disks | Delete | $500/mo | ✅ Implemented |
| 2 unused public IPs | Release | $100/mo | ✅ Implemented |
| Stable AKS workload | Reserve instances | $4,000/mo | ⏳ Approval required |

**Total Potential Savings:** $7,100/month (15.8%)

**Budget Alerts:** ✅ Configured (50%, 75%, 90%, 100%)

**Next Analysis:** 2024-12-10

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `validation-agent` | **Triggers** cost analysis |
| `infrastructure-agent` | **Receives** resize recommendations |
| All agents | **Informs** resource decisions |

---

**Spec Version:** 1.0.0
