# Observability Agent

## 🤖 Agent Identity

```yaml
name: observability-agent
version: 1.0.0
horizon: H2 - Enhancement
description: |
  Deploys and configures the observability stack on AKS.
  Installs Prometheus, Grafana, Alertmanager, and Loki.
  Creates dashboards, alerts, and notification channels.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 📁 Terraform Module
**Primary Module:** `terraform/modules/observability/main.tf`

## 📋 Related Resources
| Resource Type | Path |
|--------------|------|
| Terraform Module | `terraform/modules/observability/main.tf` |
| Issue Template | `.github/ISSUE_TEMPLATE/observability.yml` |
| Grafana Dashboard | `grafana/dashboards/golden-path-application.json` |
| Prometheus Rules | `prometheus/alerting-rules.yaml` |
| Sizing Config | `config/sizing-profiles.yaml` |

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Install Prometheus** | Deploy Prometheus via Helm | Medium |
| **Install Grafana** | Deploy Grafana with dashboards | Medium |
| **Install Alertmanager** | Configure alert routing | Low |
| **Install Loki** | Deploy log aggregation | Medium |
| **Create Dashboards** | Import/create Grafana dashboards | Low |
| **Configure Alerts** | Setup Prometheus alert rules | Low |
| **Configure Notifications** | Teams, Slack, PagerDuty | Low |
| **Enable Azure Monitor** | Azure-native integration | Medium |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "kubernetes": {
      "required": true,
      "capabilities": ["kubectl apply", "kubectl get", "helm install"]
    },
    "helm": {
      "required": true,
      "capabilities": ["helm repo add", "helm install", "helm upgrade"]
    },
    "github": {
      "required": true
    },
    "filesystem": {
      "required": true
    }
  }
}
```

---

## 🏷️ Trigger Labels

```yaml
primary_label: "agent:observability"
required_labels:
  - horizon:h2
environment_labels:
  - env:dev
  - env:staging
  - env:prod
```

---

## 📋 Issue Template

```markdown
---
title: "[H2] Setup Observability - {PROJECT_NAME}"
labels: agent:observability, horizon:h2, env:dev
---

## Configuration

```yaml
observability:
  prometheus:
    enabled: true
    retention: "15d"
    storage_size: "50Gi"
    
  grafana:
    enabled: true
    admin_password: "${GRAFANA_ADMIN_PASSWORD}"
    dashboards:
      - kubernetes-cluster
      - node-exporter
      - argocd
      - aks-monitoring
      - ai-apps
      
  alertmanager:
    enabled: true
    routes:
      - match:
          severity: critical
        receiver: pagerduty
      - match:
          severity: warning
        receiver: teams
        
  loki:
    enabled: true
    retention: "7d"
    
  notifications:
    teams:
      enabled: true
      webhook_url: ""
    slack:
      enabled: false
    pagerduty:
      enabled: false
```

## Acceptance Criteria
- [ ] Prometheus running and scraping targets
- [ ] Grafana accessible with dashboards
- [ ] Alertmanager configured
- [ ] Test alert fires correctly
```

---

## 🛠️ Installation Commands

```bash
# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Create namespace
kubectl create namespace monitoring

# Install kube-prometheus-stack (Prometheus + Grafana + Alertmanager)
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values prometheus-values.yaml \
  --wait --timeout 10m

# Install Loki
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --values loki-values.yaml \
  --wait

# Verify
kubectl get pods -n monitoring
kubectl get svc -n monitoring
```

---

## 📊 Pre-configured Dashboards

| Dashboard | ID | Description |
|-----------|-----|-------------|
| Kubernetes Cluster | 7249 | Cluster overview |
| Node Exporter | 1860 | Node metrics |
| ArgoCD | 14584 | ArgoCD monitoring |
| AKS Monitoring | 18283 | Azure AKS specific |
| AI Applications | Custom | AI/ML workloads |

---

## 🔔 Alert Rules Included

| Alert | Severity | Description |
|-------|----------|-------------|
| `HighCPUUsage` | warning | Node CPU > 80% |
| `HighMemoryUsage` | warning | Node Memory > 85% |
| `PodCrashLooping` | critical | Pod restart > 5 |
| `DeploymentReplicasMismatch` | warning | Replicas != desired |
| `PersistentVolumeFillingUp` | warning | PV > 85% full |
| `KubeAPILatency` | warning | API latency > 1s |

---

**Spec Version:** 1.0.0
