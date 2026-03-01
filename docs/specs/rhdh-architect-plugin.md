---
name: rhdh-architect-plugin
description: "Complete RHDH/Backstage plugin architecture toolkit — bundles the rhdh-architect agent with its design skills, validation scripts, configuration assets, deployment workflows, and pre-deploy hooks. Install this plugin to get the full RHDH portal customization capability."
version: 1.0.0
author: Paula Silva (Microsoft Latam GBB)
license: MIT
agents:
  - rhdh-architect
skills:
  - rhdh-plugin-design
instructions:
  - rhdh-plugin-architecture
hooks:
  - pre-deploy-validate
workflows:
  - portal-customization
---

# RHDH Architect Plugin

A comprehensive plugin that bundles everything needed to architect, design, and deploy custom RHDH portal customizations.

## What's Included

### Agent: `@rhdh-architect`
RHDH/Backstage Plugin Architect with expertise in:
- Dynamic plugin architecture (84+ plugins, OCI artifacts)
- Frontend wiring (dynamicRoutes, mountPoints, menuItems, entityTabs)
- Backstage API consumption (Catalog, Scaffolder, Search, Identity)
- Three Horizons Portal gap analysis and component design

### Skill: `rhdh-plugin-design`
Complete reference for plugin design decisions:
- `references/frontend-wiring.md` — All 8 wiring mechanisms documented
- `references/backstage-apis.md` — Full API catalog with usage examples
- `references/portal-gap-analysis.md` — 14-page analysis with effort estimates (inc. Copilot + GHAS)

### Scripts
- `validate-plugin-config.py` — Validates YAML config before deployment
- `scaffold-plugin.sh` — Generates plugin boilerplate in seconds

### Assets (ready-to-use configs)
- `three-horizons-branding.yaml` — Microsoft branding for app-config.yaml
- `dynamic-plugins-three-horizons.yaml` — Complete plugin wiring config

### Instructions
- `rhdh-plugin-architecture.instructions.md` — Code standards for plugin development

### Workflow
- `portal-customization.workflow.md` — 6-phase orchestration with validation gates

### Hook
- `pre-deploy-validate.hook.md` — Blocks deployment if config is invalid

## Installation

```bash
# Copy to your .github/copilot/ directory
cp -r agents/rhdh-architect/ .github/copilot/agents/
```

## Usage

```
@rhdh-architect Design the plugin architecture for customizing RHDH
                to match our Three Horizons Portal reference template.
```

## Depends On

This plugin works alongside these agents (not included):
- `@platform` — Implements the plugins designed by `@rhdh-architect`
- `@deploy` — Orchestrates deployment with all custom plugins
- `@template-engineer` — Creates Golden Path templates
- `@devops` — Sets up CI/CD for plugin builds
- `@security` — Reviews RBAC and auth configuration
