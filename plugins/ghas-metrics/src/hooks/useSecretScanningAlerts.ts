import { useApi, fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { useAsync } from 'react-use';
import { fetchSecretScanningAlerts } from '../api/ghasApiClient';
import { SecretScanningAlert } from '../api/types';

export function useSecretScanningAlerts(): {
  openAlerts: SecretScanningAlert[];
  resolvedAlerts: SecretScanningAlert[];
  loading: boolean;
  error?: Error;
} {
  const fetchApi = useApi(fetchApiRef);
  const configApi = useApi(configApiRef);
  const org = configApi.getOptionalString('organization.name') ?? '';

  const { value, loading, error } = useAsync(async () => {
    const [open, resolved] = await Promise.all([
      fetchSecretScanningAlerts(fetchApi, org, 'open'),
      fetchSecretScanningAlerts(fetchApi, org, 'resolved'),
    ]);
    return { open, resolved };
  }, [fetchApi, org]);

  return {
    openAlerts: value?.open ?? [],
    resolvedAlerts: value?.resolved ?? [],
    loading,
    error: error as Error | undefined,
  };
}
