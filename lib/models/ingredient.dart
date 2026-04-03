enum IngredientSource {
  camera,
  manual,
}

class Ingredient {
  const Ingredient({
    required this.id,
    required this.name,
    required this.category,
    this.quantity,
    this.unit,
    this.daysLeft,
    this.stockLevel,
    required this.source,
  });

  final String id;
  final String name;
  final String category;
  final int? quantity;
  final String? unit;
  final int? daysLeft;
  final String? stockLevel;
  final IngredientSource source;
}
