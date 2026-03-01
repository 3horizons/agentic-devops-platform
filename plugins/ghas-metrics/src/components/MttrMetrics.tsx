import React from 'react';
import { Card, CardContent, Typography, Grid, Box, Chip } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import TrendingDownIcon from '@material-ui/icons/TrendingDown';
import TrendingUpIcon from '@material-ui/icons/TrendingUp';
import TrendingFlatIcon from '@material-ui/icons/TrendingFlat';
import { MS_COLORS, MttrMetrics as MttrData } from '../api/types';

interface MttrMetricsProps {
  mttr?: MttrData;
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
  statBox: {
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
    fontSize: '0.7rem',
    color: '#666',
    marginTop: 4,
  },
  trendChip: {
    marginTop: 12,
  },
});

function formatHours(hours: number): string {
  if (hours < 24) return `${Math.round(hours)}h`;
  const days = Math.round(hours / 24);
  return `${days}d`;
}

/** Cards showing Mean Time To Remediate per alert type with trend indicator. */
export const MttrMetricsComponent = ({ mttr }: MttrMetricsProps) => {
  const classes = useStyles();

  const TrendIcon =
    mttr?.trend === 'improving'
      ? TrendingDownIcon
      : mttr?.trend === 'degrading'
        ? TrendingUpIcon
        : TrendingFlatIcon;

  const trendColor =
    mttr?.trend === 'improving'
      ? MS_COLORS.green
      : mttr?.trend === 'degrading'
        ? MS_COLORS.red
        : '#888';

  const items = [
    {
      label: 'Code Scanning',
      value: mttr?.code_scanning_mttr_hours ?? 0,
      color: MS_COLORS.blue,
    },
    {
      label: 'Secret Scanning',
      value: mttr?.secret_scanning_mttr_hours ?? 0,
      color: MS_COLORS.yellow,
    },
    {
      label: 'Dependabot',
      value: mttr?.dependabot_mttr_hours ?? 0,
      color: MS_COLORS.green,
    },
  ];

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>
          Mean Time To Remediate
        </Typography>
        <Grid container spacing={2}>
          {items.map(item => (
            <Grid item xs={4} key={item.label}>
              <Box className={classes.statBox}>
                <Typography
                  className={classes.statValue}
                  style={{ color: item.color }}
                >
                  {formatHours(item.value)}
                </Typography>
                <Typography className={classes.statLabel}>
                  {item.label}
                </Typography>
              </Box>
            </Grid>
          ))}
        </Grid>
        {mttr && (
          <Box textAlign="center" className={classes.trendChip}>
            <Chip
              icon={<TrendIcon style={{ color: trendColor }} />}
              label={mttr.trend}
              size="small"
              style={{ color: trendColor, borderColor: trendColor }}
              variant="outlined"
            />
          </Box>
        )}
      </CardContent>
    </Card>
  );
};
