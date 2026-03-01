import React from 'react';
import { Box, Typography, Button, ButtonGroup } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import RefreshIcon from '@material-ui/icons/Refresh';
import { DateRange, DATE_RANGE_LABELS, MS_COLORS } from '../api/types';

interface MetricsHeaderProps {
  range: DateRange;
  onRangeChange: (range: DateRange) => void;
  onRefresh: () => void;
}

const useStyles = makeStyles({
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 24,
  },
  title: {
    fontSize: '1.5rem',
    fontWeight: 700,
    color: '#333',
  },
  controls: {
    display: 'flex',
    alignItems: 'center',
    gap: 12,
  },
  activeBtn: {
    backgroundColor: MS_COLORS.blue,
    color: '#fff',
    '&:hover': {
      backgroundColor: '#0078D4',
    },
  },
});

/** Header with title, date range selector, and refresh button. */
export const MetricsHeader = ({
  range,
  onRangeChange,
  onRefresh,
}: MetricsHeaderProps) => {
  const classes = useStyles();
  const ranges: DateRange[] = ['7d', '14d', '28d'];

  return (
    <Box className={classes.header}>
      <Typography className={classes.title}>
        GitHub Copilot Metrics
      </Typography>
      <Box className={classes.controls}>
        <ButtonGroup size="small" variant="outlined">
          {ranges.map(r => (
            <Button
              key={r}
              onClick={() => onRangeChange(r)}
              className={r === range ? classes.activeBtn : undefined}
            >
              {DATE_RANGE_LABELS[r]}
            </Button>
          ))}
        </ButtonGroup>
        <Button
          size="small"
          variant="outlined"
          startIcon={<RefreshIcon />}
          onClick={onRefresh}
        >
          Refresh
        </Button>
      </Box>
    </Box>
  );
};
