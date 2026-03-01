import {
  createPlugin,
  createRoutableExtension,
} from '@backstage/core-plugin-api';

import { rootRouteRef } from './routes';

/**
 * Engineering Intelligence Plugin
 *
 * Registers dashboard pages and entity tabs for engineering metrics.
 */
export const engineeringIntelligencePlugin = createPlugin({
  id: '${{ values.pluginName }}',
  routes: {
    root: rootRouteRef,
  },
});

/**
 * Entity Tab — appears on component/service entity pages
 */
export const EntityEngineeringIntelligenceTab =
  engineeringIntelligencePlugin.provide(
    createRoutableExtension({
      name: 'EntityEngineeringIntelligenceTab',
      component: () =>
        import('./components/DashboardPage').then(m => m.DashboardPage),
      mountPoint: rootRouteRef,
    }),
  );

/**
 * Standalone Page — accessible via /engineering-intelligence
 */
export const EngineeringIntelligencePage =
  engineeringIntelligencePlugin.provide(
    createRoutableExtension({
      name: 'EngineeringIntelligencePage',
      component: () =>
        import('./components/DashboardPage').then(m => m.DashboardPage),
      mountPoint: rootRouteRef,
    }),
  );
