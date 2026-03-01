---
name: rhdh-plugin-design
description: "Complete reference for designing RHDH/Backstage custom dynamic plugins, including frontend wiring mechanisms, Backstage API catalog, component patterns, and the Three Horizons Portal gap analysis. Use this skill whenever you need to design a plugin, evaluate wiring options, or understand what Backstage APIs are available for custom frontend components."
---

# RHDH Plugin Design Skill

This skill provides the architectural knowledge needed to design custom dynamic plugins for Red Hat Developer Hub 1.8+. It covers the complete frontend wiring system, available Backstage APIs, component patterns, and a reference analysis of the Three Horizons Portal.

## When to Use This Skill

- Designing a new custom RHDH dynamic plugin (frontend or full-stack)
- Deciding which wiring mechanism to use (`dynamicRoutes`, `mountPoints`, `menuItems`, `entityTabs`)
- Looking up which Backstage APIs are available for custom components
- Creating a feasibility analysis for a UI customization request
- Converting a community Backstage plugin to a RHDH dynamic plugin via Dynamic Plugin Factory

## Prerequisites

- RHDH 1.8+ deployed on AKS (or OpenShift)
- Node.js 18+ and npm/yarn for plugin development
- Familiarity with React, TypeScript, and Material UI (MUI)
- Access to the RHDH `app-config.yaml` and `dynamic-plugins-config.yaml`

## Dynamic Plugin Architecture

### How Dynamic Plugins Work in RHDH

RHDH loads plugins at **runtime** — no rebuild of the portal is needed. Plugins are packaged as OCI artifacts (from RHDH 1.9+) or npm packages and loaded via the `dynamic-plugins-config.yaml`.

**Plugin lifecycle:**
1. Developer creates a Backstage plugin (React + TypeScript)
2. Plugin is exported as a dynamic plugin using `@janus-idp/cli`
3. Plugin is packaged as an OCI artifact and pushed to a container registry (ACR)
4. RHDH is configured to load the plugin via `dynamic-plugins-config.yaml`
5. RHDH loads the plugin at startup and wires it into the UI

### Creating a Dynamic Plugin

```bash
# 1. Scaffold a new Backstage plugin
npx @backstage/create-app --skip-install
cd plugins/my-plugin

# 2. Build the plugin
npm run build

# 3. Export as dynamic plugin
npx @janus-idp/cli package export-dynamic-plugin

# 4. Push to ACR as OCI artifact
oras push myacr.azurecr.io/plugins/my-plugin:1.0.0 dist-dynamic/*
```

### Dynamic Plugin Factory (Developer Preview)

For converting existing community Backstage plugins:
```bash
# Wrap an existing plugin
npx @red-hat-developer-hub/plugin-dynamic-plugin-factory wrap \
  --plugin @backstage/plugin-catalog-graph
```

## Frontend Wiring Reference

> **For complete details, see:** [references/frontend-wiring.md](references/frontend-wiring.md)

### Quick Reference

| Mechanism | Use Case | Scope |
|-----------|----------|-------|
| `dynamicRoutes` | Full custom pages (Home, My Group) | App-level route |
| `mountPoints` | Widgets embedded in existing pages | Component-level |
| `menuItems` | Sidebar navigation entries | Navigation |
| `entityTabs` | Custom tabs on entity detail pages | Entity page |
| `appIcons` | Custom SVG icons for menu items | Visual |
| `routeBindings` | Link plugins to each other's routes | Cross-plugin |
| `apiFactories` | Register custom backend APIs | Data layer |

### dynamicRoutes — Full Page Plugin

```yaml
dynamicPlugins:
  frontend:
    my-home-plugin:
      dynamicRoutes:
        - path: /
          importName: ThreeHorizonsHomePage
          menuItem:
            icon: HomeIcon
            text: Home
        - path: /my-group
          importName: MyGroupDashboard
          menuItem:
            icon: GroupIcon
            text: My Group
```

### mountPoints — Embedded Component

```yaml
dynamicPlugins:
  frontend:
    my-stats-plugin:
      mountPoints:
        - mountPoint: entity.page.overview/cards
          importName: StatCards
          config:
            layout:
              gridColumn: "1 / -1"
            if:
              allOf:
                - isKind: component
```

### menuItems — Sidebar Navigation

```yaml
dynamicPlugins:
  frontend:
    my-plugin:
      menuItems:
        - text: Learning Paths
          icon: SchoolIcon
          to: /learning-paths
```

## Backstage API Catalog

> **For complete details, see:** [references/backstage-apis.md](references/backstage-apis.md)

### Key APIs for Custom Plugins

| API Ref | Purpose | Import |
|---------|---------|--------|
| `catalogApiRef` | Query catalog entities (components, APIs, groups, users) | `@backstage/plugin-catalog-react` |
| `scaffolderApiRef` | List and execute templates | `@backstage/plugin-scaffolder` |
| `identityApiRef` | Get current user identity and group membership | `@backstage/core-plugin-api` |
| `searchApiRef` | Full-text search across catalog | `@backstage/plugin-search-react` |
| `techdocsStorageApiRef` | Access TechDocs content | `@backstage/plugin-techdocs` |
| `configApiRef` | Read app-config values | `@backstage/core-plugin-api` |
| `fetchApiRef` | Make authenticated HTTP requests | `@backstage/core-plugin-api` |

### Example: Fetching Entity Counts

```typescript
import { useApi, catalogApiRef } from '@backstage/plugin-catalog-react';

function useEntityCounts() {
  const catalogApi = useApi(catalogApiRef);

  const [counts, setCounts] = useState({ components: 0, apis: 0, templates: 0 });

  useEffect(() => {
    async function fetchCounts() {
      const components = await catalogApi.getEntities({
        filter: { kind: 'Component' },
      });
      const apis = await catalogApi.getEntities({
        filter: { kind: 'API' },
      });
      const templates = await catalogApi.getEntities({
        filter: { kind: 'Template' },
      });
      setCounts({
        components: components.items.length,
        apis: apis.items.length,
        templates: templates.items.length,
      });
    }
    fetchCounts();
  }, [catalogApi]);

  return counts;
}
```

## Three Horizons Portal — Gap Analysis

> **For complete details, see:** [references/portal-gap-analysis.md](references/portal-gap-analysis.md)

### Summary

| Page | Native? | Plugin Needed? | Effort |
|------|---------|----------------|--------|
| Home | Partial | Custom Home Page Plugin | 3-5 days |
| My Group | No | Custom My Group Plugin | 2-3 days |
| Catalog | 90% | Minor mountPoint for stat cards | 0.5 day |
| APIs | 80% | Minor layout customization | 0.5 day |
| Learning Paths | Via TechDocs | Optional custom plugin | 1-2 days |
| Create | 100% | None (native Scaffolder) | 0 |
| Docs | 95% | None (native TechDocs) | 0 |
| Lightspeed | 100% | Enable dynamic plugin | 0.5 day |
| Notifications | 95% | Enable dynamic plugin | 0.5 day |
| Administration | 90% | Enable RBAC Web UI | 0.5 day |
| Copilot Metrics | No | Custom Full-Stack Plugin (GitHub API) | 4-6 days |
| GHAS Metrics | No | Custom Full-Stack Plugin (GitHub API) | 5-7 days |
| Settings | 100% | None (native) | 0 |

### Custom Home Page Plugin — Component Specs

```
ThreeHorizonsHomePage
├── HeroBanner
│   ├── BrandingHeader (Agentic DevOps Platform + Three Horizons title)
│   ├── SubtitleText (RHDH description)
│   └── GlobalSearchBar (uses searchApiRef)
├── StatCards (grid of 4)
│   ├── StatCard[blue] — Components count (catalogApiRef)
│   ├── StatCard[green] — APIs count (catalogApiRef)
│   ├── StatCard[yellow] — Templates count (catalogApiRef)
│   └── StatCard[red] — Horizons (static: 3)
├── HorizonCards (grid of 3)
│   ├── HorizonCard[H1] — Foundation (blue border)
│   ├── HorizonCard[H2] — Intelligence (green border)
│   └── HorizonCard[H3] — Autonomy (yellow border)
├── QuickAccess (grid of 4)
│   ├── QuickLink — Software Catalog → /catalog
│   ├── QuickLink — API Explorer → /api-docs
│   ├── QuickLink — Create Component → /create
│   └── QuickLink — Documentation → /docs
└── FeaturedTemplates (grid of 3)
    ├── TemplateCard — Node.js Microservice (scaffolderApiRef)
    ├── TemplateCard — Python FastAPI (scaffolderApiRef)
    └── TemplateCard — React Frontend (scaffolderApiRef)
```

## Validation Checklist

Before handing off a plugin design:

- [ ] ADR written and approved
- [ ] Component specs include: purpose, data sources, props, visual reference, wiring
- [ ] `dynamic-plugins-config.yaml` snippet is valid YAML
- [ ] `app-config.yaml` branding snippet is valid YAML
- [ ] All Backstage APIs used are available in RHDH 1.8
- [ ] No direct cluster access from frontend (use backend-for-frontend if needed)
- [ ] RBAC implications documented
- [ ] Effort estimates provided
- [ ] Handoff agents identified
