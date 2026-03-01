# ADR-001: Custom Home Page Plugin Architecture

## Status: Accepted

## Context

The Three Horizons Portal reference template defines a custom home page with 6 distinct UI sections: HeroBanner, StatCards, HorizonCards, QuickAccess, FeaturedTemplates, and ColorBar. RHDH 1.8 provides a built-in home page plugin (`red-hat-developer-hub.backstage-plugin-dynamic-home-page`) that supports `SearchBar`, `QuickAccessCard`, `CatalogStarredEntitiesCard`, and `FeaturedDocsCard` via `mountPoints`. However, the reference template requires components that do not exist in any supported or community plugin: stat counters pulled from the Catalog API, Three Horizons maturity cards (H1/H2/H3), and a Microsoft 4-color gradient bar.

**Decision Framework result:** No existing dynamic plugin satisfies the requirements. A custom dynamic plugin is needed.

## Decision

Build a **custom RHDH dynamic plugin** (`@internal/plugin-home-three-horizons`) that replaces the default home page via `dynamicRoutes` at path `/`. The plugin is a frontend-only React plugin that consumes Backstage APIs (`catalogApiRef`, `searchApiRef`, `identityApiRef`) and renders all 6 sections.

### Architecture

```
ThreeHorizonsHomePage (dynamicRoutes: path=/)
|
+-- ColorBar                          [Pure CSS, no API]
|
+-- HeroBanner
|   +-- BrandingHeader                [Static text: "Agentic DevOps Platform"]
|   +-- SubtitleText                  [Static text: RHDH description]
|   +-- GlobalSearchBar               [searchApiRef]
|
+-- StatCards (Grid: 4 columns)
|   +-- StatCard[blue]  -- Components [catalogApiRef: kind=Component]
|   +-- StatCard[green] -- APIs       [catalogApiRef: kind=API]
|   +-- StatCard[yellow]-- Templates  [catalogApiRef: kind=Template]
|   +-- StatCard[red]   -- Horizons   [Static: 3]
|
+-- HorizonCards (Grid: 3 columns)
|   +-- HorizonCard[H1] -- Foundation   [Static config + catalogApiRef filter]
|   +-- HorizonCard[H2] -- Enhancement  [Static config + catalogApiRef filter]
|   +-- HorizonCard[H3] -- Innovation   [Static config + catalogApiRef filter]
|
+-- QuickAccess (Grid: 4 columns)
|   +-- QuickLink -- Software Catalog   [Route: /catalog]
|   +-- QuickLink -- API Explorer       [Route: /api-docs]
|   +-- QuickLink -- Create Component   [Route: /create]
|   +-- QuickLink -- Documentation      [Route: /docs]
|
+-- FeaturedTemplates (Grid: 3 columns)
    +-- TemplateCard -- (template 1)    [catalogApiRef: kind=Template, limit=3]
    +-- TemplateCard -- (template 2)
    +-- TemplateCard -- (template 3)
```

### Wiring

```yaml
dynamicPlugins:
  frontend:
    "@internal/plugin-home-three-horizons":
      dynamicRoutes:
        - path: /
          importName: ThreeHorizonsHomePage
          menuItem:
            icon: HomeIcon
            text: Home
```

### Plugin Structure

```
plugins/home-three-horizons/
+-- package.json
+-- tsconfig.json
+-- src/
|   +-- plugin.ts               # createPlugin + createRoutableExtension
|   +-- index.ts                 # barrel export
|   +-- routes.ts                # routeRef definitions
|   +-- theme.ts                 # MS_COLORS constants
|   +-- components/
|   |   +-- ThreeHorizonsHomePage.tsx  # Page container
|   |   +-- ColorBar.tsx              # 4-color gradient bar
|   |   +-- HeroBanner.tsx            # Hero with search
|   |   +-- StatCards.tsx             # 4 stat counters
|   |   +-- HorizonCards.tsx          # H1/H2/H3 maturity cards
|   |   +-- QuickAccess.tsx           # 4 quick-link buttons
|   |   +-- FeaturedTemplates.tsx     # 3 template cards
|   |   +-- StatCard.tsx              # Reusable single stat card
|   |   +-- HorizonCard.tsx           # Reusable single horizon card
|   |   +-- TemplateCard.tsx          # Reusable single template card
|   +-- hooks/
|   |   +-- useEntityCounts.ts        # catalogApiRef entity counts
|   |   +-- useFeaturedTemplates.ts   # catalogApiRef template query
|   |   +-- useCurrentUser.ts         # identityApiRef user info
|   +-- api/
|       +-- types.ts                  # TypeScript interfaces
+-- dev/
|   +-- index.tsx                # Dev harness
+-- dist-dynamic/                # Generated (do not edit)
```

### Data Flow

```
Browser --> ThreeHorizonsHomePage
                |
                +--> useEntityCounts() -----> catalogApiRef.getEntities()
                |                               |-> filter: kind=Component => count
                |                               |-> filter: kind=API       => count
                |                               |-> filter: kind=Template  => count
                |
                +--> useFeaturedTemplates() -> catalogApiRef.getEntities()
                |                               |-> filter: kind=Template, limit=3
                |
                +--> useCurrentUser() -------> identityApiRef.getBackstageIdentity()
                |
                +--> GlobalSearchBar --------> searchApiRef.query()
```

## Alternatives Considered

### Alternative 1: Extend the built-in Dynamic Home Page plugin

Use `red-hat-developer-hub.backstage-plugin-dynamic-home-page` with `mountPoints` to add custom cards.

**Rejected because:**
- The built-in plugin uses a grid-based card system (`SearchBar`, `QuickAccessCard`, `CatalogStarredEntitiesCard`, `FeaturedDocsCard`) that cannot render the HeroBanner, HorizonCards, or ColorBar
- Layout control is limited to grid positioning; the reference design requires a full-page vertical layout with hero section
- StatCards need to display live entity counts from the Catalog API; no built-in mountPoint card supports this

### Alternative 2: Use the Quick Access Card + Custom CSS

Override the home page visually using CSS injections in the theme, combined with Quick Access card configuration.

**Rejected because:**
- CSS-only approach cannot inject new React components or data-fetching logic
- Entity counts require JavaScript API calls that CSS cannot provide
- Fragile; RHDH theme updates could break CSS overrides

### Alternative 3: Fork RHDH and modify the built-in home page

**Rejected because:**
- Violates the Dynamic Plugin philosophy (no rebuild needed)
- Creates maintenance burden on every RHDH version upgrade
- Not supported by Red Hat

## Consequences

### Positive
- Full control over home page UX, matching the reference template pixel-perfect
- Live data from Catalog API (entity counts update dynamically)
- Follows RHDH dynamic plugin architecture (no fork, no rebuild)
- Can be versioned, tested, and deployed independently as an OCI artifact
- Reusable components (StatCard, HorizonCard) for other pages

### Negative
- Custom React code to maintain (~10 components)
- Requires build pipeline for OCI artifact packaging
- Must be regression-tested on RHDH version upgrades
- Adds ~3-5 days of development effort

## Implementation Notes

**For @platform:**
1. Use `scaffold-plugin.sh home-three-horizons ./plugins` to generate boilerplate
2. Implement components following `rhdh-plugin-architecture.instructions.md`
3. Use `makeStyles` with `MS_COLORS` constants for theming
4. Wrap page in `<ErrorBoundary>` from `@backstage/core-components`
5. Export via `npx @janus-idp/cli package export-dynamic-plugin`
6. Push to ACR: `oras push myacr.azurecr.io/plugins/home-three-horizons:1.0.0`

**For @test:**
- Mock `catalogApiRef` with `TestApiProvider`
- Test each component in isolation
- Verify stat counts render correctly with mock data
- Target >80% code coverage

**For @devops:**
- Add to `.github/workflows/build-plugins.yaml`
- Trigger on changes to `plugins/home-three-horizons/**`

**Effort estimate:** 3-5 days (implementation) + 1 day (tests) + 0.5 day (pipeline)
