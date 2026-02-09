import 'package:flutter/material.dart';
import 'recipe_data.dart' as data;
import 'calculator_page.dart';

class RecipeDetailPage extends StatelessWidget {
  final data.Recipe recipe;

  const RecipeDetailPage({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            recipe.description,
            style: const TextStyle(fontSize: 16),
          ),

          const SizedBox(height: 12),

Row(
  children: [
    _infoChip(
      label: recipe.difficulty,
      color: _difficultyColor(recipe.difficulty),
    ),
    const SizedBox(width: 8),
    _infoChip(
      label: '💧 ${recipe.hydration.toStringAsFixed(0)} %',
      color: Colors.blueGrey,
    ),
    const SizedBox(width: 8),
    _infoChip(
      label: '⏱ ${(recipe.totalMinutes / 60).toStringAsFixed(1)} h',
      color: Colors.brown,
    ),
  ],
),


          ElevatedButton.icon(
            icon: const Icon(Icons.calculate),
            label: const Text('Mengen berechnen'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalculatorPage(
                    initialHydration: recipe.hydration,
                    initialFlour: 500,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.brown.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
Widget _infoChip({
  required String label,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 12,
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
