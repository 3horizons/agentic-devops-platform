import React from 'react';
import { Box, Typography, Chip } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { Table, TableColumn, Link } from '@backstage/core-components';
import { OwnedEntity, MS_COLORS } from '../api/types';

interface OwnedComponentsProps {
  entities: OwnedEntity[];
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
  kindChip: {
    height: 22,
    fontSize: '0.65rem',
    fontWeight: 600,
  },
});

const KIND_COLORS: Record<string, string> = {
  Component: MS_COLORS.blue,
  API: MS_COLORS.green,
  Resource: MS_COLORS.yellow,
};

/** Table displaying all entities owned by the team group. */
export const OwnedComponents = ({ entities, loading }: OwnedComponentsProps) => {
  const classes = useStyles();

  const columns: TableColumn<OwnedEntity>[] = [
    {
      title: 'Name',
      field: 'title',
      render: (row: OwnedEntity) => (
        <Link to={`/catalog/default/${row.kind.toLowerCase()}/${row.name}`}>
          {row.title}
        </Link>
      ),
    },
    {
      title: 'Kind',
      field: 'kind',
      render: (row: OwnedEntity) => (
        <Chip
          label={row.kind}
          size="small"
          className={classes.kindChip}
          style={{
            backgroundColor: `${KIND_COLORS[row.kind] ?? MS_COLORS.blue}20`,
            color: KIND_COLORS[row.kind] ?? MS_COLORS.blue,
          }}
        />
      ),
    },
    {
      title: 'Type',
      field: 'type',
    },
    {
      title: 'Lifecycle',
      field: 'lifecycle',
    },
    {
      title: 'System',
      field: 'system',
    },
  ];

  return (
    <Box className={classes.section}>
      <Typography className={classes.sectionTitle}>
        Owned Components
      </Typography>
      <Table
        title=""
        options={{ paging: true, pageSize: 10, search: true }}
        columns={columns}
        data={entities}
        isLoading={loading}
      />
    </Box>
  );
};
