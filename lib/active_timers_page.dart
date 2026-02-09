import 'package:flutter/material.dart';
import 'timer_service.dart';
import 'timer_model.dart';

class ActiveTimersPage extends StatefulWidget {
  const ActiveTimersPage({super.key});

  @override
  State<ActiveTimersPage> createState() => _ActiveTimersPageState();
}

class _ActiveTimersPageState extends State<ActiveTimersPage> {
  List<RunningTimer> timers = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    timers = await TimerService.loadTimers();
    setState(() {});
  }

  void deleteTimer(int index) async {
    await TimerService.removeTimer(index);
    await load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aktive Timer"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: timers.isEmpty
          ? const Center(
              child: Text("Keine aktiven Timer"),
            )
          : ListView.builder(
              itemCount: timers.length,
              itemBuilder: (context, index) {
                final t = timers[index];

                final remaining = t.endTimestamp -
                    DateTime.now().millisecondsSinceEpoch;

                return Dismissible(
                  key: Key("${t.recipeTitle}-${t.stepIndex}"),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => deleteTimer(index),
                  child: ListTile(
                    title: Text(t.recipeTitle),
                    subtitle: Text(
                      "Schritt ${t.stepIndex + 1} - Rest: ${remaining ~/ 1000}s",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteTimer(index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
