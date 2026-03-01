# Plugin 3: Custom Sign-in Page

> **Plugin Name**: `plugin-custom-signin`
> **Package**: `@three-horizons/backstage-plugin-custom-signin`
> **Type**: Frontend Dynamic Plugin for RHDH 1.8
> **MountPoint**: `sign-in-page` (custom theme override)
> **Priority**: MEDIUM — Branding impact, higher complexity

---

## 1. Objective

Create a custom RHDH Dynamic Plugin that **replaces the default sign-in page** with a fully branded Three Horizons login experience. The default RHDH sign-in page only shows the configured logo and an OAuth button. Our design includes:

- Three Horizons composite logo (220px wide)
- Title: "Three Horizons"
- Subtitle: "Agentic DevOps Platform"
- Tagline: "Powered by Red Hat® Developer Hub"
- GitHub OAuth sign-in button (dark, full width)
- Info text: "Sign in with your GitHub organization account to access the developer portal."
- Three mini Horizon cards (Foundation, Intelligence, Autonomy)
- Footer: "Microsoft · GitHub · Open Source"
- 4-color gradient bar at the top of the page

---

## 2. Visual Reference (from login.html mockup)

### Page Layout

```
┌──────────────────────────────────────────────┐
│ ████ 4-color gradient bar (4px height)  ████ │
│                                              │
│         [Three Horizons Logo - 220px]        │
│                                              │
│            Three Horizons                    │
│         Agentic DevOps Platform              │
│     Powered by Red Hat® Developer Hub        │
│                                              │
│  ┌────────────────────────────────────────┐  │
│  │  🐙  Sign in with GitHub              │  │
│  └────────────────────────────────────────┘  │
│                                              │
│  Sign in with your GitHub organization       │
│  account to access the developer portal.     │
│                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐    │
│  │ 🔨       │ │ ⚡       │ │ 🚀       │    │
│  │Foundation │ │Intellig. │ │Autonomy  │    │
│  │Core infra │ │AI tools  │ │Self-heal │    │
│  └──────────┘ └──────────┘ └──────────┘    │
│                                              │
│     Microsoft · GitHub · Open Source         │
└──────────────────────────────────────────────┘
```

### Design Specifications

- **Background**: `#F7F7F9` with centered content
- **4-color gradient bar**: 4px height, `linear-gradient(90deg, #F25022 25%, #7FBA00 25%, #7FBA00 50%, #00A4EF 50%, #00A4EF 75%, #FFB900 75%)`
- **Login box**: max-width 520px, centered, no visible border
- **Logo**: Three Horizons composite logo, 220px width
- **Title**: 32px, font-weight 700, color `#1B1B1F`
- **Subtitle**: 20px, font-weight 500, color `#5C5C6D`
- **Tagline**: 14px, color `#8E8E9A`
- **GitHub button**: Full width, 52px height, `#24292e` background, white text, GitHub Octocat SVG icon, border-radius 8px
- **Info text**: 14px, color `#8E8E9A`, single line with `white-space: nowrap`
- **Horizon mini-cards**: 3-column grid, white bg, 1px border, 3px colored top border
- **Footer**: 12px, color `#8E8E9A`, top border separator
- **Animations**: All elements fade in sequentially (0.1s stagger)

---

## 3. Technical Architecture

### 3.1 IMPORTANT: Sign-in Page Override Strategy

RHDH 1.8 does **not** expose a `sign-in-page` mountPoint natively. There are two approaches:

#### Approach A: Custom Sign-In Page Component (Recommended)

Override the sign-in page by providing a custom `SignInPage` component via the app's `createApp` configuration. In a dynamic plugin context, this requires:

1. Create a plugin that provides a `SignInPage` component
2. Register it via `app.components.signInPage` in `app-config.yaml`

```yaml
# app-config.yaml
app:
  components:
    signInPage:
      importName: ThreeHorizonsSignInPage
      package: plugin-custom-signin
```

#### Approach B: Theme Override with Custom CSS + Branding

If full sign-in page replacement is not feasible in RHDH dynamic plugin model, use a combination of:

1. **Branding config** in `app-config.yaml` for logo and colors
2. **Custom CSS injection** via a theme plugin for layout adjustments
3. Accept the limitation that the 3 horizon mini-cards and footer cannot appear

### 3.2 Plugin Structure (Approach A)

```
plugins/custom-signin/
├── src/
│   ├── index.ts                     # Public exports
│   ├── plugin.ts                    # Plugin definition
│   ├── components/
│   │   ├── ThreeHorizonsSignInPage.tsx  # Full sign-in page
│   │   ├── HorizonMiniCard.tsx      # Mini horizon card
│   │   ├── GitHubSignInButton.tsx   # Styled OAuth button
│   │   └── ColorBar.tsx             # 4-color gradient bar
│   ├── assets/
│   │   └── three-horizons-logo.ts   # Logo as base64 or SVG constant
│   └── styles/
│       └── signin-theme.ts          # Styled components / sx props
├── package.json
└── README.md
```

### 3.3 Core Component: `ThreeHorizonsSignInPage.tsx`

```tsx
import React from 'react';
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import Grid from '@mui/material/Grid';
import { useApi, configApiRef } from '@backstage/core-plugin-api';
import { githubAuthApiRef } from '@backstage/core-plugin-api';

const HORIZONS_MINI = [
  { icon: '🔨', title: 'Foundation', desc: 'Core infrastructure & CI/CD', color: '#00A4EF' },
  { icon: '⚡', title: 'Intelligence', desc: 'AI-powered dev tools', color: '#7FBA00' },
  { icon: '🚀', title: 'Autonomy', desc: 'Self-healing operations', color: '#FFB900' },
];

const COLOR_BAR_GRADIENT =
  'linear-gradient(90deg, #F25022 25%, #7FBA00 25%, #7FBA00 50%, #00A4EF 50%, #00A4EF 75%, #FFB900 75%)';

export const ThreeHorizonsSignInPage = ({ onSignInSuccess }: { onSignInSuccess: Function }) => {
  const githubAuth = useApi(githubAuthApiRef);

  const handleSignIn = async () => {
    // Trigger GitHub OAuth flow
    const identity = await githubAuth.getBackstageIdentity();
    onSignInSuccess(identity);
  };

  return (
    <Box sx={{ minHeight: '100vh', background: '#F7F7F9', display: 'flex', flexDirection: 'column' }}>
      {/* 4-color bar */}
      <Box sx={{ height: 4, background: COLOR_BAR_GRADIENT }} />

      {/* Centered login box */}
      <Box sx={{
        flex: 1, display: 'flex', justifyContent: 'center', alignItems: 'center',
      }}>
        <Box sx={{ width: '100%', maxWidth: 520, px: 3, textAlign: 'center' }}>
          {/* Logo */}
          <Box sx={{ mb: 4 }}>
            <img
              src="/branding/full-logo.png"
              alt="Three Horizons"
              style={{ width: 220, height: 'auto' }}
            />
          </Box>

          {/* Title hierarchy */}
          <Typography variant="h3" sx={{ fontSize: 32, fontWeight: 700, mb: 1, color: '#1B1B1F' }}>
            Three Horizons
          </Typography>
          <Typography sx={{ fontSize: 20, fontWeight: 500, color: '#5C5C6D', mb: 0.5 }}>
            Agentic DevOps Platform
          </Typography>
          <Typography sx={{ fontSize: 14, color: '#8E8E9A', mb: 5 }}>
            Powered by Red Hat® Developer Hub
          </Typography>

          {/* GitHub Sign-in Button */}
          <Button
            variant="contained"
            fullWidth
            onClick={handleSignIn}
            sx={{
              height: 52,
              background: '#24292e',
              color: '#fff',
              borderRadius: '8px',
              fontSize: 16,
              fontWeight: 600,
              textTransform: 'none',
              boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
              '&:hover': { background: '#2f363d', transform: 'translateY(-2px)' },
              gap: 1.5,
            }}
          >
            {/* GitHub Octocat SVG inline */}
            <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
              <path d="M12 0C5.374 0 0 5.373 0 12c0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23A11.509 11.509 0 0112 5.803c1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576C20.566 21.797 24 17.3 24 12c0-6.627-5.373-12-12-12z"/>
            </svg>
            Sign in with GitHub
          </Button>

          {/* Info text */}
          <Typography sx={{ fontSize: 14, color: '#8E8E9A', my: 3, whiteSpace: 'nowrap' }}>
            Sign in with your GitHub organization account to access the developer portal.
          </Typography>

          {/* Mini Horizon Cards */}
          <Grid container spacing={2} sx={{ mb: 5 }}>
            {HORIZONS_MINI.map((h) => (
              <Grid item xs={4} key={h.title}>
                <Box sx={{
                  background: '#fff',
                  border: '1px solid #E8E8EC',
                  borderTop: `3px solid ${h.color}`,
                  borderRadius: '8px',
                  p: '18px 14px',
                  transition: 'all 0.2s',
                  '&:hover': { transform: 'translateY(-3px)', boxShadow: '0 8px 24px rgba(0,0,0,0.12)' },
                }}>
                  <Typography sx={{ fontSize: 26, mb: 1 }}>{h.icon}</Typography>
                  <Typography sx={{ fontSize: 14, fontWeight: 700, mb: 0.5 }}>{h.title}</Typography>
                  <Typography sx={{ fontSize: 12, color: '#5C5C6D', lineHeight: 1.4 }}>{h.desc}</Typography>
                </Box>
              </Grid>
            ))}
          </Grid>

          {/* Footer */}
          <Box sx={{ borderTop: '1px solid #EDEDF0', pt: 3 }}>
            <Typography sx={{ fontSize: 12, color: '#8E8E9A' }}>
              Microsoft · GitHub · Open Source
            </Typography>
          </Box>
        </Box>
      </Box>
    </Box>
  );
};
```

### 3.4 Plugin Definition: `plugin.ts`

```tsx
import { createPlugin } from '@backstage/core-plugin-api';

export const customSigninPlugin = createPlugin({
  id: 'custom-signin',
});
```

### 3.5 Public Export: `index.ts`

```tsx
export { customSigninPlugin } from './plugin';
export { ThreeHorizonsSignInPage } from './components/ThreeHorizonsSignInPage';
```

---

## 4. RHDH Configuration

### 4.1 dynamic-plugins.yaml

```yaml
plugins:
  - package: oci://quay.io/three-horizons/backstage-plugin-custom-signin:0.1.0!plugin-custom-signin
    disabled: false
    pluginConfig:
      dynamicPlugins:
        frontend:
          plugin-custom-signin:
            appIcons:
              - name: threeHorizonsSignIn
                importName: ThreeHorizonsSignInPage
```

### 4.2 app-config.yaml — Sign-in Page Override

```yaml
app:
  signInPage: github
  # The custom sign-in page is registered via the dynamic plugin
  # If RHDH supports component override:
  components:
    signInPage:
      importName: ThreeHorizonsSignInPage
      package: plugin-custom-signin
```

### 4.3 Branding Configuration (Required either way)

```yaml
app:
  branding:
    fullLogo: data:image/png;base64,[THREE_HORIZONS_LOGO_BASE64]
    iconLogo: data:image/png;base64,[THREE_HORIZONS_ICON_BASE64]
    fullLogoWidth: 220
    theme:
      light:
        primaryColor: '#00A4EF'
        headerColor1: '#1B1B1F'
        headerColor2: '#00A4EF'
        navigationIndicatorColor: '#00A4EF'
        sidebarBackgroundColor: '#1B1B1F'
        sidebarItemTextColor: '#B8B8C0'
```

---

## 5. Feasibility Notes

### Known Limitations

1. **RHDH 1.8 sign-in page customization is limited**: The default sign-in page only renders the configured logo and OAuth provider buttons. Full page replacement via dynamic plugins may require RHDH 1.9+ or a custom theme plugin approach.

2. **Fallback Strategy**: If full sign-in page replacement is not possible via dynamic plugins:
   - Configure the Three Horizons logo via `branding.fullLogo` in `app-config.yaml`
   - Configure the primary color for the button styling
   - Accept that subtitle, tagline, mini-cards, and footer won't appear
   - Document this as a feature request for RHDH 1.9+

3. **Authentication Flow**: The `onSignInSuccess` callback must be compatible with RHDH's authentication flow. The actual OAuth redirect is handled by the backend — this component wraps the UI around it.

---

## 6. Acceptance Criteria

- [ ] Custom sign-in page renders with Three Horizons branding
- [ ] 4-color gradient bar at top of page
- [ ] Three Horizons logo displayed at 220px width
- [ ] Title hierarchy: "Three Horizons" / "Agentic DevOps Platform" / "Powered by Red Hat® Developer Hub"
- [ ] GitHub OAuth button triggers proper authentication flow
- [ ] "Sign in with your GitHub..." text on single line
- [ ] Three mini Horizon cards (Foundation, Intelligence, Autonomy)
- [ ] Footer with "Microsoft · GitHub · Open Source"
- [ ] Sequential fade-in animations
- [ ] Plugin exports as Scalprum dynamic module
- [ ] Responsive layout (stacks mini-cards on mobile)
- [ ] **FALLBACK**: If full replacement not feasible, document limitation and configure maximum branding via `app-config.yaml`

---

## 7. Files to Create

| File | Description |
|------|-------------|
| `plugins/custom-signin/package.json` | Plugin package |
| `plugins/custom-signin/src/index.ts` | Public exports |
| `plugins/custom-signin/src/plugin.ts` | Plugin definition |
| `plugins/custom-signin/src/components/ThreeHorizonsSignInPage.tsx` | Full sign-in page |
| `plugins/custom-signin/src/assets/three-horizons-logo.ts` | Logo as base64 |
| `plugins/custom-signin/README.md` | Plugin documentation |
| `new-features/deploy/app-config-rhdh.yaml` | Update branding section |
| `new-features/deploy/dynamic-plugins.yaml` | Update with plugin entry |
