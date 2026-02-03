---
name: openshift-operations
description: OpenShift administrative operations and management
version: "1.0.0"
license: MIT
tools_required: ["oc"]
---

## When to Use
- OpenShift cluster administration
- Operator management
- Security configuration
- Cluster troubleshooting

## Prerequisites
- Cluster admin access
- OpenShift CLI (oc) installed
- Understanding of OpenShift concepts

## Commands

### Cluster Health
```bash
# Check cluster version
oc get clusterversion

# Check cluster operators
oc get clusteroperators

# Check nodes
oc get nodes -o wide

# Check pods in all namespaces
oc get pods -A | grep -v Running
```

### Operator Management
```bash
# List available operators
oc get packagemanifests -n openshift-marketplace

# Install operator via subscription
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: operator-name
  namespace: openshift-operators
spec:
  channel: stable
  name: operator-name
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

# Check operator status
oc get csv -n openshift-operators
```

### Security Configuration
```bash
# Check SCCs
oc get scc

# Add SCC to service account
oc adm policy add-scc-to-user <scc-name> -z <sa-name> -n <namespace>

# Check OAuth configuration
oc get oauth cluster -o yaml
```

## Best Practices
1. Use operators for complex deployments
2. Configure OAuth for SSO integration
3. Apply NetworkPolicies for pod isolation
4. Enable cluster monitoring

## Output Format
1. Command executed
2. Cluster state summary
3. Any issues detected
4. Remediation steps

## Integration with Agents
Used by: @aro-platform
