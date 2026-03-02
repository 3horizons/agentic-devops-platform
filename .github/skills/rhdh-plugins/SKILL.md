---
name: rhdh-plugins
description: "RHDH dynamic plugins reference — covers plugin architecture, configuration, wiring, MCP tools, AI connectors, and orchestrator. ALWAYS consult these docs before enabling, configuring, or troubleshooting dynamic plugins."
---

# RHDH Dynamic Plugins Skill

This skill provides the official Red Hat documentation for RHDH dynamic plugins — the runtime extension mechanism that allows enabling, disabling, and configuring plugins via YAML without rebuilding the portal. **Always consult these references before enabling, configuring, wiring, or troubleshooting any dynamic plugin.**

## When to Use This Skill

- Enabling or disabling a dynamic plugin in `dynamic-plugins-config.yaml`
- Configuring plugin wiring (dynamicRoutes, mountPoints, menuItems, entityTabs)
- Looking up the plugin reference for a specific RHDH plugin
- Installing new plugins (OCI artifacts, npm packages)
- Integrating MCP (Model Context Protocol) tools with RHDH
- Configuring OpenShift AI Connector for AI-powered features
- Setting up Orchestrator (Serverless Workflows) in RHDH
- Troubleshooting plugin loading failures or wiring issues
- Building CI/CD pipelines for custom dynamic plugins

## Mandatory Rule

> **ALWAYS** read the relevant plugin documentation below **BEFORE** enabling, configuring, or troubleshooting any RHDH dynamic plugin. Plugin configuration syntax, supported versions, and wiring mechanisms change between RHDH releases. The Dynamic Plugins Reference is the authoritative source for plugin package names, wiring keys, and configuration options.

## Official Documentation References

### Plugin Architecture & Configuration

| Document | Path | Covers |
|----------|------|--------|
| **Introduction to Plugins** | [introduction_to_plugins.md](../../../docs/official-docs/rhdh/markdown/introduction_to_plugins.md) | Plugin types (frontend, backend, full-stack), plugin lifecycle, preloaded vs external |
| **Configuring Dynamic Plugins** | [configuring_dynamic_plugins.md](../../../docs/official-docs/rhdh/markdown/configuring_dynamic_plugins.md) | `dynamic-plugins-config.yaml` syntax, plugin enablement, wiring mechanisms, OCI artifacts, integrity verification |
| **Dynamic Plugins Reference** | [dynamic_plugins_reference.md](../../../docs/official-docs/rhdh/markdown/dynamic_plugins_reference.md) | Complete reference: every supported plugin with package name, wiring config, and configuration options |
| **Using Dynamic Plugins** | [using_dynamic_plugins_in_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/using_dynamic_plugins_in_red_hat_developer_hub.md) | How to use installed plugins, plugin-specific configuration, common patterns |
| **Installing & Viewing Plugins** | [installing_and_viewing_plugins_in_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/installing_and_viewing_plugins_in_red_hat_developer_hub.md) | Plugin marketplace, installation methods, version management, viewing installed plugins |

### AI & MCP Integration

| Document | Path | Covers |
|----------|------|--------|
| **MCP Tools** | [interacting_with_model_context_protocol_tools_for_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/interacting_with_model_context_protocol_tools_for_red_hat_developer_hub.md) | MCP server configuration, tool registration, Lightspeed MCP integration, catalog MCP actions |
| **AI Connector** | [accelerate_ai_development_with_openshift_ai_connector_for_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/accelerate_ai_development_with_openshift_ai_connector_for_red_hat_developer_hub.md) | OpenShift AI Connector, model serving, AI workbench integration |

### Orchestrator

| Document | Path | Covers |
|----------|------|--------|
| **Orchestrator** | [orchestrator_in_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/orchestrator_in_red_hat_developer_hub.md) | Serverless Workflow definitions, workflow execution, SonataFlow integration |

## Quick Reference: Plugin Configuration

### Enabling a Plugin
```yaml
# dynamic-plugins-config.yaml
plugins:
  - package: ./dynamic-plugins/dist/backstage-plugin-kubernetes
    disabled: false
    pluginConfig:
      dynamicPlugins:
        frontend:
          backstage-plugin-kubernetes:
            dynamicRoutes:
              - path: /kubernetes
                importName: KubernetesPage
                menuItem:
                  icon: kubernetes
                  text: Kubernetes
```

### Frontend Wiring Mechanisms

| Mechanism | Use Case | Config Key |
|-----------|----------|------------|
| `dynamicRoutes` | Full custom pages with navigation | Top-level route + optional menuItem |
| `mountPoints` | Widgets embedded in existing pages | Component injected at mount point |
| `menuItems` | Sidebar navigation entries | Sidebar link with icon |
| `entityTabs` | Custom tabs on entity detail pages | Tab on catalog entity page |
| `appIcons` | Custom SVG icons | Icon registration |
| `apiFactories` | Custom backend API providers | API factory registration |
| `routeBindings` | Cross-plugin route connections | Route binding declaration |

### Plugin Integrity Verification
```yaml
plugins:
  - package: ./dynamic-plugins/dist/my-plugin
    disabled: false
    integrity: sha512-abc123...  # Required for external plugins
```

## Troubleshooting Checklist

- [ ] Plugin package path is correct in `dynamic-plugins-config.yaml`
- [ ] Plugin is not set to `disabled: true`
- [ ] Plugin wiring keys match the plugin's exported names (check `importName`)
- [ ] Required plugin configuration is provided in `pluginConfig`
- [ ] OCI artifact is accessible from AKS (check ACR credentials)
- [ ] Plugin version is compatible with current RHDH version
- [ ] Check RHDH logs for plugin loading errors: `kubectl logs -n rhdh deployment/rhdh`
