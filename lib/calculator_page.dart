import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  double? _totalFlour;
  String _flourType = "Weizen";
  String _selectedType = "550"; 
  String _selectedExtra = "Keine";
  bool _isSameDay = false; 
  final Map<int, bool> _stepsDone = {};

  DateTime _targetTime = DateTime.now().add(const Duration(days: 1)).copyWith(
      hour: 12, minute: 0, second: 0, millisecond: 0);

  final Map<String, Map<String, double>> _mehlDetails = {
    "Weizen": {"405": 0.60, "550": 0.68, "1050": 0.74, "1600": 0.78},
    "Dinkel": {"630": 0.63, "1050": 0.72},
    "Roggen": {"997": 0.78, "1150": 0.82, "1370": 0.85},
    "Vollkorn": {"Weizen": 0.82, "Dinkel": 0.80, "Roggen": 0.88},
  };

  final Map<String, double> _extraLimits = {
    "Keine": 0.0, "Saaten": 0.20, "Oliven": 0.15, "Tomaten": 0.10, "Zwiebeln": 0.10,
  };

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

  @override
  Widget build(BuildContext context) {
    final double flour = _totalFlour ?? 0.0;
    final double extraWeight = flour * (_extraLimits[_selectedExtra] ?? 0);
    bool needsSoak = _selectedExtra == "Saaten" || _selectedExtra == "Tomaten";
    
    final double baseHydration = _mehlDetails[_flourType]?[_selectedType] ?? 0.70;
    final double waterBase = flour * baseHydration;
    final double extraWater = needsSoak ? extraWeight : 0.0;

    final double sourdough = flour * 0.20;
    final double sourdoughFlour = sourdough / 2;
    final double sourdoughWater = sourdough / 2;

    final double netFlour = flour - sourdoughFlour;
    final double netWater = waterBase - sourdoughWater;

    final double totalFlourForCalc = netFlour + sourdoughFlour;
    final double totalWaterForCalc = netWater + sourdoughWater;
    final double doughHydration = totalFlourForCalc > 0 
        ? (totalWaterForCalc / totalFlourForCalc).toDouble() 
        : 0.0;
    
    final double salt = flour * 0.02;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCFAF8),
        foregroundColor: const Color(0xFF4A2C1E),
        elevation: 0,
        title: const Text("Brot-Designer", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Hallo! Lass uns dein Brot planen.", style: TextStyle(fontSize: 16, color: Colors.brown, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildSectionTitle("Mehl-Konfiguration"),
            const SizedBox(height: 14),
            _buildMainInputCard(),
            
            const SizedBox(height: 24),
            _buildSectionTitle("Extras"),
            _buildExtraPicker(extraWeight),

            const SizedBox(height: 24),
            if (flour > 0) _buildResultCard(netWater, extraWater, sourdough, salt, doughHydration, needsSoak, extraWeight),

            const SizedBox(height: 32),
            _buildSectionTitle("Zeitplanung"),
            _buildTimePickerCard(),
            _buildModeToggle(),

            const SizedBox(height: 32),
            _buildTimeline(doughHydration),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF4A2C1E), letterSpacing: -0.5)),
    );
  }

  Widget _buildMainInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 4))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: _inputDecoration("Wie viel Mehl nutzt du insgesamt? (g)"),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => _totalFlour = double.tryParse(v)),
          ),
          const SizedBox(height: 24),
          const Text("GETREIDEART", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 8),
          _buildModernChipRow(_mehlDetails.keys.toList(), _flourType, (val) {
             setState(() {
                _flourType = val;
                _selectedType = _mehlDetails[val]!.keys.first;
              });
          }),
          const SizedBox(height: 20),
          const Text("TYPE / SPEZIFIKATION", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.brown)),
          const SizedBox(height: 8),
          _buildModernChipRow(_mehlDetails[_flourType]!.keys.toList(), _selectedType, (val) {
             setState(() => _selectedType = val);
          }, small: true),
        ],
      ),
    );
  }

  Widget _buildModernChipRow(List<String> items, String selectedItem, Function(String) onSelect, {bool small = false}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        bool isSelected = selectedItem == item;
        return InkWell(
          onTap: () => onSelect(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: small ? 12 : 16, vertical: small ? 8 : 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF7A4A32) : const Color(0xFFF7F2EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(item, style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4A2C1E),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: small ? 12 : 14,
            )),
          ),
        );
      }).toList(),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label, filled: true, fillColor: const Color(0xFFF7F2EE).withOpacity(0.5),
    labelStyle: const TextStyle(color: Colors.brown, fontWeight: FontWeight.w500),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF7A4A32), width: 2)),
  );

  Widget _buildExtraPicker(double weight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Möchtest du noch etwas hinzufügen?", style: TextStyle(fontSize: 14, color: Colors.black54)),
        const SizedBox(height: 12),
        _buildModernChipRow(_extraLimits.keys.toList(), _selectedExtra, (val) {
          setState(() => _selectedExtra = val);
        }),
      ],
    );
  }

  Widget _buildResultCard(double nw, double ew, double sd, double s, double hyd, bool soak, double exW) {
    String haptik = "Der Teig wird fest und stabil sein.";
    if (hyd > 0.75) haptik = "Der Teig wird sehr weich und klebrig – nimm eine Teigkarte!";
    if (hyd > 0.68 && hyd <= 0.75) haptik = "Der Teig ist geschmeidig und lässt sich gut dehnen.";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFE9D7CC), Color(0xFFD8C3B6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        _resRow("Hauptwasser", "${nw.toInt()} g"),
        if (exW > 0) _resRow(_selectedExtra, "${exW.toInt()} g"),
        if (ew > 0) _resRow("Einweichwasser", "${ew.toInt()} g"),
        _resRow("Sauerteig (1:1)", "${sd.toInt()} g"),
        _resRow("Salz", "${s.toInt()} g"),
        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Colors.white38)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Hydration", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
              child: Text("${(hyd * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF4A2C1E))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text("Hinweis: $haptik", style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF4A2C1E))),
      ]),
    );
  }

  Widget _resRow(String l, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(l, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A2C1E))), 
      Text(v, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF4A2C1E)))
    ]),
  );

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFD8C3B6).withOpacity(0.3))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          Icon(_isSameDay ? Icons.wb_sunny_rounded : Icons.ac_unit_rounded, size: 20, color: _isSameDay ? Colors.orange : Colors.blue),
          const SizedBox(width: 12),
          Text(_isSameDay ? "Same-Day Modus" : "Übernachtgare", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
        Switch(value: _isSameDay, activeColor: const Color(0xFF7A4A32), onChanged: (v) => setState(() => _isSameDay = v)),
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
        padding: const EdgeInsets.all(20), width: double.infinity,
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

  Widget _buildTimeline(double hydration) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> steps = _isSameDay 
      ? [
          {"id": 0, "t": -8, "title": "Sauerteig füttern", "d": "Dein Starter braucht jetzt Energie."},
          {"id": 1, "t": -4, "title": "Hauptteig mischen", "d": "Mehl, Wasser & Sauerteig vereinen."},
          {"id": 2, "t": -2, "title": "Formen", "d": "Vorsichtig Spannung aufbauen."},
          {"id": 3, "t": -1, "title": "Backen", "d": "Ofen volle Hitze (250°C)."},
        ]
      : [
          {"id": 0, "t": -24, "title": "Sauerteig füttern", "d": "Aktiviere deinen Starter."},
          {"id": 1, "t": -20, "title": "Teig kneten & falten", "d": "Struktur aufbauen durch Dehnen."},
          {"id": 2, "t": -14, "title": "Kalte Gare", "d": "Ab in den Kühlschrank für das Aroma."},
          {"id": 3, "t": -2, "title": "Formen", "d": "Gärkörbchen vorbereiten."},
          {"id": 4, "t": -1, "title": "Backen", "d": "Heißer Topf, viel Dampf."},
        ];

    if (_targetTime.add(Duration(hours: (steps[0]['t'] as int))).isBefore(now)) {
      return _buildTimeTravelCard();
    }

    return Column(children: [
      const Row(children: [
        Icon(Icons.auto_awesome_rounded, color: Colors.orangeAccent, size: 20),
        SizedBox(width: 10),
        Text("DEIN BACKPLAN", style: TextStyle(color: Color(0xFF4A2C1E), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
      ]),
      const SizedBox(height: 24),
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
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(shape: BoxShape.circle, color: isDone ? Colors.green : Colors.white, border: Border.all(color: isDone ? Colors.green : const Color(0xFF7A4A32), width: 2)),
                child: Icon(isDone ? Icons.check : Icons.circle, size: 10, color: isDone ? Colors.white : const Color(0xFF7A4A32)),
              ),
            ),
            if (!isLast) Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), color: const Color(0xFF7A4A32).withOpacity(0.2))),
          ]),
          const SizedBox(width: 20),
          Expanded(child: Opacity(opacity: isDone ? 0.4 : 1.0, child: Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_formatTimelineDate(time), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.brown)),
              const SizedBox(height: 4),
              Text(s['title'] as String, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, decoration: isDone ? TextDecoration.lineThrough : null, color: const Color(0xFF4A2C1E))),
              Text(s['d'] as String, style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ]),
          ))),
        ]));
      }).toList(),
    ]);
  }

  Widget _buildTimeTravelCard() => Container(
    padding: const EdgeInsets.all(24), width: double.infinity,
    decoration: BoxDecoration(color: const Color(0xFFFDECEA), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.red.withOpacity(0.1))),
    child: const Column(children: [
      Icon(Icons.history_toggle_off_rounded, color: Color(0xFFC06C53), size: 36),
      SizedBox(height: 12),
      Text("Zeitplan anpassen", style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFC06C53), fontSize: 18)),
      SizedBox(height: 6),
      Text("Verschiebe die Zielzeit, damit wir genug Vorlauf für den Teig haben.", textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.black87)),
    ]),
  );
}