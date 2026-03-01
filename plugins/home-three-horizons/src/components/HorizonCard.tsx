import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Chip,
  Box,
} from '@material-ui/core';
import { makeStyles, Theme } from '@material-ui/core/styles';
import { Link } from '@backstage/core-components';
import { HorizonData } from '../api/types';

interface HorizonCardProps {
  horizon: HorizonData;
}

const useStyles = makeStyles<Theme, { color: string }>({
  card: {
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    cursor: 'pointer',
    transition: 'transform 0.2s, box-shadow 0.2s',
    borderLeft: ({ color }) => `4px solid ${color}`,
    '&:hover': {
      transform: 'translateY(-4px)',
      boxShadow: '0 8px 24px rgba(0,0,0,0.12)',
    },
  },
  header: {
    display: 'flex',
    alignItems: 'center',
    gap: 8,
    marginBottom: 8,
  },
  dot: {
    width: 12,
    height: 12,
    borderRadius: '50%',
    backgroundColor: ({ color }) => color,
    flexShrink: 0,
  },
  title: {
    fontWeight: 600,
    fontSize: '1rem',
  },
  subtitle: {
    fontSize: '0.75rem',
    color: '#888',
    marginBottom: 8,
  },
  description: {
    fontSize: '0.875rem',
    color: '#555',
    lineHeight: 1.5,
    flex: 1,
  },
  tags: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: 4,
    marginTop: 12,
  },
  chip: {
    height: 24,
    fontSize: '0.7rem',
    backgroundColor: ({ color }) => `${color}18`,
    color: ({ color }) => color,
    border: ({ color }) => `1px solid ${color}40`,
  },
});

/** Card displaying a Three Horizons maturity level with tags. */
export const HorizonCard = ({ horizon }: HorizonCardProps) => {
  const classes = useStyles({ color: horizon.color });

  return (
    <Link to={horizon.route} underline="none">
      <Card className={classes.card} variant="outlined">
        <CardContent>
          <Box className={classes.header}>
            <span className={classes.dot} />
            <Typography className={classes.title}>{horizon.title}</Typography>
          </Box>
          <Typography className={classes.subtitle}>
            {horizon.subtitle}
          </Typography>
          <Typography className={classes.description}>
            {horizon.description}
          </Typography>
          <Box className={classes.tags}>
            {horizon.tags.map(tag => (
              <Chip
                key={tag}
                label={tag}
                size="small"
                className={classes.chip}
              />
            ))}
          </Box>
        </CardContent>
      </Card>
    </Link>
  );
};
