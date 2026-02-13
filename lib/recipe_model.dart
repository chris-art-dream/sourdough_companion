class Recipe {
  final String title;
  final String description;
  final String imageEmoji;
  final String difficulty;
  final double hydration;
  final String ingredients;
  final List<RecipeStep> steps;
  final String unitName;

  Recipe({
    required this.title,
    required this.description,
    required this.imageEmoji,
    required this.difficulty,
    required this.hydration,
    required this.ingredients,
    required this.steps,
    this.unitName = "Brote",
  });
}

class RecipeStep {
  final String title;
  final int durationMinutes;
  final String? temperature; // Das ? erlaubt 'null' (keine Angabe)
  final String detailedInstructions;
  final String? techniqueExplanation;

  RecipeStep({
    required this.title,
    required this.durationMinutes,
    this.temperature, // Hier das 'required' entfernen!
    required this.detailedInstructions,
    this.techniqueExplanation,
  });
}