# Plugin 2: Platform Stats Cards Widget

> **Plugin Name**: `plugin-platform-stats`
> **Package**: `@three-horizons/backstage-plugin-platform-stats`
> **Type**: Frontend Dynamic Plugin for RHDH 1.8
> **MountPoint**: `home.page/cards`
> **Priority**: HIGH — Key metrics visible immediately on homepage

---

## 1. Objective

Create a custom RHDH Dynamic Plugin that renders **four metric counter cards** on the homepage, showing live counts fetched from the Backstage Catalog API. These cards display the total number of Components, APIs, Templates, and Horizons registered in the catalog.

| Metric | Label | Color | Source |
|--------|-------|-------|--------|
| Components | Components | `#00A4EF` (Blue) | Catalog API: `kind=Component` count |
| APIs | APIs | `#7FBA00` (Green) | Catalog API: `kind=API` count |
| Templates | Templates | `#FFB900` (Yellow, text `#B58200`) | Catalog API: `kind=Template` count |
| Horizons | Horizons | `#F25022` (Red) | Static value: `3` (or tag-based count) |

---

## 2. Visual Reference (from index.html mockup)

```html
<div style="display:grid; grid-template-columns:repeat(4,1fr); gap:20px;">
  <div style="background:#fff; border:1px solid #E8E8EC; border-radius:12px;
              padding:20px; text-align:center; border-top:3px solid #00A4EF;">
    <div style="font-size:28px; font-weight:800; color:#00A4EF; margin-bottom:4px;">42</div>
    <div style="font-size:14px; color:#5C5C6D; text-transform:uppercase; letter-spacing:0.5px;">Components</div>
  </div>
  <div style="border-top:3px solid #7FBA00;">
    <div style="color:#7FBA00;">18</div>
    <div>APIs</div>
  </div>
  <div style="border-top:3px solid #FFB900;">
    <div style="color:#B58200;">12</div>
    <div>Templates</div>
  </div>
  <div style="border-top:3px solid #F25022;">
    <div style="color:#F25022;">3</div>
    <div>Horizons</div>
  </div>
</div>
```

### Design Specifications

- **Layout**: 4-column grid, equal width, responsive (2x2 on tablet, 1-column on mobile)
- **Card**: White background, 1px border `#E8E8EC`, border-radius 12px, padding 20px, center-aligned
- **Top border**: 3px solid, color per metric
- **Counter value**: 28px, font-weight 800, color matching the top border
- **Label**: 14px, uppercase, letter-spacing 0.5px, color `#5C5C6D`
- **Loading state**: Skeleton shimmer while fetching catalog data

---

## 3. Technical Architecture

### 3.1 Plugin Scaffolding

```bash
cd plugins/
npx @backstage/cli new --select plugin --id platform-stats
```

### 3.2 Component Structure

```
plugins/platform-stats/
├── src/
│   ├── index.ts                    # Public exports
│   ├── plugin.ts                   # Plugin definition
│   ├── components/
│   │   ├── PlatformStatsCard.tsx   # Main grid component (exported)
│   │   └── StatCounter.tsx         # Individual stat counter
│   ├── hooks/
│   │   └── useCatalogCounts.ts     # Hook to fetch catalog counts
│   └── constants.ts                # Colors, labels, API kinds
├── package.json
└── README.md
```

### 3.3 Catalog API Integration: `useCatalogCounts.ts`

```tsx
import { useApi, catalogApiRef } from '@backstage/plugin-catalog-react';
import { useState, useEffect } from 'react';

interface CatalogCounts {
  components: number;
  apis: number;
  templates: number;
  horizons: number;
  loading: boolean;
  error: Error | null;
}

export function useCatalogCounts(): CatalogCounts {
  const catalogApi = useApi(catalogApiRef);
  const [counts, setCounts] = useState<CatalogCounts>({
    components: 0,
    apis: 0,
    templates: 0,
    horizons: 3,
    loading: true,
    error: null,
  });

  useEffect(() => {
    async function fetchCounts() {
      try {
        const [components, apis, templates] = await Promise.all([
          catalogApi.getEntities({
            filter: { kind: 'Component' },
            fields: ['metadata.name'],
          }),
          catalogApi.getEntities({
            filter: { kind: 'API' },
            fields: ['metadata.name'],
          }),
          catalogApi.getEntities({
            filter: { kind: 'Template' },
            fields: ['metadata.name'],
          }),
        ]);

        setCounts({
          components: components.items.length,
          apis: apis.items.length,
          templates: templates.items.length,
          horizons: 3,
          loading: false,
          error: null,
        });
      } catch (e) {
        setCounts((prev) => ({
          ...prev,
          loading: false,
          error: e as Error,
        }));
      }
    }

    fetchCounts();
    // Refresh every 60 seconds
    const interval = setInterval(fetchCounts, 60000);
    return () => clearInterval(interval);
  }, [catalogApi]);

  return counts;
}
```

### 3.4 Core Component: `PlatformStatsCard.tsx`

```tsx
import React from 'react';
import Grid from '@mui/material/Grid';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Skeleton from '@mui/material/Skeleton';
import { useCatalogCounts } from '../hooks/useCatalogCounts';

interface StatConfig {
  key: 'components' | 'apis' | 'templates' | 'horizons';
  label: string;
  color: string;
  textColor?: string;
}

const STATS: StatConfig[] = [
  { key: 'components', label: 'Components', color: '#00A4EF' },
  { key: 'apis', label: 'APIs', color: '#7FBA00' },
  { key: 'templates', label: 'Templates', color: '#FFB900', textColor: '#B58200' },
  { key: 'horizons', label: 'Horizons', color: '#F25022' },
];

export const PlatformStatsCard = () => {
  const counts = useCatalogCounts();

  return (
    <Grid container spacing={3}>
      {STATS.map((stat) => (
        <Grid item xs={6} md={3} key={stat.key}>
          <Box
            sx={{
              background: '#fff',
              border: '1px solid #E8E8EC',
              borderTop: `3px solid ${stat.color}`,
              borderRadius: '12px',
              padding: '20px',
              textAlign: 'center',
              height: '100%',
            }}
          >
            {counts.loading ? (
              <Skeleton variant="text" width={60} height={40} sx={{ mx: 'auto' }} />
            ) : (
              <Typography
                sx={{
                  fontSize: 28,
                  fontWeight: 800,
                  color: stat.textColor || stat.color,
                  mb: 0.5,
                }}
              >
                {counts[stat.key]}
              </Typography>
            )}
            <Typography
              sx={{
                fontSize: 14,
                color: '#5C5C6D',
                textTransform: 'uppercase',
                letterSpacing: '0.5px',
              }}
            >
              {stat.label}
            </Typography>
          </Box>
        </Grid>
      ))}
    </Grid>
  );
};
```

### 3.5 Plugin Definition: `plugin.ts`

```tsx
import { createPlugin, catalogApiRef } from '@backstage/core-plugin-api';

export const platformStatsPlugin = createPlugin({
  id: 'platform-stats',
  apis: [],
});
```

### 3.6 Public Export: `index.ts`

```tsx
export { platformStatsPlugin } from './plugin';
export { PlatformStatsCard } from './components/PlatformStatsCard';
```

---

## 4. Dependencies

```json
{
  "dependencies": {
    "@backstage/core-plugin-api": "^1.9.0",
    "@backstage/core-components": "^0.14.0",
    "@backstage/plugin-catalog-react": "^1.12.0",
    "@mui/material": "^5.15.0",
    "react": "^18.2.0"
  },
  "devDependencies": {
    "@red-hat-developer-hub/cli": "^0.3.0",
    "@backstage/cli": "^0.26.0"
  }
}
```

---

## 5. Dynamic Plugin Packaging for RHDH

### 5.1 Export with RHDH CLI

```bash
cd plugins/platform-stats
npx @red-hat-developer-hub/cli package export --in-place --clean
```

### 5.2 Package as OCI Image

```bash
npx @red-hat-developer-hub/cli package package \
  --tag quay.io/three-horizons/backstage-plugin-platform-stats:0.1.0

podman push quay.io/three-horizons/backstage-plugin-platform-stats:0.1.0
```

---

## 6. RHDH Configuration

### 6.1 dynamic-plugins.yaml

```yaml
plugins:
  - package: oci://quay.io/three-horizons/backstage-plugin-platform-stats:0.1.0!plugin-platform-stats
    disabled: false
    pluginConfig:
      dynamicPlugins:
        frontend:
          plugin-platform-stats:
            mountPoints:
              - mountPoint: home.page/cards
                importName: PlatformStatsCard
                config:
                  layouts:
                    xl: { w: 12, h: 4 }
                    lg: { w: 12, h: 4 }
                    md: { w: 12, h: 4 }
                    sm: { w: 12, h: 6 }
                    xs: { w: 12, h: 8 }
                    xxs: { w: 12, h: 8 }
```

### 6.2 Layout Position on Homepage

```
Row 0:  [SearchBar ─────────────── w:12 h:1]
Row 1:  [PlatformStatsCard ─────── w:12 h:4]   ← THIS PLUGIN
Row 5:  [ThreeHorizonsCard ──────── w:12 h:6]
Row 11: [QuickAccessCard ────────── w:12 h:8]
```

---

## 7. Acceptance Criteria

- [ ] Plugin renders 4 stat cards in a responsive 4-column grid
- [ ] Components, APIs, and Templates counts fetched live from Catalog API
- [ ] Horizons shows static value of 3
- [ ] Microsoft brand colors used correctly for each card
- [ ] Loading skeleton displayed while fetching
- [ ] Auto-refresh every 60 seconds
- [ ] Error state handled gracefully (show `--` or last known value)
- [ ] Plugin mounts correctly via `home.page/cards` mountPoint
- [ ] Plugin exports as Scalprum dynamic module
- [ ] Plugin packages as OCI image
- [ ] Responsive: 2x2 grid on tablet, 1-column on mobile

---

## 8. Files to Create

| File | Description |
|------|-------------|
| `plugins/platform-stats/package.json` | Plugin package with catalog deps |
| `plugins/platform-stats/src/index.ts` | Public exports |
| `plugins/platform-stats/src/plugin.ts` | Plugin definition |
| `plugins/platform-stats/src/components/PlatformStatsCard.tsx` | Main component |
| `plugins/platform-stats/src/hooks/useCatalogCounts.ts` | Catalog API hook |
| `plugins/platform-stats/README.md` | Plugin documentation |
| `new-features/deploy/dynamic-plugins.yaml` | Update with plugin entry |
