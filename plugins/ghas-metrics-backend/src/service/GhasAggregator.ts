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
    const response = await fetch(
      `${GITHUB_API}/repos/${org}/${repo}/dependabot/alerts?state=open&per_page=100`,
      { headers: this.headers() },
    );

    if (!response.ok) return [];
    return (await response.json()) as DependabotAlert[];
  }

  private headers() {
    return {
      Authorization: `Bearer ${this.token}`,
      Accept: 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    };
  }
}
