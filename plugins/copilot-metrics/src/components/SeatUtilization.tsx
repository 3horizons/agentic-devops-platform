import React from 'react';
import { Card, CardContent, Typography, Box, LinearProgress } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { MS_COLORS, CopilotBilling } from '../api/types';

interface SeatUtilizationProps {
  billing?: CopilotBilling;
}

const useStyles = makeStyles({
  card: {
    height: '100%',
    borderTop: `3px solid ${MS_COLORS.green}`,
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
    color: MS_COLORS.green,
    lineHeight: 1.2,
  },
  progress: {
    height: 8,
    borderRadius: 4,
    marginTop: 12,
    backgroundColor: '#E0E0E0',
  },
  bar: {
    backgroundColor: MS_COLORS.green,
    borderRadius: 4,
  },
  details: {
    display: 'flex',
    justifyContent: 'space-between',
    marginTop: 8,
    fontSize: '0.8rem',
    color: '#666',
  },
});

/** Card showing seat utilization: assigned vs. active as a gauge. */
export const SeatUtilization = ({ billing }: SeatUtilizationProps) => {
  const classes = useStyles();

  const total = billing?.seat_breakdown.total ?? 0;
  const active = billing?.seat_breakdown.active_this_cycle ?? 0;
  const utilization = total > 0 ? Math.round((active / total) * 100) : 0;

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>Seat Utilization</Typography>
        <Typography className={classes.value}>{utilization}%</Typography>
        <LinearProgress
          variant="determinate"
          value={utilization}
          className={classes.progress}
          classes={{ bar: classes.bar }}
        />
        <Box className={classes.details}>
          <span>{active} active</span>
          <span>{total} assigned</span>
        </Box>
      </CardContent>
    </Card>
  );
};
