import React, { useMemo } from 'react';
import { Card, CardContent, Typography, Grid, Box } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { LineChart, Line, ResponsiveContainer } from 'recharts';
import { MS_COLORS, CopilotDayMetrics, TrendPoint } from '../api/types';

interface TrendSparklinesProps {
  metrics: CopilotDayMetrics[];
}

const useStyles = makeStyles({
  card: {
    textAlign: 'center',
  },
  label: {
    fontSize: '0.7rem',
    color: '#888',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 4,
  },
  value: {
    fontSize: '1.1rem',
    fontWeight: 700,
  },
});

interface SparklineProps {
  title: string;
  data: TrendPoint[];
  color: string;
  currentValue: string;
}

const Sparkline = ({ title, data, color, currentValue }: SparklineProps) => {
  const classes = useStyles();
  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>{title}</Typography>
        <Typography className={classes.value} style={{ color }}>
          {currentValue}
        </Typography>
        <ResponsiveContainer width="100%" height={40}>
          <LineChart data={data}>
            <Line
              type="monotone"
              dataKey="value"
              stroke={color}
              strokeWidth={1.5}
              dot={false}
            />
          </LineChart>
        </ResponsiveContainer>
      </CardContent>
    </Card>
  );
};

/** 4 mini sparkline charts showing 28-day trends. */
export const TrendSparklines = ({ metrics }: TrendSparklinesProps) => {
  const trends = useMemo(() => {
    const activeUsers: TrendPoint[] = [];
    const acceptanceRates: TrendPoint[] = [];
    const chatTurns: TrendPoint[] = [];
    const linesSuggested: TrendPoint[] = [];

    metrics.forEach(day => {
      activeUsers.push({ date: day.date, value: day.total_active_users ?? 0 });

      let totalSuggested = 0;
      let totalAccepted = 0;
      let totalLines = 0;
      let dailyChatTurns = 0;

      day.copilot_ide_code_completions?.editors?.forEach(editor => {
        editor.models?.forEach(model => {
          model.languages?.forEach(lang => {
            totalSuggested += lang.total_code_suggestions;
            totalAccepted += lang.total_code_acceptances;
            totalLines += lang.total_code_lines_suggested;
          });
        });
      });

      day.copilot_ide_chat?.editors?.forEach(editor => {
        editor.models?.forEach(model => {
          dailyChatTurns += model.total_chat_turns;
        });
      });

      const rate =
        totalSuggested > 0
          ? Math.round((totalAccepted / totalSuggested) * 100)
          : 0;

      acceptanceRates.push({ date: day.date, value: rate });
      chatTurns.push({ date: day.date, value: dailyChatTurns });
      linesSuggested.push({ date: day.date, value: totalLines });
    });

    return { activeUsers, acceptanceRates, chatTurns, linesSuggested };
  }, [metrics]);

  const lastActive = trends.activeUsers[trends.activeUsers.length - 1]?.value ?? 0;
  const lastRate = trends.acceptanceRates[trends.acceptanceRates.length - 1]?.value ?? 0;
  const totalChat = trends.chatTurns.reduce((sum, p) => sum + p.value, 0);
  const totalLines = trends.linesSuggested.reduce((sum, p) => sum + p.value, 0);

  return (
    <Box mt={3}>
      <Grid container spacing={2}>
        <Grid item xs={6} sm={3}>
          <Sparkline
            title="Active Users"
            data={trends.activeUsers}
            color={MS_COLORS.blue}
            currentValue={String(lastActive)}
          />
        </Grid>
        <Grid item xs={6} sm={3}>
          <Sparkline
            title="Acceptance Rate"
            data={trends.acceptanceRates}
            color={MS_COLORS.green}
            currentValue={`${lastRate}%`}
          />
        </Grid>
        <Grid item xs={6} sm={3}>
          <Sparkline
            title="Chat Turns"
            data={trends.chatTurns}
            color={MS_COLORS.yellow}
            currentValue={totalChat.toLocaleString()}
          />
        </Grid>
        <Grid item xs={6} sm={3}>
          <Sparkline
            title="Lines Suggested"
            data={trends.linesSuggested}
            color={MS_COLORS.red}
            currentValue={totalLines.toLocaleString()}
          />
        </Grid>
      </Grid>
    </Box>
  );
};
