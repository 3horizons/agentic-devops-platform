import { createPlugin, createRoutableExtension } from '@backstage/core-plugin-api';
import { rootRouteRef } from './routes';

export const copilotMetricsPlugin = createPlugin({
  id: 'copilot-metrics',
  routes: {
    root: rootRouteRef,
  },
});

export const CopilotMetricsPage = copilotMetricsPlugin.provide(
  createRoutableExtension({
    name: 'CopilotMetricsPage',
    component: () =>
      import('./components/CopilotMetricsPage').then(
        m => m.CopilotMetricsPage,
      ),
    mountPoint: rootRouteRef,
  }),
);
