import React, { useState } from 'react';
import { Grid, Box, Typography, Button, ButtonGroup } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import RefreshIcon from '@material-ui/icons/Refresh';
import {
  Content,
  Header,
  Page,
  Progress,
  ErrorBoundary,
  ResponseErrorPanel,
} from '@backstage/core-components';
import { CodeScanningCard } from './CodeScanningCard';
import { SecretScanningCard } from './SecretScanningCard';
import { DependabotAlertsCard } from './DependabotAlertsCard';
import { GhasCommittersCard } from './GhasCommittersCard';
import { SeverityBreakdown } from './SeverityBreakdown';
import { MttrMetricsComponent } from './MttrMetrics';
import { useCodeScanningAlerts } from '../hooks/useCodeScanningAlerts';
import { useSecretScanningAlerts } from '../hooks/useSecretScanningAlerts';
import { useDependabotSummary } from '../hooks/useDependabotSummary';
import { useGhasBilling } from '../hooks/useGhasBilling';
import { useMttrMetrics } from '../hooks/useMttrMetrics';
import { DateRange, DATE_RANGE_LABELS, MS_COLORS } from '../api/types';

const useStyles = makeStyles({
  content: {
    maxWidth: 1200,
    margin: '0 auto',
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  title: {
    fontSize: '1.5rem',
    fontWeight: 700,
    color: '#333',
  },
  controls: {
    display: 'flex',
    alignItems: 'center',
    gap: 12,
  },
  activeBtn: {
    backgroundColor: MS_COLORS.blue,
    color: '#fff',
    '&:hover': { backgroundColor: '#0078D4' },
  },
});

/**
 * GHAS Metrics Page — organization-wide GitHub Advanced Security analytics.
 *
 * Registered as a dynamic route at `/ghas-metrics`.
 */
export const GhasMetricsPage = () => {
  const classes = useStyles();
  const [range, setRange] = useState<DateRange>('28d');

  const {
    openAlerts: codeOpen,
    fixedAlerts: codeFixed,
    loading: codeLoading,
    error: codeError,
  } = useCodeScanningAlerts();
  const {
    openAlerts: secretOpen,
    resolvedAlerts: secretResolved,
    loading: secretLoading,
  } = useSecretScanningAlerts();
  const { summary: depSummary, loading: depLoading } = useDependabotSummary();
  const { billing, loading: billingLoading } = useGhasBilling();
  const { mttr } = useMttrMetrics(range);

  const loading = codeLoading || secretLoading || depLoading || billingLoading;

  const ranges: DateRange[] = ['7d', '14d', '28d', '90d'];

  return (
    <ErrorBoundary>
      <Page themeId="tool">
        <Header
          title="GHAS Metrics"
          subtitle="GitHub Advanced Security analytics"
        />
        <Content className={classes.content}>
          <Box className={classes.header}>
            <Typography className={classes.title}>
              Security Posture
            </Typography>
            <Box className={classes.controls}>
              <ButtonGroup size="small" variant="outlined">
                {ranges.map(r => (
                  <Button
                    key={r}
                    onClick={() => setRange(r)}
                    className={r === range ? classes.activeBtn : undefined}
                  >
                    {DATE_RANGE_LABELS[r]}
                  </Button>
                ))}
              </ButtonGroup>
              <Button size="small" variant="outlined" startIcon={<RefreshIcon />}>
                Refresh
              </Button>
            </Box>
          </Box>

          {loading && <Progress />}
          {codeError && <ResponseErrorPanel error={codeError} />}

          {!loading && (
            <>
              {/* Summary Row */}
              <Grid container spacing={2}>
                <Grid item xs={12} sm={3}>
                  <CodeScanningCard
                    openAlerts={codeOpen}
                    fixedAlerts={codeFixed}
                  />
                </Grid>
                <Grid item xs={12} sm={3}>
                  <SecretScanningCard
                    openAlerts={secretOpen}
                    resolvedAlerts={secretResolved}
                  />
                </Grid>
                <Grid item xs={12} sm={3}>
                  <DependabotAlertsCard summary={depSummary} />
                </Grid>
                <Grid item xs={12} sm={3}>
                  <GhasCommittersCard billing={billing} />
                </Grid>
              </Grid>

              {/* Charts Row */}
              <Grid container spacing={2} style={{ marginTop: 16 }}>
                <Grid item xs={12} sm={6}>
                  <SeverityBreakdown alerts={codeOpen} />
                </Grid>
                <Grid item xs={12} sm={6}>
                  <MttrMetricsComponent mttr={mttr} />
                </Grid>
              </Grid>
            </>
          )}
        </Content>
      </Page>
    </ErrorBoundary>
  );
};
