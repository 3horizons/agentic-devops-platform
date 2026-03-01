import React, { useCallback, useState } from 'react';
import { Grid } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import {
  Content,
  Header,
  Page,
  Progress,
  ErrorBoundary,
  ResponseErrorPanel,
} from '@backstage/core-components';
import { MetricsHeader } from './MetricsHeader';
import { ActiveUsersCard } from './ActiveUsersCard';
import { SeatUtilization } from './SeatUtilization';
import { AcceptanceRateChart } from './AcceptanceRateChart';
import { LanguageBreakdown } from './LanguageBreakdown';
import { IdeUsageChart } from './IdeUsageChart';
import { ChatUsageStats } from './ChatUsageStats';
import { TrendSparklines } from './TrendSparklines';
import { useCopilotMetrics } from '../hooks/useCopilotMetrics';
import { useCopilotBilling } from '../hooks/useCopilotBilling';
import { useDateRange } from '../hooks/useDateRange';

const useStyles = makeStyles({
  content: {
    maxWidth: 1200,
    margin: '0 auto',
  },
});

/**
 * Copilot Metrics Page — organization-wide GitHub Copilot analytics.
 *
 * Registered as a dynamic route at `/copilot-metrics`.
 */
export const CopilotMetricsPage = () => {
  const classes = useStyles();
  const { range, setRange } = useDateRange('28d');
  const { metrics, loading, error } = useCopilotMetrics(range);
  const { billing } = useCopilotBilling();
  const [refreshKey, setRefreshKey] = useState(0);

  const handleRefresh = useCallback(() => {
    setRefreshKey(k => k + 1);
  }, []);

  return (
    <ErrorBoundary>
      <Page themeId="tool">
        <Header
          title="Copilot Metrics"
          subtitle="GitHub Copilot usage analytics"
        />
        <Content className={classes.content}>
          <MetricsHeader
            range={range}
            onRangeChange={setRange}
            onRefresh={handleRefresh}
          />

          {loading && <Progress />}
          {error && <ResponseErrorPanel error={error} />}

          {!loading && !error && (
            <>
              {/* Top Row: Active Users, Seat Utilization, Acceptance Rate */}
              <Grid container spacing={2}>
                <Grid item xs={12} sm={4}>
                  <ActiveUsersCard metrics={metrics} />
                </Grid>
                <Grid item xs={12} sm={4}>
                  <SeatUtilization billing={billing} />
                </Grid>
                <Grid item xs={12} sm={4}>
                  <AcceptanceRateChart metrics={metrics} />
                </Grid>
              </Grid>

              {/* Middle Row: Language Breakdown, IDE Usage */}
              <Grid container spacing={2} style={{ marginTop: 16 }}>
                <Grid item xs={12} sm={6}>
                  <LanguageBreakdown metrics={metrics} />
                </Grid>
                <Grid item xs={12} sm={6}>
                  <IdeUsageChart metrics={metrics} />
                </Grid>
              </Grid>

              {/* Bottom Row: Chat Usage */}
              <Grid container spacing={2} style={{ marginTop: 16 }}>
                <Grid item xs={12}>
                  <ChatUsageStats metrics={metrics} />
                </Grid>
              </Grid>

              {/* Trend Sparklines */}
              <TrendSparklines metrics={metrics} />
            </>
          )}
        </Content>
      </Page>
    </ErrorBoundary>
  );
};
