import React from 'react';
import { Grid, Box, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { Progress } from '@backstage/core-components';
import { StatCard } from './StatCard';
import { useEntityCounts } from '../hooks/useEntityCounts';

const useStyles = makeStyles({
  section: {
    marginBottom: 32,
  },
  sectionTitle: {
    fontSize: '1.1rem',
    fontWeight: 600,
    marginBottom: 16,
    color: '#333',
  },
});

/** Grid of 4 stat cards showing entity counts from the Catalog API. */
export const StatCards = () => {
  const classes = useStyles();
  const { counts, loading, error } = useEntityCounts();

  if (loading) return <Progress />;
  if (error) return null;

  return (
    <Box className={classes.section}>
      <Typography className={classes.sectionTitle}>
        Platform Overview
      </Typography>
      <Grid container spacing={2}>
        {counts.map(stat => (
          <Grid item xs={6} sm={3} key={stat.label}>
            <StatCard stat={stat} />
          </Grid>
        ))}
      </Grid>
    </Box>
  );
};
