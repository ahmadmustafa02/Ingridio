import 'dart:async';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ingridio/models/food_vision_result.dart';
import 'package:ingridio/models/scanned_ingredient.dart';
import 'package:ingridio/services/food_detection_service.dart';
import 'package:ingridio/screens/scan_result_screen.dart';
import 'package:permission_handler/permission_handler.dart';

enum _WebCameraInit { success, permissionDenied, exhausted }

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key, required this.isActive});

  final bool isActive;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  static const Color _primaryContainer = Color(0xFFF97316);
  static const String _kDefaultNoCameraMessage =
      'No camera found on this device';
  static const String _kWebCameraOpenFailedMessage =
      'Could not open the camera in the browser. Close other tabs or apps '
      'using the camera (video calls, Windows Camera), wait a few seconds, '
      'then try again—or use “Choose from gallery”.';

  CameraController? _controller;
  bool _initializing = false;
  bool _permissionDenied = false;
  bool _noCamera = false;
  String _noCameraMessage = _kDefaultNoCameraMessage;
  bool _isFlashOn = false;
  bool _capturing = false;
  static const FoodDetectionService _foodDetection = FoodDetectionService();

  int _cameraSession = 0;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _scanLineAnimation = CurvedAnimation(
      parent: _scanLineController,
      curve: Curves.linear,
    );
    if (widget.isActive) {
      _initializing = true;
      unawaited(_initCamera());
    }
  }

  @override
  void didUpdateWidget(ScanScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && oldWidget.isActive) {
      unawaited(_disposeCamera());
      return;
    }
    if (widget.isActive && !oldWidget.isActive) {
      setState(() {
        _initializing = true;
        _noCamera = false;
        _noCameraMessage = _kDefaultNoCameraMessage;
      });
      unawaited(_initCamera());
    }
  }

  Future<void> _releaseCameraHardware() async {
    final CameraController? c = _controller;
    _controller = null;
    if (c != null) {
      try {
        await c.dispose();
      } on Object catch (_) {}
    }
  }

  Future<void> _disposeCamera() async {
    _cameraSession++;
    await _releaseCameraHardware();
    if (mounted) {
      setState(() {
        _initializing = false;
      });
    }
  }

  Future<void> _initCamera() async {
    final int token = ++_cameraSession;

    await _releaseCameraHardware();
    if (!mounted || _cameraSession != token) {
      return;
    }

    if (!kIsWeb) {
      final PermissionStatus status = await Permission.camera.request();
      if (!mounted || _cameraSession != token) {
        return;
      }
      if (!status.isGranted) {
        if (mounted) {
          setState(() {
            _permissionDenied = true;
            _initializing = false;
          });
        }
        return;
      }
    }

    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (!mounted || _cameraSession != token) {
        return;
      }

      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _noCamera = true;
            _initializing = false;
            _noCameraMessage =
                'No camera is available. Use “Choose from gallery” to pick a photo instead.';
          });
        }
        return;
      }

      if (kIsWeb) {
        final _WebCameraInit webResult =
            await _tryOpenCameraWeb(cameras, token);
        if (!mounted || _cameraSession != token) {
          return;
        }
        if (webResult == _WebCameraInit.permissionDenied) {
          return;
        }
        if (webResult == _WebCameraInit.exhausted) {
          setState(() {
            _noCamera = true;
            _initializing = false;
            _noCameraMessage = _kWebCameraOpenFailedMessage;
          });
        }
        return;
      }

      CameraDescription? back;
      for (final CameraDescription c in cameras) {
        if (c.lensDirection == CameraLensDirection.back) {
          back = c;
          break;
        }
      }
      back ??= cameras.first;

      final CameraController controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );

      if (!mounted || _cameraSession != token) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
        _noCameraMessage = _kDefaultNoCameraMessage;
      });
    } on CameraException catch (e) {
      if (!mounted || _cameraSession != token) {
        return;
      }
      if (_cameraExceptionIsPermissionDenied(e)) {
        setState(() {
          _permissionDenied = true;
          _initializing = false;
        });
      } else if (_cameraExceptionIsNotFound(e)) {
        setState(() {
          _noCamera = true;
          _initializing = false;
          _noCameraMessage =
              'No camera was found. Your browser or device may not expose one, or it may be in use elsewhere.';
        });
      } else {
        setState(() {
          _noCamera = true;
          _initializing = false;
          _noCameraMessage = (e.description != null && e.description!.trim().isNotEmpty)
              ? e.description!.trim()
              : 'Could not start the camera. Try again or use “Choose from gallery”.';
        });
      }
    } catch (_) {
      if (mounted && _cameraSession == token) {
        setState(() {
          _noCamera = true;
          _initializing = false;
          _noCameraMessage =
              'Could not start the camera. Try again or use “Choose from gallery”.';
        });
      }
    }
  }

  static bool _cameraExceptionIsPermissionDenied(CameraException e) {
    final String code = e.code;
    switch (code) {
      case 'CameraAccessDenied':
      case 'AudioAccessDenied':
      case 'NotAllowedError':
      case 'PermissionDenied':
      case 'permissionDenied':
      case 'Permission denied':
        return true;
      default:
        return false;
    }
  }

  static bool _cameraExceptionIsNotFound(CameraException e) =>
      e.code == 'cameraNotFound';

  static int _webCameraPriority(CameraDescription c) {
    switch (c.lensDirection) {
      case CameraLensDirection.back:
        return 0;
      case CameraLensDirection.external:
        return 1;
      case CameraLensDirection.front:
        return 2;
    }
  }

  Future<_WebCameraInit> _tryOpenCameraWeb(
    List<CameraDescription> cameras,
    int token,
  ) async {
    final List<CameraDescription> ordered =
        List<CameraDescription>.from(cameras)
          ..sort(
            (CameraDescription a, CameraDescription b) =>
                _webCameraPriority(a).compareTo(_webCameraPriority(b)),
          );

    const List<ResolutionPreset> presets = <ResolutionPreset>[
      ResolutionPreset.veryHigh,
      ResolutionPreset.high,
      ResolutionPreset.medium,
      ResolutionPreset.low,
    ];

    for (final CameraDescription desc in ordered) {
      for (final ResolutionPreset preset in presets) {
        if (!mounted || _cameraSession != token) {
          return _WebCameraInit.exhausted;
        }
        CameraController? trial;
        try {
          trial = CameraController(
            desc,
            preset,
            enableAudio: false,
            imageFormatGroup: ImageFormatGroup.unknown,
          );
          await trial.initialize();
          if (!mounted || _cameraSession != token) {
            await trial.dispose();
            return _WebCameraInit.exhausted;
          }
          final CameraController ready = trial;
          trial = null;
          setState(() {
            _controller = ready;
            _initializing = false;
            _noCameraMessage = _kDefaultNoCameraMessage;
          });
          return _WebCameraInit.success;
        } on CameraException catch (e) {
          if (trial != null) {
            try {
              await trial.dispose();
            } on Object catch (_) {}
          }
          if (_cameraExceptionIsPermissionDenied(e)) {
            if (mounted && _cameraSession == token) {
              setState(() {
                _permissionDenied = true;
                _initializing = false;
              });
            }
            return _WebCameraInit.permissionDenied;
          }
        }
      }
    }
    return _WebCameraInit.exhausted;
  }

  Future<void> _onGrantPermission() async {
    if (kIsWeb) {
      setState(() {
        _permissionDenied = false;
        _initializing = true;
        _noCamera = false;
        _noCameraMessage = _kDefaultNoCameraMessage;
      });
      await _initCamera();
      return;
    }
    final PermissionStatus s = await Permission.camera.request();
    if (s.isGranted) {
      setState(() {
        _permissionDenied = false;
        _initializing = true;
        _noCamera = false;
        _noCameraMessage = _kDefaultNoCameraMessage;
      });
      await _initCamera();
    } else if (s.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  Future<void> _toggleFlash() async {
    final CameraController? c = _controller;
    if (c == null || !c.value.isInitialized) {
      return;
    }
    setState(() => _isFlashOn = !_isFlashOn);
    try {
      await c.setFlashMode(_isFlashOn ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      if (mounted) {
        setState(() => _isFlashOn = !_isFlashOn);
      }
    }
  }

  Future<void> _capture() async {
    final CameraController? c = _controller;
    if (c == null || !c.value.isInitialized || _capturing) {
      return;
    }

    XFile imageFile;
    setState(() => _capturing = true);
    try {
      imageFile = await c.takePicture();
    } catch (_) {
      if (mounted) {
        setState(() => _capturing = false);
      }
      return;
    }

    if (!mounted) {
      return;
    }

    await _runGeminiOnXFile(imageFile);
  }

  Future<void> _pickFromGallery() async {
    if (_capturing) {
      return;
    }
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 88,
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _capturing = true);
    await _runGeminiOnXFile(picked);
  }

  Future<void> _runGeminiOnXFile(XFile imageFile) async {
    if (!mounted) {
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (BuildContext ctx) => const _DetectionLoadingDialog(),
    );

    List<ScannedIngredient> detected = <ScannedIngredient>[];
    String? fallbackMessage;
    FoodVisionResult? foodVisionResult;

    try {
      final FoodVisionResult result = await _foodDetection.analyzeCapture(imageFile);
      foodVisionResult = result;
      if (result.detectedIngredientNames.isNotEmpty) {
        detected = result.detectedIngredientNames
            .map(
              (String name) => ScannedIngredient(
                name: _toTitleCase(name),
                confidence: IngredientConfidence.high,
              ),
            )
            .toList(growable: false);
      } else {
        fallbackMessage = 'No ingredients detected in this image. Try again.';
      }
    } on Object catch (error) {
      final String reason = error.toString().replaceFirst('Exception: ', '').trim();
      fallbackMessage = reason.isNotEmpty
          ? reason
          : 'Could not analyze this image. Check your API key and try again.';
    }

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    setState(() => _capturing = false);
    if (fallbackMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallbackMessage),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    if (detected.isEmpty) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScanResultScreen(
          initialIngredients: detected,
          foodVisionResult: foodVisionResult,
        ),
      ),
    );
  }

  static String _toTitleCase(String input) {
    final List<String> words = input
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return input;
    }

    return words
        .map(
          (String word) =>
              '${word[0].toUpperCase()}${word.length > 1 ? word.substring(1).toLowerCase() : ''}',
        )
        .join(' ');
  }

  @override
  void dispose() {
    _cameraSession++;
    _scanLineController.dispose();
    unawaited(_releaseCameraHardware());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return _PermissionRequiredView(
        onGrant: _onGrantPermission,
        webHint: kIsWeb
            ? 'When your browser asks, allow camera access for this site. You can change this later in the site or lock icon in the address bar.'
            : null,
      );
    }
    if (_noCamera) {
      return _NoCameraView(message: _noCameraMessage);
    }

    return ColoredBox(
      color: const Color(0xFF1c1917),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (_initializing || _controller == null)
            const Center(
              child: CircularProgressIndicator(color: _primaryContainer),
            )
          else
            Positioned.fill(
              child: _FullScreenCameraPreview(
                controller: _controller!,
                letterbox: kIsWeb,
              ),
            ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.95,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.38),
                    ],
                    stops: const <double>[0.35, 1.0],
                  ),
                ),
              ),
            ),
          ),
          const _ScanHudOverlay(primaryContainer: _primaryContainer),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanLineAnimation,
              builder: (BuildContext context, Widget? child) {
                return CustomPaint(
                  painter: _ScanLinePainter(
                    progress: _scanLineAnimation.value,
                    color: _primaryContainer,
                  ),
                  child: child,
                );
              },
            ),
          ),
          _BottomControls(
            onGallery: _pickFromGallery,
            galleryEnabled: !_capturing,
            onVoice: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Voice feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onCapture: _capture,
            captureEnabled: !_initializing &&
                _controller != null &&
                _controller!.value.isInitialized &&
                !_capturing,
          ),
          _TopBar(
            onClose: () {
              final NavigatorState nav = Navigator.of(context);
              if (nav.canPop()) {
                nav.pop();
              }
            },
            onFlash: _toggleFlash,
            isFlashOn: _isFlashOn,
          ),
        ],
      ),
    );
  }
}

class _PermissionRequiredView extends StatelessWidget {
  const _PermissionRequiredView({
    required this.onGrant,
    this.webHint,
  });

  final VoidCallback onGrant;
  final String? webHint;

  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _primaryContainer = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFF8F5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Camera permission required',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: _onSurface,
                ),
              ),
              if (webHint != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  webHint!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    height: 1.45,
                    color: Color(0xFF584237),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onGrant,
                style: FilledButton.styleFrom(
                  backgroundColor: _primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                child: Text(
                  'Grant Permission',
                  style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoCameraView extends StatelessWidget {
  const _NoCameraView({required this.message});

  final String message;

  static const Color _onSurface = Color(0xFF2F1400);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFF8F5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: _onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _FullScreenCameraPreview extends StatelessWidget {
  const _FullScreenCameraPreview({
    required this.controller,
    this.letterbox = false,
  });

  final CameraController controller;
  final bool letterbox;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox.expand();
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxW = constraints.maxWidth;
        final double maxH = constraints.maxHeight;
        final double ar = controller.value.aspectRatio;

        if (letterbox) {
          double w = maxW;
          double h = w / ar;
          if (h > maxH) {
            h = maxH;
            w = h * ar;
          }
          return ColoredBox(
            color: Colors.black,
            child: Center(
              child: SizedBox(
                width: w,
                height: h,
                child: CameraPreview(controller),
              ),
            ),
          );
        }

        double previewW = maxW;
        double previewH = maxW * ar;
        if (previewH < maxH) {
          previewH = maxH;
          previewW = maxH / ar;
        }
        return ClipRect(
          child: OverflowBox(
            maxWidth: previewW,
            maxHeight: previewH,
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: previewW,
                height: previewH,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScanHudOverlay extends StatelessWidget {
  const _ScanHudOverlay({
    required this.primaryContainer,
  });

  final Color primaryContainer;
  static const double _frameVerticalOffset = -154;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double frameW = (constraints.maxWidth * 0.61).clamp(0.0, 286.0);
        final double frameH = (constraints.maxHeight * 0.23).clamp(140.0, 220.0);

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            IgnorePointer(
              child: Transform.translate(
                offset: const Offset(0, _frameVerticalOffset),
                child: SizedBox(
                  width: frameW,
                  height: frameH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: <Widget>[
                      _CornerBracket(alignment: Alignment.topLeft, color: primaryContainer),
                      _CornerBracket(alignment: Alignment.topRight, color: primaryContainer),
                      _CornerBracket(alignment: Alignment.bottomLeft, color: primaryContainer),
                      _CornerBracket(alignment: Alignment.bottomRight, color: primaryContainer),
                      const _StaggerPulseDot(
                        alignment: Alignment(-0.35, -0.45),
                        delay: Duration.zero,
                      ),
                      const _StaggerPulseDot(
                        alignment: Alignment(0.42, 0.38),
                        delay: Duration(milliseconds: 300),
                      ),
                      const _StaggerPulseDot(
                        alignment: Alignment(0.05, 0.02),
                        delay: Duration(milliseconds: 600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CornerBracket extends StatelessWidget {
  const _CornerBracket({
    required this.alignment,
    required this.color,
  });

  final Alignment alignment;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const double s = 48;
    const double t = 4;
    const double r = 16;
    return Align(
      alignment: alignment,
      child: Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: alignment == Alignment.topLeft
                ? const Radius.circular(r)
                : Radius.zero,
            topRight: alignment == Alignment.topRight
                ? const Radius.circular(r)
                : Radius.zero,
            bottomLeft: alignment == Alignment.bottomLeft
                ? const Radius.circular(r)
                : Radius.zero,
            bottomRight: alignment == Alignment.bottomRight
                ? const Radius.circular(r)
                : Radius.zero,
          ),
          border: Border(
            top: alignment == Alignment.topLeft || alignment == Alignment.topRight
                ? BorderSide(color: color, width: t)
                : BorderSide.none,
            bottom: alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight
                ? BorderSide(color: color, width: t)
                : BorderSide.none,
            left: alignment == Alignment.topLeft || alignment == Alignment.bottomLeft
                ? BorderSide(color: color, width: t)
                : BorderSide.none,
            right: alignment == Alignment.topRight || alignment == Alignment.bottomRight
                ? BorderSide(color: color, width: t)
                : BorderSide.none,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: color.withValues(alpha: 0.45),
              blurRadius: 18,
              spreadRadius: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _StaggerPulseDot extends StatefulWidget {
  const _StaggerPulseDot({
    required this.alignment,
    required this.delay,
  });

  final Alignment alignment;
  final Duration delay;

  @override
  State<_StaggerPulseDot> createState() => _StaggerPulseDotState();
}

class _StaggerPulseDotState extends State<_StaggerPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        _c.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.alignment,
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (BuildContext context, Widget? child) {
          return Opacity(
            opacity: _opacity.value,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.85),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScanLinePainter extends CustomPainter {
  _ScanLinePainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;
  static const double _frameVerticalOffset = -132;

  @override
  void paint(Canvas canvas, Size size) {
    final double frameW = (size.width * 0.68).clamp(0.0, 320.0);
    final double frameH = (size.height * 0.28).clamp(160.0, 250.0);
    final double left = (size.width - frameW) / 2;
    final double top = (size.height - frameH) / 2 + _frameVerticalOffset;
    final double y = top + 4 + (frameH - 8) * progress;

    final Paint glow = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final Paint line = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(left + 8, y), Offset(left + frameW - 8, y), glow);
    canvas.drawLine(Offset(left + 8, y), Offset(left + frameW - 8, y), line);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.onClose,
    required this.onFlash,
    required this.isFlashOn,
  });

  final VoidCallback onClose;
  final VoidCallback onFlash;
  final bool isFlashOn;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets pad = MediaQuery.paddingOf(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, pad.top + 12, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _GlassIconButton(
              icon: Icons.close_rounded,
              onPressed: onClose,
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Ingridio AI Scan',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            _GlassIconButton(
              icon: isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              onPressed: onFlash,
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.onGallery,
    required this.galleryEnabled,
    required this.onVoice,
    required this.onCapture,
    required this.captureEnabled,
  });

  final VoidCallback onGallery;
  final bool galleryEnabled;
  final VoidCallback onVoice;
  final VoidCallback onCapture;
  final bool captureEnabled;

  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _onSurface = Color(0xFF2F1400);

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double navReserve = 88 + bottomInset;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: <Color>[
              Colors.black.withValues(alpha: 0.82),
              Colors.black.withValues(alpha: 0.4),
              Colors.transparent,
            ],
            stops: const <double>[0.0, 0.45, 1.0],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(28, 32, 28, navReserve),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Center your ingredients and tap capture',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Keep items inside the frame for better detection.',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _SideAction(
                    icon: Icons.image_rounded,
                    label: 'Gallery',
                    onTap: onGallery,
                    enabled: galleryEnabled,
                  ),
                  _CaptureButton(
                    enabled: captureEnabled,
                    onTap: onCapture,
                    primary: _primary,
                    primaryContainer: _primaryContainer,
                    onSurface: _onSurface,
                  ),
                  _SideAction(
                    icon: Icons.mic_rounded,
                    label: 'Voice',
                    onTap: onVoice,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideAction extends StatelessWidget {
  const _SideAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Icon(icon, color: Colors.white, size: 26),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.enabled,
    required this.onTap,
    required this.primary,
    required this.primaryContainer,
    required this.onSurface,
  });

  final bool enabled;
  final VoidCallback onTap;
  final Color primary;
  final Color primaryContainer;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 112,
          height: 112,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryContainer.withValues(alpha: 0.22),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: primaryContainer.withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ],
                ),
              ),
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: onSurface.withValues(alpha: 0.06),
                      width: 4,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: <Color>[primary, primaryContainer],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetectionLoadingDialog extends StatelessWidget {
  const _DetectionLoadingDialog();

  static const Color _primaryContainer = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 340),
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      width: 46,
                      height: 46,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: _primaryContainer,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Identifying ingredients',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This can take a few seconds while the AI scans your photo.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.beVietnamPro(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
