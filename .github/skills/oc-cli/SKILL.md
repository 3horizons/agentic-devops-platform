---
name: oc-cli
description: OpenShift CLI operations for ARO cluster management
version: "1.0.0"
license: MIT
tools_required: ["oc"]
min_versions:
  oc: "4.14.0"
---

## When to Use
- Azure Red Hat OpenShift (ARO) operations
- OpenShift-specific resource management
- Operator lifecycle management
- Route and build configurations

## Prerequisites
- OpenShift CLI (oc) installed
- Authenticated to ARO cluster
- Appropriate RBAC permissions

## Commands

### Authentication
```bash
# Login with token
oc login --token=<token> --server=<api-server>

# Login with kubeadmin
oc login -u kubeadmin -p <password> --server=<api-server>

# Current context
oc whoami --show-server
```

### Project Operations
```bash
# List projects
oc projects

# Switch project
oc project <project-name>

# Create project
oc new-project <project-name>
```

### Operator Management
```bash
# List installed operators
oc get csv -n openshift-operators

# View operator status
oc describe csv <operator-name> -n openshift-operators
```

### Route Management
```bash
# List routes
oc get routes -A

# Create route
oc expose service <service-name>

# Get route URL
oc get route <route-name> -o jsonpath='{.spec.host}'
```

## Best Practices
1. Use projects for namespace isolation
2. Prefer oc to kubectl for OpenShift-specific features
3. Use Operators for complex application management
4. Enable NetworkPolicies for pod isolation

## Output Format
1. Command executed
2. Operation result
3. Relevant status information
4. Next steps

## Integration with Agents
Used by: @aro-platform, @devops
