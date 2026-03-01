#!/bin/bash
# ============================================================
# Scaffold a new RHDH dynamic plugin structure
#
# Usage: ./scaffold-plugin.sh <plugin-name> <output-dir>
#
# Example:
#   ./scaffold-plugin.sh home-three-horizons ./plugins
#   Creates: ./plugins/home-three-horizons/
# ============================================================

set -euo pipefail

PLUGIN_NAME="${1:?Usage: scaffold-plugin.sh <plugin-name> <output-dir>}"
OUTPUT_DIR="${2:-.}"

PLUGIN_DIR="${OUTPUT_DIR}/${PLUGIN_NAME}"
PASCAL_NAME=$(echo "${PLUGIN_NAME}" | sed -r 's/(^|-)(\w)/\U\2/g')

echo "Scaffolding RHDH dynamic plugin: ${PLUGIN_NAME}"
echo "  Directory: ${PLUGIN_DIR}"
echo "  Component: ${PASCAL_NAME}"
echo ""

# Create directory structure
mkdir -p "${PLUGIN_DIR}/src/components"
mkdir -p "${PLUGIN_DIR}/src/hooks"
mkdir -p "${PLUGIN_DIR}/src/api"
mkdir -p "${PLUGIN_DIR}/dev"

# package.json
cat > "${PLUGIN_DIR}/package.json" << EOF
{
  "name": "@internal/plugin-${PLUGIN_NAME}",
  "version": "0.1.0",
  "main": "src/index.ts",
  "types": "src/index.ts",
  "license": "Apache-2.0",
  "private": true,
  "backstage": {
    "role": "frontend-plugin"
  },
  "scripts": {
    "start": "backstage-cli package start",
    "build": "backstage-cli package build",
    "lint": "backstage-cli package lint",
    "test": "backstage-cli package test",
    "clean": "backstage-cli package clean",
    "export-dynamic-plugin": "janus-cli package export-dynamic-plugin"
  },
  "dependencies": {
    "@backstage/core-components": "^0.14.0",
    "@backstage/core-plugin-api": "^1.9.0",
    "@backstage/plugin-catalog-react": "^1.12.0",
    "@backstage/theme": "^0.5.0",
    "@material-ui/core": "^4.12.4",
    "react-use": "^17.5.0"
  },
  "peerDependencies": {
    "react": "^17.0.0 || ^18.0.0",
    "react-dom": "^17.0.0 || ^18.0.0",
    "react-router-dom": "^6.0.0"
  },
  "devDependencies": {
    "@backstage/cli": "^0.26.0",
    "@backstage/test-utils": "^1.5.0",
    "@janus-idp/cli": "^1.13.0",
    "@testing-library/react": "^14.0.0",
    "typescript": "^5.3.0"
  }
}
EOF

# tsconfig.json
cat > "${PLUGIN_DIR}/tsconfig.json" << EOF
{
  "extends": "@backstage/cli/config/tsconfig.json",
  "include": ["src"],
  "exclude": ["node_modules"],
  "compilerOptions": {
    "outDir": "dist",
    "rootDir": "src"
  }
}
EOF

# src/plugin.ts
cat > "${PLUGIN_DIR}/src/plugin.ts" << EOF
import {
  createPlugin,
  createRouteRef,
  createRoutableExtension,
} from '@backstage/core-plugin-api';

export const rootRouteRef = createRouteRef({
  id: '${PLUGIN_NAME}',
});

export const ${PLUGIN_NAME//-/}Plugin = createPlugin({
  id: '${PLUGIN_NAME}',
  routes: {
    root: rootRouteRef,
  },
});

export const ${PASCAL_NAME}Page = ${PLUGIN_NAME//-/}Plugin.provide(
  createRoutableExtension({
    name: '${PASCAL_NAME}Page',
    component: () =>
      import('./components/${PASCAL_NAME}Page').then(m => m.${PASCAL_NAME}Page),
    mountPoint: rootRouteRef,
  }),
);
EOF

# src/index.ts
cat > "${PLUGIN_DIR}/src/index.ts" << EOF
export { ${PLUGIN_NAME//-/}Plugin, ${PASCAL_NAME}Page } from './plugin';
EOF

# src/components/{PascalName}Page.tsx
cat > "${PLUGIN_DIR}/src/components/${PASCAL_NAME}Page.tsx" << EOF
import React from 'react';
import { Content, Header, Page } from '@backstage/core-components';
import { Grid } from '@material-ui/core';

export const ${PASCAL_NAME}Page = () => {
  return (
    <Page themeId="home">
      <Header title="${PASCAL_NAME}" subtitle="RHDH Custom Plugin" />
      <Content>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            {/* Add your components here */}
            <p>Hello from ${PASCAL_NAME}!</p>
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};
EOF

# dev/index.tsx
cat > "${PLUGIN_DIR}/dev/index.tsx" << EOF
import React from 'react';
import { createDevApp } from '@backstage/dev-utils';
import { ${PLUGIN_NAME//-/}Plugin, ${PASCAL_NAME}Page } from '../src';

createDevApp()
  .registerPlugin(${PLUGIN_NAME//-/}Plugin)
  .addPage({
    element: <${PASCAL_NAME}Page />,
    title: '${PASCAL_NAME}',
    path: '/${PLUGIN_NAME}',
  })
  .render();
EOF

echo "Plugin scaffolded successfully!"
echo ""
echo "Next steps:"
echo "  1. cd ${PLUGIN_DIR}"
echo "  2. npm install"
echo "  3. npm start  (dev server)"
echo "  4. Add components to src/components/"
echo "  5. npm run build && npx @janus-idp/cli package export-dynamic-plugin"
echo ""
echo "Wiring config to add to dynamic-plugins-config.yaml:"
echo ""
echo "dynamicPlugins:"
echo "  frontend:"
echo "    @internal/plugin-${PLUGIN_NAME}:"
echo "      dynamicRoutes:"
echo "        - path: /${PLUGIN_NAME}"
echo "          importName: ${PASCAL_NAME}Page"
echo "          menuItem:"
echo "            icon: DashboardIcon"
echo "            text: ${PASCAL_NAME}"
