---
name: observability-stack
description: Prometheus, Grafana, and observability operations
version: "1.0.0"
license: MIT
tools_required: ["kubectl", "promtool"]
---

## When to Use
- Monitoring stack operations
- Prometheus queries
- Grafana dashboard management
- Alert rule configuration

## Prerequisites
- kubectl access to cluster
- Prometheus/Grafana deployed
- Appropriate RBAC permissions

## Commands

### Prometheus Operations
```bash
# Check Prometheus status
kubectl get pods -n monitoring -l app.kubernetes.io/name=prometheus

# Port forward Prometheus
kubectl port-forward -n monitoring svc/prometheus 9090:9090

# Query Prometheus API
curl -s http://localhost:9090/api/v1/query?query=up | jq '.data.result'

# Check targets
curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets | length'
```

### Grafana Operations
```bash
# Check Grafana status
kubectl get pods -n monitoring -l app.kubernetes.io/name=grafana

# Port forward Grafana
kubectl port-forward -n monitoring svc/grafana 3000:3000

# List data sources
curl -s -u admin:admin http://localhost:3000/api/datasources | jq '.[].name'
```

### Alert Management
```bash
# Check alertmanager
kubectl get pods -n monitoring -l app.kubernetes.io/name=alertmanager

# List active alerts
curl -s http://localhost:9093/api/v2/alerts | jq '.[].labels.alertname'

# Validate Prometheus rules
promtool check rules prometheus-rules.yaml
```

## Best Practices
1. Use ServiceMonitors for scrape configuration
2. Set appropriate retention periods
3. Configure alert routing correctly
4. Use recording rules for expensive queries
5. Enable persistent storage for Prometheus

## Output Format
1. Command executed
2. Monitoring status summary
3. Active alerts if any
4. Recommendations

## Integration with Agents
Used by: @observability, @sre
