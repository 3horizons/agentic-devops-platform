import { createPlugin, createRoutableExtension } from '@backstage/core-plugin-api';
import { rootRouteRef } from './routes';

export const homeThreeHorizonsPlugin = createPlugin({
  id: 'home-three-horizons',
  routes: {
    root: rootRouteRef,
  },
});

export const ThreeHorizonsHomePage = homeThreeHorizonsPlugin.provide(
  createRoutableExtension({
    name: 'ThreeHorizonsHomePage',
    component: () =>
      import('./components/ThreeHorizonsHomePage').then(
        m => m.ThreeHorizonsHomePage,
      ),
    mountPoint: rootRouteRef,
  }),
);
