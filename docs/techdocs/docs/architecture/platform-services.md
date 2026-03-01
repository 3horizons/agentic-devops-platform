# Platform Services

Platform services (H2) transform the raw Azure infrastructure into a self-service developer platform. These services are deployed on AKS using Helm charts and managed via ArgoCD GitOps.

## Red Hat Developer Hub (RHDH)

RHDH 1.8 is the central developer portal, built on the Backstage open-source framework with enterprise enhancements from Red Hat.

**Key capabilities**:

- **Software Catalog** -- Centralized registry for all services, APIs, libraries, and infrastructure
- **Golden Path Templates** -- 23 scaffolding templates organized by horizon (H1/H2/H3)
- **TechDocs** -- MkDocs-based documentation rendered in the portal
- **Dynamic Plugins** -- Enable or disable plugins via YAML configuration without rebuilding the portal
- **Built-in RBAC** -- Admin, Developer, and Viewer roles with CSV-based policy management
- **Developer Lightspeed** -- AI chat powered by Llama Stack and Azure OpenAI

**RHDH vs Backstage OSS differences**:

| Feature | Backstage OSS | RHDH |
|---------|--------------|------|
| Plugin management | Build-time compilation | Dynamic YAML configuration |
| RBAC | Community plugins | Built-in with CSV policies |
| AI Chat | Not available | Developer Lightspeed |
| Support | Community | Red Hat commercial support |

RHDH is deployed to the `rhdh` namespace and exposes metrics on port 7007 via a ServiceMonitor.

## ArgoCD

ArgoCD 5.51.0 provides GitOps-based continuous deployment using the App-of-Apps pattern.

**Architecture**:

- A root Application (`argocd/app-of-apps/root-application.yaml`) manages all child applications
- Sync waves control deployment ordering across the cluster
- Environment-specific sync policies govern automation behavior

**Sync wave order**:

1. cert-manager, external-dns
2. ingress-nginx
3. prometheus, jaeger
4. Red Hat Developer Hub
5. Team namespaces and applications

**Sync policy presets**:

| Preset | Auto-Sync | Self-Heal | Prune | Target |
|--------|-----------|-----------|-------|--------|
| dev-auto-sync | Yes | Yes | Yes | Development |
| staging-auto-sync | Yes | Yes | Yes | Staging |
| prod-manual-sync | No | No | No | Production |
| infra-careful-sync | Yes | Yes | No | Infrastructure |

## External Secrets Operator

ESO 0.9.9 bridges Azure Key Vault and Kubernetes Secrets using Workload Identity authentication. A ClusterSecretStore connects to Key Vault, and ExternalSecret resources declaratively map vault entries to Kubernetes secrets.

**Flow**: Azure Key Vault --> ClusterSecretStore --> ExternalSecret --> Kubernetes Secret

No static credentials are used. The ESO pod authenticates via a Kubernetes service account federated with an Azure Managed Identity.

## Observability Stack

The observability stack provides full-stack monitoring, alerting, and tracing:

- **Prometheus** -- Metrics collection with 50+ alerting rules and 40+ recording rules
- **Grafana** -- 3 dashboards (platform overview, cost management, Golden Path application metrics)
- **Alertmanager** -- Alert routing with severity-based escalation
- **Jaeger** -- Distributed tracing for request flow visualization

**ServiceMonitors** are configured for: RHDH (:7007), ArgoCD (server, repo-server, controller), ingress-nginx (:10254), cert-manager (:9402), and external-secrets (:8080).

## GitHub Actions Runners

Self-hosted GitHub Actions runners are deployed on AKS using the Actions Runner Controller (ARC). Runners execute CI/CD workflows within the cluster, providing:

- Faster build times via local container registry access
- Network-level access to private endpoints
- Cost efficiency by leveraging existing AKS compute

Runners are enabled via the `enable_github_runners` feature flag.
