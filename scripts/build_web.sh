#!/usr/bin/env bash
# Release web bundle for Docker / static hosting.
#
# Note: Flutter 3.29+ removed the --web-renderer html (DOM) option. The supported
# stack is CanvasKit or Skwasm; this project uses the default JS compile target
# (CanvasKit at runtime) for broad mobile browser compatibility.
# https://docs.flutter.dev/platform-integration/web/renderers
#
# Usage (from repo root): ./scripts/build_web.sh
# Optional: ./scripts/build_web.sh --base-href /app/

set -euo pipefail
cd "$(dirname "$0")/.."
flutter build web --release "$@"
