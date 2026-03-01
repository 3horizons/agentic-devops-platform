import React, { useMemo } from 'react';
import { Card, CardContent, Typography, Grid, Box } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { MS_COLORS, CopilotDayMetrics } from '../api/types';

interface ChatUsageStatsProps {
  metrics: CopilotDayMetrics[];
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
  statCard: {
    textAlign: 'center',
    padding: 16,
    borderRadius: 8,
    backgroundColor: '#F5F5F5',
  },
  statValue: {
    fontSize: '1.5rem',
    fontWeight: 700,
    lineHeight: 1.2,
  },
  statLabel: {
    fontSize: '0.75rem',
    color: '#666',
    marginTop: 4,
  },
});

/** Stats showing IDE Chat, Dotcom Chat, and PR Summaries usage. */
export const ChatUsageStats = ({ metrics }: ChatUsageStatsProps) => {
  const classes = useStyles();

  const stats = useMemo(() => {
    let ideChatTurns = 0;
    let dotcomChatTurns = 0;
    let prSummaries = 0;

    metrics.forEach(day => {
      day.copilot_ide_chat?.editors?.forEach(editor => {
        editor.models?.forEach(model => {
          ideChatTurns += model.total_chat_turns;
        });
      });
      day.copilot_dotcom_chat?.models?.forEach(model => {
        dotcomChatTurns += model.total_chat_turns;
      });
      day.copilot_dotcom_pull_requests?.repositories?.forEach(repo => {
        repo.models?.forEach(model => {
          prSummaries += model.total_pr_summaries_created;
        });
      });
    });

    return { ideChatTurns, dotcomChatTurns, prSummaries };
  }, [metrics]);

  const items = [
    { label: 'IDE Chat Turns', value: stats.ideChatTurns, color: MS_COLORS.blue },
    { label: 'Dotcom Chat Turns', value: stats.dotcomChatTurns, color: MS_COLORS.green },
    { label: 'PR Summaries', value: stats.prSummaries, color: MS_COLORS.yellow },
  ];

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>Chat & PR Usage</Typography>
        <Grid container spacing={2}>
          {items.map(item => (
            <Grid item xs={4} key={item.label}>
              <Box className={classes.statCard}>
                <Typography
                  className={classes.statValue}
                  style={{ color: item.color }}
                >
                  {item.value.toLocaleString()}
                </Typography>
                <Typography className={classes.statLabel}>
                  {item.label}
                </Typography>
              </Box>
            </Grid>
          ))}
        </Grid>
      </CardContent>
    </Card>
  );
};
