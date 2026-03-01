import React from 'react';
import { createDevApp } from '@backstage/dev-utils';
import { ghasMetricsPlugin, GhasMetricsPage } from '../src';

createDevApp()
  .registerPlugin(ghasMetricsPlugin)
  .addPage({
    element: <GhasMetricsPage />,
    title: 'GHAS Metrics',
    path: '/ghas-metrics',
  })
  .render();
