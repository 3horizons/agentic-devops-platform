import React from 'react';
import { Box, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import {
  Content,
  Header,
  Page,
  Progress,
  ErrorBoundary,
} from '@backstage/core-components';
import { GroupHeader } from './GroupHeader';
import { GroupStats } from './GroupStats';
import { MemberList } from './MemberList';
import { OwnedComponents } from './OwnedComponents';
import { useCurrentGroup } from '../hooks/useCurrentGroup';
import { useGroupMembers } from '../hooks/useGroupMembers';
import { useOwnedEntities } from '../hooks/useOwnedEntities';

const useStyles = makeStyles({
  noGroup: {
    textAlign: 'center',
    padding: '64px 24px',
  },
  noGroupTitle: {
    fontSize: '1.2rem',
    fontWeight: 600,
    color: '#333',
    marginBottom: 8,
  },
  noGroupText: {
    fontSize: '0.9rem',
    color: '#666',
  },
});

/**
 * My Group Dashboard — team-scoped view.
 *
 * Shows the current user's group, member list, and owned entities.
 * Registered as a dynamic route at `/my-group`.
 */
export const MyGroupDashboard = () => {
  const classes = useStyles();
  const { group, loading: groupLoading } = useCurrentGroup();
  const { members, loading: membersLoading } = useGroupMembers(
    group?.entityRef,
  );
  const { entities, loading: entitiesLoading } = useOwnedEntities(
    group?.entityRef,
  );

  if (groupLoading) {
    return (
      <Page themeId="tool">
        <Header title="My Group" subtitle="Team Dashboard" />
        <Content>
          <Progress />
        </Content>
      </Page>
    );
  }

  if (!group) {
    return (
      <Page themeId="tool">
        <Header title="My Group" subtitle="Team Dashboard" />
        <Content>
          <Box className={classes.noGroup}>
            <Typography className={classes.noGroupTitle}>
              No team found
            </Typography>
            <Typography className={classes.noGroupText}>
              You are not currently assigned to a team in the catalog. Ask your
              admin to add you to a Group entity, or configure GitHub org
              discovery to auto-populate teams.
            </Typography>
          </Box>
        </Content>
      </Page>
    );
  }

  const componentCount = entities.filter(e => e.kind === 'Component').length;
  const apiCount = entities.filter(e => e.kind === 'API').length;
  const resourceCount = entities.filter(e => e.kind === 'Resource').length;

  return (
    <ErrorBoundary>
      <Page themeId="tool">
        <Header title="My Group" subtitle={group.displayName} />
        <Content>
          <GroupHeader group={group} memberCount={members.length} />
          <GroupStats
            components={componentCount}
            members={members.length}
            apis={apiCount}
            resources={resourceCount}
          />
          <MemberList members={members} loading={membersLoading} />
          <OwnedComponents entities={entities} loading={entitiesLoading} />
        </Content>
      </Page>
    </ErrorBoundary>
  );
};
