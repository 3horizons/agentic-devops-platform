# Plugin 4: Hero Welcome Banner Widget

> **Plugin Name**: `plugin-hero-welcome-banner`
> **Package**: `@three-horizons/backstage-plugin-hero-welcome-banner`
> **Type**: Frontend Dynamic Plugin for RHDH 1.8
> **MountPoint**: `home.page/cards`
> **Priority**: MEDIUM — Visual identity for homepage hero section

---

## 1. Objective

Create a custom RHDH Dynamic Plugin that renders a **branded hero/welcome banner** at the top of the homepage. The RHDH Dynamic Home Page does not natively support a hero section with custom typography, gradient accent lines, or taglines. This plugin fills that gap.

The hero banner includes:

- Vertical gradient accent bar (blue → green, 4px wide × 40px tall)
- Eyebrow text: "AGENTIC DEVOPS PLATFORM" (uppercase, letter-spacing, blue)
- Main heading: "Three Horizons" (28px, bold)
- Description: "Powered by Red Hat® Developer Hub — Your single pane of glass for services, APIs, documentation, and developer tooling."
- Integrated search bar (delegates to Backstage SearchBar)

---

## 2. Visual Reference (from index.html mockup)

```html
<div style="padding:40px 0 24px;">
  <div style="display:flex; align-items:center; gap:12px; margin-bottom:8px;">
    <!-- Gradient accent bar -->
    <div style="width:4px; height:40px; border-radius:2px;
                background:linear-gradient(180deg, #00A4EF, #7FBA00);"></div>
    <div>
      <!-- Eyebrow -->
      <div style="font-size:13px; font-weight:600; text-transform:uppercase;
                  letter-spacing:1.5px; color:#00A4EF; margin-bottom:2px;">
        Agentic DevOps Platform
      </div>
      <!-- Main heading -->
      <h1 style="font-size:28px; font-weight:700; color:#1B1B1F; margin:0; line-height:1.2;">
        Three Horizons
      </h1>
    </div>
  </div>
  <!-- Description -->
  <p style="color:#5C5C6D; font-size:15px; margin:8px 0 20px; max-width:600px;">
    Powered by Red Hat® Developer Hub — Your single pane of glass for services,
    APIs, documentation, and developer tooling.
  </p>
  <!-- Search bar -->
  <div style="max-width:640px; background:#fff; border:1px solid #E8E8EC;
              border-radius:10px; padding:12px 16px; display:flex; align-items:center; gap:12px;">
    <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="#8E8E9A" stroke-width="2">
      <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
    </svg>
    <input type="text" placeholder="Search components, APIs, templates, and docs..."
           style="border:none; flex:1; font-size:16px; outline:none;" />
  </div>
</div>
```

### Design Specifications

- **Container**: Full width, padding 40px top / 24px bottom, no background color (inherits page bg)
- **Gradient bar**: 4px wide × 40px tall, border-radius 2px, `linear-gradient(180deg, #00A4EF, #7FBA00)`
- **Eyebrow**: 13px, font-weight 600, uppercase, letter-spacing 1.5px, color `#00A4EF`
- **Heading**: 28px, font-weight 700, color `#1B1B1F`, line-height 1.2
- **Description**: 15px, color `#5C5C6D`, max-width 600px
- **Search bar**: max-width 640px, white bg, 1px border `#E8E8EC`, border-radius 10px, padding 12px 16px
- **Search icon**: 20px, stroke `#8E8E9A`
- **Search placeholder**: "Search components, APIs, templates, and docs..."

---

## 3. Technical Architecture

### 3.1 Plugin Scaffolding

```bash
cd plugins/
npx @backstage/cli new --select plugin --id hero-welcome-banner
```

### 3.2 Component Structure

```
plugins/hero-welcome-banner/
├── src/
│   ├── index.ts                       # Public exports
│   ├── plugin.ts                      # Plugin definition
│   ├── components/
│   │   ├── HeroWelcomeBanner.tsx      # Main component (exported)
│   │   ├── GradientAccentBar.tsx      # Accent bar component
│   │   └── HeroSearchBar.tsx          # Search input (delegates to Backstage search)
│   └── constants.ts                   # Text, colors, URLs
├── package.json
└── README.md
```

### 3.3 Core Component: `HeroWelcomeBanner.tsx`

```tsx
import React from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import InputBase from '@mui/material/InputBase';
import SearchIcon from '@mui/icons-material/Search';
import { useNavigate } from 'react-router-dom';

const GRADIENT = 'linear-gradient(180deg, #00A4EF, #7FBA00)';

export const HeroWelcomeBanner = () => {
  const navigate = useNavigate();
  const [query, setQuery] = React.useState('');

  const handleSearch = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && query.trim()) {
      navigate(`/search?query=${encodeURIComponent(query.trim())}`);
    }
  };

  return (
    <Box sx={{ pt: 5, pb: 3 }}>
      {/* Title block with gradient accent */}
      <Box sx={{ display: 'flex', alignItems: 'center', gap: 1.5, mb: 1 }}>
        {/* Gradient accent bar */}
        <Box
          sx={{
            width: 4,
            height: 40,
            borderRadius: '2px',
            background: GRADIENT,
            flexShrink: 0,
          }}
        />
        <Box>
          {/* Eyebrow */}
          <Typography
            sx={{
              fontSize: 13,
              fontWeight: 600,
              textTransform: 'uppercase',
              letterSpacing: '1.5px',
              color: '#00A4EF',
              mb: 0.25,
            }}
          >
            Agentic DevOps Platform
          </Typography>
          {/* Main heading */}
          <Typography
            variant="h1"
            sx={{
              fontSize: 28,
              fontWeight: 700,
              color: '#1B1B1F',
              lineHeight: 1.2,
              m: 0,
            }}
          >
            Three Horizons
          </Typography>
        </Box>
      </Box>

      {/* Description */}
      <Typography
        sx={{
          color: '#5C5C6D',
          fontSize: 15,
          my: 1,
          maxWidth: 600,
          lineHeight: 1.6,
        }}
      >
        Powered by Red Hat® Developer Hub — Your single pane of glass for services,
        APIs, documentation, and developer tooling.
      </Typography>

      {/* Search bar */}
      <Box
        sx={{
          maxWidth: 640,
          mt: 2.5,
          background: '#fff',
          border: '1px solid #E8E8EC',
          borderRadius: '10px',
          px: 2,
          py: 1.5,
          display: 'flex',
          alignItems: 'center',
          gap: 1.5,
          transition: 'all 0.2s',
          '&:focus-within': {
            borderColor: '#00A4EF',
            boxShadow: '0 0 0 3px rgba(0,164,239,0.1)',
          },
        }}
      >
        <SearchIcon sx={{ color: '#8E8E9A', fontSize: 20 }} />
        <InputBase
          fullWidth
          placeholder="Search components, APIs, templates, and docs..."
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          onKeyDown={handleSearch}
          sx={{ fontSize: 16, color: '#1B1B1F' }}
        />
      </Box>
    </Box>
  );
};
```

### 3.4 Plugin Definition: `plugin.ts`

```tsx
import { createPlugin } from '@backstage/core-plugin-api';

export const heroWelcomeBannerPlugin = createPlugin({
  id: 'hero-welcome-banner',
});
```

### 3.5 Public Export: `index.ts`

```tsx
export { heroWelcomeBannerPlugin } from './plugin';
export { HeroWelcomeBanner } from './components/HeroWelcomeBanner';
```

---

## 4. Dependencies

```json
{
  "dependencies": {
    "@backstage/core-plugin-api": "^1.9.0",
    "@backstage/core-components": "^0.14.0",
    "@mui/material": "^5.15.0",
    "@mui/icons-material": "^5.15.0",
    "react": "^18.2.0",
    "react-router-dom": "^6.0.0"
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
cd plugins/hero-welcome-banner
npx @red-hat-developer-hub/cli package export --in-place --clean
```

### 5.2 Package as OCI Image

```bash
npx @red-hat-developer-hub/cli package package \
  --tag quay.io/three-horizons/backstage-plugin-hero-welcome-banner:0.1.0

podman push quay.io/three-horizons/backstage-plugin-hero-welcome-banner:0.1.0
```

---

## 6. RHDH Configuration

### 6.1 dynamic-plugins.yaml

```yaml
plugins:
  - package: oci://quay.io/three-horizons/backstage-plugin-hero-welcome-banner:0.1.0!plugin-hero-welcome-banner
    disabled: false
    pluginConfig:
      dynamicPlugins:
        frontend:
          plugin-hero-welcome-banner:
            mountPoints:
              - mountPoint: home.page/cards
                importName: HeroWelcomeBanner
                config:
                  layouts:
                    xl: { w: 12, h: 5, x: 0, y: 0 }
                    lg: { w: 12, h: 5, x: 0, y: 0 }
                    md: { w: 12, h: 5, x: 0, y: 0 }
                    sm: { w: 12, h: 6, x: 0, y: 0 }
                    xs: { w: 12, h: 7, x: 0, y: 0 }
                    xxs: { w: 12, h: 8, x: 0, y: 0 }
```

### 6.2 Complete Homepage Layout (all 4 plugins combined)

```
Row 0:  [HeroWelcomeBanner ──────── w:12 h:5]   ← PLUGIN 4
Row 5:  [PlatformStatsCard ─────── w:12 h:4]    ← PLUGIN 2
Row 9:  [ThreeHorizonsCard ──────── w:12 h:6]   ← PLUGIN 1
Row 15: [QuickAccessCard ────────── w:12 h:8]   ← NATIVE
Row 23: [CatalogStarredEntities ─── w:12 h:4]  ← NATIVE
```

---

## 7. Search Integration Notes

The search bar in this hero banner navigates to `/search?query=...` which is the standard Backstage search page route. This works because:

1. The `backstage-plugin-search` is already enabled in `dynamic-plugins.yaml`
2. The search backend (`backstage-plugin-search-backend-module-pg`) is configured
3. The route `/search` is automatically registered by the search plugin

For a more integrated experience, you can use the Backstage `SearchBar` component directly:

```tsx
import { SearchBar } from '@backstage/plugin-search-react';

// Replace the custom InputBase with:
<SearchBar placeholder="Search components, APIs, templates, and docs..." />
```

However, the Backstage `SearchBar` has its own styling that may not match the mockup exactly. The custom approach gives full visual control.

---

## 8. Acceptance Criteria

- [ ] Hero banner renders at the top of the homepage
- [ ] Gradient accent bar: 4px × 40px, blue-to-green gradient
- [ ] Eyebrow text: "AGENTIC DEVOPS PLATFORM" in uppercase blue
- [ ] Main heading: "Three Horizons" at 28px bold
- [ ] Description text matches mockup
- [ ] Search bar with icon, placeholder text, and focus ring
- [ ] Search submits to `/search?query=...` on Enter
- [ ] Focus state: blue border + shadow
- [ ] Plugin mounts as first card on homepage (y: 0)
- [ ] Plugin exports as Scalprum dynamic module
- [ ] Plugin packages as OCI image
- [ ] Responsive: search bar scales, text wraps naturally

---

## 9. Files to Create

| File | Description |
|------|-------------|
| `plugins/hero-welcome-banner/package.json` | Plugin package |
| `plugins/hero-welcome-banner/src/index.ts` | Public exports |
| `plugins/hero-welcome-banner/src/plugin.ts` | Plugin definition |
| `plugins/hero-welcome-banner/src/components/HeroWelcomeBanner.tsx` | Main component |
| `plugins/hero-welcome-banner/README.md` | Plugin documentation |
| `new-features/deploy/dynamic-plugins.yaml` | Update with plugin entry |
