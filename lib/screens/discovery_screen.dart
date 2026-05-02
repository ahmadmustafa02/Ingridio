import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/data/mock_data.dart';
import 'package:ingridio/models/recipe.dart';
import 'package:ingridio/screens/profile_screen.dart';
import 'package:ingridio/screens/recipe_detail_screen.dart';

class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _CuisineItem {
  const _CuisineItem(this.label, this.imageUrl);

  final String label;
  final String imageUrl;
}

class _DiscoveryScreenState extends State<DiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCuisine;
  final Set<String> _savedRecipeIds = <String>{};

  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _outline = Color(0xFF8C7164);

  static const List<_CuisineItem> _cuisineItems = <_CuisineItem>[
    _CuisineItem('Pakistani', MockData.cuisineCirclePakistaniUrl),
    _CuisineItem('Italian', MockData.cuisineCircleItalianUrl),
    _CuisineItem('Japanese', MockData.cuisineCircleJapaneseUrl),
    _CuisineItem('Mexican', MockData.cuisineCircleMexicanUrl),
  ];

  Recipe get _trendingLarge => MockData.mockRecipes[0];
  Recipe get _trendingSmallA => MockData.mockRecipes[1];
  Recipe get _trendingSmallB => MockData.mockRecipes[2];
  List<Recipe> get _healthyRecipes =>
      <Recipe>[MockData.mockRecipes[3], MockData.mockRecipes[4]];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _searchActive => _searchController.text.trim().isNotEmpty;

  List<Recipe> get _searchResults {
    final String q = _searchController.text.trim().toLowerCase();
    return MockData.mockRecipes
        .where((Recipe r) => r.matchesSearch(q))
        .toList();
  }

  List<Recipe> get _cuisineResults {
    if (_selectedCuisine == null) {
      return <Recipe>[];
    }
    return MockData.mockRecipes
        .where((Recipe r) => r.cuisine == _selectedCuisine)
        .toList();
  }

  void _openRecipe(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailScreen(recipe: recipe),
      ),
    );
  }

  void _toggleCuisine(String label) {
    setState(() {
      if (_selectedCuisine == label) {
        _selectedCuisine = null;
      } else {
        _selectedCuisine = label;
      }
    });
  }

  void _toggleSaved(String id) {
    setState(() {
      if (_savedRecipeIds.contains(id)) {
        _savedRecipeIds.remove(id);
      } else {
        _savedRecipeIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double horizontal = MediaQuery.sizeOf(context).width < 380 ? 20 : 24;
    final double bottomPad = MediaQuery.paddingOf(context).bottom + 100;

    return ColoredBox(
      color: _background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ColoredBox(
            color: _background,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 12),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Ingridio',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: _onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.settings_rounded,
                        color: _primaryContainer,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _searchActive
                ? _buildSearchOnlyBody(horizontal, bottomPad)
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontal,
                      0,
                      horizontal,
                      bottomPad,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        const SizedBox(height: 8),
                        Text(
                          'Explore New Flavors',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1.05,
                            letterSpacing: -0.8,
                            color: _onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Curated recipes for your culinary journey.',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _secondary,
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildSearchField(),
                        const SizedBox(height: 28),
                        if (_selectedCuisine == null) ...<Widget>[
                          _buildTrendingSection(horizontal),
                          const SizedBox(height: 40),
                        ],
                        _buildCuisineSection(horizontal),
                        if (_selectedCuisine != null) ...<Widget>[
                          const SizedBox(height: 20),
                          _buildCuisineResultsSection(),
                        ],
                        if (_selectedCuisine == null) ...<Widget>[
                          const SizedBox(height: 36),
                          _buildHealthySection(horizontal),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOnlyBody(double horizontal, double bottomPad) {
    final List<Recipe> results = _searchResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildSearchField(),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? Center(
                  child: Text(
                    'No recipes found',
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    horizontal,
                    0,
                    horizontal,
                    bottomPad,
                  ),
                  itemCount: results.length,
                  itemBuilder: (_, int i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SearchResultTile(
                        recipe: results[i],
                        onTap: () => _openRecipe(results[i]),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      style: GoogleFonts.beVietnamPro(
        color: _onSurface,
        fontWeight: FontWeight.w500,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Search ingredients, cuisines, or dishes...',
        hintStyle: GoogleFonts.beVietnamPro(
          color: _outline.withValues(alpha: 0.9),
        ),
        prefixIcon: const Icon(Icons.search_rounded, color: _primary),
        filled: true,
        fillColor: _surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
      ),
    );
  }

  Widget _buildTrendingSection(double horizontal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Trending Now',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 420,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              if (c.maxWidth >= 720) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      flex: 8,
                      child: _TrendingLargeCard(
                        recipe: _trendingLarge,
                        onTap: () => _openRecipe(_trendingLarge),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: _TrendingSmallCard(
                              recipe: _trendingSmallA,
                              onTap: () => _openRecipe(_trendingSmallA),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: _TrendingSmallCard(
                              recipe: _trendingSmallB,
                              onTap: () => _openRecipe(_trendingSmallB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: <Widget>[
                  SizedBox(
                    height: 220,
                    child: _TrendingLargeCard(
                      recipe: _trendingLarge,
                      onTap: () => _openRecipe(_trendingLarge),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: _TrendingSmallCard(
                            recipe: _trendingSmallA,
                            onTap: () => _openRecipe(_trendingSmallA),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _TrendingSmallCard(
                            recipe: _trendingSmallB,
                            onTap: () => _openRecipe(_trendingSmallB),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCuisineSection(double horizontal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Cuisine Specialties',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: _cuisineItems.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (BuildContext context, int index) {
              final _CuisineItem item = _cuisineItems[index];
              final bool active = _selectedCuisine == item.label;
              return _CuisineCircleTile(
                item: item,
                active: active,
                onTap: () => _toggleCuisine(item.label),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCuisineResultsSection() {
    final List<Recipe> list = _cuisineResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '$_selectedCuisine recipes',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _onSurface,
          ),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Text(
            'No recipes in this cuisine yet.',
            style: GoogleFonts.beVietnamPro(
              color: _onSurfaceVariant,
              fontSize: 15,
            ),
          )
        else
          ...list.map(
            (Recipe r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SearchResultTile(
                recipe: r,
                onTap: () => _openRecipe(r),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHealthySection(double horizontal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Healthy & Guilt-Free',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See Nutrition',
                style: GoogleFonts.beVietnamPro(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: _primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ..._healthyRecipes.map(
          (Recipe r) => Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: _HealthyRecipeCard(
              recipe: r,
              saved: _savedRecipeIds.contains(r.id),
              onHeart: () => _toggleSaved(r.id),
              onTap: () => _openRecipe(r),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrendingLargeCard extends StatelessWidget {
  const _TrendingLargeCard({
    required this.recipe,
    required this.onTap,
  });

  final Recipe recipe;
  final VoidCallback onTap;

  static const Color _tertiaryContainer = Color(0xFFC99000);

  @override
  Widget build(BuildContext context) {
    final String? tag = recipe.tag;
    final bool showAi = tag != null && tag.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(
                recipe.imageUrl,
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
                      Colors.black.withValues(alpha: 0.05),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.8),
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
                    if (showAi)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.star_rounded,
                                    size: 18,
                                    color: _tertiaryContainer,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    tag,
                                    style: GoogleFonts.beVietnamPro(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF2F1400),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    Text(
                      recipe.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      recipe.cardSubtitle ??
                          '${recipe.cookTime} • ${recipe.cuisine}',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.82),
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

class _TrendingSmallCard extends StatelessWidget {
  const _TrendingSmallCard({
    required this.recipe,
    required this.onTap,
  });

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.network(
                recipe.imageUrl,
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
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.72),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Text(
                  recipe.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

class _CuisineCircleTile extends StatelessWidget {
  const _CuisineCircleTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final _CuisineItem item;
  final bool active;
  final VoidCallback onTap;

  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _primaryContainer = Color(0xFFF97316);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? _primaryContainer : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipOval(
                    child: ColoredBox(
                      color: _surfaceContainerHigh,
                      child: Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.restaurant),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.label,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: const Color(0xFF2F1400),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.recipe,
    required this.onTap,
  });

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF1E9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  recipe.imageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFFFE3D1),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF2F1400),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.cuisine} • ${recipe.cookTime}',
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 13,
                        color: const Color(0xFF584237),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8C7164)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HealthyRecipeCard extends StatelessWidget {
  const _HealthyRecipeCard({
    required this.recipe,
    required this.saved,
    required this.onHeart,
    required this.onTap,
  });

  final Recipe recipe;
  final bool saved;
  final VoidCallback onHeart;
  final VoidCallback onTap;

  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _tertiaryContainer = Color(0xFFC99000);
  static const Color _onTertiaryContainer = Color(0xFF442E00);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _onPrimaryContainer = Color(0xFF582200);
  static const Color _outline = Color(0xFF8C7164);

  @override
  Widget build(BuildContext context) {
    final String? tag = recipe.tag;
    final bool hasTag = tag != null && tag.isNotEmpty;
    final bool lowCarb = tag == 'Low Carb';

    return Material(
      color: _surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final bool wide = c.maxWidth > 560;
              final Widget image = ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  recipe.imageUrl,
                  width: wide ? 192 : double.infinity,
                  height: 192,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 192,
                    color: _surfaceContainerHigh,
                  ),
                ),
              );
              final Widget body = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            if (hasTag)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: lowCarb
                                      ? _tertiaryContainer
                                      : _primaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  tag.toUpperCase(),
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: lowCarb
                                        ? _onTertiaryContainer
                                        : _onPrimaryContainer,
                                  ),
                                ),
                              ),
                            if (hasTag) const SizedBox(height: 8),
                            Text(
                              recipe.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: onHeart,
                        icon: Icon(
                          saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: saved ? const Color(0xFFBA1A1A) : _outline,
                        ),
                      ),
                    ],
                  ),
                  if (recipe.description != null) ...<Widget>[
                    const SizedBox(height: 10),
                    Text(
                      recipe.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.beVietnamPro(
                        fontSize: 14,
                        height: 1.45,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  Row(
                    children: <Widget>[
                      Icon(Icons.schedule_rounded,
                          size: 16, color: _secondary),
                      const SizedBox(width: 4),
                      Text(
                        recipe.cookTime.toUpperCase(),
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _secondary,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Icon(Icons.local_fire_department_rounded,
                          size: 16, color: _secondary),
                      const SizedBox(width: 4),
                      Text(
                        '${recipe.calories ?? 0} KCAL',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              );

              if (wide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    image,
                    const SizedBox(width: 22),
                    Expanded(child: body),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[image, const SizedBox(height: 16), body],
              );
            },
          ),
        ),
      ),
    );
  }
}
