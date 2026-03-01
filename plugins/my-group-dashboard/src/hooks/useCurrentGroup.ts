import { useApi, identityApiRef } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { useAsync } from 'react-use';
import { GroupInfo } from '../api/types';

/**
 * Resolves the current user's primary group from Identity + Catalog APIs.
 * Returns the first group found in ownershipEntityRefs.
 */
export function useCurrentGroup(): {
  group: GroupInfo | undefined;
  loading: boolean;
  error?: Error;
} {
  const identityApi = useApi(identityApiRef);
  const catalogApi = useApi(catalogApiRef);

  const { value, loading, error } = useAsync(async () => {
    const identity = await identityApi.getBackstageIdentity();
    const groupRef = identity.ownershipEntityRefs.find(ref =>
      ref.startsWith('group:'),
    );

    if (!groupRef) return undefined;

    const entity = await catalogApi.getEntityByRef(groupRef);
    if (!entity) return undefined;

    return {
      name: entity.metadata.name,
      displayName:
        (entity.metadata.title as string) ?? entity.metadata.name,
      description:
        (entity.metadata.description as string) ?? '',
      entityRef: groupRef,
    } as GroupInfo;
  }, [identityApi, catalogApi]);

  return { group: value, loading, error: error as Error | undefined };
}
