import { createPlugin, createRoutableExtension } from '@backstage/core-plugin-api';
import { rootRouteRef } from './routes';

export const myGroupDashboardPlugin = createPlugin({
  id: 'my-group-dashboard',
  routes: {
    root: rootRouteRef,
  },
});

export const MyGroupDashboardPage = myGroupDashboardPlugin.provide(
  createRoutableExtension({
    name: 'MyGroupDashboardPage',
    component: () =>
      import('./components/MyGroupDashboard').then(m => m.MyGroupDashboard),
    mountPoint: rootRouteRef,
  }),
);
