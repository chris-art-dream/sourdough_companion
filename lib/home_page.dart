import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sourdough Companion'),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
          Icon(Icons.search),
          SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _welcomeCard(),
            const SizedBox(height: 24),
            _sectionTitle('Beliebte Rezepte'),
            _recipePreview('Einfaches Sauerteigbrot', 'Grundrezept für Anfänger'),
            _recipePreview('Weizenmischbrot', 'Klassisches Alltagsbrot'),
            const SizedBox(height: 24),
            _sectionTitle('Tools'),
            Row(
              children: const [
                Expanded(child: _toolCard(Icons.calculate, 'Rechner', 'Zutaten berechnen')),
                SizedBox(width: 12),
                Expanded(child: _toolCard(Icons.timer, 'Timer', 'Aktive Timer')),
              ],
            ),
            const SizedBox(height: 24),
            _sectionTitle('Tipps & Tricks'),
            _tipCard(
              'Raumtemperatur beachten',
              'Die ideale Gärtemperatur liegt bei 24–28°C.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: const Color(0xFFE8D8CF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '👋 Willkommen zurück!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bereit für dein nächstes Brot?',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.play_arrow),
            label: const Text('Jetzt backen starten'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A4A32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _recipePreview(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.bakery_dining, size: 36, color: Color(0xFF7A4A32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _tipCard(String title, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _toolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _toolCard(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: const Color(0xFF7A4A32)),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
