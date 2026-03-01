import React from 'react';
import { createDevApp } from '@backstage/dev-utils';
import { homeThreeHorizonsPlugin, ThreeHorizonsHomePage } from '../src';

createDevApp()
  .registerPlugin(homeThreeHorizonsPlugin)
  .addPage({
    element: <ThreeHorizonsHomePage />,
    title: 'Three Horizons Home',
    path: '/home-three-horizons',
  })
  .render();
