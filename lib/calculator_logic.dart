class SourdoughCalculator {
  // Das klassische Verhältnis für ein Standard-Landbrot:
  // 100% Mehl, 70% Wasser, 20% Sauerteig, 2% Salz
  
  static Map<String, double> calculateBySourdough(double sourdoughAmount) {
    // Wenn 20% Sauerteig = sourdoughAmount, dann ist 100% Mehl = sourdoughAmount * 5
    double flour = sourdoughAmount * 5;
    double water = flour * 0.7;
    double salt = flour * 0.02;

    return {
      'Mehl': flour,
      'Wasser': water,
      'Salz': salt,
      'Sauerteig': sourdoughAmount,
    };
  }
}