# Code Citations

## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3000
  volumePermissions:
    enabled: true
EOF

# Install — vers
```


## License: Apache-2.0
https://github.com/redhat-developer/red-hat-developers-documentation-rhdh/blob/04d6035116359c257d74435f6c1aba0b19118011/admin/proc-rhdh-deploy-aks.adoc

```
Os agentes foram atualizados pelo usuário com ferramentas muito mais completas (MCPs do Azure, PostgreSQL, browser, AI Toolkit, etc.). O ecossistema está pronto.

Baseado na documentação oficial Red Hat que acabei de ler, aqui está o **guia de deploy passo a passo** alinhado com os docs oficiais e agentes:

---

## Deploy do Zero — Seguindo Documentação Oficial RHDH 1.8

A doc oficial em [installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_microsoft_azure_kubernetes_service_aks.md) oferece **2 métodos** para AKS:

| Método | Doc Oficial Cap. | Agente | Quando Usar |
|--------|-----------------|--------|-------------|
| **Operator (OLM)** | Chapter 1 | `@azure-portal-deploy` → `@deploy` | Produção, updates automáticos |
| **Helm Chart** | Chapter 2 | `@azure-portal-deploy` → `@deploy` | Dev/staging, mais simples |

E para ARO via [installing_red_hat_developer_hub_on_openshift_container_platform.md](docs/official-docs/rhdh/markdown/installing_red_hat_developer_hub_on_openshift_container_platform.md):

| Método | Agente | Quando Usar |
|--------|--------|-------------|
| **Operator via OperatorHub** | `@deploy` (ARO) | ARO/OpenShift, preferido pela Red Hat |

---

### Etapa 1: Pre-requisitos (`@onboarding`)

```bash
# Validar CLIs instaladas
./scripts/validate-prerequisites.sh --core

# Login Azure
az login
az account set --subscription <subscription-id>

# Registrar providers
az provider register -n Microsoft.ContainerService
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.KeyVault
az provider register -n Microsoft.DBforPostgreSQL
```

### Etapa 2: Infraestrutura Base (`@azure-portal-deploy`)

```bash
# Resource Group
az group create --name rg-3horizons-dev --location centralus

# ACR
az acr create --name acr3horizonsdev --resource-group rg-3horizons-dev \
  --sku Basic --location centralus

# AKS (Chapter 2 da doc)
az aks create \
  --resource-group rg-3horizons-dev \
  --name aks-3horizons-dev \
  --enable-managed-identity \
  --generate-ssh-keys \
  --node-count 3 --node-vm-size Standard_D4s_v5 \
  --attach-acr acr3horizonsdev \
  --location centralus

# Habilitar App Routing (Ingress) — doc oficial recomenda
az aks approuting enable --resource-group rg-3horizons-dev --name aks-3horizons-dev

# Conectar
az aks get-credentials --resource-group rg-3horizons-dev --name aks-3horizons-dev
```

### Etapa 3a: Deploy RHDH no AKS via Helm (`@deploy` — Chapter 2 da doc)

```bash
# Namespace
NAMESPACE=rhdh
DEPLOYMENT_NAME=redhat-developer-hub
kubectl create namespace ${NAMESPACE}

# Pull secret (usando seu pull-secret-ARO.txt)
kubectl -n ${NAMESPACE} create secret docker-registry rhdh-pull-secret \
  --docker-server=registry.redhat.io \
  --docker-username=<user> \
  --docker-password=<token> \
  --docker-email=<email>

# Helm repo
helm repo add openshift-helm-charts https://charts.openshift.io/

# values.yaml (conforme doc oficial Chapter 2)
cat > values.yaml << 'EOF'
global:
  host: ""
route:
  enabled: false
upstream:
  ingress:
    enabled: true
    className: webapprouting.kubernetes.azure.com
    host:
  backstage:
    image:
      pullSecrets:
        - rhdh-pull-secret
    podSecurityContext:
      fsGroup: 3000
  postgresql:
    image:
      pullSecrets:
        - rhdh-pull-secret
    primary:
      podSecurityContext:
        enabled: true
        fsGroup: 3000
  volumePermissions:
    enabled: true
EOF

# Install — vers
```

