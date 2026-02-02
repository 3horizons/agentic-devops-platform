---
name: kubectl-cli
description: 'Kubernetes kubectl CLI reference for cluster operations. Use when asked to deploy workloads, debug pods, check logs, apply manifests, configure RBAC. Covers kubectl apply, kubectl get, kubectl describe, kubectl logs, kubectl exec.'
license: Complete terms in LICENSE.txt
---

# kubectl CLI

USE FOR:
- `kubectl` commands and Kubernetes resource management
- Deploying workloads (pods, deployments, services)
- Debugging pods (`kubectl logs`, `kubectl exec`, `kubectl describe`)
- Applying Kubernetes manifests (`kubectl apply`)
- Managing namespaces and contexts
- RBAC configuration (roles, rolebindings)
- ConfigMaps and Secrets management
- Resource scaling and updates

DO NOT USE FOR:
- OpenShift-specific resources like Routes, SCCs (use oc-cli)
- Helm chart operations (use helm-cli)
- ArgoCD application management (use argocd-cli)
- Azure resource management (use azure-cli)
- AKS cluster provisioning (use terraform-cli)

Comprehensive reference for kubectl - the Kubernetes command-line tool.

**Version:** 1.31+ (current as of 2026)

## Prerequisites

### Installation

```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Windows
winget install Kubernetes.kubectl

# Verify installation
kubectl version --client
```

### Configuration

```bash
# View kubeconfig
kubectl config view

# Get current context
kubectl config current-context

# List contexts
kubectl config get-contexts

# Switch context
kubectl config use-context my-cluster

# Set namespace for context
kubectl config set-context --current --namespace=my-namespace

# View cluster info
kubectl cluster-info
```

## CLI Structure

```
kubectl                     # Root command
├── get                     # Display resources
├── describe                # Show resource details
├── create                  # Create resources
├── apply                   # Apply configuration
├── delete                  # Delete resources
├── edit                    # Edit resources
├── exec                    # Execute command in container
├── logs                    # View container logs
├── port-forward            # Forward ports
├── cp                      # Copy files
├── top                     # Show resource usage
├── rollout                 # Manage rollouts
├── scale                   # Scale deployments
├── autoscale               # Configure autoscaling
├── expose                  # Expose as service
├── run                     # Run pod
├── patch                   # Patch resources
├── label                   # Manage labels
├── annotate                # Manage annotations
├── taint                   # Manage taints
├── cordon                  # Mark node unschedulable
├── uncordon                # Mark node schedulable
├── drain                   # Drain node
├── api-resources           # List API resources
├── api-versions            # List API versions
├── explain                 # Documentation
├── diff                    # Diff configurations
├── wait                    # Wait for condition
├── auth                    # Check authorization
└── debug                   # Debug pods
```

## Resource Operations

### Get Resources

```bash
# List pods
kubectl get pods
kubectl get po

# All namespaces
kubectl get pods -A
kubectl get pods --all-namespaces

# Specific namespace
kubectl get pods -n kube-system

# Wide output
kubectl get pods -o wide

# YAML output
kubectl get pod my-pod -o yaml

# JSON output
kubectl get pod my-pod -o json

# Custom columns
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase

# JSONPath
kubectl get pods -o jsonpath='{.items[*].metadata.name}'

# Sort by
kubectl get pods --sort-by='.status.startTime'

# Label selector
kubectl get pods -l app=nginx
kubectl get pods -l 'app in (nginx,redis)'

# Field selector
kubectl get pods --field-selector=status.phase=Running

# Watch
kubectl get pods -w
```

### Common Resource Types

```bash
# Nodes
kubectl get nodes
kubectl get no

# Namespaces
kubectl get namespaces
kubectl get ns

# Deployments
kubectl get deployments
kubectl get deploy

# Services
kubectl get services
kubectl get svc

# ConfigMaps
kubectl get configmaps
kubectl get cm

# Secrets
kubectl get secrets

# Ingress
kubectl get ingress
kubectl get ing

# StatefulSets
kubectl get statefulsets
kubectl get sts

# DaemonSets
kubectl get daemonsets
kubectl get ds

# Jobs
kubectl get jobs

# CronJobs
kubectl get cronjobs

# PersistentVolumeClaims
kubectl get persistentvolumeclaims
kubectl get pvc

# All resources
kubectl get all
kubectl get all -A
```

### Describe Resources

```bash
# Describe pod
kubectl describe pod my-pod

# Describe node
kubectl describe node my-node

# Describe deployment
kubectl describe deployment my-deployment

# Describe service
kubectl describe service my-service

# Describe with events
kubectl describe pod my-pod | grep -A 20 Events
```

### Create Resources

```bash
# From file
kubectl create -f deployment.yaml

# From URL
kubectl create -f https://example.com/deployment.yaml

# Namespace
kubectl create namespace my-namespace

# ConfigMap from literal
kubectl create configmap my-config --from-literal=key1=value1

# ConfigMap from file
kubectl create configmap my-config --from-file=config.txt

# Secret from literal
kubectl create secret generic my-secret --from-literal=password=mysecret

# Secret from file
kubectl create secret generic my-secret --from-file=./secret.txt

# Service account
kubectl create serviceaccount my-sa
```

### Apply Configuration

```bash
# Apply from file
kubectl apply -f deployment.yaml

# Apply from directory
kubectl apply -f ./manifests/

# Apply recursively
kubectl apply -f ./manifests/ -R

# Apply with kustomize
kubectl apply -k ./overlays/prod/

# Dry run (client-side)
kubectl apply -f deployment.yaml --dry-run=client

# Dry run (server-side)
kubectl apply -f deployment.yaml --dry-run=server

# Apply with output
kubectl apply -f deployment.yaml -o yaml
```

### Delete Resources

```bash
# Delete pod
kubectl delete pod my-pod

# Delete from file
kubectl delete -f deployment.yaml

# Delete by label
kubectl delete pods -l app=nginx

# Delete all pods
kubectl delete pods --all

# Force delete
kubectl delete pod my-pod --force --grace-period=0

# Delete namespace (deletes all resources)
kubectl delete namespace my-namespace
```

## Workload Management

### Deployments

```bash
# Create deployment
kubectl create deployment nginx --image=nginx:latest

# Scale deployment
kubectl scale deployment nginx --replicas=5

# Set image
kubectl set image deployment/nginx nginx=nginx:1.25

# Rollout status
kubectl rollout status deployment/nginx

# Rollout history
kubectl rollout history deployment/nginx

# Rollback
kubectl rollout undo deployment/nginx
kubectl rollout undo deployment/nginx --to-revision=2

# Pause rollout
kubectl rollout pause deployment/nginx

# Resume rollout
kubectl rollout resume deployment/nginx

# Restart pods
kubectl rollout restart deployment/nginx
```

### Pod Operations

```bash
# Run pod
kubectl run nginx --image=nginx

# Run pod and expose
kubectl run nginx --image=nginx --port=80

# Run pod with command
kubectl run busybox --image=busybox --command -- sleep 3600

# Run pod interactively
kubectl run -it busybox --image=busybox --rm -- /bin/sh

# Execute command in pod
kubectl exec my-pod -- ls /
kubectl exec my-pod -c my-container -- ls /

# Interactive shell
kubectl exec -it my-pod -- /bin/sh
kubectl exec -it my-pod -- /bin/bash

# Copy files to/from pod
kubectl cp my-pod:/path/to/file ./local-file
kubectl cp ./local-file my-pod:/path/to/file
```

### Services

```bash
# Expose deployment
kubectl expose deployment nginx --port=80 --type=ClusterIP
kubectl expose deployment nginx --port=80 --type=LoadBalancer
kubectl expose deployment nginx --port=80 --type=NodePort

# Create service from file
kubectl apply -f service.yaml

# Port forward
kubectl port-forward svc/nginx 8080:80
kubectl port-forward pod/my-pod 8080:80

# Service proxy
kubectl proxy --port=8080
```

## Logging and Debugging

### Logs

```bash
# Pod logs
kubectl logs my-pod

# Container logs
kubectl logs my-pod -c my-container

# Previous container logs
kubectl logs my-pod --previous

# Follow logs
kubectl logs my-pod -f

# Last N lines
kubectl logs my-pod --tail=100

# Since duration
kubectl logs my-pod --since=1h

# All pods with label
kubectl logs -l app=nginx

# All containers in pod
kubectl logs my-pod --all-containers

# Timestamps
kubectl logs my-pod --timestamps
```

### Debug

```bash
# Debug pod (ephemeral container)
kubectl debug my-pod -it --image=busybox

# Debug with copy
kubectl debug my-pod -it --image=busybox --copy-to=my-pod-debug

# Debug node
kubectl debug node/my-node -it --image=busybox

# Get events
kubectl get events
kubectl get events --sort-by='.lastTimestamp'
kubectl get events -n my-namespace --field-selector type=Warning

# Resource usage
kubectl top nodes
kubectl top pods
kubectl top pods --containers
```

### Troubleshooting

```bash
# Check pod status
kubectl get pod my-pod -o jsonpath='{.status.conditions}'

# Check container status
kubectl get pod my-pod -o jsonpath='{.status.containerStatuses}'

# Get pod IP
kubectl get pod my-pod -o jsonpath='{.status.podIP}'

# Get node for pod
kubectl get pod my-pod -o jsonpath='{.spec.nodeName}'

# Describe for events
kubectl describe pod my-pod | grep -A 10 Events

# Check endpoints
kubectl get endpoints my-service
```

## Labels and Annotations

### Labels

```bash
# Add label
kubectl label pod my-pod app=nginx

# Update label
kubectl label pod my-pod app=nginx-v2 --overwrite

# Remove label
kubectl label pod my-pod app-

# Label selector
kubectl get pods -l app=nginx
kubectl get pods -l 'app in (nginx,redis)'
kubectl get pods -l app!=nginx
kubectl get pods -l 'app,environment'

# Label all pods
kubectl label pods --all status=healthy
```

### Annotations

```bash
# Add annotation
kubectl annotate pod my-pod description='My pod'

# Update annotation
kubectl annotate pod my-pod description='Updated' --overwrite

# Remove annotation
kubectl annotate pod my-pod description-
```

## Node Management

### Node Operations

```bash
# List nodes
kubectl get nodes
kubectl get nodes -o wide

# Node details
kubectl describe node my-node

# Node labels
kubectl label node my-node env=prod

# Node taints
kubectl taint nodes my-node key=value:NoSchedule
kubectl taint nodes my-node key:NoSchedule-

# Cordon node (mark unschedulable)
kubectl cordon my-node

# Uncordon node
kubectl uncordon my-node

# Drain node
kubectl drain my-node --ignore-daemonsets --delete-emptydir-data
```

## RBAC

### Check Permissions

```bash
# Can I?
kubectl auth can-i create pods
kubectl auth can-i delete pods --namespace=my-namespace
kubectl auth can-i '*' '*'

# As user
kubectl auth can-i create pods --as=user@example.com

# As service account
kubectl auth can-i list secrets --as=system:serviceaccount:default:my-sa

# Who can?
kubectl auth who-can create pods
```

### RBAC Resources

```bash
# List roles
kubectl get roles
kubectl get clusterroles

# List bindings
kubectl get rolebindings
kubectl get clusterrolebindings

# Describe role
kubectl describe role my-role
kubectl describe clusterrole cluster-admin
```

## Patching

### Patch Types

```bash
# Strategic merge patch
kubectl patch deployment nginx -p '{"spec":{"replicas":5}}'

# JSON patch
kubectl patch deployment nginx --type='json' \
  -p='[{"op":"replace","path":"/spec/replicas","value":5}]'

# Merge patch
kubectl patch deployment nginx --type='merge' \
  -p='{"spec":{"replicas":5}}'

# Patch from file
kubectl patch deployment nginx --patch-file=patch.yaml
```

## Diff and Validation

```bash
# Diff before apply
kubectl diff -f deployment.yaml

# Dry run (client)
kubectl apply -f deployment.yaml --dry-run=client

# Dry run (server)
kubectl apply -f deployment.yaml --dry-run=server

# Validate
kubectl apply -f deployment.yaml --validate=strict
```

## Wait Conditions

```bash
# Wait for pod ready
kubectl wait --for=condition=Ready pod/my-pod --timeout=60s

# Wait for deployment
kubectl wait --for=condition=Available deployment/nginx --timeout=120s

# Wait for deletion
kubectl wait --for=delete pod/my-pod --timeout=60s

# Wait for job completion
kubectl wait --for=condition=complete job/my-job --timeout=300s
```

## API Resources

```bash
# List API resources
kubectl api-resources

# List with verbs
kubectl api-resources --verbs=list,get

# API versions
kubectl api-versions

# Explain resource
kubectl explain pod
kubectl explain pod.spec
kubectl explain pod.spec.containers
kubectl explain deployment.spec.strategy
```

## Context and Config

### Manage Contexts

```bash
# View config
kubectl config view

# List clusters
kubectl config get-clusters

# List contexts
kubectl config get-contexts

# Current context
kubectl config current-context

# Use context
kubectl config use-context my-context

# Delete context
kubectl config delete-context my-context

# Set namespace
kubectl config set-context --current --namespace=my-namespace

# Rename context
kubectl config rename-context old-name new-name
```

### Manage Clusters

```bash
# Set cluster
kubectl config set-cluster my-cluster --server=https://api.example.com

# Set credentials
kubectl config set-credentials my-user --token=my-token

# Set context
kubectl config set-context my-context --cluster=my-cluster --user=my-user
```

## Plugins (Krew)

```bash
# Install krew
kubectl krew install krew

# Search plugins
kubectl krew search

# Install plugin
kubectl krew install ctx
kubectl krew install ns
kubectl krew install neat

# Use plugins
kubectl ctx
kubectl ns
kubectl neat get pod my-pod -o yaml
```

## Output Formats

```bash
# Wide
kubectl get pods -o wide

# YAML
kubectl get pod my-pod -o yaml

# JSON
kubectl get pod my-pod -o json

# Name only
kubectl get pods -o name

# Custom columns
kubectl get pods -o custom-columns=\
'NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP'

# JSONPath
kubectl get pods -o jsonpath='{.items[*].metadata.name}'
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'

# Go template
kubectl get pods -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
```

## Common Workflows

### Deploy Application

```bash
# Create namespace
kubectl create namespace my-app

# Apply manifests
kubectl apply -f ./manifests/ -n my-app

# Wait for deployment
kubectl rollout status deployment/my-app -n my-app

# Verify
kubectl get all -n my-app
```

### Debug Pod

```bash
# Check pod status
kubectl get pod my-pod -o wide

# Check events
kubectl describe pod my-pod | grep -A 20 Events

# Check logs
kubectl logs my-pod --previous

# Debug with ephemeral container
kubectl debug my-pod -it --image=busybox -- /bin/sh

# Port forward for local testing
kubectl port-forward pod/my-pod 8080:80
```

### Rolling Update

```bash
# Update image
kubectl set image deployment/nginx nginx=nginx:1.25

# Watch rollout
kubectl rollout status deployment/nginx

# Check history
kubectl rollout history deployment/nginx

# Rollback if needed
kubectl rollout undo deployment/nginx
```

## Best Practices

1. **Use namespaces**: Organize resources by namespace
2. **Use labels**: Label everything for easy selection
3. **Dry run first**: Use `--dry-run=server` before apply
4. **Check diff**: Use `kubectl diff` before apply
5. **Use declarative**: Prefer `apply` over `create`
6. **Resource limits**: Always set resource limits
7. **Health checks**: Configure liveness and readiness probes
8. **RBAC**: Use least-privilege access
9. **Plugins**: Use krew for extended functionality
10. **Context alias**: Use context/namespace plugins for productivity

## References

- [kubectl Reference](https://kubernetes.io/docs/reference/kubectl/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [JSONPath Support](https://kubernetes.io/docs/reference/kubectl/jsonpath/)
