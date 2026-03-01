# Backstage API Catalog — Reference for Custom Plugins

This document catalogs all Backstage APIs available for consumption in RHDH 1.8 custom frontend plugins via `useApi()`.

## Core APIs (always available)

| API Ref | Package | Purpose |
|---------|---------|---------|
| `configApiRef` | `@backstage/core-plugin-api` | Read `app-config.yaml` values |
| `identityApiRef` | `@backstage/core-plugin-api` | Get current user identity (name, email, groups) |
| `fetchApiRef` | `@backstage/core-plugin-api` | Make authenticated HTTP requests to backend |
| `discoveryApiRef` | `@backstage/core-plugin-api` | Discover backend plugin base URLs |
| `errorApiRef` | `@backstage/core-plugin-api` | Report errors to the Backstage error boundary |
| `alertApiRef` | `@backstage/core-plugin-api` | Show toast/snackbar notifications |
| `storageApiRef` | `@backstage/core-plugin-api` | Browser-local key-value storage |
| `analyticsApiRef` | `@backstage/core-plugin-api` | Track user events for analytics |

## Catalog APIs

| API Ref | Package | Purpose |
|---------|---------|---------|
| `catalogApiRef` | `@backstage/plugin-catalog-react` | CRUD operations on catalog entities |
| `starredEntitiesApiRef` | `@backstage/plugin-catalog-react` | User's starred/bookmarked entities |
| `entityPresentationApiRef` | `@backstage/plugin-catalog-react` | Entity display names and descriptions |

### catalogApiRef — Key Methods

```typescript
const catalogApi = useApi(catalogApiRef);

// Get all entities of a specific kind
const { items } = await catalogApi.getEntities({
  filter: { kind: 'Component' }
});

// Get entities by owner
const { items } = await catalogApi.getEntities({
  filter: {
    kind: 'Component',
    'spec.owner': 'team-platform'
  }
});

// Get a single entity by ref
const entity = await catalogApi.getEntityByRef('component:default/auth-service');

// Count entities (use getEntities and count items)
const { items } = await catalogApi.getEntities({ filter: { kind: 'API' } });
const apiCount = items.length;

// Get entity facets (unique values for a field)
const { facets } = await catalogApi.getEntityFacets({
  facets: ['kind', 'spec.type', 'spec.lifecycle']
});
```

## Scaffolder APIs

| API Ref | Package | Purpose |
|---------|---------|---------|
| `scaffolderApiRef` | `@backstage/plugin-scaffolder-react` | List and execute templates |

### scaffolderApiRef — Key Methods

```typescript
const scaffolderApi = useApi(scaffolderApiRef);

// List all available templates
const { items } = await scaffolderApi.listTasks();

// Get templates from catalog
const { items: templates } = await catalogApi.getEntities({
  filter: { kind: 'Template' }
});

// Execute a template
const { taskId } = await scaffolderApi.scaffold({
  templateRef: 'template:default/nodejs-microservice',
  values: {
    name: 'my-service',
    owner: 'team-backend',
    description: 'My new microservice'
  }
});
```

## Search APIs

| API Ref | Package | Purpose |
|---------|---------|---------|
| `searchApiRef` | `@backstage/plugin-search-react` | Full-text search |

```typescript
const searchApi = useApi(searchApiRef);

const { results } = await searchApi.query({
  term: 'auth service',
  types: ['software-catalog'],
  filters: { kind: 'Component' }
});
```

## TechDocs APIs

| API Ref | Package | Purpose |
|---------|---------|---------|
| `techdocsStorageApiRef` | `@backstage/plugin-techdocs` | TechDocs content access |

## Kubernetes APIs

| API Ref | Package | Purpose |
|---------|---------|---------|
| `kubernetesApiRef` | `@backstage/plugin-kubernetes` | K8s cluster data |
| `kubernetesProxyApiRef` | `@backstage/plugin-kubernetes` | Proxy requests to K8s API |

## Permission APIs

| API Ref | Package | Purpose |
|---------|---------|---------|
| `permissionApiRef` | `@backstage/plugin-permission-react` | Check user permissions |

```typescript
const permissionApi = useApi(permissionApiRef);

const { allowed } = await permissionApi.authorize({
  permission: catalogEntityCreatePermission
});
```

## Using APIs in React Components

```typescript
import React from 'react';
import { useApi } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';

export const StatCards = () => {
  const catalogApi = useApi(catalogApiRef);
  const [stats, setStats] = React.useState({ components: 0, apis: 0 });

  React.useEffect(() => {
    Promise.all([
      catalogApi.getEntities({ filter: { kind: 'Component' } }),
      catalogApi.getEntities({ filter: { kind: 'API' } }),
    ]).then(([components, apis]) => {
      setStats({
        components: components.items.length,
        apis: apis.items.length,
      });
    });
  }, [catalogApi]);

  return (
    <Grid container spacing={2}>
      <Grid item xs={3}>
        <StatCard value={stats.components} label="Components" color="#00A4EF" />
      </Grid>
      <Grid item xs={3}>
        <StatCard value={stats.apis} label="APIs" color="#7FBA00" />
      </Grid>
    </Grid>
  );
};
```

## API Discovery Pattern

When a custom plugin needs to call a backend endpoint:

```typescript
import { useApi, discoveryApiRef, fetchApiRef } from '@backstage/core-plugin-api';

export function useCustomBackend() {
  const discoveryApi = useApi(discoveryApiRef);
  const fetchApi = useApi(fetchApiRef);

  async function getMetrics() {
    const baseUrl = await discoveryApi.getBaseUrl('custom-metrics');
    const response = await fetchApi.fetch(`${baseUrl}/api/metrics`);
    return response.json();
  }

  return { getMetrics };
}
```
