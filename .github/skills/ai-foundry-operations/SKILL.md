````skill
---
name: ai-foundry-operations
description: 'Azure AI Foundry operations for Three Horizons Accelerator. Use when deploying AI workloads, managing AI models, configuring AI endpoints. Covers Azure AI Studio, model deployment, RAG patterns, prompt flow, AI agents, MLOps pipelines.'
license: Complete terms in LICENSE.txt
---

# AI Foundry Operations Skill

Comprehensive skill for Azure AI Foundry operations in the Three Horizons Accelerator platform.

**Version:** 1.0.0

---

## Overview

This skill encapsulates all tools required for AI Foundry operations:
- **MCP Servers**: azure
- **Terraform Modules**: ai-foundry
- **Golden Paths**: foundry-agent, rag-application
- **Services**: Azure AI Studio, Azure OpenAI, Azure AI Search

---

## MCP Server Configuration

### Azure MCP Server

```json
{
  "azure": {
    "command": "npx",
    "args": ["-y", "@anthropic/mcp-azure"],
    "capabilities": [
      "az cognitiveservices",
      "az ml",
      "az search"
    ]
  }
}
```

---

## Azure AI Foundry Components

### Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Azure AI Foundry                          │
├─────────────────┬─────────────────┬─────────────────────────┤
│  AI Hub         │  AI Project     │  AI Services            │
│  ├─ Workspace   │  ├─ Endpoints   │  ├─ Azure OpenAI        │
│  ├─ Compute     │  ├─ Flows       │  ├─ AI Search           │
│  ├─ Storage     │  ├─ Datasets    │  ├─ Content Safety      │
│  └─ Connections │  └─ Evaluations │  └─ Document Intel.     │
└─────────────────┴─────────────────┴─────────────────────────┘
```

---

## Azure OpenAI Service

### Create Azure OpenAI Resource

```bash
# Create Azure OpenAI account
az cognitiveservices account create \
  --resource-group ${RESOURCE_GROUP} \
  --name oai-${PROJECT}-${ENV}-${LOCATION_SHORT} \
  --location ${LOCATION} \
  --kind OpenAI \
  --sku S0 \
  --custom-domain oai-${PROJECT}-${ENV} \
  --tags Environment=${ENV} Project=${PROJECT}

# List models
az cognitiveservices account list-models \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT} \
  --output table
```

### Deploy Models

```bash
# Deploy GPT-4o model
az cognitiveservices account deployment create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT} \
  --deployment-name gpt-4o \
  --model-name gpt-4o \
  --model-version "2024-05-13" \
  --model-format OpenAI \
  --sku-name Standard \
  --sku-capacity 40

# Deploy text-embedding-3-large
az cognitiveservices account deployment create \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT} \
  --deployment-name text-embedding-3-large \
  --model-name text-embedding-3-large \
  --model-version "1" \
  --model-format OpenAI \
  --sku-name Standard \
  --sku-capacity 120

# List deployments
az cognitiveservices account deployment list \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT} \
  --output table
```

### Get Endpoint and Keys

```bash
# Get endpoint
az cognitiveservices account show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT} \
  --query "properties.endpoint" -o tsv

# Get keys
az cognitiveservices account keys list \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT}
```

---

## Azure AI Search

### Create AI Search Service

```bash
# Create AI Search service
az search service create \
  --resource-group ${RESOURCE_GROUP} \
  --name srch-${PROJECT}-${ENV}-${LOCATION_SHORT} \
  --location ${LOCATION} \
  --sku standard \
  --partition-count 1 \
  --replica-count 1 \
  --semantic-search standard \
  --tags Environment=${ENV} Project=${PROJECT}
```

### Create Search Index

```bash
# Get admin key
SEARCH_KEY=$(az search admin-key show \
  --resource-group ${RESOURCE_GROUP} \
  --service-name ${SEARCH_SERVICE} \
  --query primaryKey -o tsv)

# Create index via REST API
curl -X PUT "https://${SEARCH_SERVICE}.search.windows.net/indexes/${INDEX_NAME}?api-version=2024-07-01" \
  -H "Content-Type: application/json" \
  -H "api-key: ${SEARCH_KEY}" \
  -d '{
    "name": "documents",
    "fields": [
      {"name": "id", "type": "Edm.String", "key": true},
      {"name": "content", "type": "Edm.String", "searchable": true},
      {"name": "title", "type": "Edm.String", "searchable": true},
      {"name": "embedding", "type": "Collection(Edm.Single)", "searchable": true, "dimensions": 3072, "vectorSearchProfile": "default"}
    ],
    "vectorSearch": {
      "algorithms": [{"name": "hnsw", "kind": "hnsw"}],
      "profiles": [{"name": "default", "algorithm": "hnsw"}]
    }
  }'
```

---

## Terraform Module Reference

**Path:** `terraform/modules/ai-foundry/`

```hcl
module "ai_foundry" {
  source = "./modules/ai-foundry"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  
  # Azure OpenAI
  openai = {
    name     = local.openai_name
    sku_name = "S0"
    
    deployments = [
      {
        name          = "gpt-4o"
        model_name    = "gpt-4o"
        model_version = "2024-05-13"
        capacity      = 40
      },
      {
        name          = "text-embedding-3-large"
        model_name    = "text-embedding-3-large"
        model_version = "1"
        capacity      = 120
      }
    ]
  }
  
  # AI Search
  search = {
    enabled       = true
    name          = local.search_name
    sku           = "standard"
    replica_count = 1
    partition_count = 1
    semantic_search_sku = "standard"
  }
  
  # AI Hub (ML Workspace)
  ai_hub = {
    enabled = true
    name    = local.ai_hub_name
    
    storage_account_id   = azurerm_storage_account.ai.id
    key_vault_id         = azurerm_key_vault.main.id
    application_insights_id = azurerm_application_insights.main.id
  }
  
  # Private endpoints
  private_endpoint_subnet_id = module.networking.private_endpoints_subnet_id
  private_dns_zone_ids       = local.ai_private_dns_zone_ids
  
  tags = local.tags
}
```

---

## Golden Path Templates

### RAG Application Template

**Path:** `golden-paths/h3-innovation/rag-application/`

```yaml
# cookiecutter.json
{
  "project_name": "my-rag-app",
  "openai_deployment": "gpt-4o",
  "embedding_deployment": "text-embedding-3-large",
  "search_service": "srch-myproject-prod",
  "enable_content_safety": true
}
```

### AI Agent Template

**Path:** `golden-paths/h3-innovation/foundry-agent/`

```yaml
# cookiecutter.json
{
  "agent_name": "support-agent",
  "agent_type": "conversational",
  "tools": ["search", "calculator", "web"],
  "memory_type": "cosmos"
}
```

---

## Kubernetes Deployment for AI Applications

### External Secret for OpenAI

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: openai-credentials
  namespace: ai-apps
spec:
  refreshInterval: 1h
  secretStoreRef:
    kind: ClusterSecretStore
    name: azure-keyvault
  target:
    name: openai-credentials
  data:
    - secretKey: AZURE_OPENAI_ENDPOINT
      remoteRef:
        key: openai-endpoint
    - secretKey: AZURE_OPENAI_API_KEY
      remoteRef:
        key: openai-api-key
    - secretKey: AZURE_SEARCH_ENDPOINT
      remoteRef:
        key: search-endpoint
    - secretKey: AZURE_SEARCH_KEY
      remoteRef:
        key: search-admin-key
```

### AI Application Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rag-api
  namespace: ai-apps
spec:
  replicas: 3
  selector:
    matchLabels:
      app: rag-api
  template:
    metadata:
      labels:
        app: rag-api
    spec:
      serviceAccountName: ai-workload
      containers:
        - name: api
          image: ${ACR_NAME}.azurecr.io/rag-api:${VERSION}
          ports:
            - containerPort: 8000
          env:
            - name: AZURE_OPENAI_ENDPOINT
              valueFrom:
                secretKeyRef:
                  name: openai-credentials
                  key: AZURE_OPENAI_ENDPOINT
            - name: AZURE_OPENAI_API_KEY
              valueFrom:
                secretKeyRef:
                  name: openai-credentials
                  key: AZURE_OPENAI_API_KEY
            - name: OPENAI_DEPLOYMENT_NAME
              value: "gpt-4o"
            - name: EMBEDDING_DEPLOYMENT_NAME
              value: "text-embedding-3-large"
          resources:
            requests:
              cpu: 250m
              memory: 512Mi
            limits:
              cpu: 1000m
              memory: 2Gi
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 10
          readinessProbe:
            httpGet:
              path: /ready
              port: 8000
```

---

## Common Patterns

### RAG Pipeline

```python
# Example RAG implementation pattern
from azure.search.documents import SearchClient
from openai import AzureOpenAI

# 1. Initialize clients
openai_client = AzureOpenAI(
    azure_endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],
    api_key=os.environ["AZURE_OPENAI_API_KEY"],
    api_version="2024-06-01"
)

search_client = SearchClient(
    endpoint=os.environ["AZURE_SEARCH_ENDPOINT"],
    index_name="documents",
    credential=AzureKeyCredential(os.environ["AZURE_SEARCH_KEY"])
)

# 2. Generate embedding
def get_embedding(text: str) -> list[float]:
    response = openai_client.embeddings.create(
        model="text-embedding-3-large",
        input=text
    )
    return response.data[0].embedding

# 3. Search documents
def search_documents(query: str, top_k: int = 5):
    query_embedding = get_embedding(query)
    results = search_client.search(
        search_text=query,
        vector_queries=[{
            "kind": "vector",
            "vector": query_embedding,
            "k_nearest_neighbors": top_k,
            "fields": "embedding"
        }],
        top=top_k,
        select=["id", "title", "content"]
    )
    return list(results)

# 4. Generate response
def generate_response(query: str, context: list[dict]) -> str:
    context_text = "\n\n".join([doc["content"] for doc in context])
    
    response = openai_client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": f"Answer based on this context:\n{context_text}"},
            {"role": "user", "content": query}
        ]
    )
    return response.choices[0].message.content
```

---

## Error Handling

### Common Errors and Solutions

#### Rate Limit Exceeded

```bash
# Error: 429 Too Many Requests
# Solution: Implement retry with exponential backoff or increase capacity

az cognitiveservices account deployment show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT} \
  --deployment-name gpt-4o \
  --query "sku"

# Increase capacity
az cognitiveservices account deployment update \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT} \
  --deployment-name gpt-4o \
  --sku-capacity 80
```

#### Content Filter Triggered

```bash
# Error: content_filter triggered
# Solution: Review and adjust content safety settings

az cognitiveservices account show \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT} \
  --query "properties.contentFilter"
```

#### Model Not Available in Region

```bash
# Error: The model 'gpt-4o' is not available in region 'eastus'
# Solution: Check model availability and use supported region

az cognitiveservices model list \
  --location ${LOCATION} \
  --query "[?kind=='OpenAI'].{model:model.name, version:model.version}" \
  --output table
```

---

## Pre-Deployment Checklist

- [ ] Azure OpenAI access approved (may require application)
- [ ] Required model quotas available
- [ ] VNet with private endpoints configured
- [ ] Key Vault for storing API keys
- [ ] Content safety requirements defined
- [ ] Cost monitoring configured

## Post-Deployment Validation

```bash
# Test OpenAI endpoint
curl -X POST "${OPENAI_ENDPOINT}/openai/deployments/gpt-4o/chat/completions?api-version=2024-06-01" \
  -H "Content-Type: application/json" \
  -H "api-key: ${OPENAI_KEY}" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'

# Validate AI Search
curl "https://${SEARCH_SERVICE}.search.windows.net/indexes?api-version=2024-07-01" \
  -H "api-key: ${SEARCH_KEY}"

# Check model deployments
az cognitiveservices account deployment list \
  --resource-group ${RESOURCE_GROUP} \
  --name ${OPENAI_ACCOUNT} \
  --output table
```

---

## Related Skills

- [azure-infrastructure](../azure-infrastructure/) - Infrastructure provisioning
- [kubernetes-operations](../kubectl-cli/) - Kubernetes operations
- [database-management](../database-management/) - Database operations

---

## References

- [Azure AI Foundry](https://learn.microsoft.com/en-us/azure/ai-studio/)
- [Azure OpenAI Service](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- [Azure AI Search](https://learn.microsoft.com/en-us/azure/search/)
- [RAG Pattern](https://learn.microsoft.com/en-us/azure/search/retrieval-augmented-generation-overview)

````
