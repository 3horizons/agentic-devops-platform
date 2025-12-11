# Golden Path Section 12: Self-Healing Patterns

## Resilience and Automatic Recovery Patterns

**Version:** 2.0  
**Parent Document:** golden_path_end_to_end_guide_v2_complete.md  
**Author:** paulasilva@microsoft.com  
**Last Updated:** December 2025

---

## Table of Contents

1. [Overview](#1-overview)
2. [Kubernetes Self-Healing](#2-kubernetes-self-healing)
3. [Application-Level Resilience](#3-application-level-resilience)
4. [Infrastructure Self-Healing](#4-infrastructure-self-healing)
5. [Database Resilience](#5-database-resilience)
6. [SRE Agent Integration](#6-sre-agent-integration)
7. [Chaos Engineering](#7-chaos-engineering)
8. [Runbook Automation](#8-runbook-automation)
9. [Metrics & Dashboards](#9-metrics--dashboards)

---

## 1. Overview

### Self-Healing Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    SELF-HEALING ARCHITECTURE                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         DETECTION LAYER                              │   │
│  │                                                                       │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │  Prometheus  │  │Azure Monitor │  │  SRE Agent   │              │   │
│  │  │   Metrics    │  │    Logs      │  │   AI/ML      │              │   │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘              │   │
│  │         │                 │                 │                        │   │
│  │         └─────────────────┼─────────────────┘                        │   │
│  │                           ▼                                          │   │
│  │                    ┌──────────────┐                                  │   │
│  │                    │   Alerting   │                                  │   │
│  │                    └──────┬───────┘                                  │   │
│  └───────────────────────────┼──────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         DECISION LAYER                               │   │
│  │                                                                       │   │
│  │  ┌────────────────────────────────────────────────────────────────┐ │   │
│  │  │                      SRE Agent Brain                            │ │   │
│  │  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐       │ │   │
│  │  │  │ Pattern  │  │  Root    │  │Remediation│  │Confidence│       │ │   │
│  │  │  │ Matching │─►│  Cause   │─►│ Selection │─►│  Check   │       │ │   │
│  │  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘       │ │   │
│  │  └────────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│                              ▼                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                         ACTION LAYER                                 │   │
│  │                                                                       │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │   │
│  │  │  Kubernetes  │  │   Ansible    │  │   Terraform  │              │   │
│  │  │  Controllers │  │   Runbooks   │  │    Drift     │              │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘              │   │
│  │         │                 │                 │                        │   │
│  │         └─────────────────┼─────────────────┘                        │   │
│  │                           ▼                                          │   │
│  │  ┌────────────────────────────────────────────────────────────────┐ │   │
│  │  │ Pod Restart │ Scale Up │ Rollback │ Failover │ Config Update   │ │   │
│  │  └────────────────────────────────────────────────────────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Resilience Patterns Summary

| Pattern | Scope | Auto-Heal | Human Approval |
|---------|-------|-----------|----------------|
| Pod Restart | Container | Yes | No |
| HPA Scaling | Deployment | Yes | No |
| Node Drain | Node | Yes | No |
| Rollback | Deployment | Conditional | If > 10% error |
| Database Failover | Infrastructure | Yes | No |
| Configuration Update | Application | No | Yes |
| Scale to Zero | Cost optimization | Yes | Alert only |

---

## 2. Kubernetes Self-Healing

### Liveness and Readiness Probes

```yaml
# kubernetes/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
        - name: order-service
          image: myacr.azurecr.io/order-service:latest
          ports:
            - containerPort: 8080
              name: http
            - containerPort: 8081
              name: management
              
          # Liveness Probe - Restart container if unhealthy
          livenessProbe:
            httpGet:
              path: /health/live
              port: management
            initialDelaySeconds: 30
            periodSeconds: 10
            timeoutSeconds: 5
            failureThreshold: 3
            successThreshold: 1
            
          # Readiness Probe - Remove from service if not ready
          readinessProbe:
            httpGet:
              path: /health/ready
              port: management
            initialDelaySeconds: 10
            periodSeconds: 5
            timeoutSeconds: 3
            failureThreshold: 3
            successThreshold: 1
            
          # Startup Probe - Give time for slow-starting containers
          startupProbe:
            httpGet:
              path: /health/started
              port: management
            initialDelaySeconds: 5
            periodSeconds: 5
            failureThreshold: 30  # 30 * 5 = 150s max startup time
            
          resources:
            requests:
              memory: "512Mi"
              cpu: "250m"
            limits:
              memory: "1Gi"
              cpu: "1000m"
```

### Health Check Implementation

```java
// src/main/java/com/example/orderservice/health/HealthController.java
package com.example.orderservice.health;

import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.sql.DataSource;
import java.sql.Connection;
import java.time.Duration;
import java.time.Instant;

@RestController
public class HealthController {

    private final DataSource dataSource;
    private final RedisTemplate<String, String> redis;
    private final KafkaTemplate<String, String> kafka;
    private final Instant startTime = Instant.now();
    
    // Liveness - Is the application alive?
    @GetMapping("/health/live")
    public ResponseEntity<Health> liveness() {
        // Check if the application can respond
        // Don't check external dependencies here
        return ResponseEntity.ok(Health.up()
            .withDetail("uptime", Duration.between(startTime, Instant.now()).toSeconds())
            .build());
    }
    
    // Readiness - Is the application ready to serve traffic?
    @GetMapping("/health/ready")
    public ResponseEntity<Health> readiness() {
        Health.Builder builder = Health.up();
        boolean ready = true;
        
        // Check database connection
        try (Connection conn = dataSource.getConnection()) {
            conn.isValid(2);
            builder.withDetail("database", "connected");
        } catch (Exception e) {
            builder.withDetail("database", "disconnected: " + e.getMessage());
            ready = false;
        }
        
        // Check Redis connection
        try {
            redis.getConnectionFactory().getConnection().ping();
            builder.withDetail("redis", "connected");
        } catch (Exception e) {
            builder.withDetail("redis", "disconnected: " + e.getMessage());
            ready = false;
        }
        
        // Check Kafka connection
        try {
            kafka.send("health-check", "ping").get(2, TimeUnit.SECONDS);
            builder.withDetail("kafka", "connected");
        } catch (Exception e) {
            builder.withDetail("kafka", "disconnected: " + e.getMessage());
            ready = false;
        }
        
        if (ready) {
            return ResponseEntity.ok(builder.build());
        } else {
            return ResponseEntity.status(503).body(builder.down().build());
        }
    }
    
    // Startup - Has the application started successfully?
    @GetMapping("/health/started")
    public ResponseEntity<Health> startup() {
        // Check if all initialization is complete
        if (applicationContext.isRunning() && warmupComplete) {
            return ResponseEntity.ok(Health.up().build());
        }
        return ResponseEntity.status(503).body(Health.down().build());
    }
}
```

### Pod Disruption Budget

```yaml
# kubernetes/base/pdb.yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: order-service-pdb
spec:
  minAvailable: 2  # Always keep at least 2 pods running
  selector:
    matchLabels:
      app: order-service
---
# Alternative: maxUnavailable
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: order-service-pdb-percent
spec:
  maxUnavailable: 33%  # Allow up to 33% of pods to be unavailable
  selector:
    matchLabels:
      app: order-service
```

### Horizontal Pod Autoscaler

```yaml
# kubernetes/base/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: order-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: order-service
  minReplicas: 3
  maxReplicas: 20
  
  metrics:
    # CPU-based scaling
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
          
    # Memory-based scaling
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
          
    # Custom metrics from Prometheus
    - type: Pods
      pods:
        metric:
          name: http_requests_per_second
        target:
          type: AverageValue
          averageValue: 1000
          
    # External metrics (e.g., queue depth)
    - type: External
      external:
        metric:
          name: azure_servicebus_queue_length
          selector:
            matchLabels:
              queue_name: orders
        target:
          type: AverageValue
          averageValue: 100
          
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 100
          periodSeconds: 60
        - type: Pods
          value: 4
          periodSeconds: 60
      selectPolicy: Max
      
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
      selectPolicy: Min
```

### Vertical Pod Autoscaler

```yaml
# kubernetes/base/vpa.yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: order-service-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: order-service
  updatePolicy:
    updateMode: "Auto"  # Auto, Recreate, Initial, Off
  resourcePolicy:
    containerPolicies:
      - containerName: order-service
        minAllowed:
          cpu: 100m
          memory: 256Mi
        maxAllowed:
          cpu: 4
          memory: 8Gi
        controlledResources: ["cpu", "memory"]
        controlledValues: RequestsAndLimits
```

---

## 3. Application-Level Resilience

### Circuit Breaker Pattern

```java
// src/main/java/com/example/orderservice/resilience/CircuitBreakerConfig.java
package com.example.orderservice.resilience;

import io.github.resilience4j.circuitbreaker.CircuitBreaker;
import io.github.resilience4j.circuitbreaker.CircuitBreakerConfig;
import io.github.resilience4j.circuitbreaker.CircuitBreakerRegistry;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

@Configuration
public class CircuitBreakerConfiguration {

    @Bean
    public CircuitBreakerRegistry circuitBreakerRegistry() {
        CircuitBreakerConfig defaultConfig = CircuitBreakerConfig.custom()
            // Failure rate threshold percentage
            .failureRateThreshold(50)
            // Slow call rate threshold percentage
            .slowCallRateThreshold(50)
            // Slow call duration threshold
            .slowCallDurationThreshold(Duration.ofSeconds(2))
            // Minimum number of calls before calculating failure rate
            .minimumNumberOfCalls(10)
            // Sliding window type (COUNT_BASED or TIME_BASED)
            .slidingWindowType(CircuitBreakerConfig.SlidingWindowType.COUNT_BASED)
            // Sliding window size
            .slidingWindowSize(20)
            // Wait duration in open state before transitioning to half-open
            .waitDurationInOpenState(Duration.ofSeconds(30))
            // Number of permitted calls in half-open state
            .permittedNumberOfCallsInHalfOpenState(5)
            // Automatically transition from open to half-open
            .automaticTransitionFromOpenToHalfOpenEnabled(true)
            // Record these exceptions as failures
            .recordExceptions(
                IOException.class,
                TimeoutException.class,
                ServiceUnavailableException.class
            )
            // Ignore these exceptions (don't count as failures)
            .ignoreExceptions(
                BusinessException.class,
                ValidationException.class
            )
            .build();

        return CircuitBreakerRegistry.of(defaultConfig);
    }
    
    @Bean
    public CircuitBreaker paymentServiceCircuitBreaker(CircuitBreakerRegistry registry) {
        return registry.circuitBreaker("paymentService", CircuitBreakerConfig.custom()
            .failureRateThreshold(30)  // More sensitive for payment service
            .waitDurationInOpenState(Duration.ofSeconds(60))
            .build());
    }
    
    @Bean
    public CircuitBreaker inventoryServiceCircuitBreaker(CircuitBreakerRegistry registry) {
        return registry.circuitBreaker("inventoryService");
    }
}
```

### Circuit Breaker Usage

```java
// src/main/java/com/example/orderservice/client/PaymentServiceClient.java
package com.example.orderservice.client;

import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import io.github.resilience4j.bulkhead.annotation.Bulkhead;
import io.github.resilience4j.timelimiter.annotation.TimeLimiter;
import org.springframework.stereotype.Service;

import java.util.concurrent.CompletableFuture;

@Service
public class PaymentServiceClient {

    private final WebClient webClient;
    
    @CircuitBreaker(name = "paymentService", fallbackMethod = "processPaymentFallback")
    @Retry(name = "paymentService")
    @Bulkhead(name = "paymentService", type = Bulkhead.Type.THREADPOOL)
    @TimeLimiter(name = "paymentService")
    public CompletableFuture<PaymentResult> processPayment(PaymentRequest request) {
        return webClient.post()
            .uri("/api/v1/payments")
            .bodyValue(request)
            .retrieve()
            .bodyToMono(PaymentResult.class)
            .toFuture();
    }
    
    // Fallback when circuit is open or all retries exhausted
    public CompletableFuture<PaymentResult> processPaymentFallback(
            PaymentRequest request, Throwable throwable) {
        
        log.warn("Payment service unavailable, using fallback. Error: {}", 
            throwable.getMessage());
        
        // Queue payment for later processing
        paymentQueue.enqueue(request);
        
        return CompletableFuture.completedFuture(PaymentResult.builder()
            .status(PaymentStatus.PENDING)
            .message("Payment queued for processing")
            .retryable(true)
            .build());
    }
}
```

### Retry Configuration

```yaml
# src/main/resources/application.yml
resilience4j:
  retry:
    instances:
      paymentService:
        maxAttempts: 3
        waitDuration: 1s
        enableExponentialBackoff: true
        exponentialBackoffMultiplier: 2
        retryExceptions:
          - java.io.IOException
          - java.util.concurrent.TimeoutException
        ignoreExceptions:
          - com.example.BusinessException
          
      inventoryService:
        maxAttempts: 5
        waitDuration: 500ms
        enableExponentialBackoff: true
        exponentialBackoffMultiplier: 1.5
        
  bulkhead:
    instances:
      paymentService:
        maxConcurrentCalls: 25
        maxWaitDuration: 500ms
        
      inventoryService:
        maxConcurrentCalls: 50
        maxWaitDuration: 1s
        
  timelimiter:
    instances:
      paymentService:
        timeoutDuration: 5s
        cancelRunningFuture: true
        
      inventoryService:
        timeoutDuration: 3s
        
  circuitbreaker:
    instances:
      paymentService:
        registerHealthIndicator: true
        slidingWindowSize: 20
        minimumNumberOfCalls: 10
        permittedNumberOfCallsInHalfOpenState: 5
        waitDurationInOpenState: 30s
        failureRateThreshold: 50
        eventConsumerBufferSize: 10
```

### Bulkhead Pattern

```java
// src/main/java/com/example/orderservice/resilience/BulkheadConfig.java
package com.example.orderservice.resilience;

import io.github.resilience4j.bulkhead.Bulkhead;
import io.github.resilience4j.bulkhead.BulkheadConfig;
import io.github.resilience4j.bulkhead.BulkheadRegistry;
import io.github.resilience4j.bulkhead.ThreadPoolBulkhead;
import io.github.resilience4j.bulkhead.ThreadPoolBulkheadConfig;
import io.github.resilience4j.bulkhead.ThreadPoolBulkheadRegistry;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

@Configuration
public class BulkheadConfiguration {

    @Bean
    public BulkheadRegistry bulkheadRegistry() {
        BulkheadConfig config = BulkheadConfig.custom()
            .maxConcurrentCalls(25)
            .maxWaitDuration(Duration.ofMillis(500))
            .build();
            
        return BulkheadRegistry.of(config);
    }
    
    @Bean
    public ThreadPoolBulkheadRegistry threadPoolBulkheadRegistry() {
        ThreadPoolBulkheadConfig config = ThreadPoolBulkheadConfig.custom()
            .maxThreadPoolSize(10)
            .coreThreadPoolSize(5)
            .queueCapacity(100)
            .keepAliveDuration(Duration.ofMillis(100))
            .build();
            
        return ThreadPoolBulkheadRegistry.of(config);
    }
}
```

### Rate Limiter

```java
// src/main/java/com/example/orderservice/resilience/RateLimiterConfig.java
package com.example.orderservice.resilience;

import io.github.resilience4j.ratelimiter.RateLimiter;
import io.github.resilience4j.ratelimiter.RateLimiterConfig;
import io.github.resilience4j.ratelimiter.RateLimiterRegistry;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

@Configuration
public class RateLimiterConfiguration {

    @Bean
    public RateLimiterRegistry rateLimiterRegistry() {
        RateLimiterConfig config = RateLimiterConfig.custom()
            .limitRefreshPeriod(Duration.ofSeconds(1))
            .limitForPeriod(100)  // 100 requests per second
            .timeoutDuration(Duration.ofMillis(500))
            .build();
            
        return RateLimiterRegistry.of(config);
    }
    
    @Bean
    public RateLimiter orderCreationRateLimiter(RateLimiterRegistry registry) {
        return registry.rateLimiter("orderCreation", RateLimiterConfig.custom()
            .limitForPeriod(50)  // 50 orders per second max
            .limitRefreshPeriod(Duration.ofSeconds(1))
            .timeoutDuration(Duration.ofSeconds(2))
            .build());
    }
}
```

### Usage in Controller

```java
// src/main/java/com/example/orderservice/api/OrderController.java
@RestController
@RequestMapping("/api/v1/orders")
public class OrderController {

    @PostMapping
    @RateLimiter(name = "orderCreation", fallbackMethod = "createOrderFallback")
    public ResponseEntity<Order> createOrder(@Valid @RequestBody CreateOrderRequest request) {
        Order order = orderService.createOrder(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(order);
    }
    
    public ResponseEntity<Order> createOrderFallback(
            CreateOrderRequest request, RequestNotPermitted exception) {
        log.warn("Rate limit exceeded for order creation");
        throw new TooManyRequestsException("Please try again later");
    }
}
```

---

## 4. Infrastructure Self-Healing

### AKS Node Auto-Repair

```terraform
# terraform/modules/aks/main.tf
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "aks-${var.environment}"
  
  default_node_pool {
    name                = "system"
    node_count          = 3
    vm_size             = "Standard_D4s_v3"
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    
    # Enable node auto-repair
    upgrade_settings {
      max_surge = "33%"
    }
  }
  
  auto_scaler_profile {
    balance_similar_node_groups      = true
    expander                         = "random"
    max_graceful_termination_sec     = 600
    max_node_provision_time          = "15m"
    max_unready_nodes                = 3
    max_unready_percentage           = 45
    new_pod_scale_up_delay           = "10s"
    scale_down_delay_after_add       = "10m"
    scale_down_delay_after_delete    = "10s"
    scale_down_delay_after_failure   = "3m"
    scale_down_unneeded              = "10m"
    scale_down_unready               = "20m"
    scale_down_utilization_threshold = 0.5
    scan_interval                    = "10s"
    skip_nodes_with_local_storage    = true
    skip_nodes_with_system_pods      = true
  }
  
  maintenance_window {
    allowed {
      day   = "Saturday"
      hours = [2, 3, 4]
    }
    allowed {
      day   = "Sunday"
      hours = [2, 3, 4]
    }
  }
  
  maintenance_window_auto_upgrade {
    frequency    = "Weekly"
    interval     = 1
    duration     = 4
    day_of_week  = "Sunday"
    start_time   = "02:00"
    utc_offset   = "-03:00"
  }
  
  maintenance_window_node_os {
    frequency    = "Weekly"
    interval     = 1
    duration     = 4
    day_of_week  = "Saturday"
    start_time   = "02:00"
    utc_offset   = "-03:00"
  }
}
```

### Node Problem Detector

```yaml
# kubernetes/system/node-problem-detector.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-problem-detector
  namespace: kube-system
spec:
  selector:
    matchLabels:
      app: node-problem-detector
  template:
    metadata:
      labels:
        app: node-problem-detector
    spec:
      containers:
        - name: node-problem-detector
          image: k8s.gcr.io/node-problem-detector/node-problem-detector:v0.8.13
          securityContext:
            privileged: true
          env:
            - name: NODE_NAME
              valueFrom:
                fieldRef:
                  fieldPath: spec.nodeName
          volumeMounts:
            - name: log
              mountPath: /var/log
              readOnly: true
            - name: kmsg
              mountPath: /dev/kmsg
              readOnly: true
            - name: config
              mountPath: /config
          resources:
            limits:
              cpu: 10m
              memory: 80Mi
            requests:
              cpu: 10m
              memory: 80Mi
      volumes:
        - name: log
          hostPath:
            path: /var/log/
        - name: kmsg
          hostPath:
            path: /dev/kmsg
        - name: config
          configMap:
            name: node-problem-detector-config
      tolerations:
        - operator: "Exists"
          effect: "NoExecute"
        - operator: "Exists"
          effect: "NoSchedule"
```

### Automatic Node Drain on Issues

```yaml
# kubernetes/system/node-drain-controller.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: node-drain-controller-config
  namespace: kube-system
data:
  config.yaml: |
    triggers:
      - name: disk-pressure
        condition: DiskPressure
        action: drain
        gracePeriod: 300s
        
      - name: memory-pressure
        condition: MemoryPressure
        action: drain
        gracePeriod: 300s
        
      - name: network-unavailable
        condition: NetworkUnavailable
        action: drain
        gracePeriod: 60s
        
      - name: kernel-deadlock
        condition: KernelDeadlock
        action: drain
        gracePeriod: 30s
        
    drainSettings:
      timeout: 600s
      ignoreDaemonsets: true
      deleteEmptyDirData: true
      force: false
      podSelector: ""
```

---

## 5. Database Resilience

### Connection Pool Configuration

```yaml
# src/main/resources/application.yml
spring:
  datasource:
    hikari:
      # Pool sizing
      minimum-idle: 5
      maximum-pool-size: 20
      
      # Connection lifecycle
      max-lifetime: 1800000  # 30 minutes
      idle-timeout: 600000   # 10 minutes
      connection-timeout: 30000  # 30 seconds
      
      # Validation
      validation-timeout: 5000
      
      # Leak detection
      leak-detection-threshold: 60000  # 1 minute
      
      # Health checks
      connection-test-query: SELECT 1
      
      # Auto-recovery
      initialization-fail-timeout: 1
      
      # Metrics
      register-mbeans: true
      pool-name: OrderServicePool
```

### Database Failover Configuration

```yaml
# kubernetes/base/postgresql-connection.yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgresql-connection
type: Opaque
stringData:
  # Primary connection with read-write
  primary-url: |
    jdbc:postgresql://order-db.postgres.database.azure.com:5432/orders?
    sslmode=require&
    targetServerType=primary&
    hostRecheckSeconds=30&
    connectTimeout=10&
    socketTimeout=30&
    loginTimeout=10
    
  # Replica connection for read-only queries
  replica-url: |
    jdbc:postgresql://order-db-replica.postgres.database.azure.com:5432/orders?
    sslmode=require&
    targetServerType=any&
    loadBalanceHosts=true&
    connectTimeout=10
```

### Read Replica Routing

```java
// src/main/java/com/example/orderservice/config/DatabaseRoutingConfig.java
package com.example.orderservice.config;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.jdbc.datasource.lookup.AbstractRoutingDataSource;
import org.springframework.transaction.support.TransactionSynchronizationManager;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;

@Configuration
public class DatabaseRoutingConfig {

    public enum DatabaseType {
        PRIMARY, REPLICA
    }
    
    public static class RoutingDataSource extends AbstractRoutingDataSource {
        @Override
        protected Object determineCurrentLookupKey() {
            boolean isReadOnly = TransactionSynchronizationManager.isCurrentTransactionReadOnly();
            return isReadOnly ? DatabaseType.REPLICA : DatabaseType.PRIMARY;
        }
    }
    
    @Bean
    @Primary
    public DataSource routingDataSource(
            @Qualifier("primaryDataSource") DataSource primaryDataSource,
            @Qualifier("replicaDataSource") DataSource replicaDataSource) {
        
        RoutingDataSource routingDataSource = new RoutingDataSource();
        
        Map<Object, Object> targetDataSources = new HashMap<>();
        targetDataSources.put(DatabaseType.PRIMARY, primaryDataSource);
        targetDataSources.put(DatabaseType.REPLICA, replicaDataSource);
        
        routingDataSource.setTargetDataSources(targetDataSources);
        routingDataSource.setDefaultTargetDataSource(primaryDataSource);
        
        return routingDataSource;
    }
}
```

### Usage with @Transactional

```java
// Read-only queries automatically route to replica
@Transactional(readOnly = true)
public List<Order> findOrdersByUser(UUID userId) {
    return orderRepository.findByUserId(userId);
}

// Write operations route to primary
@Transactional
public Order createOrder(CreateOrderRequest request) {
    Order order = orderMapper.toEntity(request);
    return orderRepository.save(order);
}
```

---

## 6. SRE Agent Integration

### SRE Agent Configuration

```yaml
# kubernetes/sre-agent/config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: sre-agent-config
  namespace: monitoring
data:
  config.yaml: |
    agent:
      name: order-service-sre-agent
      mode: autonomous  # autonomous, supervised, manual
      
    monitoring:
      prometheus:
        url: http://prometheus:9090
      azure_monitor:
        workspace_id: ${WORKSPACE_ID}
        
    ai:
      azure_openai:
        deployment: gpt-4o
        endpoint: ${AZURE_OPENAI_ENDPOINT}
        
    remediation:
      enabled: true
      confidence_threshold: 0.85
      require_approval:
        - rollback
        - scale_down
        - configuration_change
        
    patterns:
      - name: high-error-rate
        condition: |
          rate(http_requests_total{status=~"5.."}[5m]) / 
          rate(http_requests_total[5m]) > 0.01
        actions:
          - check_recent_deployments
          - analyze_logs
          - auto_rollback_if_deployment_recent
          
      - name: high-latency
        condition: |
          histogram_quantile(0.99, 
            rate(http_request_duration_seconds_bucket[5m])) > 0.5
        actions:
          - check_database_connections
          - check_downstream_services
          - scale_up_if_cpu_high
          
      - name: pod-restart-loop
        condition: |
          increase(kube_pod_container_status_restarts_total[1h]) > 5
        actions:
          - analyze_crash_logs
          - check_memory_limits
          - notify_oncall
```

### SRE Agent Implementation

```python
# sre-agent/agent.py
import asyncio
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from prometheus_api_client import PrometheusConnect
import kubernetes

class SREAgent:
    def __init__(self, config):
        self.config = config
        self.ai_client = AIProjectClient.from_connection_string(
            conn_str=os.environ["AI_PROJECT_CONNECTION"],
            credential=DefaultAzureCredential()
        )
        self.prometheus = PrometheusConnect(url=config["monitoring"]["prometheus"]["url"])
        self.k8s = kubernetes.client.CoreV1Api()
        
    async def run(self):
        """Main agent loop."""
        while True:
            try:
                # Check all patterns
                for pattern in self.config["patterns"]:
                    if await self._check_condition(pattern["condition"]):
                        await self._handle_pattern(pattern)
                        
                await asyncio.sleep(30)
            except Exception as e:
                log.error(f"Agent error: {e}")
                await asyncio.sleep(60)
                
    async def _check_condition(self, condition: str) -> bool:
        """Evaluate Prometheus condition."""
        result = self.prometheus.custom_query(condition)
        return len(result) > 0 and float(result[0]["value"][1]) > 0
        
    async def _handle_pattern(self, pattern: dict):
        """Handle detected pattern with AI assistance."""
        
        # Gather context
        context = await self._gather_context(pattern)
        
        # Get AI analysis
        analysis = await self._get_ai_analysis(pattern, context)
        
        # Execute actions
        for action in analysis.recommended_actions:
            if self._should_auto_execute(action):
                await self._execute_action(action)
            else:
                await self._request_approval(action)
                
    async def _gather_context(self, pattern: dict) -> dict:
        """Gather relevant context for analysis."""
        return {
            "logs": await self._get_recent_logs(),
            "metrics": await self._get_metrics_snapshot(),
            "events": await self._get_k8s_events(),
            "deployments": await self._get_recent_deployments(),
            "config_changes": await self._get_recent_config_changes(),
        }
        
    async def _get_ai_analysis(self, pattern: dict, context: dict):
        """Use AI to analyze situation and recommend actions."""
        
        chat = self.ai_client.inference.get_chat_completions_client()
        
        response = await chat.complete(
            model="gpt-4o",
            messages=[
                {
                    "role": "system",
                    "content": """You are an expert SRE agent. Analyze the situation and provide:
                    1. Root cause analysis
                    2. Confidence level (0-1)
                    3. Recommended actions (ordered by priority)
                    4. Expected impact of each action
                    5. Rollback plan if action fails
                    
                    Be conservative - only recommend actions you're confident about."""
                },
                {
                    "role": "user",
                    "content": f"""
                    Pattern detected: {pattern['name']}
                    Condition: {pattern['condition']}
                    
                    Context:
                    {json.dumps(context, indent=2)}
                    """
                }
            ],
            temperature=0.1  # Low temperature for consistent analysis
        )
        
        return self._parse_analysis(response.choices[0].message.content)
        
    async def _execute_action(self, action: dict):
        """Execute remediation action."""
        
        action_handlers = {
            "rollback": self._rollback_deployment,
            "scale_up": self._scale_up,
            "scale_down": self._scale_down,
            "restart_pod": self._restart_pod,
            "update_config": self._update_config,
            "drain_node": self._drain_node,
        }
        
        handler = action_handlers.get(action["type"])
        if handler:
            log.info(f"Executing action: {action}")
            result = await handler(action["params"])
            await self._record_action(action, result)
        else:
            log.warning(f"Unknown action type: {action['type']}")
            
    async def _rollback_deployment(self, params: dict):
        """Rollback to previous deployment version."""
        
        apps_v1 = kubernetes.client.AppsV1Api()
        
        # Get deployment history
        deployment = apps_v1.read_namespaced_deployment(
            name=params["deployment"],
            namespace=params["namespace"]
        )
        
        # Rollback to previous revision
        rollback_body = {
            "name": params["deployment"],
            "rollbackTo": {
                "revision": params.get("revision", 0)  # 0 = previous
            }
        }
        
        apps_v1.patch_namespaced_deployment(
            name=params["deployment"],
            namespace=params["namespace"],
            body=rollback_body
        )
        
        return {"status": "success", "message": f"Rolled back {params['deployment']}"}
```

---

## 7. Chaos Engineering

### Azure Chaos Studio Experiments

```json
// chaos/experiments/pod-failure.json
{
  "name": "order-service-pod-failure",
  "properties": {
    "steps": [
      {
        "name": "Kill random pod",
        "branches": [
          {
            "name": "AKS pod chaos",
            "actions": [
              {
                "type": "continuous",
                "name": "urn:csci:microsoft:azureKubernetesServiceChaosMesh:podChaos/2.1",
                "duration": "PT5M",
                "parameters": [
                  {
                    "key": "jsonSpec",
                    "value": "{\"action\":\"pod-kill\",\"mode\":\"one\",\"selector\":{\"namespaces\":[\"order-service\"],\"labelSelectors\":{\"app\":\"order-service\"}}}"
                  }
                ],
                "selectorId": "selector-aks"
              }
            ]
          }
        ]
      }
    ],
    "selectors": [
      {
        "type": "List",
        "id": "selector-aks",
        "targets": [
          {
            "type": "ChaosTarget",
            "id": "/subscriptions/.../providers/Microsoft.ContainerService/managedClusters/aks-prod/providers/Microsoft.Chaos/targets/Microsoft-AzureKubernetesServiceChaosMesh"
          }
        ]
      }
    ]
  }
}
```

### Litmus Chaos Experiments

```yaml
# chaos/litmus/pod-delete.yaml
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: order-service-chaos
  namespace: order-service
spec:
  appinfo:
    appns: order-service
    applabel: "app=order-service"
    appkind: deployment
  chaosServiceAccount: litmus-admin
  experiments:
    - name: pod-delete
      spec:
        components:
          env:
            - name: TOTAL_CHAOS_DURATION
              value: "60"
            - name: CHAOS_INTERVAL
              value: "10"
            - name: FORCE
              value: "false"
            - name: PODS_AFFECTED_PERC
              value: "50"
---
apiVersion: litmuschaos.io/v1alpha1
kind: ChaosEngine
metadata:
  name: order-service-network-chaos
  namespace: order-service
spec:
  appinfo:
    appns: order-service
    applabel: "app=order-service"
    appkind: deployment
  chaosServiceAccount: litmus-admin
  experiments:
    - name: pod-network-latency
      spec:
        components:
          env:
            - name: NETWORK_LATENCY
              value: "500"  # 500ms latency
            - name: TOTAL_CHAOS_DURATION
              value: "120"
            - name: TARGET_CONTAINER
              value: "order-service"
```

### Chaos Testing Pipeline

```yaml
# .github/workflows/chaos-test.yml
name: Chaos Testing

on:
  schedule:
    - cron: '0 2 * * 1-5'  # Weekdays at 2 AM
  workflow_dispatch:

jobs:
  chaos-test:
    runs-on: ubuntu-latest
    environment: staging
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Azure Login
        uses: azure/login@v1
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          
      - name: Start baseline metrics collection
        run: |
          curl -X POST http://prometheus:9090/api/v1/admin/tsdb/snapshot
          
      - name: Run pod failure experiment
        run: |
          az rest --method post \
            --url "https://management.azure.com/subscriptions/${{ secrets.AZURE_SUBSCRIPTION_ID }}/resourceGroups/rg-staging/providers/Microsoft.Chaos/experiments/pod-failure/start?api-version=2023-11-01"
            
      - name: Wait for experiment
        run: sleep 300
        
      - name: Verify self-healing
        run: |
          # Check all pods are running
          READY_PODS=$(kubectl get pods -n order-service -l app=order-service -o jsonpath='{.items[*].status.containerStatuses[0].ready}' | tr ' ' '\n' | grep -c true)
          TOTAL_PODS=$(kubectl get pods -n order-service -l app=order-service --no-headers | wc -l)
          
          if [ "$READY_PODS" -ne "$TOTAL_PODS" ]; then
            echo "Self-healing failed: $READY_PODS/$TOTAL_PODS pods ready"
            exit 1
          fi
          
      - name: Verify SLOs maintained
        run: |
          ERROR_RATE=$(curl -s "http://prometheus:9090/api/v1/query?query=rate(http_requests_total{app='order-service',status=~'5..'}[5m])/rate(http_requests_total{app='order-service'}[5m])" | jq '.data.result[0].value[1]')
          
          if (( $(echo "$ERROR_RATE > 0.01" | bc -l) )); then
            echo "SLO violated: Error rate $ERROR_RATE > 1%"
            exit 1
          fi
          
      - name: Generate chaos report
        run: |
          python scripts/generate-chaos-report.py \
            --experiment pod-failure \
            --output chaos-report.html
            
      - name: Upload report
        uses: actions/upload-artifact@v3
        with:
          name: chaos-report
          path: chaos-report.html
```

---

## 8. Runbook Automation

### Runbook Structure

```yaml
# runbooks/high-error-rate.yaml
apiVersion: runbook.sre/v1
kind: Runbook
metadata:
  name: high-error-rate
  labels:
    service: order-service
    severity: critical
spec:
  trigger:
    alert: OrderServiceHighErrorRate
    
  context:
    gather:
      - type: logs
        query: |
          {app="order-service"} |= "error" | json
        duration: 15m
        
      - type: metrics
        queries:
          - rate(http_requests_total{app="order-service",status=~"5.."}[5m])
          - histogram_quantile(0.99, rate(http_request_duration_seconds_bucket{app="order-service"}[5m]))
          - rate(http_requests_total{app="order-service"}[5m])
          
      - type: events
        namespace: order-service
        duration: 30m
        
      - type: deployments
        namespace: order-service
        duration: 1h
        
  steps:
    - name: Check recent deployments
      condition: deployments.count > 0 AND deployments[0].age < 30m
      action:
        type: rollback
        params:
          deployment: order-service
          namespace: order-service
      onSuccess: notify_success
      onFailure: continue
      
    - name: Check database connectivity
      action:
        type: script
        script: |
          kubectl exec -n order-service deploy/order-service -- \
            curl -f http://localhost:8081/health/ready
      onSuccess: continue
      onFailure: escalate_database
      
    - name: Check downstream services
      action:
        type: parallel
        actions:
          - name: Check payment service
            script: curl -f http://payment-service/health
          - name: Check inventory service
            script: curl -f http://inventory-service/health
      onFailure: isolate_and_fallback
      
    - name: Scale up if under pressure
      condition: cpu_utilization > 80 OR memory_utilization > 85
      action:
        type: scale
        params:
          deployment: order-service
          replicas: "+2"
      onSuccess: monitor
      
  escalation:
    - level: 1
      after: 5m
      notify:
        - channel: slack
          target: "#sre-alerts"
          
    - level: 2
      after: 15m
      notify:
        - channel: pagerduty
          target: "order-service-oncall"
```

### Ansible Runbook Executor

```yaml
# ansible/playbooks/runbook-executor.yml
---
- name: Execute Runbook
  hosts: localhost
  connection: local
  
  vars:
    runbook_name: "{{ lookup('env', 'RUNBOOK_NAME') }}"
    alert_data: "{{ lookup('env', 'ALERT_DATA') | from_json }}"
    
  tasks:
    - name: Load runbook definition
      include_vars:
        file: "runbooks/{{ runbook_name }}.yaml"
        name: runbook
        
    - name: Gather context
      include_tasks: "tasks/gather-{{ item.type }}.yml"
      loop: "{{ runbook.spec.context.gather }}"
      register: context_results
      
    - name: Execute runbook steps
      include_tasks: "tasks/execute-step.yml"
      loop: "{{ runbook.spec.steps }}"
      loop_control:
        loop_var: step
      when: step.condition is not defined or (step.condition | bool)
      
    - name: Record execution
      uri:
        url: "http://runbook-tracker/api/v1/executions"
        method: POST
        body_format: json
        body:
          runbook: "{{ runbook_name }}"
          alert: "{{ alert_data }}"
          context: "{{ context_results }}"
          result: "{{ execution_result }}"
          timestamp: "{{ ansible_date_time.iso8601 }}"
```

---

## 9. Metrics & Dashboards

### Self-Healing Metrics

```yaml
# kubernetes/monitoring/self-healing-rules.yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: self-healing-metrics
  namespace: monitoring
spec:
  groups:
    - name: self-healing.rules
      rules:
        # Track automatic remediations
        - record: sre:auto_remediation_total
          expr: |
            sum(increase(sre_agent_remediation_total[24h])) by (service, action, result)
            
        # Track MTTR with self-healing
        - record: sre:mttr_with_selfhealing
          expr: |
            avg(sre_agent_incident_resolution_duration_seconds) by (service)
            
        # Self-healing success rate
        - record: sre:selfhealing_success_rate
          expr: |
            sum(sre_agent_remediation_total{result="success"}) by (service)
            /
            sum(sre_agent_remediation_total) by (service)
            
        # Track circuit breaker state
        - record: app:circuit_breaker_state
          expr: |
            resilience4j_circuitbreaker_state{state="open"}
            
        # Track retry exhaustion
        - record: app:retry_exhaustion_rate
          expr: |
            sum(rate(resilience4j_retry_calls_total{kind="failed_with_retry"}[5m])) by (name)
            /
            sum(rate(resilience4j_retry_calls_total[5m])) by (name)
```

### Grafana Dashboard

```json
{
  "dashboard": {
    "title": "Self-Healing & Resilience",
    "uid": "self-healing",
    "panels": [
      {
        "title": "Auto-Remediation Actions (24h)",
        "type": "stat",
        "gridPos": { "x": 0, "y": 0, "w": 6, "h": 4 },
        "targets": [{
          "expr": "sum(increase(sre_agent_remediation_total[24h]))"
        }]
      },
      {
        "title": "Self-Healing Success Rate",
        "type": "gauge",
        "gridPos": { "x": 6, "y": 0, "w": 6, "h": 4 },
        "targets": [{
          "expr": "sum(sre_agent_remediation_total{result='success'}) / sum(sre_agent_remediation_total) * 100"
        }],
        "options": {
          "thresholds": {
            "steps": [
              { "value": 0, "color": "red" },
              { "value": 80, "color": "yellow" },
              { "value": 95, "color": "green" }
            ]
          }
        }
      },
      {
        "title": "MTTR with Self-Healing",
        "type": "stat",
        "gridPos": { "x": 12, "y": 0, "w": 6, "h": 4 },
        "targets": [{
          "expr": "avg(sre_agent_incident_resolution_duration_seconds)"
        }],
        "options": {
          "unit": "s"
        }
      },
      {
        "title": "Circuit Breaker States",
        "type": "table",
        "gridPos": { "x": 0, "y": 4, "w": 12, "h": 6 },
        "targets": [{
          "expr": "resilience4j_circuitbreaker_state"
        }]
      },
      {
        "title": "Remediation Actions Over Time",
        "type": "timeseries",
        "gridPos": { "x": 0, "y": 10, "w": 24, "h": 8 },
        "targets": [
          {
            "expr": "sum(rate(sre_agent_remediation_total{result='success'}[1h])) by (action)",
            "legendFormat": "{{action}} (success)"
          },
          {
            "expr": "sum(rate(sre_agent_remediation_total{result='failure'}[1h])) by (action)",
            "legendFormat": "{{action}} (failure)"
          }
        ]
      }
    ]
  }
}
```

---

## Document Information

**Version:** 2.0  
**Parent:** golden_path_end_to_end_guide_v2_complete.md  
**Author:** Paula Silva (paulasilva@microsoft.com)  
**Last Updated:** December 2025
