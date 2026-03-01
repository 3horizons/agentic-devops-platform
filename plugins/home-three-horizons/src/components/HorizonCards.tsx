import React from 'react';
import { Grid, Box, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { HorizonCard } from './HorizonCard';
import { HORIZONS } from '../api/types';

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

/** Grid of 3 horizon cards (H1 Foundation, H2 Enhancement, H3 Innovation). */
export const HorizonCards = () => {
  const classes = useStyles();

  return (
    <Box className={classes.section} id="horizons">
      <Typography className={classes.sectionTitle}>
        Three Horizons
      </Typography>
      <Grid container spacing={2}>
        {HORIZONS.map(horizon => (
          <Grid item xs={12} sm={4} key={horizon.id}>
            <HorizonCard horizon={horizon} />
          </Grid>
        ))}
      </Grid>
    </Box>
  );
};
