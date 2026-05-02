import 'package:ingridio/models/ingredient.dart';
import 'package:ingridio/models/recipe.dart';

class FoodVisionResult {
  const FoodVisionResult({
    required this.detectedIngredientNames,
    required this.recipes,
    required this.detectedIngredients,
  });

  final List<String> detectedIngredientNames;
  final List<Recipe> recipes;
  final List<Ingredient> detectedIngredients;
}
