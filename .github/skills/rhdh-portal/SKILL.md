---
name: rhdh-portal
description: Red Hat Developer Hub portal operations
version: "1.0.0"
license: MIT
tools_required: ["kubectl", "curl"]
---

## When to Use
- RHDH portal management
- Catalog entity registration
- Template management
- Plugin configuration

## Prerequisites
- kubectl access to RHDH namespace
- RHDH admin access
- Git repository access for entities

## Commands

### Portal Health
```bash
# Check RHDH pods
kubectl get pods -n rhdh -l app.kubernetes.io/name=backstage

# Check portal logs
kubectl logs -n rhdh -l app.kubernetes.io/name=backstage --tail=100

# Port forward for local access
kubectl port-forward -n rhdh svc/rhdh 7007:7007
```

### Catalog Operations
```bash
# Register entity
curl -X POST "http://localhost:7007/api/catalog/locations" \
  -H "Content-Type: application/json" \
  -d '{"type":"url","target":"https://github.com/org/repo/blob/main/catalog-info.yaml"}'

# List entities
curl -s "http://localhost:7007/api/catalog/entities" | jq '.[].metadata.name'

# Refresh entity
curl -X POST "http://localhost:7007/api/catalog/refresh"
```

### Template Operations
```bash
# List templates
curl -s "http://localhost:7007/api/catalog/entities?filter=kind=Template" | jq '.[].metadata.name'

# Get template details
curl -s "http://localhost:7007/api/catalog/entities/by-name/template/default/<template-name>"
```

## Best Practices
1. Use catalog-info.yaml for entity definition
2. Configure OAuth for authentication
3. Use groups for access control
4. Enable TechDocs for documentation
5. Configure proper CORS settings

## Output Format
1. Command executed
2. Portal status
3. Entity count and status
4. Recommendations

## Integration with Agents
Used by: @rhdh-portal, @golden-paths
