import 'package:ingridio/models/recipe.dart';
import 'package:ingridio/models/recipe_match_result.dart';

class RecipeMatcher {
  RecipeMatcher._();

  static Set<String> _normalizeSet(List<String> items) {
    return items
        .map((String s) => s.toLowerCase().trim())
        .where((String s) => s.isNotEmpty)
        .toSet();
  }

  static int matchPercentFor(Recipe recipe, Set<String> detected) {
    if (recipe.ingredients.isEmpty) {
      return 0;
    }
    int matches = 0;
    for (final String ing in recipe.ingredients) {
      final String n = ing.toLowerCase().trim();
      if (detected.contains(n)) {
        matches++;
        continue;
      }
      for (final String d in detected) {
        if (d == n || d.contains(n) || n.contains(d)) {
          matches++;
          break;
        }
      }
    }
    return ((matches / recipe.ingredients.length) * 100).round();
  }

  static List<RecipeMatchResult> match(
    List<String> detectedIngredients,
    List<Recipe> catalog,
  ) {
    final Set<String> detected = _normalizeSet(detectedIngredients);
    final List<RecipeMatchResult> out = <RecipeMatchResult>[];
    for (final Recipe r in catalog) {
      if (r.ingredients.isEmpty) {
        continue;
      }
      out.add(
        RecipeMatchResult(
          recipe: r,
          matchPercent: matchPercentFor(r, detected),
        ),
      );
    }
    out.sort(
      (RecipeMatchResult a, RecipeMatchResult b) =>
          b.matchPercent.compareTo(a.matchPercent),
    );
    return out;
  }
}
