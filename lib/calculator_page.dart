import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController flourController = TextEditingController();
  final TextEditingController hydrationController = TextEditingController(text: "70");
  final TextEditingController starterController = TextEditingController(text: "20");
  final TextEditingController saltController = TextEditingController(text: "2");

  double water = 0;
  double starter = 0;
  double salt = 0;
  double totalDough = 0;

  void calculate() {
    double flour = double.tryParse(flourController.text) ?? 0;
    double hydration = double.tryParse(hydrationController.text) ?? 0;
    double starterPercent = double.tryParse(starterController.text) ?? 0;
    double saltPercent = double.tryParse(saltController.text) ?? 0;

    setState(() {
      water = flour * (hydration / 100);
      starter = flour * (starterPercent / 100);
      salt = flour * (saltPercent / 100);
      totalDough = flour + water + starter + salt;
    });
  }

  Widget inputField(String label, TextEditingController controller, String suffix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget resultRow(String label, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text("${value.toStringAsFixed(0)} g",
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sauerteig Rechner")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Brotteig Berechnung",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            inputField("Mehlmenge", flourController, "g"),
            inputField("Hydration", hydrationController, "%"),
            inputField("Sauerteiganteil", starterController, "%"),
            inputField("Salz", saltController, "%"),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: calculate,
              child: const Text("Berechnen"),
            ),

            const Divider(height: 30),

            const Text(
              "Ergebnis:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            resultRow("Wasser", water),
            resultRow("Sauerteig", starter),
            resultRow("Salz", salt),
            const Divider(),
            resultRow("Gesamtteig", totalDough),
          ],
        ),
      ),
    );
  }
}
