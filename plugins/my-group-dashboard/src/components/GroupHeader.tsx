import React from 'react';
import { Typography, Box, Avatar } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import GroupIcon from '@material-ui/icons/Group';
import { GroupInfo, MS_COLORS } from '../api/types';

interface GroupHeaderProps {
  group: GroupInfo;
  memberCount: number;
}

const useStyles = makeStyles({
  header: {
    display: 'flex',
    alignItems: 'center',
    gap: 16,
    marginBottom: 24,
    padding: '24px 0',
    borderBottom: '1px solid #E0E0E0',
  },
  avatar: {
    width: 56,
    height: 56,
    backgroundColor: MS_COLORS.blue,
  },
  info: {
    flex: 1,
  },
  name: {
    fontSize: '1.5rem',
    fontWeight: 700,
    color: '#333',
  },
  description: {
    fontSize: '0.9rem',
    color: '#666',
    marginTop: 4,
  },
  memberBadge: {
    fontSize: '0.8rem',
    color: '#888',
    marginTop: 4,
  },
});

/** Group header displaying team avatar, name, description, and member count. */
export const GroupHeader = ({ group, memberCount }: GroupHeaderProps) => {
  const classes = useStyles();

  return (
    <Box className={classes.header}>
      <Avatar className={classes.avatar}>
        <GroupIcon />
      </Avatar>
      <Box className={classes.info}>
        <Typography className={classes.name}>{group.displayName}</Typography>
        {group.description && (
          <Typography className={classes.description}>
            {group.description}
          </Typography>
        )}
        <Typography className={classes.memberBadge}>
          {memberCount} member{memberCount !== 1 ? 's' : ''}
        </Typography>
      </Box>
    </Box>
  );
};
