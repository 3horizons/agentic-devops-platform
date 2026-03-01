---
name: generate-dashboard
description: Generate an RHDH engineering intelligence dashboard plugin specification
agent: "agent"
tools:
  - search/codebase
  - edit/editFiles
  - execute/runInTerminal
---

# Generate Engineering Intelligence Dashboard

You are a Platform Engineer creating an RHDH (Red Hat Developer Hub) dashboard plugin for engineering intelligence metrics.

## Inputs Required

Ask the user for:
1. **Dashboard Type**:
   - **A)** DORA Metrics Dashboard
   - **B)** Copilot Analytics Dashboard
   - **C)** Security Posture Dashboard
   - **D)** Developer Productivity Dashboard
   - **E)** Executive Overview (all metrics, summary view)
2. **Scope**: Organization-wide or specific team/repo?
3. **Placement**: RHDH entity page tab or standalone page?

## Generation Steps

### Step 1: Review Existing RHDH Plugin Architecture
Search the codebase for existing plugin patterns:
- `new-features/deploy/dynamic-plugins.yaml`
- `new-features/deploy/app-config-rhdh.yaml`
- ADRs for custom plugin decisions

### Step 2: Design Dashboard Layout
Based on dashboard type, propose:
- **Header**: Title, date range selector, team filter
- **KPI Cards**: 3-5 headline metrics with trend indicators
- **Charts**: Appropriate visualizations per metric
- **Tables**: Detail data with sorting and filtering

### Step 3: Generate Plugin Specification

#### Frontend Plugin (`plugin-engineering-intelligence`)
```typescript
// Tabs for entity pages
export const EntityEngineeringIntelligenceTab = engineeringIntelligencePlugin.provide(
  createRoutableExtension({
    name: 'EntityEngineeringIntelligenceTab',
    component: () => import('./components/DashboardPage').then(m => m.DashboardPage),
    mountPoint: rootRouteRef,
  })
);
```

#### Backend Plugin (`plugin-engineering-intelligence-backend`)
```typescript
// API proxy to GitHub APIs
router.get('/v1/dora/summary', async (req, res) => {
  // Fetch from cache or GitHub API
  // Calculate DORA metrics
  // Return structured response
});
```

### Step 4: Generate Helm Values
Add to dynamic plugins configuration:
```yaml
dynamic:
  plugins:
    - package: '@internal/plugin-engineering-intelligence'
      disabled: false
    - package: '@internal/plugin-engineering-intelligence-backend'
      disabled: false
```

### Step 5: Generate ConfigMap
Dashboard configuration as ConfigMap for runtime updates.

## Output

1. Plugin specification document (markdown)
2. React component skeleton
3. Backend API routes
4. Helm values patch
5. ConfigMap for dashboard data

Ask if the user wants to proceed with `@template-engineer` to create the Golden Path template.
