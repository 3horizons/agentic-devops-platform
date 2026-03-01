import { useApi, fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';
import { fetchCopilotMetrics } from '../api/copilotApiClient';
import { CopilotDayMetrics, DateRange } from '../api/types';

/**
 * Fetches org-level Copilot metrics via the Backstage proxy.
 */
export function useCopilotMetrics(range: DateRange): {
  metrics: CopilotDayMetrics[];
  loading: boolean;
  error?: Error;
} {
  const fetchApi = useApi(fetchApiRef);
  const configApi = useApi(configApiRef);
  const org = configApi.getOptionalString('organization.name') ?? '';

  const { value, loading, error } = useAsync(
    () => fetchCopilotMetrics(fetchApi, org, range),
    [fetchApi, org, range],
  );

  return {
    metrics: value ?? [],
    loading,
    error: error as Error | undefined,
  };
}
