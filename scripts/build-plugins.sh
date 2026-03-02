#!/usr/bin/env bash
set -euo pipefail
# =============================================================================
# Build all RHDH custom dynamic plugins locally
# Usage: ./scripts/build-plugins.sh
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

FRONTEND_PLUGINS=(
  "home-three-horizons"
  "my-group-dashboard"
  "copilot-metrics"
  "ghas-metrics"
)
BACKEND_PLUGINS=(
  "ghas-metrics-backend"
)

ALL_PLUGINS=("${FRONTEND_PLUGINS[@]}" "${BACKEND_PLUGINS[@]}")

echo "========================================"
echo "  Building ${#ALL_PLUGINS[@]} RHDH Dynamic Plugins"
echo "========================================"

for plugin in "${ALL_PLUGINS[@]}"; do
  PLUGIN_DIR="$ROOT_DIR/plugins/$plugin"

  if [[ ! -d "$PLUGIN_DIR" ]]; then
    echo "ERROR: Plugin directory not found: $PLUGIN_DIR"
    exit 1
  fi

  echo ""
  echo "── Building: $plugin ──────────────────"
  cd "$PLUGIN_DIR"

  # 1. Install dependencies
  echo "  [1/4] Installing dependencies..."
  npm install --legacy-peer-deps --silent 2>&1 | tail -1

  # 2. Generate type declarations
  echo "  [2/4] Generating type declarations..."
  npx tsc --declaration --emitDeclarationOnly --declarationDir dist-types 2>&1 || true

  # 3. Build
  echo "  [3/4] Building plugin..."
  npm run build 2>&1 | tail -3

  # 4. Export as dynamic plugin
  echo "  [4/4] Exporting dynamic plugin..."
  npx @janus-idp/cli package export-dynamic-plugin 2>&1 | tail -3

  if [[ -d "$PLUGIN_DIR/dist-dynamic" ]]; then
    echo "  ✅ $plugin → dist-dynamic/ ready"
  else
    echo "  ❌ $plugin → FAILED (no dist-dynamic/)"
    exit 1
  fi
done

echo ""
echo "========================================"
echo "  All ${#ALL_PLUGINS[@]} plugins built successfully!"
echo "========================================"
echo ""
echo "dist-dynamic contents:"
for plugin in "${ALL_PLUGINS[@]}"; do
  SIZE=$(du -sh "$ROOT_DIR/plugins/$plugin/dist-dynamic" 2>/dev/null | cut -f1)
  echo "  plugins/$plugin/dist-dynamic → $SIZE"
done
