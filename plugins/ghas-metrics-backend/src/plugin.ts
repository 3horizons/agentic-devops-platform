import {
  coreServices,
  createBackendPlugin,
} from '@backstage/backend-plugin-api';
import { createRouter } from './router';

export const ghasMetricsBackendPlugin = createBackendPlugin({
  pluginId: 'ghas-metrics',
  register(env) {
    env.registerInit({
      deps: {
        httpRouter: coreServices.httpRouter,
        config: coreServices.rootConfig,
        logger: coreServices.logger,
      },
      async init({ httpRouter, config, logger }) {
        const router = createRouter({ config, logger });
        httpRouter.use(router);
      },
    });
  },
});
