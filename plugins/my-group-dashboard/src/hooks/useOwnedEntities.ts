import { useApi } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { useAsync } from 'react-use';
import { OwnedEntity } from '../api/types';

/**
 * Fetches all entities (Components, APIs, Resources) owned by the given group.
 */
export function useOwnedEntities(groupRef?: string): {
  entities: OwnedEntity[];
  loading: boolean;
  error?: Error;
} {
  const catalogApi = useApi(catalogApiRef);

  const { value, loading, error } = useAsync(async () => {
    if (!groupRef) return [];

    const result = await catalogApi.getEntities({
      filter: {
        'spec.owner': groupRef,
      },
      fields: [
        'kind',
        'metadata.name',
        'metadata.title',
        'spec.type',
        'spec.lifecycle',
        'spec.system',
      ],
    });

    return result.items.map(entity => ({
      name: entity.metadata.name,
      title:
        (entity.metadata.title as string) ?? entity.metadata.name,
      kind: entity.kind,
      type: (entity.spec?.type as string) ?? '',
      lifecycle: (entity.spec?.lifecycle as string) ?? '',
      system: (entity.spec?.system as string) ?? '',
      entityRef: `${entity.kind.toLowerCase()}:default/${entity.metadata.name}`,
    }));
  }, [catalogApi, groupRef]);

  return {
    entities: value ?? [],
    loading,
    error: error as Error | undefined,
  };
}
