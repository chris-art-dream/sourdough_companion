import 'package:flutter/material.dart';
import 'recipe_model.dart';
import 'timer_page.dart';

class RecipeDetailPage extends StatefulWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  State<RecipeDetailPage> createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  int _portions = 1;
  late List<bool> _checkedIngredients;
  late List<String> _ingredientLines;

  @override
  void initState() {
    super.initState();
    // Zutaten in Zeilen splitten und Check-Status initialisieren
    _ingredientLines = widget.recipe.ingredients.split('\n').where((line) => line.trim().isNotEmpty).toList();
    _checkedIngredients = List.generate(_ingredientLines.length, (index) => false);
  }

  String _calculateAmount(String ingredientLine) {
    final RegExp regExp = RegExp(r'^(\d+([.,]\d+)?)');
    final match = regExp.firstMatch(ingredientLine);

    if (match != null) {
      String rawValue = match.group(1)!.replaceAll(',', '.');
      double originalAmount = double.parse(rawValue);
      double newAmount = originalAmount * _portions;
      
      String formattedAmount = newAmount % 1 == 0 
          ? newAmount.toInt().toString() 
          : newAmount.toStringAsFixed(1).replaceAll('.', ',');
          
      return ingredientLine.replaceFirst(match.group(1)!, formattedAmount);
    }
    return ingredientLine;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.recipe.title, 
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2D1B14))),
                  const SizedBox(height: 8),
                  Text(widget.recipe.description, 
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  
                  // MENGEN-WÄHLER
                  _buildPortionSelector(),
                  
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Zutaten", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () => setState(() => _checkedIngredients.fillRange(0, _checkedIngredients.length, false)),
                        child: const Text("Zurücksetzen", style: TextStyle(color: Colors.brown)),
                      ),
                    ],
                  ),
                  const Text("Tippe auf eine Zutat zum Abhaken", style: TextStyle(fontSize: 13, color: Colors.grey)),
                  const SizedBox(height: 16),
                  
                  // INTERAKTIVE CHECKLISTE
                  ...List.generate(_ingredientLines.length, (index) {
                    return _buildIngredientRow(index, _calculateAmount(_ingredientLines[index]));
                  }),

                  const SizedBox(height: 40),
                  _buildStartButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortionSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F2EE),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Menge anpassen", 
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown)),
                  Text("Anzahl der ${widget.recipe.unitName}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  _buildPortionBtn(Icons.remove, () {
                    if (_portions > 1) setState(() => _portions--);
                  }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('$_portions', 
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  _buildPortionBtn(Icons.add, () => setState(() => _portions++)),
                ],
              )
            ],
          ),
          if (_portions > 1) ...[
            const Divider(height: 30, color: Colors.brown, thickness: 0.5),
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.brown, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _portions == 2 
                      ? "Tipp: Backe zwei separate Einheiten nebeneinander."
                      : "Achtung: Bei $_portions ${widget.recipe.unitName} wird es eng in der Schüssel!",
                    style: const TextStyle(fontSize: 13, color: Colors.brown, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortionBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: const Color(0xFF7A4A32)),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: const Color(0xFFF7F2EE),
      flexibleSpace: FlexibleSpaceBar(
        background: Center(child: Text(widget.recipe.imageEmoji, style: const TextStyle(fontSize: 80))),
      ),
    );
  }

  Widget _buildIngredientRow(int index, String text) {
    bool isChecked = _checkedIngredients[index];
    return GestureDetector(
      onTap: () => setState(() => _checkedIngredients[index] = !isChecked),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isChecked ? Colors.grey.shade100 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isChecked ? Colors.green.withAlpha(50) : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_circle : Icons.circle_outlined, 
              size: 20, 
              color: isChecked ? Colors.green : const Color(0xFF7A4A32)
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text, 
                style: TextStyle(
                  fontSize: 16, 
                  decoration: isChecked ? TextDecoration.lineThrough : null,
                  color: isChecked ? Colors.grey : Colors.black87
                )
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => StepTimerPage(recipe: widget.recipe))),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7A4A32),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 64),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
      ),
      child: const Text("Back-Assistent starten", 
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}