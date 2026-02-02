---
name: mcp-cli
description: 'Model Context Protocol (MCP) server configuration and usage. Use when integrating AI agents with external tools, APIs, and services via MCP servers.'
---

# MCP (Model Context Protocol) Skill

USE FOR:
- MCP server configuration (mcp.json, mcp-config.json)
- Installing and managing MCP servers
- VS Code MCP integration
- GitHub Copilot CLI MCP usage
- Custom MCP server development
- Troubleshooting MCP connections
- Understanding available MCP tools

DO NOT USE FOR:
- Direct CLI execution (use respective CLI skills like azure-cli, kubectl-cli)
- Azure API calls without MCP (use azure-cli)
- GitHub API calls without MCP (use github-cli)
- Application development unrelated to MCP

## Overview

Model Context Protocol (MCP) enables AI agents to interact with external tools and services. MCP servers expose capabilities that AI agents can invoke during conversations.

### Architecture

```
┌──────────────────────────────────────────────────┐
│                   AI Agent                        │
│  (GitHub Copilot, Claude, etc.)                  │
└────────────────────┬─────────────────────────────┘
                     │ MCP Protocol
                     ▼
┌──────────────────────────────────────────────────┐
│              MCP Server                           │
│  (azure, github, terraform, etc.)                │
└────────────────────┬─────────────────────────────┘
                     │ API/CLI calls
                     ▼
┌──────────────────────────────────────────────────┐
│           External Services                       │
│  (Azure, GitHub, HashiCorp, etc.)                │
└──────────────────────────────────────────────────┘
```

## Prerequisites

```bash
# Node.js 18+ required for MCP servers
node --version  # v18.0.0+

# npx for running MCP servers
npx --version

# Docker (optional, for containerized MCP servers)
docker --version
```

## VS Code Configuration

### Location

MCP configuration in VS Code is stored in:
- **Workspace**: `.vscode/mcp.json`
- **User**: `~/Library/Application Support/Code/User/mcp.json` (macOS)

### Basic Configuration

```json
{
  "servers": {
    "server-name": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@package/mcp-server"],
      "env": {
        "API_KEY": "${env:API_KEY}"
      }
    }
  }
}
```

### Configuration Options

| Field | Description |
|-------|-------------|
| `type` | Connection type: `stdio` (local), `sse` (remote) |
| `command` | Command to start the server |
| `args` | Arguments for the command |
| `env` | Environment variables |
| `cwd` | Working directory |

## Available MCP Servers

### Azure MCP Server

```json
{
  "servers": {
    "azure": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@azure/mcp"],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "${env:AZURE_SUBSCRIPTION_ID}",
        "AZURE_TENANT_ID": "${env:AZURE_TENANT_ID}"
      }
    }
  }
}
```

**Tools provided:**
- `list_subscriptions` - List Azure subscriptions
- `list_resource_groups` - List resource groups
- `get_resource` - Get resource details
- `create_resource` - Create Azure resources
- `delete_resource` - Delete Azure resources

### GitHub MCP Server

```json
{
  "servers": {
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@github/mcp"],
      "env": {
        "GITHUB_TOKEN": "${env:GITHUB_TOKEN}"
      }
    }
  }
}
```

**Tools provided:**
- `list_repos` - List repositories
- `create_issue` - Create GitHub issue
- `create_pull_request` - Create PR
- `get_file_contents` - Read file from repo
- `search_code` - Search code in repos

### Terraform MCP Server

```json
{
  "servers": {
    "terraform": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@hashicorp/mcp-terraform"],
      "env": {
        "TF_CLOUD_TOKEN": "${env:TF_CLOUD_TOKEN}"
      }
    }
  }
}
```

**Tools provided:**
- `plan` - Run terraform plan
- `apply` - Run terraform apply
- `show_state` - Show current state
- `list_workspaces` - List TF Cloud workspaces

### Kubernetes MCP Server

```json
{
  "servers": {
    "kubernetes": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@kubernetes/mcp"],
      "env": {
        "KUBECONFIG": "${env:KUBECONFIG}"
      }
    }
  }
}
```

**Tools provided:**
- `list_pods` - List pods in namespace
- `get_logs` - Get pod logs
- `apply_manifest` - Apply K8s manifest
- `delete_resource` - Delete K8s resource

### OpenShift MCP Server

```json
{
  "servers": {
    "openshift": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@redhat/mcp-openshift"],
      "env": {
        "KUBECONFIG": "${env:KUBECONFIG}"
      }
    }
  }
}
```

**Tools provided:**
- OpenShift-specific operations
- Route management
- Project operations
- SCC management

### Helm MCP Server

```json
{
  "servers": {
    "helm": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@helm/mcp"],
      "env": {
        "KUBECONFIG": "${env:KUBECONFIG}"
      }
    }
  }
}
```

**Tools provided:**
- `list_releases` - List Helm releases
- `install` - Install chart
- `upgrade` - Upgrade release
- `rollback` - Rollback release

### Docker MCP Server

```json
{
  "servers": {
    "docker": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@docker/mcp"]
    }
  }
}
```

**Tools provided:**
- Container operations
- Image management
- Network operations

## Three Horizons MCP Configuration

### Full Configuration

Reference: `mcp-servers/mcp-config.json`

```json
{
  "servers": {
    "azure": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@azure/mcp"],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "${env:AZURE_SUBSCRIPTION_ID}",
        "AZURE_TENANT_ID": "${env:AZURE_TENANT_ID}"
      }
    },
    "terraform": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@hashicorp/mcp-terraform"]
    },
    "kubernetes": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@kubernetes/mcp"],
      "env": {
        "KUBECONFIG": "${env:KUBECONFIG}"
      }
    },
    "openshift": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@redhat/mcp-openshift"],
      "env": {
        "KUBECONFIG": "${env:KUBECONFIG}"
      }
    },
    "helm": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@helm/mcp"]
    },
    "docker": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@docker/mcp"]
    },
    "aro": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@azure/mcp-aro"],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "${env:AZURE_SUBSCRIPTION_ID}"
      }
    },
    "github": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@github/mcp"],
      "env": {
        "GITHUB_TOKEN": "${env:GITHUB_TOKEN}"
      }
    },
    "git": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@git/mcp"]
    },
    "bash": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@bash/mcp"]
    },
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@filesystem/mcp"]
    },
    "defender": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@azure/mcp-defender"],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "${env:AZURE_SUBSCRIPTION_ID}"
      }
    },
    "purview": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@azure/mcp-purview"],
      "env": {
        "AZURE_SUBSCRIPTION_ID": "${env:AZURE_SUBSCRIPTION_ID}"
      }
    },
    "entra": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@azure/mcp-entra"],
      "env": {
        "AZURE_TENANT_ID": "${env:AZURE_TENANT_ID}"
      }
    },
    "copilot": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@github/mcp-copilot"]
    }
  }
}
```

## Hybrid Approach

The Three Horizons Accelerator uses a hybrid approach:

### Use MCP For:
- API/DevOps operations (PRs, work items, pipelines)
- Service integrations
- Read-only queries
- Automated workflows

### Use Terminal For:
- Infrastructure CLIs (`az`, `terraform`, `kubectl`, `helm`)
- Commands requiring interactive input
- Long-running operations
- Local file operations

## Installing MCP Servers

### Via npx (Recommended)

```bash
# Servers are installed on-demand via npx
# No pre-installation needed

# Test a server manually
npx -y @azure/mcp --help
```

### Via Docker

```bash
# Run MCP server in container
docker run -it --rm \
  -e AZURE_SUBSCRIPTION_ID=${AZURE_SUBSCRIPTION_ID} \
  mcr.microsoft.com/azure-mcp:latest
```

### Via npm (Global Install)

```bash
# Global installation (not recommended)
npm install -g @azure/mcp

# Run globally installed server
azure-mcp
```

## Custom MCP Server Development

### Basic Structure

```typescript
// server.ts
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "my-mcp-server",
  version: "1.0.0",
});

// Define tools
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "my_tool",
      description: "Description of what the tool does",
      inputSchema: {
        type: "object",
        properties: {
          param1: { type: "string", description: "Parameter 1" },
        },
        required: ["param1"],
      },
    },
  ],
}));

// Handle tool calls
server.setRequestHandler("tools/call", async (request) => {
  if (request.params.name === "my_tool") {
    // Tool implementation
    return { result: "Tool output" };
  }
});

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

### Package.json

```json
{
  "name": "@my-org/mcp-server",
  "version": "1.0.0",
  "type": "module",
  "bin": {
    "my-mcp-server": "./dist/server.js"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.5.0"
  }
}
```

## Troubleshooting

### Common Issues

```bash
# Check if MCP server starts
npx -y @azure/mcp --version

# Enable MCP debug logging
export MCP_DEBUG=1

# Check Node.js version
node --version  # Must be 18+

# Clear npx cache
npx clear-npx-cache

# Check environment variables
env | grep AZURE
env | grep GITHUB
```

### VS Code Diagnostics

```json
// In settings.json
{
  "mcp.trace.server": "verbose"
}
```

### Connection Issues

1. **Server not starting**: Check command and args in mcp.json
2. **Authentication failed**: Verify environment variables
3. **Tools not appearing**: Check server implements tools/list
4. **Timeout errors**: Increase timeout in VS Code settings

## Best Practices

1. **Use Environment Variables**: Never hardcode secrets in mcp.json
2. **Version Pin Servers**: Use specific versions for production
3. **Minimal Servers**: Only enable servers you need
4. **Monitor Performance**: MCP servers can impact response time
5. **Test Locally**: Verify MCP configuration before deployment
6. **Use Hybrid Approach**: MCP for integrations, Terminal for CLIs
7. **Document Tools**: Keep track of which tools are used where

## References

- [MCP Specification](https://spec.modelcontextprotocol.io)
- [GitHub Copilot MCP](https://docs.github.com/copilot/mcp)
- [Azure MCP Server](https://github.com/Azure/mcp-azure)
- [Awesome MCP Servers](https://github.com/punkpeye/awesome-mcp-servers)
