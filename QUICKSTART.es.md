# Guía de Inicio Rápido - Acelerador Three Horizons

🌐 **Idioma / Language:** [English](QUICKSTART.md) | [Português](QUICKSTART.pt-BR.md) | [Español](#)

---

## ⚡ Deploy en 15 Minutos

Esta guía le ayudará a hacer el deploy de la plataforma Three Horizons rápidamente.

---

## 📋 Lista de Prerrequisitos

### Herramientas Requeridas

```bash
# Verificar todas las herramientas de una vez
echo "=== Verificando Prerrequisitos ===" && \
az version --query '"Azure CLI: " + "azure-cli"' -o tsv && \
terraform version | head -1 && \
kubectl version --client -o yaml | grep gitVersion && \
helm version --short && \
gh --version | head -1
```

**Versiones Mínimas:**
| Herramienta | Versión Mínima | Comando de Instalación |
|-------------|----------------|------------------------|
| Azure CLI | 2.50.0 | `curl -sL https://aka.ms/InstallAzureCLIDeb \| sudo bash` |
| Terraform | 1.5.0 | `brew install terraform` o [Descargar](https://terraform.io/downloads) |
| kubectl | 1.28 | `az aks install-cli` |
| Helm | 3.12 | `brew install helm` |
| GitHub CLI | 2.30 | `brew install gh` |

### Permisos Requeridos

- **Azure**: Rol de Contributor en la subscription destino
- **GitHub**: Acceso de Admin en la organización destino
- **Entra ID**: Application Administrator (para Workload Identity)

---

## 🚀 Deploy Paso a Paso

### Paso 1: Autenticar (2 min)

```bash
# Login Azure
az login
az account set --subscription "TU_SUBSCRIPTION_ID"

# Login GitHub
gh auth login

# Verificar
az account show --query name -o tsv
gh auth status
```

### Paso 2: Clonar y Configurar (3 min)

```bash
# Clonar el acelerador
git clone https://github.com/YOUR_ORG/three-horizons-accelerator-v4.git
cd three-horizons-accelerator-v4

# Hacer scripts ejecutables
chmod +x scripts/*.sh

# Validar prerrequisitos
./scripts/validate-cli-prerequisites.sh

# Copiar y editar configuración
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

**Editar `terraform/terraform.tfvars`:**

```hcl
# Requerido - Cambiar estos valores
project_name        = "threehorizons"        # Nombre del proyecto (minúsculas, sin espacios)
environment         = "dev"                   # dev, staging o prod
location            = "brazilsouth"           # Región Azure
subscription_id     = "xxxxxxxx-xxxx-xxxx"   # Tu Azure subscription ID
github_org          = "tu-org-github"         # Tu organización GitHub

# Opcional - Personalizar según necesidad
aks_node_count      = 3                       # 3 para dev, 5+ para prod
enable_h2           = true                    # Habilitar ArgoCD/RHDH
enable_h3           = false                   # Habilitar AI Foundry (agregar después)

# Tags
tags = {
  Project     = "ThreeHorizons"
  Environment = "Dev"
  Owner       = "tu-email@empresa.com"
}
```

### Paso 3: Deploy H1 Fundación (10 min)

```bash
cd terraform

# Inicializar Terraform
terraform init

# Validar configuración
terraform validate

# Planear deployment
terraform plan -out=tfplan

# Aplicar (confirmar con 'yes')
terraform apply tfplan
```

**Salida Esperada:**
```
Apply complete! Resources: 23 added, 0 changed, 0 destroyed.

Outputs:
aks_cluster_name = "threehorizons-dev-aks"
acr_login_server = "threehorizonsdev.azurecr.io"
keyvault_name    = "threehorizons-dev-kv"
resource_group   = "threehorizons-dev-rg"
```

### Paso 4: Conectar a AKS

```bash
# Obtener credenciales de AKS
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group) \
  --name $(terraform output -raw aks_cluster_name)

# Verificar conexión
kubectl get nodes
kubectl get namespaces
```

---

## 🎯 Referencia Rápida de Comandos

### Deploy por Horizonte

```bash
# Solo H1 (Fundación)
./scripts/platform-bootstrap.sh --horizon h1 --environment dev

# H1 + H2 (con ArgoCD/RHDH)
./scripts/platform-bootstrap.sh --horizon h2 --environment dev

# Plataforma Completa (H1 + H2 + H3)
./scripts/platform-bootstrap.sh --environment dev
```

### Atajos Útiles

```bash
# Verificar status del deployment
kubectl get pods -A | grep -v Running

# Acceder UI de ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Abrir: https://localhost:8080

# Obtener contraseña de ArgoCD
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Acceder Grafana
kubectl port-forward svc/grafana -n observability 3000:80
# Abrir: http://localhost:3000 (admin/admin)
```

---

## ✅ Lista de Verificación

Después del deployment, verificar estos componentes:

### H1 Fundación
- [ ] Cluster AKS ejecutando: `kubectl get nodes`
- [ ] ACR accesible: `az acr list -o table`
- [ ] Key Vault creado: `az keyvault list -o table`
- [ ] VNet configurada: `az network vnet list -o table`

### H2 Mejoramiento (si habilitado)
- [ ] ArgoCD ejecutando: `kubectl get pods -n argocd`
- [ ] RHDH accesible: `kubectl get pods -n rhdh`
- [ ] Prometheus ejecutando: `kubectl get pods -n observability`
- [ ] Grafana accesible: `kubectl get pods -n observability`

### H3 Innovación (si habilitado)
- [ ] AI Foundry deployado: `az cognitiveservices account list`
- [ ] OpenAI disponible: Verificar Portal Azure

---

## 🔧 Problemas Comunes y Soluciones

### Problema: Terraform init falla

```bash
# Limpiar cache y reintentar
rm -rf .terraform .terraform.lock.hcl
terraform init -upgrade
```

### Problema: Cluster AKS no listo

```bash
# Verificar status de los nodos
kubectl describe nodes

# Verificar pods pendientes
kubectl get pods -A --field-selector=status.phase!=Running
```

### Problema: ArgoCD no accesible

```bash
# Verificar pods de ArgoCD
kubectl get pods -n argocd

# Reiniciar si necesario
kubectl rollout restart deployment argocd-server -n argocd
```

### Problema: Permiso denegado

```bash
# Verificar rol de Azure
az role assignment list --assignee $(az account show --query user.name -o tsv) -o table

# Verificar permisos GitHub
gh api /user --jq '.login'
```

---

## 📊 Resumen de Recursos

### Qué se Deploya (H1)

| Recurso | Patrón de Nombre | Cantidad |
|---------|------------------|----------|
| Resource Group | `{proyecto}-{env}-rg` | 1 |
| Cluster AKS | `{proyecto}-{env}-aks` | 1 |
| Container Registry | `{proyecto}{env}acr` | 1 |
| Key Vault | `{proyecto}-{env}-kv` | 1 |
| Virtual Network | `{proyecto}-{env}-vnet` | 1 |
| Managed Identity | `{proyecto}-{env}-identity` | 2-3 |
| NSG | `{proyecto}-{env}-nsg-*` | 3 |

### Tiempo Estimado de Deployment

| Componente | Tiempo |
|------------|--------|
| Resource Group | 10 seg |
| VNet + Subnets | 30 seg |
| Cluster AKS | 5-8 min |
| ACR | 1 min |
| Key Vault | 30 seg |
| **Total H1** | **~10 min** |

---

## 🚀 Próximos Pasos

Después de deployment exitoso:

1. **Registrar Plantillas Golden Path**
   ```bash
   ./scripts/bootstrap.sh --register-templates
   ```

2. **Crear Tu Primera Aplicación**
   - Acceder al portal RHDH
   - Seleccionar la plantilla "H1: Basic Microservice"
   - Seguir el asistente

3. **Configurar Notificaciones**
   - Editar `argocd/notifications.yaml`
   - Agregar tus webhooks de Teams/Slack

4. **Habilitar H3 (AI Foundry)**
   ```bash
   terraform apply -var="enable_h3=true"
   ```

---

## 📞 ¿Necesitas Ayuda?

| Recurso | Enlace |
|---------|--------|
| Documentación Completa | [README.es.md](README.es.md) |
| Solución de Problemas | [docs/guides/TROUBLESHOOTING_GUIDE.md](docs/guides/TROUBLESHOOTING_GUIDE.md) |
| GitHub Issues | [Crear Issue](https://github.com/paulanunes85/three-horizons-accelerator-v4/issues) |

---

**Versión:** 4.0.0
**Última Actualización:** Diciembre 2025
