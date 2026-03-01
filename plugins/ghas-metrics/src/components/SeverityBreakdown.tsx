import React, { useMemo } from 'react';
import { Card, CardContent, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { SEVERITY_COLORS, CodeScanningAlert, SeverityCount } from '../api/types';

interface SeverityBreakdownProps {
  alerts: CodeScanningAlert[];
}

const useStyles = makeStyles({
  card: {
    height: '100%',
  },
  label: {
    fontSize: '0.75rem',
    color: '#888',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 16,
  },
});

/** Donut chart showing severity distribution of code scanning alerts. */
export const SeverityBreakdown = ({ alerts }: SeverityBreakdownProps) => {
  const classes = useStyles();

  const data: SeverityCount[] = useMemo(() => {
    const counts: Record<string, number> = {};
    alerts.forEach(alert => {
      const sev = alert.rule.severity;
      counts[sev] = (counts[sev] ?? 0) + 1;
    });

    return Object.entries(counts)
      .map(([severity, count]) => ({
        severity,
        count,
        color:
          SEVERITY_COLORS[severity as keyof typeof SEVERITY_COLORS] ?? '#888',
      }))
      .sort((a, b) => {
        const order = ['critical', 'high', 'medium', 'low'];
        return order.indexOf(a.severity) - order.indexOf(b.severity);
      });
  }, [alerts]);

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>
          Severity Distribution
        </Typography>
        <ResponsiveContainer width="100%" height={250}>
          <PieChart>
            <Pie
              data={data}
              dataKey="count"
              nameKey="severity"
              cx="50%"
              cy="50%"
              innerRadius={60}
              outerRadius={90}
              paddingAngle={2}
            >
              {data.map((entry, index) => (
                <Cell key={`cell-${index}`} fill={entry.color} />
              ))}
            </Pie>
            <Tooltip />
            <Legend />
          </PieChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
};
