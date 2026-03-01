# Three Horizons — Custom RHDH Dynamic Plugins

> 4 custom plugins to bridge the gap between our HTML mockups and RHDH 1.8 native capabilities

---

## Overview

Our `login.html` and `index.html` mockups define a fully branded Three Horizons developer portal experience. After analyzing RHDH 1.8 documentation, we identified that **branding, sidebar, Quick Access cards, and search** are natively configurable — but **4 UI elements require custom dynamic plugins**.

## Plugin Summary

| # | Plugin | Purpose | MountPoint | Priority |
|---|--------|---------|------------|----------|
| 1 | `plugin-three-horizons-home` | 3 Horizon Cards (H1/H2/H3) with icons, tags | `home.page/cards` | HIGH |
| 2 | `plugin-platform-stats` | 4 metric counters from Catalog API | `home.page/cards` | HIGH |
| 3 | `plugin-custom-signin` | Custom branded sign-in page | `sign-in-page` override | MEDIUM |
| 4 | `plugin-hero-welcome-banner` | Hero section with gradient accent + search | `home.page/cards` | MEDIUM |

## Homepage Layout (after all plugins)

```
┌─────────────────────────────────────────────────────┐
│  [HeroWelcomeBanner]              Plugin 4  h:5     │
│   Agentic DevOps Platform                           │
│   Three Horizons                                    │
│   Description + Search bar                          │
├─────────────────────────────────────────────────────┤
│  [PlatformStatsCard]              Plugin 2  h:4     │
│   42 Components │ 18 APIs │ 12 Templates │ 3 H      │
├─────────────────────────────────────────────────────┤
│  [ThreeHorizonsCard]              Plugin 1  h:6     │
│   H1 Foundation │ H2 Intelligence │ H3 Autonomy     │
├─────────────────────────────────────────────────────┤
│  [QuickAccessCard]                Native    h:8     │
│   Software Catalog │ API Explorer │ Create │ Docs   │
├─────────────────────────────────────────────────────┤
│  [CatalogStarredEntities]         Native    h:4     │
│   Your starred entities                              │
└─────────────────────────────────────────────────────┘
```

## Technology Stack

- **React 18** + **MUI 5** (Material UI)
- **Backstage Plugin API** (`@backstage/core-plugin-api`)
- **Backstage Catalog API** (`@backstage/plugin-catalog-react`) — for Plugin 2
- **RHDH CLI** (`@red-hat-developer-hub/cli`) — for Scalprum export
- **OCI Images** on Quay.io — for deployment

## Development Workflow

```bash
# 1. Scaffold each plugin
cd plugins/
npx @backstage/cli new --select plugin --id <plugin-id>

# 2. Develop the React component
# ... implement per each plugin prompt

# 3. Export as dynamic plugin
npx @red-hat-developer-hub/cli package export --in-place --clean

# 4. Package as OCI
npx @red-hat-developer-hub/cli package package \
  --tag quay.io/three-horizons/<plugin-name>:0.1.0

# 5. Push to registry
podman push quay.io/three-horizons/<plugin-name>:0.1.0

# 6. Configure in dynamic-plugins.yaml
# Add the plugin entry with mountPoints config
```

## Microsoft Brand Colors Reference

| Color | Hex | Usage |
|-------|-----|-------|
| Blue | `#00A4EF` | H1 Foundation, primary accent, links |
| Green | `#7FBA00` | H2 Intelligence, APIs metric |
| Yellow | `#FFB900` | H3 Autonomy, Templates metric (text: `#B58200`) |
| Red | `#F25022` | Horizons metric, alerts |
| Dark | `#1B1B1F` | Sidebar, headings, primary text |
| Secondary | `#5C5C6D` | Descriptions, secondary text |
| Tertiary | `#8E8E9A` | Hints, placeholders |
| Border | `#E8E8EC` | Card borders, dividers |
| Background | `#F7F7F9` | Page background |

## Files Reference

- **Visual mockup — Login**: `new-features/homepage/login.html`
- **Visual mockup — Dashboard**: `new-features/homepage/index.html`
- **Current RHDH config**: `new-features/deploy/app-config-rhdh.yaml`
- **Current dynamic plugins**: `new-features/deploy/dynamic-plugins.yaml`
- **Homepage data (Quick Access)**: `new-features/deploy/configmaps.yaml`
- **Three Horizons logo**: `images-logos/Three-Horizon-Logo.png`

## Agent Note

The `@template-engineer` agent is specialized in RHDH **Software Templates** (scaffolder), not frontend plugins. These prompts are designed to be **self-contained** with complete React component code, plugin architecture, and deployment instructions. They can be executed by any developer or agent with Node.js + Backstage CLI knowledge.
