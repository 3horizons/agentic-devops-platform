---
name: "SRE Agent Setup"
version: "1.0.0"
horizon: "H3"
status: "stable"
last_updated: "2025-12-15"
mcp_servers:
  - azure
  - kubernetes
dependencies:
  - observability
  - aks-cluster
---

# SRE Agent Setup

## 🤖 Agent Identity

```yaml
name: sre-agent-setup
version: 1.0.0
horizon: H3 - Innovation
description: |
  Configures Azure SRE Agent for autonomous operations.
  Enables self-healing, auto-remediation, and intelligent
  incident response across AKS workloads.
  
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
| **Enable SRE Agent** | Configure Azure SRE Agent | Medium |
| **Onboard Applications** | Register apps for monitoring | Low |
| **Configure Runbooks** | Auto-remediation playbooks | Medium |
| **Setup Escalations** | Alert routing and escalation | Low |
| **Enable Auto-healing** | Self-healing policies | Medium |
| **Configure Guardrails** | Safety limits and approvals | Low |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "azure": {
      "required": true,
      "capabilities": [
        "az sre-agent",
        "az monitor"
      ]
    },
    "kubernetes": {
      "required": true
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
primary_label: "agent:sre-agent"
required_labels:
  - horizon:h3
```

---

## 📋 Issue Template

```markdown
---
title: "[H3] Setup SRE Agent - {PROJECT_NAME}"
labels: agent:sre-agent, horizon:h3, env:dev
---

## Prerequisites
- [ ] AKS cluster running
- [ ] Observability stack deployed
- [ ] AI Foundry configured (optional)

## Configuration

```yaml
sre_agent:
  name: "${PROJECT}-sre-agent"
  
  # Applications to monitor
  applications:
    - name: "api-service"
      namespace: "production"
      type: "deployment"
      criticality: "high"
      
    - name: "web-frontend"
      namespace: "production"
      type: "deployment"
      criticality: "medium"
      
  # Auto-remediation policies
  remediation:
    enabled: true
    policies:
      - name: "restart-crashing-pods"
        trigger: "PodCrashLooping"
        action: "restart"
        max_retries: 3
        cooldown: "5m"
        
      - name: "scale-on-high-cpu"
        trigger: "HighCPUUsage"
        action: "scale"
        scale_up_by: 1
        max_replicas: 10
        cooldown: "10m"
        
      - name: "rollback-failed-deploy"
        trigger: "DeploymentFailed"
        action: "rollback"
        require_approval: true
        
  # Guardrails
  guardrails:
    require_approval:
      - "delete"
      - "rollback"
      - "scale_down"
    max_scale: 20
    blackout_windows:
      - day: "friday"
        after: "18:00"
        until: "monday 09:00"
        
  # Escalation
  escalation:
    primary: "oncall-team"
    secondary: "platform-leads"
    timeout: "15m"
    
  # Notifications
  notifications:
    teams:
      webhook: ""
    pagerduty:
      api_key: ""
```

## Acceptance Criteria
- [ ] SRE Agent enabled on AKS
- [ ] Applications onboarded
- [ ] Remediation policies active
- [ ] Test auto-heal triggered
- [ ] Escalations working
```

---

## 🛠️ Configuration Commands

### Enable SRE Agent

```bash
# Enable SRE Agent on AKS (Preview)
az aks update \
  --name ${AKS_NAME} \
  --resource-group ${RG_NAME} \
  --enable-sre-agent

# Verify status
az aks show \
  --name ${AKS_NAME} \
  --resource-group ${RG_NAME} \
  --query "sreAgentProfile"
```

### Onboard Applications

```bash
# Register application for monitoring
az sre-agent application create \
  --name "api-service" \
  --resource-group ${RG_NAME} \
  --cluster-name ${AKS_NAME} \
  --namespace "production" \
  --resource-type "deployment" \
  --criticality "high"
```

### Configure Remediation

```yaml
# remediation-policy.yaml
apiVersion: sreagent.azure.com/v1beta1
kind: RemediationPolicy
metadata:
  name: restart-crashing-pods
  namespace: sre-agent
spec:
  trigger:
    type: alert
    alertName: "PodCrashLooping"
    severity: critical
  action:
    type: restart
    target:
      kind: Pod
      labelSelector:
        app: "{{ .labels.app }}"
  constraints:
    maxRetries: 3
    cooldownPeriod: 5m
    requireApproval: false
```

### Test Auto-healing

```bash
# Simulate pod crash
kubectl delete pod -l app=api-service -n production

# Watch SRE Agent response
kubectl logs -n sre-agent -l app=sre-agent -f

# Check remediation history
az sre-agent remediation list \
  --resource-group ${RG_NAME} \
  --cluster-name ${AKS_NAME}
```

---

## 📊 Monitoring Dashboard

```json
{
  "dashboard": {
    "title": "SRE Agent Operations",
    "panels": [
      {
        "title": "Remediations (24h)",
        "query": "sre_agent_remediation_total{status=~\"success|failed\"}"
      },
      {
        "title": "Auto-heal Actions",
        "query": "sre_agent_actions_total"
      },
      {
        "title": "MTTR by Application",
        "query": "avg(sre_agent_mttr_seconds) by (application)"
      },
      {
        "title": "Agent Decisions",
        "query": "sre_agent_decisions_total"
      }
    ]
  }
}
```

---

## 💰 Cost Considerations

| Component | Cost Model | Estimate |
|-----------|------------|----------|
| SRE Agent | AAU-based | ~$300-1500/mo |
| Always-on monitoring | 4 AAU/hour | $288/mo base |
| Active operations | 0.25 AAU/sec | Variable |

---

## ✅ Validation Criteria

```yaml
validation:
  agent:
    - enabled: true
    - status: "Running"
    
  applications:
    - onboarded_count: ">= 1"
    - health_status: "healthy"
    
  remediation:
    - policies_active: true
    - test_trigger: "successful"
    
  escalation:
    - routes_configured: true
    - test_alert: "delivered"
```

---

## 💬 Agent Communication

### On Success
```markdown
✅ **SRE Agent Configured**

**Status:** ✅ Running

**Applications Monitored:**
| App | Namespace | Criticality |
|-----|-----------|-------------|
| api-service | production | High |
| web-frontend | production | Medium |

**Remediation Policies:**
- ✅ restart-crashing-pods
- ✅ scale-on-high-cpu
- ✅ rollback-failed-deploy (approval required)

**Guardrails:**
- Max scale: 20 replicas
- Blackout: Fri 18:00 → Mon 09:00

**Estimated Cost:** ~$400/month

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `observability-agent` | **Prerequisite** |
| `ai-foundry-agent` | **Optional** |
| `validation-agent` | **Post** |

---

**Spec Version:** 1.0.0
