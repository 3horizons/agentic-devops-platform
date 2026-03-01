import React from 'react';
import { makeStyles } from '@material-ui/core/styles';
import { MS_COLORS } from '../api/types';

const useStyles = makeStyles({
  colorBar: {
    position: 'fixed',
    top: 0,
    left: 0,
    right: 0,
    height: 4,
    zIndex: 9999,
    background: `linear-gradient(to right, ${MS_COLORS.red} 0%, ${MS_COLORS.red} 25%, ${MS_COLORS.green} 25%, ${MS_COLORS.green} 50%, ${MS_COLORS.blue} 50%, ${MS_COLORS.blue} 75%, ${MS_COLORS.yellow} 75%, ${MS_COLORS.yellow} 100%)`,
  },
});

/** Fixed 4px gradient bar at the top of the page using Microsoft logo colors. */
export const ColorBar = () => {
  const classes = useStyles();
  return <div className={classes.colorBar} />;
};
