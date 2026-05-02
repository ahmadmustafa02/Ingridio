import 'package:flutter/foundation.dart';
import 'package:ingridio/data/mock_data.dart';
import 'package:ingridio/models/ingredient.dart';

class PantryManager extends ChangeNotifier {
  PantryManager._() {
    _items.addAll(MockData.mockPantry);
  }

  static final PantryManager instance = PantryManager._();

  final List<Ingredient> _items = <Ingredient>[];

  List<Ingredient> get items => List<Ingredient>.unmodifiable(_items);

  int get totalCount => _items.length;

  void add(Ingredient ingredient) {
    _items.add(ingredient);
    notifyListeners();
  }

  void removeById(String id) {
    _items.removeWhere((Ingredient e) => e.id == id);
    notifyListeners();
  }

  static String newId() =>
      'ing_${DateTime.now().microsecondsSinceEpoch}';
}
