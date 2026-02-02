---
name: github-runners-agent
version: 1.0.0
horizon: H2-Enhancement
task: Deploy GitHub Actions runners
skills:
  - github-cli
  - kubectl-cli
  - helm-cli
  - validation-scripts
triggers:
  - "deploy github runners"
  - "configure self-hosted runners"
  - "setup arc runners"
---

# GitHub Runners Agent

## Task
Deploy and configure self-hosted GitHub Actions runners on Kubernetes.

## Skills Reference
- **[github-cli](../../skills/github-cli/)** - GitHub configuration
- **[kubectl-cli](../../skills/kubectl-cli/)** - Kubernetes operations
- **[helm-cli](../../skills/helm-cli/)** - Helm chart management
- **[validation-scripts](../../skills/validation-scripts/)** - Runner validation

## Workflow

```mermaid
graph LR
    A[Start] --> B[Create GitHub App]
    B --> C[Install ARC Controller]
    C --> D[Create Runner Scale Set]
    D --> E[Configure Autoscaling]
    E --> F[Validate Runners]
```

## Commands

### Install ARC Controller
```bash
helm repo add actions-runner-controller https://actions-runner-controller.github.io/actions-runner-controller
helm repo update

helm upgrade --install arc actions-runner-controller/gha-runner-scale-set-controller \
  --namespace arc-systems --create-namespace
```

### Create Runner Scale Set
```bash
helm upgrade --install arc-runner-set actions-runner-controller/gha-runner-scale-set \
  --namespace arc-runners --create-namespace \
  --set githubConfigUrl="https://github.com/${ORG}" \
  --set githubConfigSecret.github_token="${GH_TOKEN}" \
  --set minRunners=1 \
  --set maxRunners=10
```

### Validate
```bash
kubectl get pods -n arc-runners
kubectl get runnerdeployments -A
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| github_org | Yes | - | GitHub organization |
| min_runners | No | 1 | Minimum runners |
| max_runners | No | 10 | Maximum runners |
| runner_image | No | default | Custom runner image |

## Dependencies
- `infrastructure-agent` or `aro-platform-agent` (cluster)
- GitHub App or PAT with runner registration permissions

## Triggers Next
- CI/CD workflows can use self-hosted runners
