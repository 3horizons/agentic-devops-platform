# Acelerador de Implementación Three Horizons

🌐 **Idioma / Language:** [English](README.md) | [Português](README.pt-BR.md) | [Español](#)

---

## 🎯 Descripción General

El **Acelerador de Implementación Three Horizons** es un kit completo de Infrastructure as Code (IaC), GitOps y plantillas para desarrolladores, diseñado para implementar la plataforma Three Horizons en clientes de LATAM.

### Qué Incluye

| Componente | Cantidad | Descripción |
|------------|----------|-------------|
| **Módulos Terraform** | 14 | Infraestructura Azure completa |
| **Agentes AI** | 23 | Orquestación inteligente de deploys |
| **Plantillas Golden Path** | 21 | Plantillas self-service para RHDH |
| **Issue Templates** | 25 | Plantillas para GitHub Issues |
| **Scripts de Automatización** | 10 | Bootstrap y operaciones |
| **MCP Servers** | 15 | Configuraciones de servidores MCP |
| **Observabilidad** | 4 | Dashboards y alertas |

**Total: 100+ archivos | ~18,000 líneas de código listo para producción**

---

## 🏗️ Arquitectura Three Horizons

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        H3: INNOVACIÓN                                    │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ AI Foundry  │  │ SRE Agent   │  │ Multi-Agent │  │   MLOps     │    │
│  │   Agentes   │  │ Integración │  │  Sistemas   │  │  Pipeline   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────────────┤
│                        H2: MEJORAMIENTO                                  │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   ArgoCD    │  │    RHDH     │  │Observabilidad│ │   GitOps    │    │
│  │   GitOps    │  │   Portal    │  │    Stack    │  │  Workflows  │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────────────────────┤
│                        H1: FUNDACIÓN                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │     AKS     │  │     Red     │  │  Seguridad  │  │     ACR     │    │
│  │   Cluster   │  │  VNet/NSG   │  │  KeyVault   │  │  Registry   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘    │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 🚀 Inicio Rápido (5 minutos)

### Prerrequisitos

```bash
# Herramientas requeridas
az version        # >= 2.50.0
terraform version # >= 1.5.0
kubectl version   # >= 1.28
helm version      # >= 3.12
gh --version      # >= 2.30

# Autenticación
az login
gh auth login
```

### Deploy Rápido

```bash
# 1. Clonar el acelerador
git clone https://github.com/YOUR_ORG/three-horizons-accelerator-v4.git
cd three-horizons-accelerator-v4

# 2. Hacer scripts ejecutables
chmod +x scripts/*.sh

# 3. Validar prerrequisitos y configurar variables
./scripts/validate-cli-prerequisites.sh
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Editar terraform.tfvars con sus valores

# 4. Deploy completo (Dev)
./scripts/platform-bootstrap.sh --environment dev

# O deploy por horizonte
./scripts/platform-bootstrap.sh --horizon h1 --environment dev
./scripts/platform-bootstrap.sh --horizon h2 --environment staging
./scripts/platform-bootstrap.sh --horizon h3 --environment prod
```

---

## 📁 Estructura de Directorios

```
three-horizons-accelerator-v4/
│
├── agents/                         # 23 especificaciones de agentes AI
│   ├── h1-foundation/              # 8 agentes (infra, red, seguridad, ACR, DB, defender, purview, ARO)
│   ├── h2-enhancement/             # 5 agentes (gitops, golden-paths, observability, rhdh, runners)
│   ├── h3-innovation/              # 4 agentes (ai-foundry, sre, mlops, multi-agent)
│   └── cross-cutting/              # 6 agentes (migration, validation, rollback, cost, github-app, identity)
│
├── terraform/                      # 14 módulos Infrastructure as Code
│   ├── main.tf                     # Módulo raíz
│   └── modules/
│       ├── aks-cluster/            # Azure Kubernetes Service
│       ├── argocd/                 # ArgoCD GitOps
│       ├── networking/             # VNet, Subnets, NSGs
│       ├── observability/          # Prometheus, Grafana, Loki
│       ├── databases/              # PostgreSQL, Redis, Cosmos
│       ├── security/               # Key Vault, Identidades
│       ├── ai-foundry/             # Azure AI Foundry
│       ├── container-registry/     # ACR
│       ├── github-runners/         # Runners auto-hospedados
│       ├── rhdh/                   # Red Hat Developer Hub
│       ├── defender/               # Defender for Cloud
│       ├── purview/                # Microsoft Purview
│       └── naming/                 # Convenciones de nomenclatura
│
├── golden-paths/                   # 21 plantillas RHDH (Backstage)
│   ├── h1-foundation/              # 6 plantillas básicas
│   ├── h2-enhancement/             # 8 plantillas avanzadas
│   └── h3-innovation/              # 7 plantillas AI/Agentes
│
├── .github/ISSUE_TEMPLATE/         # 25 plantillas de issues
├── argocd/                         # Configuraciones GitOps
├── config/                         # Sizing profiles y regiones
├── mcp-servers/                    # 15 configuraciones MCP
├── scripts/                        # 10 scripts de automatización
├── grafana/dashboards/             # Dashboards
├── prometheus/                     # Alertas
└── docs/                           # Documentación
```

---

## 📚 Documentación

### Guías Paso a Paso

| Guía | Descripción |
|------|-------------|
| [🚀 Guía de Deployment](./docs/guides/DEPLOYMENT_GUIDE.md) | Instrucciones completas de deployment paso a paso |
| [🏗️ Guía de Arquitectura](./docs/guides/ARCHITECTURE_GUIDE.md) | Arquitectura Three Horizons explicada |
| [🔧 Guía del Administrador](./docs/guides/ADMINISTRATOR_GUIDE.md) | Operaciones Day-2 y mantenimiento |
| [📦 Referencia de Módulos](./docs/guides/MODULE_REFERENCE.md) | Todos los módulos Terraform con ejemplos |
| [🔍 Guía de Troubleshooting](./docs/guides/TROUBLESHOOTING_GUIDE.md) | Diagnóstico y resolución de problemas |

### Documentación de Referencia

- [Enterprise Review](./ENTERPRISE_REVIEW.md) - Decisiones de arquitectura
- [Inventario](./INVENTORY_v4.md) - Lista completa de componentes
- [Catálogo de Agentes](./AGENT_CATALOG.md) - Documentación de agentes AI
- [Perfiles de Sizing](./config/sizing-profiles.yaml) - Estimación de costos

---

## 🔧 Guía de Uso Detallada

### Paso 1: Deploy de Infraestructura Base (H1)

```bash
cd terraform

# Inicializar Terraform
terraform init

# Crear plan
terraform plan -var-file=environments/dev.tfvars -out=tfplan

# Aplicar (H1 Fundación)
terraform apply tfplan
```

**Recursos creados en H1:**
- Cluster AKS (3 nodos)
- VNet con 3 subnets
- Azure Container Registry
- Key Vault
- Managed Identities
- NSGs y Private Endpoints

### Paso 2: Deploy de ArgoCD y RHDH (H2)

```bash
# Después de H1 completo, aplicar H2
terraform apply -var-file=environments/dev.tfvars -var="enable_h2=true"

# O via script
./scripts/platform-bootstrap.sh --horizon h2 --environment dev
```

**Recursos creados en H2:**
- ArgoCD con ApplicationSets
- Red Hat Developer Hub
- Prometheus + Grafana + Loki
- GitHub Actions Runners

### Paso 3: Deploy de AI Foundry (H3)

```bash
# Requiere H1 y H2
terraform apply -var-file=environments/dev.tfvars -var="enable_h3=true"
```

**Recursos creados en H3:**
- Azure AI Foundry
- Azure OpenAI (GPT-4o, o1)
- AI Search (Vectorial)
- Cosmos DB (Vector Store)

---

## 📋 Golden Paths - Cómo Usar

### Registrar Plantillas en RHDH

```bash
# Registrar todas las plantillas
./scripts/bootstrap.sh --register-templates

# O registrar individualmente
kubectl apply -f golden-paths/h1-foundation/basic-cicd/template.yaml
```

### Crear Aplicación via RHDH

1. Acceder al portal: `https://rhdh.su-dominio.com`
2. Navegar a **Crear** → **Elegir Plantilla**
3. Seleccionar plantilla (ej: "H2: Crear Microservicio")
4. Completar parámetros:
   - Nombre del componente
   - Descripción
   - Propietario (equipo)
   - Lenguaje/Framework
   - Tipo de deploy
5. Click en **Crear**
6. Monitorear en ArgoCD

### Plantillas Disponibles por Horizonte

#### H1 Fundación (Inicio)
| Plantilla | Caso de Uso |
|-----------|-------------|
| `basic-cicd` | Pipeline CI/CD simple |
| `security-baseline` | Configuración de seguridad |
| `documentation-site` | Sitios de documentación |
| `web-application` | Aplicaciones web full-stack |
| `new-microservice` | Microservicio básico |
| `infrastructure-provisioning` | Módulos Terraform |

#### H2 Mejoramiento (Producción)
| Plantilla | Caso de Uso |
|-----------|-------------|
| `gitops-deployment` | Aplicaciones ArgoCD |
| `microservice` | Microservicio completo |
| `api-gateway` | API Management |
| `event-driven-microservice` | Event Hubs/Service Bus |
| `data-pipeline` | ETL con Databricks |
| `batch-job` | Jobs programados |
| `reusable-workflows` | Workflows GitHub |

#### H3 Innovación (AI/Agentes)
| Plantilla | Caso de Uso |
|-----------|-------------|
| `foundry-agent` | Agentes AI Foundry |
| `sre-agent-integration` | Automatización SRE |
| `mlops-pipeline` | Pipeline ML completo |
| `multi-agent-system` | Orquestación multi-agente |
| `copilot-extension` | Extensiones GitHub Copilot |
| `rag-application` | Aplicaciones RAG |
| `ai-evaluation-pipeline` | Evaluación de modelos |

---

## ⚙️ Configuración de ArgoCD

### ApplicationSets

El acelerador usa ApplicationSets para generación dinámica de aplicaciones:

```yaml
# Monorepo - apps/* se convierte en Application
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: monorepo-apps
spec:
  generators:
    - git:
        repoURL: https://github.com/org/platform-gitops.git
        directories:
          - path: apps/*
```

### Proyectos por Ambiente

- **Dev** - auto-sync habilitado
- **Staging** - auto-sync con aprobación
- **Prod** - sync manual, ventanas de mantenimiento

### RBAC y Roles

| Rol | Permisos |
|-----|----------|
| `admin` | Acceso total |
| `platform-engineer` | Acceso total + exec |
| `sre` | Sync + actions, sin delete |
| `developer` | Total dev, sync staging, view prod |
| `qa` | Total staging, view otros |
| `release-manager` | Puede hacer sync prod |
| `ci-bot` | Deploy dev/staging/previews |

### Notificaciones

Configurado para enviar a:
- **Microsoft Teams** - Cards formateados
- **Slack** - Attachments con colores
- **Email** - Plantillas HTML
- **PagerDuty** - Incidentes críticos

---

## 📊 Observabilidad

### Dashboards Grafana

1. **Platform Overview** - Salud de la infraestructura
2. **Golden Path Application** - Métricas RED/USE
3. **AI Agent Metrics** - Observabilidad de agentes

### Alertas Prometheus

| Categoría | Alertas | Ejemplos |
|-----------|---------|----------|
| Infraestructura | 8 | CPU, Memoria, Disco, Nodo |
| Aplicaciones | 10 | Tasa de error, Latencia, Disponibilidad |
| AI & Agentes | 8 | Uso de tokens, Latencia, Errores |
| GitOps | 5 | Fallas de sync, Salud de app |
| Seguridad | 4 | Expiración de certificados, Secrets |

---

## 🔐 Seguridad

### Gestión de Secrets

El acelerador usa **External Secrets Operator** con **Azure Key Vault**:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: app-secrets
spec:
  secretStoreRef:
    name: azure-keyvault
  target:
    name: app-secrets
  data:
    - secretKey: database-password
      remoteRef:
        key: prod-database-password
```

### Workload Identity

Todas las aplicaciones usan **Azure Workload Identity** (sin secrets estáticos):

```yaml
serviceAccountName: my-app
metadata:
  annotations:
    azure.workload.identity/client-id: "<managed-identity-client-id>"
```

---

## 🔄 Migración ADO → GitHub

### Script de Migración

```bash
# Migrar repositorios de Azure DevOps a GitHub
./scripts/migration/ado-to-github-migration.sh \
  --ado-org "contoso" \
  --ado-project "MiProyecto" \
  --github-org "contoso-github" \
  --repos "repo1,repo2,repo3"
```

### Qué se Migra:
- ✅ Código fuente e historial Git
- ✅ Branches y tags
- ✅ Pull requests (como issues)
- ✅ Wiki (como repositorio separado)
- ⚠️ Pipelines (requieren conversión manual)
- ⚠️ Work items (via integración Azure Boards)

---

## 💰 Costos Estimados (USD/mes)

| Recurso | Dev | Staging | Producción |
|---------|-----|---------|------------|
| AKS (3-5 nodos) | $300 | $600 | $1,500 |
| PostgreSQL | $50 | $100 | $300 |
| Redis | $30 | $60 | $150 |
| ACR | $20 | $40 | $100 |
| AI Foundry | $100 | $300 | $1,000+ |
| Monitoreo | $50 | $100 | $250 |
| **Total** | **~$550** | **~$1,200** | **~$3,300+** |

*Nota: Costos de AI Foundry varían con uso de tokens*

---

## ⏱️ Tiempos de Deploy

| Fase | Dev | Staging | Producción |
|------|-----|---------|------------|
| H1 Fundación | 25-35 min | 35-45 min | 45-60 min |
| H2 Mejoramiento | 30-40 min | 40-50 min | 50-70 min |
| H3 Innovación | 20-30 min | 25-35 min | 35-45 min |
| **Total** | **75-105 min** | **100-130 min** | **130-175 min** |

---

## 🆘 Solución de Problemas

### Errores de Terraform

```bash
# Limpiar estado corrupto
terraform state list
terraform state rm <recurso>

# Actualizar estado
terraform refresh

# Importar recurso existente
terraform import azurerm_resource_group.main /subscriptions/.../resourceGroups/...
```

### Problemas con ArgoCD

```bash
# Ver status de sync
argocd app list
argocd app get <nombre-app>

# Forzar sync
argocd app sync <nombre-app> --force

# Ver logs
argocd app logs <nombre-app>

# Hard refresh
argocd app get <nombre-app> --hard-refresh
```

### Problemas con AKS

```bash
# Verificar nodos
kubectl get nodes
kubectl describe node <nombre-nodo>

# Ver pods problemáticos
kubectl get pods --all-namespaces | grep -v Running

# Logs del pod
kubectl logs <nombre-pod> -n <namespace> --previous
```

---

## 📞 Soporte

Para dudas, problemas o sugerencias, abra un issue en GitHub:
- **GitHub Issues:** [Crear Issue](https://github.com/paulanunes85/three-horizons-accelerator-v4/issues)

---

## 📚 Referencias

### Documentación Oficial
- [Azure AKS](https://docs.microsoft.com/azure/aks/)
- [ArgoCD](https://argo-cd.readthedocs.io/)
- [Red Hat Developer Hub](https://developers.redhat.com/rhdh)
- [Azure AI Foundry](https://azure.microsoft.com/products/ai-foundry/)
- [GitHub Actions](https://docs.github.com/actions)
- [External Secrets Operator](https://external-secrets.io/)

---

## 📝 Historial de Versiones

### v4.0.0 (Diciembre 2025) - Unified Agentic DevOps
- ✅ 14 módulos Terraform (incluyendo Defender, Purview, Naming)
- ✅ 23 agentes AI para orquestación inteligente
- ✅ 25 plantillas de GitHub Issues
- ✅ 21 plantillas Golden Path
- ✅ 10 scripts de automatización
- ✅ 15 configuraciones MCP Server
- ✅ Stack de observabilidad completo
- ✅ Documentación multi-idioma

### v3.0.0 (Diciembre 2024)
- 11 módulos Terraform
- 21 plantillas Golden Path
- 6 scripts de automatización

---

**Versión:** 4.0.0 Unified
**Última Actualización:** Diciembre 2025
**Mantenido por:** Microsoft LATAM Platform Engineering
**Licencia:** MIT
