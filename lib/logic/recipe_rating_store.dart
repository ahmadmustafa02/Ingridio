import 'package:flutter/foundation.dart';

class RecipeRatingStore extends ChangeNotifier {
  RecipeRatingStore._();

  static final RecipeRatingStore instance = RecipeRatingStore._();

  final Map<String, int> _stars = <String, int>{};

  int? starsFor(String recipeId) => _stars[recipeId];

  void setRating(String recipeId, int stars) {
    _stars[recipeId] = stars.clamp(1, 5);
    notifyListeners();
  }
}
