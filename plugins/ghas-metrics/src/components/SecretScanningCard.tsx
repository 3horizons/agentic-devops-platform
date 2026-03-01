import React, { useMemo } from 'react';
import { Card, CardContent, Typography, Box, Chip } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { SEVERITY_COLORS, SecretScanningAlert } from '../api/types';

interface SecretScanningCardProps {
  openAlerts: SecretScanningAlert[];
  resolvedAlerts: SecretScanningAlert[];
}

const useStyles = makeStyles({
  card: {
    height: '100%',
    borderTop: `3px solid ${SEVERITY_COLORS.high}`,
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
    color: SEVERITY_COLORS.high,
    lineHeight: 1.2,
  },
  badges: {
    display: 'flex',
    gap: 4,
    flexWrap: 'wrap',
    marginTop: 12,
  },
  resolved: {
    fontSize: '0.8rem',
    color: '#666',
    marginTop: 8,
  },
});

/** Card showing open secret scanning alerts with validity breakdown. */
export const SecretScanningCard = ({
  openAlerts,
  resolvedAlerts,
}: SecretScanningCardProps) => {
  const classes = useStyles();

  const validityCounts = useMemo(() => {
    const counts: Record<string, number> = {};
    openAlerts.forEach(alert => {
      counts[alert.validity] = (counts[alert.validity] ?? 0) + 1;
    });
    return counts;
  }, [openAlerts]);

  const validityColors: Record<string, string> = {
    active: SEVERITY_COLORS.critical,
    inactive: SEVERITY_COLORS.low,
    unknown: SEVERITY_COLORS.medium,
  };

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>Secret Scanning</Typography>
        <Typography className={classes.value}>{openAlerts.length}</Typography>
        <Typography className={classes.label}>Open Secrets</Typography>
        <Box className={classes.badges}>
          {Object.entries(validityCounts).map(([validity, count]) => (
            <Chip
              key={validity}
              label={`${validity}: ${count}`}
              size="small"
              style={{
                backgroundColor: `${validityColors[validity] ?? '#888'}20`,
                color: validityColors[validity] ?? '#888',
                fontWeight: 600,
                fontSize: '0.7rem',
              }}
            />
          ))}
        </Box>
        <Typography className={classes.resolved}>
          {resolvedAlerts.length} resolved
        </Typography>
      </CardContent>
    </Card>
  );
};
