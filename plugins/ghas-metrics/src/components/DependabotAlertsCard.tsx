import React from 'react';
import { Card, CardContent, Typography, Box, Chip } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { SEVERITY_COLORS, DependabotSummary } from '../api/types';

interface DependabotAlertsCardProps {
  summary?: DependabotSummary;
}

const useStyles = makeStyles({
  card: {
    height: '100%',
    borderTop: `3px solid ${SEVERITY_COLORS.medium}`,
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
    color: SEVERITY_COLORS.medium,
    lineHeight: 1.2,
  },
  badges: {
    display: 'flex',
    gap: 4,
    flexWrap: 'wrap',
    marginTop: 12,
  },
  ecosystems: {
    fontSize: '0.8rem',
    color: '#666',
    marginTop: 8,
  },
});

/** Card showing aggregated Dependabot vulnerability summary by ecosystem. */
export const DependabotAlertsCard = ({ summary }: DependabotAlertsCardProps) => {
  const classes = useStyles();

  const total = summary?.total ?? 0;
  const critical = summary?.by_severity?.critical ?? 0;
  const ecosystems = summary?.by_ecosystem ?? {};

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>Dependabot</Typography>
        <Typography className={classes.value}>{total}</Typography>
        <Typography className={classes.label}>Vulnerabilities</Typography>
        {critical > 0 && (
          <Box className={classes.badges}>
            <Chip
              label={`${critical} critical`}
              size="small"
              style={{
                backgroundColor: `${SEVERITY_COLORS.critical}20`,
                color: SEVERITY_COLORS.critical,
                fontWeight: 600,
                fontSize: '0.7rem',
              }}
            />
          </Box>
        )}
        <Typography className={classes.ecosystems}>
          {Object.entries(ecosystems)
            .sort(([, a], [, b]) => b - a)
            .slice(0, 3)
            .map(([eco, count]) => `${eco}: ${count}`)
            .join(' | ')}
        </Typography>
      </CardContent>
    </Card>
  );
};
