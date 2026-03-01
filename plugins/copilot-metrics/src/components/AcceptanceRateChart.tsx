import React, { useMemo } from 'react';
import { Card, CardContent, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts';
import { MS_COLORS, CopilotDayMetrics } from '../api/types';

interface AcceptanceRateChartProps {
  metrics: CopilotDayMetrics[];
}

const useStyles = makeStyles({
  card: {
    height: '100%',
    borderTop: `3px solid ${MS_COLORS.yellow}`,
  },
  label: {
    fontSize: '0.75rem',
    color: '#888',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 16,
  },
});

/** Line chart showing code suggestion acceptance rate over time. */
export const AcceptanceRateChart = ({ metrics }: AcceptanceRateChartProps) => {
  const classes = useStyles();

  const chartData = useMemo(() => {
    return metrics.map(day => {
      let totalSuggested = 0;
      let totalAccepted = 0;

      day.copilot_ide_code_completions?.editors?.forEach(editor => {
        editor.models?.forEach(model => {
          model.languages?.forEach(lang => {
            totalSuggested += lang.total_code_suggestions;
            totalAccepted += lang.total_code_acceptances;
          });
        });
      });

      const rate =
        totalSuggested > 0
          ? Math.round((totalAccepted / totalSuggested) * 100)
          : 0;

      return {
        date: day.date.slice(5), // MM-DD
        rate,
        suggested: totalSuggested,
        accepted: totalAccepted,
      };
    });
  }, [metrics]);

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>
          Acceptance Rate Over Time
        </Typography>
        <ResponsiveContainer width="100%" height={200}>
          <LineChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" stroke="#E0E0E0" />
            <XAxis dataKey="date" tick={{ fontSize: 11 }} />
            <YAxis
              tick={{ fontSize: 11 }}
              domain={[0, 100]}
              tickFormatter={v => `${v}%`}
            />
            <Tooltip
              formatter={(value: number) => [`${value}%`, 'Acceptance Rate']}
            />
            <Line
              type="monotone"
              dataKey="rate"
              stroke={MS_COLORS.blue}
              strokeWidth={2}
              dot={false}
              activeDot={{ r: 4 }}
            />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
};
