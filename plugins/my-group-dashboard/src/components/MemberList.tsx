import React from 'react';
import {
  Box,
  Typography,
  Avatar,
} from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { Table, TableColumn, Link } from '@backstage/core-components';
import { TeamMember, MS_COLORS } from '../api/types';

interface MemberListProps {
  members: TeamMember[];
  loading: boolean;
}

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
  nameCell: {
    display: 'flex',
    alignItems: 'center',
    gap: 8,
  },
  avatar: {
    width: 28,
    height: 28,
    fontSize: '0.75rem',
    backgroundColor: MS_COLORS.green,
  },
});

/** Table displaying team members with avatar, name, role, and email. */
export const MemberList = ({ members, loading }: MemberListProps) => {
  const classes = useStyles();

  const columns: TableColumn<TeamMember>[] = [
    {
      title: 'Name',
      field: 'displayName',
      render: (row: TeamMember) => (
        <Box className={classes.nameCell}>
          <Avatar
            src={row.avatarUrl}
            className={classes.avatar}
          >
            {row.displayName.charAt(0).toUpperCase()}
          </Avatar>
          <Link to={`/catalog/default/user/${row.name}`}>
            {row.displayName}
          </Link>
        </Box>
      ),
    },
    {
      title: 'Role',
      field: 'role',
    },
    {
      title: 'Email',
      field: 'email',
    },
  ];

  return (
    <Box className={classes.section}>
      <Typography className={classes.sectionTitle}>Team Members</Typography>
      <Table
        title=""
        options={{ paging: false, search: false, toolbar: false }}
        columns={columns}
        data={members}
        isLoading={loading}
      />
    </Box>
  );
};
