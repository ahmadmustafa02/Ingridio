import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/logic/cooked_recipes_store.dart';
import 'package:ingridio/logic/recipe_rating_store.dart';
import 'package:ingridio/logic/step_timer_parse.dart';
import 'package:ingridio/models/recipe.dart';
import 'package:ingridio/models/recipe_cooking_step.dart';
import 'package:ingridio/screens/home_screen.dart';

class CookingModeScreen extends StatefulWidget {
  const CookingModeScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<CookingModeScreen> createState() => _CookingModeScreenState();
}

class _CookingModeScreenState extends State<CookingModeScreen>
    with TickerProviderStateMixin {
  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _onPrimaryContainer = Color(0xFF582200);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _tertiary = Color(0xFF7C5800);
  static const Color _onTertiaryContainer = Color(0xFF442E00);

  static const List<String> _aiTips = <String>[
    'Prep all ingredients before you start cooking.',
    'Medium heat is key — don\'t rush this step.',
    'Taste and adjust seasoning as you go.',
    'Keep stirring to prevent sticking.',
    'Let it rest before serving for best results.',
  ];

  int _index = 0;
  bool _completionVisible = false;
  int _ratingStars = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;

  List<RecipeCookingStep> get _steps {
    final Recipe r = widget.recipe;
    if (r.cookingSteps != null && r.cookingSteps!.isNotEmpty) {
      return r.cookingSteps!;
    }
    return List<RecipeCookingStep>.generate(
      r.steps.length,
      (int i) => RecipeCookingStep(
        title: (r.stepTitles != null && i < r.stepTitles!.length)
            ? r.stepTitles![i]
            : 'Step ${i + 1}',
        body: r.steps[i],
      ),
    );
  }

  RecipeCookingStep? get _currentOrNull =>
      _steps.isEmpty ? null : _steps[_index.clamp(0, _steps.length - 1)];

  String get _stepText {
    final RecipeCookingStep? s = _currentOrNull;
    if (s == null) {
      return '';
    }
    return '${s.title} ${s.body}';
  }

  double get _progress =>
      _steps.isEmpty ? 0 : (_index + 1) / _steps.length;

  bool get _showTimer =>
      stepTextSuggestsTimer(_stepText) &&
      parseDurationFromStepText(_stepText) != null;

  Duration? get _parsedDuration => parseDurationFromStepText(_stepText);

  String get _aiTip => _aiTips[_index % _aiTips.length];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_index <= 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _index--);
    }
  }

  void _goNext() {
    if (_steps.isEmpty) {
      return;
    }
    if (_index >= _steps.length - 1) {
      setState(() {
        _completionVisible = true;
        _ratingStars = RecipeRatingStore.instance.starsFor(widget.recipe.id) ?? 0;
      });
      return;
    }
    setState(() => _index++);
  }

  void _onSwipe(DragEndDetails d) {
    if (d.velocity.pixelsPerSecond.dx < -240) {
      _goNext();
    } else if (d.velocity.pixelsPerSecond.dx > 240) {
      _goBack();
    }
  }

  void _saveToCooked() {
    CookedRecipesStore.instance.add(widget.recipe.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to your cooked recipes!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _backToHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (Route<dynamic> r) => false,
    );
  }

  void _settingsTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<RecipeCookingStep> steps = _steps;
    final bool wide = MediaQuery.sizeOf(context).width >= 900;

    return GestureDetector(
      onHorizontalDragEnd: _onSwipe,
      behavior: HitTestBehavior.deferToChild,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Scaffold(
            backgroundColor: _background,
            body: steps.isEmpty
                ? _EmptyStepsBody(
                    onBack: () => Navigator.of(context).pop(),
                    onSettings: _settingsTap,
                    onSurface: _onSurface,
                    onSurfaceVariant: _onSurfaceVariant,
                    primaryContainer: _primaryContainer,
                  )
                : Builder(
                    builder: (BuildContext context) {
                      final RecipeCookingStep step =
                          steps[_index.clamp(0, steps.length - 1)];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _CookingTopBar(onSettings: _settingsTap),
                          Expanded(
                            child: SingleChildScrollView(
                              padding:
                                  const EdgeInsets.fromLTRB(22, 20, 22, 32),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  _HeaderProgress(
                                recipeName: widget.recipe.name,
                                stepIndex: _index,
                                stepCount: steps.length,
                                progress: _progress,
                                secondary: _secondary,
                                onSurface: _onSurface,
                                onSurfaceVariant: _onSurfaceVariant,
                                surfaceHigh: _surfaceContainerHigh,
                                primaryContainer: _primaryContainer,
                              ),
                              const SizedBox(height: 28),
                              wide
                                  ? Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 7,
                                          child: _StepImageColumn(
                                            imageUrl: widget.recipe.imageUrl,
                                            aiTip: _aiTip,
                                            surfaceLow: _surfaceContainerLow,
                                            outlineVariant: _outlineVariant,
                                            tertiary: _tertiary,
                                            onTertiaryContainer:
                                                _onTertiaryContainer,
                                            onSurface: _onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: 28),
                                        Expanded(
                                          flex: 5,
                                          child: _StepContentColumn(
                                            key: ValueKey<int>(_index),
                                            title: step.title,
                                            body: step.body,
                                            showTimer: _showTimer,
                                            duration: _parsedDuration ??
                                                Duration.zero,
                                            surfaceLowest:
                                                _surfaceContainerLowest,
                                            surfaceLow: _surfaceContainerLow,
                                            onSurface: _onSurface,
                                            onSurfaceVariant:
                                                _onSurfaceVariant,
                                            primary: _primary,
                                            primaryContainer:
                                                _primaryContainer,
                                            onPrimaryContainer:
                                                _onPrimaryContainer,
                                            pulseScale: _pulseScale,
                                            onMicTap: _goNext,
                                            secondary: _secondary,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        _StepImageColumn(
                                          imageUrl: widget.recipe.imageUrl,
                                          aiTip: _aiTip,
                                          surfaceLow: _surfaceContainerLow,
                                          outlineVariant: _outlineVariant,
                                          tertiary: _tertiary,
                                          onTertiaryContainer:
                                              _onTertiaryContainer,
                                          onSurface: _onSurface,
                                        ),
                                        const SizedBox(height: 24),
                                        _StepContentColumn(
                                          key: ValueKey<int>(_index),
                                          title: step.title,
                                          body: step.body,
                                          showTimer: _showTimer,
                                          duration: _parsedDuration ??
                                              Duration.zero,
                                          surfaceLowest:
                                              _surfaceContainerLowest,
                                          surfaceLow: _surfaceContainerLow,
                                          onSurface: _onSurface,
                                          onSurfaceVariant: _onSurfaceVariant,
                                          primary: _primary,
                                          primaryContainer: _primaryContainer,
                                          onPrimaryContainer:
                                              _onPrimaryContainer,
                                          pulseScale: _pulseScale,
                                          onMicTap: _goNext,
                                          secondary: _secondary,
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 36),
                                  _NavRow(
                                    onBack: _goBack,
                                    onNext: _goNext,
                                    isLast: _index >= steps.length - 1,
                                    outlineVariant: _outlineVariant,
                                    secondary: _secondary,
                                    surfaceLow: _surfaceContainerLow,
                                    primary: _primary,
                                    primaryContainer: _primaryContainer,
                                    onPrimary: _onPrimary,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (_completionVisible) _CompletionOverlay(
            recipeName: widget.recipe.name,
            ratingStars: _ratingStars,
            onStarsChanged: (int s) {
              setState(() => _ratingStars = s);
              RecipeRatingStore.instance.setRating(widget.recipe.id, s);
            },
            onSaveCooked: _saveToCooked,
            onBackToHome: _backToHome,
            background: _background,
            onSurface: _onSurface,
            onSurfaceVariant: _onSurfaceVariant,
            primaryContainer: _primaryContainer,
            onPrimary: _onPrimary,
          ),
        ],
      ),
    );
  }
}

class _CookingTopBar extends StatelessWidget {
  const _CookingTopBar({required this.onSettings});

  final VoidCallback onSettings;

  static const Color _onSurface = Color(0xFF2F1400);

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.paddingOf(context).top;
    return Material(
      color: const Color(0xFFFFF8F5),
      elevation: 0,
      child: SizedBox(
        height: top + 56,
        child: Padding(
          padding: EdgeInsets.only(top: top, left: 16, right: 4),
          child: Row(
            children: <Widget>[
              Text(
                'Ingridio',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.4,
                  color: _onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onSettings,
                icon: const Icon(Icons.settings_rounded),
                color: _onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyStepsBody extends StatelessWidget {
  const _EmptyStepsBody({
    required this.onBack,
    required this.onSettings,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primaryContainer,
  });

  final VoidCallback onBack;
  final VoidCallback onSettings;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primaryContainer;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _CookingTopBar(onSettings: onSettings),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'No cooking steps for this recipe yet.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add steps in the recipe data to use cooking mode.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.beVietnamPro(
                      color: onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: onBack,
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryContainer,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Go back',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderProgress extends StatelessWidget {
  const _HeaderProgress({
    required this.recipeName,
    required this.stepIndex,
    required this.stepCount,
    required this.progress,
    required this.secondary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceHigh,
    required this.primaryContainer,
  });

  final String recipeName;
  final int stepIndex;
  final int stepCount;
  final double progress;
  final Color secondary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceHigh;
  final Color primaryContainer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'NOW COOKING',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: secondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                recipeName,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 32,
                  height: 1.1,
                  letterSpacing: -0.6,
                  color: onSurface,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              'Step ${stepIndex + 1} of $stepCount',
              style: GoogleFonts.beVietnamPro(
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 120,
              height: 8,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    width: 120 * progress.clamp(0.0, 1.0),
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepImageColumn extends StatelessWidget {
  const _StepImageColumn({
    required this.imageUrl,
    required this.aiTip,
    required this.surfaceLow,
    required this.outlineVariant,
    required this.tertiary,
    required this.onTertiaryContainer,
    required this.onSurface,
  });

  final String imageUrl;
  final String aiTip;
  final Color surfaceLow;
  final Color outlineVariant;
  final Color tertiary;
  final Color onTertiaryContainer;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ColoredBox(
              color: surfaceLow,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) =>
                    const Icon(Icons.image_not_supported_outlined, size: 48),
              ),
            ),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 320),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.72),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: outlineVariant.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(Icons.lightbulb_outline_rounded,
                              color: tertiary, size: 22),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'AI TIP',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                    color: onTertiaryContainer,
                                  ),
                                ),
                                Text(
                                  aiTip,
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepContentColumn extends StatelessWidget {
  const _StepContentColumn({
    super.key,
    required this.title,
    required this.body,
    required this.showTimer,
    required this.duration,
    required this.surfaceLowest,
    required this.surfaceLow,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.pulseScale,
    required this.onMicTap,
    required this.secondary,
  });

  final String title;
  final String body;
  final bool showTimer;
  final Duration duration;
  final Color surfaceLowest;
  final Color surfaceLow;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Animation<double> pulseScale;
  final VoidCallback onMicTap;
  final Color secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: Container(
            key: ValueKey<String>('$title$body'),
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: surfaceLowest,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x144C2706),
                  blurRadius: 40,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  body,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 18,
                    height: 1.55,
                    color: onSurfaceVariant,
                  ),
                ),
                if (showTimer && duration.inSeconds > 0) ...<Widget>[
                  const SizedBox(height: 22),
                  _InlineStepTimer(
                    key: ValueKey<int>(duration.inSeconds),
                    total: duration,
                    surfaceLow: surfaceLow,
                    onSurface: onSurface,
                    onSurfaceVariant: onSurfaceVariant,
                    primary: primary,
                    primaryContainer: primaryContainer,
                    onPrimaryContainer: onPrimaryContainer,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ScaleTransition(
              scale: pulseScale,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryContainer.withValues(alpha: 0.22),
                    ),
                  ),
                  Material(
                    color: primaryContainer,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onMicTap,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 42,
                        height: 42,
                        child: Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '"Hey Ingridio, next step"',
                    style: GoogleFonts.beVietnamPro(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LISTENING FOR COMMANDS...',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InlineStepTimer extends StatefulWidget {
  const _InlineStepTimer({
    super.key,
    required this.total,
    required this.surfaceLow,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
  });

  final Duration total;
  final Color surfaceLow;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  @override
  State<_InlineStepTimer> createState() => _InlineStepTimerState();
}

class _InlineStepTimerState extends State<_InlineStepTimer> {
  late int _remaining;
  Timer? _timer;
  bool _running = false;
  bool _everStarted = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.total.inSeconds;
  }

  @override
  void didUpdateWidget(covariant _InlineStepTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.total != widget.total) {
      _timer?.cancel();
      _running = false;
      _everStarted = false;
      _remaining = widget.total.inSeconds;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _mmss {
    final int m = _remaining ~/ 60;
    final int s = _remaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _tick(Timer t) {
    if (_remaining <= 0) {
      _timer?.cancel();
      setState(() {
        _running = false;
        _everStarted = false;
        _remaining = widget.total.inSeconds;
      });
      final ScaffoldMessengerState? m =
          ScaffoldMessenger.maybeOf(context);
      m?.showSnackBar(
        const SnackBar(
          content: Text('Time\'s up! Check your dish 🍳'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _remaining--);
  }

  void _startOrResume() {
    if (_remaining <= 0) {
      _remaining = widget.total.inSeconds;
    }
    _timer?.cancel();
    setState(() {
      _running = true;
      _everStarted = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _running = false);
  }

  String get _buttonLabel {
    if (_running) {
      return 'PAUSE';
    }
    if (_everStarted && _remaining > 0) {
      return 'RESUME';
    }
    return 'START';
  }

  void _onButtonTap() {
    if (_running) {
      _pause();
    } else {
      _startOrResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: widget.surfaceLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.primaryContainer.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.timer_outlined, color: widget.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Timer for this step',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: widget.onSurfaceVariant,
                  ),
                ),
                Text(
                  _mmss,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    color: widget.onSurface,
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: _onButtonTap,
            style: FilledButton.styleFrom(
              backgroundColor: widget.primaryContainer,
              foregroundColor: widget.onPrimaryContainer,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              _buttonLabel,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.onBack,
    required this.onNext,
    required this.isLast,
    required this.outlineVariant,
    required this.secondary,
    required this.surfaceLow,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimary,
  });

  final VoidCallback onBack;
  final VoidCallback onNext;
  final bool isLast;
  final Color outlineVariant;
  final Color secondary;
  final Color surfaceLow;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onBack,
            customBorder: const CircleBorder(),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: outlineVariant, width: 2),
              ),
              child: Icon(Icons.arrow_back_rounded, color: secondary),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: <Color>[primaryContainer, primary],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: primary.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onNext,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        isLast ? 'Finish' : 'Next Step',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: onPrimary,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletionOverlay extends StatelessWidget {
  const _CompletionOverlay({
    required this.recipeName,
    required this.ratingStars,
    required this.onStarsChanged,
    required this.onSaveCooked,
    required this.onBackToHome,
    required this.background,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primaryContainer,
    required this.onPrimary,
  });

  final String recipeName;
  final int ratingStars;
  final ValueChanged<int> onStarsChanged;
  final VoidCallback onSaveCooked;
  final VoidCallback onBackToHome;
  final Color background;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primaryContainer;
  final Color onPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background.withValues(alpha: 0.98),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('🎉', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 16),
              Text(
                'Your dish is ready!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                recipeName,
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 17,
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Rate this recipe',
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.w600,
                  color: onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(5, (int i) {
                  final int star = i + 1;
                  return IconButton(
                    onPressed: () => onStarsChanged(star),
                    icon: Icon(
                      star <= ratingStars
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: star <= ratingStars
                          ? primaryContainer
                          : onSurfaceVariant,
                      size: 40,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onSaveCooked,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: onSurface,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: onSurfaceVariant.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    'Save to Cooked',
                    style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onBackToHome,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryContainer,
                    foregroundColor: onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'Back to Home',
                    style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w700),
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
