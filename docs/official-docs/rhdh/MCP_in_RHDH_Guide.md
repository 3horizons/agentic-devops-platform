# Model Context Protocol (MCP) in Red Hat Developer Hub 1.8

## Technical Guide — How to Use and What You Can Do

**Version:** 1.0
**Date:** March 2026
**Author:** paulasilva@microsoft.com
**Status:** Developer Preview (Technology Preview in RHDH 1.8)

---

## 1. What is MCP?

Model Context Protocol (MCP) is an open standard that connects AI models and applications (MCP clients) with external systems (MCP servers). The MCP server defines the tools that clients can interact with, providing a standardized method for AI applications to access information and workflows.

Red Hat Developer Hub 1.8 supports MCP through the **mcp-actions-backend** plugin (available in Backstage 1.40+), which exposes RHDH data — Software Catalog entities, TechDocs documentation — to any MCP-compatible AI client.

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│  MCP Hosts (AI Clients)                             │
│  Cursor │ Continue │ Lightspeed │ Claude │ VS Code  │
└────────────────────┬────────────────────────────────┘
                     │ Streamable HTTP / SSE
                     │ Bearer Token Auth
                     ▼
┌─────────────────────────────────────────────────────┐
│  RHDH MCP Server                                    │
│  Endpoint: /api/mcp-actions/v1                      │
│  Plugin: backstage-plugin-mcp-actions-backend       │
│                                                     │
│  ┌─────────────────┐  ┌──────────────────────────┐  │
│  │ Software Catalog │  │ TechDocs MCP Tools       │  │
│  │ MCP Tool         │  │ • fetch-techdocs         │  │
│  │                  │  │ • analyze-techdocs       │  │
│  │ fetch-catalog-   │  │   -coverage              │  │
│  │ entities         │  │ • retrieve-techdocs      │  │
│  │                  │  │   -content               │  │
│  └─────────────────┘  └──────────────────────────┘  │
└────────────────────┬────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────┐
│  Backstage Backend Services                         │
│  Software Catalog │ TechDocs │ Scaffolder │ Auth    │
└─────────────────────────────────────────────────────┘
```

---

## 3. What Can You Do?

### 3.1 Software Catalog MCP Tool

Query all Backstage entities — **Components, Systems, Resources, APIs, Locations, Users, Groups** — directly from your AI client.

**Available Parameters:**

| Parameter | Description | Example |
|-----------|-------------|---------|
| `kind` | Filter by Backstage kind | `"Component"` |
| `type` | Filter by Backstage type (requires `kind`) | `"model-server"` |
| `name` | Specific entity name | `"vllm-model-server"` |
| `owner` | Filter by owner | `"test-platform"` |
| `lifecycle` | Filter by lifecycle stage | `"development"` |
| `tags` | Filter by tags | `["genai", "ibm", "llm"]` |
| `verbose` | Return full entity object | `true` |

**Example Queries (Natural Language):**

- "Fetch all ai-model resources in the Backstage catalog"
- "Fetch the API definition for the beneficiary-management-api API"
- "Construct a curl command based on the API definition for the insert beneficiary endpoint"

**Response Format:** JSON array with fields: `name`, `description`, `type`, `owner`, `tags`, `dependsOn`, `kind`

### 3.2 TechDocs MCP Tools

Three specialized tools to search, analyze, and retrieve documentation:

#### 3.2.1 fetch-techdocs

Lists all Backstage entities with TechDocs. Returns entity details plus TechDocs metadata (last update timestamp, build information).

| Parameter | Description | Example |
|-----------|-------------|---------|
| `entityType` | Filter by entity type | `"Component"` |
| `namespace` | Filter by namespace | `"default"` |
| `owner` | Filter by owner | `"user:john.doe"` |
| `lifecycle` | Filter by lifecycle | `"development"` |
| `tags` | Filter by tags | `["genai", "conversational"]` |

**Response fields:** `name`, `title`, `tags`, `description`, `owner`, `lifecycle`, `namespace`, `kind`, `techDocsUrl`, `matadataUrl`, `metadata`

#### 3.2.2 analyze-techdocs-coverage

Calculates documentation coverage percentage — identifies gaps and measures overall documentation health.

**Response fields:** `totalEntities`, `entitiesWithDocs`, `coveragePercentage`

**Example:** "What is the coverage of techdocs in the default namespace?"

#### 3.2.3 retrieve-techdocs-content

Retrieves the actual content of a specific TechDoc resource for a Software Catalog entity.

| Parameter | Description | Example |
|-----------|-------------|---------|
| `entityRef` | Entity reference (kind:namespace/name) | `"component:default/my-service"` |
| `pagePath` | Path to specific doc page (default: index.html) | `"about.html"` |

**Response fields:** `entityRef`, `name`, `title`, `kind`, `namespace`, `content`, `path`, `contentType`, `lastModified`, `metadata`

---

## 4. Installation

### 4.1 Prerequisites

- RHDH instance installed and running
- AI model that supports tool calling (minimum 7B parameters, 32k context recommended)

### 4.2 Install Plugins

Add to your **dynamic-plugins-rhdh.yaml** ConfigMap:

```yaml
plugins:
  # 1. Backend MCP Server (required)
  - package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/backstage-plugin-mcp-actions-backend:bs_1.42.5__0.1.2!backstage-plugin-mcp-actions-backend
    disabled: false

  # 2. Software Catalog MCP Tool
  - package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/red-hat-developer-hub-backstage-plugin-software-catalog-mcp-tool:bs_1.42.5__0.2.3!red-hat-developer-hub-backstage-plugin-software-catalog-mcp-tool
    disabled: false

  # 3. TechDocs MCP Tool
  - package: oci://ghcr.io/redhat-developer/rhdh-plugin-export-overlays/red-hat-developer-hub-backstage-plugin-techdocs-mcp-tool:bs_1.42.5__0.3.0!red-hat-developer-hub-backstage-plugin-techdocs-mcp-tool
    disabled: false
```

### 4.3 Configure app-config.yaml

```yaml
app:
  title: AI Dev Developer Hub
  baseUrl: "${RHDH_BASE_URL}"

backend:
  actions:
    pluginSources:
      - 'software-catalog-mcp-tool'
      - 'techdocs-mcp-tool'
  auth:
    externalAccess:
      - type: static
        options:
          token: ${MCP_TOKEN}
          subject: mcp-clients
  baseUrl: "${RHDH_BASE_URL}"
  cors:
    origin: "${RHDH_BASE_URL}"
```

**Generate a token:**
```bash
node -p 'require("crypto").randomBytes(24).toString("base64")'
```

---

## 5. Configuring MCP Clients

### 5.1 Cursor

Navigate to **Cursor Settings > MCP Tools > New MCP Server**:

```json
{
  "mcpServers": {
    "backstage-actions": {
      "url": "https://<my_developer_hub_domain>/api/mcp-actions/v1",
      "headers": {
        "Authorization": "Bearer <MCP_TOKEN>"
      }
    }
  }
}
```

### 5.2 Continue

In your `agent.yaml`:

```yaml
mcpServers:
  - name: backstage-actions
    type: sse
    url: https://<my_developer_hub_domain>/api/mcp-actions/v1/sse
    requestOptions:
      headers:
        Authorization: "Bearer <MCP_TOKEN>"
```

### 5.3 Developer Lightspeed for RHDH

In `lightspeed-stack.yaml`:

```yaml
mcp_servers:
  - name: mcp::backstage
    provider_id: model-context-protocol
    url: https://<my_developer_hub_domain>/api/mcp-actions/v1
```

In `app-config.yaml`:

```yaml
lightspeed:
  mcpServers:
    - name: mcp::backstage
      token: ${MCP_TOKEN}
```

### 5.4 Transport Endpoints

| Endpoint | Type | Use When |
|----------|------|----------|
| `/api/mcp-actions/v1` | Streamable HTTP | Client supports Streamable (preferred) |
| `/api/mcp-actions/v1/sse` | SSE (Legacy) | Client only supports SSE |

---

## 6. Troubleshooting

### 6.1 Verify Plugin Installation

```bash
oc project {my-product-namespace}
oc logs -c install-dynamic-plugins deployment/<my-product-deployment>
```

Look for: `==> Successfully installed dynamic plugin ...backstage-plugin-mcp-actions-backend`

### 6.2 Check MCP Tool Logs

LoggerService targets: `software-catalog-mcp-tool` or `techdocs-mcp-tool`

### 6.3 Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| "Model does not support tool calls" | Model lacks tool calling | Switch to model with tool calling support (7B+ params) |
| Tools not found | Auth or config issue | Verify Bearer token, check endpoint URL, use SSE if Streamable fails |
| Nonsensical output | Small model or context | Use model with 32k+ context window, refine queries |
| Duplicate backend entries | Misconfigured app-config.yaml | Ensure pluginSources and static token are under same `backend` key |

---

## 7. Use Cases for Customers

1. **Developer Onboarding** — AI assistant queries the catalog to find relevant components, APIs, and documentation for new team members
2. **API Discovery** — Natural language queries to find and understand API definitions, including generating curl commands
3. **Documentation Health** — Automated coverage analysis identifying undocumented services
4. **Incident Response** — AI queries catalog metadata (owners, dependencies, lifecycle) during incidents
5. **Self-Service Templates** — AI suggests and helps customize software templates based on catalog context
6. **Compliance Auditing** — Validate that all production components have documentation, owners, and proper tagging

---

## 8. Sources

- Red Hat Developer Hub 1.8 — Interacting with Model Context Protocol tools for Red Hat Developer Hub (Official PDF, Feb 2026)
- https://developers.redhat.com/articles/2025/11/10/mcp-red-hat-developer-hub-chat-your-catalog
- https://vrabbi.cloud/post/backstage-as-the-ultimate-mcp-server/
- https://modelcontextprotocol.io/docs/learn/architecture
