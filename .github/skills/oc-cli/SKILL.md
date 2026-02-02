---
name: oc-cli
description: 'OpenShift CLI (oc) reference for ARO and OpenShift operations. Use when working with routes, projects, SCCs, image streams, and OpenShift-specific resources.'
---

# OpenShift CLI (oc) Skill

USE FOR:
- `oc` commands and OpenShift resource management
- Routes, Projects, Security Context Constraints (SCCs)
- Image Streams, BuildConfigs, DeploymentConfigs
- OpenShift-specific RBAC and permissions
- ARO (Azure Red Hat OpenShift) cluster operations
- Template processing with `oc process`
- Debugging with `oc debug`, `oc rsh`, `oc logs`

DO NOT USE FOR:
- Vanilla Kubernetes resources (use kubectl-cli)
- Azure resource management (use azure-cli)
- ARO cluster provisioning via Terraform (use aro-deployment skill)
- Helm chart operations (use helm-cli)

## Prerequisites

```bash
# Install OpenShift CLI
# macOS
brew install openshift-cli

# Linux (download from OpenShift mirror)
curl -LO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz
tar xzf openshift-client-linux.tar.gz
sudo mv oc kubectl /usr/local/bin/

# Verify installation
oc version
```

## Authentication

### Login to ARO Cluster

```bash
# Get ARO API server URL
API_SERVER=$(az aro show \
  --name ${CLUSTER_NAME} \
  --resource-group ${RESOURCE_GROUP} \
  --query apiserverProfile.url -o tsv)

# Get kubeadmin credentials
KUBEADMIN_PASSWORD=$(az aro list-credentials \
  --name ${CLUSTER_NAME} \
  --resource-group ${RESOURCE_GROUP} \
  --query kubeadminPassword -o tsv)

# Login with kubeadmin
oc login ${API_SERVER} \
  --username kubeadmin \
  --password ${KUBEADMIN_PASSWORD}

# Login with token (for service accounts)
oc login ${API_SERVER} --token=${TOKEN}

# Logout
oc logout
```

### Authentication Status

```bash
# Check current user
oc whoami

# Check current context
oc whoami --show-context

# Check current server
oc whoami --show-server

# Get current token
oc whoami -t
```

## Project Management

```bash
# List all projects
oc get projects

# Create new project
oc new-project ${PROJECT_NAME} \
  --description="Project description" \
  --display-name="Display Name"

# Switch to project
oc project ${PROJECT_NAME}

# Delete project
oc delete project ${PROJECT_NAME}

# Get current project
oc project
```

## Resource Operations

### Basic CRUD

```bash
# Get resources
oc get pods
oc get deployments
oc get services
oc get routes
oc get configmaps
oc get secrets

# Get resources in all namespaces
oc get pods --all-namespaces
oc get pods -A

# Describe resource
oc describe pod ${POD_NAME}
oc describe route ${ROUTE_NAME}

# Create from YAML
oc apply -f resource.yaml
oc create -f resource.yaml

# Delete resource
oc delete pod ${POD_NAME}
oc delete -f resource.yaml

# Edit resource
oc edit deployment ${DEPLOYMENT_NAME}

# Get YAML output
oc get deployment ${DEPLOYMENT_NAME} -o yaml
```

### Labels and Selectors

```bash
# Get pods with label
oc get pods -l app=myapp

# Add label
oc label pod ${POD_NAME} env=production

# Remove label
oc label pod ${POD_NAME} env-

# Annotate resource
oc annotate pod ${POD_NAME} description="My pod"
```

## Routes

```bash
# Create route from service
oc expose service ${SERVICE_NAME}

# Create route with custom hostname
oc expose service ${SERVICE_NAME} \
  --hostname=${CUSTOM_HOSTNAME}

# Create edge TLS route
oc create route edge ${ROUTE_NAME} \
  --service=${SERVICE_NAME} \
  --cert=tls.crt \
  --key=tls.key

# Create passthrough TLS route
oc create route passthrough ${ROUTE_NAME} \
  --service=${SERVICE_NAME}

# Get route URL
oc get route ${ROUTE_NAME} -o jsonpath='{.spec.host}'

# Delete route
oc delete route ${ROUTE_NAME}
```

## Security Context Constraints (SCCs)

```bash
# List all SCCs
oc get scc

# Describe SCC
oc describe scc restricted
oc describe scc anyuid
oc describe scc privileged

# Add SCC to service account
oc adm policy add-scc-to-user anyuid \
  -z ${SERVICE_ACCOUNT} \
  -n ${NAMESPACE}

# Remove SCC from service account
oc adm policy remove-scc-from-user anyuid \
  -z ${SERVICE_ACCOUNT} \
  -n ${NAMESPACE}

# Check which SCC a pod is using
oc get pod ${POD_NAME} -o yaml | grep scc
```

## Image Streams

```bash
# List image streams
oc get imagestreams
oc get is

# Create image stream from external image
oc import-image ${IMAGE_STREAM_NAME} \
  --from=${EXTERNAL_IMAGE} \
  --confirm

# Tag image stream
oc tag ${SOURCE_IMAGE} ${DEST_IMAGE}

# Get image stream details
oc describe imagestream ${IMAGE_STREAM_NAME}
```

## BuildConfigs

```bash
# List build configs
oc get buildconfigs
oc get bc

# Start build
oc start-build ${BUILD_CONFIG_NAME}

# Start build from local source
oc start-build ${BUILD_CONFIG_NAME} \
  --from-dir=./src

# View build logs
oc logs -f bc/${BUILD_CONFIG_NAME}

# Cancel build
oc cancel-build ${BUILD_NAME}
```

## DeploymentConfigs (Legacy)

```bash
# List deployment configs
oc get deploymentconfigs
oc get dc

# Rollout latest
oc rollout latest dc/${DC_NAME}

# Rollback
oc rollback dc/${DC_NAME}

# Scale
oc scale dc/${DC_NAME} --replicas=3

# View rollout history
oc rollout history dc/${DC_NAME}

# Pause/Resume rollout
oc rollout pause dc/${DC_NAME}
oc rollout resume dc/${DC_NAME}
```

## Debugging

### Pod Debugging

```bash
# Get pod logs
oc logs ${POD_NAME}
oc logs ${POD_NAME} -c ${CONTAINER_NAME}
oc logs -f ${POD_NAME}  # follow

# Previous container logs
oc logs ${POD_NAME} --previous

# Execute command in pod
oc exec ${POD_NAME} -- ls -la
oc exec -it ${POD_NAME} -- /bin/bash

# Remote shell
oc rsh ${POD_NAME}

# Debug node
oc debug node/${NODE_NAME}

# Debug deployment
oc debug deployment/${DEPLOYMENT_NAME}

# Copy files
oc cp ${POD_NAME}:/path/to/file ./local-file
oc cp ./local-file ${POD_NAME}:/path/to/file
```

### Resource Events

```bash
# Get events
oc get events
oc get events --sort-by='.lastTimestamp'

# Watch events
oc get events -w
```

## Admin Operations

```bash
# Get cluster info
oc cluster-info

# List nodes
oc get nodes
oc describe node ${NODE_NAME}

# Cordon/Uncordon node
oc adm cordon ${NODE_NAME}
oc adm uncordon ${NODE_NAME}

# Drain node
oc adm drain ${NODE_NAME} \
  --ignore-daemonsets \
  --delete-emptydir-data

# Manage node roles
oc label node ${NODE_NAME} node-role.kubernetes.io/infra=

# Check API resources
oc api-resources

# Check cluster operators
oc get clusteroperators
oc get co
```

## Templates

```bash
# List templates
oc get templates -n openshift

# Process template
oc process -f template.yaml \
  -p PARAM1=value1 \
  -p PARAM2=value2 | oc apply -f -

# Process template from cluster
oc process openshift//mysql-persistent \
  -p MYSQL_USER=myuser \
  -p MYSQL_PASSWORD=mypass | oc apply -f -

# Export processed template
oc process -f template.yaml \
  -p PARAM1=value1 > processed.yaml
```

## Common Patterns

### Create Application from Source

```bash
# From Git repository
oc new-app https://github.com/org/repo.git

# From Git with specific builder image
oc new-app python:3.9~https://github.com/org/repo.git

# From existing image
oc new-app --image=nginx

# With environment variables
oc new-app myimage \
  -e VAR1=value1 \
  -e VAR2=value2
```

### Scale and Autoscale

```bash
# Manual scale
oc scale deployment/${DEPLOYMENT_NAME} --replicas=3

# Autoscale
oc autoscale deployment/${DEPLOYMENT_NAME} \
  --min=1 \
  --max=10 \
  --cpu-percent=80
```

### ConfigMaps and Secrets

```bash
# Create configmap
oc create configmap ${CM_NAME} \
  --from-file=config.properties

# Create secret
oc create secret generic ${SECRET_NAME} \
  --from-literal=username=admin \
  --from-literal=password=secret

# Mount to deployment
oc set volume deployment/${DEPLOYMENT_NAME} \
  --add \
  --type=configmap \
  --configmap-name=${CM_NAME} \
  --mount-path=/config
```

## Troubleshooting

### Common Issues

```bash
# Pod not starting - check events
oc describe pod ${POD_NAME} | grep -A 10 Events

# Image pull issues
oc get events | grep -i pull

# Check resource quotas
oc describe quota

# Check limit ranges
oc describe limitrange

# SCC issues - check pod security context
oc get pod ${POD_NAME} -o yaml | grep -A 10 securityContext

# Route not working - check endpoints
oc get endpoints ${SERVICE_NAME}
```

### Must-Gather

```bash
# Collect cluster diagnostics
oc adm must-gather

# Collect specific component
oc adm must-gather --image=registry.redhat.io/container-native-virtualization/cnv-must-gather-rhel9
```

## Best Practices

1. **Use Projects for Isolation**: Separate workloads by project
2. **Apply SCCs Minimally**: Use least-privilege SCCs
3. **Use Routes with TLS**: Always enable TLS for external routes
4. **Monitor Resource Quotas**: Set and monitor project quotas
5. **Use Image Streams**: Reference images via image streams for easier updates
6. **Label Everything**: Use consistent labeling for resources
7. **Use DeploymentConfigs or Deployments**: Prefer Deployments for new apps
8. **Backup etcd**: Regular etcd backups for cluster recovery
