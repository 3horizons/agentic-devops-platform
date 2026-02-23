# Three Horizons Accelerator — Local Demo

Run the entire Three Horizons platform locally on **kind** (Kubernetes in Docker) for demonstrations, testing, and development — no Azure subscription required.

## Quick Start

```bash
# 1. Install prerequisites (macOS)
brew install kind kubectl helm jq yq

# 2. Deploy everything
make -C local up

# 3. Access services
#    ArgoCD:     https://localhost:8443
#    Grafana:    http://localhost:3000  (admin/admin)
#    Prometheus: http://localhost:9090
```

## What's Included

| Component | Status | Access |
|-----------|--------|--------|
| **kind cluster** (1 CP + 2 workers) | Always | `kubectl get nodes` |
| **ArgoCD** (GitOps) | Always | https://localhost:8443 |
| **Prometheus** (metrics) | Always | http://localhost:9090 |
| **Grafana** (dashboards) | Always | http://localhost:3000 |
| **Alertmanager** (alerts) | Always | Via Grafana |
| **cert-manager** (TLS) | Always | Self-signed issuer |
| **ingress-nginx** (routing) | Always | Ports 80/443 |
| **Gatekeeper/OPA** (policies) | Always | Audit mode |
| **PostgreSQL 16** | Always | databases namespace |
| **Redis 7** | Always | databases namespace |
| **RHDH** (Developer Hub) | Optional | http://localhost:7007 |
| **13 Copilot Chat Agents** | Always | VS Code Copilot Chat |

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   kind cluster (local)                      │
│                                                             │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────────┐ │
│  │   ArgoCD     │  │  Prometheus   │  │     Grafana      │ │
│  │  (argocd ns) │  │ (observab.)   │  │  (observab.)     │ │
│  │  :8443       │  │  :9090        │  │  :3000           │ │
│  └──────────────┘  └───────────────┘  └──────────────────┘ │
│                                                             │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────────┐ │
│  │ ingress-     │  │ cert-manager  │  │    Gatekeeper    │ │
│  │   nginx      │  │ (self-signed) │  │  (audit mode)    │ │
│  └──────────────┘  └───────────────┘  └──────────────────┘ │
│                                                             │
│  ┌──────────────┐  ┌───────────────┐  ┌──────────────────┐ │
│  │ PostgreSQL   │  │    Redis      │  │   RHDH (opt.)    │ │
│  │ (databases)  │  │  (databases)  │  │  :7007           │ │
│  └──────────────┘  └───────────────┘  └──────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

## Requirements

| Requirement | Minimum |
|-------------|---------|
| Docker Desktop | Running, 16 GB RAM allocated, 6 CPUs |
| macOS/Linux | macOS 12+ or Ubuntu 20.04+ |
| kind | 0.20+ |
| kubectl | 1.28+ |
| helm | 3.12+ |
| jq | 1.6+ |
| yq | 4.0+ |
| Disk | 20 GB free |

### Docker Desktop Settings

Allocate at least **16 GB RAM** and **6 CPUs** in Docker Desktop → Settings → Resources.

## Makefile Targets

| Command | Description |
|---------|-------------|
| `make up` | Deploy full local demo |
| `make down` | Tear down cluster |
| `make reset` | Destroy and rebuild |
| `make status` | Show all pods |
| `make validate` | Run validation checks |
| `make dry-run` | Preview deployment |
| `make resume` | Resume from checkpoint |
| `make argocd` | Port-forward ArgoCD |
| `make grafana` | Port-forward Grafana |
| `make prometheus` | Port-forward Prometheus |
| `make rhdh` | Port-forward RHDH |
| `make argocd-password` | Show ArgoCD admin password |
| `make dashboards` | Import Grafana dashboards |
| `make logs NS=x POD=y` | Tail pod logs |

## Using Copilot Chat Agents

All 13 agents work with the local cluster. Open VS Code with GitHub Copilot Chat and use:

```
@deploy Deploy local demo
@sre Check cluster health
@devops Show ArgoCD sync status
@architect Design a microservice architecture
@security Review the platform security posture
@terraform Show me the Terraform modules
@reviewer Review the monitoring configuration
@test Generate tests for the platform
@docs Generate deployment documentation
@onboarding Help me get started with the platform
@platform Show Golden Path templates
```

The agents execute `kubectl`, `helm`, and other CLI commands against the local kind cluster — identical behavior to an Azure AKS cluster.

## RHDH (Optional)

RHDH requires credentials for `registry.redhat.io`:

1. Create a free account at https://developers.redhat.com
2. Create a pull secret at https://console.redhat.com/openshift/install/pull-secret
3. Configure Docker: `docker login registry.redhat.io`
4. Set `RHDH_ENABLED=true` in `local/config/local.env`
5. Re-run `make -C local up`

### Authentication Modes

RHDH supports two authentication modes:

#### Guest Mode (default)

No configuration needed — instant access without login. Good for quick demos.

#### GitHub App Mode (recommended for full demo)

Enables GitHub login, catalog auto-discovery, scaffolding to real repos, and org-based permissions.

**Step 1: Create a GitHub App**

Go to https://github.com/settings/apps/new and fill in:

| Field | Value |
|-------|-------|
| App name | `three-horizons-rhdh` |
| Homepage URL | `http://localhost:7007` |
| Callback URL | `http://localhost:7007/api/auth/github/handler/frame` |
| Webhook active | **Uncheck** (not needed for local demo) |

**Permissions (Repository):**
- Contents: Read
- Metadata: Read
- Pull requests: Read & Write
- Actions: Read
- Issues: Read

**Permissions (Organization):**
- Members: Read

**Where can this app be installed?** → Only on this account

Click **Create GitHub App**.

**Step 2: Generate credentials**

After creating the app:
1. Note the **App ID** (number at the top of the app page)
2. Generate a **Client Secret** → copy it
3. Generate a **Private Key** → downloads a `.pem` file
4. Click **Install App** → select your repositories (or all)

**Step 3: Configure in local.env**

Edit `local/config/local.env`:

```bash
RHDH_AUTH_MODE="github"
GITHUB_APP_ID="123456"
GITHUB_APP_CLIENT_ID="Iv1.abc123..."
GITHUB_APP_CLIENT_SECRET="your-client-secret"
GITHUB_APP_PRIVATE_KEY_FILE="/Users/you/Downloads/three-horizons-rhdh.pem"
```

**Step 4: Redeploy RHDH**

```bash
make -C local up  # or: ./local/deploy-local.sh --phase 5
```

Login at http://localhost:7007 using your GitHub account.

## Differences from Azure Deployment

| Feature | Azure (Production) | Local (Demo) |
|---------|-------------------|--------------|
| Cluster | AKS managed | kind on Docker |
| Networking | VNet + Private Endpoints | Docker network |
| Secrets | Key Vault + External Secrets | K8s Secrets (static) |
| TLS | Let's Encrypt | Self-signed |
| Auth | Entra ID / Workload Identity | Admin / Guest |
| Storage | Azure Managed Disks | hostpath |
| HA | Multi-replica, zone-redundant | Single replica |
| Databases | Azure PaaS (PostgreSQL, Redis) | In-cluster containers |
| AI Foundry | Azure OpenAI + AI Search | Not available |
| Cost | $50-3000+/month | $0 |
| Terraform | Required | Not used |

## Troubleshooting

### Pods stuck in Pending

```bash
kubectl describe pod <pod-name> -n <namespace>
# Usually: insufficient resources. Increase Docker Desktop RAM.
```

### ArgoCD UI not loading

```bash
# Use port-forward instead of NodePort
make argocd
# Or: kubectl port-forward svc/argocd-server -n argocd 8443:443
```

### Helm install timeout

```bash
# Check pod status
kubectl get pods -A | grep -v Running
# Resume from checkpoint
make resume
```

### Reset everything

```bash
make reset  # Destroys and rebuilds from scratch
```

## File Structure

```
local/
├── kind-config.yaml           # kind cluster: 3 nodes, port mappings
├── deploy-local.sh            # Main deployment orchestrator
├── teardown-local.sh          # Cleanup script
├── validate-local.sh          # Health checks
├── Makefile                   # Convenience targets
├── README.md                  # This file
├── DEMO_SCRIPT.md             # Full demo walkthrough script
├── DEMO_PREP.md               # Pre-demo checklist
├── config/
│   └── local.env              # Environment variables
├── values/
│   ├── argocd-local.yaml      # ArgoCD Helm overrides
│   ├── monitoring-local.yaml  # Prometheus/Grafana overrides
│   ├── cert-manager-local.yaml
│   ├── gatekeeper-local.yaml
│   ├── ingress-nginx-local.yaml
│   └── rhdh-local.yaml
├── manifests/
│   ├── namespaces.yaml        # Platform namespaces
│   ├── postgres.yaml          # PostgreSQL StatefulSet
│   ├── redis.yaml             # Redis Deployment
│   ├── secrets.yaml           # Demo secrets
│   └── self-signed-issuer.yaml
└── dashboards/
    └── import-dashboards.sh   # Grafana dashboard importer
```
