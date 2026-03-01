import React from 'react';
import { createDevApp } from '@backstage/dev-utils';
import { myGroupDashboardPlugin, MyGroupDashboardPage } from '../src';

createDevApp()
  .registerPlugin(myGroupDashboardPlugin)
  .addPage({
    element: <MyGroupDashboardPage />,
    title: 'My Group Dashboard',
    path: '/my-group',
  })
  .render();
