import React from 'react';
import { Grid, Card, CardContent, Typography, Box } from '@material-ui/core';
import { makeStyles, Theme } from '@material-ui/core/styles';
import { MS_COLORS, GroupStat } from '../api/types';

interface GroupStatsProps {
  components: number;
  members: number;
  apis: number;
  resources: number;
}

const useStatStyles = makeStyles<Theme, { color: string }>({
  card: {
    textAlign: 'center',
    borderTop: ({ color }) => `3px solid ${color}`,
  },
  count: {
    fontSize: '2rem',
    fontWeight: 700,
    color: ({ color }) => color,
    lineHeight: 1.2,
  },
  label: {
    fontSize: '0.8rem',
    color: '#666',
    marginTop: 4,
  },
});

const SingleStat = ({ stat }: { stat: GroupStat }) => {
  const classes = useStatStyles({ color: stat.color });
  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.count}>{stat.count}</Typography>
        <Typography className={classes.label}>{stat.label}</Typography>
      </CardContent>
    </Card>
  );
};

/** Grid of 4 stat cards showing group-scoped entity counts. */
export const GroupStats = ({
  components,
  members,
  apis,
  resources,
}: GroupStatsProps) => {
  const stats: GroupStat[] = [
    { label: 'Components', count: components, color: MS_COLORS.blue },
    { label: 'Members', count: members, color: MS_COLORS.green },
    { label: 'APIs', count: apis, color: MS_COLORS.yellow },
    { label: 'Resources', count: resources, color: MS_COLORS.red },
  ];

  return (
    <Box mb={3}>
      <Grid container spacing={2}>
        {stats.map(stat => (
          <Grid item xs={6} sm={3} key={stat.label}>
            <SingleStat stat={stat} />
          </Grid>
        ))}
      </Grid>
    </Box>
  );
};
