import { FetchApi } from '@backstage/core-plugin-api';
import {
  CodeScanningAlert,
  SecretScanningAlert,
  DependabotSummary,
  GhasBilling,
  MttrMetrics,
  DateRange,
  RepoCoverage,
} from './types';
import { PushProtectionStats } from '../components/PushProtectionCard';

const PROXY_BASE = '/api/proxy/github-security';
const BACKEND_BASE = '/api/ghas-metrics';
const CACHE_TTL_MS = 5 * 60 * 1000;

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

/** Fetch code scanning alerts (org-level) */
export async function fetchCodeScanningAlerts(
  fetchApi: FetchApi,
  org: string,
  state: 'open' | 'fixed' = 'open',
): Promise<CodeScanningAlert[]> {
  const cacheKey = `code-scanning-${org}-${state}`;
  const cached = getCached<CodeScanningAlert[]>(cacheKey);
  if (cached) return cached;

  const response = await fetchApi.fetch(
    `${PROXY_BASE}/orgs/${encodeURIComponent(org)}/code-scanning/alerts?state=${state}&per_page=100`,
  );

  if (!response.ok) {
    throw new Error(`Code Scanning API error: ${response.status}`);
  }

  const data: CodeScanningAlert[] = await response.json();
  setCache(cacheKey, data);
  return data;
}

/** Fetch secret scanning alerts (org-level) */
export async function fetchSecretScanningAlerts(
  fetchApi: FetchApi,
  org: string,
  state: 'open' | 'resolved' = 'open',
): Promise<SecretScanningAlert[]> {
  const cacheKey = `secret-scanning-${org}-${state}`;
  const cached = getCached<SecretScanningAlert[]>(cacheKey);
  if (cached) return cached;

  const response = await fetchApi.fetch(
    `${PROXY_BASE}/orgs/${encodeURIComponent(org)}/secret-scanning/alerts?state=${state}&per_page=100`,
  );

  if (!response.ok) {
    throw new Error(`Secret Scanning API error: ${response.status}`);
  }

  const data: SecretScanningAlert[] = await response.json();
  setCache(cacheKey, data);
  return data;
}

/** Fetch aggregated Dependabot summary (from backend module) */
export async function fetchDependabotSummary(
  fetchApi: FetchApi,
  org: string,
): Promise<DependabotSummary> {
  const cacheKey = `dependabot-${org}`;
  const cached = getCached<DependabotSummary>(cacheKey);
  if (cached) return cached;

  const response = await fetchApi.fetch(
    `${BACKEND_BASE}/org/${encodeURIComponent(org)}/dependabot`,
  );

  if (!response.ok) {
    throw new Error(`Dependabot API error: ${response.status}`);
  }

  const data: DependabotSummary = await response.json();
  setCache(cacheKey, data);
  return data;
}

/** Fetch GHAS billing information */
export async function fetchGhasBilling(
  fetchApi: FetchApi,
  org: string,
): Promise<GhasBilling> {
  const cacheKey = `ghas-billing-${org}`;
  const cached = getCached<GhasBilling>(cacheKey);
  if (cached) return cached;

  const response = await fetchApi.fetch(
    `${PROXY_BASE}/orgs/${encodeURIComponent(org)}/settings/billing/advanced-security`,
  );

  if (!response.ok) {
    throw new Error(`GHAS Billing API error: ${response.status}`);
  }

  const data: GhasBilling = await response.json();
  setCache(cacheKey, data);
  return data;
}

/** Fetch push protection stats (from backend module) */
export async function fetchPushProtectionStats(
  fetchApi: FetchApi,
  org: string,
): Promise<PushProtectionStats> {
  const cacheKey = `push-protection-${org}`;
  const cached = getCached<PushProtectionStats>(cacheKey);
  if (cached) return cached;

  const response = await fetchApi.fetch(
    `${BACKEND_BASE}/org/${encodeURIComponent(org)}/push-protection`,
  );

  if (!response.ok) {
    throw new Error(`Push Protection API error: ${response.status}`);
  }

  const data: PushProtectionStats = await response.json();
  setCache(cacheKey, data);
  return data;
}

/** Fetch per-repo GHAS coverage (from backend module) */
export async function fetchRepoCoverage(
  fetchApi: FetchApi,
  org: string,
): Promise<RepoCoverage[]> {
  const cacheKey = `repo-coverage-${org}`;
  const cached = getCached<RepoCoverage[]>(cacheKey);
  if (cached) return cached;

  const response = await fetchApi.fetch(
    `${BACKEND_BASE}/org/${encodeURIComponent(org)}/coverage`,
  );

  if (!response.ok) {
    throw new Error(`Repo Coverage API error: ${response.status}`);
  }

  const data: RepoCoverage[] = await response.json();
  setCache(cacheKey, data);
  return data;
}

/** Fetch MTTR metrics (from backend module) */
export async function fetchMttrMetrics(
  fetchApi: FetchApi,
  org: string,
  range: DateRange,
): Promise<MttrMetrics> {
  const days = parseInt(range, 10);
  const since = new Date(Date.now() - days * 24 * 60 * 60 * 1000)
    .toISOString()
    .split('T')[0];

  const response = await fetchApi.fetch(
    `${BACKEND_BASE}/org/${encodeURIComponent(org)}/mttr?since=${since}`,
  );

  if (!response.ok) {
    throw new Error(`MTTR API error: ${response.status}`);
  }

  return response.json();
}
