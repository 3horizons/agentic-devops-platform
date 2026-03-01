import { useState, useEffect } from 'react';
import { useApi, configApiRef } from '@backstage/core-plugin-api';

interface ApiResult<T> {
  data: T | null;
  loading: boolean;
  error: Error | null;
}

/**
 * Hook to fetch data from the Engineering Intelligence backend plugin.
 *
 * Uses the Backstage proxy to call the backend API, which in turn
 * calls GitHub APIs with server-side authentication.
 *
 * @param endpoint - API path relative to /api/engineering-intelligence
 * @param refreshInterval - Auto-refresh interval in ms (default: 5min)
 */
export function useEngineeringIntelligenceApi<T = any>(
  endpoint: string,
  refreshInterval: number = 300000,
): ApiResult<T> {
  const config = useApi(configApiRef);
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  useEffect(() => {
    const backendUrl = config.getString('backend.baseUrl');
    const url = `${backendUrl}/api/proxy/engineering-intelligence${endpoint}`;

    const fetchData = async () => {
      try {
        setLoading(true);
        const response = await fetch(url, {
          headers: {
            'Content-Type': 'application/json',
          },
        });

        if (!response.ok) {
          throw new Error(`API error: ${response.status} ${response.statusText}`);
        }

        const result = await response.json();
        setData(result);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err : new Error('Unknown error'));
      } finally {
        setLoading(false);
      }
    };

    fetchData();

    // Auto-refresh
    const interval = setInterval(fetchData, refreshInterval);
    return () => clearInterval(interval);
  }, [endpoint, config, refreshInterval]);

  return { data, loading, error };
}
