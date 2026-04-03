import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/data/mock_data.dart';
import 'package:ingridio/logic/pantry_manager.dart';
import 'package:ingridio/models/recipe.dart';
import 'package:ingridio/screens/discovery_screen.dart';
import 'package:ingridio/screens/pantry_screen.dart';
import 'package:ingridio/screens/profile_screen.dart';
import 'package:ingridio/screens/recipe_detail_screen.dart';
import 'package:ingridio/screens/scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _surfaceContainerHighest = Color(0xFFFFDCC4);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _secondaryFixed = Color(0xFFFFDCC4);
  static const Color _onSecondaryFixedVariant = Color(0xFF6F3800);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _tertiaryContainer = Color(0xFFC99000);
  static const Color _onTertiaryContainer = Color(0xFF442E00);
  static const Color _onSecondaryContainer = Color(0xFF673400);

  static const int _tabHome = 0;
  static const int _tabScan = 1;
  static const int _tabPantry = 2;
  static const int _tabDiscovery = 3;
  static const int _tabProfile = 4;

  int _tabIndex = _tabHome;
  final Set<String> _selectedChips = <String>{MockData.homeDietChipLabels.first};

  void _openRecipe(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }

  void _setTab(int index) {
    setState(() => _tabIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double navBarHeight = 72 + bottomInset;

    return Scaffold(
      backgroundColor: _background,
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          IndexedStack(
            index: _tabIndex,
            children: <Widget>[
              _HomeTab(
                selectedChips: _selectedChips,
                onChipToggle: (String label) {
                  setState(() {
                    if (_selectedChips.contains(label)) {
                      _selectedChips.remove(label);
                    } else {
                      _selectedChips.add(label);
                    }
                  });
                },
                onStartCooking: () =>
                    _openRecipe(MockData.recipeChanaChaat),
                onRecipeTap: _openRecipe,
                onSeeAll: () => _setTab(_tabDiscovery),
                onReviewPantry: () => _setTab(_tabPantry),
                onSettings: () => _setTab(_tabProfile),
                bottomContentPadding: navBarHeight + 56,
              ),
              const ScanScreen(),
              const PantryScreen(),
              const DiscoveryScreen(),
              const ProfileScreen(),
            ],
          ),
          Positioned(
            right: 24,
            bottom: navBarHeight + 16,
            child: Material(
              color: _primaryContainer,
              elevation: 8,
              shadowColor: const Color(0x669D4300),
              shape: const CircleBorder(
                side: BorderSide(color: Colors.white, width: 4),
              ),
              child: InkWell(
                onTap: () => _setTab(_tabScan),
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 64,
                  height: 64,
                  child: Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _GlassBottomNav(
        currentIndex: _tabIndex,
        onTap: _setTab,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.selectedChips,
    required this.onChipToggle,
    required this.onStartCooking,
    required this.onRecipeTap,
    required this.onSeeAll,
    required this.onReviewPantry,
    required this.onSettings,
    required this.bottomContentPadding,
  });

  final Set<String> selectedChips;
  final void Function(String label) onChipToggle;
  final VoidCallback onStartCooking;
  final void Function(Recipe recipe) onRecipeTap;
  final VoidCallback onSeeAll;
  final VoidCallback onReviewPantry;
  final VoidCallback onSettings;
  final double bottomContentPadding;

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
  static const Color _secondaryFixed = Color(0xFFFFDCC4);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _tertiaryContainer = Color(0xFFC99000);
  static const Color _onTertiaryContainer = Color(0xFF442E00);
  static const Color _onSecondaryContainer = Color(0xFF673400);

  @override
  Widget build(BuildContext context) {
    final double horizontal = MediaQuery.sizeOf(context).width < 380 ? 20 : 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ColoredBox(
          color: _background,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _primaryContainer,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          MockData.profileAvatarUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: _surfaceContainerHigh,
                            child: Icon(Icons.person, color: _secondary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Ingridio',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                          color: _onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: onSettings,
                    icon: const Icon(
                      Icons.settings_rounded,
                      color: _primaryContainer,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomContentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: _HeroCard(onStartCooking: onStartCooking),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: horizontal),
                    scrollDirection: Axis.horizontal,
                    itemCount: MockData.homeDietChipLabels.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (BuildContext context, int index) {
                      final String label =
                          MockData.homeDietChipLabels[index];
                      final bool selected = selectedChips.contains(label);
                      return _DietChipPill(
                        label: label,
                        selected: selected,
                        onTap: () => onChipToggle(label),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 44),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Curated Picks',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                              color: _onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Based on your taste profile',
                            style: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w500,
                              color: _secondary,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: onSeeAll,
                        child: Text(
                          'See all',
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: _CuratedBento(
                    onRecipeTap: onRecipeTap,
                  ),
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontal),
                  child: ListenableBuilder(
                    listenable: PantryManager.instance,
                    builder: (BuildContext context, Widget? child) {
                      return _InventoryCard(
                        ingredientCount: PantryManager.instance.totalCount,
                        onReviewPantry: onReviewPantry,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onStartCooking});

  final VoidCallback onStartCooking;

  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _primary = Color(0xFF9D4300);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: _surfaceContainerLow,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool wide = constraints.maxWidth > 560;
            final Widget textBlock = Padding(
              padding: const EdgeInsets.all(26),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    MockData.heroEyebrow,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: _secondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    MockData.heroTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      letterSpacing: -0.8,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    MockData.heroSubtitle,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 17,
                      height: 1.45,
                      color: _onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 22),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: <Color>[_primaryContainer, _primary],
                      ),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x1A4C2706),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onStartCooking,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          child: Text(
                            'Start Cooking',
                            style: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );

            final Widget imageBlock = SizedBox(
              height: wide ? null : 192,
              width: wide ? constraints.maxWidth * 0.34 : double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.network(
                    MockData.heroImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: _surfaceContainerLow),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: wide
                            ? Alignment.centerRight
                            : Alignment.topCenter,
                        end: wide
                            ? Alignment.centerLeft
                            : Alignment.bottomCenter,
                        colors: <Color>[
                          _surfaceContainerLow.withValues(alpha: 0),
                          _surfaceContainerLow.withValues(alpha: 0.25),
                          _surfaceContainerLow,
                        ],
                        stops: wide
                            ? const <double>[0.0, 0.35, 1.0]
                            : const <double>[0.0, 0.2, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            );

            if (wide) {
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(flex: 3, child: textBlock),
                    Expanded(flex: 2, child: imageBlock),
                  ],
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[textBlock, imageBlock],
            );
          },
        ),
      ),
    );
  }
}

class _DietChipPill extends StatelessWidget {
  const _DietChipPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const Color _secondaryFixed = Color(0xFFFFDCC4);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _onSecondaryFixedVariant = Color(0xFF6F3800);
  static const Color _onSurfaceVariant = Color(0xFF584237);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _secondaryFixed : _surfaceContainerHigh,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.beVietnamPro(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: selected ? _onSecondaryFixedVariant : _onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CuratedBento extends StatelessWidget {
  const _CuratedBento({required this.onRecipeTap});

  final void Function(Recipe recipe) onRecipeTap;

  static const Color _tertiaryContainer = Color(0xFFC99000);
  static const Color _onTertiaryContainer = Color(0xFF442E00);

  @override
  Widget build(BuildContext context) {
    final Recipe featured = MockData.recipeChanaChaat;
    final Recipe r2 = MockData.recipeSeekhKebabs;
    final Recipe r3 = MockData.recipeBeefNihari;

    return Column(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onRecipeTap(featured),
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Image.network(
                      featured.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const ColoredBox(color: Color(0xFFFFE3D1)),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.black.withValues(alpha: 0),
                            Colors.black.withValues(alpha: 0.35),
                            Colors.black.withValues(alpha: 0.62),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      right: 22,
                      bottom: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (featured.showAiBadge)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _tertiaryContainer,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'AI SMART PICK',
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                  color: _onTertiaryContainer,
                                ),
                              ),
                            ),
                          if (featured.showAiBadge) const SizedBox(height: 10),
                          Text(
                            featured.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (featured.cardSubtitle != null) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              featured.cardSubtitle!,
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: _SmallRecipeCard(
                recipe: r2,
                onTap: () => onRecipeTap(r2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _SmallRecipeCard(
                recipe: r3,
                onTap: () => onRecipeTap(r3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SmallRecipeCard extends StatelessWidget {
  const _SmallRecipeCard({
    required this.recipe,
    required this.onTap,
  });

  final Recipe recipe;
  final VoidCallback onTap;

  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _outlineVariant = Color(0xFFE0C0B1);

  String get _timeUpper {
    return recipe.cookTime.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surfaceContainerLowest,
      elevation: 0,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _outlineVariant.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const ColoredBox(color: Color(0xFFFFF1E9)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                recipe.name,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  height: 1.2,
                  color: _onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: _secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _timeUpper,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                      color: _secondary,
                    ),
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

class _InventoryCard extends StatelessWidget {
  const _InventoryCard({
    required this.ingredientCount,
    required this.onReviewPantry,
  });

  final int ingredientCount;
  final VoidCallback onReviewPantry;

  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _surfaceContainerHighest = Color(0xFFFFDCC4);
  static const Color _onSecondaryContainer = Color(0xFF673400);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: _surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Inventory Check',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200),
                      child: Text(
                        '$ingredientCount ingredients in your pantry',
                        style: GoogleFonts.beVietnamPro(
                          color: _onSurfaceVariant,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Material(
                      color: _surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        onTap: onReviewPantry,
                        borderRadius: BorderRadius.circular(999),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),
                          child: Text(
                            'Review Pantry',
                            style: GoogleFonts.beVietnamPro(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: _onSecondaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerRight,
                  children: <Widget>[
                    const Align(
                      alignment: Alignment.topRight,
                      child: _IngredientBubble(icon: Icons.egg_rounded),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Transform.translate(
                        offset: const Offset(-22, 0),
                        child: const _IngredientBubble(
                          icon: Icons.restaurant_rounded,
                        ),
                      ),
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

class _IngredientBubble extends StatelessWidget {
  const _IngredientBubble({required this.icon});

  final IconData icon;

  static const Color _primary = Color(0xFF9D4300);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: _primary, size: 28),
        ),
      ),
    );
  }
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final void Function(int index) onTap;

  static const Color _primary = Color(0xFF9D4300);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _secondaryFixed = Color(0xFFFFDCC4);
  static const Color _outlineVariant = Color(0xFFE0C0B1);

  @override
  Widget build(BuildContext context) {
    const List<_NavItem> items = <_NavItem>[
      _NavItem(Icons.home_rounded, 'Home'),
      _NavItem(Icons.document_scanner_rounded, 'Scan'),
      _NavItem(Icons.inventory_2_rounded, 'Pantry'),
      _NavItem(Icons.explore_rounded, 'Discovery'),
      _NavItem(Icons.person_rounded, 'Profile'),
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
                  final _NavItem item = items[i];
                  final bool active = i == currentIndex;
                  return Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onTap(i),
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

class _NavItem {
  const _NavItem(this.icon, this.label);

  final IconData icon;
  final String label;
}
