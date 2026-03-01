import { useApi, identityApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';

export interface CurrentUser {
  displayName: string;
  userEntityRef: string;
}

/**
 * Resolves the currently signed-in user via the Backstage Identity API.
 */
export function useCurrentUser(): {
  user: CurrentUser | undefined;
  loading: boolean;
  error?: Error;
} {
  const identityApi = useApi(identityApiRef);

  const { value, loading, error } = useAsync(async () => {
    const identity = await identityApi.getBackstageIdentity();
    const profile = await identityApi.getProfileInfo();

    return {
      displayName: profile.displayName ?? 'Developer',
      userEntityRef: identity.userEntityRef,
    };
  }, [identityApi]);

  return { user: value, loading, error: error as Error | undefined };
}
