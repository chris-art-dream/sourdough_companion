import 'package:flutter/material.dart';
import '../models/baking_log_model.dart';

class BakingLogPage extends StatefulWidget {
  const BakingLogPage({super.key});

  @override
  State<BakingLogPage> createState() => _BakingLogPageState();
}

class _BakingLogPageState extends State<BakingLogPage> {
  final BakingLogService _logService = BakingLogService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backlog'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: _logService,
        builder: (context, child) {
          if (_logService.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.brown.shade200),
                  const SizedBox(height: 16),
                  const Text(
                    'Noch kein Backlog vorhanden',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Starte einen Backtag und dokumentiere ihn!',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _logService.logs.length,
            itemBuilder: (context, index) {
              final log = _logService.logs[_logService.logs.length - 1 - index];
              return _buildLogCard(log);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewBakingLogPage(
                onSave: (entry) {
                  _logService.addLog(entry);
                  Navigator.pop(context);
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildLogCard(BakingLogEntry log) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: _getRatingColor(log.rating),
          child: Text(
            '${log.rating}⭐',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        title: Text(log.recipeName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Datum: ${log.bakeDate.day}.${log.bakeDate.month}.${log.bakeDate.year}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Teigtemp: ${log.doughTemperature}°C | Hydration: ${log.hydrationPercentage.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            if (log.result.isNotEmpty)
              Text(
                'Ergebnis: ${log.result}',
                style: const TextStyle(fontSize: 11, color: Colors.brown),
              ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BakingLogDetailPage(
                log: log,
                logService: _logService,
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating >= 5) return Colors.green;
    if (rating >= 4) return Colors.lightGreen;
    if (rating >= 3) return Colors.orange;
    return Colors.red;
  }
}

class NewBakingLogPage extends StatefulWidget {
  final Function(BakingLogEntry) onSave;

  const NewBakingLogPage({super.key, required this.onSave});

  @override
  State<NewBakingLogPage> createState() => _NewBakingLogPageState();
}

class _NewBakingLogPageState extends State<NewBakingLogPage> {
  final TextEditingController _recipeNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _roomTempController = TextEditingController();
  final TextEditingController _doughTempController = TextEditingController();
  final TextEditingController _bakeTimeController = TextEditingController();
  final TextEditingController _hydrationController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();

  int _rating = 3;
  List<BakingPhoto> _photos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuer Backtag'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('📖 Rezept-Info', [
              TextField(
                controller: _recipeNameController,
                decoration: InputDecoration(
                  labelText: 'Rezept-Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.menu_book),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('🌡️ Bedingungen', [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _roomTempController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Raumtemp (°C)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _doughTempController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Teigtemp (°C)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _bakeTimeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Backtotal (min)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _hydrationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Hydration (%)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('⭐ Bewertung', [
              Row(
                children: [
                  const Text('Wie war das Brot? '),
                  const Spacer(),
                  ...[1, 2, 3, 4, 5].map((star) => GestureDetector(
                    onTap: () => setState(() => _rating = star),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        star <= _rating ? '⭐' : '☆',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  )),
                ],
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('📝 Notizen & Ergebnis', [
              TextField(
                controller: _resultController,
                decoration: InputDecoration(
                  labelText: 'Ergebnis (z.B. "Perfekt", "Zu trocken")',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Detaillierte Notizen',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  hintText: 'Was hast du gelernt? Worauf solltest du nächstes Mal achten?',
                ),
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection('📸 Fotos (geplant)', [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.brown.shade200),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.brown.shade50,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foto-Timeline wird in nächster Version unterstützt',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Du kannst während des Backvorgangs Fotos machen und sie hier speichern.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveBakingLog,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Backtag speichern',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveBakingLog() {
    if (_recipeNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Rezept-Name eingeben')),
      );
      return;
    }

    final entry = BakingLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipeName: _recipeNameController.text,
      bakeDate: DateTime.now(),
      photos: _photos,
      notes: _notesController.text,
      rating: _rating,
      result: _resultController.text,
      roomTemperature: double.tryParse(_roomTempController.text) ?? 22.0,
      doughTemperature: double.tryParse(_doughTempController.text) ?? 26.0,
      totalBakeTime: int.tryParse(_bakeTimeController.text) ?? 0,
      hydrationPercentage: double.tryParse(_hydrationController.text) ?? 80.0,
    );

    widget.onSave(entry);
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    _notesController.dispose();
    _roomTempController.dispose();
    _doughTempController.dispose();
    _bakeTimeController.dispose();
    _hydrationController.dispose();
    _resultController.dispose();
    super.dispose();
  }
}

class BakingLogDetailPage extends StatelessWidget {
  final BakingLogEntry log;
  final BakingLogService logService;

  const BakingLogDetailPage({
    super.key,
    required this.log,
    required this.logService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(log.recipeName),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              'Datum: ${log.bakeDate.day}.${log.bakeDate.month}.${log.bakeDate.year}',
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Bewertung: ${log.rating}⭐',
              Icons.star,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Teigtemperatur: ${log.doughTemperature}°C',
              Icons.thermostat,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Hydration: ${log.hydrationPercentage.toStringAsFixed(1)}%',
              Icons.water_drop,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              'Backtotal: ${log.totalBakeTime} Minuten',
              Icons.timer,
            ),
            const SizedBox(height: 20),
            if (log.result.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ergebnis',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(log.result),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            if (log.notes.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notizen',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(log.notes),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.brown),
        title: Text(text),
      ),
    );
  }
}
