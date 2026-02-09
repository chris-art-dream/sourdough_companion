import 'package:flutter/material.dart';

/// =======================
/// MODELLE
/// =======================

class RecipeStep {
  final String title;
  final String description;
  final String detailedInstructions;
  final int durationMinutes;
  final String temperature;
  final String tip;
  final IconData icon;

  const RecipeStep({
    required this.title,
    required this.description,
    required this.detailedInstructions,
    required this.durationMinutes,
    required this.temperature,
    required this.tip,
    required this.icon,
  });
}

class Recipe {
  final String title;
  final String description;
  final String difficulty;
  final double hydration;
  final int totalMinutes;
  final String imageEmoji;
  final String ingredients;
  final List<RecipeStep> steps;
  final String background;

  const Recipe({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.hydration,
    required this.totalMinutes,
    required this.imageEmoji,
    required this.ingredients,
    required this.steps,
    required this.background,
  });
}

/// =======================
/// REZEPTE
/// =======================

final List<Recipe> recipes = [
  Recipe(
    title: "Klassisches Sauerteigbrot",
    description: "Das Standardrezept für knuspriges Sauerteigbrot",
    difficulty: "Anfänger",
    hydration: 70.0,
    totalMinutes: 1020, // ca. 17 h
    imageEmoji: "🥖",
    background:
        "Ein traditionelles Sauerteigbrot mit würzigem Aroma und knuspriger Kruste.",
    ingredients: '''
500 g Weizenmehl Type 550
350 ml Wasser
75 g Sauerteig-Starter
10 g Salz
Gesamtteig: ca. 935 g
''',
    steps: [
      RecipeStep(
        title: "Teig mischen",
        description: "Alle Zutaten kombinieren",
        detailedInstructions:
            "Mehl, Wasser und Starter in einer Schüssel vermischen, bis keine trockenen Stellen mehr sichtbar sind.",
        durationMinutes: 10,
        temperature: "~22°C",
        tip: "Raumtemperatur-Wasser verwenden.",
        icon: Icons.water_drop,
      ),
      RecipeStep(
        title: "Stockgare",
        description: "Teig ruhen lassen",
        detailedInstructions:
            "Teig abgedeckt 4 Stunden bei Raumtemperatur ruhen lassen.",
        durationMinutes: 240,
        temperature: "22–24°C",
        tip: "Der Teig sollte sichtbar an Volumen gewinnen.",
        icon: Icons.timer,
      ),
      RecipeStep(
        title: "Backen",
        description: "Brot ausbacken",
        detailedInstructions:
            "Ofen auf 250°C vorheizen, Brot einschieben, nach 15 Minuten auf 200°C reduzieren und fertig backen.",
        durationMinutes: 60,
        temperature: "250 → 200°C",
        tip: "Für Dampf eine feuerfeste Schale Wasser in den Ofen stellen.",
        icon: Icons.local_fire_department,
      ),
    ],
  ),

  Recipe(
    title: "Roggen-Sauerteigbrot",
    description: "Kräftiges Roggenbrot mit langer Teigführung",
    difficulty: "Profi",
    hydration: 85.0,
    totalMinutes: 1440, // 24 h
    imageEmoji: "🍞",
    background:
        "Saftiges Roggenbrot mit intensiver Säure und sehr guter Frischhaltung.",
    ingredients: '''
1000 g Roggenmehl
850 ml Wasser
200 g Roggensauerteig
20 g Salz
''',
    steps: [
      RecipeStep(
        title: "Sauerteig auffrischen",
        description: "Grundlage vorbereiten",
        detailedInstructions:
            "Sauerteig mit Roggenmehl und Wasser mischen und 12–16 Stunden bei 22–24°C reifen lassen.",
        durationMinutes: 720,
        temperature: "22–24°C",
        tip: "Reifer Sauerteig riecht mild-säuerlich.",
        icon: Icons.bubble_chart,
      ),
      RecipeStep(
        title: "Teig mischen",
        description: "Zutaten vermengen",
        detailedInstructions:
            "Alle Zutaten gründlich vermengen. Nicht kneten, nur mischen.",
        durationMinutes: 10,
        temperature: "Raumtemperatur",
        tip: "Roggenteig bleibt immer klebrig.",
        icon: Icons.soup_kitchen,
      ),
      RecipeStep(
        title: "Backen",
        description: "Brot ausbacken",
        detailedInstructions:
            "Bei 250°C anbacken, nach 15 Minuten auf 200°C reduzieren und fertig backen.",
        durationMinutes: 60,
        temperature: "250 → 200°C",
        tip: "Nach dem Backen vollständig auskühlen lassen.",
        icon: Icons.local_fire_department,
      ),
    ],
  ),

  Recipe(
    title: "Sauerteig-Zimtschnecken",
    description: "Fluffige Zimtschnecken mit mildem Sauerteigaroma",
    difficulty: "Fortgeschrittene",
    hydration: 70.0,
    totalMinutes: 900,
    imageEmoji: "🍥",
    background:
        "Saftige Zimtschnecken mit ausgewogenem Süße-Säure-Spiel.",
    ingredients: '''
500 g Weizenmehl
250 ml Milch
100 g Sauerteig
80 g Butter
80 g Zucker
1 Ei
10 g Salz
Zimt-Zucker-Füllung
''',
    steps: [
      RecipeStep(
        title: "Vorteig ansetzen",
        description: "Aroma aufbauen",
        detailedInstructions:
            "Sauerteig, Milch und einen Teil des Mehls mischen und 4 Stunden bei 24°C reifen lassen.",
        durationMinutes: 240,
        temperature: "24°C",
        tip: "Vorteig sorgt für ein rundes Aroma.",
        icon: Icons.bubble_chart,
      ),
      RecipeStep(
        title: "Formen & Backen",
        description: "Schnecken herstellen",
        detailedInstructions:
            "Teig ausrollen, mit Zimt-Zucker bestreichen, aufrollen, schneiden und bei 180°C goldbraun backen.",
        durationMinutes: 45,
        temperature: "180°C",
        tip: "Nicht zu dunkel backen.",
        icon: Icons.cake,
      ),
    ],
  ),
];
