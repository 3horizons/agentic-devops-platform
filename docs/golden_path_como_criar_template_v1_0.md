# Golden Path Template — Como Criar

> **3 Abordagens para Transformar o 3horizons/todo-app em Template RHDH**
> Guia Prático com Implementação Completa
>
> Version 1.0 | Microsoft LATAM — Platform Engineering | paulasilva@microsoft.com

---

## O Problema

Você tem o repositório 3horizons/todo-app com o app funcionando. Quer que quando um dev clique "Create" no RHDH, um NOVO repositório seja criado a partir desse app — com nome customizado, infra no Azure, Codespaces, agents, etc.

A pergunta é: onde mora o template.yaml e como ele encontra o código do todo-app?

O Backstage scaffolder tem uma action chamada `fetch:template` que aceita um parâmetro `url`. Esse url pode ser um caminho relativo (`./skeleton`) ou uma URL remota do GitHub. Isso abre 3 possibilidades:

---

## As 3 Abordagens

### Opção A — Tudo no Mesmo Repo (RECOMENDADA para demo)

Adicionar o template.yaml na RAIZ do 3horizons/todo-app. O repositório inteiro vira o skeleton. O `fetch:template` aponta para `./` (o próprio repo).

Estrutura do repo:

```
3horizons/todo-app/
├── template.yaml          ← ADICIONAR (definição do template)
├── catalog-info.yaml.njk  ← ADICIONAR (com variáveis ${{ values.* }})
├── .devcontainer/         ← ADICIONAR
├── .github/agents/        ← JÁ EXISTE + novos agents
├── .github/workflows/     ← JÁ EXISTE
├── frontend/              ← JÁ EXISTE
├── backend/               ← JÁ EXISTE
├── terraform/             ← JÁ EXISTE
├── e2e/                   ← JÁ EXISTE
└── docs/                  ← JÁ EXISTE
```

No template.yaml, o `fetch:template` fica assim:

```yaml
- id: fetch-skeleton
  action: fetch:template
  input:
    url: ./                                    # aponta para o PRÓPRIO repo
    templateFileExtension: '.njk'              # só processa .njk files
    copyWithoutTemplating:
      - '**/*.png'
      - '**/*.ico'
      - '**/*.zip'
      - '**/*.woff2'
      - '**/node_modules/**'
    values:
      name: ${{ parameters.name }}
      environment: ${{ parameters.environment }}
      azure_region: ${{ parameters.azure_region }}
```

| Vantagem | Desvantagem |
|----------|-------------|
| ZERO repos extras — tudo num lugar só | template.yaml vai para o repo do dev (mas é inofensivo) |
| O app funciona normalmente E é template ao mesmo tempo | Precisa cuidar com variáveis $\{\{ \}\} em arquivos que não devem ser processados |
| Uma branch = uma versão do template + app | Arquivos .zip, .png, logs não devem ser templateados |
| Mais simples de manter e versionar | Precisa do copyWithoutTemplating para binários |

**COMO RESOLVER a variável:** Em vez de colocar `${{ values.name }}` diretamente nos arquivos do app (o que quebraria o app rodando localmente), usamos a abordagem de Nunjucks com extensão `.njk`. Os arquivos que precisam de variáveis ganham extensão `.njk` (ex: `catalog-info.yaml.njk`) e o `templateFileExtension: '.njk'` garante que SÓ esses arquivos são processados. Os demais são copiados sem alteração.

---

### Opção B — Repo Separado com skeleton/ (Produção)

Criar um novo repo `3horizons/golden-path-todo-app` que contém o template.yaml e uma pasta `skeleton/` com uma CÓPIA do código do todo-app (com variáveis `${{ values.* }}`).

Estrutura:

```
3horizons/golden-path-todo-app/     ← REPO NOVO
├── template.yaml
└── skeleton/                        ← cópia do todo-app com variáveis
    ├── catalog-info.yaml            ← ${{ values.name }}, ${{ values.owner }}
    ├── .devcontainer/
    ├── .github/
    ├── frontend/
    ├── backend/
    ├── terraform/
    └── ...

3horizons/todo-app/                  ← REPO ORIGINAL (fica como está)
```

| Vantagem | Desvantagem |
|----------|-------------|
| Separação clara: app ≠ template | DOIS repos para manter — código duplicado |
| O skeleton pode ter variáveis livremente | Quando o app muda, precisa atualizar o skeleton |
| Padrão da indústria para templates Backstage | Mais overhead de manutenção |
| template.yaml não vai para o repo do dev | Para demo, é complexidade desnecessária |

---

### Opção C — Repo Separado com URL Remota (Híbrido)

Criar um repo mínimo com SÓ o template.yaml, que aponta para o 3horizons/todo-app via URL remota.

Estrutura:

```
3horizons/golden-path-todo-app/     ← REPO NOVO (mínimo)
└── template.yaml                    ← url: https://github.com/3horizons/todo-app/tree/main

3horizons/todo-app/                  ← REPO ORIGINAL (fonte do skeleton)
```

No template.yaml:

```yaml
- id: fetch-skeleton
  action: fetch:template
  input:
    url: https://github.com/3horizons/todo-app/tree/main    # URL REMOTA
    values:
      name: ${{ parameters.name }}
```

| Vantagem | Desvantagem |
|----------|-------------|
| Template repo é minúsculo (1 arquivo) | Precisa que o todo-app seja público (ou GitHub App com acesso) |
| Zero duplicação de código | Mais lento: scaffold baixa de URL remota em vez de local |
| O app vive normalmente sem saber que é template | Não funciona bem com variáveis — copia raw sem substituição |
| Simples de entender | LIMITAÇÃO: fetch:template com URL remota TEM problemas com Nunjucks vars |

---

## Recomendação: Opção A para Demo

Para o cenário de demo, a Opção A é a melhor. Motivos:

1. **ZERO repos extras:** só precisa do 3horizons/todo-app que já existe
2. **O app continua funcionando normalmente** (as variáveis ficam só nos arquivos .njk)
3. **Para a demo, o template.yaml aparecer no repo do dev não é problema**
4. **Manutenção simples:** uma mudança no app = atualização automática do template
5. **Quando quiser ir para produção,** migra para Opção B (mover para skeleton/)

---

## Implementação Completa — Opção A

Aqui está o passo a passo exato para transformar o 3horizons/todo-app existente em um Golden Path template.

### Passo 1: Adicionar template.yaml na raiz

Este arquivo define o template que aparece no RHDH Self-service. Colocar na raiz do repo 3horizons/todo-app.

O template.yaml já foi criado e entregue no ZIP anterior. O ponto-chave é o step `fetch:template` com `url: './'`.

### Passo 2: Criar arquivos com variáveis (.njk)

Arquivos que precisam de customização por instância ganham extensão `.njk`. O scaffolder processa SOMENTE esses arquivos, substituindo as variáveis.

| Arquivo Original | Arquivo Template | Variáveis Substituídas |
|------------------|-----------------|----------------------|
| catalog-info.yaml | catalog-info.yaml.njk | `${{ values.name }}`, `${{ values.owner }}`, `${{ values.system }}`, `${{ values.orgName }}` |
| package.json (frontend) | Não precisa .njk | O nome do repo fica só no catalog-info e terraform — package.json mantém "todo-app" |
| package.json (backend) | Não precisa .njk | Mesmo motivo — o nome é genérico |
| terraform/environments/dev.tfvars | terraform/environments/dev.tfvars.njk | `${{ values.name }}`, `${{ values.azure_region }}`, `${{ values.environment }}` |
| .github/workflows/*.yml | Não precisa .njk | Workflows são genéricos — secrets vêm do GitHub environment |
| .devcontainer/devcontainer.json | Não precisa .njk | Config é idêntica para todas as instâncias |

Na prática, POUCOS arquivos precisam de variáveis. A maioria do código do app é copiada sem alteração. Só o catalog-info.yaml (identidade no RHDH) e o terraform.tfvars (configuração Azure) precisam de customização.

### Passo 3: Adicionar os novos arquivos

Arquivos que não existem no repo e precisam ser criados:

1. `template.yaml` (raiz) — definição do template RHDH
2. `catalog-info.yaml.njk` (raiz) — entity RHDH com variáveis
3. `.devcontainer/devcontainer.json` — Codespaces config
4. `.devcontainer/post-create.sh` — script de auto-setup
5. `.github/agents/todo-dev.agent.md` — agent de desenvolvimento
6. `.github/agents/todo-deploy.agent.md` — agent de deploy
7. `.github/agents/todo-sre.agent.md` — agent de SRE
8. `.github/copilot-instructions.md` — contexto global Copilot
9. `.vscode/mcp.json` — configuração MCP servers

Todos esses arquivos já foram entregues no ZIP `golden_path_todo_app_implementation_v1_0.zip`.

### Passo 4: Registrar no RHDH

Para que o template apareça no portal, registrar via Location entity:

1. No RHDH, ir em Settings → Locations (ou usar a API do catalog)
2. Adicionar uma nova Location apontando para o template.yaml:
   - **Type:** url
   - **Target:** `https://github.com/3horizons/todo-app/blob/main/template.yaml`
3. O RHDH lê o template.yaml, descobre que é `kind: Template`, e exibe no Self-service
4. Agora qualquer dev que clicar Create → verá "Full-Stack Todo Application"

Alternativamente, registrar via `app-config-rhdh.yaml`:

```yaml
catalog:
  locations:
    - type: url
      target: https://github.com/3horizons/todo-app/blob/main/template.yaml
      rules:
        - allow: [Template]
```

### Passo 5: Testar o Fluxo Completo

1. Abrir RHDH → login GitHub → Create → buscar "Todo"
2. Clicar "Choose" no template Full-Stack Todo Application
3. Preencher o wizard: name='test-todo', environment='dev', region='brazilsouth'
4. Clicar Create → verificar que os 4 steps executam sem erro
5. Verificar: novo repo criado? catalog-info.yaml com o nome correto? infra deploying?
6. Abrir o novo repo → verificar que template.yaml NÃO tem variáveis (foram substituídas)
7. Abrir Codespace → verificar que .devcontainer funciona
8. Cleanup: deletar o repo de teste e o resource group Azure

---

## template.yaml Final (Opção A)

Versão completa do template.yaml para colocar na raiz do 3horizons/todo-app. Diferença-chave da versão anterior: `url: './'` em vez de `./skeleton`.

Os steps são:

| # | Step | Action | O Que Faz |
|---|------|--------|-----------|
| 1 | fetch-skeleton | fetch:template | Copia o PRÓPRIO repo (url: './'), processa .njk files com variáveis, ignora binários |
| 2 | publish-repo | publish:github | Cria novo repo no GitHub com todos os arquivos já processados |
| 3 | deploy-infra | github:actions:dispatch | Dispara o workflow infrastructure-deploy.yml no novo repo |
| 4 | register-catalog | catalog:register | Registra o componente no catálogo RHDH via catalog-info.yaml |

O step 3 (deploy-infra) funciona porque o workflow infrastructure-deploy.yml está nos arquivos que foram copiados para o novo repo. Quando o scaffolder faz o dispatch, o workflow roda no NOVO repo com as credenciais do NOVO repo (GitHub Environments + Secrets).

---

## Resumo Visual do Fluxo

Dev clica "Create" no RHDH → RHDH lê template.yaml do 3horizons/todo-app → Wizard (3 páginas) → Scaffolder executa steps:

1. **fetch:template** (url: './') → baixa todo o repo → processa .njk → output: arquivos processados em memória
2. **publish:github** → cria 3horizons/meu-novo-app → push dos arquivos → branch protection
3. **github:actions:dispatch** → infrastructure-deploy.yml roda no NOVO repo → Terraform cria Azure resources
4. **catalog:register** → RHDH lê catalog-info.yaml do NOVO repo → entidade aparece no catálogo

**Resultado:** dev tem um repo próprio, com Codespaces, CI/CD, agents, infra no Azure — tudo criado a partir de um único clique no portal.

---

## E Depois? Migração para Opção B (Produção)

Quando a demo funcionar perfeitamente e vocês quiserem ir para produção com múltiplos templates, a migração para Opção B é simples:

1. Criar repo `3horizons/golden-paths/` (pode ter múltiplos templates)
2. Criar pasta `golden-paths/fullstack-todo-app/`
3. Mover template.yaml para `golden-paths/fullstack-todo-app/template.yaml`
4. Copiar o 3horizons/todo-app para `golden-paths/fullstack-todo-app/skeleton/`
5. Converter os .njk para variáveis diretas `${{ values.* }}` (sem extensão .njk)
6. Atualizar o url no fetch:template de `./` para `./skeleton`
7. Atualizar a Location no RHDH para apontar para o novo repo
8. Manter o 3horizons/todo-app como o "app de referência" para desenvolvimento

Nesse ponto, o `golden-paths/` repo pode ter outros templates também: `golden-paths/python-microservice/`, `golden-paths/dotnet-api/`, `golden-paths/data-pipeline/`, etc.

---

## Sources

1. [RHDH 1.8 Software Templates](https://docs.redhat.com/en/documentation/red_hat_developer_hub/1.8/html/streamline_software_development/)
2. [Backstage fetch:template Action](https://backstage.io/docs/features/software-templates/builtin-actions/fetch-template/)
3. Developer Portals Summit eBook — Chapter 3 (project knowledge)
4. [Golden Paths and Developer Productivity](https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity)
