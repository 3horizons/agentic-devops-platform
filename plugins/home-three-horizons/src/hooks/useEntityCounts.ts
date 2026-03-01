import { useApi } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { useAsync } from 'react-use';
import { EntityCount, MS_COLORS } from '../api/types';

/**
 * Fetches entity counts from the Backstage Catalog API.
 * Returns counts for Components, APIs, Templates, and a static Horizons count.
 */
export function useEntityCounts(): {
  counts: EntityCount[];
  loading: boolean;
  error?: Error;
} {
  const catalogApi = useApi(catalogApiRef);

  const { value, loading, error } = useAsync(async () => {
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

    return [
      {
        label: 'Components',
        count: components.items.length,
        color: MS_COLORS.blue,
        icon: 'widgets',
        route: '/catalog?filters[kind]=component',
      },
      {
        label: 'APIs',
        count: apis.items.length,
        color: MS_COLORS.green,
        icon: 'extension',
        route: '/catalog?filters[kind]=api',
      },
      {
        label: 'Templates',
        count: templates.items.length,
        color: MS_COLORS.yellow,
        icon: 'description',
        route: '/create',
      },
      {
        label: 'Horizons',
        count: 3,
        color: MS_COLORS.red,
        icon: 'layers',
        route: '#horizons',
      },
    ] as EntityCount[];
  }, [catalogApi]);

  return { counts: value ?? [], loading, error: error as Error | undefined };
}
