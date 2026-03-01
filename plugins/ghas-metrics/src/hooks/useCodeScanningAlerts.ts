import { useApi, fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';
import { fetchCodeScanningAlerts } from '../api/ghasApiClient';
import { CodeScanningAlert } from '../api/types';

export function useCodeScanningAlerts(): {
  openAlerts: CodeScanningAlert[];
  fixedAlerts: CodeScanningAlert[];
  loading: boolean;
  error?: Error;
} {
  const fetchApi = useApi(fetchApiRef);
  const configApi = useApi(configApiRef);
  const org = configApi.getOptionalString('organization.name') ?? '';

  const { value, loading, error } = useAsync(async () => {
    const [open, fixed] = await Promise.all([
      fetchCodeScanningAlerts(fetchApi, org, 'open'),
      fetchCodeScanningAlerts(fetchApi, org, 'fixed'),
    ]);
    return { open, fixed };
  }, [fetchApi, org]);

  return {
    openAlerts: value?.open ?? [],
    fixedAlerts: value?.fixed ?? [],
    loading,
    error: error as Error | undefined,
  };
}
