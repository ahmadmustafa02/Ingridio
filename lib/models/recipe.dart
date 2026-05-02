import 'package:ingridio/models/recipe_cooking_step.dart';
import 'package:ingridio/models/recipe_ingredient_line.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.cookTime,
    required this.difficulty,
    required this.imageUrl,
    this.cardSubtitle,
    this.showAiBadge = false,
    this.calories,
    this.tag,
    this.description,
    this.searchKeywords = const <String>[],
    this.ingredients = const <String>[],
    this.steps = const <String>[],
    this.ingredientLines,
    this.cookingSteps,
    this.proteinG,
    this.carbsG,
    this.fatsG,
    this.fiberG,
    this.stepTitles,
  });

  final String id;
  final String name;
  final String cuisine;
  final String cookTime;
  final String difficulty;
  final String imageUrl;
  final String? cardSubtitle;
  final bool showAiBadge;
  final int? calories;
  final String? tag;
  final String? description;
  final List<String> searchKeywords;
  final List<String> ingredients;
  final List<String> steps;
  final List<RecipeIngredientLine>? ingredientLines;
  final List<RecipeCookingStep>? cookingSteps;
  final int? proteinG;
  final int? carbsG;
  final int? fatsG;
  final int? fiberG;
  final List<String>? stepTitles;

  bool get hasNutrition =>
      proteinG != null ||
      carbsG != null ||
      fatsG != null ||
      fiberG != null;

  bool matchesSearch(String queryLower) {
    if (name.toLowerCase().contains(queryLower)) {
      return true;
    }
    if (cuisine.toLowerCase().contains(queryLower)) {
      return true;
    }
    if (description != null &&
        description!.toLowerCase().contains(queryLower)) {
      return true;
    }
    if (tag != null && tag!.toLowerCase().contains(queryLower)) {
      return true;
    }
    for (final String k in searchKeywords) {
      if (k.toLowerCase().contains(queryLower)) {
        return true;
      }
    }
    return false;
  }
}
