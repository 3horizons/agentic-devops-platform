import { GhasAggregator } from '../GhasAggregator';
import { LoggerService } from '@backstage/backend-plugin-api';

jest.mock('node-fetch', () => jest.fn());
import fetch from 'node-fetch';
const mockFetch = fetch as jest.MockedFunction<typeof fetch>;

const mockLogger: LoggerService = {
  info: jest.fn(),
  warn: jest.fn(),
  error: jest.fn(),
  debug: jest.fn(),
  child: jest.fn().mockReturnThis(),
};

describe('GhasAggregator', () => {
  let aggregator: GhasAggregator;

  beforeEach(() => {
    jest.clearAllMocks();
    aggregator = new GhasAggregator('test-token', mockLogger);
  });

  describe('getDependabotSummary', () => {
    it('aggregates dependabot alerts across repos', async () => {
      // First call: get org repos
      mockFetch
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve([{ name: 'repo-a' }, { name: 'repo-b' }]),
        } as any)
        // Empty second page
        .mockResolvedValueOnce({
          ok: true,
          json: () => Promise.resolve([]),
        } as any)
        // repo-a alerts
        .mockResolvedValueOnce({
          ok: true,
          json: () =>
            Promise.resolve([
              {
                number: 1,
                state: 'open',
                security_advisory: { severity: 'critical' },
                dependency: { package: { ecosystem: 'npm', name: 'lodash' } },
              },
              {
                number: 2,
                state: 'open',
                security_advisory: { severity: 'high' },
                dependency: { package: { ecosystem: 'npm', name: 'express' } },
              },
            ]),
        } as any)
        // repo-b alerts
        .mockResolvedValueOnce({
          ok: true,
          json: () =>
            Promise.resolve([
              {
                number: 1,
                state: 'open',
                security_advisory: { severity: 'medium' },
                dependency: { package: { ecosystem: 'pip', name: 'requests' } },
              },
            ]),
        } as any);

      const summary = await aggregator.getDependabotSummary('test-org');

      expect(summary.total).toBe(3);
      expect(summary.by_severity.critical).toBe(1);
      expect(summary.by_severity.high).toBe(1);
      expect(summary.by_severity.medium).toBe(1);
      expect(summary.by_ecosystem.npm).toBe(2);
      expect(summary.by_ecosystem.pip).toBe(1);
      expect(summary.repos).toHaveLength(2);
    });
  });

  describe('getPushProtectionStats', () => {
    it('counts bypassed and blocked alerts', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: true,
        json: () =>
          Promise.resolve([
            { push_protection_bypassed: true },
            { push_protection_bypassed: true },
            { push_protection_bypassed: false },
            { push_protection_bypassed: false },
            { push_protection_bypassed: false },
          ]),
      } as any);

      const stats = await aggregator.getPushProtectionStats('test-org');

      expect(stats.bypassed).toBe(2);
      expect(stats.blocked).toBe(3);
      expect(stats.bypassReasons.manual_bypass).toBe(2);
    });

    it('returns zeros on API failure', async () => {
      mockFetch.mockResolvedValueOnce({
        ok: false,
        status: 403,
      } as any);

      const stats = await aggregator.getPushProtectionStats('test-org');

      expect(stats.bypassed).toBe(0);
      expect(stats.blocked).toBe(0);
    });
  });
});
