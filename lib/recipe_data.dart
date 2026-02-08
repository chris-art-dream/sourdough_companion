import 'package:flutter/material.dart';

class RecipeStep {
  final String title;
  final String description;
  final String detailedInstructions;
  final int durationMinutes;
  final String temperature; // z.B. "26°C", "230°C"
  final String tip; // Praktischer Tipp
  final IconData icon; // Visueller Indikator

  RecipeStep({
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
  final String difficulty; // "Anfänger", "Fortgeschrittene", "Profi"
  final double hydration; // z.B. 80.0
  final int totalMinutes;
  final String imageEmoji; // Emoji für das Rezept
  final String ingredients; // Zutaten als Text
  final List<RecipeStep> steps;
  final String background; // Hintergrund-Beschreibung

  Recipe({
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

final List<Recipe> recipes = [
  Recipe(
    title: "Klassisches Sauerteigbrot",
    description: "Das Standardrezept für knuspriges Sauerteigbrot",
    difficulty: "Anfänger",
    hydration: 80.0,
    totalMinutes: 1020, // ~17h
    imageEmoji: "🥖",
    background: "Ein traditionelles französisches Sauerteigbrot mit würzigem Aroma und knuspriger Kruste.",
    ingredients: """
500g Weizenmehl Type 550
350ml Wasser (70% Hydration)
75g Sauerteig-Starter (15%)
10g Salz (2%)

Gesamtteig: ~935g
Teigausbeute: 170%
    """,
    steps: [
      RecipeStep(
        title: "Teig mischen",
        description: "Alle Zutaten kombinieren",
        detailedInstructions:
            "Mehl, Wasser und Starter in einer Schüssel vermischen. Mit den Händen kurz durcharbeiten, bis keine trockenen Mehlflöckchen mehr sichtbar sind. Der Teig sollte wirr und etwas klebrig wirken.",
        durationMinutes: 10,
        temperature: "~22°C",
        tip:
            "Verwende immer Raumtemperatur-Wasser. Warmes Wasser beschleunigt die Fermentation unnötig.",
        icon: Icons.water_drop,
      ),
      RecipeStep(
        title: "Autolyse (Quellung)",
        description: "Mehl und Wasser ruhen lassen",
        detailedInstructions:
            "Abdecken und 30 Minuten ruhen lassen. Das Mehl saugt Wasser auf und entwickelt erste Glutenstrukturen. Das Kneten wird später einfacher.",
        durationMinutes: 30,
        temperature: "~22°C",
        tip:
            "Diese Phase ist wichtig! Sie reduziert Knetenarbeit und verbessert die Teigqualität.",
        icon: Icons.timer,
      ),
      RecipeStep(
        title: "Salz einarbeiten",
        description: "Salz und Sauerteig-Starter hinzufügen",
        detailedInstructions:
            "Nach der Autolyse: Salz (10g) und restliche Starter-Menge einarbeiten. Mit feuchten Händen einarbeiten. Der Teig wird straffer.",
        durationMinutes: 15,
        temperature: "~22°C",
        tip:
            "Die Pincer Method: Mit Daumen und Zeigefinger von oben greifen, Teig nach unten falten. Alle 30 Sekunden Position wechseln.",
        icon: Icons.grain,
      ),
      RecipeStep(
        title: "Dehnen und Falten (Stretch & Fold)",
        description: "Glutenentwicklung ohne intensive Knete",
        detailedInstructions:
            "Alle 30 Minuten für 2-3 Stunden: Teig von oben greifen, nach oben dehnen, nach unten in die Mitte falten. 4-seitig wiederholen. Der Teig wird sichtbar straffer und elastischer.",
        durationMinutes: 120,
        temperature: "~22-24°C",
        tip:
            "Insgesamt 4-6 Sätze machen. Der Teig sollte sich immer stärker anfühlen.",
        icon: Icons.open_in_full,
      ),
      RecipeStep(
        title: "Bulk Fermentation (Gärung)",
        description: "Teig fermentiert bei Raumtemperatur",
        detailedInstructions:
            "Nach letztem Stretch & Fold: Teig weitere 2-4 Stunden bei Raumtemperatur gären lassen. Der Teig sollte um ca. 50-75% aufgehen.",
        durationMinutes: 180,
        temperature: "~24-26°C",
        tip:
            "Poke-Test: Mit Finger leicht eindrücken. Loch sollte langsam zurückgehen.",
        icon: Icons.bubble_chart,
      ),
      RecipeStep(
        title: "Über Nacht kalt gären",
        description: "Im Kühlschrank über Nacht entwickeln",
        detailedInstructions:
            "Nach Bulk Fermentation: Teig in Banneton legen, mit Folie abdecken und für 8-16 Stunden in den Kühlschrank.",
        durationMinutes: 480,
        temperature: "4°C",
        tip:
            "Kalte Gärung: Perfekt für Anfänger! Du kannst jederzeit wählen wann zu backen.",
        icon: Icons.ac_unit,
      ),
      RecipeStep(
        title: "Formen",
        description: "Teig in Backform bringen",
        detailedInstructions:
            "Teig aus Banneton stürzen. Evtl. nochmals spannen. Mit Mehl oder Speisestärke bestäuben.",
        durationMinutes: 10,
        temperature: "~22°C",
        tip:
            "Spannen: Mit beiden Händen von außen nach innen ziehen - erzeugt Oberflächenspannung.",
        icon: Icons.thumb_up_outlined,
      ),
      RecipeStep(
        title: "Backofen vorheizen",
        description: "Dutch Oven / Backtopf auf Temperatur bringen",
        detailedInstructions:
            "Dutch Oven bei 250°C für 45 Minuten vorheizen. Dies erzeugt Dampf für die Kruste.",
        durationMinutes: 45,
        temperature: "250°C",
        tip:
            "Ohne Dutch Oven: Eine Schale mit Wasser auf den Ofenboden stellen für Dampf.",
        icon: Icons.local_fire_department,
      ),
      RecipeStep(
        title: "Backen mit Dampf",
        description: "Brot mit geschlossenem Deckel backen",
        detailedInstructions:
            "Teig vorsichtig in den heißen Dutch Oven gleiten. Mit Deckel 20 Minuten bei 250°C backen. Der Dampf erzeugt die Kruste.",
        durationMinutes: 20,
        temperature: "250°C",
        tip:
            "VORSICHT: Sehr heiß! Ofenhandschuhe benutzen.",
        icon: Icons.water_drop_outlined,
      ),
      RecipeStep(
        title: "Backen ohne Dampf",
        description: "Kruste finalisieren",
        detailedInstructions:
            "Deckel abnehmen und weitere 25-30 Minuten bei 230°C backen. Das Brot sollte dunkelbraun werden.",
        durationMinutes: 30,
        temperature: "230°C",
        tip:
            "Kerntemperatur: Mit Thermometer messen - sollte 205-210°C sein.",
        icon: Icons.check_circle,
      ),
      RecipeStep(
        title: "Abkühlen",
        description: "Brot auskühlen lassen",
        detailedInstructions:
            "Brot aus dem Ofen nehmen und auf Gitter mindestens 1 Stunde abkühlen. NICHT anschneiden!",
        durationMinutes: 60,
        temperature: "Raumtemp.",
        tip:
            "Warmes Brot zu schneiden = zähe Krume. Geduld! Nach Abkühlung ist die Struktur perfekt.",
        icon: Icons.ac_unit,
      ),
    ],
  ),
  Recipe(
    title: "Dinkel-Sauerteig (Vollkorn)",
    description: "Nussiges Aroma mit Vollkornmehl",
    difficulty: "Fortgeschrittene",
    hydration: 85.0,
    totalMinutes: 960,
    imageEmoji: "🌾",
    background: "Ein erdiges, nussig-würziges Brot mit gesundem Vollkornmehl und intensivem Sauerteig-Aroma.",
    ingredients: """
300g Dinkelvollkornmehl
200g Weizenmehl Type 550
315ml Wasser (85% Hydration)
80g Sauerteig-Starter (17%)
12g Salz
""",
    steps: [
      RecipeStep(
        title: "Teig mischen & Autolyse",
        description: "Mischen und 45 Minuten ruhen",
        detailedInstructions:
            "Vollkornmehl benötigt mehr Wasser! Alle Mehle mit 280ml Wasser mischen und 45 Minuten ruhen.",
        durationMinutes: 50,
        temperature: "~22°C",
        tip:
            "Vollkornmehl: Die Keimlinge und Kleien schneiden Gluten. Darum braucht es mehr Wasser.",
        icon: Icons.eco,
      ),
      RecipeStep(
        title: "Starter & Salz einarbeiten",
        description: "Starter (80g) + Salz (12g) + restliches Wasser (35ml)",
        detailedInstructions:
            "Nach Autolyse: Starter auflösen und einarbeiten. Mit feuchten Händen arbeiten.",
        durationMinutes: 15,
        temperature: "~22°C",
        tip:
            "Vollkornteig ist natürlich flüssiger. Das ist OK! Nicht mehr Mehl hinzufügen.",
        icon: Icons.grain,
      ),
      RecipeStep(
        title: "Stretchung & Ruhe",
        description: "Dehnungs-Technik zum Stärken",
        detailedInstructions:
            "Nach 30 Min: Teig auf feuchte Arbeitsfläche kippen. Stretch & Fold. Dann 30 Min Ruhe. Repeat.",
        durationMinutes: 60,
        temperature: "~22°C",
        tip:
            "Vollkorn braucht sanftere Behandlung. Nicht zu aggressiv dehnen!",
        icon: Icons.waves,
      ),
      RecipeStep(
        title: "Bulk Fermentation",
        description: "4-6 Stunden bei Raumtemperatur",
        detailedInstructions:
            "Der Teig sollte um 70% aufgehen. Vollkorn gärt etwas schneller.",
        durationMinutes: 300,
        temperature: "~24-26°C",
        tip:
            "Vollkorn: Früher fertig! Bei 26°C kann es schneller gehen.",
        icon: Icons.watch_later,
      ),
      RecipeStep(
        title: "Stückgare im Kühlen",
        description: "Über Nacht kalt gären oder 2h raumtemp.",
        detailedInstructions:
            "Banneton + Folie + Kühlschrank für 8+ Stunden ODER 2 Stunden Raumtemperatur.",
        durationMinutes: 480,
        temperature: "4°C",
        tip:
            "Kalte Gärung entwickelt Aroma und macht Formen leichter.",
        icon: Icons.ac_unit,
      ),
      RecipeStep(
        title: "Back-Vorbereitung",
        description: "Formen, Dutch Oven vorbereiten",
        detailedInstructions:
            "Aus Banneton stürzen, spannen, bestäuben. Dutch Oven 45 Min bei 250°C vorheizen.",
        durationMinutes: 50,
        temperature: "250°C",
        tip: "Vollkorn kann etwas weniger Ofentrieb haben. Das ist normal!",
        icon: Icons.thumb_up_outlined,
      ),
      RecipeStep(
        title: "Backen Phase 1 (mit Dampf)",
        description: "20 Min mit Deckel bei 250°C",
        detailedInstructions:
            "In heißen Dutch Oven schieben. Deckel drauf. 20 Min backen.",
        durationMinutes: 20,
        temperature: "250°C",
        tip:
            "Optionale Lame-Schnitte. Aber auch ohne schön!",
        icon: Icons.water_drop_outlined,
      ),
      RecipeStep(
        title: "Backen Phase 2 (ohne Dampf)",
        description: "30 Min ohne Deckel bei 220°C",
        detailedInstructions:
            "Deckel ab. Temperatur auf 220°C senken. 30 Min backen bis dunkelbraun.",
        durationMinutes: 30,
        temperature: "220°C",
        tip:
            "Vollkorn wird schneller dunkel. Bei ca. 22 Min prüfen.",
        icon: Icons.dark_mode,
      ),
      RecipeStep(
        title: "Abkühlen",
        description: "Mindestens 1.5 Stunden kühlen",
        detailedInstructions:
            "Brot auf Gitter. NICHT anschneiden. 1.5 Stunden minimum.",
        durationMinutes: 90,
        temperature: "Raumtemp.",
        tip:
            "Vollkornbrot: Länger abkühlen lassen. Die Krume braucht Zeit zum Setzen.",
        icon: Icons.access_time,
      ),
    ],
  ),
  Recipe(
    title: "Schnell-Sauerteig (24h)",
    description: "Perfekt für Anfänger - alles in 24 Stunden",
    difficulty: "Anfänger",
    hydration: 75.0,
    totalMinutes: 1440,
    imageEmoji: "⚡",
    background:
        "Ein schnelles Rezept für ungeduldig Bäcker. Von Anmischung bis zum Anschneiden in 24 Stunden!",
    ingredients: """
500g Weizenmehl Type 550
375ml Wasser (75% Hydration)
100g aktiver Sauerteig-Starter (peak!)
10g Salz
""",
    steps: [
      RecipeStep(
        title: "Starter aktivieren",
        description: "Reifer Starter auf Peak bringen",
        detailedInstructions:
            "Starter mindestens 2-4h vorher füttern. Er sollte seine Peak-Aktivität haben.",
        durationMinutes: 180,
        temperature: "~22-24°C",
        tip:
            "Peak-Starter: Das ist WICHTIG! Nur dann passiert alles schnell genug.",
        icon: Icons.star,
      ),
      RecipeStep(
        title: "Schnell-Mix",
        description: "Alle Zutaten auf einmal mischen",
        detailedInstructions:
            "Alle Zutaten in einer Schüssel mischen. Kein separater Autolyse-Schritt!",
        durationMinutes: 10,
        temperature: "~22°C",
        tip:
            "Deshalb 75% Hydration - weniger Wasser beschleunigt Verarbeitung.",
        icon: Icons.speed,
      ),
      RecipeStep(
        title: "Aktivitäts-Dehnung (45 Min)",
        description: "4x Stretch & Fold in schneller Folge",
        detailedInstructions:
            "Alle 10-12 Minuten Stretch & Fold. Total 4 Runden in 45-50 Minuten.",
        durationMinutes: 50,
        temperature: "~24-26°C",
        tip:
            "Hohe Frequenz! Das beschleunigt Glutenentwicklung massiv.",
        icon: Icons.fast_forward,
      ),
      RecipeStep(
        title: "Kurze Bulk-Gärung",
        description: "Nur 3-4 Stunden!",
        detailedInstructions:
            "Der Teig sollte um 50-60% aufgehen. Mit Peak-Starter ist das in 3-4h möglich.",
        durationMinutes: 210,
        temperature: "~25-26°C",
        tip:
            "Nicht zu lange gären! 'Underproof' ist OK, 'Overproof' ist Desaster.",
        icon: Icons.timer,
      ),
      RecipeStep(
        title: "Direkt formen",
        description: "Keine Stückgare! Direkt in DutchOven",
        detailedInstructions:
            "Nach Bulk: Teig formen, sofort (!) in vorgeheizten Dutch Oven. KEINE Stückgare!",
        durationMinutes: 15,
        temperature: "~22°C",
        tip:
            "Das macht dieses Rezept 'schnell'. Bulk-Gärung = Hauptgärung.",
        icon: Icons.bolt,
      ),
      RecipeStep(
        title: "Dutch Oven vorbereiten",
        description: "45 Min Vorheizzeit bei 250°C",
        detailedInstructions:
            "Während Bulk gärt: Dutch Oven mit Deckel bei 250°C vorheizen.",
        durationMinutes: 45,
        temperature: "250°C",
        tip:
            "Heißer = besser für Ofentrieb. Dieser Teig braucht schnelle Hitze!",
        icon: Icons.local_fire_department,
      ),
      RecipeStep(
        title: "Backen (Dampf-Phase)",
        description: "20 Min mit Deckel bei 250°C",
        detailedInstructions:
            "Teig in heißen Topf schieben. Deckel drauf. 20 Min.",
        durationMinutes: 20,
        temperature: "250°C",
        tip:
            "Der Dampf erzeugt massiven Ofentrieb - wichtig für schnelles Rezept!",
        icon: Icons.water_drop_outlined,
      ),
      RecipeStep(
        title: "Backen (Kruste-Phase)",
        description: "25 Min ohne Deckel bei 230°C",
        detailedInstructions:
            "Deckel ab, Temp 230°C, bis dunkelbraun.",
        durationMinutes: 25,
        temperature: "230°C",
        tip:
            "Ziel: dunkelbraun, nicht schwarz! Gesamtbackzeit: 45 Min total.",
        icon: Icons.done,
      ),
      RecipeStep(
        title: "Abkühl-Trick",
        description: "30 Min mit Tuch zugedeckt kühlen",
        detailedInstructions:
            "Aus Dutch Oven raus, auf Gitter mit Tuch bedeckt für 30 Min. Dann 30 weitere Minuten ohne Tuch.",
        durationMinutes: 60,
        temperature: "Raumtemp.",
        tip:
            "Tuch beim Abkühlen: Verhindert dass die Kruste zu schnell auskühlt.",
        icon: Icons.ac_unit,
      ),
    ],
  ),
];
