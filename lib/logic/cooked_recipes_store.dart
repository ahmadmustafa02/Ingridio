import 'package:flutter/foundation.dart';

class CookedRecipesStore extends ChangeNotifier {
  CookedRecipesStore._();

  static final CookedRecipesStore instance = CookedRecipesStore._();

  final Set<String> _ids = <String>{};

  bool contains(String recipeId) => _ids.contains(recipeId);

  void add(String recipeId) {
    _ids.add(recipeId);
    notifyListeners();
  }
}
