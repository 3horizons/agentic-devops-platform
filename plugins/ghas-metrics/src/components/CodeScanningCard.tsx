import React, { useMemo } from 'react';
import { Card, CardContent, Typography, Box, Chip } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { SEVERITY_COLORS, CodeScanningAlert } from '../api/types';

interface CodeScanningCardProps {
  openAlerts: CodeScanningAlert[];
  fixedAlerts: CodeScanningAlert[];
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
  fixed: {
    fontSize: '0.8rem',
    color: '#666',
    marginTop: 8,
  },
});

/** Card showing open code scanning alerts by severity. */
export const CodeScanningCard = ({ openAlerts, fixedAlerts }: CodeScanningCardProps) => {
  const classes = useStyles();

  const bySeverity = useMemo(() => {
    const counts: Record<string, number> = {};
    openAlerts.forEach(alert => {
      const sev = alert.rule.severity;
      counts[sev] = (counts[sev] ?? 0) + 1;
    });
    return counts;
  }, [openAlerts]);

  const severities = ['critical', 'high', 'medium', 'low'] as const;

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>Code Scanning</Typography>
        <Typography className={classes.value}>{openAlerts.length}</Typography>
        <Typography className={classes.label}>Open Alerts</Typography>
        <Box className={classes.badges}>
          {severities.map(sev =>
            bySeverity[sev] ? (
              <Chip
                key={sev}
                label={`${sev}: ${bySeverity[sev]}`}
                size="small"
                style={{
                  backgroundColor: `${SEVERITY_COLORS[sev]}20`,
                  color: SEVERITY_COLORS[sev],
                  fontWeight: 600,
                  fontSize: '0.7rem',
                }}
              />
            ) : null,
          )}
        </Box>
        <Typography className={classes.fixed}>
          {fixedAlerts.length} fixed this period
        </Typography>
      </CardContent>
    </Card>
  );
};
