# Release web bundle for Docker / static hosting.
#
# Note: Flutter 3.29+ removed the --web-renderer html (DOM) option. The supported
# stack is CanvasKit or Skwasm; this project uses the default JS compile target
# (CanvasKit at runtime) for broad mobile browser compatibility.
# https://docs.flutter.dev/platform-integration/web/renderers
#
# Usage (from repo root): .\scripts\build_web.ps1
# Optional: pass extra flags, e.g. .\scripts\build_web.ps1 --base-href /app/

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)

flutter build web --release @args
