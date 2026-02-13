import 'package:flutter/material.dart';

class SourdoughPage extends StatefulWidget {
  const SourdoughPage({super.key});

  @override
  State<SourdoughPage> createState() => _SourdoughPageState();
}

class _SourdoughPageState extends State<SourdoughPage> {
  String _name = "Sourdough Joe";
  DateTime _letzteFuetterung = DateTime.now().subtract(const Duration(hours: 12));
  String _typ = "Roggen";

  // Berechnet den Gesundheitszustand basierend auf der Zeit
  Map<String, dynamic> _getHealthStatus() {
    final stunden = DateTime.now().difference(_letzteFuetterung).inHours;

    if (stunden < 24) {
      return {
        "label": "Topfit",
        "emoji": "🚀",
        "color": Colors.green,
        "text": "Dein Sauerteig ist bereit für Action!",
      };
    } else if (stunden < 72) {
      return {
        "label": "Hungrig",
        "emoji": "😋",
        "color": Colors.orange,
        "text": "Zeit für einen Snack (Fütterung).",
      };
    } else {
      return {
        "label": "Schlapp",
        "emoji": "😴",
        "color": Colors.red,
        "text": "Er braucht dringend Pflege!",
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _getHealthStatus();

    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        title: const Text("Sauerteig-Status", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusCard(status),
            const SizedBox(height: 30),
            _buildActionCard(),
            const SizedBox(height: 20),
            _buildHistoryPreview(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Map<String, dynamic> status) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: status['color'], width: 2),
        boxShadow: [BoxShadow(color: status['color'].withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Text(status['emoji'], style: const TextStyle(fontSize: 50)),
          const SizedBox(height: 12),
          Text(_name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("Typ: $_typ", style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: status['color'],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status['label'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            status['text'],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF7A4A32),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Letzte Fütterung", style: TextStyle(color: Colors.white70, fontSize: 12)),
                Text("Heute, 08:30 Uhr", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => setState(() => _letzteFuetterung = DateTime.now()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF7A4A32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Füttern"),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Notizen & Verlauf", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.edit_note, color: Color(0xFF7A4A32)),
          title: const Text("Aktivität war gestern extrem hoch"),
          subtitle: const Text("11. Feb 2026"),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        ),
      ],
    );
  }
}