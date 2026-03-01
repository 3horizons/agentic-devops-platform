import React from 'react';
import { Card, CardContent, Typography, Box } from '@material-ui/core';
import { makeStyles, Theme } from '@material-ui/core/styles';
import { Link } from '@backstage/core-components';
import { EntityCount } from '../api/types';

interface StatCardProps {
  stat: EntityCount;
}

const useStyles = makeStyles<Theme, { color: string }>({
  card: {
    textAlign: 'center',
    cursor: 'pointer',
    transition: 'transform 0.2s, box-shadow 0.2s',
    borderTop: ({ color }) => `3px solid ${color}`,
    '&:hover': {
      transform: 'translateY(-4px)',
      boxShadow: '0 8px 24px rgba(0,0,0,0.12)',
    },
  },
  count: {
    fontSize: '2.5rem',
    fontWeight: 700,
    color: ({ color }) => color,
    lineHeight: 1.2,
  },
  label: {
    fontSize: '0.875rem',
    color: '#666',
    marginTop: 4,
  },
});

/** Single stat card displaying an entity count with a colored top border. */
export const StatCard = ({ stat }: StatCardProps) => {
  const classes = useStyles({ color: stat.color });

  return (
    <Link to={stat.route} underline="none">
      <Card className={classes.card} variant="outlined">
        <CardContent>
          <Box>
            <Typography className={classes.count}>{stat.count}</Typography>
            <Typography className={classes.label}>{stat.label}</Typography>
          </Box>
        </CardContent>
      </Card>
    </Link>
  );
};
