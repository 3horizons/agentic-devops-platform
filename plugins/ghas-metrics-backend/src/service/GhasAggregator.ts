import fetch from 'node-fetch';
import { LoggerService } from '@backstage/backend-plugin-api';

interface DependabotAlert {
  number: number;
  state: string;
  security_advisory: {
    severity: string;
  };
  dependency: {
    package: {
      ecosystem: string;
      name: string;
    };
  };
}

export interface DependabotSummary {
  total: number;
  by_severity: Record<string, number>;
  by_ecosystem: Record<string, number>;
  repos: { name: string; count: number; critical: number }[];
}

const GITHUB_API = 'https://api.github.com';
const CACHE_TTL_MS = 10 * 60 * 1000; // 10 minutes
const RATE_LIMIT_THRESHOLD = 50; // Pause when remaining requests drop below this

export class GhasAggregator {
  private cache: { data?: DependabotSummary; timestamp: number; org: string } = {
    timestamp: 0,
    org: '',
  };

  constructor(
    private readonly token: string,
    private readonly logger: LoggerService,
  ) {}

  async getDependabotSummary(org: string): Promise<DependabotSummary> {
    if (
      this.cache.data &&
      this.cache.org === org &&
      Date.now() - this.cache.timestamp < CACHE_TTL_MS
    ) {
      return this.cache.data;
    }

    this.logger.info(`Aggregating Dependabot alerts for org: ${org}`);

    const repos = await this.getOrgRepos(org);
    const summary: DependabotSummary = {
      total: 0,
      by_severity: {},
      by_ecosystem: {},
      repos: [],
    };

    for (const repo of repos) {
      try {
        const alerts = await this.getRepoAlerts(org, repo);
        const openAlerts = alerts.filter(a => a.state === 'open');

        if (openAlerts.length === 0) continue;

        let critical = 0;
        openAlerts.forEach(alert => {
          summary.total++;
          const sev = alert.security_advisory?.severity ?? 'unknown';
          summary.by_severity[sev] = (summary.by_severity[sev] ?? 0) + 1;
          const eco = alert.dependency?.package?.ecosystem ?? 'unknown';
          summary.by_ecosystem[eco] = (summary.by_ecosystem[eco] ?? 0) + 1;
          if (sev === 'critical') critical++;
        });

        summary.repos.push({
          name: repo,
          count: openAlerts.length,
          critical,
        });
      } catch {
        // Skip repos without Dependabot access
      }
    }

    summary.repos.sort((a, b) => b.count - a.count);

    this.cache = { data: summary, timestamp: Date.now(), org };
    return summary;
  }

  private async getOrgRepos(org: string): Promise<string[]> {
    const repos: string[] = [];
    let page = 1;

    while (true) {
      const response = await fetch(
        `${GITHUB_API}/orgs/${org}/repos?type=all&per_page=100&page=${page}`,
        { headers: this.headers() },
      );

      if (!response.ok) break;

      const data = (await response.json()) as { name: string }[];
      if (data.length === 0) break;

      repos.push(...data.map(r => r.name));
      page++;
    }

    return repos;
  }

  private async getRepoAlerts(
    org: string,
    repo: string,
  ): Promise<DependabotAlert[]> {
    await this.checkRateLimit();
    const response = await fetch(
      `${GITHUB_API}/repos/${org}/${repo}/dependabot/alerts?state=open&per_page=100`,
      { headers: this.headers() },
    );

    if (!response.ok) return [];
    this.updateRateLimit(response);
    return (await response.json()) as DependabotAlert[];
  }

  private rateLimitRemaining = Infinity;
  private rateLimitReset = 0;

  private updateRateLimit(response: { headers: { get(name: string): string | null } }) {
    const remaining = response.headers.get('x-ratelimit-remaining');
    const reset = response.headers.get('x-ratelimit-reset');
    if (remaining) this.rateLimitRemaining = parseInt(remaining, 10);
    if (reset) this.rateLimitReset = parseInt(reset, 10);
  }

  private async checkRateLimit() {
    if (this.rateLimitRemaining < RATE_LIMIT_THRESHOLD) {
      const waitMs = Math.max(0, (this.rateLimitReset * 1000) - Date.now()) + 1000;
      this.logger.warn(`Rate limit low (${this.rateLimitRemaining} remaining), pausing ${Math.round(waitMs / 1000)}s`);
      await new Promise(resolve => setTimeout(resolve, Math.min(waitMs, 60000)));
      this.rateLimitRemaining = Infinity; // Reset after wait
    }
  }

  private headers() {
    return {
      Authorization: `Bearer ${this.token}`,
      Accept: 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    };
  }

  /** Aggregate push protection bypass stats from secret scanning alerts. */
  async getPushProtectionStats(org: string): Promise<{
    blocked: number;
    bypassed: number;
    bypassReasons: Record<string, number>;
  }> {
    this.logger.info(`Aggregating push protection stats for org: ${org}`);

    const response = await fetch(
      `${GITHUB_API}/orgs/${org}/secret-scanning/alerts?state=open&per_page=100`,
      { headers: this.headers() },
    );

    if (!response.ok) {
      return { blocked: 0, bypassed: 0, bypassReasons: {} };
    }

    const alerts = (await response.json()) as {
      push_protection_bypassed: boolean;
      push_protection_bypassed_by?: { login: string };
    }[];

    let bypassed = 0;
    let blocked = 0;
    const bypassReasons: Record<string, number> = {};

    alerts.forEach(alert => {
      if (alert.push_protection_bypassed) {
        bypassed++;
        const reason = 'manual_bypass';
        bypassReasons[reason] = (bypassReasons[reason] ?? 0) + 1;
      } else {
        blocked++;
      }
    });

    return { blocked, bypassed, bypassReasons };
  }

  /** Get per-repo GHAS feature coverage and open alert counts. */
  async getRepoCoverage(org: string): Promise<{
    name: string;
    codeScanning: boolean;
    secretScanning: boolean;
    dependabot: boolean;
    pushProtection: boolean;
    openAlerts: number;
  }[]> {
    this.logger.info(`Aggregating repo coverage for org: ${org}`);

    const repoNames = await this.getOrgRepos(org);
    const results: {
      name: string;
      codeScanning: boolean;
      secretScanning: boolean;
      dependabot: boolean;
      pushProtection: boolean;
      openAlerts: number;
    }[] = [];

    for (const repo of repoNames) {
      try {
        const repoResponse = await fetch(
          `${GITHUB_API}/repos/${org}/${repo}`,
          { headers: this.headers() },
        );

        if (!repoResponse.ok) continue;

        const repoData = (await repoResponse.json()) as {
          security_and_analysis?: {
            advanced_security?: { status: string };
            secret_scanning?: { status: string };
            secret_scanning_push_protection?: { status: string };
          };
        };

        const sec = repoData.security_and_analysis;
        const codeScanning = sec?.advanced_security?.status === 'enabled';
        const secretScanning = sec?.secret_scanning?.status === 'enabled';
        const pushProtection =
          sec?.secret_scanning_push_protection?.status === 'enabled';

        // Check Dependabot by trying to fetch alerts
        let dependabot = false;
        let openAlerts = 0;
        try {
          const depResp = await fetch(
            `${GITHUB_API}/repos/${org}/${repo}/dependabot/alerts?state=open&per_page=1`,
            { headers: this.headers() },
          );
          dependabot = depResp.ok;
          if (depResp.ok) {
            const depAlerts = (await depResp.json()) as unknown[];
            openAlerts = depAlerts.length;
          }
        } catch {
          // Dependabot not enabled
        }

        results.push({
          name: repo,
          codeScanning,
          secretScanning,
          dependabot,
          pushProtection,
          openAlerts,
        });
      } catch {
        // Skip inaccessible repos
      }
    }

    return results;
  }
}
