import { useApi } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { useAsync } from 'react-use';
import { TeamMember } from '../api/types';

/**
 * Fetches all User entities that are members of the given group.
 */
export function useGroupMembers(groupRef?: string): {
  members: TeamMember[];
  loading: boolean;
  error?: Error;
} {
  const catalogApi = useApi(catalogApiRef);

  const { value, loading, error } = useAsync(async () => {
    if (!groupRef) return [];

    const result = await catalogApi.getEntities({
      filter: { kind: 'User' },
      fields: [
        'metadata.name',
        'metadata.title',
        'spec.profile',
        'relations',
      ],
    });

    return result.items
      .filter(user =>
        user.relations?.some(
          rel => rel.type === 'memberOf' && rel.targetRef === groupRef,
        ),
      )
      .map(user => ({
        name: user.metadata.name,
        displayName:
          (user.metadata.title as string) ??
          (user.spec?.profile as Record<string, string>)?.displayName ??
          user.metadata.name,
        email:
          (user.spec?.profile as Record<string, string>)?.email ?? '',
        role:
          (user.spec?.profile as Record<string, string>)?.role ?? 'Member',
        avatarUrl:
          (user.spec?.profile as Record<string, string>)?.picture,
        entityRef: `user:default/${user.metadata.name}`,
      }));
  }, [catalogApi, groupRef]);

  return {
    members: value ?? [],
    loading,
    error: error as Error | undefined,
  };
}
