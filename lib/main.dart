import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// Deine Model-Imports (Achte darauf, dass die Pfade stimmen!)
import 'models/sourdough_starter_model.dart';
import 'recipe_list_page.dart';
import 'calculator_page.dart';
import 'sourdough_page.dart';

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
          surface: const Color(0xFFFCFAF8),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFCFAF8),
          foregroundColor: Color(0xFF2D1B14),
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

  @override
  Widget build(BuildContext context) {
    // Liste der Seiten für die Navigation
    final List<Widget> pages = [
      HomePage(onNavigateToTab: (index) => setState(() => _selectedIndex = index)),
      const RecipeListPage(),
      const CalculatorPage(),
      const SourdoughPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFF7A4A32).withAlpha(30),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Entdecken'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), label: 'Rezepte'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), label: 'Rechner'),
          NavigationDestination(icon: Icon(Icons.bakery_dining_outlined), label: 'Sauerteig'),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const HomePage({super.key, required this.onNavigateToTab});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SourdoughStarter> starters = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStarters();
  }

  Future<void> _loadStarters() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('sourdough_starters');
    if (data != null) {
      try {
        final List<dynamic> decoded = json.decode(data);
        setState(() {
          starters = decoded.map((e) => SourdoughStarter.fromJson(e)).toList();
          loading = false;
        });
      } catch (e) {
        setState(() => loading = false);
      }
    } else {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadStarters,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStarterStatus(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                      const SizedBox(height: 24),
                      _buildReminders(),
                      const SizedBox(height: 24),
                      _buildMotivation(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hallo Bäcker!", style: TextStyle(color: Colors.brown.shade300, fontSize: 16)),
              const Text("Dein Dashboard", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D1B14))),
            ],
          ),
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFF7A4A32),
            child: Icon(Icons.person, color: Colors.white),
          )
        ],
      ),
    );
  }

  Widget _buildStarterStatus() {
    if (starters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: const Text("Noch kein Starter angelegt. Geh zum Sauerteig-Tab, um zu starten!"),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("Deine Starter", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        ...starters.map((s) => _starterCard(s)).toList(),
      ],
    );
  }

  Widget _starterCard(SourdoughStarter s) {
    final hunger = _getHungerLevel(s);
    final status = _getStatus(s);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: status['color'] as Color, width: 1.5),
      ),
      child: Row(
        children: [
          _buildJarIcon(hunger, status['color'] as Color, status['emoji'] as String),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Letzte Fütterung: ${_formatDateTime(s.lastFed)}", style: const TextStyle(fontSize: 12)),
                Text(status['text'] as String, style: TextStyle(fontSize: 12, color: status['color'] as Color)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: status['color'] as Color),
        ],
      ),
    );
  }

  Widget _buildJarIcon(double hunger, Color color, String emoji) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          width: 36, height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFEDE7DE),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 1),
          ),
        ),
        Container(
          width: 36, height: 48 * (1 - hunger),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
          ),
        ),
        Positioned(top: 2, child: Text(emoji, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  double _getHungerLevel(SourdoughStarter s) {
    final interval = s.fridgeMode 
        ? const Duration(days: 6) 
        : (s.temperature < 18 ? const Duration(hours: 36) : (s.temperature < 22 ? const Duration(hours: 24) : (s.temperature < 25 ? const Duration(hours: 16) : const Duration(hours: 12))));
    final sinceFed = DateTime.now().difference(s.lastFed);
    return min(1.0, sinceFed.inSeconds / interval.inSeconds);
  }

  Map<String, dynamic> _getStatus(SourdoughStarter s) {
    final hunger = _getHungerLevel(s);
    if (hunger < 0.7) return {"label": "Aktiv", "emoji": "🌱", "color": const Color(0xFF7A8B6F), "text": "Starter ist vital!"};
    if (hunger < 1.0) return {"label": "Hungrig", "emoji": "😋", "color": Colors.orange, "text": "Zeit zu füttern!"};
    return {"label": "Schlapp", "emoji": "🥶", "color": Colors.red, "text": "Braucht dringend Pflege!"};
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final timeStr = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) return "Heute, $timeStr Uhr";
    return "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}. ${timeStr} Uhr";
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => widget.onNavigateToTab(3),
              icon: const Icon(Icons.bakery_dining_outlined),
              label: const Text("Füttern"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A4A32),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => widget.onNavigateToTab(2),
              icon: const Icon(Icons.calculate_outlined),
              label: const Text("Rechner"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF7A4A32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: const BorderSide(color: Color(0xFF7A4A32)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminders() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3CD),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFF7A4A32)),
            SizedBox(width: 12),
            Expanded(child: Text("Erinnerung: Check heute dein Anstellgut!")),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE8D8CF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.emoji_emotions, color: Color(0xFF7A4A32)),
            SizedBox(width: 12),
            Expanded(child: Text("Ein gut gepflegter Starter macht das beste Brot!")),
          ],
        ),
      ),
    );
  }
}