import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.stepLabel,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.chipIcon,
    required this.chipHeadline,
    required this.chipBody,
  });

  final String stepLabel;
  final String title;
  final String description;
  final String imageUrl;
  final IconData chipIcon;
  final String chipHeadline;
  final String chipBody;
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _surfaceContainerHighest = Color(0xFFFFDCC4);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _tertiary = Color(0xFF7C5800);
  static const Color _tertiaryContainer = Color(0xFFC99000);

  static const List<_OnboardingSlide> _slides = <_OnboardingSlide>[
    _OnboardingSlide(
      stepLabel: 'STEP 01',
      title: 'Snap Your Ingredients',
      description:
          'Point your camera at your fridge or pantry. Ingridio instantly sees what you have.',
      imageUrl:
          'https://images.unsplash.com/photo-1584568694244-14fbdf83bd30?w=800',
      chipIcon: Icons.photo_camera_rounded,
      chipHeadline: 'POINT & SCAN',
      chipBody: 'Aim at your pantry or fridge',
    ),
    _OnboardingSlide(
      stepLabel: 'STEP 02',
      title: 'AI Detects Everything',
      description:
          'Our AI automatically identifies every ingredient. You can also add items manually.',
      imageUrl:
          'https://images.unsplash.com/photo-1620706857370-e1b9770e8bb1?w=800',
      chipIcon: Icons.auto_awesome_rounded,
      chipHeadline: 'AI IDENTIFICATION',
      chipBody: '12 ingredients detected',
    ),
    _OnboardingSlide(
      stepLabel: 'STEP 03',
      title: 'Get Recipes You Can Make',
      description:
          'Ingridio matches your ingredients to hundreds of recipes. No missing items, no wasted food.',
      imageUrl:
          'https://images.unsplash.com/photo-1466637574441-749b8f19452f?w=800',
      chipIcon: Icons.restaurant_menu_rounded,
      chipHeadline: 'SMART MATCH',
      chipBody: 'Recipes ready for your ingredients',
    ),
    _OnboardingSlide(
      stepLabel: 'STEP 04',
      title: 'Cook & Enjoy!',
      description:
          'Follow guided step-by-step cooking mode and enjoy a delicious home-cooked meal.',
      imageUrl:
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800',
      chipIcon: Icons.dinner_dining_rounded,
      chipHeadline: 'GUIDED MODE',
      chipBody: 'Step-by-step on your screen',
    ),
  ];

  static const int _lastIndex = 3;

  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  void _nextPage() {
    if (_currentPage == _lastIndex) {
      _goToLogin();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _skipToLast() {
    _pageController.animateToPage(
      _lastIndex,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final double horizontalPadding = size.width < 380 ? 20 : 24;
    final bool isLastSlide = _currentPage == _lastIndex;
    final String nextUpLine = isLastSlide
        ? 'You are ready to cook'
        : _slides[_currentPage + 1].title;

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: <Widget>[
          Positioned(
            bottom: -140,
            left: -140,
            child: Container(
              width: size.width * 0.9,
              height: size.width * 0.9,
              decoration: BoxDecoration(
                color: _surfaceContainerLow.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    20,
                    horizontalPadding,
                    12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Ingridio',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 30,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.8,
                          color: _onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: _skipToLast,
                        style: TextButton.styleFrom(
                          foregroundColor: _secondary,
                          textStyle: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                          ),
                        ),
                        child: const Text('Skip'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _slides.length,
                    onPageChanged: (int index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return _buildSlide(
                        context,
                        _slides[index],
                        horizontalPadding,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding + 2,
                    10,
                    horizontalPadding + 2,
                    size.height * 0.02,
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: List<Widget>.generate(_slides.length,
                            (int index) {
                          final bool active = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(right: 8),
                            height: 6,
                            width: active ? 32 : 8,
                            decoration: BoxDecoration(
                              color: active
                                  ? _primaryContainer
                                  : _surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                isLastSlide ? 'Almost there' : 'Next Up',
                                style: GoogleFonts.beVietnamPro(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  letterSpacing: 1.15,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nextUpLine,
                                style: GoogleFonts.beVietnamPro(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: _onSurface,
                                ),
                              ),
                            ],
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: isLastSlide
                                ? TextButton(
                                    key: const ValueKey<String>('lets-go'),
                                    onPressed: _goToLogin,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),
                                      foregroundColor: Colors.white,
                                      backgroundColor: _primary,
                                      textStyle: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text("Let's Go"),
                                  )
                                : DecoratedBox(
                                    key: const ValueKey<String>('next-arrow'),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(999),
                                      gradient: const LinearGradient(
                                        colors: <Color>[
                                          _primaryContainer,
                                          _primary,
                                        ],
                                      ),
                                      boxShadow: const <BoxShadow>[
                                        BoxShadow(
                                          color: Color(0x4DF97316),
                                          blurRadius: 30,
                                          offset: Offset(0, 12),
                                        ),
                                      ],
                                    ),
                                    child: SizedBox(
                                      width: 64,
                                      height: 64,
                                      child: IconButton(
                                        onPressed: _nextPage,
                                        icon: const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(
    BuildContext context,
    _OnboardingSlide slide,
    double horizontalPadding,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxW = constraints.maxWidth;
          const double heroMax = 280;
          final double heroHeight = min(heroMax, maxW * 0.92);
          final double scanBox = min(maxW * 0.58, heroHeight * 0.62);
          final double titleSize = maxW < 360 ? 26 : (maxW < 400 ? 30 : 32);
          final double bodySize =
              constraints.maxHeight < 560 ? 15.0 : 17.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: heroHeight,
                width: double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      top: -16,
                      right: -16,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: _surfaceContainerHigh.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x194C2706),
                            blurRadius: 60,
                            offset: Offset(0, 35),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Image.network(
                              slide.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (BuildContext context, Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return ColoredBox(
                                  color: _surfaceContainerLow,
                                  child: Center(
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _primaryContainer,
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (_, __, ___) => ColoredBox(
                                color: _surfaceContainerLow,
                                child: Icon(
                                  slide.chipIcon,
                                  size: 48,
                                  color: _outlineVariant,
                                ),
                              ),
                            ),
                            Center(
                              child: Container(
                                width: scanBox,
                                height: scanBox,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _primaryContainer.withOpacity(0.4),
                                    width: 2,
                                  ),
                                  color:
                                      _surfaceContainerLowest.withOpacity(0.1),
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.center,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          color: _primaryContainer
                                              .withOpacity(0.6),
                                          boxShadow: const <BoxShadow>[
                                            BoxShadow(
                                              color: Color(0xCCF97316),
                                              blurRadius: 15,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 18,
                                    sigmaY: 18,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: _surfaceContainerLowest
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _outlineVariant
                                            .withOpacity(0.15),
                                      ),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: const BoxDecoration(
                                            color: _tertiaryContainer,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            slide.chipIcon,
                                            color: const Color(0xFF442E00),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                slide.chipHeadline,
                                                style:
                                                    GoogleFonts.beVietnamPro(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 1.1,
                                                  color: _tertiary,
                                                ),
                                              ),
                                              const SizedBox(height: 1),
                                              Text(
                                                slide.chipBody,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style:
                                                    GoogleFonts.beVietnamPro(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                  color: _onSurface,
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
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            slide.stepLabel,
                            style: GoogleFonts.beVietnamPro(
                              color: _secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 1.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide.title,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: titleSize,
                              height: 1.12,
                              color: _onSurface,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            slide.description,
                            style: GoogleFonts.beVietnamPro(
                              color: _onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                              fontSize: bodySize,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
