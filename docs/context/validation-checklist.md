# Validation Checklist

> Complete validation criteria for deployment, integration, and configuration of Three Horizons implementation.

## Overview

This checklist ensures complete validation of the Three Horizons Accelerator deployment across all horizons and integration points with Microsoft, GitHub, and Red Hat.

---

## Pre-Deployment Validation

### Prerequisites

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Azure CLI installed | `az version` | >= 2.57.0 | ☐ |
| Terraform installed | `terraform version` | >= 1.7.0 | ☐ |
| kubectl installed | `kubectl version --client` | >= 1.29.0 | ☐ |
| Helm installed | `helm version` | >= 3.14.0 | ☐ |
| GitHub CLI installed | `gh version` | >= 2.43.0 | ☐ |
| ArgoCD CLI installed | `argocd version --client` | >= 2.10.0 | ☐ |
| jq installed | `jq --version` | >= 1.7 | ☐ |
| yq installed | `yq --version` | >= 4.40 | ☐ |

**Automation:**
```bash
./scripts/validate-cli-prerequisites.sh
```

### Azure Subscription

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Logged in | `az account show` | Subscription visible | ☐ |
| Correct subscription | `az account show --query id` | Matches target | ☐ |
| Owner/Contributor role | `az role assignment list` | Role assigned | ☐ |
| Sufficient quota | Azure Portal | 20+ vCPUs available | ☐ |
| Providers registered | `az provider show -n Microsoft.ContainerService` | Registered | ☐ |

### GitHub Organization

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Authenticated | `gh auth status` | Logged in | ☐ |
| Organization access | `gh org list` | Org visible | ☐ |
| Repository exists | `gh repo view` | Repo accessible | ☐ |
| Actions enabled | Organization settings | Enabled | ☐ |
| Copilot license | User settings | Active | ☐ |

---

## H1 Foundation Validation

### Infrastructure Module

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Resource group created | `az group show -n $RG` | Exists | ☐ |
| Terraform state valid | `terraform state list` | Resources listed | ☐ |
| No terraform errors | `terraform validate` | Success | ☐ |

### Networking

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| VNet created | `az network vnet show` | Exists | ☐ |
| Subnets configured | `az network vnet subnet list` | 3+ subnets | ☐ |
| NSGs attached | `az network nsg list` | NSGs present | ☐ |
| Private endpoints | `az network private-endpoint list` | If configured | ☐ |
| DNS resolution | `nslookup <internal-service>` | Resolves | ☐ |

### Kubernetes Cluster (AKS)

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Cluster running | `az aks show --query provisioningState` | Succeeded | ☐ |
| Nodes ready | `kubectl get nodes` | All Ready | ☐ |
| System pods healthy | `kubectl get pods -n kube-system` | All Running | ☐ |
| kubectl connected | `kubectl cluster-info` | Connected | ☐ |
| RBAC enabled | `az aks show --query aadProfile` | Configured | ☐ |

### Kubernetes Cluster (ARO)

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Cluster running | `az aro show --query provisioningState` | Succeeded | ☐ |
| Nodes ready | `oc get nodes` | All Ready | ☐ |
| Console accessible | Browser | Login works | ☐ |
| OAuth configured | `oc get oauth cluster` | Configured | ☐ |

### Security

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Key Vault created | `az keyvault show` | Exists | ☐ |
| Secrets accessible | `az keyvault secret list` | Accessible | ☐ |
| Managed identities | `az identity list` | Created | ☐ |
| Workload identity | `kubectl get sa -n kube-system` | WI configured | ☐ |
| Network policies | `kubectl get networkpolicy -A` | Policies exist | ☐ |

### Container Registry

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| ACR created | `az acr show` | Exists | ☐ |
| Login successful | `az acr login` | Login succeeded | ☐ |
| Push works | `docker push $ACR/test:latest` | Success | ☐ |
| Pull works | `docker pull $ACR/test:latest` | Success | ☐ |
| AKS integration | `kubectl get pods` | No imagePull errors | ☐ |

### Database (if deployed)

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| PostgreSQL running | `az postgres flexible-server show` | Available | ☐ |
| Connection works | `psql -h $HOST -U $USER` | Connected | ☐ |
| Redis running | `az redis show` | Succeeded | ☐ |
| Redis connection | `redis-cli -h $HOST` | PONG | ☐ |

### Defender for Cloud

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Defender enabled | `az security pricing list` | Standard tier | ☐ |
| AKS protected | Azure Portal | Protection on | ☐ |
| Recommendations | `az security sub-assessment list` | Listed | ☐ |

---

## H2 Enhancement Validation

### ArgoCD

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| ArgoCD pods running | `kubectl get pods -n argocd` | All Running | ☐ |
| UI accessible | `https://argocd.$DOMAIN` | Login page | ☐ |
| Admin login works | `argocd login` | Authenticated | ☐ |
| Repo connected | `argocd repo list` | Repo visible | ☐ |
| Apps syncing | `argocd app list` | Synced/Healthy | ☐ |

### GitOps Flow

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| App of Apps deployed | `kubectl get app root-application -n argocd` | Synced | ☐ |
| Git webhook active | GitHub repo settings | Webhook configured | ☐ |
| Sync on push | Push and verify | Auto-syncs | ☐ |
| Rollback works | `argocd app rollback` | Success | ☐ |

### Red Hat Developer Hub

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| RHDH pods running | `kubectl get pods -n rhdh` | All Running | ☐ |
| UI accessible | `https://rhdh.$DOMAIN` | Login page | ☐ |
| Authentication works | Login with Azure AD | Successful | ☐ |
| Catalog loaded | UI → Catalog | Entities visible | ☐ |
| Templates registered | UI → Create | Templates visible | ☐ |

### Golden Paths

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Templates in RHDH | API query | 22 templates | ☐ |
| Create from template | UI → Create | Wizard works | ☐ |
| Generates repository | After create | Repo created | ☐ |
| Triggers pipeline | GitHub Actions | Workflow runs | ☐ |

### Observability

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Prometheus running | `kubectl get pods -n monitoring -l app=prometheus` | Running | ☐ |
| Targets scraped | Prometheus UI → Targets | All up | ☐ |
| Grafana accessible | `https://grafana.$DOMAIN` | Login works | ☐ |
| Dashboards loaded | UI → Dashboards | 3+ dashboards | ☐ |
| Loki running | `kubectl get pods -n monitoring -l app=loki` | Running | ☐ |
| Logs visible | Grafana → Explore | Logs query works | ☐ |
| Alerts configured | AlertManager UI | Alerts visible | ☐ |

### GitHub Runners

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Runner pods running | `kubectl get pods -n actions-runner-system` | Running | ☐ |
| Runners registered | GitHub → Settings → Runners | Online | ☐ |
| Workflow uses runner | trigger workflow | Picks self-hosted | ☐ |
| Scale on demand | multiple triggers | Runners scale | ☐ |

---

## H3 Innovation Validation

### AI Foundry

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| AI Foundry created | `az cognitiveservices account show` | Exists | ☐ |
| Endpoints accessible | `curl $AI_ENDPOINT/health` | 200 OK | ☐ |
| OpenAI models deployed | Azure Portal | Models listed | ☐ |
| API key in Key Vault | `az keyvault secret show` | Exists | ☐ |

### MLOps Pipeline

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Pipeline template works | Create from template | Success | ☐ |
| Training job runs | Azure ML UI | Completed | ☐ |
| Model registered | Model registry | Listed | ☐ |
| Endpoint deployed | Inference endpoint | Online | ☐ |

### SRE Agent

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Agent pods running | `kubectl get pods -n ai-agents` | Running | ☐ |
| Can query metrics | Agent UI/API | Returns data | ☐ |
| Alert response | Trigger test alert | Agent responds | ☐ |

---

## Integration Validation

### Microsoft Azure Integration

| Check | Validation | Status |
|-------|------------|--------|
| OIDC federation works | GitHub Action → Azure | ☐ |
| Key Vault integration | ESO syncs secrets | ☐ |
| Defender alerts flow | Security events appear | ☐ |
| Purview scans | Data catalog updated | ☐ |
| Cost management | Budgets configured | ☐ |

### GitHub Integration

| Check | Validation | Status |
|-------|------------|--------|
| Actions workflows run | Trigger and verify | ☐ |
| Copilot agents work | Chat invocation | ☐ |
| Issue templates work | Create issue | ☐ |
| Branch protection | Cannot push to main | ☐ |
| Webhooks firing | ArgoCD receives | ☐ |

### Red Hat Integration

| Check | Validation | Status |
|-------|------------|--------|
| Pull secret works | Can pull RH images | ☐ |
| RHDH + GitHub | Can create from template | ☐ |
| OpenShift operators | Operators installed (ARO) | ☐ |
| Registry mirror | Images cached | ☐ |

---

## Security Validation

### Authentication

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Azure AD SSO | Login to apps | Works | ☐ |
| RBAC enforced | Access without permission | Denied | ☐ |
| Service accounts | SA tokens work | Yes | ☐ |
| Workload identity | Pod → Azure | Authenticated | ☐ |

### Network Security

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| NSG rules applied | `az network nsg rule list` | Rules exist | ☐ |
| Private endpoints | No public IPs | Verified | ☐ |
| Egress controlled | Blocked test | Blocked | ☐ |
| TLS for all ingress | Certificate check | Valid | ☐ |

### Secrets Management

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| No plaintext secrets | `grep -r password` | None found | ☐ |
| ESO syncing | `kubectl get externalsecrets` | Synced | ☐ |
| Key rotation works | Rotate in KV | K8s secret updates | ☐ |
| Audit logging | Key Vault logs | Events captured | ☐ |

---

## Performance Validation

### Cluster Performance

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Node CPU < 80% | Prometheus/kubectl top | < 80% | ☐ |
| Node memory < 80% | Prometheus/kubectl top | < 80% | ☐ |
| Pod scheduling | Deploy test pod | < 30s | ☐ |
| Storage IOPS | Benchmark | Meets requirements | ☐ |

### Application Performance

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| API latency P99 | Prometheus query | < 500ms | ☐ |
| Error rate | Prometheus query | < 1% | ☐ |
| ArgoCD sync time | ArgoCD metrics | < 5min | ☐ |
| RHDH load time | Browser | < 3s | ☐ |

---

## Disaster Recovery Validation

| Check | Command | Expected | Status |
|-------|---------|----------|--------|
| Backup configured | `az backup protection` | Protected | ☐ |
| Velero installed | `velero backup get` | Backups exist | ☐ |
| Restore tested | Restore and verify | Success | ☐ |
| RTO < 4 hours | DR drill | Achieved | ☐ |
| RPO < 1 hour | Backup frequency | Configured | ☐ |

---

## Final Validation Summary

### Deployment Status

| Horizon | Components | Validated | Status |
|---------|------------|-----------|--------|
| H1 Foundation | 8 | _/8 | ☐ |
| H2 Enhancement | 5 | _/5 | ☐ |
| H3 Innovation | 4 | _/4 | ☐ |
| Cross-Cutting | 6 | _/6 | ☐ |

### Integration Status

| Partner | Integrations | Validated | Status |
|---------|--------------|-----------|--------|
| Microsoft | Azure, Defender, Purview | _/5 | ☐ |
| GitHub | Actions, Copilot, Issues | _/5 | ☐ |
| Red Hat | RHDH, Operators, Images | _/4 | ☐ |

### Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Platform Lead | ________________ | ____/____/____ | _______ |
| Security Lead | ________________ | ____/____/____ | _______ |
| Operations Lead | ________________ | ____/____/____ | _______ |

---

## Automated Validation

Run the comprehensive validation script:

```bash
# Full validation
./scripts/validate-deployment.sh --environment dev --verbose

# Specific horizon
./scripts/validate-deployment.sh --horizon h1 --environment dev

# Generate report
./scripts/validate-deployment.sh --environment dev --report validation-report.md
```

---

**Document Owner:** Platform Engineering Team  
**Last Updated:** February 2026  
**Review Cycle:** Per Deployment
