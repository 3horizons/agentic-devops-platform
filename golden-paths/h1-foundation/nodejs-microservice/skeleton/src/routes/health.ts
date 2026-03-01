import { Router, Request, Response } from 'express';

export const healthRouter = Router();

/**
 * GET /health
 * Basic health check endpoint.
 * Returns the service status and current timestamp.
 */
healthRouter.get('/health', (_req: Request, res: Response) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
  });
});

/**
 * GET /ready
 * Readiness probe endpoint.
 * Returns whether the service is ready to accept traffic.
 */
healthRouter.get('/ready', (_req: Request, res: Response) => {
  res.json({
    ready: true,
  });
});
