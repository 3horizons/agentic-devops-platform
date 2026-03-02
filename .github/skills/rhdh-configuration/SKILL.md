---
name: rhdh-configuration
description: "RHDH configuration, customization, monitoring, and observability reference — covers app-config.yaml, branding, theming, logging, telemetry, and audit logs. ALWAYS consult these docs before modifying RHDH configuration."
---

# RHDH Configuration & Customization Skill

This skill provides the official Red Hat documentation for configuring, customizing, and monitoring RHDH. **Always consult these references before modifying app-config.yaml, branding, theming, monitoring, or telemetry settings.**

## When to Use This Skill

- Modifying `app-config.yaml` or ConfigMaps for RHDH
- Customizing branding (logos, colors, fonts, sidebar, login page)
- Configuring theming (dark mode, MUI overrides, custom CSS)
- Setting up monitoring and logging for the RHDH portal
- Configuring telemetry data collection
- Reviewing or configuring audit logs
- Troubleshooting configuration issues (env vars, secrets, database)

## Mandatory Rule

> **ALWAYS** read the relevant official documentation below **BEFORE** recommending configuration changes, customizing the portal branding, or modifying monitoring/logging settings. Configuration errors can break the portal — validate against official docs first.

## Official Documentation References

| Document | Path | Covers |
|----------|------|--------|
| **Configuring RHDH** | [configuring_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/configuring_red_hat_developer_hub.md) | app-config.yaml structure, ConfigMaps, Secrets, environment variables, database config, proxy config, integrations |
| **Customizing RHDH** | [customizing_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/customizing_red_hat_developer_hub.md) | Branding (logo, title, favicon), theming (colors, MUI), home page, Quick Start, Learning Paths, i18n, custom sidebar |
| **Monitoring & Logging** | [monitoring_and_logging.md](../../../docs/official-docs/rhdh/markdown/monitoring_and_logging.md) | Log levels, structured logging, Prometheus metrics endpoint, health checks, resource monitoring |
| **Telemetry** | [telemetry_data_collection_and_analysis.md](../../../docs/official-docs/rhdh/markdown/telemetry_data_collection_and_analysis.md) | Telemetry opt-in/opt-out, data collected, privacy considerations, Segment integration |
| **Audit Logs** | [audit_logs_in_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/audit_logs_in_red_hat_developer_hub.md) | Audit log format, events tracked, log destinations, compliance requirements |

## Quick Reference: Configuration Architecture

### Configuration Sources (Priority Order)
1. **Environment variables** — `APP_CONFIG_*` or direct env vars
2. **Secrets** — Kubernetes Secrets mounted as files
3. **ConfigMaps** — `app-config.yaml` in ConfigMap
4. **Helm values** — `values.yaml` upstream config

### Key Configuration Sections
```yaml
app:
  title: "Three Horizons"          # Portal title
  baseUrl: https://devhub.example.com
  branding:                         # Logo, favicon, theme
    fullLogo: ...
    iconLogo: ...
    theme:
      light: ...
      dark: ...

backend:
  baseUrl: https://devhub.example.com
  database:                         # PostgreSQL connection
    client: pg
    connection: ...
  auth:                             # Authentication backend
    keys: ...

proxy:                              # Backend proxy for external APIs
  endpoints: ...

catalog:                            # Software Catalog
  locations: ...
  rules: ...
```

### Branding Configuration (Three Horizons)
```yaml
app:
  branding:
    fullLogo: <base64-svg-or-url>
    iconLogo: <base64-svg-or-url>
    theme:
      light:
        primaryColor: '#0078D4'     # Microsoft Blue
        headerColor1: '#0078D4'
        navigationIndicatorColor: '#0078D4'
      dark:
        primaryColor: '#4DB8FF'
        headerColor1: '#1B1B1F'
        navigationIndicatorColor: '#4DB8FF'
```

## Monitoring Checklist

- [ ] Prometheus ServiceMonitor configured for `:7007/metrics`
- [ ] Log level set appropriately (info for prod, debug for troubleshooting)
- [ ] Health check endpoint `/healthcheck` monitored
- [ ] Resource limits configured (CPU/memory requests and limits)
- [ ] Audit logs enabled for compliance tracking
