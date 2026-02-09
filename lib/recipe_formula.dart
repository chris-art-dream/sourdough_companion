class RecipeFormula {
  final String recipeTitle;
  final double baseFlour;
  final double hydration;
  final double starterPercent;
  final double saltPercent;

  const RecipeFormula({
    required this.recipeTitle,
    required this.baseFlour,
    required this.hydration,
    required this.starterPercent,
    required this.saltPercent,
  });
}

final RecipeFormula kanelbullarFormula = RecipeFormula(
  recipeTitle: "Sauerteig-Zimtschnecken",
  baseFlour: 575,
  hydration: 63,
  starterPercent: 20,
  saltPercent: 2,
);
