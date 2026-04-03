import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/models/scanned_ingredient.dart';
import 'package:ingridio/screens/scan_result_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _onSurface = Color(0xFF2F1400);

  CameraController? _controller;
  bool _initializing = true;
  bool _permissionDenied = false;
  bool _noCamera = false;
  bool _isFlashOn = false;
  bool _capturing = false;

  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  static List<ScannedIngredient> get _mockCaptureResults =>
      const <ScannedIngredient>[
        ScannedIngredient(name: 'Tomatoes', confidence: IngredientConfidence.high),
        ScannedIngredient(
          name: 'Bell Pepper',
          confidence: IngredientConfidence.high,
        ),
        ScannedIngredient(name: 'Basil', confidence: IngredientConfidence.high),
        ScannedIngredient(name: 'Spinach', confidence: IngredientConfidence.medium),
        ScannedIngredient(name: 'Carrots', confidence: IngredientConfidence.high),
        ScannedIngredient(name: 'Onion', confidence: IngredientConfidence.medium),
      ];

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
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (kIsWeb) {
      if (mounted) {
        setState(() {
          _noCamera = true;
          _initializing = false;
        });
      }
      return;
    }

    final PermissionStatus status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _permissionDenied = true;
          _initializing = false;
        });
      }
      return;
    }

    try {
      final List<CameraDescription> cameras = await availableCameras();
      CameraDescription? back;
      for (final CameraDescription c in cameras) {
        if (c.lensDirection == CameraLensDirection.back) {
          back = c;
          break;
        }
      }
      back ??= cameras.isNotEmpty ? cameras.first : null;

      if (back == null) {
        if (mounted) {
          setState(() {
            _noCamera = true;
            _initializing = false;
          });
        }
        return;
      }

      final CameraController controller = CameraController(
        back,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      await controller.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );

      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _initializing = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _noCamera = true;
          _initializing = false;
        });
      }
    }
  }

  Future<void> _onGrantPermission() async {
    final PermissionStatus s = await Permission.camera.request();
    if (s.isGranted) {
      setState(() {
        _permissionDenied = false;
        _initializing = true;
        _noCamera = false;
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
    setState(() => _capturing = true);
    try {
      await c.takePicture();
    } catch (_) {
      if (mounted) {
        setState(() => _capturing = false);
      }
      return;
    }

    if (!mounted) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.88),
      builder: (BuildContext ctx) {
        return PopScope(
          canPop: false,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: _primaryContainer,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Identifying your ingredients...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
    setState(() => _capturing = false);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScanResultScreen(
          initialIngredients: List<ScannedIngredient>.from(_mockCaptureResults),
        ),
      ),
    );
  }

  void _openSuggestionResult(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name added!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ScanResultScreen(
          initialIngredients: <ScannedIngredient>[
            ScannedIngredient(
              name: name,
              confidence: IngredientConfidence.high,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return _PermissionRequiredView(onGrant: _onGrantPermission);
    }
    if (_noCamera) {
      return const _NoCameraView();
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
            Positioned.fill(child: _FullScreenCameraPreview(controller: _controller!)),
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
          const _ScanHudOverlay(
            primaryContainer: _primaryContainer,
            onSurface: _onSurface,
          ),
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
            onGallery: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gallery feature coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
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
            onSuggestion: _openSuggestionResult,
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
  const _PermissionRequiredView({required this.onGrant});

  final VoidCallback onGrant;

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
  const _NoCameraView();

  static const Color _onSurface = Color(0xFF2F1400);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFFFF8F5),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No camera found on this device',
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
  const _FullScreenCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox.expand();
    }
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double maxW = constraints.maxWidth;
        final double maxH = constraints.maxHeight;
        final double aspect = controller.value.aspectRatio;
        double previewW = maxW;
        double previewH = maxW * aspect;
        if (previewH < maxH) {
          previewH = maxH;
          previewW = maxH / aspect;
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
    required this.onSurface,
  });

  final Color primaryContainer;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double frameW = (constraints.maxWidth * 0.8).clamp(0.0, 400.0);
        final double frameH = (constraints.maxHeight * 0.52).clamp(220.0, 500.0);

        return Stack(
          alignment: Alignment.center,
          children: <Widget>[
            IgnorePointer(
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
                    _AnalyzingChip(onSurface: onSurface),
                  ],
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

class _AnalyzingChip extends StatelessWidget {
  const _AnalyzingChip({required this.onSurface});

  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: _ChipFadeWrapper(onSurface: onSurface),
    );
  }
}

class _ChipFadeWrapper extends StatefulWidget {
  const _ChipFadeWrapper({required this.onSurface});

  final Color onSurface;

  @override
  State<_ChipFadeWrapper> createState() => _ChipFadeWrapperState();
}

class _ChipFadeWrapperState extends State<_ChipFadeWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: _opacity.value,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 18,
                  color: const Color(0xFFF97316),
                ),
                const SizedBox(width: 8),
                Text(
                  'ANALYZING INGREDIENTS...',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: widget.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
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

  @override
  void paint(Canvas canvas, Size size) {
    final double frameW = (size.width * 0.8).clamp(0.0, 400.0);
    final double frameH = (size.height * 0.52).clamp(220.0, 500.0);
    final double left = (size.width - frameW) / 2;
    final double top = (size.height - frameH) / 2;
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
    required this.onVoice,
    required this.onCapture,
    required this.captureEnabled,
    required this.onSuggestion,
  });

  final VoidCallback onGallery;
  final VoidCallback onVoice;
  final VoidCallback onCapture;
  final bool captureEnabled;
  final void Function(String name) onSuggestion;

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
          padding: EdgeInsets.fromLTRB(28, 48, 28, navReserve),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Snap a photo of your ingredients to start cooking',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Center your items within the frame for best recognition.',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _SideAction(
                    icon: Icons.image_rounded,
                    label: 'Gallery',
                    onTap: onGallery,
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
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    _SuggestionChip(
                      label: 'Tomato',
                      onTap: () => onSuggestion('Tomato'),
                    ),
                    const SizedBox(width: 8),
                    _SuggestionChip(
                      label: 'Basil',
                      onTap: () => onSuggestion('Basil'),
                    ),
                    const SizedBox(width: 8),
                    _SuggestionChip(
                      label: 'Bell Pepper',
                      onTap: () => onSuggestion('Bell Pepper'),
                    ),
                  ],
                ),
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
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
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
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

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                label,
                style: GoogleFonts.beVietnamPro(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
