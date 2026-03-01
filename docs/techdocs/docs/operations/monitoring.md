# Monitoring & Observability

The Three Horizons platform provides comprehensive observability through **Prometheus**, **Grafana**, **Alertmanager**, and **Jaeger**, all deployed on AKS and managed via ArgoCD. Azure-native monitoring is provided by **Container Insights** and **Azure Managed Grafana**.

---

## Architecture

```
Applications ----> Prometheus (scrape metrics every 30s)
                       |
                       +--> Recording Rules (pre-calculate aggregations)
                       |
                       +--> Alerting Rules (evaluate conditions)
                       |         |
                       |         v
                       |    Alertmanager (route, group, silence alerts)
                       |         |
                       |         +--> Slack (#platform-alerts)
                       |         +--> PagerDuty (SEV-1/SEV-2)
                       |         +--> Email (SEV-3/SEV-4)
                       |
                       +--> Grafana (dashboards, exploration)

Applications ----> Jaeger Collector (receive traces)
                       |
                       v
                  Jaeger Query (search, visualize traces)

AKS Cluster -----> Container Insights (Azure Monitor)
                       |
                       v
                  Log Analytics Workspace
```

---

## Prometheus

Prometheus collects metrics from all platform components and applications via ServiceMonitor resources. It is deployed by the `observability` Terraform module via the kube-prometheus-stack Helm chart.

### Configured ServiceMonitors

| Target | Port | Path | Scrape Interval |
|--------|------|------|-----------------|
| RHDH | 7007 | /metrics | 30s |
| ArgoCD Server | 8083 | /metrics | 30s |
| ArgoCD Repo Server | 8084 | /metrics | 30s |
| ArgoCD Application Controller | 8082 | /metrics | 30s |
| ingress-nginx | 10254 | /metrics | 30s |
| cert-manager | 9402 | /metrics | 60s |
| External Secrets Operator | 8080 | /metrics | 60s |
| kube-state-metrics | 8080 | /metrics | 30s |
| node-exporter | 9100 | /metrics | 30s |

### Alerting Rules (50+)

Alerts are organized by category with severity levels (`critical`, `warning`, `info`). All rules are defined in `prometheus/alerting-rules.yaml`.

#### Infrastructure Alerts

| Alert | Condition | Severity | For |
|-------|-----------|----------|-----|
| `HighCPUUsage` | Node CPU > 80% | Warning | 10 min |
| `CriticalCPUUsage` | Node CPU > 95% | Critical | 5 min |
| `HighMemoryUsage` | Node memory > 85% | Warning | 10 min |
| `CriticalMemoryUsage` | Node memory > 95% | Critical | 5 min |
| `DiskSpaceLow` | Disk usage > 90% | Warning | 15 min |
| `DiskSpaceCritical` | Disk usage > 95% | Critical | 5 min |
| `NodeNotReady` | Node unready | Critical | 5 min |
| `PodCrashLooping` | Pod restarts > 5 in 10 min | Warning | 10 min |
| `PodOOMKilled` | Container OOMKilled | Warning | 0 min |
| `PersistentVolumeFillingUp` | PV usage > 85% | Warning | 15 min |

#### Application Alerts

| Alert | Condition | Severity | For |
|-------|-----------|----------|-----|
| `HighErrorRate` | HTTP 5xx rate > 5% | Warning | 5 min |
| `CriticalErrorRate` | HTTP 5xx rate > 20% | Critical | 2 min |
| `HighLatency` | P99 latency > 2s | Warning | 10 min |
| `CriticalLatency` | P99 latency > 5s | Critical | 5 min |
| `PodNotReady` | Application pod not ready | Warning | 5 min |
| `DeploymentReplicasMismatch` | Desired != available replicas | Warning | 15 min |
| `HPAMaxedOut` | HPA at max replicas for 15 min | Warning | 15 min |

#### AI Agent Alerts

| Alert | Condition | Severity | For |
|-------|-----------|----------|-----|
| `HighTokenUsage` | Token consumption > 80% of budget | Warning | 1 hour |
| `TokenBudgetExceeded` | Token consumption > 100% of budget | Critical | 0 min |
| `LLMHighLatency` | AI model response > 10s | Warning | 5 min |
| `LLMErrorRate` | AI model error rate > 10% | Warning | 5 min |
| `LightspeedUnavailable` | Developer Lightspeed not responding | Critical | 5 min |

#### GitOps Alerts

| Alert | Condition | Severity | For |
|-------|-----------|----------|-----|
| `ArgoSyncFailed` | ArgoCD application sync failure | Warning | 5 min |
| `ArgoAppDegraded` | Application health degraded | Warning | 10 min |
| `ArgoAppMissing` | Expected application not found | Critical | 5 min |
| `ArgoRepoConnectionFailed` | Cannot connect to Git repository | Warning | 5 min |

#### Security Alerts

| Alert | Condition | Severity | For |
|-------|-----------|----------|-----|
| `CertificateExpiring` | TLS cert expires in < 14 days | Warning | 0 min |
| `CertificateExpired` | TLS cert has expired | Critical | 0 min |
| `FailedLoginAttempts` | > 10 failed logins in 5 min | Warning | 5 min |
| `UnauthorizedAPIAccess` | > 5 HTTP 401/403 responses in 1 min | Warning | 1 min |

#### SLO Burn Rate Alerts

Multi-window burn rate detection for balanced speed and accuracy:

| Window | Burn Rate | Action | Severity |
|--------|-----------|--------|----------|
| 5 min | 14.4x | Page on-call immediately | Critical |
| 1 hour | 6x | Page on-call | Critical |
| 24 hours | 3x | Create ticket, investigate | Warning |
| 30 days | 1x | Review in next planning cycle | Info |

```yaml
# Example SLO burn rate alert
- alert: SLOBurnRateFast
  expr: |
    (
      sum(rate(http_requests_total{code=~"5.."}[5m]))
      /
      sum(rate(http_requests_total[5m]))
    ) > (14.4 * (1 - 0.999))
  for: 2m
  labels:
    severity: critical
    slo: availability
  annotations:
    summary: "SLO burn rate is 14.4x in 5-minute window"
    description: "At this rate, the 30-day error budget will be exhausted in 2 hours."
```

### Recording Rules (40+)

Pre-calculated metrics for efficient dashboard queries. All rules are defined in `prometheus/recording-rules.yaml`.

#### Cluster Utilization

```yaml
- record: cluster:cpu_utilization:ratio
  expr: 1 - avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))

- record: cluster:memory_utilization:ratio
  expr: 1 - sum(node_memory_MemAvailable_bytes) / sum(node_memory_MemTotal_bytes)

- record: cluster:disk_utilization:ratio
  expr: 1 - sum(node_filesystem_avail_bytes{mountpoint="/"}) / sum(node_filesystem_size_bytes{mountpoint="/"})
```

#### Application RED Metrics

```yaml
# Request rate
- record: service:http_requests:rate5m
  expr: sum by (service) (rate(http_requests_total[5m]))

# Error rate
- record: service:http_errors:ratio5m
  expr: |
    sum by (service) (rate(http_requests_total{code=~"5.."}[5m]))
    /
    sum by (service) (rate(http_requests_total[5m]))

# Duration percentiles
- record: service:http_duration:p50
  expr: histogram_quantile(0.50, sum by (service, le) (rate(http_request_duration_seconds_bucket[5m])))

- record: service:http_duration:p90
  expr: histogram_quantile(0.90, sum by (service, le) (rate(http_request_duration_seconds_bucket[5m])))

- record: service:http_duration:p99
  expr: histogram_quantile(0.99, sum by (service, le) (rate(http_request_duration_seconds_bucket[5m])))
```

#### SLO Availability

```yaml
- record: slo:availability:ratio30d
  expr: |
    1 - (
      sum(increase(http_requests_total{code=~"5.."}[30d]))
      /
      sum(increase(http_requests_total[30d]))
    )
```

#### GitOps Success Rates

```yaml
- record: argocd:sync_success:ratio1h
  expr: |
    sum(increase(argocd_app_sync_total{phase="Succeeded"}[1h]))
    /
    sum(increase(argocd_app_sync_total[1h]))
```

---

## Grafana Dashboards

Three pre-built dashboards are available in `grafana/dashboards/`:

### Platform Overview Dashboard

**File**: `grafana/dashboards/platform-overview.json`

Panels include:

- Cluster health status (nodes, pods, namespaces)
- CPU and memory utilization (cluster and per-node)
- Pod distribution by namespace
- Network I/O rates
- Persistent volume usage
- Top resource consumers

### Cost Management Dashboard

**File**: `grafana/dashboards/cost-management.json`

Panels include:

- Budget utilization percentage with threshold indicators
- Cost trends over 7/30/90 days
- Resource costs broken down by tag (`cost-center`, `environment`, `owner`)
- VM size distribution and cost impact
- Storage costs by type (managed disks, blob, table)
- Recommendations for right-sizing

### Golden Path Application Dashboard

**File**: `grafana/dashboards/golden-path-application.json`

Panels include:

- Request rate (requests/second)
- Error rate (percentage of 5xx responses)
- Latency percentiles (p50, p90, p99)
- Deployment frequency (deploys per day/week)
- Pod replica count and HPA status
- Resource usage vs. requests/limits

### Dashboard Provisioning

Dashboards are provisioned as ConfigMaps and automatically loaded by the Grafana sidecar:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: platform-overview-dashboard
  namespace: monitoring
  labels:
    grafana_dashboard: "1"
data:
  platform-overview.json: |
    { ... dashboard JSON ... }
```

The `grafana_dashboard: "1"` label tells the Grafana sidecar to load the ConfigMap as a dashboard.

---

## Alertmanager

Alertmanager handles alert routing, grouping, silencing, and notification.

### Notification Routing

```yaml
route:
  receiver: default-slack
  group_by: ['alertname', 'namespace']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  routes:
    - match:
        severity: critical
      receiver: pagerduty-critical
      repeat_interval: 1h
    - match:
        severity: warning
      receiver: slack-warnings
      repeat_interval: 4h
    - match:
        severity: info
      receiver: slack-info
      repeat_interval: 12h

receivers:
  - name: pagerduty-critical
    pagerduty_configs:
      - routing_key: ${PAGERDUTY_KEY}
        severity: critical
  - name: slack-warnings
    slack_configs:
      - api_url: ${SLACK_WEBHOOK_URL}
        channel: '#platform-alerts'
        title: '[{{ .Status }}] {{ .CommonLabels.alertname }}'
  - name: slack-info
    slack_configs:
      - api_url: ${SLACK_WEBHOOK_URL}
        channel: '#platform-info'
  - name: default-slack
    slack_configs:
      - api_url: ${SLACK_WEBHOOK_URL}
        channel: '#platform-alerts'
```

### Silencing Alerts

During planned maintenance, silence alerts to prevent noise:

```bash
# Silence via Alertmanager API
amtool silence add \
  --alertmanager.url=http://alertmanager:9093 \
  --comment="Planned AKS node upgrade" \
  --duration=2h \
  alertname=~"NodeNotReady|PodCrashLooping"
```

---

## Jaeger Distributed Tracing

Jaeger provides distributed tracing for microservice architectures. Applications instrumented with OpenTelemetry export traces to the Jaeger collector.

### Architecture

```
Application (OpenTelemetry SDK)
        |
        v
Jaeger Collector (receive, process, store)
        |
        v
Jaeger Query (API + UI)
```

### Accessing Jaeger

- **Via RHDH**: Navigate to the component page and click the Jaeger link
- **Via Ingress**: Access the Jaeger UI at the configured ingress URL
- **Via Port Forward**: `kubectl port-forward svc/jaeger-query -n observability 16686:16686`

### Using Jaeger

- **Trace search**: Search by service name, operation, tags, duration, and time range
- **Trace comparison**: Compare two traces to identify regression in latency
- **Dependency graph**: Visualize service-to-service communication patterns
- **Error analysis**: Filter traces by error status to debug failure propagation

### Instrumenting Your Service

Golden Path templates include OpenTelemetry instrumentation automatically. For custom services:

```python
# Python example (FastAPI)
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

tracer_provider = TracerProvider()
jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger-agent.observability.svc.cluster.local",
    agent_port=6831,
)
tracer_provider.add_span_processor(BatchSpanProcessor(jaeger_exporter))
trace.set_tracer_provider(tracer_provider)
```

---

## Container Insights

Azure Container Insights provides native Azure monitoring for AKS clusters, integrating with Log Analytics Workspace.

### Collected Data

- Container logs (stdout/stderr)
- Node and pod performance metrics
- Kubernetes events
- Cluster inventory

### Integration with Prometheus

Container Insights can scrape Prometheus metrics and forward them to Azure Monitor:

```yaml
# ConfigMap for Prometheus scraping
apiVersion: v1
kind: ConfigMap
metadata:
  name: container-azm-ms-agentconfig
  namespace: kube-system
data:
  prometheus-data-collection-settings: |
    [prometheus_data_collection_settings.cluster]
    interval = "1m"
    monitor_kubernetes_pods = true
```

### Log Analytics Queries

```kql
// Container crash loops
ContainerLog
| where LogEntry contains "CrashLoopBackOff"
| summarize count() by ContainerName, PodName, bin(TimeGenerated, 1h)

// High memory usage pods
Perf
| where ObjectName == "K8SContainer" and CounterName == "memoryRssBytes"
| summarize AvgMem = avg(CounterValue) by InstanceName, bin(TimeGenerated, 5m)
| where AvgMem > 1073741824
```

---

## Adding Monitoring to Your Service

Golden Path templates automatically include monitoring configuration. For custom services, follow these steps:

### 1. Expose a /metrics Endpoint

Expose Prometheus-format metrics from your application:

```python
# Python (FastAPI + prometheus_client)
from prometheus_client import Counter, Histogram, generate_latest
from fastapi import FastAPI, Response

app = FastAPI()
REQUEST_COUNT = Counter('http_requests_total', 'Total requests', ['method', 'path', 'status'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'Request latency', ['method', 'path'])

@app.get("/metrics")
def metrics():
    return Response(content=generate_latest(), media_type="text/plain")
```

### 2. Create a ServiceMonitor

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: my-service
  namespace: my-namespace
  labels:
    app.kubernetes.io/name: my-service
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: my-service
  endpoints:
    - port: metrics
      interval: 30s
      path: /metrics
```

### 3. Add a Grafana Dashboard

Create a JSON dashboard and add it as a ConfigMap:

```bash
# Export a dashboard from Grafana UI and save as JSON
# Then create a ConfigMap
kubectl create configmap my-service-dashboard \
  -n monitoring \
  --from-file=my-service.json=dashboard.json

kubectl label configmap my-service-dashboard \
  -n monitoring \
  grafana_dashboard=1
```

### 4. Configure Alert Rules

Add alert rules to `prometheus/alerting-rules.yaml`:

```yaml
- alert: MyServiceHighErrorRate
  expr: service:http_errors:ratio5m{service="my-service"} > 0.05
  for: 5m
  labels:
    severity: warning
    team: my-team
  annotations:
    summary: "High error rate on my-service"
    description: "Error rate is {{ $value | humanizePercentage }} over the last 5 minutes."
```

---

## Troubleshooting Monitoring

### Common Issues

| Issue | Cause | Resolution |
|-------|-------|------------|
| ServiceMonitor not scraping | Missing labels | Verify selector labels match the Service |
| Dashboard not showing data | Wrong Prometheus datasource | Check datasource UID in dashboard JSON |
| Alerts not firing | Expression error or `for` too long | Test expression in Prometheus UI |
| Jaeger traces missing | Collector not reachable | Check Jaeger collector pod and service |
| Grafana dashboard empty | No data in time range | Extend the time range or check data source |

### Useful Commands

```bash
# Check Prometheus targets
kubectl port-forward svc/prometheus-kube-prometheus-prometheus -n monitoring 9090:9090
# Then visit http://localhost:9090/targets

# Check Alertmanager
kubectl port-forward svc/prometheus-kube-prometheus-alertmanager -n monitoring 9093:9093

# View Grafana
kubectl port-forward svc/grafana -n monitoring 3000:3000

# Check ServiceMonitor status
kubectl get servicemonitor -A

# View Prometheus rules
kubectl get prometheusrule -A
```
