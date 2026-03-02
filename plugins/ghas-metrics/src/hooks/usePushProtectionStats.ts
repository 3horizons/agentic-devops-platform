import { useApi, fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';
import { fetchPushProtectionStats } from '../api/ghasApiClient';
import { PushProtectionStats } from '../components/PushProtectionCard';

export function usePushProtectionStats(): {
  stats: PushProtectionStats | undefined;
  loading: boolean;
  error?: Error;
} {
  const fetchApi = useApi(fetchApiRef);
  const configApi = useApi(configApiRef);
  const org = configApi.getOptionalString('organization.name') ?? '';

  const { value, loading, error } = useAsync(
    () => fetchPushProtectionStats(fetchApi, org),
    [fetchApi, org],
  );

  return {
    stats: value,
    loading,
    error: error as Error | undefined,
  };
}
