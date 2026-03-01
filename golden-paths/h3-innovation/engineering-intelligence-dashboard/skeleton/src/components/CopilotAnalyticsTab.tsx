import React from 'react';
import { InfoCard } from '@backstage/core-components';
import { Grid, Typography, Box, LinearProgress } from '@material-ui/core';
import {
  BarChart, Bar, LineChart, Line, PieChart, Pie, Cell,
  XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
} from 'recharts';
import { useEngineeringIntelligenceApi } from '../hooks/useApi';

const COLORS = {
  blue: '#00A4EF',
  green: '#7FBA00',
  yellow: '#FFB900',
  red: '#F25022',
};

const PIE_COLORS = [COLORS.blue, COLORS.green, COLORS.yellow, COLORS.red, '#737373', '#00188F'];

export const CopilotAnalyticsTab = () => {
  const { data, loading, error } = useEngineeringIntelligenceApi('/v1/copilot/adoption');

  if (loading) return <LinearProgress />;
  if (error) return <Typography color="error">Error: {error.message}</Typography>;

  const summary = data?.summary || {
    activeUsers: 142,
    acceptanceRate: 31.5,
    totalSuggestions: 28500,
    linesAccepted: 12400,
    chatSessions: 3200,
  };

  const languageData = data?.languages || [
    { language: 'TypeScript', suggestions: 8500, acceptance: 34 },
    { language: 'Python', suggestions: 6200, acceptance: 29 },
    { language: 'HCL', suggestions: 4100, acceptance: 38 },
    { language: 'Go', suggestions: 3800, acceptance: 27 },
    { language: 'YAML', suggestions: 2900, acceptance: 42 },
    { language: 'Bash', suggestions: 1800, acceptance: 25 },
  ];

  const trendData = data?.trend || [];

  return (
    <Grid container spacing={3}>
      {/* KPI Cards */}
      <Grid item xs={12} sm={6} md={2}>
        <InfoCard title="Active Users">
          <Box textAlign="center" p={1}>
            <Typography variant="h3" style={{ color: COLORS.blue }}>{summary.activeUsers}</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={2}>
        <InfoCard title="Acceptance Rate">
          <Box textAlign="center" p={1}>
            <Typography variant="h3" style={{ color: COLORS.green }}>{summary.acceptanceRate}%</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={2}>
        <InfoCard title="Suggestions">
          <Box textAlign="center" p={1}>
            <Typography variant="h3" style={{ color: COLORS.yellow }}>{(summary.totalSuggestions / 1000).toFixed(1)}K</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={2}>
        <InfoCard title="Lines Accepted">
          <Box textAlign="center" p={1}>
            <Typography variant="h3" style={{ color: COLORS.red }}>{(summary.linesAccepted / 1000).toFixed(1)}K</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={2}>
        <InfoCard title="Chat Sessions">
          <Box textAlign="center" p={1}>
            <Typography variant="h3" style={{ color: COLORS.blue }}>{(summary.chatSessions / 1000).toFixed(1)}K</Typography>
          </Box>
        </InfoCard>
      </Grid>

      {/* Language Breakdown */}
      <Grid item xs={12} md={6}>
        <InfoCard title="Acceptance Rate by Language">
          <Box height={350} p={2}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={languageData} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" domain={[0, 50]} unit="%" />
                <YAxis type="category" dataKey="language" width={100} />
                <Tooltip />
                <Bar dataKey="acceptance" name="Acceptance Rate (%)">
                  {languageData.map((_, i) => (
                    <Cell key={`cell-${i}`} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </Box>
        </InfoCard>
      </Grid>

      {/* Suggestions by Language */}
      <Grid item xs={12} md={6}>
        <InfoCard title="Suggestions by Language">
          <Box height={350} p={2}>
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={languageData}
                  dataKey="suggestions"
                  nameKey="language"
                  cx="50%"
                  cy="50%"
                  outerRadius={120}
                  label={({ language, suggestions }) => `${language}: ${suggestions}`}
                >
                  {languageData.map((_, i) => (
                    <Cell key={`cell-${i}`} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </Box>
        </InfoCard>
      </Grid>
    </Grid>
  );
};
