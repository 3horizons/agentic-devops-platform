# Golden Path Section 14: End-to-End Flow

## Complete Journey from Scaffolding to Production

**Version:** 2.0  
**Parent Document:** golden_path_end_to_end_guide_v2_complete.md  
**Author:** paulasilva@microsoft.com  
**Last Updated:** December 2025

---

## Table of Contents

1. [Overview](#1-overview)
2. [Developer Journey Map](#2-developer-journey-map)
3. [Service Scaffolding](#3-service-scaffolding)
4. [Development Workflow](#4-development-workflow)
5. [CI/CD Pipeline](#5-cicd-pipeline)
6. [Blue-Green Deployment](#6-blue-green-deployment)
7. [Production Validation](#7-production-validation)
8. [Monitoring & Alerting](#8-monitoring--alerting)
9. [Incident Response](#9-incident-response)
10. [Complete Timeline](#10-complete-timeline)

---

## 1. Overview

This section provides a complete walkthrough of the Golden Path from initial service creation to production deployment and ongoing operations.

### End-to-End Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    GOLDEN PATH END-TO-END FLOW                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ PHASE 1: SCAFFOLDING (T+0 to T+5 min)                                │  │
│  │                                                                       │  │
│  │  Developer ──► RHDH Portal ──► Software Template ──► GitHub Repo     │  │
│  │                     │                                    │            │  │
│  │                     └── Terraform ──► Azure Resources    │            │  │
│  │                                                          │            │  │
│  │  Output: Complete repository with CI/CD, IaC, configs   │            │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ PHASE 2: DEVELOPMENT (T+5 min to T+N days)                           │  │
│  │                                                                       │  │
│  │  Local Dev ──► Copilot ──► Tests ──► PR ──► Code Review ──► Merge   │  │
│  │      │                         │                                      │  │
│  │      └── Dev Container         └── AI-Generated Tests                │  │
│  │                                                                       │  │
│  │  Tools: VS Code, Copilot, Testcontainers, GitHub Actions            │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ PHASE 3: CI/CD (T+merge to T+20 min)                                 │  │
│  │                                                                       │  │
│  │  Build ──► Test ──► Scan ──► Push ──► Deploy Dev ──► Deploy Staging │  │
│  │    │         │        │                                  │            │  │
│  │    │         │        └── GHAS Security                  │            │  │
│  │    │         └── Unit + Integration                      │            │  │
│  │    └── Docker Build                                      │            │  │
│  │                                                          │            │  │
│  │  Output: Tested, scanned image in ACR, deployed to staging           │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ PHASE 4: PRODUCTION DEPLOYMENT (T+staging to T+48 min)               │  │
│  │                                                                       │  │
│  │  ┌────────┐   ┌────────┐   ┌────────┐   ┌────────┐                  │  │
│  │  │   T1   │──►│   T2   │──►│   T3   │──►│   T4   │                  │  │
│  │  │ Deploy │   │ Sync & │   │Traffic │   │ Post-  │                  │  │
│  │  │ Green  │   │ Test   │   │ Switch │   │Validate│                  │  │
│  │  └────────┘   └────────┘   └────────┘   └────────┘                  │  │
│  │   5-10min      10-20min     1-2min       5-15min                     │  │
│  │                                                                       │  │
│  │  Output: Production deployment with validation                       │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                    │                                        │
│                                    ▼                                        │
│  ┌──────────────────────────────────────────────────────────────────────┐  │
│  │ PHASE 5: OPERATIONS (Ongoing)                                        │  │
│  │                                                                       │  │
│  │  Azure Monitor ──► Prometheus ──► Grafana ──► SRE Agent ──► Alerts  │  │
│  │        │                                           │                  │  │
│  │        └── Anomaly Detection                       └── Auto-Remediate│  │
│  │                                                                       │  │
│  │  Tools: Azure Monitor, Managed Prometheus, Grafana, SRE Agent        │  │
│  └──────────────────────────────────────────────────────────────────────┘  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Developer Journey Map

### Complete Journey Timeline

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DEVELOPER JOURNEY TIMELINE                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TIME        ACTION                      TOOL              OUTCOME          │
│  ────        ──────                      ────              ───────          │
│                                                                             │
│  T+0         Access RHDH Portal          RHDH              Dashboard view   │
│  T+1 min     Select template             Software Template Options listed   │
│  T+2 min     Fill parameters             Scaffolder UI     Config ready     │
│  T+3 min     Submit creation             RHDH              Job started      │
│  T+5 min     ✅ Repository created       GitHub            Full repo        │
│                                                                             │
│  T+6 min     Clone repository            Git               Local copy       │
│  T+7 min     Open in VS Code             VS Code           Dev environment  │
│  T+8 min     Start Codespace/Container   Codespaces        Ready to code    │
│  T+10 min    Begin coding                Copilot           AI assistance    │
│                                                                             │
│  T+N         Create PR                   GitHub            Review requested │
│  T+N+5       AI Code Review              Copilot Review    Feedback         │
│  T+N+10      Address comments            VS Code           Changes made     │
│  T+N+15      Approval & merge            GitHub            PR merged        │
│                                                                             │
│  T+merge     CI triggered                GitHub Actions    Pipeline runs    │
│  T+merge+5   Unit tests pass             JUnit/Jest        ✅ Tests green   │
│  T+merge+8   Integration tests pass      Testcontainers    ✅ Tests green   │
│  T+merge+10  Security scan complete      GHAS              ✅ No issues     │
│  T+merge+12  Image pushed                ACR               Image available  │
│  T+merge+15  Dev deployed                ArgoCD            Dev running      │
│  T+merge+20  Staging deployed            ArgoCD            Staging running  │
│                                                                             │
│  T+staging   Production approval         GitHub            Manual gate      │
│  T+staging+5 T1: Deploy green            Ansible           Green ready      │
│  T+staging+20 T2: Validation             k6/Prometheus     SLOs verified    │
│  T+staging+22 T3: Traffic switch         Kubernetes        Live traffic     │
│  T+staging+37 T4: Post-validation        SRE Agent         ✅ Stable        │
│                                                                             │
│  TOTAL: ~48 minutes from merge to production                               │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Service Scaffolding

### Step 1: Access RHDH Portal

```bash
# Developer opens RHDH portal
https://rhdh.example.com

# Authenticate via Microsoft Entra ID (SSO)
# Navigate to "Create" > "Create Component"
```

### Step 2: Select Template

```yaml
# Available templates for new services:
templates:
  - name: golden-path-java-service
    title: Java Spring Boot Service
    description: Production-ready Java microservice with all Golden Path integrations
    
  - name: golden-path-node-service
    title: Node.js Express Service
    description: TypeScript Node.js service with full observability
    
  - name: golden-path-python-service
    title: Python FastAPI Service
    description: High-performance Python API service
    
  - name: rehost-vm-to-aks
    title: Rehost - VM to AKS Migration
    description: Containerize existing VM-based application
    
  - name: refactor-cloud-native
    title: Refactor - Cloud Native Re-architecture
    description: Decompose monolith into microservices
```

### Step 3: Fill Parameters

```yaml
# Example parameter values for Java service:
parameters:
  serviceName: order-service
  description: Order management microservice
  owner: platform-team
  system: ecommerce
  
  runtime:
    language: java
    version: "21"
    framework: spring-boot
    
  database:
    type: postgresql
    tier: flexible-standard
    
  deployment:
    environments:
      - dev
      - staging
      - prod
    replicas:
      dev: 1
      staging: 2
      prod: 3
```

### Step 4: Generated Artifacts

```
order-service/
├── .github/
│   ├── workflows/
│   │   ├── ci.yml
│   │   ├── cd.yml
│   │   └── security.yml
│   ├── copilot-config.yml
│   └── CODEOWNERS
├── src/
│   ├── main/java/com/example/orderservice/
│   │   ├── OrderServiceApplication.java
│   │   ├── api/
│   │   ├── domain/
│   │   ├── infrastructure/
│   │   └── config/
│   └── test/
├── kubernetes/
│   ├── base/
│   │   ├── deployment.yaml
│   │   ├── service.yaml
│   │   ├── configmap.yaml
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── environments/
├── ansible/
│   ├── playbooks/
│   └── roles/
├── docs/
│   └── index.md
├── catalog-info.yaml
├── Dockerfile
├── pom.xml
└── README.md
```

---

## 4. Development Workflow

### Local Development Setup

```bash
# Clone the repository
git clone https://github.com/org/order-service.git
cd order-service

# Option 1: Start Dev Container (VS Code)
code .
# Click "Reopen in Container" when prompted

# Option 2: Start GitHub Codespace
gh codespace create --repo org/order-service
gh codespace code

# Option 3: Local Docker Compose
docker-compose -f docker-compose.dev.yml up -d
```

### Development with Copilot

```java
// Developer types a comment, Copilot suggests implementation

// Create an order from cart items
// Copilot generates:
@Transactional
public Order createOrderFromCart(UUID userId, UUID cartId) {
    Cart cart = cartRepository.findById(cartId)
        .orElseThrow(() -> new CartNotFoundException(cartId));
    
    if (!cart.getUserId().equals(userId)) {
        throw new UnauthorizedAccessException("Cart does not belong to user");
    }
    
    Order order = Order.builder()
        .userId(userId)
        .orderNumber(generateOrderNumber())
        .status(OrderStatus.PENDING)
        .items(cart.getItems().stream()
            .map(this::toOrderItem)
            .collect(Collectors.toList()))
        .totalAmount(calculateTotal(cart.getItems()))
        .createdAt(Instant.now())
        .build();
    
    Order savedOrder = orderRepository.save(order);
    
    eventPublisher.publish(new OrderCreatedEvent(savedOrder));
    cartService.clearCart(cartId);
    
    return savedOrder;
}
```

---

## 5. CI/CD Pipeline

### GitHub Actions CI Workflow

```yaml
# .github/workflows/ci.yml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  REGISTRY: myacr.azurecr.io
  IMAGE_NAME: order-service

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: maven
          
      - name: Build
        run: mvn clean package -DskipTests
        
      - name: Unit Tests
        run: mvn test -Dtest="**/*Test" -DexcludedGroups="integration"
        
      - name: Integration Tests
        run: mvn verify -Dgroups="integration"
        
      - name: Code Coverage
        run: mvn jacoco:report
        
      - name: Upload Coverage
        uses: codecov/codecov-action@v3
        with:
          files: target/site/jacoco/jacoco.xml
          fail_ci_if_error: true
          
  security-scan:
    runs-on: ubuntu-latest
    needs: build-and-test
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Run GHAS Code Scanning
        uses: github/codeql-action/analyze@v2
        
      - name: Run Dependency Check
        run: mvn org.owasp:dependency-check-maven:check
        
  build-image:
    runs-on: ubuntu-latest
    needs: [build-and-test, security-scan]
    if: github.ref == 'refs/heads/main'
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          
      - name: ACR Login
        run: az acr login --name myacr
        
      - name: Build and Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }}
            ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:latest
```

---

## 6. Blue-Green Deployment

### T1: Deploy Green Environment

```yaml
# ansible/playbooks/blue-green-t1-deploy.yml
---
- name: "T1: Deploy Green Environment"
  hosts: localhost
  connection: local
  
  vars:
    service_name: order-service
    namespace: order-service
    image_tag: "{{ lookup('env', 'IMAGE_TAG') }}"
    
  tasks:
    - name: Get current active color
      kubernetes.core.k8s_info:
        kind: Service
        name: "{{ service_name }}"
        namespace: "{{ namespace }}"
      register: current_service
      
    - name: Determine deployment colors
      set_fact:
        current_color: "{{ current_service.resources[0].spec.selector.color | default('blue') }}"
        new_color: "{{ 'green' if current_service.resources[0].spec.selector.color | default('blue') == 'blue' else 'blue' }}"
        
    - name: Deploy new version to {{ new_color }}
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: apps/v1
          kind: Deployment
          metadata:
            name: "{{ service_name }}-{{ new_color }}"
            namespace: "{{ namespace }}"
          spec:
            replicas: 3
            selector:
              matchLabels:
                app: "{{ service_name }}"
                color: "{{ new_color }}"
            template:
              metadata:
                labels:
                  app: "{{ service_name }}"
                  color: "{{ new_color }}"
              spec:
                containers:
                  - name: "{{ service_name }}"
                    image: "myacr.azurecr.io/{{ service_name }}:{{ image_tag }}"
                    ports:
                      - containerPort: 8080
                    readinessProbe:
                      httpGet:
                        path: /health/ready
                        port: 8080
                      initialDelaySeconds: 10
                      periodSeconds: 5
                      
    - name: Wait for deployment to be ready
      kubernetes.core.k8s_info:
        kind: Deployment
        name: "{{ service_name }}-{{ new_color }}"
        namespace: "{{ namespace }}"
      register: deployment_status
      until: deployment_status.resources[0].status.readyReplicas | default(0) == 3
      retries: 30
      delay: 10
```

### T2: Validate Green Environment

```yaml
# ansible/playbooks/blue-green-t2-validate.yml
---
- name: "T2: Validate Green Environment"
  hosts: localhost
  
  tasks:
    - name: Run smoke tests against green
      shell: |
        k6 run --env BASE_URL=http://{{ service_name }}-{{ new_color }}-test:8080 \
          /tests/smoke-test.js
      register: smoke_result
      
    - name: Verify SLOs are met
      uri:
        url: "http://prometheus:9090/api/v1/query"
        method: POST
        body_format: form-urlencoded
        body:
          query: 'histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{app="{{ service_name }}",color="{{ new_color }}"}[5m]))'
      register: latency_p99
      failed_when: latency_p99.json.data.result[0].value[1] | float > 0.5
```

### T3: Traffic Switch

```yaml
# ansible/playbooks/blue-green-t3-switch.yml
---
- name: "T3: Switch Traffic to Green"
  hosts: localhost
  
  tasks:
    - name: Switch service selector to green
      kubernetes.core.k8s:
        state: present
        definition:
          apiVersion: v1
          kind: Service
          metadata:
            name: "{{ service_name }}"
            namespace: "{{ namespace }}"
          spec:
            selector:
              app: "{{ service_name }}"
              color: "{{ new_color }}"
            ports:
              - port: 80
                targetPort: 8080
```

### T4: Post-Deployment Validation

```yaml
# ansible/playbooks/blue-green-t4-validate.yml
---
- name: "T4: Post-Deployment Validation"
  hosts: localhost
  
  tasks:
    - name: Monitor error rate for 15 minutes
      uri:
        url: "http://prometheus:9090/api/v1/query"
        method: POST
        body_format: form-urlencoded
        body:
          query: 'rate(http_requests_total{app="{{ service_name }}",status=~"5.."}[5m]) / rate(http_requests_total{app="{{ service_name }}"}[5m])'
      register: error_rate_check
      until: error_rate_check.json.data.result[0].value[1] | float < 0.01
      retries: 30
      delay: 30
      
    - name: Scale down old deployment
      kubernetes.core.k8s_scale:
        kind: Deployment
        name: "{{ service_name }}-{{ old_color }}"
        namespace: "{{ namespace }}"
        replicas: 0
      when: error_rate_check is succeeded
```

---

## 7. Production Validation

### Synthetic Monitoring

```yaml
# kubernetes/monitoring/synthetic-monitor.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: order-service-synthetic
  namespace: monitoring
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: synthetic-test
              image: grafana/k6:latest
              command: ["k6", "run", "/scripts/synthetic.js"]
              env:
                - name: BASE_URL
                  value: "https://order-service.example.com"
          restartPolicy: OnFailure
```

---

## 8. Monitoring & Alerting

### Prometheus Rules

```yaml
# kubernetes/monitoring/prometheus-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: order-service-alerts
spec:
  groups:
    - name: order-service.rules
      rules:
        - alert: OrderServiceHighErrorRate
          expr: |
            sum(rate(http_requests_total{app="order-service",status=~"5.."}[5m]))
            /
            sum(rate(http_requests_total{app="order-service"}[5m])) > 0.001
          for: 5m
          labels:
            severity: critical
          annotations:
            summary: "Order Service error rate exceeds SLO"
            
        - alert: OrderServiceHighLatency
          expr: |
            histogram_quantile(0.99, 
              sum(rate(http_request_duration_seconds_bucket{app="order-service"}[5m])) by (le)
            ) > 0.5
          for: 5m
          labels:
            severity: warning
          annotations:
            summary: "Order Service P99 latency exceeds SLO"
```

---

## 9. Incident Response

### SRE Agent Integration

```python
# sre-agent/incident_handler.py
class IncidentHandler:
    async def handle_alert(self, alert: dict):
        # Gather context
        context = await self._gather_context(alert)
        
        # Get AI analysis
        analysis = await self._analyze_incident(alert, context)
        
        # Execute remediation if confident
        if analysis.confidence > 0.8:
            await self._execute_remediation(analysis.remediation)
            
        # Create incident ticket
        await self._create_ticket(alert, analysis)
```

---

## 10. Complete Timeline

### Full Deployment Timeline

| Phase | Duration | Actions |
|-------|----------|---------|
| **Scaffolding** | 5 min | Template selection, repo creation |
| **Development** | N days | Coding with Copilot, PR creation |
| **CI Pipeline** | 12 min | Build, test, scan, push |
| **CD Pipeline** | 10 min | Deploy to dev, staging |
| **Production T1** | 10 min | Deploy green environment |
| **Production T2** | 15 min | Validate and test |
| **Production T3** | 2 min | Traffic switch |
| **Production T4** | 15 min | Post-deployment validation |
| **TOTAL** | ~48 min | From merge to production |

### Success Metrics

| Metric | Target | Measured |
|--------|--------|----------|
| Time to first commit | < 10 min | 8 min |
| PR to staging | < 30 min | 25 min |
| Staging to production | < 45 min | 40 min |
| Deployment success rate | > 99% | 99.5% |
| Rollback time | < 5 min | 2 min |
| MTTR | < 30 min | 18 min |

---

## Document Information

**Version:** 2.0  
**Parent:** golden_path_end_to_end_guide_v2_complete.md  
**Author:** Paula Silva (paulasilva@microsoft.com)  
**Last Updated:** December 2025
