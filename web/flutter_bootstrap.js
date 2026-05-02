{{flutter_js}}
{{flutter_build_config}}

// Flutter 3.29+ removed the legacy DOM ("HTML") renderer. Release web builds use
// CanvasKit (WebGL) for GPU-backed rendering, including on mobile browsers.
// canvasKitVariant "auto" picks a browser-appropriate CanvasKit build.
_flutter.loader.load({
  config: {
    canvasKitVariant: "auto",
  },
});
