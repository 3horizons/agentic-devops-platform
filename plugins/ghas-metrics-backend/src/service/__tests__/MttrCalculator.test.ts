import { MttrCalculator } from '../MttrCalculator';
import { LoggerService } from '@backstage/backend-plugin-api';

// Mock node-fetch
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

describe('MttrCalculator', () => {
  let calculator: MttrCalculator;

  beforeEach(() => {
    jest.clearAllMocks();
    calculator = new MttrCalculator('test-token', mockLogger);
  });

  it('computes MTTR from fixed alerts', async () => {
    const codeAlerts = [
      {
        created_at: '2026-02-01T00:00:00Z',
        fixed_at: '2026-02-01T12:00:00Z',
      },
      {
        created_at: '2026-02-02T00:00:00Z',
        fixed_at: '2026-02-02T24:00:00Z',
      },
    ];

    const secretAlerts = [
      {
        created_at: '2026-02-01T00:00:00Z',
        resolved_at: '2026-02-01T06:00:00Z',
      },
    ];

    mockFetch
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(codeAlerts),
      } as any)
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(secretAlerts),
      } as any);

    const result = await calculator.computeMttr('test-org', '2026-02-01');

    // Code scanning: avg(12h, 24h) = 18h
    expect(result.code_scanning_mttr_hours).toBe(18);
    // Secret scanning: avg(6h) = 6h
    expect(result.secret_scanning_mttr_hours).toBe(6);
    expect(result.trend).toBe('improving'); // avg < 24h
  });

  it('returns zero when API fails', async () => {
    mockFetch.mockResolvedValue({
      ok: false,
      status: 403,
    } as any);

    const result = await calculator.computeMttr('test-org', '');

    expect(result.code_scanning_mttr_hours).toBe(0);
    expect(result.secret_scanning_mttr_hours).toBe(0);
    expect(result.trend).toBe('stable');
  });

  it('classifies degrading trend when MTTR > 72h', async () => {
    const slowAlerts = [
      {
        created_at: '2026-01-01T00:00:00Z',
        fixed_at: '2026-01-05T00:00:00Z', // 96 hours
      },
    ];

    mockFetch
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(slowAlerts),
      } as any)
      .mockResolvedValueOnce({
        ok: true,
        json: () => Promise.resolve(slowAlerts.map(a => ({ ...a, resolved_at: a.fixed_at }))),
      } as any);

    const result = await calculator.computeMttr('test-org', '');

    expect(result.trend).toBe('degrading');
  });
});
