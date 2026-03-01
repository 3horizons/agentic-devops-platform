# Security Baseline

Security is built into every layer of the Three Horizons platform. This document describes the baseline security controls enforced across infrastructure, networking, identity, container runtime, and compliance.

---

## Security Architecture Overview

```
                         Internet
                            |
                    Application Gateway (WAF)
                            |
                    ingress-nginx (TLS termination)
                            |
                +-----------+-----------+
                |                       |
          AKS Cluster              Private Endpoints
          (Calico CNI)           (Key Vault, PostgreSQL,
                |                 Redis, ACR, AI Search)
          OPA Gatekeeper
          (Runtime Policies)
                |
          Workload Identity
          (No static secrets)
```

All traffic flows through encrypted channels. No PaaS service exposes a public endpoint in `standard` or `enterprise` deployment modes.

---

## GitHub Advanced Security (GHAS)

GHAS provides three layers of security analysis integrated into the development workflow:

### Code Scanning (CodeQL)

CodeQL runs static analysis on every push and PR to detect vulnerability patterns:

- SQL injection, XSS, command injection
- Insecure deserialization
- Path traversal
- Hardcoded credentials
- Improper error handling

```yaml
# In CI workflow
- uses: github/codeql-action/init@v3
  with:
    languages: python, javascript, go
- uses: github/codeql-action/analyze@v3
```

Code scanning results appear directly in the PR conversation and on the repository Security tab.

### Secret Scanning

GitHub secret scanning detects tokens, keys, and credentials committed to the repository:

- Runs on every push to any branch
- Supports 200+ token patterns (Azure, AWS, GitHub, Slack, etc.)
- Push protection blocks commits containing detected secrets before they reach the remote
- Custom patterns can be defined for organization-specific credential formats

### Dependabot

Dependabot monitors dependencies for known vulnerabilities:

- **Security alerts**: Notifies when a dependency has a published CVE
- **Security updates**: Automatically creates PRs to update vulnerable dependencies
- **Version updates**: Keeps dependencies current to reduce vulnerability surface

Dependabot is configured via `.github/dependabot.yml` and runs daily checks.

### GHAS Metrics Collection

The Engineering Intelligence pipeline collects GHAS metrics every 6 hours:

```bash
# Collect security metrics
./scripts/engineering-intelligence/collect-security-metrics.sh
```

Metrics include: open/closed code scanning alerts by severity, secret scanning alert count, Dependabot alert status by ecosystem.

---

## Container Security

All containers running on the platform must comply with these runtime policies, enforced by OPA Gatekeeper constraint templates.

### Gatekeeper Constraint Templates

Five constraint templates are deployed in `policies/kubernetes/constraint-templates/`:

| Template | Policy | Enforcement |
|----------|--------|-------------|
| `K8sRequireNonRoot` | Containers must run as non-root (`runAsNonRoot: true`, `runAsUser >= 1000`) | Deny |
| `K8sDenyPrivileged` | Privileged containers and `allowPrivilegeEscalation: true` are blocked | Deny |
| `K8sContainerResources` | All containers must declare CPU and memory `requests` and `limits` | Deny |
| `K8sAllowedRegistries` | Images can only be pulled from approved ACR instances | Deny |
| `K8sRequiredLabels` | Mandatory labels with regex validation | Deny |

### Required Security Context

Every container deployed to the platform must include:

```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  readOnlyRootFilesystem: true
  allowPrivilegeEscalation: false
  capabilities:
    drop:
      - ALL
```

### Container Image Requirements

- Images must be pulled from the approved Azure Container Registry only
- Base images should use minimal distributions (distroless or Alpine)
- No root user in the Dockerfile
- Multi-stage builds to minimize final image size
- All images are scanned at build time, in the registry, and at runtime

### Image Scanning Pipeline

Container images are scanned for vulnerabilities at three stages:

| Stage | Tool | Trigger |
|-------|------|---------|
| Build time | Trivy | GitHub Actions CI pipeline |
| Registry | Azure Container Registry scanning | On push to ACR |
| Runtime | Microsoft Defender for Containers | Continuous assessment |

```yaml
# Trivy scan in CI
- name: Scan container image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ${{ env.ACR_NAME }}.azurecr.io/${{ env.IMAGE }}:${{ env.TAG }}
    format: sarif
    output: trivy-results.sarif
    severity: CRITICAL,HIGH

- name: Upload scan results
  uses: github/codeql-action/upload-sarif@v3
  with:
    sarif_file: trivy-results.sarif
```

---

## Network Security

### Private Endpoints

All Azure PaaS services are accessed exclusively through private endpoints within the VNet. No public network access is permitted in `standard` and `enterprise` deployment modes:

| Service | Private Endpoint | Private DNS Zone |
|---------|-----------------|------------------|
| Azure Key Vault | Yes | `privatelink.vaultcore.azure.net` |
| PostgreSQL Flexible Server | Yes | `privatelink.postgres.database.azure.com` |
| Redis Cache | Yes | `privatelink.redis.cache.windows.net` |
| Azure Container Registry | Yes (Premium tier) | `privatelink.azurecr.io` |
| Azure AI Search | Yes | `privatelink.search.windows.net` |
| Azure OpenAI | Yes | `privatelink.openai.azure.com` |

Private DNS zones resolve service FQDNs to private IP addresses within the cluster network.

### VNet Architecture

The platform VNet is divided into dedicated subnets:

| Subnet | Purpose | NSG Rules |
|--------|---------|-----------|
| `aks-nodes` | AKS node pool VMs | Allow VNet internal, deny all external |
| `aks-pods` | AKS pod CIDR (Azure CNI Overlay) | Allow VNet internal, deny all external |
| `private-endpoints` | PaaS service private endpoints | Allow from AKS subnet only |
| `bastion` | Azure Bastion for secure access | Allow SSH/RDP from approved IPs only |
| `appgw` | Application Gateway (WAF) | Allow HTTPS (443) from internet |

### Network Security Groups (NSGs)

NSGs apply deny-by-default inbound rules on all subnets:

```
Default Rule: Deny all inbound traffic
Exception Rules (by subnet):
  - AKS nodes:         Allow VNet internal traffic
  - Private endpoints:  Allow from AKS subnet only
  - Bastion:           Allow SSH/RDP from approved CIDRs
  - Application Gateway: Allow HTTPS (443) from internet
```

### Kubernetes Network Policies

Calico network policies enforce pod-level isolation:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: my-service
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
```

- Default deny all ingress and egress per namespace
- Explicit allow rules for known service-to-service communication
- DNS egress allowed to `kube-system` namespace only
- Ingress from ingress-nginx namespace allowed for public services

---

## Identity and Access Management

### Workload Identity

All AKS workloads authenticate to Azure services using Workload Identity Federation. No static service principal secrets are used anywhere in the platform.

```
AKS Pod --> Kubernetes Service Account --> OIDC Issuer --> Azure AD
                                                            |
                                                            v
                                                    Managed Identity
                                                            |
                                                            v
                                                    Azure Resource
                                                    (Key Vault, ACR, etc.)
```

Setup:

```bash
./scripts/setup-identity-federation.sh
```

### Managed Identity

All Azure services use system-assigned managed identities:

- AKS cluster identity for Azure API operations
- Kubelet identity for ACR image pulls
- External Secrets Operator identity for Key Vault access
- Application identities for service-specific Azure resources

### Authentication Providers

| Service | Auth Method | Provider |
|---------|-------------|----------|
| RHDH Portal | GitHub OAuth | GitHub App |
| ArgoCD | Azure AD SSO | OIDC |
| Grafana | Azure AD SSO | OAuth 2.0 |
| GitHub Actions | OIDC Federation | Workload Identity |
| AKS workloads | Workload Identity | Azure AD |
| Azure PaaS | Managed Identity | Azure AD |

### Prohibited Identity Practices

- Never create service principal secrets
- Never use static credentials in code or configuration
- Never assign the `Owner` role programmatically
- Never extract secret values with `kubectl get secret -o yaml`
- Never pass credentials as environment variables in Dockerfiles

---

## Encryption

### Encryption in Transit

TLS 1.2 is the minimum protocol version enforced on all communication channels:

| Communication Path | TLS Version | Certificate |
|-------------------|-------------|-------------|
| Client to Application Gateway | TLS 1.2+ | Azure-managed or custom |
| Application Gateway to ingress-nginx | TLS 1.2+ | Internal CA |
| Service-to-service within AKS | mTLS (optional) | cert-manager |
| AKS to Azure PaaS | TLS 1.2+ | Azure-managed |
| GitHub to AKS (webhooks) | TLS 1.2+ | Let's Encrypt |

### Encryption at Rest

| Resource | Encryption | Key Management |
|----------|-----------|----------------|
| Azure Key Vault | AES-256 | Azure-managed (or BYOK with Premium) |
| PostgreSQL | AES-256 | Azure-managed |
| Redis Cache | AES-256 | Azure-managed |
| Azure Storage | AES-256 | Azure-managed (or CMK) |
| AKS etcd | AES-256 | Azure-managed |
| Container Registry | AES-256 | Azure-managed |

---

## Microsoft Defender for Cloud

When enabled (`enable_defender = true`), Microsoft Defender provides:

### Defender for Containers

- Runtime threat detection for AKS workloads
- Vulnerability assessment for running container images
- Kubernetes audit log analysis
- Network traffic anomaly detection

### Defender for Cloud Security Posture (CSPM)

- Security score across all Azure resources
- Compliance assessment against regulatory frameworks
- Attack path analysis
- Cloud security graph queries

### Defender Alerts

Critical Defender alerts are routed to the platform alert system:

| Alert Category | Severity | Response |
|---------------|----------|----------|
| Crypto mining detected | Critical | Immediate pod termination |
| Suspicious network traffic | High | Investigation within 30 min |
| Privileged container creation | High | Block and notify |
| Anonymous access to AKS API | Medium | Audit and review |

---

## OPA Policy Enforcement in CI

Terraform plans are validated against OPA/Rego policies via Conftest in CI. Policies in `policies/terraform/azure.rego` check for:

### Required Policies

- **Required tags**: `environment`, `project`, `owner`, `cost-center` on all resources
- **TLS 1.2 enforcement**: Storage accounts, PostgreSQL, Key Vault
- **Encryption at rest**: Storage accounts, Key Vault
- **No public access**: Storage, Key Vault, AKS
- **HTTPS only**: Storage accounts
- **AKS hardening**: RBAC enabled, Managed Identity, Azure Policy, Defender
- **Database security**: Geo-redundant backups for PostgreSQL

### Warning Policies

- Expensive VM sizes (Standard_E, Standard_M series) trigger warnings
- Non-Brazil regions trigger LGPD compliance warnings

### Running Policies Locally

```bash
# Generate a Terraform plan in JSON format
terraform plan -out=tfplan
terraform show -json tfplan > tfplan.json

# Run OPA policy checks
conftest test tfplan.json -p policies/terraform/
```

---

## Compliance Standards

The platform is designed to support the following compliance frameworks:

| Framework | Key Controls | Implementation |
|-----------|-------------|----------------|
| **LGPD** | Data residency in Brazil | Primary region `brazilsouth` |
| **SOC 2** | Audit trails, access controls | Azure Activity Log, K8s audit, Git history |
| **PCI-DSS** | Network segmentation, encryption | VNet isolation, TLS 1.2+, private endpoints |
| **CIS Benchmarks** | Azure + Kubernetes hardening | AKS CIS profile, Defender CSPM |

### LGPD Considerations

- Default deployment region is `brazilsouth` for Brazilian data protection compliance
- AI Foundry uses `eastus2` for model availability (no PII data sent)
- Region availability matrix in `config/region-availability.yaml`
- Tier 1 regions support full platform deployment
- Tier 2 regions support limited services

---

## Secret Detection and Prevention

Multiple layers prevent secrets from entering the codebase:

| Layer | Tool | Trigger |
|-------|------|---------|
| Pre-commit | detect-secrets | Before git commit |
| Pre-commit | gitleaks | Before git commit |
| CI Pipeline | GHAS secret scanning | On push and PR |
| Push protection | GitHub push protection | Before push reaches remote |
| Baseline | `.secrets.baseline` | 13+ detectors configured |

See the [Secret Management](secrets.md) page for the full secrets architecture.

---

## Security Validation

Run the platform security validation script:

```bash
# Validate prerequisites including security tools
./scripts/validate-prerequisites.sh

# Validate deployment security posture
./scripts/validate-deployment.sh
```

Use the `@security` Copilot agent for security assessments:

```
@security Scan for vulnerabilities in the terraform/ directory
@security Review the AKS cluster security configuration
@security Audit the RBAC policies for the platform
```
