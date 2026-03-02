import React from 'react';
import { render, screen } from '@testing-library/react';
import { TestApiProvider } from '@backstage/test-utils';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { identityApiRef } from '@backstage/core-plugin-api';
import { MyGroupDashboard } from '../MyGroupDashboard';

const mockIdentityApi = {
  getBackstageIdentity: jest.fn().mockResolvedValue({
    type: 'user',
    userEntityRef: 'user:default/paula',
    ownershipEntityRefs: ['group:default/platform-team'],
  }),
};

const mockCatalogApi = {
  getEntityByRef: jest.fn().mockResolvedValue({
    metadata: {
      name: 'platform-team',
      title: 'Platform Team',
      description: 'Platform engineering team',
    },
    kind: 'Group',
  }),
  getEntities: jest.fn().mockResolvedValue({
    items: [
      {
        metadata: { name: 'paula', title: 'Paula Silva' },
        kind: 'User',
        spec: { profile: { displayName: 'Paula Silva', email: 'paula@example.com', role: 'Lead' } },
        relations: [{ type: 'memberOf', targetRef: 'group:default/platform-team' }],
      },
    ],
  }),
};

describe('MyGroupDashboard', () => {
  it('renders group header when group is found', async () => {
    render(
      <TestApiProvider
        apis={[
          [identityApiRef, mockIdentityApi],
          [catalogApiRef, mockCatalogApi],
        ]}
      >
        <MyGroupDashboard />
      </TestApiProvider>,
    );

    expect(await screen.findByText('Platform Team')).toBeInTheDocument();
  });
});
