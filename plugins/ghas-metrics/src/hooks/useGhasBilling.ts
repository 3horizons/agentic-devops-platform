import { useApi, fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';
import { fetchGhasBilling } from '../api/ghasApiClient';
import { GhasBilling } from '../api/types';

export function useGhasBilling(): {
  billing: GhasBilling | undefined;
  loading: boolean;
  error?: Error;
} {
  const fetchApi = useApi(fetchApiRef);
  const configApi = useApi(configApiRef);
  const org = configApi.getOptionalString('organization.name') ?? '';

  const { value, loading, error } = useAsync(
    () => fetchGhasBilling(fetchApi, org),
    [fetchApi, org],
  );

  return {
    billing: value,
    loading,
    error: error as Error | undefined,
  };
}
