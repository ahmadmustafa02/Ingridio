import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/data/mock_data.dart';
import 'package:ingridio/logic/recipe_matcher.dart';
import 'package:ingridio/models/recipe.dart';
import 'package:ingridio/models/recipe_match_result.dart';
import 'package:ingridio/screens/discovery_screen.dart';
import 'package:ingridio/screens/pantry_screen.dart';
import 'package:ingridio/screens/profile_screen.dart';
import 'package:ingridio/screens/recipe_detail_screen.dart';

enum _SortMode { matchPercent, protein, carb }

class RecipeMatchScreen extends StatefulWidget {
  const RecipeMatchScreen({
    super.key,
    required this.detectedIngredients,
  });

  final List<String> detectedIngredients;

  @override
  State<RecipeMatchScreen> createState() => _RecipeMatchScreenState();
}

class _RecipeMatchScreenState extends State<RecipeMatchScreen> {
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _tertiaryContainer = Color(0xFFC99000);
  static const Color _onTertiaryContainer = Color(0xFF442E00);

  late final List<RecipeMatchResult> _baseResults;
  late List<RecipeMatchResult> _display;
  _SortMode _sortMode = _SortMode.matchPercent;

  @override
  void initState() {
    super.initState();
    _baseResults = RecipeMatcher.match(
      widget.detectedIngredients,
      MockData.mockRecipes,
    );
    _display = List<RecipeMatchResult>.from(_baseResults);
  }

  void _resort() {
    final List<RecipeMatchResult> next =
        List<RecipeMatchResult>.from(_baseResults);
    switch (_sortMode) {
      case _SortMode.matchPercent:
        next.sort(
          (RecipeMatchResult a, RecipeMatchResult b) =>
              b.matchPercent.compareTo(a.matchPercent),
        );
        break;
      case _SortMode.protein:
        next.sort(
          (RecipeMatchResult a, RecipeMatchResult b) =>
              (b.recipe.calories ?? 0).compareTo(a.recipe.calories ?? 0),
        );
        break;
      case _SortMode.carb:
        next.sort(
          (RecipeMatchResult a, RecipeMatchResult b) =>
              (a.recipe.calories ?? 99999).compareTo(b.recipe.calories ?? 99999),
        );
        break;
    }
    setState(() => _display = next);
  }

  void _setSortMode(_SortMode mode) {
    setState(() {
      if (_sortMode == mode) {
        _sortMode = _SortMode.matchPercent;
      } else {
        _sortMode = mode;
      }
    });
    _resort();
  }

  void _onVeganChip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vegan filter coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openRecipe(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailScreen(
          recipe: recipe,
          detectedIngredients: widget.detectedIngredients,
        ),
      ),
    );
  }

  void _navPopToHomeThen(void Function(BuildContext ctx) action) {
    final NavigatorState nav = Navigator.of(context);
    nav.popUntil((Route<dynamic> r) => r.isFirst);
    action(nav.context);
  }

  void _goHome() {
    final NavigatorState nav = Navigator.of(context);
    nav.popUntil((Route<dynamic> r) => r.isFirst);
  }

  void _goScan() {
    Navigator.of(context).pop();
  }

  void _goPantry() {
    _navPopToHomeThen(
      (BuildContext ctx) {
        Navigator.of(ctx).push(
          MaterialPageRoute<void>(builder: (_) => const PantryScreen()),
        );
      },
    );
  }

  void _goDiscovery() {
    _navPopToHomeThen(
      (BuildContext ctx) {
        Navigator.of(ctx).push(
          MaterialPageRoute<void>(builder: (_) => const DiscoveryScreen()),
        );
      },
    );
  }

  void _goProfile() {
    _navPopToHomeThen(
      (BuildContext ctx) {
        Navigator.of(ctx).push(
          MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
        );
      },
    );
  }

  _BentoSlots _slots() {
    if (_display.isEmpty) {
      return const _BentoSlots.empty();
    }
    final RecipeMatchResult best = _display.first;
    RecipeMatchResult quick = _display.firstWhere(
      (RecipeMatchResult r) => r.recipe.tag == 'Quickest',
      orElse: () =>
          _display.length > 1 ? _display[1] : _display.first,
    );
    if (quick.recipe.id == best.recipe.id && _display.length > 1) {
      quick = _display[1];
    }
    final Set<String> used = <String>{best.recipe.id, quick.recipe.id};
    final List<RecipeMatchResult> secondary = _display
        .where((RecipeMatchResult r) => !used.contains(r.recipe.id))
        .take(2)
        .toList();
    return _BentoSlots(
      best: best,
      quickest: quick,
      secondary: secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final int n = widget.detectedIngredients.length;
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double navH = 72 + bottomInset;
    final _BentoSlots slots = _slots();

    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CustomScrollView(
            slivers: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  minHeight: 56 + MediaQuery.paddingOf(context).top,
                  maxHeight: 56 + MediaQuery.paddingOf(context).top,
                  child: _TopBar(
                    onSettings: _goProfile,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                sliver: SliverToBoxAdapter(
                  child: _HeroSection(ingredientCount: n),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(22, 24, 22, navH + 24),
                sliver: SliverToBoxAdapter(
                  child: _display.isEmpty
                      ? Text(
                          'No recipes with ingredient data to match yet.',
                          style: GoogleFonts.beVietnamPro(
                            color: _onSurfaceVariant,
                            fontSize: 16,
                          ),
                        )
                      : LayoutBuilder(
                          builder:
                              (BuildContext context, BoxConstraints c) {
                            final bool wide = c.maxWidth >= 720;
                            return _BentoGrid(
                              wide: wide,
                              slots: slots,
                              sortMode: _sortMode,
                              onOpenRecipe: _openRecipe,
                              onProtein: () => _setSortMode(_SortMode.protein),
                              onCarb: () => _setSortMode(_SortMode.carb),
                              onVegan: _onVeganChip,
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _GlassBottomNav(
              onHome: _goHome,
              onScan: _goScan,
              onPantry: _goPantry,
              onDiscovery: _goDiscovery,
              onProfile: _goProfile,
            ),
          ),
        ],
      ),
    );
  }
}

class _BentoSlots {
  const _BentoSlots({
    required this.best,
    required this.quickest,
    required this.secondary,
  });

  const _BentoSlots.empty()
      : best = null,
        quickest = null,
        secondary = const <RecipeMatchResult>[];

  final RecipeMatchResult? best;
  final RecipeMatchResult? quickest;
  final List<RecipeMatchResult> secondary;
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: maxHeight, child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onSettings});

  final VoidCallback onSettings;

  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _primaryContainer = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.paddingOf(context).top;
    return ColoredBox(
      color: const Color(0xFFFFF8F5),
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, top + 8, 22, 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                ClipOval(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Image.network(
                      MockData.profileAvatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Color(0xFFFFE3D1),
                        child: Icon(Icons.person_rounded, color: Color(0xFF924C00)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Ingridio',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.4,
                    color: _onSurface,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: onSettings,
              icon: const Icon(Icons.settings_rounded),
              color: _primaryContainer,
              iconSize: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.ingredientCount});

  final int ingredientCount;

  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _secondaryFixed = Color(0xFFFFDCC4);
  static const Color _tertiaryContainer = Color(0xFFC99000);
  static const Color _onTertiaryContainer = Color(0xFF442E00);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: _surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final bool row = c.maxWidth > 560;
              final Widget copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _tertiaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$ingredientCount Ingredients Matched',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _onTertiaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Magic matches for your pantry.',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 32,
                      height: 1.1,
                      letterSpacing: -0.8,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We've curated these recipes based on what you just scanned. Ready to get cooking?",
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 17,
                      height: 1.45,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ],
              );
              final Widget art = SizedBox(
                height: row ? 200 : 180,
                width: row ? 220 : double.infinity,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      left: row ? 12 : 40,
                      bottom: -8,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: _secondaryFixed,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x22000000),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: row ? Alignment.centerRight : Alignment.center,
                      child: Transform.rotate(
                        angle: 0.035,
                        child: Material(
                          elevation: 8,
                          shadowColor: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: SizedBox(
                            width: row ? 200 : double.infinity,
                            height: 160,
                            child: Image.network(
                              MockData.recipeMatchHeroImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const ColoredBox(color: Color(0xFFFFE3D1)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
              if (row) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(child: copy),
                    const SizedBox(width: 16),
                    art,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[copy, const SizedBox(height: 20), art],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({
    required this.wide,
    required this.slots,
    required this.sortMode,
    required this.onOpenRecipe,
    required this.onProtein,
    required this.onCarb,
    required this.onVegan,
  });

  final bool wide;
  final _BentoSlots slots;
  final _SortMode sortMode;
  final void Function(Recipe recipe) onOpenRecipe;
  final VoidCallback onProtein;
  final VoidCallback onCarb;
  final VoidCallback onVegan;

  @override
  Widget build(BuildContext context) {
    final RecipeMatchResult? b = slots.best;
    final RecipeMatchResult? q = slots.quickest;
    if (b == null) {
      return const SizedBox.shrink();
    }

    final Widget bestCard = _ScaleCard(
      child: _BestMatchCard(
        result: b,
        showBestBadge: sortMode == _SortMode.matchPercent,
        onView: () => onOpenRecipe(b.recipe),
      ),
    );

    final Widget quickCard = q != null
        ? _ScaleCard(
            child: _QuickestCard(
              result: q,
              onView: () => onOpenRecipe(q.recipe),
            ),
          )
        : const SizedBox.shrink();

    final List<Widget> smalls = <Widget>[];
    for (int i = 0; i < slots.secondary.length; i++) {
      final RecipeMatchResult s = slots.secondary[i];
      smalls.add(
        _ScaleCard(
          child: _SecondaryRecipeCard(
            result: s,
            onView: () => onOpenRecipe(s.recipe),
          ),
        ),
      );
    }

    final Widget chipPanel = _ChipPanel(
      sortMode: sortMode,
      onProtein: onProtein,
      onCarb: onCarb,
      onVegan: onVegan,
    );

    if (wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(flex: 8, child: bestCard),
                const SizedBox(width: 20),
                Expanded(flex: 4, child: quickCard),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (smalls.isNotEmpty) Expanded(child: smalls[0]),
              if (smalls.length > 1) ...<Widget>[
                const SizedBox(width: 20),
                Expanded(child: smalls[1]),
              ],
              if (smalls.length < 2) ...<Widget>[
                const Spacer(),
              ],
              const SizedBox(width: 20),
              Expanded(child: chipPanel),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        bestCard,
        const SizedBox(height: 20),
        quickCard,
        const SizedBox(height: 20),
        ...smalls.map(
          (Widget w) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: w,
          ),
        ),
        chipPanel,
      ],
    );
  }
}

class _ScaleCard extends StatefulWidget {
  const _ScaleCard({required this.child});

  final Widget child;

  @override
  State<_ScaleCard> createState() => _ScaleCardState();
}

class _ScaleCardState extends State<_ScaleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _BestMatchCard extends StatelessWidget {
  const _BestMatchCard({
    required this.result,
    required this.showBestBadge,
    required this.onView,
  });

  final RecipeMatchResult result;
  final bool showBestBadge;
  final VoidCallback onView;

  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _tertiary = Color(0xFF7C5800);

  @override
  Widget build(BuildContext context) {
    final Recipe r = result.recipe;
    return Material(
      color: _surfaceContainerLowest,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final bool row = c.maxWidth > 520;
          final Widget image = Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(
                r.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const ColoredBox(color: Color(0xFFFFF1E9)),
              ),
              if (showBestBadge)
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x44000000),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      'Best Match',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          );

          final Widget body = Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.star_rounded, size: 18, color: _tertiary),
                        const SizedBox(width: 6),
                        Text(
                          '${result.matchPercent}% Ingredient Match',
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: _tertiary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      r.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 1.2,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      r.description ??
                          'Curated for your scanned ingredients.',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        height: 1.45,
                        color: _onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: <Widget>[
                        Icon(Icons.schedule_rounded,
                            size: 20, color: _secondary),
                        const SizedBox(width: 4),
                        Text(
                          r.cookTime,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            color: _secondary,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Icon(Icons.restaurant_menu_rounded,
                            size: 20, color: _secondary),
                        const SizedBox(width: 4),
                        Text(
                          r.difficulty,
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 13,
                            color: _secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: <Color>[_primaryContainer, _primary],
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x224C2706),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onView,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: Text(
                              'View Recipe',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          if (row) {
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: SizedBox(height: 300, child: image),
                  ),
                  Expanded(flex: 1, child: body),
                ],
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 240, child: image),
              body,
            ],
          );
        },
      ),
    );
  }
}

class _QuickestCard extends StatelessWidget {
  const _QuickestCard({
    required this.result,
    required this.onView,
  });

  final RecipeMatchResult result;
  final VoidCallback onView;

  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _tertiary = Color(0xFF7C5800);

  @override
  Widget build(BuildContext context) {
    final Recipe r = result.recipe;
    return Material(
      color: _surfaceContainerLowest,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.network(
                  r.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const ColoredBox(color: Color(0xFFFFF1E9)),
                ),
                Positioned(
                  top: 14,
                  left: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _tertiary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Quickest',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${r.ingredients.length} Ingredients',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: _secondary,
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Icon(Icons.schedule_rounded,
                            size: 18, color: _primary),
                        const SizedBox(width: 2),
                        Text(
                          r.cookTime.replaceAll(' mins', ' min'),
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.restaurant_menu_rounded,
                            size: 18, color: _primary),
                        const SizedBox(width: 2),
                        Text(
                          r.difficulty,
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: _primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  r.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryContainer,
                    side: BorderSide(
                      color: _primaryContainer.withValues(alpha: 0.25),
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'View Recipe',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryRecipeCard extends StatelessWidget {
  const _SecondaryRecipeCard({
    required this.result,
    required this.onView,
  });

  final RecipeMatchResult result;
  final VoidCallback onView;

  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final Recipe r = result.recipe;
    return Material(
      color: _surfaceContainerLowest,
      elevation: 1,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 180,
            child: Image.network(
              r.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const ColoredBox(color: Color(0xFFFFF1E9)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  r.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    color: _onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Icon(Icons.schedule_rounded,
                        size: 18, color: _onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      r.cookTime,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        color: _onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(Icons.restaurant_menu_rounded,
                        size: 18, color: _onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text(
                      r.difficulty,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryContainer,
                    side: BorderSide(
                      color: _primaryContainer.withValues(alpha: 0.25),
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'View Recipe',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipPanel extends StatelessWidget {
  const _ChipPanel({
    required this.sortMode,
    required this.onProtein,
    required this.onCarb,
    required this.onVegan,
  });

  final _SortMode sortMode;
  final VoidCallback onProtein;
  final VoidCallback onCarb;
  final VoidCallback onVegan;

  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _surfaceContainerHighest = Color(0xFFFFDCC4);
  static const Color _primaryContainer = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: _surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _outlineVariant.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Looking for something else?',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: _onSurface,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _FilterChip(
                    label: 'Add more protein',
                    selected: sortMode == _SortMode.protein,
                    onTap: onProtein,
                  ),
                  _FilterChip(
                    label: 'Lower carb',
                    selected: sortMode == _SortMode.carb,
                    onTap: onCarb,
                  ),
                  _FilterChip(
                    label: 'Vegan only',
                    selected: false,
                    onTap: onVegan,
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Color _primaryContainer = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _primaryContainer : Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Color(0x14000000), blurRadius: 6),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.beVietnamPro(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected ? Colors.white : const Color(0xFF2F1400),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.onHome,
    required this.onScan,
    required this.onPantry,
    required this.onDiscovery,
    required this.onProfile,
  });

  final VoidCallback onHome;
  final VoidCallback onScan;
  final VoidCallback onPantry;
  final VoidCallback onDiscovery;
  final VoidCallback onProfile;

  static const Color _primary = Color(0xFF9D4300);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _secondaryFixed = Color(0xFFFFDCC4);
  static const Color _outlineVariant = Color(0xFFE0C0B1);

  @override
  Widget build(BuildContext context) {
    const List<_NavEntry> items = <_NavEntry>[
      _NavEntry(Icons.home_rounded, 'Home'),
      _NavEntry(Icons.document_scanner_rounded, 'Scan'),
      _NavEntry(Icons.inventory_2_rounded, 'Pantry'),
      _NavEntry(Icons.explore_rounded, 'Discovery'),
      _NavEntry(Icons.person_rounded, 'Profile'),
    ];

    final List<VoidCallback> actions = <VoidCallback>[
      onHome,
      onScan,
      onPantry,
      onDiscovery,
      onProfile,
    ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            border: Border(
              top: BorderSide(color: _outlineVariant.withValues(alpha: 0.15)),
            ),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x0F4C2706),
                blurRadius: 40,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List<Widget>.generate(items.length, (int i) {
                  final bool active = i == 1;
                  final _NavEntry item = items[i];
                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: actions[i],
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: active ? _secondaryFixed : null,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 24,
                                  color: active ? _primary : _secondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.label,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: active ? _primary : _secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavEntry {
  const _NavEntry(this.icon, this.label);

  final IconData icon;
  final String label;
}
