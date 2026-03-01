import { useApi } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { useAsync } from 'react-use';
import { FeaturedTemplate } from '../api/types';

/**
 * Fetches featured templates from the Backstage Catalog API.
 * Returns up to `limit` templates sorted by name.
 */
export function useFeaturedTemplates(limit = 6): {
  templates: FeaturedTemplate[];
  loading: boolean;
  error?: Error;
} {
  const catalogApi = useApi(catalogApiRef);

  const { value, loading, error } = useAsync(async () => {
    const result = await catalogApi.getEntities({
      filter: { kind: 'Template' },
      fields: [
        'metadata.name',
        'metadata.title',
        'metadata.description',
        'metadata.tags',
        'spec.type',
      ],
    });

    return result.items.slice(0, limit).map(entity => ({
      name: entity.metadata.name,
      title:
        (entity.metadata.title as string) ??
        entity.metadata.name.replace(/-/g, ' '),
      description:
        (entity.metadata.description as string) ?? 'No description available',
      tags: ((entity.metadata.tags as string[]) ?? []).slice(0, 3),
      type: (entity.spec?.type as string) ?? 'service',
      route: `/create/templates/default/${entity.metadata.name}`,
    }));
  }, [catalogApi, limit]);

  return {
    templates: value ?? [],
    loading,
    error: error as Error | undefined,
  };
}
