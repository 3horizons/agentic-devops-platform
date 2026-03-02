import { useApi, fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';
import { fetchRepoCoverage } from '../api/ghasApiClient';
import { RepoCoverage } from '../api/types';

export function useRepoCoverage(): {
  repos: RepoCoverage[];
  loading: boolean;
  error?: Error;
} {
  const fetchApi = useApi(fetchApiRef);
  const configApi = useApi(configApiRef);
  const org = configApi.getOptionalString('organization.name') ?? '';

  const { value, loading, error } = useAsync(
    () => fetchRepoCoverage(fetchApi, org),
    [fetchApi, org],
  );

  return {
    repos: value ?? [],
    loading,
    error: error as Error | undefined,
  };
}
