import 'package:flutter/material.dart';

class Recipe {
  final String title;
  final String description;
  final String imageEmoji;
  final String ingredients;
  final List<RecipeStep> steps;

  Recipe({
    required this.title,
    required this.description,
    required this.imageEmoji,
    required this.ingredients,
    required this.steps,
  });
}

class RecipeStep {
  final String title;
  final String description;
  final String detailedInstructions;
  final IconData icon;
  final int durationMinutes; // Exakt dieser Name muss im Code stehen
  final String temperature;
  final String tip;

  RecipeStep({
    required this.title,
    required this.description,
    required this.detailedInstructions,
    required this.icon,
    required this.durationMinutes,
    required this.temperature,
    required this.tip,
  });
}