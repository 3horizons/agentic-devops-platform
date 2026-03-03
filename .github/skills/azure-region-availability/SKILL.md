---
name: azure-region-availability
description: "Azure region availability and quota validation — verify service availability, AI model support, and compute quotas BEFORE recommending or provisioning any Azure resource."
---

# Azure Region Availability & Quota Validation

## Purpose

This skill provides mandatory rules for validating Azure service availability, AI model support, and compute quotas **before** recommending or provisioning any Azure resource. All agents that interact with Azure infrastructure MUST follow this skill.

## Mandatory Rule

> **BEFORE recommending any Azure service or region, ALWAYS:**
> 1. Consult `config/region-availability.yaml` (internal source-of-truth)
> 2. Validate with MCP tools or CLI (runtime verification)
> 3. If a service is unavailable in the target region, suggest alternatives from the config

## Sources of Truth

### Internal (project-specific)
- **File:** `config/region-availability.yaml`
- **Contains:** Tier 1/Tier 2 regions, service matrices, AI model availability, quota requirements, deployment patterns
- **Maintenance:** Review quarterly against official Microsoft page

### External (always up-to-date)
- **URL:** https://azure.microsoft.com/en-us/explore/global-infrastructure/products-by-region/table
- **Use when:** The internal YAML does not cover a region or service, or when verifying latest availability
- **AI Model regions:** https://learn.microsoft.com/azure/ai-foundry/openai/concepts/models#model-summary-table-and-region-availability
- **Claude models:** https://learn.microsoft.com/azure/foundry/foundry-models/how-to/use-foundry-models-claude

## MCP Tools for Runtime Validation

### Quota Validation
Use these MCP tools to check quotas in real-time before provisioning:

- **`azure-mcp/quota`** — Check Azure resource quotas
- **`com.microsoft/azure/quota`** — Alternative quota endpoint
- **`azure-ai-foundry/mcp-foundry/get_model_quotas`** — Check AI model TPM quotas

### CLI Fallback
When MCP tools are unavailable, use CLI commands:

```bash
# Check VM quota in a region
az vm list-usage --location <region> -o table

# Check specific VM family
az vm list-usage --location <region> \
  --query "[?contains(name.value,'standardDSv5')].{Name:name.localizedValue, Current:currentValue, Limit:limit}" \
  -o table

# Check if a resource provider is registered and available
az provider show -n Microsoft.CognitiveServices --query registrationState -o tsv

# Check available AKS versions in a region
az aks get-versions --location <region> -o table

# List available PostgreSQL Flexible Server SKUs
az postgres flexible-server list-skus --location <region> -o table
```

## Platform Required Services

The Three Horizons platform requires these Azure services. Verify ALL are available in the target region:

| Service | Resource Provider | Required for |
|---------|------------------|-------------|
| AKS | `Microsoft.ContainerService` | H1: Platform runtime |
| PostgreSQL Flexible | `Microsoft.DBforPostgreSQL` | H1: Portal database |
| Redis Cache | `Microsoft.Cache` | H1: Caching layer |
| Key Vault | `Microsoft.KeyVault` | H1: Secrets management |
| ACR | `Microsoft.ContainerRegistry` | H1: Container images |
| Log Analytics | `Microsoft.OperationalInsights` | H2: Observability |
| Grafana Managed | `Microsoft.Dashboard` | H2: Dashboards |
| Microsoft Foundry | `Microsoft.CognitiveServices` | H3: AI models |
| AI Search | `Microsoft.Search` | H3: RAG retrieval |
| Defender | `Microsoft.Security` | Security: Posture |
| Purview | `Microsoft.Purview` | Governance: Data catalog |

## AI Model Availability by Region

### OpenAI Models (via Microsoft Foundry — Terraform deployed)

| Model | eastus2 | eastus | centralus | southcentralus | brazilsouth |
|-------|---------|--------|-----------|----------------|-------------|
| o3 | ✅ Global+Standard | ✅ Global | ✅ Global | ✅ Global+Standard | ❌ |
| o4-mini | ✅ Global+Standard | ✅ Global | ✅ Global | ✅ Global+Standard | ❌ |
| gpt-4.1 | ✅ Global+Standard | ✅ Global | ✅ Global | ✅ Global+Standard | ❌ |
| gpt-4o | ✅ All | ✅ Global | ✅ Global | ✅ All | ⚠️ Limited |
| gpt-4o-mini | ✅ All | ✅ Global | ✅ Global | ✅ All | ⚠️ Limited |
| text-embedding-3-large | ✅ Standard | ❌ | ❌ | ❌ | ❌ |

### Anthropic Claude Models (via Microsoft Foundry Marketplace — manual deploy)

| Model | eastus2 | swedencentral | All other regions |
|-------|---------|---------------|-------------------|
| claude-opus-4-6 | ✅ | ✅ | ❌ |
| claude-sonnet-4-6 | ✅ | ✅ | ❌ |
| claude-haiku-4-5 | ✅ | ✅ | ❌ |

> **Note:** Claude models require a paid Azure subscription with Azure Marketplace access. Deploy via Foundry Portal, NOT via Terraform.

## Quota Requirements by Deployment Mode

| Resource | Express (3 nodes) | Standard (5 nodes) | Enterprise (10 nodes) |
|----------|-------------------|---------------------|-----------------------|
| Regional vCPUs | 12 | 20 | 40 |
| DSv5 Family vCPUs | 12 | 20 | 40 |
| PostgreSQL | Burstable B2ms | GP D2s_v3 | GP D4s_v3 |
| Redis | Basic C1 | Standard C1 | Premium P1 |
| AI Model TPM | 30K | 60K | 120K |

## Validation Flow

```
User provides target region
         │
         ▼
┌──────────────────────────┐
│ 1. Check config YAML     │ → Is region listed as Tier 1 or Tier 2?
│    region-availability   │    If NO → suggest Tier 1 alternatives
└──────────┬───────────────┘
           │ YES
           ▼
┌──────────────────────────┐
│ 2. Check service matrix  │ → Are ALL required services available?
│    in config YAML        │    If NO → show which are missing,
└──────────┬───────────────┘    suggest region with full support
           │ ALL AVAILABLE
           ▼
┌──────────────────────────┐
│ 3. Validate quotas       │ → Use MCP tools or CLI to check:
│    via MCP/CLI           │    - vCPU quota (DSv5 family)
└──────────┬───────────────┘    - Regional vCPU total
           │ SUFFICIENT        - AI model TPM (if H3 enabled)
           ▼
┌──────────────────────────┐
│ 4. Check AI models       │ → If enable_ai_foundry=true:
│    (if H3 enabled)       │    Are required models available?
└──────────┬───────────────┘    If using Claude: only eastus2/swedencentral
           │ OK
           ▼
    ✅ Region validated — proceed with deployment
```

## Output Template

When reporting region validation results, use this format:

```
## Region Validation: <region_name>

| Service | Status | Notes |
|---------|--------|-------|
| AKS | ✅ Available | v1.33 |
| PostgreSQL | ✅ Available | Flexible Server v16 |
| Redis | ✅ Available | All tiers |
| Key Vault | ✅ Available | HSM available |
| ACR | ✅ Available | Geo-replication |
| Microsoft Foundry (OpenAI) | ⚠️ Limited | Global Standard only — no Standard regional |
| Microsoft Foundry (Claude) | ❌ Not available | Claude requires eastus2 or swedencentral |
| Defender | ✅ Available | All plans |

### Quota Status
| Resource | Required | Current | Limit | Status |
|----------|----------|---------|-------|--------|
| Regional vCPUs | 20 | 0 | 40 | ✅ OK |
| DSv5 Family | 20 | 0 | 20 | ✅ OK |

### Recommendation
<region_name> is suitable for H1+H2 deployment. For H3 (AI), use eastus2 as the AI region.
```

## Performance Guidance

- Run region validation as an **explicit Step 0** at the beginning of each deployment/architecture workflow
- Do NOT re-validate for each individual service recommendation within the same session
- Cache the validation result for the duration of the conversation
- If the user changes target region mid-conversation, re-run validation

## Maintenance

- **Quarterly review:** Compare `config/region-availability.yaml` against the official Microsoft Products by Region page
- **On failure:** If a service deployment fails with a region availability error, update the YAML immediately
- **New services:** When adding new Azure services to the platform, add them to the service matrix in the YAML
