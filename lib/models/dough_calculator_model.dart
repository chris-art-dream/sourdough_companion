/// Teigtemperatur-Rechner nach professioneller Formel
/// Zieltemp × 3 - (Raumtemp + Mehtemp + Reibungswärme) = notwendige Wassertemp
class DoughTemperatureCalculator {
  /// Berechnet die notwendige Wassertemperatur
  /// 
  /// [targetDoughTemp] - Gewünschte Teigtemperatur (z.B. 26°C)
  /// [roomTemp] - Raumtemperatur in °C
  /// [flourTemp] - Mehltemperatur in °C (meist ~21°C)
  /// [frictionFactor] - Reibungswärme-Faktor (2-3, Standard: 2.5)
  static double calculateWaterTemperature({
    required double targetDoughTemp,
    required double roomTemp,
    required double flourTemp,
    double frictionFactor = 2.5,
  }) {
    // Formel: Zieltemp × 3 - (Raumtemp + Mehtemp + Reibungsfaktor) = Wassertemp
    return (targetDoughTemp * 3) - (roomTemp + flourTemp + frictionFactor);
  }

  /// Berechnet die tatsächliche Teigtemperatur (für Kontrolle)
  /// Umkehrformel zur Validierung
  static double calculateActualDoughTemp({
    required double waterTemp,
    required double roomTemp,
    required double flourTemp,
    double frictionFactor = 2.5,
  }) {
    return (waterTemp + roomTemp + flourTemp + frictionFactor) / 3;
  }

  /// Gibt eine Empfehlung für die Gärzeit basierend auf Teigtemperatur und Diehlzahlen
  static String getGarTimeRecommendation(double doughTemp) {
    if (doughTemp < 20) {
      return "Sehr kalt (~32h) - Lange, kalte Gärung";
    } else if (doughTemp < 24) {
      return "Kühl (~16-20h) - Kalte Nachtkalt-Gärung";
    } else if (doughTemp < 26) {
      return "Optimal (~12-16h) - Perfekt für Standard-Rezepte";
    } else if (doughTemp < 28) {
      return "Warm (~8-12h) - Schneller Gärprozess";
    } else {
      return "Sehr warm (~4-8h) - Schnelle Fermentation";
    }
  }

  /// Berechnet die Diehl-Zahl (Fermentation-Indikator)
  /// Diehl-Zahl = Teigtemperatur × Gärzeit (h) = ~180-200 für Sauerteig
  static double calculateDiehlNumber({
    required double doughTemp,
    required double gaerZeitStunden,
  }) {
    return doughTemp * gaerZeitStunden;
  }

  /// Berechnet die angepasste Gärzeit basierend auf Diehl-Zahl und Teigtemperatur
  /// Wenn die Teigtemperatur abweicht, kann man die Gärzeit anpassen
  static double adjustedGarTime({
    required double targetDiehlNumber, // Standard: 190
    required double actualDoughTemp,
  }) {
    return targetDiehlNumber / actualDoughTemp;
  }
}

/// Intelligente Berechnung für Teigausbeute und Hydration
class DoughCalculations {
  /// Teigausbeute = (Gesamtteigmenge / Mehelmenge) × 100
  /// Standard: 160-180% (160 = sehr trockener Teig, 180 = nasser Teig)
  static double calculateBakersPercentage({
    required double flourWeight, // in g
    required double waterWeight, // in g
    required double saltWeight, // in g (optional)
    required double starterWeight, // in g
  }) {
    final totalDough = flourWeight + waterWeight + saltWeight + starterWeight;
    return (totalDough / flourWeight) * 100;
  }

  /// Hydration = (Wasser / Mehl) × 100
  /// Standard Sauerteig: 75-85%
  static double calculateHydration({
    required double waterWeight, // in g
    required double flourWeight, // in g
  }) {
    return (waterWeight / flourWeight) * 100;
  }

  /// Skaliert Rezept-Zutaten basierend auf gewünschter Mehelmenge
  static Map<String, double> scaleRecipe({
    required Map<String, double> originalRecipe, // {"Mehl": 500, "Wasser": 350, etc}
    required double originalFlourWeight,
    required double desiredFlourWeight,
  }) {
    final scaleFactor = desiredFlourWeight / originalFlourWeight;
    return originalRecipe.map((ingredient, weight) {
      return MapEntry(ingredient, weight * scaleFactor);
    });
  }

  /// Berechnet benötigte Zutatenmengen basierend auf Teigausbeute
  static Map<String, double> calculateFromBakersPercentage({
    required double flourWeight, // Mehl in g
    required double bakersPercentage, // z.B. 170
    required Map<String, double> percentages, // {"Wasser": 75, "Salz": 2, "Starter": 15, etc}
  }) {
    final result = {"Mehl": flourWeight};
    percentages.forEach((ingredient, percentage) {
      result[ingredient] = (flourWeight * percentage) / 100;
    });
    return result;
  }
}
