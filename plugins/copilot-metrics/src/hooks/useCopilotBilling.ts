import { useApi, fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';
import { fetchCopilotBilling } from '../api/copilotApiClient';
import { CopilotBilling } from '../api/types';

/**
 * Fetches Copilot billing/seat information via the Backstage proxy.
 */
export function useCopilotBilling(): {
  billing: CopilotBilling | undefined;
  loading: boolean;
  error?: Error;
} {
  const fetchApi = useApi(fetchApiRef);
  const configApi = useApi(configApiRef);
  const org = configApi.getOptionalString('organization.name') ?? '';

  const { value, loading, error } = useAsync(
    () => fetchCopilotBilling(fetchApi, org),
    [fetchApi, org],
  );

  return {
    billing: value,
    loading,
    error: error as Error | undefined,
  };
}
