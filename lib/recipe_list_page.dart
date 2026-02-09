import 'package:flutter/material.dart';
import 'recipe_data.dart' as data;
import 'recipe_detail_page.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  String selectedDifficulty = 'Alle';

  final List<String> difficulties = [
    'Alle',
    'Anfänger',
    'Fortgeschrittene',
    'Profi',
  ];

  @override
  Widget build(BuildContext context) {
    final List<data.Recipe> filteredRecipes =
        selectedDifficulty == 'Alle'
            ? data.recipes
            : data.recipes
                .where((r) => r.difficulty == selectedDifficulty)
                .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rezepte'),
      ),
      body: Column(
        children: [
          // Filter
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Filter:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: selectedDifficulty,
                  items: difficulties
                      .map(
                        (d) => DropdownMenuItem(
                          value: d,
                          child: Text(d),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedDifficulty = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),

          // Rezeptliste
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: filteredRecipes.length,
              itemBuilder: (context, index) {
                final recipe = filteredRecipes[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Text(
                      recipe.imageEmoji,
                      style: const TextStyle(fontSize: 28),
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
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _badge(
                              recipe.difficulty,
                              _difficultyColor(recipe.difficulty),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '💧 ${recipe.hydration.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailPage(recipe: recipe),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
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
