import 'package:flutter/foundation.dart';

class SavedRecipesStore extends ChangeNotifier {
  SavedRecipesStore._();

  static final SavedRecipesStore instance = SavedRecipesStore._();

  final Set<String> _ids = <String>{};

  Set<String> get ids => Set<String>.unmodifiable(_ids);

  bool isSaved(String recipeId) => _ids.contains(recipeId);

  void toggle(String recipeId) {
    if (_ids.contains(recipeId)) {
      _ids.remove(recipeId);
    } else {
      _ids.add(recipeId);
    }
    notifyListeners();
  }
}
