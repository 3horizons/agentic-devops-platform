import React, { useMemo } from 'react';
import { Card, CardContent, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend } from 'recharts';
import { MS_COLORS, CopilotDayMetrics } from '../api/types';

interface IdeUsageChartProps {
  metrics: CopilotDayMetrics[];
}

const CHART_COLORS = [MS_COLORS.blue, MS_COLORS.green, MS_COLORS.yellow, MS_COLORS.red, '#888'];

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

/** Donut chart showing Copilot usage by IDE. */
export const IdeUsageChart = ({ metrics }: IdeUsageChartProps) => {
  const classes = useStyles();

  const editorData = useMemo(() => {
    const editorMap = new Map<string, number>();

    metrics.forEach(day => {
      day.copilot_ide_code_completions?.editors?.forEach(editor => {
        const count = editorMap.get(editor.name) ?? 0;
        editorMap.set(editor.name, count + editor.total_engaged_users);
      });
    });

    return Array.from(editorMap.entries())
      .map(([name, users]) => ({ name, users }))
      .sort((a, b) => b.users - a.users);
  }, [metrics]);

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>IDE Usage</Typography>
        <ResponsiveContainer width="100%" height={250}>
          <PieChart>
            <Pie
              data={editorData}
              dataKey="users"
              nameKey="name"
              cx="50%"
              cy="50%"
              innerRadius={60}
              outerRadius={90}
              paddingAngle={2}
            >
              {editorData.map((_entry, index) => (
                <Cell
                  key={`cell-${index}`}
                  fill={CHART_COLORS[index % CHART_COLORS.length]}
                />
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
