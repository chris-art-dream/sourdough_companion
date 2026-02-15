import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

// WICHTIG: Deine Model-Klasse muss diese Felder haben (name, type, lastFed, fridgeMode, temperature, history, feedingPhotos)
import 'models/sourdough_starter_model.dart';

class SourdoughPage extends StatefulWidget {
  const SourdoughPage({super.key});
  @override
  State<SourdoughPage> createState() => _SourdoughPageState();
}

class _SourdoughPageState extends State<SourdoughPage> {
  List<SourdoughStarter> starters = [];

  @override
  void initState() {
    super.initState();
    _loadStarters();
  }

  // --- PERSISTENZ ---
  Future<void> _loadStarters() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('sourdough_starters');
    if (data != null) {
      setState(() {
        starters = List<Map<String, dynamic>>.from(json.decode(data))
            .map((e) => SourdoughStarter.fromJson(e))
            .toList();
      });
    }
  }

  Future<void> _saveStarters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sourdough_starters', json.encode(starters.map((e) => e.toJson()).toList()));
  }

  // --- LOGIK ---
  Duration getFeedingInterval(SourdoughStarter s) {
    if (s.fridgeMode) return const Duration(days: 6);
    double t = s.temperature;
    if (t < 18) return const Duration(hours: 36);
    if (t < 22) return const Duration(hours: 24);
    if (t < 25) return const Duration(hours: 16);
    return const Duration(hours: 12);
  }

  double getHungerLevel(SourdoughStarter s) {
    final interval = getFeedingInterval(s);
    final sinceFed = DateTime.now().difference(s.lastFed);
    return min(1.0, sinceFed.inSeconds / interval.inSeconds);
  }

  Map<String, dynamic> getStatus(SourdoughStarter s) {
    final hunger = getHungerLevel(s);
    if (hunger < 0.7) return {"label": "Aktiv", "emoji": "🌱", "color": const Color(0xFF7A8B6F), "text": "Starter ist vital!"};
    if (hunger < 1.0) return {"label": "Hungrig", "emoji": "😋", "color": Colors.orange, "text": "Zeit zu füttern!"};
    return {"label": "Schlapp", "emoji": "🥶", "color": Colors.red, "text": "Dringend füttern!"};
  }

  // --- AKTIONEN ---
  void _addStarter() {
    String name = "";
    String type = "Weizen";
    double temp = 22.0;
    bool fridge = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Neuer Starter", style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: "Name"),
                onChanged: (v) => name = v,
              ),
              DropdownButtonFormField<String>(
                value: type,
                items: ["Weizen", "Roggen", "Dinkel", "Vollkorn"].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => type = v ?? "Weizen",
                decoration: const InputDecoration(labelText: "Mehltyp"),
              ),
              SwitchListTile(
                title: const Text("Kühlschrank"),
                value: fridge,
                onChanged: (v) => setDialogState(() => fridge = v),
              ),
              Text("Temperatur: ${temp.round()}°C"),
              Slider(
                value: temp, min: 4, max: 30, divisions: 26,
                onChanged: (v) => setDialogState(() => temp = v),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Abbrechen")),
            ElevatedButton(
              onPressed: () {
                if (name.isEmpty) return;
                setState(() {
                  starters.add(SourdoughStarter(
                    name: name, type: type, lastFed: DateTime.now(),
                    fridgeMode: fridge, temperature: temp,
                    history: ["Angelegt am ${DateFormat('dd.MM.').format(DateTime.now())}"],
                    feedingPhotos: [],
                  ));
                  _saveStarters();
                });
                Navigator.pop(context);
              },
              child: const Text("Anlegen"),
            ),
          ],
        ),
      ),
    );
  }

  void _feedStarter(int idx, double amount, int ratioIndex) {
    setState(() {
      starters[idx].lastFed = DateTime.now();
      starters[idx].history.insert(0, "Gefüttert: ${DateFormat('dd.MM. HH:mm').format(DateTime.now())}");
      _saveStarters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        title: const Text("Sauerteig Dashboard", style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent, elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.add_circle, size: 30), onPressed: _addStarter)],
      ),
      body: starters.isEmpty
          ? const Center(child: Text("Keine Starter vorhanden."))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: starters.length,
              itemBuilder: (context, idx) => _buildStarterCard(idx),
            ),
    );
  }

  Widget _buildStarterCard(int idx) {
    final s = starters[idx];
    final status = getStatus(s);
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                _buildJarIcon(getHungerLevel(s), status['color']),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text("${s.type} • ${s.temperature.round()}°C"),
                ])),
                IconButton(icon: const Icon(Icons.delete, color: Colors.grey), onPressed: () => setState(() { starters.removeAt(idx); _saveStarters(); })),
              ],
            ),
            const Divider(height: 30),
            SwitchListTile(
              title: const Text("Kühlschrank Modus", style: TextStyle(fontSize: 14)),
              value: s.fridgeMode,
              onChanged: (v) => setState(() { s.fridgeMode = v; _saveStarters(); }),
            ),
            Slider(
              value: s.temperature, min: 4, max: 30, divisions: 26,
              onChanged: (v) => setState(() { s.temperature = v; _saveStarters(); }),
            ),
            const SizedBox(height: 10),
            FeedingCalculator(onFeed: (amt, rIdx) => _feedStarter(idx, amt, rIdx)),
            const SizedBox(height: 20),
            BackplanerWidget(
              starter: s,
              getFeedingInterval: () => getFeedingInterval(s),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJarIcon(double hunger, Color color) {
    return Container(
      width: 40, height: 60,
      decoration: BoxDecoration(border: Border.all(color: color, width: 2), borderRadius: BorderRadius.circular(8)),
      child: Stack(alignment: Alignment.bottomCenter, children: [
        Container(width: 40, height: 60 * (1 - hunger), color: color),
      ]),
    );
  }
}

// --- BACKPLANER WIDGET (DYNAMISCH) ---
class BackplanerWidget extends StatefulWidget {
  final SourdoughStarter starter;
  final Duration Function() getFeedingInterval;
  const BackplanerWidget({required this.starter, required this.getFeedingInterval, super.key});

  @override
  State<BackplanerWidget> createState() => _BackplanerWidgetState();
}

class _BackplanerWidgetState extends State<BackplanerWidget> {
  DateTime? bakeTime;

  @override
  Widget build(BuildContext context) {
    final interval = widget.getFeedingInterval();
    final List<Map<String, dynamic>> plan = bakeTime == null ? [] : [
      {"step": 1, "time": bakeTime!.subtract(interval * 2), "desc": "1. Fütterung"},
      {"step": 2, "time": bakeTime!.subtract(interval), "desc": "Letzte Fütterung"},
      {"step": 3, "time": bakeTime!, "desc": "Backen / Teigstart"},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF7F2EE), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("BACKPLANER", style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () async {
                  final d = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 30)));
                  if (d != null) {
                    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (t != null) setState(() => bakeTime = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                  }
                },
                child: Text(bakeTime == null ? "Datum wählen" : DateFormat('dd.MM. HH:mm').format(bakeTime!)),
              ),
            ],
          ),
          ...plan.map((s) => ListTile(
            dense: true,
            leading: CircleAvatar(radius: 10, child: Text("${s['step']}", style: const TextStyle(fontSize: 10))),
            title: Text(s['desc']),
            trailing: Text(DateFormat('HH:mm').format(s['time']), style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
        ],
      ),
    );
  }
}

// --- FEEDING CALCULATOR ---
class FeedingCalculator extends StatefulWidget {
  final void Function(double, int) onFeed;
  const FeedingCalculator({required this.onFeed, super.key});
  @override
  State<FeedingCalculator> createState() => _FeedingCalculatorState();
}

class _FeedingCalculatorState extends State<FeedingCalculator> {
  double amount = 50;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text("Menge: ${amount.round()}g")),
        Slider(value: amount, min: 10, max: 200, onChanged: (v) => setState(() => amount = v)),
        ElevatedButton(onPressed: () => widget.onFeed(amount, 0), child: const Text("Füttern")),
      ],
    );
  }
}