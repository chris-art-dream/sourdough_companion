import 'package:flutter/material.dart';
import '../models/dough_calculator_model.dart';

class IntelligentCalculatorPage extends StatefulWidget {
  const IntelligentCalculatorPage({super.key});

  @override
  State<IntelligentCalculatorPage> createState() =>
      _IntelligentCalculatorPageState();
}

class _IntelligentCalculatorPageState extends State<IntelligentCalculatorPage> {
  int _selectedTab = 0; // 0: Hydration, 1: Teigausbeute, 2: Skalierung

  // Hydration Calculator
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _flourController = TextEditingController();
  double? _hydration;

  // Teigausbeute Calculator
  final TextEditingController _flourWeightController = TextEditingController();
  final TextEditingController _waterWeightController = TextEditingController();
  final TextEditingController _saltWeightController = TextEditingController();
  final TextEditingController _starterWeightController = TextEditingController();
  double? _bakersPercentage;

  // Skalierung
  final TextEditingController _originalFlourController = TextEditingController(text: '500');
  final TextEditingController _desiredFlourController = TextEditingController();
  final Map<String, TextEditingController> _recipeControllers = {};
  Map<String, double>? _scaledRecipe;

  void _calculateHydration() {
    try {
      final water = double.parse(_waterController.text);
      final flour = double.parse(_flourController.text);

      setState(() {
        _hydration = DoughCalculations.calculateHydration(
          waterWeight: water,
          flourWeight: flour,
        );
      });
    } catch (e) {
      _showError('Fehler bei Hydration-Berechnung');
    }
  }

  void _calculateBakersPercentage() {
    try {
      final flour = double.parse(_flourWeightController.text);
      final water = double.parse(_waterWeightController.text);
      final salt = double.tryParse(_saltWeightController.text) ?? 0.0;
      final starter = double.tryParse(_starterWeightController.text) ?? 0.0;

      setState(() {
        _bakersPercentage = DoughCalculations.calculateBakersPercentage(
          flourWeight: flour,
          waterWeight: water,
          saltWeight: salt,
          starterWeight: starter,
        );
      });
    } catch (e) {
      _showError('Fehler bei Teigausbeute-Berechnung');
    }
  }

  void _scaleRecipe() {
    try {
      final originalFlour = double.parse(_originalFlourController.text);
      final desiredFlour = double.parse(_desiredFlourController.text);

      final originalRecipe = <String, double>{};
      _recipeControllers.forEach((key, controller) {
        if (controller.text.isNotEmpty) {
          originalRecipe[key] = double.parse(controller.text);
        }
      });
      originalRecipe['Mehl'] = originalFlour;

      setState(() {
        _scaledRecipe = DoughCalculations.scaleRecipe(
          originalRecipe: originalRecipe,
          originalFlourWeight: originalFlour,
          desiredFlourWeight: desiredFlour,
        );
      });
    } catch (e) {
      _showError('Fehler bei Rezept-Skalierung');
    }
  }

  void _addIngredient() {
    setState(() {
      final ingredientName = 'Zutat ${_recipeControllers.length}';
      _recipeControllers[ingredientName] = TextEditingController();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Intelligente Berechnung'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.brown.shade50,
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Hydration', 0),
                ),
                Expanded(
                  child: _buildTabButton('Teigausbeute', 1),
                ),
                Expanded(
                  child: _buildTabButton('Skalierung', 2),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _selectedTab == 0
                  ? _buildHydrationTab()
                  : _selectedTab == 1
                      ? _buildBakersPercentageTab()
                      : _buildScalingTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.brown : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.brown : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHydrationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '💧 Hydration berechnen',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Hydration % = (Wasser / Mehl) × 100\nStandard Sauerteig: 75-85%',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _waterController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Wasser (g)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.water_drop),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _flourController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Mehl (g)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.grain),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
            ),
            onPressed: _calculateHydration,
            icon: const Icon(Icons.calculate),
            label: const Text('Berechnen'),
          ),
        ),
        if (_hydration != null) ...[
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'Hydration',
            value: '${_hydration!.toStringAsFixed(1)}%',
            description: _getHydrationDescription(_hydration!),
            color: Colors.lightBlue,
          ),
        ],
      ],
    );
  }

  Widget _buildBakersPercentageTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📊 Teigausbeute berechnen',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Teigausbeute % = (Gesamtteig / Mehl) × 100\nStandard: 160-180%',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _flourWeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Mehl (g)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.grain),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _waterWeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Wasser (g)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.water_drop),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _saltWeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Salz (g) - optional',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.grain),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _starterWeightController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Sauerteig-Starter (g)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.bubble_chart),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
            ),
            onPressed: _calculateBakersPercentage,
            icon: const Icon(Icons.calculate),
            label: const Text('Berechnen'),
          ),
        ),
        if (_bakersPercentage != null) ...[
          const SizedBox(height: 20),
          _buildInfoCard(
            title: 'Teigausbeute',
            value: '${_bakersPercentage!.toStringAsFixed(1)}%',
            description: _getBakersPercentageDescription(_bakersPercentage!),
            color: Colors.green,
          ),
        ],
      ],
    );
  }

  Widget _buildScalingTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '📐 Rezept skalieren',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Skaliere dein Rezept auf die gewünschte Mehelmenge',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _originalFlourController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Ursprüngl. Mehl (g)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _desiredFlourController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Gewünschtes Mehl (g)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Zutaten des Original-Rezepts:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ..._recipeControllers.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(e.key),
                  ),
                  Expanded(
                    child: TextField(
                      controller: e.value,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'g',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            )),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown.shade300,
              foregroundColor: Colors.white,
            ),
            onPressed: _addIngredient,
            icon: const Icon(Icons.add),
            label: const Text('Zutat hinzufügen'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
            ),
            onPressed: _scaleRecipe,
            icon: const Icon(Icons.calculate),
            label: const Text('Skalieren'),
          ),
        ),
        if (_scaledRecipe != null) ...[
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Skaliertes Rezept:',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._scaledRecipe!.entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key),
                            Text(
                              '${e.value.toStringAsFixed(1)} g',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required String description,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getHydrationDescription(double hydration) {
    if (hydration < 70) {
      return '🏔️ Sehr trockener Teig - Weniger Wasser';
    } else if (hydration < 75) {
      return '👍 Trockener Teig - Gute Struktur';
    } else if (hydration < 85) {
      return '⭐ Optimal - Standard Sauerteig';
    } else if (hydration < 90) {
      return '💧 Nasser Teig - Mehr Feuchtigkeit';
    } else {
      return '🌊 Sehr nasser Teig - Viel Wasser';
    }
  }

  String _getBakersPercentageDescription(double percentage) {
    if (percentage < 160) {
      return 'Trockener, denser Teig';
    } else if (percentage < 170) {
      return 'Standard, mittlerer Teig';
    } else if (percentage < 180) {
      return 'Luftiger, feuchter Teig';
    } else {
      return 'Sehr luftiger Teig - Viel Volumen';
    }
  }

  @override
  void dispose() {
    _waterController.dispose();
    _flourController.dispose();
    _flourWeightController.dispose();
    _waterWeightController.dispose();
    _saltWeightController.dispose();
    _starterWeightController.dispose();
    _originalFlourController.dispose();
    _desiredFlourController.dispose();
    for (var controller in _recipeControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
