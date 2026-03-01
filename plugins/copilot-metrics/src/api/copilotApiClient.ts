import { FetchApi } from '@backstage/core-plugin-api';
import { CopilotDayMetrics, CopilotBilling, DateRange } from './types';

const PROXY_BASE = '/api/proxy/github-copilot';
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes

interface CacheEntry<T> {
  data: T;
  timestamp: number;
}

const cache = new Map<string, CacheEntry<unknown>>();

function getCached<T>(key: string): T | undefined {
  const entry = cache.get(key);
  if (entry && Date.now() - entry.timestamp < CACHE_TTL_MS) {
    return entry.data as T;
  }
  cache.delete(key);
  return undefined;
}

function setCache<T>(key: string, data: T): void {
  cache.set(key, { data, timestamp: Date.now() });
}

function getDateRange(range: DateRange): { since: string; until: string } {
  const now = new Date();
  const until = now.toISOString().split('T')[0];
  const days = parseInt(range, 10);
  const since = new Date(now.getTime() - days * 24 * 60 * 60 * 1000)
    .toISOString()
    .split('T')[0];
  return { since, until };
}

/** Fetch Copilot org-level metrics for a date range */
export async function fetchCopilotMetrics(
  fetchApi: FetchApi,
  org: string,
  range: DateRange,
): Promise<CopilotDayMetrics[]> {
  const cacheKey = `metrics-${org}-${range}`;
  const cached = getCached<CopilotDayMetrics[]>(cacheKey);
  if (cached) return cached;

  const { since, until } = getDateRange(range);
  const response = await fetchApi.fetch(
    `${PROXY_BASE}/orgs/${encodeURIComponent(org)}/copilot/metrics?since=${since}&until=${until}`,
  );

  if (!response.ok) {
    throw new Error(`Copilot Metrics API error: ${response.status} ${response.statusText}`);
  }

  const data: CopilotDayMetrics[] = await response.json();
  setCache(cacheKey, data);
  return data;
}

/** Fetch Copilot billing/seat information */
export async function fetchCopilotBilling(
  fetchApi: FetchApi,
  org: string,
): Promise<CopilotBilling> {
  const cacheKey = `billing-${org}`;
  const cached = getCached<CopilotBilling>(cacheKey);
  if (cached) return cached;

  const response = await fetchApi.fetch(
    `${PROXY_BASE}/orgs/${encodeURIComponent(org)}/copilot/billing`,
  );

  if (!response.ok) {
    throw new Error(`Copilot Billing API error: ${response.status} ${response.statusText}`);
  }

  const data: CopilotBilling = await response.json();
  setCache(cacheKey, data);
  return data;
}

/** Fetch team-level Copilot metrics */
export async function fetchTeamMetrics(
  fetchApi: FetchApi,
  org: string,
  teamSlug: string,
  range: DateRange,
): Promise<CopilotDayMetrics[]> {
  const cacheKey = `team-${org}-${teamSlug}-${range}`;
  const cached = getCached<CopilotDayMetrics[]>(cacheKey);
  if (cached) return cached;

  const { since, until } = getDateRange(range);
  const response = await fetchApi.fetch(
    `${PROXY_BASE}/orgs/${encodeURIComponent(org)}/team/${encodeURIComponent(teamSlug)}/copilot/metrics?since=${since}&until=${until}`,
  );

  if (!response.ok) {
    throw new Error(`Team Metrics API error: ${response.status} ${response.statusText}`);
  }

  const data: CopilotDayMetrics[] = await response.json();
  setCache(cacheKey, data);
  return data;
}
