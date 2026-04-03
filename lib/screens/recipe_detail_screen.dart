import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingridio/logic/saved_recipes_store.dart';
import 'package:ingridio/models/recipe.dart';
import 'package:ingridio/models/recipe_cooking_step.dart';
import 'package:ingridio/models/recipe_ingredient_line.dart';
import 'package:ingridio/screens/cooking_mode_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    this.detectedIngredients = const <String>[],
  });

  final Recipe recipe;
  final List<String> detectedIngredients;

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  static const Color _primary = Color(0xFF9D4300);
  static const Color _primaryContainer = Color(0xFFF97316);
  static const Color _background = Color(0xFFFFF8F5);
  static const Color _onSurface = Color(0xFF2F1400);
  static const Color _onSurfaceVariant = Color(0xFF584237);
  static const Color _onPrimaryContainer = Color(0xFF582200);
  static const Color _secondary = Color(0xFF924C00);
  static const Color _surfaceContainerLow = Color(0xFFFFF1E9);
  static const Color _surfaceContainerHigh = Color(0xFFFFE3D1);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _outlineVariant = Color(0xFFE0C0B1);
  static const Color _tertiaryContainer = Color(0xFFC99000);
  static const Color _onTertiaryContainer = Color(0xFF442E00);

  int _servings = 2;

  Recipe get _r => widget.recipe;

  Set<String> get _detectedNorm => widget.detectedIngredients
      .map((String s) => s.toLowerCase().trim())
      .where((String s) => s.isNotEmpty)
      .toSet();

  bool get _hasPantryContext => _detectedNorm.isNotEmpty;

  bool _userHasName(String name) {
    final String n = name.toLowerCase().trim();
    if (_detectedNorm.contains(n)) {
      return true;
    }
    for (final String d in _detectedNorm) {
      if (d.contains(n) || n.contains(d)) {
        return true;
      }
    }
    return false;
  }

  List<RecipeCookingStep> get _steps {
    if (_r.cookingSteps != null && _r.cookingSteps!.isNotEmpty) {
      return _r.cookingSteps!;
    }
    return List<RecipeCookingStep>.generate(
      _r.steps.length,
      (int i) => RecipeCookingStep(
        title: 'Step ${i + 1}',
        body: _r.steps[i],
      ),
    );
  }

  String _formatAmount(double v) {
    if ((v - v.round()).abs() < 0.001) {
      return v.round().toString();
    }
    return v.toStringAsFixed(1);
  }

  double _scaledAmount(double amountAtTwo) {
    return (amountAtTwo / 2) * _servings;
  }

  void _openCooking() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CookingModeScreen(recipe: _r),
      ),
    );
  }

  void _toggleFavorite() {
    final SavedRecipesStore store = SavedRecipesStore.instance;
    final bool was = store.isSaved(_r.id);
    store.toggle(_r.id);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(was ? 'Recipe removed' : 'Recipe saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _share() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String get _cookTimeShort {
    final String t = _r.cookTime.replaceAll(' mins', 'm').replaceAll(' min', 'm');
    return t;
  }

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.paddingOf(context).top;
    final List<RecipeCookingStep> steps = _steps;

    return ListenableBuilder(
      listenable: SavedRecipesStore.instance,
      builder: (BuildContext context, Widget? child) {
        final bool saved = SavedRecipesStore.instance.isSaved(_r.id);
        return Scaffold(
          backgroundColor: _background,
          extendBodyBehindAppBar: true,
          body: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              CustomScrollView(
                slivers: <Widget>[
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 400,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Image.network(
                            _r.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const ColoredBox(color: _surfaceContainerLow),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: <Color>[
                                  Colors.black.withValues(alpha: 0.35),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                                stops: const <double>[0.0, 0.35, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            right: 20,
                            bottom: 28,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                if (_r.showAiBadge ||
                                    _r.tag == 'Best Match' ||
                                    _r.tag == 'AI Top Pick' ||
                                    _r.tag == 'AI Smart Pick')
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _tertiaryContainer,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Icon(
                                          Icons.bolt_rounded,
                                          size: 16,
                                          color: _onTertiaryContainer,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'AI Recommended',
                                          style: GoogleFonts.beVietnamPro(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 11,
                                            letterSpacing: 0.6,
                                            color: _onTertiaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Text(
                                  _r.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 34,
                                    height: 1.1,
                                    letterSpacing: -0.8,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Transform.translate(
                      offset: const Offset(0, -32),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            _StatsBento(
                              recipe: _r,
                              servings: _servings,
                              primary: _primary,
                              secondary: _secondary,
                              onSurface: _onSurface,
                              surfaceLowest: _surfaceContainerLowest,
                            ),
                            const SizedBox(height: 18),
                            _ServingAdjuster(
                              servings: _servings,
                              onChanged: (int v) => setState(() => _servings = v),
                              secondary: _secondary,
                              onSurface: _onSurface,
                              surfaceHigh: _surfaceContainerHigh,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints c) {
                          final bool wide = c.maxWidth >= 900;
                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: _IngredientsColumn(
                                    recipe: _r,
                                    servings: _servings,
                                    hasPantryContext: _hasPantryContext,
                                    userHasName: _userHasName,
                                    formatAmount: _formatAmount,
                                    scaledAmount: _scaledAmount,
                                    secondary: _secondary,
                                    onSurface: _onSurface,
                                    onSurfaceVariant: _onSurfaceVariant,
                                    surfaceLow: _surfaceContainerLow,
                                    surfaceHigh: _surfaceContainerHigh,
                                    primaryContainer: _primaryContainer,
                                    outlineVariant: _outlineVariant,
                                  ),
                                ),
                                const SizedBox(width: 36),
                                Expanded(
                                  flex: 2,
                                  child: _StepsNutritionColumn(
                                    steps: steps,
                                    recipe: _r,
                                    surfaceLow: _surfaceContainerLow,
                                    secondary: _secondary,
                                    onSurface: _onSurface,
                                    onSurfaceVariant: _onSurfaceVariant,
                                    primaryContainer: _primaryContainer,
                                    onPrimaryContainer: _onPrimaryContainer,
                                    surfaceHigh: _surfaceContainerHigh,
                                    outlineVariant: _outlineVariant,
                                  ),
                                ),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              _IngredientsColumn(
                                recipe: _r,
                                servings: _servings,
                                hasPantryContext: _hasPantryContext,
                                userHasName: _userHasName,
                                formatAmount: _formatAmount,
                                scaledAmount: _scaledAmount,
                                secondary: _secondary,
                                onSurface: _onSurface,
                                onSurfaceVariant: _onSurfaceVariant,
                                surfaceLow: _surfaceContainerLow,
                                surfaceHigh: _surfaceContainerHigh,
                                primaryContainer: _primaryContainer,
                                outlineVariant: _outlineVariant,
                              ),
                              const SizedBox(height: 36),
                              _StepsNutritionColumn(
                                steps: steps,
                                recipe: _r,
                                surfaceLow: _surfaceContainerLow,
                                secondary: _secondary,
                                onSurface: _onSurface,
                                onSurfaceVariant: _onSurfaceVariant,
                                primaryContainer: _primaryContainer,
                                onPrimaryContainer: _onPrimaryContainer,
                                surfaceHigh: _surfaceContainerHigh,
                                outlineVariant: _outlineVariant,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      height: topPad + 56,
                      padding: EdgeInsets.only(top: topPad),
                      color: _background.withValues(alpha: 0.88),
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                            color: _primary,
                            iconSize: 26,
                          ),
                          Expanded(
                            child: Text(
                              'Ingridio',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                letterSpacing: -0.4,
                                color: _onSurface,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _toggleFavorite,
                            icon: Icon(
                              saved
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: saved ? Colors.redAccent : _primary,
                            ),
                          ),
                          IconButton(
                            onPressed: _share,
                            icon: const Icon(Icons.share_rounded),
                            color: _primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _GlassCookBar(
                  servings: _servings,
                  cookTimeShort: _cookTimeShort,
                  onStart: _openCooking,
                  onSurface: _onSurface,
                  secondary: _secondary,
                  primary: _primary,
                  primaryContainer: _primaryContainer,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatsBento extends StatelessWidget {
  const _StatsBento({
    required this.recipe,
    required this.servings,
    required this.primary,
    required this.secondary,
    required this.onSurface,
    required this.surfaceLowest,
  });

  final Recipe recipe;
  final int servings;
  final Color primary;
  final Color secondary;
  final Color onSurface;
  final Color surfaceLowest;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final int cols = c.maxWidth >= 520 ? 4 : 2;
        final List<_StatItem> items = <_StatItem>[
          _StatItem(Icons.schedule_rounded, 'Time', recipe.cookTime.toUpperCase()),
          _StatItem(Icons.tune_rounded, 'Difficulty', recipe.difficulty),
          _StatItem(
            Icons.local_fire_department_rounded,
            'Calories',
            recipe.calories != null ? '${recipe.calories} kcal' : '—',
          ),
          _StatItem(
            Icons.group_rounded,
            'Servings',
            '$servings ${servings == 1 ? 'Person' : 'People'}',
          ),
        ];
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: cols == 4 ? 1.05 : 1.35,
          children: List<Widget>.generate(items.length, (int i) {
            final _StatItem it = items[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              decoration: BoxDecoration(
                color: surfaceLowest,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x0A4C2706),
                    blurRadius: 28,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(it.icon, color: primary, size: 26),
                  const SizedBox(height: 8),
                  Text(
                    it.label,
                    style: GoogleFonts.beVietnamPro(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    it.value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

class _StatItem {
  const _StatItem(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

class _ServingAdjuster extends StatelessWidget {
  const _ServingAdjuster({
    required this.servings,
    required this.onChanged,
    required this.secondary,
    required this.onSurface,
    required this.surfaceHigh,
  });

  final int servings;
  final ValueChanged<int> onChanged;
  final Color secondary;
  final Color onSurface;
  final Color surfaceHigh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceHigh.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton.filledTonal(
            onPressed: servings > 1 ? () => onChanged(servings - 1) : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: secondary,
            ),
            icon: const Icon(Icons.remove_rounded),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '$servings Servings',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: onSurface,
              ),
            ),
          ),
          IconButton.filledTonal(
            onPressed: servings < 10 ? () => onChanged(servings + 1) : null,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: secondary,
            ),
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _IngredientsColumn extends StatelessWidget {
  const _IngredientsColumn({
    required this.recipe,
    required this.servings,
    required this.hasPantryContext,
    required this.userHasName,
    required this.formatAmount,
    required this.scaledAmount,
    required this.secondary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceLow,
    required this.surfaceHigh,
    required this.primaryContainer,
    required this.outlineVariant,
  });

  final Recipe recipe;
  final int servings;
  final bool hasPantryContext;
  final bool Function(String name) userHasName;
  final String Function(double v) formatAmount;
  final double Function(double base) scaledAmount;
  final Color secondary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceLow;
  final Color surfaceHigh;
  final Color primaryContainer;
  final Color outlineVariant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Ingredients',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: secondary,
          ),
        ),
        const SizedBox(height: 18),
        if (recipe.ingredientLines != null &&
            recipe.ingredientLines!.isNotEmpty)
          ...recipe.ingredientLines!.map((RecipeIngredientLine line) {
            final double scaled = scaledAmount(line.amountAtTwoServings);
            final String amountPart = line.unit.isEmpty
                ? formatAmount(scaled)
                : '${formatAmount(scaled)} ${line.unit}'.trim();
            final String detailLine = line.preparation != null
                ? '$amountPart, ${line.preparation}'
                : amountPart;
            final bool has = hasPantryContext && userHasName(line.name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: surfaceLow,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(14),
                  splashColor: surfaceHigh.withValues(alpha: 0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: <Widget>[
                        ClipOval(
                          child: SizedBox(
                            width: 48,
                            height: 48,
                            child: line.imageUrl != null
                                ? Image.network(
                                    line.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _IngredientPlaceholder(
                                            primaryContainer: primaryContainer),
                                  )
                                : _IngredientPlaceholder(
                                    primaryContainer: primaryContainer),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                line.name,
                                style: GoogleFonts.beVietnamPro(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: onSurface,
                                ),
                              ),
                              Text(
                                detailLine,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 13,
                                  color: onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          has
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: has ? primaryContainer : outlineVariant,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          })
        else if (recipe.ingredients.isNotEmpty)
          ...recipe.ingredients.map((String name) {
            final bool has = hasPantryContext && userHasName(name);
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: surfaceLow,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: <Widget>[
                      ClipOval(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: _IngredientPlaceholder(
                              primaryContainer: primaryContainer),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          name,
                          style: GoogleFonts.beVietnamPro(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: onSurface,
                          ),
                        ),
                      ),
                      Icon(
                        hasPantryContext
                            ? (has
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined)
                            : Icons.circle_outlined,
                        color: hasPantryContext && has
                            ? primaryContainer
                            : outlineVariant,
                        size: 26,
                      ),
                    ],
                  ),
                ),
              ),
            );
          })
        else
          Text(
            'No ingredients listed.',
            style: GoogleFonts.beVietnamPro(color: onSurfaceVariant),
          ),
      ],
    );
  }
}

class _IngredientPlaceholder extends StatelessWidget {
  const _IngredientPlaceholder({required this.primaryContainer});

  final Color primaryContainer;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Icon(Icons.restaurant_rounded, color: primaryContainer, size: 24),
    );
  }
}

class _StepsNutritionColumn extends StatelessWidget {
  const _StepsNutritionColumn({
    required this.steps,
    required this.recipe,
    required this.surfaceLow,
    required this.secondary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.surfaceHigh,
    required this.outlineVariant,
  });

  final List<RecipeCookingStep> steps;
  final Recipe recipe;
  final Color surfaceLow;
  final Color secondary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color surfaceHigh;
  final Color outlineVariant;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Cooking Steps',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: secondary,
          ),
        ),
        const SizedBox(height: 22),
        ...List<Widget>.generate(steps.length, (int i) {
          final RecipeCookingStep s = steps[i];
          final bool isFirst = i == 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 28),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isFirst ? primaryContainer : surfaceHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color:
                          isFirst ? onPrimaryContainer : onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        s.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.body,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 15,
                          height: 1.55,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        if (recipe.hasNutrition) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Nutritional Info',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: secondary,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: _nutritionChildren(recipe, onSurface, onSurfaceVariant, outlineVariant),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  static List<Widget> _nutritionChildren(
    Recipe recipe,
    Color onSurface,
    Color onSurfaceVariant,
    Color outlineVariant,
  ) {
    final List<(String, int)> parts = <(String, int)>[
      if (recipe.proteinG != null) ('Protein', recipe.proteinG!),
      if (recipe.carbsG != null) ('Carbs', recipe.carbsG!),
      if (recipe.fatsG != null) ('Fats', recipe.fatsG!),
      if (recipe.fiberG != null) ('Fiber', recipe.fiberG!),
    ];
    final List<Widget> out = <Widget>[];
    for (int i = 0; i < parts.length; i++) {
      final (String label, int value) = parts[i];
      out.add(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label.toUpperCase(),
              style: GoogleFonts.beVietnamPro(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${value}g',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 24,
                color: onSurface,
              ),
            ),
          ],
        ),
      );
      if (i < parts.length - 1) {
        out.add(
          Container(
            width: 1,
            height: 36,
            color: outlineVariant.withValues(alpha: 0.35),
          ),
        );
      }
    }
    return out;
  }
}

class _GlassCookBar extends StatelessWidget {
  const _GlassCookBar({
    required this.servings,
    required this.cookTimeShort,
    required this.onStart,
    required this.onSurface,
    required this.secondary,
    required this.primary,
    required this.primaryContainer,
  });

  final int servings;
  final String cookTimeShort;
  final VoidCallback onStart;
  final Color onSurface;
  final Color secondary;
  final Color primary;
  final Color primaryContainer;

  @override
  Widget build(BuildContext context) {
    final double bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(22, 12, 22, bottom + 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x264C2706),
                  blurRadius: 28,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Ready to cook?',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: secondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$servings Servings • $cookTimeShort',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: <Color>[primaryContainer, primary],
                    ),
                    boxShadow: const <BoxShadow>[
                      BoxShadow(
                        color: Color(0x334C2706),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onStart,
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 16,
                        ),
                        child: Text(
                          'Start Cooking',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.white,
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
      ),
    );
  }
}
