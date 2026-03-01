import React from 'react';
import {
  Card,
  CardContent,
  Typography,
  Chip,
  Box,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { Link } from '@backstage/core-components';
import { FeaturedTemplate, MS_COLORS } from '../api/types';

interface TemplateCardProps {
  template: FeaturedTemplate;
}

const useStyles = makeStyles({
  card: {
    height: '100%',
    display: 'flex',
    flexDirection: 'column',
    cursor: 'pointer',
    transition: 'transform 0.2s, box-shadow 0.2s',
    '&:hover': {
      transform: 'translateY(-4px)',
      boxShadow: '0 8px 24px rgba(0,0,0,0.12)',
    },
  },
  title: {
    fontWeight: 600,
    fontSize: '0.95rem',
    marginBottom: 4,
  },
  type: {
    fontSize: '0.7rem',
    color: '#888',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 8,
  },
  description: {
    fontSize: '0.85rem',
    color: '#555',
    lineHeight: 1.5,
    flex: 1,
    display: '-webkit-box',
    WebkitLineClamp: 3,
    WebkitBoxOrient: 'vertical',
    overflow: 'hidden',
  },
  tags: {
    display: 'flex',
    flexWrap: 'wrap',
    gap: 4,
    marginTop: 12,
  },
  chip: {
    height: 22,
    fontSize: '0.65rem',
    backgroundColor: `${MS_COLORS.blue}12`,
    color: MS_COLORS.blue,
  },
  action: {
    marginTop: 12,
    fontSize: '0.8rem',
    fontWeight: 600,
    color: MS_COLORS.blue,
  },
});

/** Card displaying a featured Golden Path template from the catalog. */
export const TemplateCard = ({ template }: TemplateCardProps) => {
  const classes = useStyles();

  return (
    <Link to={template.route} underline="none">
      <Card className={classes.card} variant="outlined">
        <CardContent>
          <Typography className={classes.type}>{template.type}</Typography>
          <Typography className={classes.title}>{template.title}</Typography>
          <Typography className={classes.description}>
            {template.description}
          </Typography>
          <Box className={classes.tags}>
            {template.tags.map(tag => (
              <Chip
                key={tag}
                label={tag}
                size="small"
                className={classes.chip}
              />
            ))}
          </Box>
          <Typography className={classes.action}>Use template &rarr;</Typography>
        </CardContent>
      </Card>
    </Link>
  );
};
