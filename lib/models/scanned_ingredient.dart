enum IngredientConfidence { high, medium }

class ScannedIngredient {
  const ScannedIngredient({
    required this.name,
    required this.confidence,
  });

  final String name;
  final IngredientConfidence confidence;
}
