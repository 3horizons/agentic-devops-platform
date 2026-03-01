# Lightspeed Chat

**Developer Lightspeed** is the AI-powered chat assistant built into Red Hat Developer Hub. It provides contextual help, code generation, and platform guidance directly within the developer portal, powered by Azure OpenAI and Llama Stack with RAG (Retrieval-Augmented Generation).

---

## Overview

Lightspeed is an **H3 Innovation** feature that brings conversational AI into the RHDH portal. Unlike GitHub Copilot (which operates in the IDE), Lightspeed is designed for platform-level questions and portal interactions.

### Key Capabilities

- Answer questions about platform services, configurations, and architecture
- Explain error messages and suggest remediation steps
- Guide developers through Golden Path template selection
- Provide code snippets and configuration examples
- Summarize TechDocs content and API specifications
- Assist with troubleshooting deployment and runtime issues
- Explain RBAC policies and access requirements
- Generate Kubernetes manifest snippets

### Lightspeed vs. Copilot

| Feature | Developer Lightspeed | GitHub Copilot |
| ------- | -------------------- | -------------- |
| Interface | RHDH portal (browser) | IDE (VS Code, JetBrains) |
| Focus | Platform guidance, portal tasks | Code generation, file editing |
| Context | Software Catalog, TechDocs, APIs | Repository code, open files |
| Models | Azure OpenAI (GPT-4o) via Llama Stack | GitHub Copilot models |
| RAG | Yes (platform documentation) | No (code context only) |
| Agents | No (single chat interface) | Yes (19 specialized agents) |
| RBAC | RHDH role-based access | GitHub seat assignment |

Both tools complement each other: use Copilot for coding in the IDE and Lightspeed for platform questions in the portal.

---

## Architecture

```text
Developer (RHDH Portal)
        |
        v
Lightspeed Chat UI (RHDH Dynamic Plugin)
        |
        v
Lightspeed Backend (RHDH Plugin)
        |
        v
Llama Stack (Orchestration Layer)
        |
        +--> Azure OpenAI (GPT-4o / GPT-4o-mini)
        |         |
        |         +--> Chat completion API
        |         +--> Function calling
        |
        +--> RAG Pipeline
        |         |
        |         +--> Query Embedding (text-embedding-3-large)
        |         +--> Azure AI Search (Vector Index)
        |         +--> Context Assembly
        |
        +--> Content Safety Filter
                  |
                  +--> Azure AI Content Safety
```

### Component Roles

| Component | Role |
| --------- | ---- |
| **Lightspeed Chat UI** | RHDH dynamic plugin providing the chat interface |
| **Lightspeed Backend** | Server-side plugin handling message routing and context |
| **Llama Stack** | Orchestration layer managing model selection, RAG, and safety |
| **Azure OpenAI** | LLM provider for chat completion and embeddings |
| **Azure AI Search** | Vector index for semantic search over documentation |
| **Content Safety** | Filters for harmful content detection and blocking |

---

## Azure OpenAI Models

Lightspeed uses Azure AI Foundry models deployed in the `eastus2` region (selected for model availability):

| Model | Deployment Name | Purpose | Token Limit |
| ----- | --------------- | ------- | ----------- |
| **GPT-4o** | `gpt-4o` | Complex architecture questions, code generation, multi-step reasoning | 128K context |
| **GPT-4o-mini** | `gpt-4o-mini` | Simple Q&A, summaries, quick lookups, high-volume queries | 128K context |
| **text-embedding-3-large** | `text-embedding-3-large` | Document embedding for RAG vector search | 8K input |

Model selection is automatic based on query complexity:

- Simple factual questions route to GPT-4o-mini (faster, cheaper)
- Complex reasoning, code generation, and multi-step queries route to GPT-4o
- All document indexing uses text-embedding-3-large

---

## Enabling Lightspeed

### Prerequisites

- Azure AI Foundry deployed (`enable_ai_foundry = true` in Terraform)
- GPT-4o and embedding model deployments active
- Azure AI Search index populated with platform documentation
- API credentials stored in Azure Key Vault

### RHDH Configuration

Lightspeed is enabled as a dynamic plugin in `app-config-rhdh.yaml`:

```yaml
dynamicPlugins:
  frontend:
    redhat.plugin-developer-lightspeed:
      dynamicRoutes:
        - path: /lightspeed
          importName: LightspeedPage
      appIcons:
        - name: lightspeedIcon
          importName: LightspeedIcon
```

The backend connection is configured in the `lightspeed` section:

```yaml
lightspeed:
  servers:
    - id: azure-ai-foundry
      url: ${AZURE_AI_FOUNDRY_ENDPOINT}
      token: ${AZURE_AI_FOUNDRY_API_KEY}
```

### Secret Configuration

Lightspeed credentials are managed through External Secrets Operator:

| Secret Name | Key Vault Entry | Purpose |
| ----------- | --------------- | ------- |
| `AZURE_AI_FOUNDRY_ENDPOINT` | `prod-ai-foundry-endpoint` | Azure OpenAI API URL |
| `AZURE_AI_FOUNDRY_API_KEY` | `prod-ai-foundry-api-key` | Azure OpenAI API key |
| `LIGHTSPEED_API_URL` | `prod-lightspeed-api-url` | Lightspeed backend URL |
| `LIGHTSPEED_API_TOKEN` | `prod-lightspeed-api-token` | Lightspeed auth token |

---

## Using Lightspeed

### Accessing the Chat Interface

1. Log in to the RHDH portal at `https://devhub.3horizons.ai`
2. Click the **Lightspeed** icon in the RHDH sidebar or navigate to `/lightspeed`
3. The chat panel opens, ready for conversation
4. Type your question and press Enter

### Example Prompts

#### Platform Guidance

```text
What Golden Path template should I use for a REST API with PostgreSQL?
How do I add monitoring to my service?
What are the RBAC roles available in the portal?
Explain the Three Horizons deployment modes.
How do I register a new service in the Software Catalog?
```

#### Troubleshooting

```text
My ArgoCD application is stuck in "OutOfSync" state. What should I check?
Pod is in CrashLoopBackOff with OOMKilled. How do I fix this?
ExternalSecret is not syncing from Key Vault. Help me debug.
Why is my service returning 503 errors after deployment?
How do I check if my TLS certificate is about to expire?
```

#### Code and Configuration

```text
Show me a ServiceMonitor configuration for a Python FastAPI service.
Generate a Helm values file for a Node.js microservice with Redis.
What labels are required by the Gatekeeper policies?
Write a NetworkPolicy that allows ingress only from the ingress-nginx namespace.
Create an ExternalSecret that syncs database credentials from Key Vault.
```

#### Architecture and Design

```text
What is the recommended way to implement event-driven communication between services?
How should I structure my Terraform module for a new Azure service?
Explain the ArgoCD sync wave ordering for the platform.
What security controls must my container meet to pass Gatekeeper?
```

---

## RAG Knowledge Base

The RAG pipeline indexes platform documentation for contextual retrieval, ensuring Lightspeed answers are grounded in actual platform configuration and policies.

### Indexed Sources

| Source | Content | Refresh Frequency |
| ------ | ------- | ----------------- |
| TechDocs | All documentation from RHDH catalog entities | On merge to main |
| Runbooks | Operational procedures from `docs/techdocs/docs/operations/` | On merge to main |
| Golden Paths | Template descriptions and parameters | On merge to main |
| Security Policies | OPA/Rego policies and Gatekeeper constraints | On merge to main |
| API Specifications | OpenAPI/Swagger specs from the catalog | On merge to main |
| Alert Rules | Prometheus alerting rule descriptions | On merge to main |
| Platform Config | Sizing profiles, region availability, APM config | On merge to main |

### How RAG Works

1. **Indexing**: When documentation changes are merged to `main`, a pipeline extracts text, generates embeddings using `text-embedding-3-large`, and stores them in Azure AI Search
2. **Query**: When a user asks a question, the query is embedded and searched against the vector index
3. **Retrieval**: The top-k most relevant document chunks are retrieved
4. **Augmentation**: Retrieved chunks are injected into the LLM prompt as context
5. **Generation**: GPT-4o generates a response grounded in the retrieved documentation

### Vector Index Configuration

Azure AI Search is configured with:

- **Index type**: HNSW (Hierarchical Navigable Small World) for fast vector search
- **Dimensions**: 3072 (matching text-embedding-3-large output)
- **Similarity metric**: Cosine similarity
- **Hybrid search**: Combines keyword (BM25) and vector search for best results

---

## Content Safety

Azure AI Content Safety filters are enabled on all Lightspeed interactions to ensure safe and appropriate responses.

### Safety Filters

| Category | Action | Threshold |
| -------- | ------ | --------- |
| Hate speech | Block | Medium |
| Self-harm | Block | Medium |
| Violence | Block | Medium |
| Sexual content | Block | Medium |

### Platform-Specific Safety Rules

In addition to Azure AI Content Safety, Lightspeed enforces platform-specific rules:

- **Never expose secrets** -- Will not output Key Vault values, passwords, tokens, or API keys
- **Never bypass policies** -- Will not suggest workarounds to Gatekeeper or OPA policies
- **Never suggest forbidden operations** -- Follows the same MCP forbidden operations list
- **Always reference documentation** -- Prefers documented procedures over ad-hoc suggestions
- **Respect RBAC** -- Responses are scoped to the user's RHDH role (Admin/Developer/Viewer)

---

## BYOM (Bring Your Own Model) Support

Lightspeed supports connecting custom models through the Llama Stack orchestration layer, enabling teams to use alternative LLM providers or fine-tuned models.

### Supported Configurations

| Provider | Transport | Authentication |
| -------- | --------- | -------------- |
| Azure OpenAI (default) | HTTPS REST API | API key or Managed Identity |
| OpenAI | HTTPS REST API | API key |
| Custom Llama models | Local or remote Llama Stack | Token-based |
| Ollama | Local HTTP | None (localhost) |

### Configuring a Custom Model

Add a new server entry to the `lightspeed.servers` configuration:

```yaml
lightspeed:
  servers:
    - id: azure-ai-foundry
      url: ${AZURE_AI_FOUNDRY_ENDPOINT}
      token: ${AZURE_AI_FOUNDRY_API_KEY}
    - id: custom-model
      url: https://my-custom-model.example.com/v1
      token: ${CUSTOM_MODEL_TOKEN}
```

The Llama Stack layer handles routing between models based on query type, available capacity, and cost optimization rules.

---

## Monitoring Lightspeed

### Health Monitoring

Lightspeed health is monitored through Prometheus alerts:

| Alert | Condition | Severity |
| ----- | --------- | -------- |
| `LightspeedUnavailable` | Chat endpoint not responding for 5 min | Critical |
| `LLMHighLatency` | Response time > 10 seconds for 5 min | Warning |
| `LLMErrorRate` | Error rate > 10% for 5 min | Warning |
| `HighTokenUsage` | Token consumption > 80% of budget | Warning |
| `TokenBudgetExceeded` | Token consumption > 100% of budget | Critical |

### Usage Metrics

Lightspeed usage metrics are tracked via the RHDH metrics endpoint (`:7007/metrics`):

- Total chat messages sent
- Average response latency
- Token consumption per model
- Error rate by category
- Active user count

### Cost Management

AI model usage is tracked to control costs:

- GPT-4o: Higher cost per token, used for complex queries
- GPT-4o-mini: Lower cost, used for simple queries
- Embeddings: One-time cost at indexing, negligible at query time
- Budget alerts fire at 50%, 75%, 90%, and 100% thresholds

---

## Troubleshooting

### Common Issues

| Issue | Cause | Resolution |
| ----- | ----- | ---------- |
| Chat returns "Service unavailable" | Lightspeed backend pod is down | Check pod health: `kubectl get pods -n rhdh` |
| Slow responses (> 10s) | Model overloaded or network latency | Check Azure OpenAI service health |
| "I don't have information about that" | Topic not covered in RAG index | Add documentation and re-index |
| Empty responses | Content Safety filter triggered | Rephrase the question; check filter logs |
| Plugin not visible in RHDH | Dynamic plugin not enabled | Verify `dynamicPlugins` config in app-config |

### Diagnostic Commands

```bash
# Check RHDH pod health
kubectl get pods -n rhdh
kubectl logs deployment/rhdh-developer-hub -n rhdh --tail=100

# Check Lightspeed plugin is loaded
kubectl exec deployment/rhdh-developer-hub -n rhdh -- \
  curl -sf http://localhost:7007/api/lightspeed/health

# Verify Azure OpenAI endpoint is reachable from the cluster
kubectl run ai-check --rm -it --restart=Never \
  --image=curlimages/curl -- \
  curl -sf "${AZURE_AI_FOUNDRY_ENDPOINT}/openai/deployments?api-version=2024-02-01" \
  -H "api-key: ${AZURE_AI_FOUNDRY_API_KEY}"

# Check AI Search index status
az search service show \
  --resource-group ${RG} \
  --name ${SEARCH_SERVICE} \
  --query "status"

# Verify External Secrets for AI credentials
kubectl get externalsecrets -n rhdh | grep ai-foundry
```
