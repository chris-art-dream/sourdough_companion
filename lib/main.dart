
import 'package:flutter/material.dart';


// DEINE IMPORTS
import 'recipe_model.dart';
import 'recipe_data.dart' as data;
import 'calculator_page.dart';
import 'active_timers_page.dart';
import 'timer_page.dart';
import 'recipe_list_page.dart';
import 'recipe_detail_page.dart';
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
    final List<Widget> pages = [
      HomePage(onNavigateToTab: (index) => setState(() => _selectedIndex = index)),
      const RecipeListPage(),
      const CalculatorPage(),
      const ActiveTimersPage(),
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
          NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'Timer'),
        ],
      ),
    );
  }
}


class HomePage extends StatelessWidget {
  final Function(int) onNavigateToTab;
  const HomePage({super.key, required this.onNavigateToTab});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
             
              // Das Highlight-Rezept (Inspiration)
              _buildHighlightCard(context, data.recipes[1]), // Zimtschnecken als Eyecatcher
             
              const SizedBox(height: 32),
             
              // Kategorien statt einfacher Liste
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Kategorien", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextButton(
                      onPressed: () => onNavigateToTab(1),
                      child: const Text("Alle ansehen", style: TextStyle(color: Color(0xFF7A4A32))),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  children: [
                    _buildCategoryItem("Anfänger", Icons.auto_awesome, Colors.green),
                    _buildCategoryItem("Süßes", Icons.bakery_dining, Colors.pink),
                    _buildCategoryItem("Herzhaft", Icons.breakfast_dining, Colors.orange),
                    _buildCategoryItem("Über Nacht", Icons.nights_stay, Colors.indigo),
                  ],
                ),
              ),
             
              const SizedBox(height: 32),
             
              // Direkte Tools für den Back-Alltag
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text("Schnelle Helfer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _buildSmallTool("Mehl-Rechner", Icons.calculate_outlined, Colors.teal, () => onNavigateToTab(2)),
                    const SizedBox(width: 12),
                    _buildSmallTool("Brot-Glossar", Icons.menu_book_outlined, Colors.brown, () {}),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
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
              Text("Hallo Bäcker,", style: TextStyle(color: Colors.brown.shade300, fontSize: 16)),
              const Text("Bereit für heute?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2D1B14))),
            ],
          ),
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFF7A4A32),
            child: Text("S", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }


  Widget _buildHighlightCard(BuildContext context, Recipe recipe) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: recipe))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: const DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=600'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withAlpha(180), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recipe.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(recipe.description, style: const TextStyle(color: Colors.white70, fontSize: 14), maxLines: 2),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildCategoryItem(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2D1B14))),
        ],
      ),
    );
  }


  Widget _buildSmallTool(String title, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

