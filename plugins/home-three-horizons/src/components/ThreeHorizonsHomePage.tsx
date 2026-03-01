import React from 'react';
import { Box } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { ErrorBoundary } from '@backstage/core-components';
import { ColorBar } from './ColorBar';
import { HeroBanner } from './HeroBanner';
import { StatCards } from './StatCards';
import { HorizonCards } from './HorizonCards';
import { QuickAccess } from './QuickAccess';
import { FeaturedTemplates } from './FeaturedTemplates';
import { useCurrentUser } from '../hooks/useCurrentUser';

const useStyles = makeStyles({
  root: {
    padding: '24px 32px',
    maxWidth: 1200,
    margin: '0 auto',
  },
});

/**
 * Three Horizons Home Page — main entry point.
 *
 * Renders the complete home page with all 6 sections:
 * ColorBar, HeroBanner, StatCards, HorizonCards, QuickAccess, FeaturedTemplates.
 *
 * Registered as a dynamic route at `/` in the RHDH dynamic plugins config.
 */
export const ThreeHorizonsHomePage = () => {
  const classes = useStyles();
  const { user } = useCurrentUser();

  return (
    <ErrorBoundary>
      <ColorBar />
      <Box className={classes.root}>
        <HeroBanner userName={user?.displayName} />
        <StatCards />
        <HorizonCards />
        <QuickAccess />
        <FeaturedTemplates />
      </Box>
    </ErrorBoundary>
  );
};
