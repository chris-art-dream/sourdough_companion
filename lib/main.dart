
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'recipe_data.dart' as data;
import 'timer_page.dart';
import 'active_timers_page.dart';
import 'calculator_page.dart';
import 'pages/dough_temperature_calculator_page.dart';
import 'pages/intelligent_calculator_page.dart';
import 'pages/baking_log_page.dart';
import 'settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SourdoughApp());
}

class SourdoughApp extends StatelessWidget {
  const SourdoughApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mein Sauerteighelfer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
  useMaterial3: true,

  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.brown,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.brown,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
  ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.brown,
    labelTextStyle: WidgetStatePropertyAll(
      TextStyle(color: Colors.white),
    ),
    iconTheme: WidgetStatePropertyAll(
      IconThemeData(color: Colors.white),
    ),
  ),
),


      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    RecipeListPage(),
    CalculatorPage(),
    ActiveTimersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.brown,
        indicatorColor: Colors.brown.shade300,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        labelBehavior:
      NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home, color: Colors.white),
            label: "Start",
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book, color: Colors.white),
            label: "Rezepte",
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate, color: Colors.white),
            label: "Rechner",
          ),
          NavigationDestination(
            icon: Icon(Icons.timer, color: Colors.white),
            label: "Timer",
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mein Sauerteighelfer"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Willkommen-Banner
              Card(
                color: Colors.brown.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🍞 Willkommen zurück!",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Wähle ein Rezept und backe es Schritt für Schritt mit Hilfe deines persönlichen Timer-Assistenten.",
                        style: TextStyle(fontSize: 14, color: Colors.brown),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          // Navigiere zur Rezepte-Seite
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RecipeListPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.menu_book),
                        label: const Text("Jetzt backen starten!"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Schnellzugriff - Beliebte Rezepte
              const Text(
                "📖 Beliebte Rezepte",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...data.recipes.take(2).map((recipe) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.cake, color: Colors.brown),
                      title: Text(recipe.title),
                      subtitle: Text(recipe.description),
                      trailing: const Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecipeDetailPage(recipe: recipe),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Funktions-Übersicht
              const Text(
                "⚙️ Functions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.thermostat,
                    title: "Temperatur",
                    subtitle: "Wassertemp berechnen",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const DoughTemperatureCalculatorPage(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.calculate,
                    title: "Rechner",
                    subtitle: "Zutaten berechnen",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const IntelligentCalculatorPage(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.timer,
                    title: "Timer",
                    subtitle: "Aktive Timer",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ActiveTimersPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildFeatureCard(
                    context,
                    icon: Icons.menu_book,
                    title: "Rezepte",
                    subtitle: "Alle Rezepte",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RecipeListPage(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.history,
                    title: "Backlog",
                    subtitle: "Dokumentieren",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BakingLogPage(),
                        ),
                      );
                    },
                  ),
                  _buildFeatureCard(
                    context,
                    icon: Icons.info,
                    title: "Info",
                    subtitle: "Tipps",
                    onTap: () {
                      // Placeholder für zukünftige Erweiterung
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Tipps-Sektion
              const Text(
                "💡 Tipps & Tricks",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildTipCard(
                "Raumtemperatur beachten",
                "Eine ideale Gärtemperatur liegt bei 24-28°C. Im Winter musst du nachheizen, im Sommer kühlen.",
              ),
              const SizedBox(height: 12),
              _buildTipCard(
                "Gluten-Entwicklung",
                "Durch Dehnen und Falten entwickelt sich das Gluten ohne intensives Kneten.",
              ),
              // Instagram-Bereich entfernt
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: SizedBox(
        height: 140, // Erhöhte Höhe für alle Funktionskarten, damit kein Overflow entsteht
        child: Card(
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 32, color: Colors.brown),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String description) {
    return Card(
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rezepte"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: data.recipes.length,
        itemBuilder: (context, index) {
          final recipe = data.recipes[index];

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.brown.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recipe.imageEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              title: Text(
                recipe.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(recipe.description),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(recipe.difficulty)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          recipe.difficulty,
                          style: TextStyle(
                            fontSize: 11,
                            color:
                                _getDifficultyColor(recipe.difficulty),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '💧 ${recipe.hydration.toStringAsFixed(0)}%',
                        style: const TextStyle(fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '⏱️ ${(recipe.totalMinutes / 60).toStringAsFixed(1)}h',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        RecipeDetailPage(recipe: recipe),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Anfänger':
        return Colors.green;
      case 'Fortgeschrittene':
        return Colors.orange;
      case 'Profi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class RecipeDetailPage extends StatelessWidget {
  final data.Recipe recipe;

  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        recipe.imageEmoji,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recipe.description,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    recipe.background,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recipe Info Row
            Row(
              children: [
                Expanded(
                  child: _buildInfoPill(
                    icon: Icons.info_outline,
                    label: 'Schwierigkeit',
                    value: recipe.difficulty,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoPill(
                    icon: Icons.water_drop,
                    label: 'Hydration',
                    value: '${recipe.hydration.toStringAsFixed(0)}%',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInfoPill(
                    icon: Icons.schedule,
                    label: 'Zeit',
                    value: '${(recipe.totalMinutes / 60).toStringAsFixed(1)}h',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Ingredients Section
            Text(
              '📋 Zutaten',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  recipe.ingredients,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.8,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Steps Section
            Text(
              '👣 Schritte des Rezepts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...recipe.steps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.brown.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          step.icon,
                          color: Colors.brown,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      '${index + 1}. ${step.title}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(step.description),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.timer,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '${step.durationMinutes} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.thermostat,
                                size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              step.temperature,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Start Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StepTimerPage(recipe: recipe),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle, size: 24),
                label: const Text(
                  'Geführten Backmodus starten!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.brown, size: 20),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}
