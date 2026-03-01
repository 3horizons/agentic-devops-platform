import React from 'react';
import { InfoCard, StatusOK, StatusWarning, StatusError } from '@backstage/core-components';
import { Grid, Typography, Box, LinearProgress, Chip } from '@material-ui/core';
import {
  LineChart, Line, BarChart, Bar, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ResponsiveContainer, Cell,
} from 'recharts';
import { useEngineeringIntelligenceApi } from '../hooks/useApi';

// Microsoft brand colors
const COLORS = {
  blue: '#00A4EF',
  green: '#7FBA00',
  yellow: '#FFB900',
  red: '#F25022',
};

const CLASSIFICATION_COLORS: Record<string, string> = {
  Elite: COLORS.green,
  High: COLORS.blue,
  Medium: COLORS.yellow,
  Low: COLORS.red,
};

interface DoraMetric {
  name: string;
  value: string;
  classification: string;
  trend: string;
}

const MetricCard = ({ metric }: { metric: DoraMetric }) => (
  <InfoCard title={metric.name}>
    <Box textAlign="center" p={2}>
      <Typography variant="h3">{metric.value}</Typography>
      <Chip
        label={metric.classification}
        style={{
          backgroundColor: CLASSIFICATION_COLORS[metric.classification] || COLORS.blue,
          color: '#fff',
          marginTop: 8,
        }}
      />
      <Typography variant="body2" color="textSecondary" style={{ marginTop: 8 }}>
        {metric.trend}
      </Typography>
    </Box>
  </InfoCard>
);

export const DoraMetricsTab = () => {
  const { data, loading, error } = useEngineeringIntelligenceApi('/v1/dora/summary');

  if (loading) return <LinearProgress />;
  if (error) return <Typography color="error">Error loading DORA metrics: {error.message}</Typography>;

  // Mock data for skeleton — replaced by real API data
  const metrics: DoraMetric[] = data?.metrics || [
    { name: 'Deployment Frequency', value: '4.2/week', classification: 'High', trend: '+12% MoM' },
    { name: 'Lead Time for Changes', value: '3.8 hours', classification: 'Elite', trend: '-18% MoM' },
    { name: 'Mean Time to Recovery', value: '2.1 hours', classification: 'High', trend: '-5% MoM' },
    { name: 'Change Failure Rate', value: '4.5%', classification: 'Elite', trend: '-2.1pp MoM' },
  ];

  const trendData = data?.trend || [];

  return (
    <Grid container spacing={3}>
      {metrics.map((metric) => (
        <Grid item xs={12} sm={6} md={3} key={metric.name}>
          <MetricCard metric={metric} />
        </Grid>
      ))}

      <Grid item xs={12}>
        <InfoCard title="DORA Metrics Trend (12 weeks)">
          <Box height={400} p={2}>
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={trendData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="week" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Line type="monotone" dataKey="deployFreq" stroke={COLORS.blue} name="Deploy Freq" />
                <Line type="monotone" dataKey="leadTime" stroke={COLORS.green} name="Lead Time (h)" />
                <Line type="monotone" dataKey="mttr" stroke={COLORS.yellow} name="MTTR (h)" />
                <Line type="monotone" dataKey="cfr" stroke={COLORS.red} name="CFR (%)" />
              </LineChart>
            </ResponsiveContainer>
          </Box>
        </InfoCard>
      </Grid>
    </Grid>
  );
};
