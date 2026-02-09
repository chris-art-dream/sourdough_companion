class DoughResult {
  final double flour;
  final double water;
  final double starter;
  final double salt;
  final double totalDough;

  DoughResult({
    required this.flour,
    required this.water,
    required this.starter,
    required this.salt,
    required this.totalDough,
  });
}

DoughResult calculateDough({
  required double flour,
  required double hydration,
  required double starterPercent,
  required double saltPercent,
}) {
  final starter = flour * (starterPercent / 100);

  // Starter = 100 % Hydration
  final starterFlour = starter / 2;
  final starterWater = starter / 2;

  final targetWater = flour * (hydration / 100);
  final water = targetWater - starterWater;

  final salt = flour * (saltPercent / 100);
  final totalDough = flour + water + starter + salt;

  return DoughResult(
    flour: flour,
    water: water,
    starter: starter,
    salt: salt,
    totalDough: totalDough,
  );
}
