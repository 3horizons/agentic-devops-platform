import { Router } from 'express';
import { Config } from '@backstage/config';
import { LoggerService } from '@backstage/backend-plugin-api';
import { GhasAggregator } from './service/GhasAggregator';
import { MttrCalculator } from './service/MttrCalculator';

interface RouterOptions {
  config: Config;
  logger: LoggerService;
}

export function createRouter(options: RouterOptions): Router {
  const { config, logger } = options;
  const router = Router();

  const token =
    process.env.GITHUB_SECURITY_TOKEN ??
    process.env.GITHUB_TOKEN ??
    config.getOptionalString("ghasMetrics.githubToken") ??
    "";

  const aggregator = new GhasAggregator(token, logger);
  const mttrCalc = new MttrCalculator(token, logger);

  router.get('/org/:org/dependabot', async (req, res) => {
    try {
      const { org } = req.params;
      const summary = await aggregator.getDependabotSummary(org);
      res.json(summary);
    } catch (error) {
      logger.error('Dependabot aggregation failed', error as Error);
      res.status(500).json({ error: 'Dependabot aggregation failed' });
    }
  });

  router.get('/org/:org/mttr', async (req, res) => {
    try {
      const { org } = req.params;
      const since = (req.query.since as string) ?? '';
      const mttr = await mttrCalc.computeMttr(org, since);
      res.json(mttr);
    } catch (error) {
      logger.error('MTTR computation failed', error as Error);
      res.status(500).json({ error: 'MTTR computation failed' });
    }
  });

  router.get('/org/:org/summary', async (req, res) => {
    try {
      const { org } = req.params;
      const [dependabot, mttr] = await Promise.all([
        aggregator.getDependabotSummary(org),
        mttrCalc.computeMttr(org, ''),
      ]);
      res.json({ dependabot, mttr });
    } catch (error) {
      logger.error('Summary aggregation failed', error as Error);
      res.status(500).json({ error: 'Summary aggregation failed' });
    }
  });

  return router;
}
