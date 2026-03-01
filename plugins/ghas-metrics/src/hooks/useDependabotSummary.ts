import { useApi, fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';
import { fetchDependabotSummary } from '../api/ghasApiClient';
import { DependabotSummary } from '../api/types';

export function useDependabotSummary(): {
  summary: DependabotSummary | undefined;
  loading: boolean;
  error?: Error;
} {
  const fetchApi = useApi(fetchApiRef);
  const configApi = useApi(configApiRef);
  const org = configApi.getOptionalString('organization.name') ?? '';

  const { value, loading, error } = useAsync(
    () => fetchDependabotSummary(fetchApi, org),
    [fetchApi, org],
  );

  return {
    summary: value,
    loading,
    error: error as Error | undefined,
  };
}
