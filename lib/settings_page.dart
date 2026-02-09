import 'package:flutter/material.dart';
import 'settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool autoAdvance = true;

  @override
  void initState() {
    super.initState();
    SettingsService.getAutoAdvance().then((v) {
      setState(() {
        autoAdvance = v;
      });
    });
  }

  Future<void> _setAutoAdvance(bool v) async {
    await SettingsService.setAutoAdvance(v);
    setState(() => autoAdvance = v);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Auto-Advance ${v ? 'aktiviert' : 'deaktiviert'}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Auto-Advance (nächster Schritt startet automatisch)'),
            value: autoAdvance,
            onChanged: _setAutoAdvance,
            activeThumbColor: Colors.brown,
          ),
        ],
      ),
    );
  }
}
