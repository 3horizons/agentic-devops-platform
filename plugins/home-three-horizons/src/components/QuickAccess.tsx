import React from 'react';
import { Grid, Box, Typography, Card, CardContent } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { Link } from '@backstage/core-components';
import CategoryIcon from '@material-ui/icons/Category';
import ExtensionIcon from '@material-ui/icons/Extension';
import AddCircleIcon from '@material-ui/icons/AddCircle';
import LibraryBooksIcon from '@material-ui/icons/LibraryBooks';
import { QUICK_LINKS, MS_COLORS } from '../api/types';

const ICON_MAP: Record<string, React.ElementType> = {
  category: CategoryIcon,
  extension: ExtensionIcon,
  addCircle: AddCircleIcon,
  libraryBooks: LibraryBooksIcon,
};

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
  card: {
    height: '100%',
    cursor: 'pointer',
    transition: 'transform 0.2s, box-shadow 0.2s',
    '&:hover': {
      transform: 'translateY(-4px)',
      boxShadow: '0 8px 24px rgba(0,0,0,0.12)',
    },
  },
  iconBox: {
    width: 40,
    height: 40,
    borderRadius: 8,
    backgroundColor: `${MS_COLORS.blue}14`,
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  icon: {
    color: MS_COLORS.blue,
    fontSize: 22,
  },
  title: {
    fontWeight: 600,
    fontSize: '0.9rem',
    marginBottom: 4,
  },
  description: {
    fontSize: '0.8rem',
    color: '#666',
    lineHeight: 1.4,
  },
});

/** Grid of 4 quick-access link cards for the most common platform actions. */
export const QuickAccess = () => {
  const classes = useStyles();

  return (
    <Box className={classes.section}>
      <Typography className={classes.sectionTitle}>Quick Access</Typography>
      <Grid container spacing={2}>
        {QUICK_LINKS.map(link => {
          const IconComponent = ICON_MAP[link.icon] ?? CategoryIcon;
          return (
            <Grid item xs={6} sm={3} key={link.title}>
              <Link to={link.route} underline="none">
                <Card className={classes.card} variant="outlined">
                  <CardContent>
                    <Box className={classes.iconBox}>
                      <IconComponent className={classes.icon} />
                    </Box>
                    <Typography className={classes.title}>
                      {link.title}
                    </Typography>
                    <Typography className={classes.description}>
                      {link.description}
                    </Typography>
                  </CardContent>
                </Card>
              </Link>
            </Grid>
          );
        })}
      </Grid>
    </Box>
  );
};
