import { createPlugin, createRoutableExtension } from '@backstage/core-plugin-api';
import { rootRouteRef } from './routes';

export const ghasMetricsPlugin = createPlugin({
  id: 'ghas-metrics',
  routes: {
    root: rootRouteRef,
  },
});

export const GhasMetricsPage = ghasMetricsPlugin.provide(
  createRoutableExtension({
    name: 'GhasMetricsPage',
    component: () =>
      import('./components/GhasMetricsPage').then(m => m.GhasMetricsPage),
    mountPoint: rootRouteRef,
  }),
);
