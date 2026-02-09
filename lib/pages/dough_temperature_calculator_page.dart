import 'package:flutter/material.dart';
import '../models/dough_calculator_model.dart';

class DoughTemperatureCalculatorPage extends StatefulWidget {
  const DoughTemperatureCalculatorPage({super.key});

  @override
  State<DoughTemperatureCalculatorPage> createState() =>
      _DoughTemperatureCalculatorPageState();
}

class _DoughTemperatureCalculatorPageState
    extends State<DoughTemperatureCalculatorPage> {
  final TextEditingController _targetTempController = TextEditingController(text: '26');
  final TextEditingController _roomTempController = TextEditingController(text: '22');
  final TextEditingController _flourTempController = TextEditingController(text: '21');
  final TextEditingController _frictionFactorController = TextEditingController(text: '2.5');

  double? _calculatedWaterTemp;
  String? _garTimeRecommendation;
  double? _diehlNumber;
  double? _actualDoughTemp;

  void _calculate() {
    try {
      final targetTemp = double.parse(_targetTempController.text);
      final roomTemp = double.parse(_roomTempController.text);
      final flourTemp = double.parse(_flourTempController.text);
      final frictionFactor = double.parse(_frictionFactorController.text);

      setState(() {
        _calculatedWaterTemp =
            DoughTemperatureCalculator.calculateWaterTemperature(
          targetDoughTemp: targetTemp,
          roomTemp: roomTemp,
          flourTemp: flourTemp,
          frictionFactor: frictionFactor,
        );

        _garTimeRecommendation =
            DoughTemperatureCalculator.getGarTimeRecommendation(targetTemp);

        _actualDoughTemp =
            DoughTemperatureCalculator.calculateActualDoughTemp(
          waterTemp: _calculatedWaterTemp!,
          roomTemp: roomTemp,
          flourTemp: flourTemp,
          frictionFactor: frictionFactor,
        );

        _diehlNumber = DoughTemperatureCalculator.calculateDiehlNumber(
          doughTemp: targetTemp,
          gaerZeitStunden: 16, // Standard-Annahme
        );
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: Bitte gültige Zahlen eingeben')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teigtemperatur-Rechner'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: Colors.brown.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🌡️ Professionelle Formel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Zieltemp × 3 - (Raumtemp + Mehtemp + Reibung) = Wassertemp',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Die richtige Wassertemperatur ist entscheidend für die Gärzeit!',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Input Fields
            Text(
              'Eingabewerte',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _targetTempController,
              label: 'Gewünschte Teigtemperatur (°C)',
              hint: 'z.B. 26',
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _roomTempController,
              label: 'Raumtemperatur (°C)',
              hint: 'z.B. 22',
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _flourTempController,
              label: 'Mehltemperatur (°C)',
              hint: 'z.B. 21 (meist Raumtemp.)',
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _frictionFactorController,
              label: 'Reibungsfaktor',
              hint: '2.5 für Hand-Kneten / 3.0 für Maschine',
            ),
            const SizedBox(height: 20),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text(
                  'Berechnen',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Results
            if (_calculatedWaterTemp != null) ...[
              Text(
                'Ergebnisse',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              _buildResultCard(
                title: '💧 Notwendige Wassertemperatur',
                value: '${_calculatedWaterTemp!.toStringAsFixed(1)}°C',
                description: 'Erhitze dein Wasser auf diese Temperatur',
                color: Colors.lightBlue,
              ),
              const SizedBox(height: 12),

              _buildResultCard(
                title: '✅ Tatsächliche Teigtemperatur',
                value: '${_actualDoughTemp!.toStringAsFixed(1)}°C',
                description: 'Das erreichst du mit diesen Eingaben',
                color: Colors.green,
              ),
              const SizedBox(height: 12),

              _buildResultCard(
                title: '⏱️ Empfohlene Gärzeit',
                value: _garTimeRecommendation ?? '',
                description: 'Auf Basis der Teigtemperatur',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),

              _buildResultCard(
                title: '📊 Diehl-Zahl (16h Gärung)',
                value: _diehlNumber!.toStringAsFixed(1),
                description: 'Standard: 180-200 für Sauerteig',
                color: Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        prefixIcon: const Icon(Icons.thermostat),
      ),
    );
  }

  Widget _buildResultCard({
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
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
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

  @override
  void dispose() {
    _targetTempController.dispose();
    _roomTempController.dispose();
    _flourTempController.dispose();
    _frictionFactorController.dispose();
    super.dispose();
  }
}
