import React from 'react';
import { Card, CardContent, Typography, Box } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { MS_COLORS, CopilotDayMetrics } from '../api/types';

interface ActiveUsersCardProps {
  metrics: CopilotDayMetrics[];
}

const useStyles = makeStyles({
  card: {
    height: '100%',
    borderTop: `3px solid ${MS_COLORS.blue}`,
  },
  label: {
    fontSize: '0.75rem',
    color: '#888',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  value: {
    fontSize: '2.5rem',
    fontWeight: 700,
    color: MS_COLORS.blue,
    lineHeight: 1.2,
  },
  subtext: {
    fontSize: '0.85rem',
    color: '#666',
    marginTop: 8,
  },
});

/** Card showing total active and engaged Copilot users. */
export const ActiveUsersCard = ({ metrics }: ActiveUsersCardProps) => {
  const classes = useStyles();

  const latest = metrics[metrics.length - 1];
  const totalActive = latest?.total_active_users ?? 0;
  const totalEngaged = latest?.total_engaged_users ?? 0;
  const engagementRate =
    totalActive > 0 ? Math.round((totalEngaged / totalActive) * 100) : 0;

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>Active Users</Typography>
        <Typography className={classes.value}>{totalActive}</Typography>
        <Box className={classes.subtext}>
          {totalEngaged} engaged ({engagementRate}% engagement rate)
        </Box>
      </CardContent>
    </Card>
  );
};
