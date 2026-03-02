import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  Chip,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { SEVERITY_COLORS } from '../api/types';

export interface PushProtectionStats {
  blocked: number;
  bypassed: number;
  bypassReasons: Record<string, number>;
}

interface PushProtectionCardProps {
  stats?: PushProtectionStats;
}

const useStyles = makeStyles({
  card: {
    height: '100%',
    borderTop: `3px solid ${SEVERITY_COLORS.critical}`,
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
    color: SEVERITY_COLORS.critical,
    lineHeight: 1.2,
  },
  badges: {
    display: 'flex',
    gap: 4,
    flexWrap: 'wrap',
    marginTop: 12,
  },
  blocked: {
    fontSize: '0.8rem',
    color: '#666',
    marginTop: 8,
  },
});

/** Card showing push protection bypass events and blocked attempts. */
export const PushProtectionCard = ({ stats }: PushProtectionCardProps) => {
  const classes = useStyles();

  const bypassed = stats?.bypassed ?? 0;
  const blocked = stats?.blocked ?? 0;
  const reasons = stats?.bypassReasons ?? {};

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>Push Protection</Typography>
        <Typography className={classes.value}>{bypassed}</Typography>
        <Typography className={classes.label}>Bypass Events</Typography>
        <Box className={classes.badges}>
          {Object.entries(reasons).map(([reason, count]) => (
            <Chip
              key={reason}
              label={`${reason}: ${count}`}
              size="small"
              style={{
                backgroundColor: `${SEVERITY_COLORS.high}20`,
                color: SEVERITY_COLORS.high,
                fontWeight: 600,
                fontSize: '0.7rem',
              }}
            />
          ))}
        </Box>
        <Typography className={classes.blocked}>
          {blocked} blocked this period
        </Typography>
      </CardContent>
    </Card>
  );
};
