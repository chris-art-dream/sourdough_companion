import 'package:flutter/material.dart';

// DEINE IMPORTS
import 'recipe_data.dart' as data;
import 'calculator_page.dart';
import 'active_timers_page.dart';
import 'timer_page.dart';

void main() {
  runApp(const SourdoughApp());
}

class SourdoughApp extends StatelessWidget {
  const SourdoughApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sauerteig-Assistent',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7A4A32),
          primary: const Color(0xFF7A4A32),
          surface: const Color(0xFFF7F2EE),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF7A4A32),
          foregroundColor: Colors.white,
          elevation: 0,
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

  // Diese Methode erlaubt es Unterseiten, den Tab zu wechseln
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Seiten-Liste direkt im Build, damit der Callback übergeben werden kann
    final List<Widget> _pages = [
      HomePage(onNavigateToTab: _onDestinationSelected),
      const RecipeListPage(),
      const CalculatorPage(),
      const ActiveTimersPage(),
    ];

    return Scaffold(
      // IndexedStack bewahrt den Status (z.B. Eingaben im Rechner) beim Tab-Wechsel
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Start'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Rezepte'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'Rechner'),
          NavigationDestination(icon: Icon(Icons.timer_outlined), selectedIcon: Icon(Icons.timer), label: 'Timer'),
        ],
      ),
    );
  }
}

// --- HOME PAGE ---
class HomePage extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const HomePage({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sauerteig-Assistent')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 24),
          const Text('Beliebte Rezepte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...data.recipes.take(2).map((recipe) => _buildRecipeCard(context, recipe)),
          const SizedBox(height: 24),
          const Text('Schnellzugriff', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildToolCard(
                icon: Icons.calculate,
                title: 'Rechner',
                color: Colors.teal,
                onTap: () => onNavigateToTab(2), // Wechselt zum Rechner-Tab
              ),
              const SizedBox(width: 12),
              _buildToolCard(
                icon: Icons.timer,
                title: 'Timer',
                color: Colors.orange,
                onTap: () => onNavigateToTab(3), // Wechselt zum Timer-Tab
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF7A4A32), Color(0xFFAC7356)]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👋 Hallo Bäcker!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Dein Sauerteig wartet schon. Welches Projekt startest du heute?', 
            style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => onNavigateToTab(1), // Zu den Rezepten
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.brown),
            child: const Text('Alle Rezepte ansehen'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, data.Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(recipe.imageEmoji, style: const TextStyle(fontSize: 32)),
        title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(recipe.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe))),
      ),
    );
  }

  Widget _buildToolCard({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// --- RECIPE LIST ---
class RecipeListPage extends StatelessWidget {
  const RecipeListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Brot-Rezepte')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.recipes.length,
        itemBuilder: (context, i) {
          final recipe = data.recipes[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: Text(recipe.imageEmoji, style: const TextStyle(fontSize: 32)),
              title: Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(recipe.description),
              trailing: const Icon(Icons.play_circle_fill, color: Colors.brown, size: 32),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StepTimerPage(recipe: recipe))),
            ),
          );
        },
      ),
    );
  }
}

// --- RECIPE DETAIL ---
class RecipeDetailPage extends StatelessWidget {
  final data.Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text(recipe.imageEmoji, style: const TextStyle(fontSize: 80))),
            const SizedBox(height: 20),
            Text(recipe.description, style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
            const Divider(height: 40),
            const Text('Zutaten', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Text(recipe.ingredients, style: const TextStyle(fontSize: 16, height: 1.6)),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StepTimerPage(recipe: recipe))),
                icon: const Icon(Icons.timer),
                label: const Text('Backvorgang starten'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}