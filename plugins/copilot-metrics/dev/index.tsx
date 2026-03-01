import React from 'react';
import { createDevApp } from '@backstage/dev-utils';
import { copilotMetricsPlugin, CopilotMetricsPage } from '../src';

createDevApp()
  .registerPlugin(copilotMetricsPlugin)
  .addPage({
    element: <CopilotMetricsPage />,
    title: 'Copilot Metrics',
    path: '/copilot-metrics',
  })
  .render();
