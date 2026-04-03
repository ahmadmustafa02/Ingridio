class RecipeIngredientLine {
  const RecipeIngredientLine({
    required this.name,
    required this.amountAtTwoServings,
    required this.unit,
    this.preparation,
    this.imageUrl,
  });

  final String name;
  final double amountAtTwoServings;
  final String unit;
  final String? preparation;
  final String? imageUrl;
}
