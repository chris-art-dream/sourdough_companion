import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // ---------- STATE ----------
  double? _totalFlour;
  String _flourType = "Weizen";
  String _selectedExtra = "Keine";
  bool _isSameDay = false; 
  final Map<int, bool> _stepsDone = {};

  DateTime _targetTime = DateTime.now().add(const Duration(days: 1)).copyWith(
      hour: 12, minute: 0, second: 0, millisecond: 0);

  final Map<String, double> _hydrationMap = {
    "Weizen": 0.70, "Dinkel": 0.65, "Roggen": 0.80, "Vollkorn": 0.75,
  };

  final Map<String, double> _extraLimits = {
    "Keine": 0.0, "Saaten": 0.20, "Oliven": 0.15, "Tomaten": 0.10, "Zwiebeln": 0.10,
  };

  // ---------- HELPERS ----------
  String _weekday(DateTime date) {
    const map = {"Mon": "Mo", "Tue": "Di", "Wed": "Mi", "Thu": "Do", "Fri": "Fr", "Sat": "Sa", "Sun": "So"};
    return map[DateFormat("EEE").format(date)] ?? "";
  }

  String _formatTimelineDate(DateTime time) {
    final now = DateTime.now();
    if (now.day == time.day && now.month == time.month && now.year == time.year) {
      return "Heute • ${DateFormat("HH:mm").format(time)}";
    }
    return "${_weekday(time)}, ${DateFormat("dd.MM.").format(time)} • ${DateFormat("HH:mm").format(time)}";
  }

  // ---------- BUILD ----------
  @override
  Widget build(BuildContext context) {
    final double flour = _totalFlour ?? 0.0;
    final double extraWeight = flour * (_extraLimits[_selectedExtra] ?? 0);
    bool needsSoak = _selectedExtra == "Saaten" || _selectedExtra == "Tomaten";
    final double extraWater = needsSoak ? extraWeight : 0.0;

    final double baseHydration = _hydrationMap[_flourType] ?? 0.70;
    final double waterBase = flour * baseHydration;
    final double sourdough = flour * 0.20;
    final double sourdoughFlour = sourdough / 2.0;
    final double sourdoughWater = sourdough / 2.0;

    final double totalFlour = flour + sourdoughFlour;
    final double totalWater = waterBase + sourdoughWater;
    final double doughHydration = totalFlour > 0 ? (totalWater / totalFlour).toDouble() : 0.0;
    final double salt = flour * 0.02;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF8),
        foregroundColor: const Color(0xFF4A2C1E),
        elevation: 0,
        title: const Text("Brot-Designer", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Gib deine Zutaten ein", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A2C1E))),
            const SizedBox(height: 6),
            const Text("Ich berechne automatisch die passende Hydration und passende Extras.", style: TextStyle(fontSize: 13, color: Colors.black54)),
            
            const SizedBox(height: 14),
            _buildInputCard(),
            
            const SizedBox(height: 20),
            _buildExtraPicker(extraWeight),

            const SizedBox(height: 20),
            if (flour > 0) _buildResultCard(waterBase, extraWater, sourdough, salt, doughHydration, needsSoak),

            const SizedBox(height: 30),
            const Text("Wann soll dein Brot fertig sein?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A2C1E))),
            const SizedBox(height: 6),
            const Text("Ich plane die Schritte automatisch für dich.", style: TextStyle(fontSize: 13, color: Colors.black54)),
            
            const SizedBox(height: 12),
            _buildTimePickerCard(),
            _buildModeToggle(),

            const SizedBox(height: 24),
            _buildTimeline(doughHydration),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------- UI COMPONENTS ----------

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        TextField(
          decoration: _inputDecoration("Mehlmenge (g)"),
          keyboardType: TextInputType.number,
          onChanged: (v) => setState(() => _totalFlour = double.tryParse(v)),
        ),
        const SizedBox(height: 14),
        Wrap(spacing: 8, children: _hydrationMap.keys.map((typ) => ChoiceChip(
          label: Text(typ), selected: _flourType == typ,
          onSelected: (_) => setState(() => _flourType = typ),
        )).toList()),
      ]),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label, filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFD8C3B6))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF7A4A32))),
  );

  Widget _buildExtraPicker(double weight) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFD8C3B6).withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Extras hinzufügen", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A2C1E))),
        const SizedBox(height: 10),
        Wrap(spacing: 8, children: _extraLimits.keys.map((e) => ChoiceChip(
          label: Text(e), selected: _selectedExtra == e,
          onSelected: (_) => setState(() => _selectedExtra = e),
        )).toList()),
        if (_selectedExtra != "Keine") Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(children: [
            const Icon(Icons.info_outline, size: 16, color: Colors.brown),
            const SizedBox(width: 6),
            Text("Empfehlung: ${weight.toInt()} g hinzufügen.", style: const TextStyle(fontSize: 13, color: Colors.brown, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildResultCard(double wb, double ew, double sd, double s, double hyd, bool soak) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFFE9D7CC), borderRadius: BorderRadius.circular(22)),
      child: Column(children: [
        _resRow("Wasser", "${wb.toInt()} g"),
        if (ew > 0) _resRow(soak ? "Einweichwasser (Saaten)" : "Zusatzwasser", "${ew.toInt()} g"),
        _resRow("Sauerteig", "${sd.toInt()} g"),
        _resRow("Salz", "${s.toInt()} g"),
        const Divider(height: 24, color: Colors.white54),
        Text("Gesamthydration: ${(hyd * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A2C1E))),
      ]),
    );
  }

  Widget _resRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(fontWeight: FontWeight.w600)), 
      Text(v, style: const TextStyle(fontWeight: FontWeight.bold))
    ]),
  );

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: _isSameDay ? Colors.orange.withOpacity(0.05) : Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(14)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(_isSameDay ? Icons.wb_sunny : Icons.ac_unit, size: 18, color: _isSameDay ? Colors.orange : Colors.blue),
          const SizedBox(width: 8),
          Text(_isSameDay ? "Same-Day Modus" : "Standard: Übernachtgare", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ]),
        Switch(value: _isSameDay, activeColor: Colors.orange, onChanged: (v) => setState(() => _isSameDay = v)),
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
        setState(() { _targetTime = DateTime(d.year, d.month, d.day, t.hour, t.minute); _stepsDone.clear(); });
      },
      child: Container(
        padding: const EdgeInsets.all(18), width: double.infinity,
        decoration: BoxDecoration(color: const Color(0xFFF7F2EE), borderRadius: BorderRadius.circular(18)),
        child: Row(children: [
          const Icon(Icons.calendar_today, size: 18, color: Color(0xFF7A4A32)),
          const SizedBox(width: 12),
          Text("${_weekday(_targetTime)}, ${DateFormat("dd.MM. HH:mm").format(_targetTime)} Uhr", style: const TextStyle(fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _buildTimeline(double hydration) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> steps = _isSameDay 
      ? [
          {"id": 0, "t": -8, "title": "Sauerteig füttern", "d": "Früh am Morgen starten."},
          {"id": 1, "t": -4, "title": "Teig kneten", "d": "Alles mischen & kräftig dehnen."},
          {"id": 2, "t": -2, "title": "Formen", "d": "In das Gärkörbchen legen."},
          {"id": 3, "t": -1, "title": "Backen", "d": "Ofen volle Hitze (250°C)."},
        ]
      : [
          {"id": 0, "t": -24, "title": "Sauerteig füttern", "d": "Ideal gegen 12:00 Uhr mittags."},
          {"id": 1, "t": -20, "title": "Teig kneten & falten", "d": "Gegen 16:00 Uhr mischen."},
          {"id": 2, "t": -14, "title": "Ab in den Kühlschrank", "d": "Kalte Gare für mehr Aroma."},
          {"id": 3, "t": -2, "title": "Formen & Aufwärmen", "d": "Teig kurz akklimatisieren."},
          {"id": 4, "t": -1, "title": "Backen", "d": "Direkt aus der Kälte in den Ofen."},
        ];

    if (_targetTime.add(Duration(hours: (steps[0]['t'] as int))).isBefore(now)) {
      return _buildTimeTravelCard();
    }

    return Column(children: [
      Row(children: [
        const Icon(Icons.auto_awesome, color: Colors.orangeAccent, size: 16),
        const SizedBox(width: 8),
        Text("Dein Plan steht!", style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 13)),
      ]),
      const SizedBox(height: 20),
      ...steps.map((s) {
        final id = s['id'] as int;
        final time = _targetTime.add(Duration(hours: (s['t'] as int)));
        final bool isDone = _stepsDone[id] ?? false;
        final bool isLast = steps.indexOf(s) == steps.length - 1;

        return IntrinsicHeight(child: Row(children: [
          Column(children: [
            GestureDetector(
              onTap: () => setState(() => _stepsDone[id] = !isDone),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? Colors.green : Colors.white, border: Border.all(color: isDone ? Colors.green : const Color(0xFF7A4A32), width: 2)),
                child: Icon(isDone ? Icons.check : Icons.circle, size: 12, color: isDone ? Colors.white : const Color(0xFF7A4A32)),
              ),
            ),
            if (!isLast) Expanded(child: Container(width: 2, color: const Color(0xFF7A4A32).withOpacity(0.2))),
          ]),
          const SizedBox(width: 20),
          Expanded(child: Opacity(opacity: isDone ? 0.5 : 1.0, child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_formatTimelineDate(time), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown)),
              Text(s['title'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, decoration: isDone ? TextDecoration.lineThrough : null, color: const Color(0xFF4A2C1E))),
              Text(s['d'] as String, style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ]),
          ))),
        ]));
      }).toList(),
    ]);
  }

  Widget _buildTimeTravelCard() => Container(
    padding: const EdgeInsets.all(20), width: double.infinity,
    decoration: BoxDecoration(color: const Color(0xFFFDECEA), borderRadius: BorderRadius.circular(20)),
    child: const Column(children: [
      Icon(Icons.auto_awesome_outlined, color: Color(0xFFC06C53)),
      SizedBox(height: 8),
      Text("Zeitreise gefällig?", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFC06C53))),
      Text("Dein Plan startet in der Vergangenheit. Schieb die Zielzeit nach hinten! ✨", textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
    ]),
  );
}