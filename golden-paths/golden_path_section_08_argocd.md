# Golden Path Section 8: GitOps Deployment (ArgoCD)

## Declarative Continuous Delivery for Kubernetes

**Version:** 2.0  
**Parent Document:** golden_path_end_to_end_guide_v2_complete.md  
**Author:** paulasilva@microsoft.com  
**Last Updated:** December 2025

---

## Table of Contents

1. [Overview](#1-overview)
2. [ArgoCD Architecture](#2-argocd-architecture)
3. [Application Definitions](#3-application-definitions)
4. [ApplicationSet Patterns](#4-applicationset-patterns)
5. [Sync Strategies](#5-sync-strategies)
6. [Blue-Green with ArgoCD](#6-blue-green-with-argocd)
7. [Canary Deployments](#7-canary-deployments)
8. [RHDH Integration](#8-rhdh-integration)
9. [Security & RBAC](#9-security--rbac)
10. [Troubleshooting](#10-troubleshooting)

---

## 1. Overview

ArgoCD provides GitOps-based continuous delivery for the Golden Path platform, ensuring that the desired state in Git is automatically synchronized to Kubernetes clusters.

### GitOps Principles

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         GITOPS WORKFLOW                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────┐     ┌─────────────┐     ┌─────────────┐                   │
│  │  Developer  │     │   GitHub    │     │   ArgoCD    │                   │
│  │             │     │   (Git)     │     │             │                   │
│  └──────┬──────┘     └──────┬──────┘     └──────┬──────┘                   │
│         │                   │                   │                           │
│         │ 1. Push changes   │                   │                           │
│         │──────────────────►│                   │                           │
│         │                   │                   │                           │
│         │                   │ 2. Webhook        │                           │
│         │                   │──────────────────►│                           │
│         │                   │                   │                           │
│         │                   │                   │ 3. Compare Git vs Cluster │
│         │                   │                   │──────────────────────────►│
│         │                   │                   │                           │
│         │                   │                   │ 4. Sync (if drift)        │
│         │                   │                   │──────────────────────────►│
│         │                   │                   │                    ┌──────┴──────┐
│         │                   │                   │                    │     AKS     │
│         │                   │                   │                    │   Cluster   │
│         │                   │                   │                    └─────────────┘
│         │                   │                   │                           │
│         │                   │ 5. Update status  │                           │
│         │                   │◄──────────────────│                           │
│         │                   │                   │                           │
│         │ 6. PR status      │                   │                           │
│         │◄──────────────────│                   │                           │
│                                                                             │
│  KEY PRINCIPLES:                                                            │
│  ─────────────────                                                          │
│  • Git is the single source of truth                                        │
│  • Declarative desired state                                                │
│  • Automated reconciliation                                                 │
│  • Audit trail via Git history                                              │
│  • Pull-based deployment (more secure)                                      │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Role in Golden Path

| Stage | ArgoCD Responsibility |
|-------|----------------------|
| **Scaffolding** | RHDH generates ArgoCD Application manifests |
| **CI** | GitHub Actions builds image, updates manifests |
| **CD** | ArgoCD detects changes, syncs to cluster |
| **Validation** | ArgoCD health checks, sync status |
| **Rollback** | Git revert triggers automatic rollback |

---

## 2. ArgoCD Architecture

### Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                       ARGOCD ARCHITECTURE                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │                    ARGOCD NAMESPACE                                  │   │
│  │                                                                      │   │
│  │  ┌────────────────┐  ┌────────────────┐  ┌────────────────┐        │   │
│  │  │   API Server   │  │ Repo Server    │  │ Application    │        │   │
│  │  │                │  │                │  │ Controller     │        │   │
│  │  │ • REST/gRPC    │  │ • Git clone    │  │                │        │   │
│  │  │ • Auth         │  │ • Manifest     │  │ • Watch Git    │        │   │
│  │  │ • RBAC         │  │   generation   │  │ • Reconcile    │        │   │
│  │  │ • Webhook      │  │ • Helm/Kust    │  │ • Sync         │        │   │
│  │  └───────┬────────┘  └───────┬────────┘  └───────┬────────┘        │   │
│  │          │                   │                   │                  │   │
│  │          └───────────────────┼───────────────────┘                  │   │
│  │                              │                                      │   │
│  │  ┌────────────────┐  ┌──────┴───────┐  ┌────────────────┐          │   │
│  │  │     Redis      │  │   Dex/SSO    │  │ Notifications  │          │   │
│  │  │   (Cache)      │  │              │  │  Controller    │          │   │
│  │  └────────────────┘  └──────────────┘  └────────────────┘          │   │
│  │                                                                      │   │
│  └─────────────────────────────────────────────────────────────────────┘   │
│                              │                                              │
│          ┌───────────────────┼───────────────────┐                         │
│          ▼                   ▼                   ▼                         │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐                 │
│  │  AKS Dev     │    │ AKS Staging  │    │  AKS Prod    │                 │
│  │  Cluster     │    │   Cluster    │    │   Cluster    │                 │
│  └──────────────┘    └──────────────┘    └──────────────┘                 │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### ArgoCD Installation (Helm)

```yaml
# argocd/values.yaml
global:
  domain: argocd.example.com

server:
  replicas: 2
  
  ingress:
    enabled: true
    ingressClassName: nginx
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    hosts:
      - argocd.example.com
    tls:
      - secretName: argocd-server-tls
        hosts:
          - argocd.example.com
          
  config:
    url: https://argocd.example.com
    application.instanceLabelKey: argocd.argoproj.io/instance
    
    # OIDC with Microsoft Entra ID
    oidc.config: |
      name: Microsoft
      issuer: https://login.microsoftonline.com/${TENANT_ID}/v2.0
      clientID: ${CLIENT_ID}
      clientSecret: $oidc.azure.clientSecret
      requestedScopes:
        - openid
        - profile
        - email
        
    # Resource tracking
    resource.customizations: |
      networking.k8s.io/Ingress:
        health.lua: |
          hs = {}
          hs.status = "Healthy"
          return hs

  rbacConfig:
    policy.default: role:readonly
    policy.csv: |
      g, platform-team, role:admin
      g, dev-team, role:developer
      p, role:developer, applications, *, */*, allow
      p, role:developer, repositories, get, *, allow

controller:
  replicas: 1
  
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
      
repoServer:
  replicas: 2
  
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true

redis:
  enabled: true
  
applicationSet:
  enabled: true
  replicas: 2

notifications:
  enabled: true
  
  argocdUrl: https://argocd.example.com
  
  secret:
    create: false
    name: argocd-notifications-secret
    
  notifiers:
    service.slack: |
      token: $slack-token
    service.github: |
      appID: $github-app-id
      installationID: $github-installation-id
      privateKey: $github-private-key
      
  subscriptions:
    - recipients:
        - slack:deployments
      triggers:
        - on-sync-succeeded
        - on-sync-failed
        - on-health-degraded
        
  templates:
    template.app-sync-succeeded: |
      message: |
        {{if eq .serviceType "slack"}}:white_check_mark:{{end}} Application {{.app.metadata.name}} sync succeeded
      slack:
        attachments: |
          [{
            "color": "#18be52",
            "fields": [{
              "title": "Application",
              "value": "{{.app.metadata.name}}",
              "short": true
            }, {
              "title": "Revision",
              "value": "{{.app.status.sync.revision}}",
              "short": true
            }]
          }]
```

---

## 3. Application Definitions

### Standard Application

```yaml
# argocd/applications/service-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-service
  namespace: argocd
  labels:
    app.kubernetes.io/name: my-service
    app.kubernetes.io/part-of: golden-path
    environment: dev
  annotations:
    argocd.argoproj.io/manifest-generate-paths: .
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  project: default
  
  source:
    repoURL: https://github.com/org/my-service.git
    targetRevision: main
    path: kubernetes/overlays/dev
    
    # Kustomize configuration
    kustomize:
      images:
        - my-service=myacr.azurecr.io/my-service
      commonLabels:
        app.kubernetes.io/managed-by: argocd
        
  destination:
    server: https://kubernetes.default.svc
    namespace: my-service
    
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
      allowEmpty: false
    syncOptions:
      - CreateNamespace=true
      - PrunePropagationPolicy=foreground
      - PruneLast=true
      - ApplyOutOfSyncOnly=true
      - ServerSideApply=true
    retry:
      limit: 5
      backoff:
        duration: 5s
        factor: 2
        maxDuration: 3m
        
  ignoreDifferences:
    - group: apps
      kind: Deployment
      jsonPointers:
        - /spec/replicas
    - group: autoscaling
      kind: HorizontalPodAutoscaler
      jqPathExpressions:
        - .spec.minReplicas
        - .spec.maxReplicas
        
  revisionHistoryLimit: 10
```

### Helm-Based Application

```yaml
# argocd/applications/helm-app.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-helm-service
  namespace: argocd
spec:
  project: default
  
  source:
    repoURL: https://github.com/org/my-service.git
    targetRevision: main
    path: helm/my-service
    
    helm:
      releaseName: my-service
      
      # Values files (in order of precedence)
      valueFiles:
        - values.yaml
        - values-dev.yaml
        
      # Inline values (highest precedence)
      values: |
        image:
          repository: myacr.azurecr.io/my-service
          tag: latest
        replicaCount: 2
        
      # Individual parameters
      parameters:
        - name: service.type
          value: ClusterIP
        - name: ingress.enabled
          value: "true"
          
      # Skip CRDs
      skipCrds: false
      
  destination:
    server: https://kubernetes.default.svc
    namespace: my-service
    
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## 4. ApplicationSet Patterns

### Multi-Environment ApplicationSet

```yaml
# argocd/applicationsets/multi-env.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: my-service-environments
  namespace: argocd
spec:
  generators:
    - list:
        elements:
          - env: dev
            cluster: aks-dev
            clusterUrl: https://aks-dev-xxxx.hcp.eastus.azmk8s.io:443
            replicas: "2"
            autoSync: "true"
          - env: staging
            cluster: aks-staging
            clusterUrl: https://aks-staging-xxxx.hcp.eastus.azmk8s.io:443
            replicas: "3"
            autoSync: "true"
          - env: prod
            cluster: aks-prod
            clusterUrl: https://aks-prod-xxxx.hcp.eastus.azmk8s.io:443
            replicas: "5"
            autoSync: "false"  # Manual sync for prod
            
  template:
    metadata:
      name: 'my-service-{{env}}'
      namespace: argocd
      labels:
        app.kubernetes.io/name: my-service
        environment: '{{env}}'
    spec:
      project: default
      
      source:
        repoURL: https://github.com/org/my-service.git
        targetRevision: main
        path: 'kubernetes/overlays/{{env}}'
        kustomize:
          images:
            - 'my-service=myacr.azurecr.io/my-service:{{env}}'
            
      destination:
        server: '{{clusterUrl}}'
        namespace: my-service
        
      syncPolicy:
        automated:
          prune: '{{autoSync}}'
          selfHeal: '{{autoSync}}'
        syncOptions:
          - CreateNamespace=true
```

### Git Directory Generator

```yaml
# argocd/applicationsets/git-directory.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: services-from-directories
  namespace: argocd
spec:
  generators:
    - git:
        repoURL: https://github.com/org/services-monorepo.git
        revision: main
        directories:
          - path: services/*
          - path: services/deprecated/*
            exclude: true
            
  template:
    metadata:
      name: '{{path.basename}}'
      namespace: argocd
      labels:
        app.kubernetes.io/name: '{{path.basename}}'
    spec:
      project: default
      
      source:
        repoURL: https://github.com/org/services-monorepo.git
        targetRevision: main
        path: '{{path}}/kubernetes'
        
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{path.basename}}'
        
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
```

### Pull Request Generator

```yaml
# argocd/applicationsets/pull-request.yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: my-service-pull-requests
  namespace: argocd
spec:
  generators:
    - pullRequest:
        github:
          owner: org
          repo: my-service
          tokenRef:
            secretName: github-token
            key: token
          labels:
            - preview
        requeueAfterSeconds: 60
        
  template:
    metadata:
      name: 'my-service-pr-{{number}}'
      namespace: argocd
      labels:
        app.kubernetes.io/name: my-service
        preview: "true"
        pull-request: '{{number}}'
    spec:
      project: default
      
      source:
        repoURL: 'https://github.com/org/my-service.git'
        targetRevision: '{{head_sha}}'
        path: kubernetes/overlays/preview
        kustomize:
          nameSuffix: '-pr-{{number}}'
          commonLabels:
            pull-request: '{{number}}'
          images:
            - 'my-service=myacr.azurecr.io/my-service:pr-{{number}}'
            
      destination:
        server: https://kubernetes.default.svc
        namespace: 'my-service-pr-{{number}}'
        
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true
```

---

## 5. Sync Strategies

### Sync Waves and Hooks

```yaml
# kubernetes/base/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: my-service
  annotations:
    argocd.argoproj.io/sync-wave: "-2"
---
# kubernetes/base/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-service-config
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
data:
  config.yaml: |
    key: value
---
# kubernetes/base/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-service
  annotations:
    argocd.argoproj.io/sync-wave: "0"
spec:
  # ...
---
# kubernetes/base/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: my-service
  annotations:
    argocd.argoproj.io/sync-wave: "1"
spec:
  # ...
```

### Pre-Sync and Post-Sync Hooks

```yaml
# kubernetes/hooks/pre-sync-migration.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: BeforeHookCreation
spec:
  template:
    spec:
      containers:
        - name: migration
          image: myacr.azurecr.io/my-service:latest
          command: ["./migrate.sh"]
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: db-credentials
                  key: url
      restartPolicy: Never
  backoffLimit: 3
---
# kubernetes/hooks/post-sync-notification.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: notify-deployment
  annotations:
    argocd.argoproj.io/hook: PostSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
spec:
  template:
    spec:
      containers:
        - name: notify
          image: curlimages/curl:latest
          command:
            - /bin/sh
            - -c
            - |
              curl -X POST $SLACK_WEBHOOK \
                -H 'Content-type: application/json' \
                --data '{"text":"Deployment successful!"}'
          env:
            - name: SLACK_WEBHOOK
              valueFrom:
                secretKeyRef:
                  name: slack-webhook
                  key: url
      restartPolicy: Never
```

### Sync Windows

```yaml
# argocd/projects/production.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: production
  namespace: argocd
spec:
  description: Production applications
  
  sourceRepos:
    - 'https://github.com/org/*'
    
  destinations:
    - namespace: '*'
      server: https://aks-prod-xxxx.hcp.eastus.azmk8s.io:443
      
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
    - group: networking.k8s.io
      kind: NetworkPolicy
      
  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota
    - group: ''
      kind: LimitRange
      
  # Sync windows - only allow syncs during maintenance windows
  syncWindows:
    - kind: allow
      schedule: '0 2 * * 1-5'  # 2 AM Mon-Fri
      duration: 2h
      applications:
        - '*'
      manualSync: true
      
    - kind: deny
      schedule: '0 8-18 * * 1-5'  # Business hours Mon-Fri
      duration: 10h
      applications:
        - '*'
      manualSync: false
      
    - kind: allow
      schedule: '0 0 * * 0'  # Midnight Sunday
      duration: 4h
      applications:
        - '*'
      manualSync: true
```

---

## 6. Blue-Green with ArgoCD

### Blue-Green Rollout

```yaml
# kubernetes/rollout/blue-green.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: my-service
spec:
  replicas: 5
  
  selector:
    matchLabels:
      app: my-service
      
  template:
    metadata:
      labels:
        app: my-service
    spec:
      containers:
        - name: my-service
          image: myacr.azurecr.io/my-service:latest
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 8080
            initialDelaySeconds: 10
            periodSeconds: 5
            
  strategy:
    blueGreen:
      activeService: my-service-active
      previewService: my-service-preview
      
      # Automatic promotion after successful analysis
      autoPromotionEnabled: true
      autoPromotionSeconds: 300  # 5 minutes
      
      # Scale down delay
      scaleDownDelaySeconds: 60
      
      # Preview replica count
      previewReplicaCount: 2
      
      # Pre-promotion analysis
      prePromotionAnalysis:
        templates:
          - templateName: success-rate
          - templateName: latency-check
        args:
          - name: service-name
            value: my-service-preview
            
      # Post-promotion analysis
      postPromotionAnalysis:
        templates:
          - templateName: success-rate
        args:
          - name: service-name
            value: my-service-active
            
      # Anti-affinity between blue and green
      antiAffinity:
        preferredDuringSchedulingIgnoredDuringExecution:
          weight: 100
```

### Analysis Templates

```yaml
# kubernetes/rollout/analysis-templates.yaml
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: success-rate
spec:
  args:
    - name: service-name
  metrics:
    - name: success-rate
      interval: 30s
      count: 10
      successCondition: result[0] >= 0.99
      failureLimit: 3
      provider:
        prometheus:
          address: http://prometheus.monitoring.svc.cluster.local:9090
          query: |
            sum(rate(http_requests_total{service="{{args.service-name}}", code=~"2.."}[5m]))
            /
            sum(rate(http_requests_total{service="{{args.service-name}}"}[5m]))
---
apiVersion: argoproj.io/v1alpha1
kind: AnalysisTemplate
metadata:
  name: latency-check
spec:
  args:
    - name: service-name
  metrics:
    - name: latency-p99
      interval: 30s
      count: 10
      successCondition: result[0] <= 0.5  # 500ms
      failureLimit: 3
      provider:
        prometheus:
          address: http://prometheus.monitoring.svc.cluster.local:9090
          query: |
            histogram_quantile(0.99,
              sum(rate(http_request_duration_seconds_bucket{service="{{args.service-name}}"}[5m])) by (le)
            )
```

---

## 7. Canary Deployments

### Canary Rollout Strategy

```yaml
# kubernetes/rollout/canary.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: my-service
spec:
  replicas: 10
  
  selector:
    matchLabels:
      app: my-service
      
  template:
    metadata:
      labels:
        app: my-service
    spec:
      containers:
        - name: my-service
          image: myacr.azurecr.io/my-service:latest
          ports:
            - containerPort: 8080
            
  strategy:
    canary:
      # Traffic routing using Nginx Ingress
      canaryService: my-service-canary
      stableService: my-service-stable
      
      trafficRouting:
        nginx:
          stableIngress: my-service-ingress
          annotationPrefix: nginx.ingress.kubernetes.io
          additionalIngressAnnotations:
            canary-by-header: X-Canary
            canary-by-header-value: "true"
            
      # Progressive traffic steps
      steps:
        - setWeight: 5
        - pause: {duration: 2m}
        - analysis:
            templates:
              - templateName: success-rate
            args:
              - name: service-name
                value: my-service-canary
                
        - setWeight: 10
        - pause: {duration: 5m}
        - analysis:
            templates:
              - templateName: success-rate
              - templateName: latency-check
            args:
              - name: service-name
                value: my-service-canary
                
        - setWeight: 25
        - pause: {duration: 10m}
        - analysis:
            templates:
              - templateName: success-rate
              - templateName: latency-check
            args:
              - name: service-name
                value: my-service-canary
                
        - setWeight: 50
        - pause: {duration: 15m}
        - analysis:
            templates:
              - templateName: success-rate
              - templateName: latency-check
              - templateName: error-budget
            args:
              - name: service-name
                value: my-service-canary
                
        - setWeight: 100
        
      # Anti-affinity for canary pods
      canaryMetadata:
        labels:
          role: canary
      stableMetadata:
        labels:
          role: stable
          
      # Max surge and unavailable
      maxSurge: "25%"
      maxUnavailable: 0
```

### Canary with Istio

```yaml
# kubernetes/rollout/canary-istio.yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: my-service
spec:
  replicas: 10
  
  selector:
    matchLabels:
      app: my-service
      
  template:
    metadata:
      labels:
        app: my-service
    spec:
      containers:
        - name: my-service
          image: myacr.azurecr.io/my-service:latest
          
  strategy:
    canary:
      trafficRouting:
        istio:
          virtualService:
            name: my-service-vsvc
            routes:
              - primary
          destinationRule:
            name: my-service-destrule
            canarySubsetName: canary
            stableSubsetName: stable
            
      steps:
        - setWeight: 5
        - pause: {duration: 2m}
        - setWeight: 20
        - pause: {duration: 5m}
        - setWeight: 50
        - pause: {duration: 10m}
        - setWeight: 100
---
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: my-service-vsvc
spec:
  hosts:
    - my-service
  http:
    - name: primary
      route:
        - destination:
            host: my-service
            subset: stable
          weight: 100
        - destination:
            host: my-service
            subset: canary
          weight: 0
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: my-service-destrule
spec:
  host: my-service
  subsets:
    - name: stable
      labels:
        app: my-service
    - name: canary
      labels:
        app: my-service
```

---

## 8. RHDH Integration

### ArgoCD Plugin Configuration

```yaml
# app-config.yaml (RHDH)
argocd:
  baseUrl: https://argocd.example.com
  
  appLocatorMethods:
    - type: config
      instances:
        - name: main
          url: https://argocd.example.com
          token: ${ARGOCD_TOKEN}
          
kubernetes:
  serviceLocatorMethod:
    type: multiTenant
  clusterLocatorMethods:
    - type: config
      clusters:
        - url: https://aks-dev-xxxx.hcp.eastus.azmk8s.io:443
          name: aks-dev
          authProvider: serviceAccount
          serviceAccountToken: ${AKS_DEV_TOKEN}
          
catalog:
  providers:
    argocd:
      production:
        appLocatorMethods:
          - type: config
            instances:
              - name: main
                url: https://argocd.example.com
                token: ${ARGOCD_TOKEN}
```

### catalog-info.yaml with ArgoCD Annotations

```yaml
# catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  description: My Golden Path Service
  annotations:
    # ArgoCD annotations
    argocd/app-name: my-service-dev
    argocd/app-namespace: argocd
    argocd/project-name: default
    
    # Kubernetes annotations
    backstage.io/kubernetes-id: my-service
    backstage.io/kubernetes-namespace: my-service
    backstage.io/kubernetes-label-selector: app=my-service
    
    # GitHub annotations
    github.com/project-slug: org/my-service
    
    # TechDocs
    backstage.io/techdocs-ref: dir:.
    
  labels:
    system: platform
    tier: backend
    
  links:
    - url: https://argocd.example.com/applications/my-service-dev
      title: ArgoCD Dev
      icon: dashboard
    - url: https://grafana.example.com/d/my-service
      title: Grafana Dashboard
      icon: dashboard
      
spec:
  type: service
  lifecycle: production
  owner: platform-team
  system: golden-path
  
  dependsOn:
    - resource:postgresql-dev
    
  providesApis:
    - my-service-api
```

### Scaffolder Action for ArgoCD

```yaml
# template.yaml - ArgoCD Registration Step
steps:
  - id: create-argocd-app
    name: Create ArgoCD Application
    action: argocd:create-resources
    input:
      appName: ${{ parameters.serviceName }}-${{ parameters.environment }}
      argoInstance: main
      projectName: default
      repoUrl: ${{ steps['publish'].output.remoteUrl }}
      path: kubernetes/overlays/${{ parameters.environment }}
      namespace: ${{ parameters.serviceName }}
      
  - id: argocd-sync
    name: Sync ArgoCD Application
    action: argocd:app:sync
    input:
      appName: ${{ parameters.serviceName }}-${{ parameters.environment }}
      argoInstance: main
      waitForHealthy: true
      timeout: 300
```

---

## 9. Security & RBAC

### AppProject with RBAC

```yaml
# argocd/projects/team-project.yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: team-alpha
  namespace: argocd
spec:
  description: Team Alpha's project
  
  # Source repositories
  sourceRepos:
    - 'https://github.com/org/team-alpha-*'
    - 'https://github.com/org/shared-libs'
    
  # Allowed destinations
  destinations:
    - namespace: 'team-alpha-*'
      server: https://kubernetes.default.svc
    - namespace: 'team-alpha-*'
      server: https://aks-dev-xxxx.hcp.eastus.azmk8s.io:443
      
  # Cluster resources that can be managed
  clusterResourceWhitelist:
    - group: ''
      kind: Namespace
      
  # Namespace resources that cannot be managed
  namespaceResourceBlacklist:
    - group: ''
      kind: ResourceQuota
    - group: ''
      kind: LimitRange
    - group: ''
      kind: NetworkPolicy
      
  # Roles
  roles:
    - name: developer
      description: Team Alpha developers
      policies:
        - p, proj:team-alpha:developer, applications, get, team-alpha/*, allow
        - p, proj:team-alpha:developer, applications, sync, team-alpha/*, allow
        - p, proj:team-alpha:developer, applications, action/*, team-alpha/*, allow
        - p, proj:team-alpha:developer, logs, get, team-alpha/*, allow
      groups:
        - team-alpha-developers
        
    - name: admin
      description: Team Alpha admins
      policies:
        - p, proj:team-alpha:admin, applications, *, team-alpha/*, allow
        - p, proj:team-alpha:admin, repositories, *, team-alpha/*, allow
      groups:
        - team-alpha-admins
```

### Secret Management

```yaml
# argocd/secrets/repo-creds.yaml
apiVersion: v1
kind: Secret
metadata:
  name: github-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/org
  password: ${GITHUB_TOKEN}
  username: not-used
---
# argocd/secrets/cluster-creds.yaml
apiVersion: v1
kind: Secret
metadata:
  name: aks-prod-cluster
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: cluster
stringData:
  name: aks-prod
  server: https://aks-prod-xxxx.hcp.eastus.azmk8s.io:443
  config: |
    {
      "bearerToken": "${AKS_PROD_TOKEN}",
      "tlsClientConfig": {
        "insecure": false,
        "caData": "${AKS_PROD_CA}"
      }
    }
```

---

## 10. Troubleshooting

### Common Issues and Solutions

| Issue | Symptoms | Solution |
|-------|----------|----------|
| **Sync Failed** | Application stuck in "OutOfSync" | Check resource health, validate manifests |
| **Health Degraded** | Pods not ready | Check pod logs, resource limits |
| **Permission Denied** | Sync fails with 403 | Verify RBAC, service account permissions |
| **Manifest Generation Error** | Repo server errors | Check Helm/Kustomize syntax |
| **Webhook Not Triggering** | Manual sync required | Verify webhook configuration, secrets |

### Debugging Commands

```bash
# Check application status
argocd app get my-service

# View sync status
argocd app sync my-service --dry-run

# Check application logs
argocd app logs my-service

# View resource tree
argocd app resources my-service

# Compare manifests
argocd app diff my-service

# Force refresh
argocd app get my-service --refresh

# Hard refresh (clear cache)
argocd app get my-service --hard-refresh

# View history
argocd app history my-service

# Rollback
argocd app rollback my-service <revision>

# Check repo server logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-repo-server

# Check application controller logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller
```

### Health Check Troubleshooting

```yaml
# Custom health check for CRDs
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  resource.customizations.health.external-secrets.io_ExternalSecret: |
    hs = {}
    if obj.status ~= nil then
      if obj.status.conditions ~= nil then
        for i, condition in ipairs(obj.status.conditions) do
          if condition.type == "Ready" and condition.status == "False" then
            hs.status = "Degraded"
            hs.message = condition.message
            return hs
          end
          if condition.type == "Ready" and condition.status == "True" then
            hs.status = "Healthy"
            hs.message = "Secret synced successfully"
            return hs
          end
        end
      end
    end
    hs.status = "Progressing"
    hs.message = "Waiting for secret sync"
    return hs
```

---

## Document Information

**Version:** 2.0  
**Parent:** golden_path_end_to_end_guide_v2_complete.md  
**Author:** Paula Silva (paulasilva@microsoft.com)  
**Last Updated:** December 2025
