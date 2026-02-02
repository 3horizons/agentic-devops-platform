````skill
---
name: observability-stack
description: 'Observability stack operations for Three Horizons Accelerator. Use when deploying Prometheus, Grafana, alerting, dashboards. Covers monitoring setup, metrics collection, log aggregation, alerting rules, dashboard provisioning, SLI/SLO configuration.'
license: Complete terms in LICENSE.txt
---

# Observability Stack Skill

Comprehensive skill for deploying and managing the observability stack in the Three Horizons Accelerator platform.

**Version:** 1.0.0

---

## Overview

This skill encapsulates all tools required for observability operations:
- **MCP Servers**: kubernetes, helm
- **Scripts**: validate-deployment.sh
- **Terraform Modules**: observability
- **Helm Charts**: kube-prometheus-stack, grafana
- **Dashboards**: grafana/dashboards/
- **Alerting**: prometheus/alerting-rules.yaml

---

## MCP Server Configuration

### Kubernetes MCP Server

```json
{
  "kubernetes": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-kubernetes"],
    "env": {
      "KUBECONFIG": "${KUBECONFIG}"
    },
    "capabilities": [
      "kubectl get",
      "kubectl apply",
      "kubectl logs",
      "kubectl port-forward"
    ]
  }
}
```

### Helm MCP Server

```json
{
  "helm": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-helm"],
    "capabilities": [
      "helm install",
      "helm upgrade",
      "helm repo",
      "helm template"
    ]
  }
}
```

---

## Core Components

### Prometheus Stack Deployment

```bash
# Add Helm repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install kube-prometheus-stack (includes Prometheus, Grafana, Alertmanager)
helm upgrade --install kube-prometheus-stack \
  prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --version 56.0.0 \
  -f deploy/helm/monitoring/values.yaml
```

### Values Configuration

**Path:** `deploy/helm/monitoring/values.yaml`

```yaml
prometheus:
  prometheusSpec:
    retention: 30d
    retentionSize: "50GB"
    resources:
      requests:
        cpu: 500m
        memory: 2Gi
      limits:
        cpu: 2000m
        memory: 8Gi
    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: managed-premium
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 100Gi
    serviceMonitorSelectorNilUsesHelmValues: false
    podMonitorSelectorNilUsesHelmValues: false
    ruleSelectorNilUsesHelmValues: false

grafana:
  enabled: true
  adminPassword: ${GRAFANA_ADMIN_PASSWORD}
  persistence:
    enabled: true
    size: 10Gi
    storageClassName: managed-premium
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - grafana.${DOMAIN}
    tls:
      - secretName: grafana-tls
        hosts:
          - grafana.${DOMAIN}
  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
        - name: 'default'
          orgId: 1
          folder: 'Three Horizons'
          type: file
          disableDeletion: false
          editable: true
          options:
            path: /var/lib/grafana/dashboards/default

alertmanager:
  enabled: true
  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: managed-premium
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 10Gi
  config:
    global:
      resolve_timeout: 5m
    route:
      group_by: ['alertname', 'severity']
      group_wait: 30s
      group_interval: 5m
      repeat_interval: 4h
      receiver: 'default-receiver'
      routes:
        - match:
            severity: critical
          receiver: 'pagerduty'
        - match:
            severity: warning
          receiver: 'slack'
    receivers:
      - name: 'default-receiver'
      - name: 'slack'
        slack_configs:
          - api_url: '${SLACK_WEBHOOK_URL}'
            channel: '#alerts'
      - name: 'pagerduty'
        pagerduty_configs:
          - service_key: '${PAGERDUTY_SERVICE_KEY}'
```

---

## Alerting Rules

**Path:** `prometheus/alerting-rules.yaml`

```yaml
groups:
  - name: kubernetes-alerts
    rules:
      - alert: KubePodCrashLooping
        expr: |
          max_over_time(kube_pod_container_status_waiting_reason{reason="CrashLoopBackOff"}[5m]) > 0
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is crash looping"
          
      - alert: KubePodNotReady
        expr: |
          sum by (namespace, pod) (
            max by (namespace, pod) (kube_pod_status_phase{phase=~"Pending|Unknown"}) * 
            on(namespace, pod) group_left(owner_kind) max by (namespace, pod, owner_kind) (kube_pod_owner{owner_kind!="Job"})
          ) > 0
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Pod {{ $labels.namespace }}/{{ $labels.pod }} is not ready"

      - alert: KubeDeploymentReplicasMismatch
        expr: |
          kube_deployment_spec_replicas != kube_deployment_status_available_replicas
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Deployment {{ $labels.namespace }}/{{ $labels.deployment }} has mismatched replicas"

  - name: node-alerts
    rules:
      - alert: NodeHighCPU
        expr: |
          100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Node {{ $labels.instance }} CPU usage is above 80%"

      - alert: NodeHighMemory
        expr: |
          (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 85
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Node {{ $labels.instance }} memory usage is above 85%"

      - alert: NodeDiskPressure
        expr: |
          (1 - (node_filesystem_avail_bytes{fstype!~"tmpfs|fuse.lxcfs"} / node_filesystem_size_bytes)) * 100 > 85
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "Node {{ $labels.instance }} disk usage is above 85%"

  - name: argocd-alerts
    rules:
      - alert: ArgoCDAppOutOfSync
        expr: |
          argocd_app_info{sync_status!="Synced"} == 1
        for: 15m
        labels:
          severity: warning
        annotations:
          summary: "ArgoCD app {{ $labels.name }} is out of sync"

      - alert: ArgoCDAppDegraded
        expr: |
          argocd_app_info{health_status="Degraded"} == 1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "ArgoCD app {{ $labels.name }} is degraded"
```

---

## Recording Rules

**Path:** `prometheus/recording-rules.yaml`

```yaml
groups:
  - name: sli-recording-rules
    rules:
      # Availability SLI
      - record: sli:availability:ratio
        expr: |
          sum(rate(http_requests_total{code!~"5.."}[5m])) /
          sum(rate(http_requests_total[5m]))

      # Latency SLI (P50, P90, P99)
      - record: sli:latency:p50
        expr: |
          histogram_quantile(0.50, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

      - record: sli:latency:p90
        expr: |
          histogram_quantile(0.90, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

      - record: sli:latency:p99
        expr: |
          histogram_quantile(0.99, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

      # Error budget
      - record: sli:error_budget:remaining
        expr: |
          1 - ((1 - sli:availability:ratio) / (1 - 0.999))
```

---

## Grafana Dashboards

### Dashboard Provisioning

**Path:** `grafana/dashboards/`

```bash
# Structure
grafana/dashboards/
├── kubernetes-cluster-overview.json
├── kubernetes-pods.json
├── argocd-overview.json
├── application-metrics.json
└── slo-overview.json
```

### Dashboard Configuration

```yaml
# ConfigMap for dashboard provisioning
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboards
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  kubernetes-overview.json: |-
    {
      "title": "Kubernetes Cluster Overview",
      "tags": ["kubernetes", "three-horizons"],
      "panels": [...]
    }
```

---

## ServiceMonitor Configuration

```yaml
# Application ServiceMonitor
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-app
  namespace: monitoring
  labels:
    release: kube-prometheus-stack
spec:
  selector:
    matchLabels:
      app: my-app
  namespaceSelector:
    matchNames:
      - my-app-namespace
  endpoints:
    - port: metrics
      path: /metrics
      interval: 30s
```

---

## Terraform Module Reference

**Path:** `terraform/modules/observability/`

```hcl
module "observability" {
  source = "./modules/observability"

  cluster_name        = var.cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  
  prometheus = {
    enabled           = true
    retention_days    = 30
    storage_size_gb   = 100
  }
  
  grafana = {
    enabled        = true
    admin_password = var.grafana_admin_password
    ingress_host   = "grafana.${var.domain}"
  }
  
  alertmanager = {
    enabled      = true
    slack_url    = var.slack_webhook_url
    pagerduty_key = var.pagerduty_key
  }
  
  tags = local.tags
}
```

---

## Common Operations

### Port Forward to Grafana

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana \
  -n monitoring 3000:80
```

### Port Forward to Prometheus

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus \
  -n monitoring 9090:9090
```

### Check Prometheus Targets

```bash
# Get Prometheus targets status
kubectl exec -it -n monitoring \
  $(kubectl get pod -n monitoring -l app.kubernetes.io/name=prometheus -o name | head -1) \
  -- wget -qO- http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length'
```

### Reload Prometheus Configuration

```bash
# Kill Prometheus pod to reload config
kubectl delete pod -n monitoring \
  -l app.kubernetes.io/name=prometheus
```

### Query Prometheus Metrics

```bash
# Using PromQL via curl
kubectl exec -it -n monitoring \
  $(kubectl get pod -n monitoring -l app.kubernetes.io/name=prometheus -o name | head -1) \
  -- wget -qO- 'http://localhost:9090/api/v1/query?query=up' | jq
```

---

## Error Handling

### Common Errors and Solutions

#### ServiceMonitor Not Discovered

```bash
# Error: Metrics not appearing in Prometheus
# Solution: Verify labels match selector

kubectl get servicemonitor -A -o yaml | grep -A5 "selector"
kubectl get svc -n ${NAMESPACE} -l ${LABEL_SELECTOR}
```

#### Prometheus Storage Full

```bash
# Error: prometheus: failed to compact head block
# Solution: Increase PVC or reduce retention

kubectl patch prometheus kube-prometheus-stack-prometheus \
  -n monitoring \
  --type merge \
  -p '{"spec":{"retention":"15d"}}'
```

#### Alertmanager Not Sending Alerts

```bash
# Check Alertmanager configuration
kubectl get secret alertmanager-kube-prometheus-stack-alertmanager \
  -n monitoring \
  -o jsonpath='{.data.alertmanager\.yaml}' | base64 -d

# Check Alertmanager logs
kubectl logs -n monitoring \
  -l app.kubernetes.io/name=alertmanager
```

---

## Pre-Deployment Checklist

- [ ] Storage class configured for persistent volumes
- [ ] Ingress controller installed for Grafana access
- [ ] TLS certificates configured (cert-manager)
- [ ] Slack/PagerDuty webhooks configured
- [ ] Network policies allow scraping
- [ ] RBAC for service accounts configured

## Post-Deployment Validation

```bash
# Validate monitoring stack
kubectl get pods -n monitoring

# Check Prometheus status
kubectl get prometheus -n monitoring

# Check ServiceMonitors
kubectl get servicemonitor -A

# Check PrometheusRules
kubectl get prometheusrules -A

# Validate Grafana accessibility
curl -I https://grafana.${DOMAIN}
```

---

## Related Skills

- [kubectl-cli](../kubectl-cli/) - Kubernetes CLI reference
- [helm-cli](../helm-cli/) - Helm CLI reference
- [argocd-cli](../argocd-cli/) - ArgoCD CLI reference

---

## References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Prometheus Operator](https://prometheus-operator.dev/)

````
