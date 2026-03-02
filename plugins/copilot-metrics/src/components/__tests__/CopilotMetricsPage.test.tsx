import React from 'react';
import { render, screen } from '@testing-library/react';
import { TestApiProvider } from '@backstage/test-utils';
import { fetchApiRef, configApiRef } from '@backstage/core-plugin-api';
import { CopilotMetricsPage } from '../CopilotMetricsPage';

// Mock recharts to avoid canvas issues in tests
jest.mock('recharts', () => ({
  ResponsiveContainer: ({ children }: { children: React.ReactNode }) => <div>{children}</div>,
  LineChart: ({ children }: { children: React.ReactNode }) => <div data-testid="line-chart">{children}</div>,
  Line: () => null,
  XAxis: () => null,
  YAxis: () => null,
  CartesianGrid: () => null,
  Tooltip: () => null,
  Legend: () => null,
  PieChart: ({ children }: { children: React.ReactNode }) => <div data-testid="pie-chart">{children}</div>,
  Pie: () => null,
  Cell: () => null,
  BarChart: ({ children }: { children: React.ReactNode }) => <div data-testid="bar-chart">{children}</div>,
  Bar: () => null,
  AreaChart: ({ children }: { children: React.ReactNode }) => <div data-testid="area-chart">{children}</div>,
  Area: () => null,
}));

const metricsResponse = [
  {
    date: '2026-02-01',
    total_active_users: 42,
    total_engaged_users: 38,
    copilot_ide_code_completions: {
      total_engaged_users: 35,
      languages: [
        { name: 'typescript', total_engaged_users: 20, total_code_suggestions: 500, total_code_acceptances: 150 },
        { name: 'python', total_engaged_users: 15, total_code_suggestions: 300, total_code_acceptances: 100 },
      ],
      editors: [
        { name: 'vscode', total_engaged_users: 30 },
        { name: 'jetbrains', total_engaged_users: 5 },
      ],
    },
    copilot_ide_chat: { total_engaged_users: 25, total_chats: 120 },
    copilot_dotcom_chat: { total_engaged_users: 10, total_chats: 30 },
    copilot_dotcom_pull_requests: { total_engaged_users: 8, total_pr_summaries_created: 15 },
  },
];

const billingResponse = {
  seat_breakdown: { total: 50, active_this_cycle: 42, inactive_this_cycle: 8 },
};

const mockFetchApi = {
  fetch: jest.fn().mockImplementation((url: string) => {
    if (url.includes('/copilot/metrics')) {
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve(metricsResponse),
      });
    }
    if (url.includes('/copilot/billing')) {
      return Promise.resolve({
        ok: true,
        json: () => Promise.resolve(billingResponse),
      });
    }
    return Promise.resolve({ ok: false, status: 404 });
  }),
};

const mockConfigApi = {
  getOptionalString: jest.fn().mockReturnValue('test-org'),
  getString: jest.fn().mockReturnValue('test-org'),
};

describe('CopilotMetricsPage', () => {
  it('renders the page header', async () => {
    render(
      <TestApiProvider
        apis={[
          [fetchApiRef, mockFetchApi],
          [configApiRef, mockConfigApi],
        ]}
      >
        <CopilotMetricsPage />
      </TestApiProvider>,
    );

    expect(await screen.findByText('Copilot Metrics')).toBeInTheDocument();
  });
});
