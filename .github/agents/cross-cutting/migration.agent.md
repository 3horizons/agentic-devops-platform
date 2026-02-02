---
name: migration-agent
version: 1.0.0
horizon: Cross-Cutting
task: Migrate workloads between environments
skills:
  - terraform-cli
  - kubectl-cli
  - azure-infrastructure
  - validation-scripts
triggers:
  - "migrate workload"
  - "move to production"
  - "promote environment"
---

# Migration Agent

## Task
Migrate workloads, data, and configurations between environments.

## Skills Reference
- **[terraform-cli](../../skills/terraform-cli/)** - State migration
- **[kubectl-cli](../../skills/kubectl-cli/)** - Workload migration
- **[azure-infrastructure](../../skills/azure-infrastructure/)** - Resource migration
- **[validation-scripts](../../skills/validation-scripts/)** - Migration validation

## Workflow

```mermaid
graph LR
    A[Start] --> B[Assess Source]
    B --> C[Plan Migration]
    C --> D[Backup Data]
    D --> E[Execute Migration]
    E --> F[Validate Target]
    F --> G[Cutover/Rollback]
```

## Migration Types

### Environment Promotion
```bash
# Promote from dev to staging
./scripts/promote-environment.sh --from dev --to staging
```

### Database Migration
```bash
# Export and import data
pg_dump -h ${SOURCE_HOST} ${DB_NAME} | psql -h ${TARGET_HOST} ${DB_NAME}
```

### Kubernetes Workloads
```bash
# Export workloads
kubectl get deploy,svc,configmap -n ${NAMESPACE} -o yaml > workloads.yaml

# Apply to target
kubectl apply -f workloads.yaml --context ${TARGET_CLUSTER}
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| source_env | Yes | - | Source environment |
| target_env | Yes | - | Target environment |
| components | No | all | Components to migrate |
| dry_run | No | true | Simulate migration |

## Dependencies
- Source and target environments must exist
- Proper permissions in both environments

## Triggers Next
- `validation-agent` (Verify migration)
