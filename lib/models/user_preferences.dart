class UserPreferences {
  const UserPreferences({
    this.displayName,
    required this.selectedCuisines,
    required this.selectedDiets,
  });

  final String? displayName;
  final List<String> selectedCuisines;
  final List<String> selectedDiets;
}
