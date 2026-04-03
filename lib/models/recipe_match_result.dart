import 'package:ingridio/models/recipe.dart';

class RecipeMatchResult {
  const RecipeMatchResult({
    required this.recipe,
    required this.matchPercent,
  });

  final Recipe recipe;
  final int matchPercent;
}
