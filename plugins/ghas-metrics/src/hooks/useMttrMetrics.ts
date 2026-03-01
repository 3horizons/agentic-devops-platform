import { useApi, fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';
import { fetchMttrMetrics } from '../api/ghasApiClient';
import { MttrMetrics, DateRange } from '../api/types';

export function useMttrMetrics(range: DateRange): {
  mttr: MttrMetrics | undefined;
  loading: boolean;
  error?: Error;
} {
  const fetchApi = useApi(fetchApiRef);
  const configApi = useApi(configApiRef);
  const org = configApi.getOptionalString('organization.name') ?? '';

  const { value, loading, error } = useAsync(
    () => fetchMttrMetrics(fetchApi, org, range),
    [fetchApi, org, range],
  );

  return {
    mttr: value,
    loading,
    error: error as Error | undefined,
  };
}
