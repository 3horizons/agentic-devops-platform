import React from 'react';
import { InfoCard, StatusOK, StatusWarning, StatusError, StatusAborted } from '@backstage/core-components';
import { Grid, Typography, Box, LinearProgress, Table, TableHead, TableRow, TableCell, TableBody } from '@material-ui/core';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, Cell } from 'recharts';
import { useEngineeringIntelligenceApi } from '../hooks/useApi';

const SEVERITY_COLORS: Record<string, string> = {
  critical: '#F25022',
  high: '#FFB900',
  medium: '#00A4EF',
  low: '#7FBA00',
};

export const SecurityPostureTab = () => {
  const { data, loading, error } = useEngineeringIntelligenceApi('/v1/security/posture');

  if (loading) return <LinearProgress />;
  if (error) return <Typography color="error">Error: {error.message}</Typography>;

  const totals = data?.totals || {
    codeScanning: { open: 12, fixed: 87 },
    secretScanning: { open: 2, resolved: 34 },
    dependabot: { open: 28, fixed: 156 },
  };

  const severityData = data?.bySeverity || [
    { severity: 'Critical', code: 2, deps: 5, secrets: 1 },
    { severity: 'High', code: 4, deps: 12, secrets: 1 },
    { severity: 'Medium', code: 6, deps: 8, secrets: 0 },
    { severity: 'Low', code: 0, deps: 3, secrets: 0 },
  ];

  const mttrData = data?.mttr || [
    { severity: 'Critical', days: 3.2, sla: 7 },
    { severity: 'High', days: 12.5, sla: 30 },
    { severity: 'Medium', days: 28.0, sla: 90 },
    { severity: 'Low', days: 45.0, sla: 180 },
  ];

  const totalOpen = totals.codeScanning.open + totals.secretScanning.open + totals.dependabot.open;

  return (
    <Grid container spacing={3}>
      {/* Summary Cards */}
      <Grid item xs={12} sm={6} md={3}>
        <InfoCard title="Code Scanning">
          <Box textAlign="center" p={2}>
            <Typography variant="h3" style={{ color: totals.codeScanning.open > 10 ? '#F25022' : '#7FBA00' }}>
              {totals.codeScanning.open}
            </Typography>
            <Typography variant="body2">open alerts ({totals.codeScanning.fixed} fixed)</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={3}>
        <InfoCard title="Secret Scanning">
          <Box textAlign="center" p={2}>
            <Typography variant="h3" style={{ color: totals.secretScanning.open > 0 ? '#F25022' : '#7FBA00' }}>
              {totals.secretScanning.open}
            </Typography>
            <Typography variant="body2">open alerts ({totals.secretScanning.resolved} resolved)</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={3}>
        <InfoCard title="Dependabot">
          <Box textAlign="center" p={2}>
            <Typography variant="h3" style={{ color: totals.dependabot.open > 20 ? '#FFB900' : '#7FBA00' }}>
              {totals.dependabot.open}
            </Typography>
            <Typography variant="body2">open alerts ({totals.dependabot.fixed} fixed)</Typography>
          </Box>
        </InfoCard>
      </Grid>
      <Grid item xs={12} sm={6} md={3}>
        <InfoCard title="Total Open">
          <Box textAlign="center" p={2}>
            <Typography variant="h3" style={{ color: totalOpen > 30 ? '#F25022' : totalOpen > 10 ? '#FFB900' : '#7FBA00' }}>
              {totalOpen}
            </Typography>
            <Typography variant="body2">across all categories</Typography>
          </Box>
        </InfoCard>
      </Grid>

      {/* Alerts by Severity */}
      <Grid item xs={12} md={7}>
        <InfoCard title="Open Alerts by Severity">
          <Box height={350} p={2}>
            <ResponsiveContainer width="100%" height="100%">
              <BarChart data={severityData}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="severity" />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="code" name="Code Scanning" fill="#00A4EF" />
                <Bar dataKey="deps" name="Dependabot" fill="#FFB900" />
                <Bar dataKey="secrets" name="Secrets" fill="#F25022" />
              </BarChart>
            </ResponsiveContainer>
          </Box>
        </InfoCard>
      </Grid>

      {/* MTTR Table */}
      <Grid item xs={12} md={5}>
        <InfoCard title="MTTR vs SLA (days)">
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Severity</TableCell>
                <TableCell align="right">Avg MTTR</TableCell>
                <TableCell align="right">SLA Target</TableCell>
                <TableCell align="center">Status</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {mttrData.map((row) => (
                <TableRow key={row.severity}>
                  <TableCell>{row.severity}</TableCell>
                  <TableCell align="right">{row.days}d</TableCell>
                  <TableCell align="right">{row.sla}d</TableCell>
                  <TableCell align="center">
                    {row.days <= row.sla ? <StatusOK /> : <StatusError />}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </InfoCard>
      </Grid>
    </Grid>
  );
};
