import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  LinearProgress,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { MS_COLORS, GhasBilling } from '../api/types';

interface GhasCommittersCardProps {
  billing?: GhasBilling;
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
  progress: {
    height: 8,
    borderRadius: 4,
    marginTop: 12,
    backgroundColor: '#E0E0E0',
  },
  bar: {
    backgroundColor: MS_COLORS.blue,
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

/** Card showing GHAS committer seat utilization as a gauge. */
export const GhasCommittersCard = ({ billing }: GhasCommittersCardProps) => {
  const classes = useStyles();

  const active = billing?.total_advanced_security_committers ?? 0;
  const max = billing?.maximum_advanced_security_committers ?? 0;
  const utilization = max > 0 ? Math.round((active / max) * 100) : 0;

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>GHAS Committers</Typography>
        <Typography className={classes.value}>{active}</Typography>
        <Typography className={classes.label}>Active</Typography>
        <LinearProgress
          variant="determinate"
          value={Math.min(utilization, 100)}
          className={classes.progress}
          classes={{ bar: classes.bar }}
        />
        <Box className={classes.details}>
          <span>{active} active</span>
          <span>{max} purchased</span>
        </Box>
      </CardContent>
    </Card>
  );
};
