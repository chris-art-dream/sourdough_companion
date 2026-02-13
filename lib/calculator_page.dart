import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // --- STATE ---
  double _totalFlour = 500;
  double _saatenGramm = 0; 
  String _mehlTyp = "Weizen";
  Map<int, bool> _stepsDone = {};
  
  DateTime _targetTime = DateTime.now().add(const Duration(days: 1)).copyWith(
      hour: 12, minute: 0, second: 0, millisecond: 0);

  final Map<String, double> _hydrationMap = {
    "Weizen": 0.70,
    "Dinkel": 0.65,
    "Roggen": 0.80,
    "Vollkorn": 0.75,
  };

  // --- LOGIK ---
  String _getGermanWeekday(DateTime date) {
    const weekdays = {'Mon': 'Mo', 'Tue': 'Di', 'Wed': 'Mi', 'Thu': 'Do', 'Fri': 'Fr', 'Sat': 'Sa', 'Sun': 'So'};
    String englishDay = DateFormat('EEE').format(date);
    return weekdays[englishDay] ?? englishDay;
  }

  int _getGaeuerzeitDauer(double hydration) {
    if (hydration > 0.75) return 3; 
    if (hydration < 0.68) return 5; 
    return 4; 
  }

  @override
  Widget build(BuildContext context) {
    double baseHydration = _hydrationMap[_mehlTyp] ?? 0.70;
    double waterBase = _totalFlour * baseHydration;
    double waterSaaten = _saatenGramm; 
    double totalWater = waterBase + waterSaaten;
    double effectiveHydration = totalWater / (_totalFlour + _saatenGramm);
    
    double sourdough = _totalFlour * 0.20;
    double salt = _totalFlour * 0.02;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        title: const Text("Brot-Designer", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("1. Rezept-Konfiguration"),
            _buildInputCard(),
            const SizedBox(height: 20),
            _buildResultCard(waterBase, waterSaaten, sourdough, salt, effectiveHydration),
            const SizedBox(height: 40),
            _buildSectionTitle("2. Interaktiver Backplan"),
            _buildTimePickerCard(),
            const SizedBox(height: 24),
            _buildDynamicTimeline(effectiveHydration),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF7A4A32))),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: "Gesamtmehl (g)",
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => _totalFlour = double.tryParse(v) ?? 500),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: "Kerne / Saaten (g)",
              hintText: "0",
              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => _saatenGramm = double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 24),
          const Text("Mehl-Typ wählen:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _hydrationMap.keys.map((String typ) {
              final bool isSelected = _mehlTyp == typ;
              return ChoiceChip(
                label: Text(typ),
                selected: isSelected,
                selectedColor: const Color(0xFF7A4A32),
                backgroundColor: const Color(0xFFF7F2EE),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onSelected: (bool selected) {
                  if (selected) setState(() => _mehlTyp = typ);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(double wBase, double wSaaten, double s, double sa, double hyd) {
    Color hydrationColor = Colors.white60;
    String warnText = "";
    if (hyd > 0.85) {
      hydrationColor = Colors.redAccent;
      warnText = "⚠️ Extrem weicher Teig! Schwer zu formen.";
    } else if (hyd > 0.80) {
      hydrationColor = Colors.orangeAccent;
      warnText = "⚠️ Hohe Hydration. Erfordert Erfahrung.";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF7A4A32), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _resRow("Wasser für Teig", "${wBase.toInt()}g"),
          if (wSaaten > 0) _resRow("Wasser für Saaten", "${wSaaten.toInt()}g"),
          const Divider(color: Colors.white24),
          _resRow("Sauerteig (fit)", "${s.toInt()}g"),
          const Divider(color: Colors.white24),
          _resRow("Salz", "${sa.toInt()}g"),
          const SizedBox(height: 10),
          Text("Effektive Hydration: ${(hyd * 100).toInt()}%", 
               style: TextStyle(color: hydrationColor, fontSize: 13, fontWeight: FontWeight.bold)),
          if (warnText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(warnText, style: const TextStyle(color: Colors.white, fontSize: 11, fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }

  Widget _resRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(color: Colors.white70, fontSize: 16)),
      Text(v, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
    ]),
  );

  Widget _buildTimePickerCard() {
    return InkWell(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _targetTime,
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (pickedDate != null) {
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(_targetTime),
          );
          if (pickedTime != null) {
            setState(() {
              _targetTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
              _stepsDone.clear(); // Plan-Reset bei Zeitänderung
            });
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFFF7F2EE), borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF7A4A32)),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Geplante Fertigstellung:", style: TextStyle(fontSize: 12, color: Colors.brown)),
              Text("${_getGermanWeekday(_targetTime)}, ${DateFormat('dd.MM. - HH:mm').format(_targetTime)} Uhr", 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ]),
            const Spacer(),
            const Icon(Icons.edit, size: 16, color: Colors.brown),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicTimeline(double hydration) {
    final now = DateTime.now();
    final gaeuerDauer = _getGaeuerzeitDauer(hydration);

    final steps = [
      {"id": 0, "t": -24, "title": "Sauerteig aktivieren", "desc": "Starter füttern und warm stellen."},
      {"id": 1, "t": -(gaeuerDauer + 2), "title": "Autolyse & Mischen", "desc": "Mehl, Wasser & Sauerteig grob mischen."},
      {"id": 2, "t": -gaeuerDauer, "title": "Stockgare", "desc": "Teig ruhen lassen und Volumen beobachten."},
      {"id": 3, "t": -2, "title": "Formen & Stückgare", "desc": "In das Gärkörbchen geben."},
      {"id": 4, "t": -1, "title": "Backen", "desc": "Topf vorheizen, einschneiden, backen."},
      {"id": 5, "t": 0, "title": "Fertig!", "desc": "Vollständig auskühlen lassen."},
    ];

    // Prüfen, ob der allererste Schritt in der Vergangenheit liegt
    final firstStepTime = _targetTime.add(Duration(hours: steps[0]['t'] as int));
    bool planImpossible = firstStepTime.isBefore(now);

    if (planImpossible) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: const Color(0xFFFDECEA), borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome_outlined, color: Color(0xFFC06C53), size: 32),
            const SizedBox(height: 12),
            const Text(
              "Zeitreise gefällig?",
              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC06C53), fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "Dein Plan müsste schon gestern starten. Schieb die Fertigstellung ein Stück nach hinten, damit der Teig genug Zeit zum Ruhen hat. ✨",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.orangeAccent, size: 18),
              SizedBox(width: 8),
              Text("Dein Zeitplan passt perfekt!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        ...steps.map((s) {
          final stepId = s['id'] as int;
          final isDone = _stepsDone[stepId] ?? false;
          final time = _targetTime.add(Duration(hours: s['t'] as int));
          Color itemColor = isDone ? Colors.grey.shade400 : const Color(0xFF7A4A32);

          return Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: InkWell(
              onTap: () => setState(() => _stepsDone[stepId] = !isDone),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Icon(isDone ? Icons.check_circle_outline : Icons.radio_button_unchecked, color: itemColor, size: 22),
                      if (stepId != 5) Container(width: 1.5, height: 45, color: Colors.grey.shade200),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_getGermanWeekday(time)}, ${DateFormat('HH:mm').format(time)} Uhr - ${s['title']}",
                          style: TextStyle(fontWeight: FontWeight.bold, color: itemColor, decoration: isDone ? TextDecoration.lineThrough : null),
                        ),
                        const SizedBox(height: 4),
                        Text(s['desc'] as String, style: TextStyle(fontSize: 13, color: isDone ? Colors.grey : Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}