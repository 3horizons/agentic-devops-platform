# Guia de Início Rápido - Acelerador Three Horizons

🌐 **Idioma / Language:** [English](QUICKSTART.md) | [Português](#) | [Español](QUICKSTART.es.md)

---

## ⚡ Deploy em 15 Minutos

Este guia vai ajudá-lo a fazer o deploy da plataforma Three Horizons rapidamente.

---

## 📋 Lista de Pré-requisitos

### Ferramentas Necessárias

```bash
# Verificar todas as ferramentas de uma vez
echo "=== Verificando Pré-requisitos ===" && \
az version --query '"Azure CLI: " + "azure-cli"' -o tsv && \
terraform version | head -1 && \
kubectl version --client -o yaml | grep gitVersion && \
helm version --short && \
gh --version | head -1
```

**Versões Mínimas:**
| Ferramenta | Versão Mínima | Comando de Instalação |
|------------|---------------|----------------------|
| Azure CLI | 2.50.0 | `curl -sL https://aka.ms/InstallAzureCLIDeb \| sudo bash` |
| Terraform | 1.5.0 | `brew install terraform` ou [Download](https://terraform.io/downloads) |
| kubectl | 1.28 | `az aks install-cli` |
| Helm | 3.12 | `brew install helm` |
| GitHub CLI | 2.30 | `brew install gh` |

### Permissões Necessárias

- **Azure**: Role de Contributor na subscription alvo
- **GitHub**: Acesso de Admin na organização alvo
- **Entra ID**: Application Administrator (para Workload Identity)

---

## 🚀 Deploy Passo a Passo

### Passo 1: Autenticar (2 min)

```bash
# Login Azure
az login
az account set --subscription "SUA_SUBSCRIPTION_ID"

# Login GitHub
gh auth login

# Verificar
az account show --query name -o tsv
gh auth status
```

### Passo 2: Clonar e Configurar (3 min)

```bash
# Clonar o acelerador
git clone https://github.com/YOUR_ORG/three-horizons-accelerator-v4.git
cd three-horizons-accelerator-v4

# Tornar scripts executáveis
chmod +x scripts/*.sh

# Validar pré-requisitos
./scripts/validate-cli-prerequisites.sh

# Copiar e editar configuração
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

**Edite `terraform/terraform.tfvars`:**

```hcl
# Obrigatório - Altere estes valores
project_name        = "threehorizons"        # Nome do projeto (minúsculas, sem espaços)
environment         = "dev"                   # dev, staging ou prod
location            = "brazilsouth"           # Região Azure
subscription_id     = "xxxxxxxx-xxxx-xxxx"   # Sua Azure subscription ID
github_org          = "sua-org-github"        # Sua organização GitHub

# Opcional - Personalize conforme necessário
aks_node_count      = 3                       # 3 para dev, 5+ para prod
enable_h2           = true                    # Habilitar ArgoCD/RHDH
enable_h3           = false                   # Habilitar AI Foundry (adicionar depois)

# Tags
tags = {
  Project     = "ThreeHorizons"
  Environment = "Dev"
  Owner       = "seu-email@empresa.com"
}
```

### Passo 3: Deploy H1 Fundação (10 min)

```bash
cd terraform

# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Planejar deployment
terraform plan -out=tfplan

# Aplicar (confirme com 'yes')
terraform apply tfplan
```

**Saída Esperada:**
```
Apply complete! Resources: 23 added, 0 changed, 0 destroyed.

Outputs:
aks_cluster_name = "threehorizons-dev-aks"
acr_login_server = "threehorizonsdev.azurecr.io"
keyvault_name    = "threehorizons-dev-kv"
resource_group   = "threehorizons-dev-rg"
```

### Passo 4: Conectar ao AKS

```bash
# Obter credenciais do AKS
az aks get-credentials \
  --resource-group $(terraform output -raw resource_group) \
  --name $(terraform output -raw aks_cluster_name)

# Verificar conexão
kubectl get nodes
kubectl get namespaces
```

---

## 🎯 Referência Rápida de Comandos

### Deploy por Horizonte

```bash
# Apenas H1 (Fundação)
./scripts/platform-bootstrap.sh --horizon h1 --environment dev

# H1 + H2 (com ArgoCD/RHDH)
./scripts/platform-bootstrap.sh --horizon h2 --environment dev

# Plataforma Completa (H1 + H2 + H3)
./scripts/platform-bootstrap.sh --environment dev
```

### Atalhos Úteis

```bash
# Verificar status do deployment
kubectl get pods -A | grep -v Running

# Acessar UI do ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Abrir: https://localhost:8080

# Obter senha do ArgoCD
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Acessar Grafana
kubectl port-forward svc/grafana -n observability 3000:80
# Abrir: http://localhost:3000 (admin/admin)
```

---

## ✅ Lista de Verificação

Após o deployment, verifique estes componentes:

### H1 Fundação
- [ ] Cluster AKS rodando: `kubectl get nodes`
- [ ] ACR acessível: `az acr list -o table`
- [ ] Key Vault criado: `az keyvault list -o table`
- [ ] VNet configurada: `az network vnet list -o table`

### H2 Aprimoramento (se habilitado)
- [ ] ArgoCD rodando: `kubectl get pods -n argocd`
- [ ] RHDH acessível: `kubectl get pods -n rhdh`
- [ ] Prometheus rodando: `kubectl get pods -n observability`
- [ ] Grafana acessível: `kubectl get pods -n observability`

### H3 Inovação (se habilitado)
- [ ] AI Foundry deployado: `az cognitiveservices account list`
- [ ] OpenAI disponível: Verificar Portal Azure

---

## 🔧 Problemas Comuns e Soluções

### Problema: Terraform init falha

```bash
# Limpar cache e tentar novamente
rm -rf .terraform .terraform.lock.hcl
terraform init -upgrade
```

### Problema: Cluster AKS não pronto

```bash
# Verificar status dos nós
kubectl describe nodes

# Verificar pods pendentes
kubectl get pods -A --field-selector=status.phase!=Running
```

### Problema: ArgoCD não acessível

```bash
# Verificar pods do ArgoCD
kubectl get pods -n argocd

# Reiniciar se necessário
kubectl rollout restart deployment argocd-server -n argocd
```

### Problema: Permissão negada

```bash
# Verificar role do Azure
az role assignment list --assignee $(az account show --query user.name -o tsv) -o table

# Verificar permissões GitHub
gh api /user --jq '.login'
```

---

## 📊 Resumo de Recursos

### O que é Deployado (H1)

| Recurso | Padrão de Nome | Quantidade |
|---------|----------------|------------|
| Resource Group | `{projeto}-{env}-rg` | 1 |
| Cluster AKS | `{projeto}-{env}-aks` | 1 |
| Container Registry | `{projeto}{env}acr` | 1 |
| Key Vault | `{projeto}-{env}-kv` | 1 |
| Virtual Network | `{projeto}-{env}-vnet` | 1 |
| Managed Identity | `{projeto}-{env}-identity` | 2-3 |
| NSG | `{projeto}-{env}-nsg-*` | 3 |

### Tempo Estimado de Deployment

| Componente | Tempo |
|------------|-------|
| Resource Group | 10 seg |
| VNet + Subnets | 30 seg |
| Cluster AKS | 5-8 min |
| ACR | 1 min |
| Key Vault | 30 seg |
| **Total H1** | **~10 min** |

---

## 🚀 Próximos Passos

Após deployment bem-sucedido:

1. **Registrar Templates Golden Path**
   ```bash
   ./scripts/bootstrap.sh --register-templates
   ```

2. **Criar Sua Primeira Aplicação**
   - Acesse o portal RHDH
   - Selecione o template "H1: Basic Microservice"
   - Siga o assistente

3. **Configurar Notificações**
   - Edite `argocd/notifications.yaml`
   - Adicione seus webhooks do Teams/Slack

4. **Habilitar H3 (AI Foundry)**
   ```bash
   terraform apply -var="enable_h3=true"
   ```

---

## 📞 Precisa de Ajuda?

| Recurso | Link |
|---------|------|
| Documentação Completa | [README.pt-BR.md](README.pt-BR.md) |
| Solução de Problemas | [README.pt-BR.md#solução-de-problemas](README.pt-BR.md#-solução-de-problemas) |
| Canal de Suporte | #platform-engineering |

---

**Versão:** 4.0.0
**Última Atualização:** Dezembro 2025
