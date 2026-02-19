import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Icons für Extras
const Map<String, String> kExtraIcons = {
  "Keine": "",
  "Saaten": "🌻",
  "Oliven": "🫒",
  "Tomaten": "🍅",
  "Zwiebeln": "🧅",
};

// Hints für Extras (optional, falls benötigt)
const Map<String, String> kExtraHints = {
  "Saaten": "z.B. Sonnenblumen, Leinsamen",
  "Oliven": "entsteint, grob gehackt",
  "Tomaten": "getrocknet, gewürfelt",
  "Zwiebeln": "geröstet oder roh",
};
// Datenklasse für Rezept-Ergebnisse
class RecipeResult {
  final double mainFlour;
  final double mainWater;
  final double starterFlour;
  final double starterWater;
  final double salt;
  final double hydrationPercent;
  final double totalDoughWeight;
  final double extraWeight;
  final double extraWater;
  final double totalFlour;
  final double totalWater;

  RecipeResult({
    required this.mainFlour,
    required this.mainWater,
    required this.starterFlour,
    required this.starterWater,
    required this.salt,
    required this.hydrationPercent,
    required this.totalDoughWeight,
    required this.extraWeight,
    required this.extraWater,
    required this.totalFlour,
    required this.totalWater,
  });
}

const double kStarterPercent = 0.20;
const double kStarterHydration = 1.0; // 1:1
const double kSaltPercent = 0.02;
const double kMinStartHour = 6.0;

const Map<String, Map<String, double>> kBaseHydration = {
  "Weizen": {"405": 0.60, "550": 0.68, "1050": 0.74, "1600": 0.78},
  "Dinkel": {"630": 0.63, "1050": 0.72},
  "Roggen": {"997": 0.78, "1150": 0.82, "1370": 0.85},
  "Vollkorn": {"Weizen": 0.82, "Dinkel": 0.80, "Roggen": 0.88},
};

const Map<String, double> kExtraLimits = {
  "Keine": 0.0,
  "Saaten": 0.10,
  "Oliven": 0.15,
  "Tomaten": 0.10,
  "Zwiebeln": 0.10,
};

class TimelineStep {
  final String title;
  final String description;
  final DateTime time;
  final String? amounts;

  TimelineStep({
    required this.title,
    required this.description,
    required this.time,
    this.amounts,
  });
}

class BakerCalculator {
  // Neu: Rein für die Logik
  static double calculateFlourFromStarter(double availableStarter) {
    if (availableStarter <= 0) return 0;
    return ((availableStarter / 2) / (kStarterPercent / 2)) - (availableStarter / 2);
  }

  static RecipeResult calculate({
    required double flour,
    required String flourType,
    required String flourSpec,
    required String extra,
  }) {
    final double baseHydration = kBaseHydration[flourType]?[flourSpec] ?? 0.70;
    final double starterTotal = flour * kStarterPercent;
    final double starterFlour = starterTotal / 2;
    final double starterWater = starterTotal / 2;
    final double totalFlour = flour + starterFlour;
    double targetTotalWater = totalFlour * baseHydration;
    double mainWater = targetTotalWater - starterWater;

    final double extraLimit = kExtraLimits[extra] ?? 0.0;
    final double extraWeight = flour * extraLimit;
    double extraWater = 0.0;
    if (extra == "Saaten") {
      extraWater = extraWeight * 1.0;
      mainWater += extraWater;
    } else if (extra == "Oliven") {
      mainWater -= extraWeight * 0.3;
    } else if (extra == "Tomaten") {
      mainWater -= extraWeight * 0.5;
    } else if (extra == "Zwiebeln") {
      mainWater -= extraWeight * 0.2;
    }

    final double salt = flour * kSaltPercent;
    final double totalWater = mainWater + starterWater;
    final double hydrationPercent = totalFlour > 0 ? (totalWater / totalFlour) * 100 : 0;
    final double totalDoughWeight = totalFlour + totalWater + salt + extraWeight;

    return RecipeResult(
      mainFlour: flour,
      mainWater: mainWater,
      starterFlour: starterFlour,
      starterWater: starterWater,
      salt: salt,
      hydrationPercent: hydrationPercent,
      totalDoughWeight: totalDoughWeight,
      extraWeight: extraWeight,
      extraWater: extraWater,
      totalFlour: totalFlour,
      totalWater: totalWater,
    );
  }

  static List<TimelineStep> generateTimeline({
    required RecipeResult result,
    required String flourType,
    required String extra,
    required DateTime targetTime,
    required bool isSameDay,
  }) {
    final List<Map<String, dynamic>> template = _getTimelineTemplate(flourType, isSameDay);
    DateTime firstStepTime = targetTime.add(Duration(hours: template.first['t'] as int));
    if (firstStepTime.hour < kMinStartHour) {
      final diff = kMinStartHour - firstStepTime.hour;
      final shift = Duration(hours: diff.ceil());
      firstStepTime = firstStepTime.add(shift);
    }
    final DateTime adjustedTargetTime = targetTime.add(firstStepTime.difference(targetTime.add(Duration(hours: template.first['t'] as int))));

    List<TimelineStep> steps = [];
    // Extras: Saaten einweichen als eigenen Schritt
    if (extra == "Saaten" && result.extraWeight > 0) {
      final DateTime einweichTime = adjustedTargetTime.add(Duration(hours: template.first['t'] as int) - Duration(hours: 1));
      steps.add(TimelineStep(
        title: "Saaten einweichen",
        description: "Saaten mindestens 1h vorher einweichen. Einweichwasser: ${result.extraWater.toInt()}g",
        time: einweichTime,
        amounts: "Saaten: ${result.extraWeight.toInt()}g, Wasser: ${result.extraWater.toInt()}g",
      ));
    }
    for (final step in template) {
      final DateTime stepTime = adjustedTargetTime.add(Duration(hours: step['t'] as int));
      String? amounts;
      String desc = step['d'];
      if (step['title'] == "Sauerteig füttern") {
        desc += "\nSauerteig ansetzen, reifen lassen bis verdoppelt (4–8h bei 25–28°C, aktiv und blubbernd verwenden).";
        amounts = "Sauerteig: ${(result.starterFlour + result.starterWater).toInt()}g";
      } else if (step['title'] == "Autolyse & Hauptteig" || step['title'] == "Hauptteig mischen") {
        amounts = "Mehl: ${result.mainFlour.toInt()}g, Wasser: ${result.mainWater.toInt()}g, Salz: ${result.salt.toInt()}g";
        if (result.extraWeight > 0) {
          amounts += ", $extra: ${result.extraWeight.toInt()}g";
          if (extra == "Saaten" && result.extraWater > 0) {
            amounts += ", Einweichwasser: ${result.extraWater.toInt()}g";
          }
        }
      } else if (step['title'] == "Dehnen & Falten") {
        desc = "Dehnen & Falten: 3x im Abstand von 30 Minuten. Teig an einer Seite greifen, langziehen und über den Teig schlagen. Schüssel drehen, wiederholen, bis alle Seiten gedehnt wurden. Nach jedem D&F Teig abgedeckt ruhen lassen.";
      } else if (step['title'] == "Backen") {
        amounts = "Ofen vorheizen & Brot backen";
      }
      steps.add(TimelineStep(title: step['title'], description: desc, time: stepTime, amounts: amounts));
    }
    return steps;
  }

  static List<Map<String, dynamic>> _getTimelineTemplate(String flourType, bool isSameDay) {
    if (flourType == "Weizen") {
        return isSameDay
          ? [{"t": -8, "title": "Sauerteig füttern", "d": "Dein Starter braucht jetzt Energie."}, {"t": -4, "title": "Autolyse & Hauptteig", "d": "Mehl & Wasser mischen, dann Sauerteig zugeben."}, {"t": -3, "title": "Dehnen & Falten", "d": "Teig kräftig dehnen für Struktur."}, {"t": -2, "title": "Formen", "d": "Vorsichtig Spannung aufbauen."}, {"t": -1, "title": "Backen", "d": "Ofen volle Hitze (250°C)."}]
          : [{"t": -24, "title": "Sauerteig füttern", "d": "Aktiviere deinen Starter."}, {"t": -20, "title": "Autolyse & Hauptteig", "d": "Mehl & Wasser mischen, dann Sauerteig zugeben."}, {"t": -18, "title": "Dehnen & Falten", "d": "Teig kräftig dehnen für Struktur."}, {"t": -3, "title": "Formen", "d": "Gärkörbchen vorbereiten."}, {"t": -2, "title": "Kalte Gare", "d": "Ab in den Kühlschrank für das Aroma."}, {"t": -1, "title": "Backen", "d": "Ofen auf 250°C vorheizen.\n10–15 Min anbacken, dann auf 220°C reduzieren.\nGesamt ca. 45 Min."}];
    } else if (flourType == "Dinkel") {
        return isSameDay
          ? [{"t": -8, "title": "Sauerteig füttern", "d": "Dinkelstarter auffrischen."}, {"t": -4, "title": "Hauptteig mischen", "d": "Mehl, Wasser & Sauerteig sanft mischen."}, {"t": -3, "title": "Kneten (kurz)", "d": "Dinkel nur kurz kneten!"}, {"t": -2, "title": "Formen", "d": "Sanft formen, wenig Spannung."}, {"t": -1, "title": "Backen", "d": "Ofen auf 230°C vorheizen."}]
          : [{"t": -24, "title": "Sauerteig füttern", "d": "Dinkelstarter auffrischen."}, {"t": -20, "title": "Hauptteig mischen", "d": "Mehl, Wasser & Sauerteig sanft mischen."}, {"t": -18, "title": "Kneten (kurz)", "d": "Dinkel nur kurz kneten!"}, {"t": -3, "title": "Formen", "d": "Sanft formen, wenig Spannung."}, {"t": -2, "title": "Kalte Gare", "d": "Über Nacht im Kühlschrank."}, {"t": -1, "title": "Backen", "d": "Ofen auf 240°C vorheizen."}];
    } else if (flourType == "Roggen") {
        return isSameDay
          ? [{"t": -10, "title": "Sauerteig füttern", "d": "Roggenstarter auffrischen."}, {"t": -6, "title": "Hauptteig mischen", "d": "Mehl, Wasser & Sauerteig gut verrühren."}, {"t": -4, "title": "Teigruhe", "d": "Roggen braucht Zeit zum Quellen."}, {"t": -2, "title": "Formen", "d": "Teig in Form bringen."}, {"t": -1, "title": "Backen", "d": "Ofen auf 240°C vorheizen."}]
          : [{"t": -28, "title": "Sauerteig füttern", "d": "Roggenstarter auffrischen."}, {"t": -24, "title": "Hauptteig mischen", "d": "Mehl, Wasser & Sauerteig gut verrühren."}, {"t": -20, "title": "Teigruhe", "d": "Roggen braucht Zeit zum Quellen."}, {"t": -3, "title": "Formen", "d": "Teig in Form bringen."}, {"t": -2, "title": "Kalte Gare", "d": "Über Nacht im Kühlschrank."}, {"t": -1, "title": "Backen", "d": "Ofen auf 240°C vorheizen."}];
    }
    return [{"t": -8, "title": "Sauerteig füttern", "d": "Starter auffrischen."}, {"t": -4, "title": "Hauptteig mischen", "d": "Mehl, Wasser & Sauerteig mischen."}, {"t": -2, "title": "Formen", "d": "Teig formen."}, {"t": -1, "title": "Backen", "d": "Ofen vorheizen."}];
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _flourController = TextEditingController();

  double? _mainFlour;
  String _flourType = "Weizen";
  String _flourSpec = "550";
  String _selectedExtra = "Keine";
  bool _isSameDay = false;
  DateTime _targetTime = DateTime.now().add(const Duration(days: 1)).copyWith(hour: 12, minute: 0, second: 0, millisecond: 0, microsecond: 0);

  RecipeResult? _result;
  List<TimelineStep> _timeline = [];

  void _recalculate() {
    final flour = _mainFlour ?? 0.0;
    final result = BakerCalculator.calculate(flour: flour, flourType: _flourType, flourSpec: _flourSpec, extra: _selectedExtra);
    final timeline = BakerCalculator.generateTimeline(result: result, flourType: _flourType, extra: _selectedExtra, targetTime: _targetTime, isSameDay: _isSameDay);
    setState(() { _result = result; _timeline = timeline; });
  }

  // NEU: Nur diese Funktion für den "Waage"-Button hinzugefügt
  void _showStarterRestDialog() {
    double rest = 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sauerteig-Rest verwerten"),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "Vorhandener Sauerteig (g)"),
          onChanged: (v) => rest = double.tryParse(v) ?? 0,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Abbrechen")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _mainFlour = BakerCalculator.calculateFlourFromStarter(rest);
                _flourController.text = _mainFlour!.toInt().toString();
                _recalculate();
              });
              Navigator.pop(ctx);
            },
            child: const Text("Berechnen"),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _recalculate();
  }

  String _weekday(DateTime date) {
    const map = {"Mon": "Mo", "Tue": "Di", "Wed": "Mi", "Thu": "Do", "Fri": "Fr", "Sat": "Sa", "Sun": "So"};
    return map[DateFormat("EEE").format(date)] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF8),
        foregroundColor: const Color(0xFF4A2C1E),
        elevation: 0,
        title: const Text("Brot-Designer", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
        actions: [
          IconButton(onPressed: _showStarterRestDialog, icon: const Icon(Icons.scale_outlined, color: Color(0xFF7A4A32))),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainInputCard(),
            const SizedBox(height: 24),
            _buildTimePickerCard(),
            _buildModeToggle(),
            const SizedBox(height: 32),
            if (result != null) ...[
              _buildWarningIfPast(),
              _buildTimeline(_timeline),
              const SizedBox(height: 32),
              _buildSummaryCard(result),
            ],
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningIfPast() {
    if (_timeline.isEmpty) return const SizedBox.shrink();
    final firstStep = _timeline.first;
    if (firstStep.time.isBefore(DateTime.now())) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.orange.shade200)),
        child: Row(children: [
          const Icon(Icons.cake_outlined, color: Colors.orange, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Text("Hoppla! Dein Zeitplan startet in der Vergangenheit.", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600))),
        ]),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMainInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Wie viel Mehl nutzt du insgesamt? (g)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF4A2C1E))),
          const SizedBox(height: 8),
          TextField(
            controller: _flourController,
            decoration: _inputDecoration(''),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            keyboardType: TextInputType.number,
            onChanged: (v) { _mainFlour = double.tryParse(v); _recalculate(); },
          ),
          const SizedBox(height: 24),
          const Text("GETREIDEART", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 8),
          _buildModernChipRow(kBaseHydration.keys.toList(), _flourType, (val) {
            setState(() { _flourType = val; _flourSpec = kBaseHydration[val]!.keys.first; _recalculate(); });
          }),
          const SizedBox(height: 20),
          const Text("TYPE / SPEZIFIKATION", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 8),
          _buildModernChipRow(kBaseHydration[_flourType]!.keys.toList(), _flourSpec, (val) {
            setState(() { _flourSpec = val; _recalculate(); });
          }, small: true),
          const SizedBox(height: 20),
          _buildExtraPicker(),
        ],
      ),
    );
  }

  Widget _buildModernChipRow(List<String> items, String selectedItem, Function(String) onSelect, {bool small = false}) {
    return Wrap(spacing: 8, runSpacing: 8, children: items.map((item) {
      bool isSelected = selectedItem == item;
      return InkWell(
        onTap: () => onSelect(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: small ? 12 : 16, vertical: small ? 8 : 10),
          decoration: BoxDecoration(color: isSelected ? const Color(0xFF7A4A32) : const Color(0xFFF7F2EE), borderRadius: BorderRadius.circular(12)),
          child: Text(item, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF4A2C1E), fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: small ? 12 : 14)),
        ),
      );
    }).toList());
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label, filled: true, fillColor: const Color(0xFFF7F2EE).withOpacity(0.5),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF7A4A32), width: 2)),
  );

  Widget _buildExtraPicker() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Möchtest du noch etwas hinzufügen?", style: TextStyle(fontSize: 14, color: Colors.black54)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(
        value: _selectedExtra,
        decoration: InputDecoration(filled: true, fillColor: const Color(0xFFF7F2EE).withOpacity(0.5), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF7A4A32)),
        onChanged: (val) { setState(() { _selectedExtra = val ?? "Keine"; _recalculate(); }); },
        items: kExtraLimits.keys.map((item) => DropdownMenuItem(value: item, child: Row(children: [Text(kExtraIcons[item] ?? ""), const SizedBox(width: 10), Text(item)]))).toList(),
      ),
    ]);
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD8C3B6).withOpacity(0.3))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(_isSameDay ? "Same-Day Modus" : "Übernachtgare", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Switch(value: _isSameDay, activeColor: const Color(0xFF7A4A32), onChanged: (v) { setState(() { _isSameDay = v; _recalculate(); }); }),
      ]),
    );
  }

  Widget _buildTimePickerCard() {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: _targetTime, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 30)));
        if (d == null) return;
        final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_targetTime));
        if (t == null) return;
        setState(() { _targetTime = DateTime(d.year, d.month, d.day, t.hour, t.minute); _recalculate(); });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFD8C3B6).withOpacity(0.5))),
        child: Row(children: [
          const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF7A4A32)),
          const SizedBox(width: 16),
          Text("${_weekday(_targetTime)}, ${DateFormat("dd.MM. HH:mm").format(_targetTime)} Uhr", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.edit, size: 16, color: Colors.black26),
        ]),
      ),
    );
  }

  Widget _buildTimeline(List<TimelineStep> steps) {
    return Column(children: [
      const Text("DEIN BACKPLAN", style: TextStyle(color: Color(0xFF4A2C1E), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
      const SizedBox(height: 24),
      ...steps.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.circle, size: 14, color: const Color(0xFF7A4A32)),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(DateFormat("dd.MM. HH:mm").format(s.time), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.brown)),
            Text(s.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF4A2C1E))),
            Text(s.description, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            if (s.amounts != null) Text(s.amounts!, style: const TextStyle(fontSize: 14, color: Color(0xFF7C5C3B), fontWeight: FontWeight.bold)),
          ])),
        ]),
      )),
    ]);
  }

  Widget _buildSummaryCard(RecipeResult result) {
    return Card(
      color: const Color(0xFFF5E9E0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
        Text("${result.hydrationPercent.toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28)),
        const Text("Hydration"),
        const SizedBox(height: 16),
          _resRow("Mehl", "${result.mainFlour.toInt()} g"),
          _resRow("Hauptwasser", "${result.mainWater.toInt()} g"),
          if (result.extraWeight > 0) _resRow(_selectedExtra, "${result.extraWeight.toInt()} g"),
          if (result.extraWater > 0 && _selectedExtra == "Saaten") _resRow("Einweichwasser", "${result.extraWater.toInt()} g"),
          _resRow("Sauerteig (1:1)", "${(result.starterFlour + result.starterWater).toInt()} g"),
          _resRow("Salz", "${result.salt.toInt()} g"),
        const Divider(),
        Text("Gesamt: ${result.totalDoughWeight.toInt()} g", style: const TextStyle(fontWeight: FontWeight.bold)),
      ])),
    );
  }

  Widget _resRow(String l, String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l), Text(v)]));
}