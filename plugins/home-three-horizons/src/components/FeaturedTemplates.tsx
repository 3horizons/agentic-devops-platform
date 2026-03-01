import React from 'react';
import { Grid, Box, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { Progress } from '@backstage/core-components';
import { TemplateCard } from './TemplateCard';
import { useFeaturedTemplates } from '../hooks/useFeaturedTemplates';

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
  empty: {
    textAlign: 'center',
    padding: 32,
    color: '#888',
    fontSize: '0.9rem',
  },
});

/** Grid of featured Golden Path templates fetched from the catalog. */
export const FeaturedTemplates = () => {
  const classes = useStyles();
  const { templates, loading, error } = useFeaturedTemplates(6);

  if (loading) return <Progress />;
  if (error) return null;

  if (templates.length === 0) {
    return (
      <Box className={classes.section}>
        <Typography className={classes.sectionTitle}>
          Featured Templates
        </Typography>
        <Typography className={classes.empty}>
          No templates registered yet. Register Golden Path templates in the
          catalog to see them here.
        </Typography>
      </Box>
    );
  }

  return (
    <Box className={classes.section}>
      <Typography className={classes.sectionTitle}>
        Featured Templates
      </Typography>
      <Grid container spacing={2}>
        {templates.map(template => (
          <Grid item xs={12} sm={6} md={4} key={template.name}>
            <TemplateCard template={template} />
          </Grid>
        ))}
      </Grid>
    </Box>
  );
};
