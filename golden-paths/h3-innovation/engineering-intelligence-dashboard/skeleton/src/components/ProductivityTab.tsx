import React from 'react';
import { InfoCard } from '@backstage/core-components';
import { Grid, Typography, Box, LinearProgress } from '@material-ui/core';
import {
  BarChart, Bar, LineChart, Line, XAxis, YAxis, CartesianGrid,
  Tooltip, Legend, ResponsiveContainer, Cell,
} from 'recharts';
import { useEngineeringIntelligenceApi } from '../hooks/useApi';

const COLORS = {
  blue: '#00A4EF',
  green: '#7FBA00',
  yellow: '#FFB900',
  red: '#F25022',
};

export const ProductivityTab = () => {
  const { data, loading, error } = useEngineeringIntelligenceApi('/v1/productivity/summary');

  if (loading) return <LinearProgress />;
  if (error) return <Typography color="error">Error: {error.message}</Typography>;

  const summary = data?.summary || {
    avgCycleTime: 4.2,
    avgReviewTime: 2.1,
    prsPerWeek: 28,
    activeContributors: 15,
  };

  const teamData = data?.teams || [
    { team: 'Platform', prs: 12, cycleTime: 3.5, reviewTime: 1.8 },
    { team: 'Backend', prs: 8, cycleTime: 5.2, reviewTime: 2.5 },
    { team: 'Frontend', prs: 6, cycleTime: 4.1, reviewTime: 2.0 },
    { team: 'SRE', prs: 2, cycleTime: 2.8, reviewTime: 1.2 },
  ];

  const weeklyTrend = data?.weeklyTrend || [];

  return (
    <Grid container spacing={3}>
      {/* KPI Cards */}
      <Grid item xs={12} sm={6} md={3}>
        <InfoCard title="Avg PR Cycle Time">
          <Box textAlign="center" p={2}>
            <Typography variant="h3" style={{ color: COLORS.blue }}>{summary.avgCycleTime}h</Typography>
            <Typography variant="body2" color="textSecondary">open → merge</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={3}>
        <InfoCard title="Avg Review Time">
          <Box textAlign="center" p={2}>
            <Typography variant="h3" style={{ color: COLORS.green }}>{summary.avgReviewTime}h</Typography>
            <Typography variant="body2" color="textSecondary">open → first review</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={3}>
        <InfoCard title="PRs / Week">
          <Box textAlign="center" p={2}>
            <Typography variant="h3" style={{ color: COLORS.yellow }}>{summary.prsPerWeek}</Typography>
            <Typography variant="body2" color="textSecondary">merged</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={3}>
        <InfoCard title="Active Contributors">
          <Box textAlign="center" p={2}>
            <Typography variant="h3" style={{ color: COLORS.red }}>{summary.activeContributors}</Typography>
            <Typography variant="body2" color="textSecondary">last 30 days</Typography>
          </Box>
        </InfoCard>
      </Grid>

      {/* Team Comparison */}
      <Grid item xs={12}>
        <InfoCard title="Team Productivity Comparison">
          <Box height={350} p={2}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={teamData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="team" />
                <YAxis yAxisId="left" orientation="left" />
                <YAxis yAxisId="right" orientation="right" />
                <Tooltip />
                <Legend />
                <Bar yAxisId="left" dataKey="prs" name="PRs/week" fill={COLORS.blue} />
                <Bar yAxisId="right" dataKey="cycleTime" name="Cycle Time (h)" fill={COLORS.yellow} />
                <Bar yAxisId="right" dataKey="reviewTime" name="Review Time (h)" fill={COLORS.green} />
              </BarChart>
            </ResponsiveContainer>
          </Box>
        </InfoCard>
      </Grid>
    </Grid>
  );
};
